{% set home = pillar['home'] %}
{% set user = pillar['user'] %}

{% for dir in pillar['vim_dirs'] %}
Initialize directory {{ dir }}:
  file.directory:
    - name: {{ home }}/.vim/{{ dir }}
    - makedirs: true
    - user: {{ user }}
    - group: {{ user }}
{% endfor %}
