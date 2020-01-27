{% set home = pillar['home'] %}
{% set homeshick_repos = home + '/.homesick/repos/' %}
{% set homeshick_bin = homeshick_repos + 'homeshick/bin/homeshick' %}

{% if grains['host'] == pillar['horde_host'] %}
  {% set repo = pillar['chezmoi_horde'] %}
  {% set path = home + '/' + pillar['chezmoi_horde_path'] %}
{% else %}
  {% set repo = pillar['chezmoi_alliance'] %}
  {% set path = home + '/' + pillar['chezmoi_alliance_path'] %}
{% endif %}
{% set common_repo = pillar['chezmoi_common'] %}
{% set common_path = home + '/' + pillar['chezmoi_common_path'] %}

Set git origin for base:
  module.run:
    - name: git.remote_set
    - cwd: {{ home }}/{{ pillar['chezmoi_base_path'] }}
    - url: {{ pillar['chezmoi_base_repo'].replace('https://gitlab.com/', 'git@gitlab.com:') }}

{% for overlay_repo, overlay_path in [(repo, path), (common_path, common_repo)] %}
Initialize chezmoi overlay {{ overlay_repo }}:
  cmd.run:
    - name: {{ home }}/go/bin/chezmoi init -S {{ overlay_path }} {{ overlay_repo }}
    - unless:
      - ls {{ overlay_path }}

Apply chezmoi overlay {{ overlay_repo }}:
  cmd.run:
    - name: {{ home }}/go/bin/chezmoi apply -S {{ overlay_path }}
{% endfor %}
