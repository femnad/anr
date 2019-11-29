{% set go_base = pillar['package_dir'] + '/go' %}
{% set go_bin = go_base + '/bin/go' %}
{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set clone_dir = pillar['clone_dir'] %}
{% set is_fedora = pillar['is_fedora'] %}
{% set cargo = home + '/.cargo/bin/cargo' %}
{% set virtualenv_base = home + '/' + pillar['virtualenv_dir'] %}

{% for dir in pillar['home_dirs'] %}
Home Dir {{ dir }}:
  file.directory:
    - name: {{ home }}/{{ dir }}
    - makedirs: true
{% endfor %}

{% set package_dir = pillar['package_dir'] %}
{% for archive in pillar['archives'] %}
Install {{ archive.name | default(archive.url) }}:
  archive.extracted:
    - name: {{ package_dir }}
    - source: {{ archive.url }}
{% if archive.hash is defined %}
    - source_hash: {{ archive.hash }}
{% else %}
    - skip_verify: true
{% endif %}
{% if archive.clean is defined %}
    - clean: {{ archive.clean }}
{% endif %}
    - trim_output: true
{% set basename = archive.exec.split('/')[-1] %}
  file.symlink:
    - name: {{ home_bin }}/{{ basename }}
    - target: {{ package_dir }}/{{ archive.exec }}
{% endfor %}

rust:
  file.managed:
    - name: {{ pillar['package_dir'] }}/rustup/rustup-init
    - source: https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init
    - makedirs: true
    - mode: 755
    - skip_verify: true
    - unless:
        - {{ cargo }}
  cmd.run:
    - name: "echo 1 | {{ pillar['package_dir'] }}/rustup/rustup-init --no-modify-path"
    - unless:
        - {{ cargo }}

{% for pkg in pillar['go_install'] %}
{% set name = pkg.split('/')[-1].split('.')[0] %}
{% set target = pillar['clone_dir'] + '/' + name %}
Install Go Package {{ name }}:
  git.cloned:
    - name: {{ pkg }}
    - target: {{ target }}
  cmd.run:
    - name: {{ go_bin}} install
    - cwd: {{ target }}
    - require:
        - Install go
{% endfor %}

{% for pkg in pillar['go_get'] %}
Go get {{ pkg }}:
  cmd.run:
    - name: {{ go_bin }} get -u {{ pkg }}
    - require:
      - Install go
{% endfor %}

{% for pkg in pillar['go_get_gopath'] %}
{% set name = pkg.split('/')[-1] %}
{% set gopath = pillar['go_path'] %}
Go get {{ pkg }}:
  environ.setenv:
    - name: GOPATH
    - value: {{ gopath }}
  cmd.run:
    - name: {{ go_bin }} get -u {{ pkg }}
    - require:
      - Install go
  file.copy:
    - name: {{ home_bin }}/{{ name }}
    - source: {{ gopath }}/bin/{{ name }}
{% endfor %}

Unset Gopath:
  environ.setenv:
    - name: GOPATH
    - value: false
    - false_unsets: true

{% for repo in pillar['go_cloned_install'] %}
{% set dir = repo.split('/')[-1].split('.')[0] %}
{% set clone_path = pillar['clone_dir'] + '/' + dir %}
Install Go package from {{ repo }}:
  git.cloned:
    - name: {{ repo }}
    - target: {{ clone_path }}
  cmd.run:
    - name: go install
    - cwd: {{ clone_path }}
{% endfor %}

{% set homeshick_repos = home + '/.homesick/repos' %}
{% set homeshick = homeshick_repos + '/homeshick' %}
{% set homeshick_bin = homeshick + '/bin/homeshick' %}

homeshick:
  git.cloned:
    - name: https://github.com/andsens/homeshick.git
    - target: {{ homeshick }}

{% for castle in pillar['castles'] %}
{% set castle_name = castle.split('/')[-1].split('.')[0] %}
Add castle {{ castle }}:
  git.cloned:
    - name: {{ castle }}
    - target: {{ homeshick_repos + '/' + castle_name }}
  cmd.run:
    - name: {{ homeshick_bin }} link {{ castle_name }}
    - require:
        - homeshick
{% endfor %}

