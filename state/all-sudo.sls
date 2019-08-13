{% set user = pillar['user'] %}
{% set home = pillar['home'] %}

Update packages:
  pkg.update:
    - refresh: true

Packages:
  pkg.installed:
    - names: {{ pillar['packages'] }}

Pamixer:
  git.cloned:
    - name: https://github.com/cdemoulins/pamixer.git
    - target: {{ pillar['clone_dir'] }}/pamixer
    - user: {{ pillar['user'] }}
  pkg.installed:
    - names:
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

Python 3 Headers:
  pkg.installed:
    - names:
        - python3-dev
        - libpython3-dev

Python linked to Python3:
  file.symlink:
    - name: /usr/bin/python
    - target: /usr/bin/python3

Virtualenv:
  pkg.installed:
    - name: python-virtualenv

{% for pkg in pillar['python'] %}
Install {{ pkg.name }}:
  virtualenv.managed:
    - name: {{ home }}/.venv/{{ pkg.name }}
    - user: {{ user }}
    - python: /usr/bin/python3
    - require:
        - Virtualenv
  pip.installed:
    - name: {{ pkg.package }}
    - user: {{ user }}
    - bin_env: {{ home }}/.venv/{{ pkg.name }}/bin/pip3
{% endfor %}
