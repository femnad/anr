{% set go_base = pillar['package_dir'] + '/go' %}
{% set go_bin = go_base + '/bin/go' %}
{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set clone_dir = pillar['clone_dir'] %}
{% set is_fedora = pillar['is_fedora'] %}

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
{% if archive.exec is defined and archive.exec_dir is defined %}
  file.symlink:
    - name: {{ home_bin }}/{{ archive.exec }}
    - target: {{ package_dir }}/{{ archive.exec_dir }}/{{ archive.exec }}
{% endif %}
{% endfor %}

rust:
  file.managed:
    - name: {{ pillar['package_dir'] }}/rustup/rustup-init
    - source: https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init
    - makedirs: true
    - mode: 755
    - skip_verify: true
    - unless:
        - cargo
  cmd.run:
    - name: "echo 1 | {{ pillar['package_dir'] }}/rustup/rustup-init"
    - unless:
        - cargo

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
    - name: {{ homeshick_bin }} link -f {{ castle_name }}
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

Module:
  cmd.run:
    - name: git submodule update --init --recursive
    - cwd: {{ home }}/.vim/plugged/YouCompleteMe
    - require:
      - VimPlug

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
    - name: {{ home }}/.cargo/bin/cargo install {{ crate.crate }}
    - unless:
        - {{ home }}/.cargo/bin/{{ crate.exec }}
{% endfor %}

{% for bin in pillar['home_bins'] %}
  {% set exec_name = bin.split('/')[-1] %}
Download {{ exec_name }}:
  file.managed:
    - name: {{ home_bin }}/{{ exec_name }}
    - source: {{ bin }}
    - skip_verify: true
    - makedirs: true
    - mode: 0755
    - unless:
      - {{ exec_name }}
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
Clipmenu {{ bin }} linked:
  file.line:
    - name: {{ clone_dir }}/clipmenu/clip{{ bin }}
    - mode: insert
    - content: CM_DIR={{ home }}/.cache/clipmenu
    - after: '#!/usr/bin/env bash'
{% endfor %}

{% if is_fedora %}
{% for bin in ['del', 'menu', 'menud'] %}
Edit Clipmenu {{ bin }}:
  file.symlink:
    - name: {{home_bin}}/clip{{ bin }}
    - target: {{ clone_dir }}/clipmenu/clip{{ bin }}
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

Load Tilix configuration:
  cmd.run:
    - name: dconf load /com/gexperts/Tilix/ < {{ homeshick_repos }}/homeless/tilix/tilix.dump