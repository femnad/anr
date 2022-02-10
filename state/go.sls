{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set package_dir = pillar['package_dir'] %}
{% set user = pillar['user'] %}
{% set go_base = pillar['package_dir'] + '/go' %}
{% set go_bin = go_base + '/bin/go' %}

{% for pkg in pillar['go_get'] %}
Go get {{ pkg.pkg }}:
  cmd.run:
    - name: {{ go_bin }} get -u {{ pkg.pkg }}
    {% if pkg.unless is defined %}
    - unless:
      {% if pkg.version is defined %}
      - test {{ pkg.unless }} = {{ pkg.version }}
      {% else %}
      - {{ pkg.unless }}
      {% endif %}
    {% endif %}
    - runas: {{ user }}
{% endfor %}

{% for repo in pillar['go_cloned_install'] %}
  {% set host = repo.host | default('github.com') %}
  {% set url = 'https://' + host + '/' + repo.name + '.git' %}
  {% set dir = url.split('/')[-1].split('.')[0] %}
  {% set clone_path = pillar['clone_dir'] + '/' + dir %}
Go clone install {{ repo.name}}:
  git.latest:
    - name: {{ url }}
    - target: {{ clone_path }}
    - force_reset: true
    {% if repo.unless is defined %}
    - unless:
        - {{ repo.unless }}
    {% endif %}
    - user: {{ user }}
  cmd.run:
    - name: {{ go_bin }} install
    {% if repo.path is defined %}
    - cwd: {{ clone_path }}/{{ repo.path }}
    {% else %}
    - cwd: {{ clone_path }}
    {% endif %}
    {% if repo.unless is defined %}
    - unless:
      - {{ repo.unless }}
    {% endif %}
    - runas: {{ user }}
{% endfor %}

{% for repo in pillar.get('go_install', []) %}
  {% set host = repo.host | default('github.com') %}
  {% set url = host + '/' + repo.name %}
  {% set version = repo.version | default('latest') %}
Go install {{ repo.name}}:
  cmd.run:
    - name: {{ go_bin }} install {{ repo.name }}@{{ version }}
    {% if repo.unless is defined %}
    - unless:
      - {{ repo.unless }}
    {% endif %}
    - runas: {{ user }}
{% endfor %}
