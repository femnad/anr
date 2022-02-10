{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set package_dir = pillar['package_dir'] %}
{% set user = pillar['user'] %}
{% set go_base = pillar['package_dir'] + '/go' %}
{% set go_bin = go_base + '/bin/go' %}

{% for repo in pillar.get('go_install', []) %}
  {% set host = repo.host | default('github.com') %}
  {% set url = host + '/' + repo.name %}
  {% set version = repo.version | default('latest') %}
Go install {{ repo.name}}:
  cmd.run:
    - name: {{ go_bin }} install {{ host }}/{{ repo.name }}@{{ version }}
    {% if repo.unless is defined %}
    - unless:
      - {{ repo.unless }}
    {% endif %}
    - runas: {{ user }}
{% endfor %}
