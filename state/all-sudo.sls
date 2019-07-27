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
