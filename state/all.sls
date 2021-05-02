{% set go_base = pillar['package_dir'] + '/go' %}
{% set go_bin = go_base + '/bin/go' %}
{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set clone_dir = pillar['clone_dir'] %}
{% set cargo = home + '/.cargo/bin/cargo' %}
{% set package_dir = pillar['package_dir'] %}
{% set host = grains['host'] %}
{% set user = pillar['user'] %}

{% set is_debian = grains['os'] == 'Debian' %}
{% set is_fedora = pillar['is_fedora'] %}
{% set is_ubuntu = pillar['is_ubuntu'] %}
{% set is_debian_or_ubuntu = is_debian or is_ubuntu %}

{% if pillar['is_laptop'] %}
Acpilight installed:
  git.cloned:
    - name: https://gitlab.com/femnad/acpilight.git
    - target: {{ pillar['clone_dir'] }}/acpilight
    - user: {{ pillar['user'] }}
  cmd.run:
    - name: make install
    - cwd: {{ pillar['clone_dir'] }}/acpilight
    - unless:
      - xbacklight -list
  group.present:
    - name: brightness
  user.present:
    - name: {{ pillar['user'] }}
    - groups:
        - brightness
    - remove_groups: False
  file.managed:
    - name: /sys/class/backlight/intel_backlight/brightness
    - replace: false
    - group: brightness
    - mode: 0664

Lock on suspend:
  pkg.installed:
    - name: i3lock
  file.managed:
    - name: /etc/systemd/system/suspend@.service
    - source: salt://services/service.j2
    - template: jinja
    - context:
        service:
          unit:
            Before: sleep
          description: Lock on suspend
          executable: /usr/bin/i3lock -e -c 000000
          wanted_by: sleep
          options:
            User: '%I'
            Type: forking
          environment:
            DISPLAY: {{ pillar['display'] }}
  service.enabled:
    - name: suspend@{{ user }}

Libinput configured:
  file.managed:
    - name: /etc/X11/xorg.conf.d/30-touchpad.conf
    - source: salt://xorg/touchpad.conf
    - makedirs: true
{% endif %}

Clipmenu installed:
  git.cloned:
    - name: https://github.com/cdown/clipmenu
    - target: {{ clone_dir }}/clipmenu
    - user: {{ user }}
  cmd.run:
    - name: make install
    - cwd: {{ clone_dir }}/clipmenu
    - unless:
      - which clipmenud

Clipnotify installed:
  git.cloned:
    - name: https://github.com/cdown/clipnotify.git
    - target: {{ clone_dir }}/clipnotify
    - user: {{ user }}
  cmd.run:
    - name: make install
    - cwd: {{ clone_dir }}/clipnotify
    - unless:
      - which clipnotify

{% set quicklisp = package_dir + '/quicklisp/quicklisp.lisp' %}
Quicklisp installed:
  file.managed:
    - name: {{ quicklisp }}
    - user: {{ user }}
    - group: {{ user }}
    - source: https://beta.quicklisp.org/quicklisp.lisp
    - source_hash: 4a7a5c2aebe0716417047854267397e24a44d0cce096127411e9ce9ccfeb2c17
    - makedirs: True
  cmd.run:
    - name: "sbcl --load '{{ quicklisp }}' --eval '(quicklisp-quickstart:install)' --non-interactive"
    - runas: {{ user }}
    - unless:
      - ls {{ home }}/.quicklisp

Hide Quicklisp package dir:
  file.rename:
    - name: '{{ home }}/.quicklisp'
    - source: '{{ home }}/quicklisp'
    - unless:
      - ls {{ home }}/.quicklisp

{% for pkg in ['alexandria', 'clx', 'cl-ppcre'] %}
Install Quicklisp package {{ pkg }}:
  cmd.run:
  - name: sbcl --eval '(ql:quickload "{{ pkg }}")' --non-interactive
  - runas: {{ user }}
  - unless:
    - stumpwm --version
  - require:
    - Initialize chezmoi base
{% endfor %}

Stumpwm compiled:
  git.cloned:
    - name: https://github.com/stumpwm/stumpwm.git
    - target: {{ clone_dir }}/stumpwm
    - user: {{ user }}
  cmd.run:
    - name: |
        ./autogen.sh
        ./configure
        make
    - cwd: {{ clone_dir }}/stumpwm
    - runas: {{ user }}
    - require:
      - Initialize chezmoi base
    {% if not pillar.get('stumpwm_update', False) %}
    - unless:
      - stumpwm --version
    {% endif %}

