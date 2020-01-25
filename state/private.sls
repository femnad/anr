{% set home = pillar['home'] %}
{% set homeshick_repos = home + '/.homesick/repos/' %}
{% set homeshick_bin = homeshick_repos + 'homeshick/bin/homeshick' %}

{% for castle in pillar['private_castles'] %}
{% set castle_name = castle.split('/')[-1].split('.')[0] %}
Add castle {{ castle }}:
  git.cloned:
    - name: {{ castle }}
    - target: {{ homeshick_repos + castle_name }}
{% endfor %}

{% if grains['host'] == pillar['horde_host'] %}
  {% set repo = pillar['chezmoi_horde'] %}
  {% set path = home + '/' + pillar['chezmoi_horde_path'] %}
{% else %}
  {% set repo = pillar['chezmoi_alliance'] %}
  {% set path = home + '/' + pillar['chezmoi_alliance_path'] %}
{% endif %}

Initialize chezmoi override:
  cmd.run:
    - name: {{ home }}/go/bin/chezmoi init {{ repo }}
    - unless:
      - ls {{ path }}

Apply chezmoi override:
  cmd.run:
    - name: {{ home }}/go/bin/chezmoi apply -S {{ path }}
