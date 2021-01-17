{% set home = pillar['home'] %}
{% set user = pillar['user'] %}
{% set virtualenv_base = home + '/' + pillar['virtualenv_dir'] %}

{% for package in pillar.get('python_pkgs', []) %}
{% set venv = virtualenv_base + '/' + (package.venv | default(package.name)) %}
Install Python package {{ package.name }}:
  virtualenv.managed:
    - name: {{ venv }}
    - user: {{ user }}
  pip.installed:
    - name: {{ package.name }}
    - bin_env: {{ venv }}
    - user: {{ user }}

{% if package.reqs is defined %}
{% for req in package.reqs %}
Install requirement {{ req }}:
  pip.installed:
    - name: {{ req }}
    - bin_env: {{ venv }}
    - user: {{ user }}
{% endfor %}
{% endif %}
{% endfor %}