Stumpwm installed:
  cmd.run:
    - name: make install
    - cwd: {{ clone_dir }}/stumpwm
    {% if not pillar.get('stumpwm_update', False) %}
    - unless:
      - stumpwm --version
    {% endif %}
  file.managed:
    - name: /usr/share/xsessions/stumpwm.desktop
    - source: salt://xsessions/stumpwm.desktop
    - makedirs: true

{% if pillar['is_ubuntu'] %}
Install Spotify:
  cmd.run:
    - name: snap install spotify
    - unless:
      - snap list | grep spotify

Enable bitmap fonts:
  file.absent:
    - name: /etc/fonts/conf.d/70-no-bitmaps.conf

Disable ptrace hardening:
  file.absent:
    - name: /etc/sysctl.d/10-ptrace.conf
{% endif %}

{% if pillar['is_debian'] %}
Install Spotify:
  pkgrepo.managed:
    - humanname: spotify
    - name: deb http://repository.spotify.com stable non-free
    - files: /etc/apt/sources.list.d/spotify.list
    - key_url: https://download.spotify.com/debian/pubkey.gpg
  pkg.installed:
    - name: spotify-client

{% set backports = grains['oscodename'] + '-backports' %}
Enable backports repo:
  pkgrepo.managed:
    - name: deb http://ftp.debian.org/debian {{ backports }} main contrib non-free
    - file: /etc/apt/sources.list.d/backports.list

Set default release:
  file.managed:
    - name: /etc/apt/apt.conf.d/10default-release.conf
    - contents: 'APT::Default-Release "{{ backports }}";'
{% endif %} # is Debian?

{% if pillar['is_arch'] %}
Enable lxdm:
  service.enabled:
    - name: lxdm
{% endif %}

Ensure resolv.conf is a symlink:
  file.symlink:
    - name: /etc/resolv.conf
    {% if is_fedora %}
    - target: /run/systemd/resolve/resolv.conf
    {% elif is_ubuntu %}
    - target: /run/resolvconf/resolv.conf
    {% endif %}

{% set hostname = grains['host'] %}

Start and Enable System Resolved:
  service.running:
    - name: systemd-resolved
    - enable: true

{% if pillar['is_debian_or_ubuntu'] %}
Set default Python:
  cmd.run:
    - name: update-alternatives --install /usr/bin/python python $(which python3) 1
    - unless:
      - test $(update-alternatives --display python | tail -n 1 | awk '{print $1}') = $(which python3)

Configure auto upgrades:
  file.managed:
    - name: /etc/apt/apt.conf.d/20auto-upgrades
    - source: salt://config/auto-upgrades

Ensure unattended upgrades configuration:
  file.managed:
    - name: /etc/apt/apt.conf.d/50unattended-upgrades
    - source: salt://config/{{ grains['osfullname'].lower() }}-unattended-upgrades.conf

{% endif %}

Add user to wireshark group:
  group.present:
    - name: wireshark
  user.present:
    - name: {{ user }}
    - groups:
        - wireshark
    - remove_groups: False
  {% if pillar['is_debian_or_ubuntu'] %}
  file.managed:
    - name: /usr/bin/dumpcap
    - group: wireshark
  cmd.run:
    - name: /usr/sbin/setcap cap_net_raw,cap_net_admin+eip /usr/bin/dumpcap
    - unless:
      - /usr/sbin/setcap -v cap_net_raw,cap_net_admin+eip /usr/bin/dumpcap
  {% endif %}

Set Inotify watch limit:
  sysctl.present:
    - name: fs.inotify.max_user_watches
    - value: 524288
    - config: /etc/sysctl.d/83-inotify-max.conf

{% if is_fedora %}
Vimx as the vim provider:
  pkg.removed:
    - name: vim-enhanced
  file.symlink:
    - name: /usr/bin/vim
    - target: /usr/bin/vimx

Enable automated installing of updates:
  file.line:
    - name: /etc/dnf/automatic.conf
    - match: apply_updates = no
    - mode: replace
    - content: apply_updates = yes

Enable dnf automatic:
  service.running:
    - name: dnf-automatic.timer
    - enable: true

{% for module in ['policy', 'discover'] %}
Bluetooth {{ module }} policies for pulseaudio:
  file.append:
    - name: /etc/pulse/system.pa
    - text: load-module module-bluetooth-{{ module }}
{% endfor %}

{% endif %}

Persistent Systemd storage enabled for user services:
  file.line:
    - name: /etc/systemd/journald.conf
    - match: '#Storage=(auto|volatile)'
    - mode: replace
    - content: Storage=persistent

{% set host_specific_xorg_conf = pillar.get('xorg_conf', {}) %}
{% if hostname in host_specific_xorg_conf %}
  {% set config_file = host_specific_xorg_conf[hostname] %}
