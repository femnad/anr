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

Pamixer:
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
  cmd.run:
    - name: make
    - runas: {{ pillar['user'] }}
    - cwd: {{ pillar['clone_dir'] }}/pamixer

Pamixer installed:
  cmd.run:
    - name: make install
    - cwd: {{ pillar['clone_dir'] }}/pamixer

{% if pillar['is_arch'] %}
Ratpoison Session file:
  file.managed:
    - name: /usr/share/xsessions
    - source: salt://xsessions/ratpoison.desktop.j2
    - makedirs: true
{% endif %}
