{% for repo in pillar.get('go_install', []) %}
  {% set host = repo.host | default('github.com') %}
  {% set url = host + '/' + repo.name %}
  {% set version = repo.version | default('latest') %}
Go install {{ repo.name}}:
  cmd.run:
    - name: go install {{ host }}/{{ repo.name }}@{{ version }}
    {% if repo.unless is defined %}
    - unless:
      - {{ repo.unless }}
    {% endif %}
{% endfor %}
