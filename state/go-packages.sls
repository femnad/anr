{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set package_dir = pillar['package_dir'] %}
{% set user = pillar['user'] %}
{% set go_base = pillar['package_dir'] + '/go' %}
{% set go_bin = go_base + '/bin/go' %}

{% from 'macros.sls' import install_from_archive with context %}

{{ install_from_archive(pillar['go_release']) }}

{% for pkg in pillar['go_install'] %}
  {% set name = pkg.split('/')[-1].split('.')[0] %}
  {% set target = pillar['clone_dir'] + '/' + name %}
Install Go Package {{ name }}:
  git.latest:
    - name: {{ pkg }}
    - target: {{ target }}
    - force_reset: true
    - user: {{ user }}
  cmd.run:
    - name: {{ go_bin}} install
    - cwd: {{ target }}
    - require:
        - Install go
    - runas: {{ user }}
{% endfor %}

{% for pkg in pillar['go_get'] %}
Go get {{ pkg.pkg }}:
  cmd.run:
    - name: {{ go_bin }} get -u {{ pkg.pkg }}
    - require:
      - Install go
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

{% for pkg in pillar['go_get_gopath'] %}
{% set name = pkg.pkg.split('/')[-1] %}
{% set gopath = pillar['go_path'] %}
Go get {{ pkg.pkg }}:
  environ.setenv:
    - name: GOPATH
    - value: {{ gopath }}
  cmd.run:
    - name: {{ go_bin }} get -u {{ pkg.pkg }}
    - require:
      - Install go
    {% if pkg.unless is defined %}
    - unless:
      - {{ pkg.unless }}
    {% endif %}
    - runas: {{ user }}
{% endfor %}

Unset Gopath:
  environ.setenv:
    - name: GOPATH
    - value: false
    - false_unsets: true

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