Add host specific Xorg conf:
  file.managed:
    - name: /etc/X11/xorg.conf.d/{{ config_file }}
    - source: salt://config/{{ config_file }}
    - makedirs: true
{% endif %}

{% if is_fedora %}
Blacklist pcspeaker:
  file.managed:
    - name: /etc/modprobe.d/pcspkr-blacklist.conf
    - contents: blacklist pcspkr
{% endif %}

{% for dir in pillar['home_dirs'] %}
Home Dir {{ dir }}:
  file.directory:
    - name: {{ home }}/{{ dir }}
    - makedirs: true
    - user: {{ user }}
    - group: {{ user }}
{% endfor %}

{% for file in pillar['unwanted_files'] %}
Remove {{ file }}:
  file.absent:
    - name: {{ home }}/{{ file }}
{% endfor %}

{% from 'macros.sls' import install_from_archive with context %}
{% from 'macros.sls' import dirname %}

Enable gsutil:
  cmd.run:
    - name: {{ home_bin }}/gcloud components install gsutil
    - unless:
        file: {{ package_dir }}/google-cloud-sdk/bin/gsutil
  file.symlink:
    - name: {{ home_bin }}/gsutil
      target: {{ package_dir }}/google-cloud-sdk/bin/gsutil

Initialize chezmoi base:
  cmd.run:
    - name: {{ home }}/go/bin/chezmoi init {{ pillar['chezmoi_base_repo'] }}
    - unless:
      - ls {{ home + '/' + pillar['chezmoi_base_path'] }}
    - runas: {{ user }}

Apply chezmoi base:
  cmd.run:
    - name: {{ home }}/bin/chezmoi apply
    - runas: {{ user }}
    - require:
      - Initialize chezmoi base

{% for prefix in pillar['mutt_dirs'] %}
  {% for cache in ['header', 'message'] %}
Mutt init cache directory {{ prefix }} {{ cache }}:
  file.directory:
    - name: {{ home }}/.mutt/{{ prefix }}{{ cache }}
    - makedirs: true
    - user: {{ user }}
    - group: {{ user }}
  {% endfor %}
{% endfor %}

{% for archive in pillar['binary_only_archives'] %}
Download binary archive {{ archive.name | default(archive.url) }}:
  archive.extracted:
    - name: {{ home_bin }}
    - source: {{ archive.url }}
    {% if archive.hash is defined %}
    - source_hash: {{ archive.hash }}
    - source_hash_update: true
    {% else %}
    - skip_verify: true
    {% endif %}
    - enforce_toplevel: false
    - overwrite: true
    {% if archive.unless is defined %}
    - unless: {{ archive.unless }}
    {% endif %}
    - user: {{ user }}
    - group: {{ user }}
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
    - user: {{ user }}
    - group: {{ user }}

{% endfor %}

Stumpwm contrib:
  git.cloned:
    - name: https://github.com/stumpwm/stumpwm-contrib.git
    - target: {{ clone_dir }}/stumpwm-contrib
    - user: {{ user }}
  file.symlink:
    - name: {{ home_bin }}/stumpish
    - target: {{ clone_dir }}/stumpwm-contrib/util/stumpish/stumpish
    - user: {{ user }}
    - group: {{ user }}

Clone Tmux plugin manager:
  git.cloned:
    - name: https://github.com/tmux-plugins/tpm
    - target: {{ home }}/.tmux/plugins/tpm
    - user: {{ user }}
  {% if pillar['tmux'].startswith('/tmp/tmux-') %}
  cmd.run:
    - name: tmux run-shell {{ home }}/.tmux/plugins/tpm/bin/install_plugins
    - runas: {{ user }}
  {% endif %}

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
    - runas: {{ user }}

{% from 'macros.sls' import basename %}

{% for item in pillar['clone_link'] %}
{% set target = clone_dir + '/' + basename(item.repo) %}
{% set link = item.link | default(basename(item.repo)) %}
Clone and link {{ item.repo }}:
  git.latest:
    - name: https://{{ item.host | default('github.com') }}/{{ item.repo }}.git
    - target: {{ target }}
    - user: {{ user }}
  file.symlink:
    - name: {{ home_bin }}/{{ link }}
    - target: {{ target }}/{{ link }}
    - mode: 0755
    - user: {{ user }}
    - group: {{ user }}
{% endfor %}

# fedora: Undetermined weirdness with packaged Firefox ctrl+t behavior in Ratpoison/Stumpwm
# debian: Only firefox-esr
{% if is_fedora or is_debian %}
Copy Firefox desktop file:
  file.managed:
    - name: {{ home }}/.local/share/applications/firefox.desktop
    - source: salt://desktop/firefox.desktop
    - makedirs: true
    - user: {{ user }}
    - group: {{ user }}
{% endif %}
