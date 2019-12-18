{% set home = pillar['home'] %}
{% set virtualenv_base = home + '/' + pillar['virtualenv_dir'] %}

{% for package in pillar['python_pkgs'] %}
{% set venv = virtualenv_base + '/' + (package.venv | default(package.name)) %}
Install Python package {{ package.name }}:
  virtualenv.managed:
    - name: {{ venv }}
  pip.installed:
    - name: {{ package.name }}
    - bin_env: {{ venv }}

{% if package.reqs is defined %}
{% for req in package.reqs %}
Install requirement {{ req }}:
  pip.installed:
    - name: {{ req }}
    - bin_env: {{ venv }}
{% endfor %}
{% endif %}
{% endfor %}
