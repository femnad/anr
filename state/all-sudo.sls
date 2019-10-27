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
        - libboost-program-options-dev
        - libpulse-dev
  cmd.run:
    - name: make
    - runas: {{ pillar['user'] }}
    - cwd: {{ pillar['clone_dir'] }}/pamixer

Pamixer installed:
  cmd.run:
    - name: make install
    - cwd: {{ pillar['clone_dir'] }}/pamixer

{% if not pillar['is_arch'] %}
Python 3 Headers:
  pkg.installed:
    - pkgs:
        - python3-dev
        - libpython3-dev
{% endif %}

Virtualenv:
  pkg.installed:
    - name: python-virtualenv
