{% set user = pillar['user'] %}
{% set home = pillar['home'] %}

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
    - name: /usr/share/xsessions
    - source: salt://xsessions/ratpoison.desktop.j2
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