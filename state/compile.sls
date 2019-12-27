{% set user = pillar['user'] %}
{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set clone_dir = pillar['clone_dir'] %}

{% for cc in pillar['clone_compile'] %}
{% set name = cc.repo.split('/')[-1].split('.')[0] %}
{% set dir = clone_dir + '/' + name %}

Compile {{ name }}:
  git.latest:
    - name: {{ cc.repo }}
    - target: {{ clone_dir }}/{{ name }}
    - user: {{ user }}
    {% if cc.unless is defined %}
    - unless:
      - {{ cc.unless }}
    {% endif %}
  cmd.run:
    - name: |
        autoreconf -i
        ./configure
        make
    - cwd: {{ dir }}
    - runas: {{ user }}
    {% if cc.unless is defined %}
    - unless:
      - {{ cc.unless }}
    {% endif %}

Install {{ name }}:
  cmd.run:
    - name: make install
    - cwd: {{ dir }}
    {% if cc.unless is defined %}
    - unless:
      - {{ cc.unless }}
    {% endif %}

{% endfor %}
