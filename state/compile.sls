{% set user = pillar['user'] %}
{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set clone_dir = pillar['clone_dir'] %}

{% for cc in pillar['clone_compile'] %}
{% set name = cc.repo.split('/')[-1].split('.')[0] %}
{% set dir = clone_dir + '/' + name %}

Compile {{ name }}:
  git.cloned:
    - name: {{ cc.repo }}
    - target: {{ clone_dir }}/{{ name }}
    - user: {{ user }}
  cmd.run:
    - name: |
        autoreconf -i
        ./configure
        make
    - cwd: {{ dir }}
    - runas: {{ user }}

Install {{ name }}:
  cmd.run:
    - name: make install
    - cwd: {{ dir }}

{% endfor %}