{% for dir in pillar['vim_dirs'] %}
Initialize directory {{ dir }}:
  file.directory:
    - name: {{ home }}/.vim/{{ dir }}
    - makedirs: true
{% endfor %}

VimPlug:
  file.managed:
    - name: {{ home }}/.vim/autoload/plug.vim
    - source: https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    - skip_verify: true
    - makedirs: true
  cmd.run:
    - name: vim -c ":PlugInstall" -c ":quitall"
    - unless:
      - ls {{ home }}/.vim/plugged/YouCompleteMe/third_party/ycmd

Module:
  cmd.run:
    - name: git submodule update --init --recursive
    - cwd: {{ home }}/.vim/plugged/YouCompleteMe
    - require:
      - VimPlug
    - unless:
      - ls {{ home }}/.vim/plugged/YouCompleteMe/third_party/ycmd

YouCompleteMe:
  cmd.run:
    - name: python3 ./install.py --rust-completer --go-completer
    - cwd: {{ home }}/.vim/plugged/YouCompleteMe
    - require:
      - Module
    - unless:
      - ls {{ home }}/.vim/plugged/YouCompleteMe/python/ycm/__pycache__/__init__.cpython-37.pyc

Tilix schemes:
{% set target = pillar['clone_dir'] + '/Tilix-Themes' %}
  git.cloned:
    - name: https://github.com/storm119/Tilix-Themes.git
    - target: {{ target }}
  file.directory:
    - name: {{ home }}/.config/tilix/schemes
    - makedirs: true
  cmd.run:
    - name: find {{ target }} -name '*.json' -exec cp '{}' {{ home }}/.config/tilix/schemes \;

{% for prefix in pillar['mutt_dirs'] %}
  {% for cache in ['header', 'message'] %}
mutt init {{ prefix }} {{ cache }}:
  file.directory:
    - name: {{ home }}/.mutt/{{ prefix }}{{ cache }}
    - makedirs: true
  {% endfor %}
{% endfor %}

{% for archive in pillar['binary_only_archives'] %}
Download binary {{ archive }}:
  archive.extracted:
    - name: {{ home }}/bin
    - source: {{ archive }}
    - skip_verify: true
    - enforce_toplevel: false
{% endfor %}

{% for crate in pillar['cargo'] %}
Cargo install {{ crate.crate }}:
  cmd.run:
    - name: {{ cargo }} install {{ crate.crate }}
    - unless:
        - {{ home }}/.cargo/bin/{{ crate.exec }}
{% endfor %}

{% for bin in pillar['home_bins'] %}
  {% set exec_name = bin.url.split('/')[-1] %}
Download {{ exec_name }}:
  file.managed:
    - name: {{ home_bin }}/{{ exec_name }}
    - source: {{ bin.url }}
    {% if bin.hash is defined %}
    - source_hash: {{ bin.hash }}
    {% else %}
    - skip_verify: true
    {% endif %}
    - makedirs: true
    - mode: 0755
{% endfor %}

Build Ratpoison helpers:
  cmd.run:
    - name: {{ go_bin }} get github.com/femnad/ratilf/cmd/...
    - onlyif:
      - ratpoison -v

Clipmenu cloned:
  git.cloned:
    - name: https://github.com/cdown/clipmenu
    - target: {{ clone_dir }}/clipmenu

{% for bin in ['del', 'menu', 'menud'] %}
Link Clipmenu {{ bin }}:
  file.symlink:
    - name: {{home_bin}}/clip{{ bin }}
    - target: {{ clone_dir }}/clipmenu/clip{{ bin }}
{% endfor %}

{% if is_fedora %}
# unwilligness to investigate flock issues in Fedora
{% for bin in ['del', 'menu', 'menud'] %}
Clipmenu {{ bin }} modified:
  file.line:
    - name: {{ clone_dir }}/clipmenu/clip{{ bin }}
    - mode: insert
    - content: CM_DIR={{ home }}/.cache/clipmenu
    - after: '#!/usr/bin/env bash'
{% endfor %}

Clipmenud cache directory:
  file.directory:
    - name: {{ home }}/.cache/clipmenu
{% endif %}

