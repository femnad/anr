{% set user = pillar['user'] %}
{% set home = pillar['home'] %}
{% set clone_dir = pillar['clone_dir'] %}
{% set is_fedora = pillar['is_fedora'] %}
{% set package_dir = pillar['package_dir'] %}

Pamixer compiled:
  git.cloned:
    - name: https://github.com/cdemoulins/pamixer.git
    - target: {{ pillar['clone_dir'] }}/pamixer
    - user: {{ pillar['user'] }}
  pkg.installed:
    - pkgs:
    {% if pillar['is_arch'] %}
        - boost
        - boost-libs
        - libpulse
    {% elif is_fedora %}
        - boost-devel
        - boost-program-options
        - pulseaudio-libs-devel
    {% else %}
        - libboost-program-options-dev
        - libpulse-dev
    {% endif %}
  file.directory:
    - name: /usr/local/man/man1
    - makedirs: True
  cmd.run:
    - name: make
    - runas: {{ pillar['user'] }}
    - cwd: {{ pillar['clone_dir'] }}/pamixer
    - unless:
      - pamixer

Pamixer installed:
  cmd.run:
    - name: make install
    - cwd: {{ pillar['clone_dir'] }}/pamixer
    - unless:
      - pamixer

{% if pillar['is_arch'] or (pillar['is_ubuntu'] and grains['osrelease'] == '19.10') %}
Ratpoison Session file:
  file.managed:
    - name: /usr/share/xsessions/ratpoison.desktop
    - source: salt://xsessions/ratpoison.desktop
    - makedirs: true
{% endif %}

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

Clipnotify installed:
  git.cloned:
    - name: https://github.com/cdown/clipnotify.git
    - target: {{ clone_dir }}/clipnotify
  cmd.run:
    - name: make
    - cwd: {{ clone_dir }}/clipnotify
    - unless:
      - which clipnotify
  file.copy:
    - name: /usr/local/bin/clipnotify
    - source: {{ clone_dir }}/clipnotify/clipnotify

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
      - ls {{ home }}/quicklisp

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
    - unless:
      - stumpwm --version

Stumpwm installed:
  cmd.run:
    - name: make install
    - cwd: {{ clone_dir }}/stumpwm
    - unless:
      - stumpwm --version
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
{% endif %}

{% if pillar['is_arch'] %}
Enable lxdm:
  service.enabled:
    - name: lxdm
{% endif %}

Compile WireGuard:
{% set wireguard = clone_dir + '/WireGuard' %}
{% set wireguard_source = wireguard + '/src' %}
  git.latest:
    - name: git://git.zx2c4.com/wireguard-linux-compat
    - target: {{ wireguard }}
    - user: {{ user }}
    - unless:
      - ls /usr/lib/modules/$(uname -r)/extra/wireguard.ko
  cmd.run:
    - name: make
    - cwd: {{ wireguard_source }}
    - runas: {{ user }}
    - unless:
      - ls /usr/lib/modules/$(uname -r)/extra/wireguard.ko

Install WireGuard:
  cmd.run:
    - name: make install
    - require:
        - Compile WireGuard
    - cwd: {{ wireguard_source }}
    - unless:
      - ls /usr/lib/modules/$(uname -r)/extra/wireguard.ko

Ensure resolv.conf is a symlink:
  file.symlink:
    - name: /etc/resolv.conf
    - target: /run/systemd/resolve/stub-resolv.conf
    - force: true

Add DNS stub file:
  file.managed:
    - name: /etc/systemd/resolved.conf.d/dns-servers.conf
    - source: salt://resolved/dns-servers.conf
    - makedirs: true

Start and Enable System Resolved:
  service.running:
    - name: systemd-resolved
    - enable: true
    - watch:
      - file: /etc/systemd/resolved.conf.d/*

{% if pillar['is_debian_or_ubuntu'] %}
Set default Python:
  cmd.run:
    - name: update-alternatives --install /usr/bin/python python $(which python3) 1
    - unless:
      - test $(update-alternatives --display python | tail -n 1 | awk '{print $1}') = $(which python3)
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
{% endif %}

Persistent Systemd storage enabled for user services:
  file.line:
    - name: /etc/systemd/journald.conf
    - match: '#Storage=(auto|volatile)'
    - mode: replace
    - content: Storage=persistent
