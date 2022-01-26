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
    - user: {{ user }}
  cmd.run:
    - name: make install
    - cwd: {{ pillar['clone_dir'] }}/acpilight
    - unless:
      - xbacklight -list
  group.present:
    - name: brightness
  user.present:
    - name: {{ user }}
    - groups:
        - brightness
    - remove_groups: False
  file.managed:
    - name: /sys/class/backlight/intel_backlight/brightness
    - replace: false
    - group: brightness
    - mode: 0664

Add locker delegate script:
  file.managed:
    - name: /usr/local/bin/lmm-delegate
    - source: {{ home }}/bin/lmm-delegate
    - mode: 0755

Lock on suspend:
  pkg.installed:
    - name: i3lock
  file.managed:
    - name: /etc/systemd/system/i3lock-on-sleep.service
    - source: salt://services/service.j2
    - template: jinja
    - context:
        service:
          unit:
            Before: sleep
          description: Lock on suspend
          executable: /usr/local/bin/lmm-delegate {{ user }}
          wanted_by: sleep
          options:
            Type: forking
          environment:
            DISPLAY: {{ pillar['display'] }}
  service.enabled:
    - name: i3lock-on-sleep

Libinput configured:
  file.managed:
    - name: /etc/X11/xorg.conf.d/30-touchpad.conf
    - source: salt://xorg/touchpad.conf
    - makedirs: true

Add monitor monitor rule:
  file.managed:
    - name: /etc/udev/rules.d/60-monitor-monitor.rules
    - source: salt://udev/monitor-monitor.rules.j2
    - template: jinja

Add monitor delegate script:
  file.managed:
    - name: /usr/local/bin/rdsp-delegate
    - source: {{ home }}/bin/rdsp-delegate
    - mode: 0755
{% endif %} # is_laptop

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

Initialize SBCL config:
  file.managed:
    - name: {{ home }}/.sbclrc
    - user: {{ user }}
    - group: {{ user }}
    - source: salt://config/sbclrc

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
{% endif %} # is_ubuntu

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
{% endif %} # is_debian

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

{% endif %} # is_debian_or_ubuntu

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

Blacklist pcspeaker:
  file.managed:
    - name: /etc/modprobe.d/pcspkr-blacklist.conf
    - contents: blacklist pcspkr

{% endif %} # is_fedora

Persistent Systemd storage enabled for user services:
  file.line:
    - name: /etc/systemd/journald.conf
    - match: '#Storage=(auto|volatile)'
    - mode: replace
    - content: Storage=persistent

{% for package in pillar['global_npm_packages'] %}
Install NPM package {{ package }}:
  cmd.run:
    - name: npm install -g {{ package }}
{% endfor %}
