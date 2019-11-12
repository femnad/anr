{% set home = pillar['home'] %}
{% set homeshick_repos = home + '/.homesick/repos/' %}
{% set homeshick_bin = homeshick_repos + 'homeshick/bin/homeshick' %}


{% for castle in pillar['private_castles'] %}
{% set castle_name = castle.split('/')[-1].split('.')[0] %}
Add castle {{ castle }}:
  git.cloned:
    - name: {{ castle }}
    - target: {{ homeshick_repos + castle_name }}
  cmd.run:
    - name: {{ homeshick_bin }} link -b {{ castle_name }}
    - required:
        - homeshick
{% endfor %}
