{% set homeshick_repos = home + '/.homesick/repos' %}
{% set homeshick = homeshick_repos + '/homeshick' %}
{% set homeshick_bin = homeshick + '/bin/homeshick' %}
{% set home = pillar['home'] %}

{% for castle in pillar['castles'] %}
{% set castle_name = castle.split('/')[-1].split('.')[0] %}
Add castle {{ castle }}:
  git.cloned:
    - name: {{ castle }}
    - target: {{ homeshick_repos + '/' + castle_name }}
  cmd.run:
    - name: {{ homeshick_bin }} link -b {{ castle_name }}
    - required:
        - homeshick
{% endfor %}
