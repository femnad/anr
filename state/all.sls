{% set go_base = pillar['package_dir'] + '/go' %}
{% set go_bin = go_base + '/bin/go' %}
{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set clone_dir = pillar['clone_dir'] %}
{% set is_fedora = pillar['is_fedora'] %}
{% set cargo = home + '/.cargo/bin/cargo' %}
{% set package_dir = pillar['package_dir'] %}
{% set host = grains['host'] %}

{% for dir in pillar['home_dirs'] %}
Home Dir {{ dir }}:
  file.directory:
    - name: {{ home }}/{{ dir }}
    - makedirs: true
{% endfor %}

{% for archive in pillar['archives'] %}
Install {{ archive.name | default(archive.url) }}:
  archive.extracted:
    - name: {{ package_dir }}
    - source: {{ archive.url }}
{% if archive.hash is defined %}
    - source_hash: {{ archive.hash }}
    - source_hash_update: true
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

Enable gsutil:
  {% set gcloud_bin = (pillar['archives'] | selectattr('name', 'defined') | selectattr('name', 'equalto', 'gcloud') | list)[0].exec.split('/')[:-1] | join('/') %}
  cmd.run:
    - name: {{ home_bin }}/gcloud components install gsutil
    - require:
      - Install gcloud
  file.symlink:
    - name: {{ home_bin }}/gsutil
      target: {{ package_dir }}/{{ gcloud_bin }}/gsutil

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
Go get {{ pkg.pkg }}:
  cmd.run:
    - name: {{ go_bin }} get -u {{ pkg.pkg }}
    - require:
      - Install go
    {% if pkg.unless is defined %}
    - unless:
      - {{ pkg.unless }}
    {% endif %}
{% endfor %}

{% for pkg in pillar['go_get_gopath'] %}
{% set name = pkg.pkg.split('/')[-1] %}
{% set gopath = pillar['go_path'] %}
Go get {{ pkg.pkg }}:
  environ.setenv:
    - name: GOPATH
    - value: {{ gopath }}
  cmd.run:
    - name: {{ go_bin }} get -u {{ pkg.pkg }}
    - require:
      - Install go
    {% if pkg.unless is defined %}
    - unless:
      - {{ pkg.unless }}
    {% endif %}
{% endfor %}

Unset Gopath:
  environ.setenv:
    - name: GOPATH
    - value: false
    - false_unsets: true

{% for repo in pillar['go_cloned_install'] %}
{% set dir = repo.url.split('/')[-1].split('.')[0] %}
{% set clone_path = pillar['clone_dir'] + '/' + dir %}
Install Go package from {{ repo.url }}:
  git.cloned:
    - name: {{ repo.url }}
    - target: {{ clone_path }}
  cmd.run:
    - name: {{ go_bin }} install
    {% if repo.path is defined %}
    - cwd: {{ clone_path }}/{{ repo.path }}
    {% else %}
    - cwd: {{ clone_path }}
    {% endif %}
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
Download binary archive {{ archive.name | default(archive.url) }}:
  archive.extracted:
    - name: {{ home }}/bin
    - source: {{ archive.url }}
    {% if archive.hash is defined %}
    - source_hash: {{ archive.hash }}
    - source_hash_update: true
    {% else %}
    - skip_verify: true
    {% endif %}
    - enforce_toplevel: false
    - overwrite: true
{% endfor %}

{% for crate in pillar['cargo'] %}
Cargo install {{ crate.crate }}:
  cmd.run:
    - name: {{ cargo }} install {{ crate.crate }}{% if crate.bins is defined and crate.bins %} --bins{% endif %}
    - unless:
        - {{ home }}/.cargo/bin/{{ crate.exec | default(crate.crate) }}
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

{% if pillar['is_laptop'] and host not in pillar['unlocked'] %}
Disable Xautolock:
  cmd.run:
    - name: |
        systemctl --user disable xautolock
        systemctl --user stop xautolock

{% set host_specific_options = pillar['xidlehook_options'].get(host, None) %}
Lock user service:
  file.managed:
    - name: {{ home }}/.config/systemd/user/xidlehook.service
    - makedirs: True
    - source: salt://services/service.j2
    - template: jinja
    - context:
        service:
          description: Xidlehook daemon
          exec: {{ home }}/.cargo/bin/xidlehook --timer 600{% if host_specific_options != None %} 'i3lock -e -c 000000' '' {{ ' '.join(host_specific_options) }}{% endif %}
          wanted_by: default
          environment:
            - 'DISPLAY=:0'
          options:
            Restart: always
            RestartSec: 5
  cmd.run:
    - name: |
        systemctl --user daemon-reload
        systemctl --user enable xidlehook
        systemctl --user start xidlehook
{% endif %}

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
    - unless:
      - {{ home }}/.tmux/plugins/tmux-thumbs/target/release/tmux-thumbs

Load Tilix configuration:
  cmd.run:
    - name: dconf load /com/gexperts/Tilix/ < {{ homeshick_repos }}/homeless/tilix/tilix.dump

{% for key in pillar['github_keys'] %}
Add GitHub key {{ key.id }} as authorized:
  file.append:
    - name: {{ home }}/.ssh/authorized_keys
    - text: {{ key.key }}
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
    - unless:
      - {{ home_bin }}/docker-credential-pass version
  cmd.run:
    - name: {{ go_bin }} build -o {{ home_bin }}/docker-credential-pass pass/cmd/main_linux.go
    - cwd: {{ pass_helper_path }}
    - unless:
      - {{ home_bin }}/docker-credential-pass version
