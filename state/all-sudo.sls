{% set user = pillar['user'] %}
{% set home = pillar['home'] %}
{% set clone_dir = pillar['clone_dir'] %}
{% set is_fedora = pillar['is_fedora'] %}
{% set package_dir = pillar['package_dir'] %}

Update packages:
  pkg.uptodate:
    - refresh: true

{% if pillar['is_arch'] %}
Break dependency cycles:
  pkg.installed:
    - pkgs:
      - freetype2
      - mesa
      - ffmpeg
{% endif %}

Packages:
  pkg.installed:
    - pkgs: {{ pillar['packages'] | tojson }}

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
    {% elif pillar['is_fedora'] %}
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

{% if pillar['is_arch'] %}
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
        description: Lock on suspend
        before: sleep
        exec: /usr/bin/i3lock -e -c 000000
        wanted_by: sleep
        options:
          User: '%I'
          Type: forking
          Environment: 'DISPLAY=:0'
  service.enabled:
    - name: suspend@{{ user }}
{% endif %}

Clipnotify installed:
  git.cloned:
    - name: https://github.com/cdown/clipnotify.git
    - target: {{ clone_dir }}/clipnotify
  cmd.run:
    - name: make
    - cwd: {{ clone_dir }}/clipnotify
  file.copy:
    - name: /usr/local/bin/clipnotify
    - source: {{ clone_dir }}/clipnotify/clipnotify

{% if is_fedora %}
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

Stumpwm installed:
  cmd.run:
    - name: make install
    - cwd: {{ clone_dir }}/stumpwm
  file.managed:
    - name: /usr/share/xsessions/stumpwm.desktop
    - source: salt://xsessions/stumpwm.desktop
    - makedirs: true
{% endif %}

{% if pillar['is_ubuntu'] %}
Install Spotify:
  cmd.run:
    - name: snap install spotify
{% endif %}

{% if pillar['is_arch'] %}
Enable lxdm:
  service.enabled:
    - name: lxdm
{% endif %}