Clipmenud user service:
  file.managed:
    - name: {{ home }}/.config/systemd/user/clipmenud.service
    - makedirs: True
    - source: salt://services/service.j2
    - template: jinja
    - context:
      service:
        description: Clipmenu daemon
        exec: {{ home_bin }}/clipmenud
        wanted_by: default
        environment:
          - 'DISPLAY=:0'
          {% if is_fedora %}
          - 'CM_DIR={{ home }}/.cache/clipmenu'
          {% endif %}
        options:
          Restart: always
          RestartSec: 500ms
          MemoryDenyWriteExecute: yes
          NoNewPrivileges: yes
          ProtectControlGroups: yes
          ProtectKernelTunables: yes
          RestrictAddressFamilies:
          RestrictRealtime: yes
  cmd.run:
    - name: |
        systemctl --user daemon-reload
        systemctl --user start clipmenud
        systemctl --user enable clipmenud

Lock user service:
  file.managed:
    - name: {{ home }}/.config/systemd/user/xautolock.service
    - makedirs: True
    - source: salt://services/service.j2
    - template: jinja
    - context:
        service:
          description: Xautolock daemon
          exec: /usr/bin/xautolock-time 10 -locker 'i3lock -e -c 000000' -notifier "notify-send 'Heads Up!' 'Locking in 60 seconds'" -detectsleep
          wanted_by: default
          environment:
            - 'DISPLAY=:0'
          options:
            Restart: always
            RestartSec: 5
  cmd.run:
    - name: |
        systemctl --user daemon-reload
        systemctl --user start xautolock
        systemctl --user enable xautolock

Stumpwm contrib:
  git.cloned:
    - name: https://github.com/stumpwm/stumpwm-contrib.git
    - target: {{ clone_dir }}/stumpwm-contrib
  file.symlink:
    - name: {{ home_bin }}/stumpish
    - target: {{ clone_dir }}/stumpwm-contrib/util/stumpish/stumpish

Clone Tmux plugin manager:
  git.cloned:
    - name: https://github.com/tmux-plugins/tpm
    - target: {{ home }}/.tmux/plugins/tpm
  {% if pillar['tmux'].startswith('/tmp/tmux-') %}
  cmd.run:
    - name: tmux run-shell {{ home }}/.tmux/plugins/tpm/bin/install_plugins
  {% endif %}

Clone Tmux thumbs:
  git.cloned:
    {% if is_fedora %}
    - name: https://github.com/femnad/tmux-thumbs
    {% else %}
    - name: https://github.com/fcsonline/tmux-thumbs
    {% endif %}
    - target: {{ home }}/.tmux/plugins/tmux-thumbs
  cmd.run:
    - name: {{ cargo }} build --release
    - cwd: {{ home }}/.tmux/plugins/tmux-thumbs

Load Tilix configuration:
  cmd.run:
    - name: dconf load /com/gexperts/Tilix/ < {{ homeshick_repos }}/homeless/tilix/tilix.dump

{% for key in pillar['github_keys'] %}
Add GitHub key {{ key.id }} as authorized:
  file.append:
    - name: {{ home }}/.ssh/authorized_keys
    - text: {{ key.key }}
{% endfor %}

{% for package in pillar['python_pkgs'] %}
{% set venv = virtualenv_base + '/' + (package.venv | default(package.name)) %}
Install Python package {{ package.name }}:
  virtualenv.managed:
    - name: {{ venv }}
  pip.installed:
    - name: {{ package.name }}
    - bin_env: {{ venv }}
{% endfor %}

Initialize Jedi for Emacs:
  cmd.run:
    - name: emacs -nw --load ~/.emacs --batch --eval '(jedi:install-server)'
    - unless:
      - ls ~/.emacs.d/elpa/jedi-core* -d

{% set pass_helper_path = home + '/go/src/github.com/docker/docker-credential-helpers' %}
Install Docker pass credential helper:
  git.cloned:
    - name: https://github.com/docker/docker-credential-helpers.git
    - target: {{ pass_helper_path }}
  cmd.run:
    - name: {{ go_bin }} build -o {{ home_bin }}/docker-credential-pass pass/cmd/main_linux.go
    - cwd: {{ pass_helper_path }}
