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

Accept key:
  ssh_known_hosts.present:
    - name: gitlab.com
    - fingerprint: HbW3g8zUjNSksFbqTiUWPWg2Bq1x8xdGUrliXFzSnUw
    - fingerprint_hash_type: sha256

Initialize chezmoi override:
  cmd.run:
    - name: {{ home }}/go/bin/chezmoi init -S {{ path }} {{ repo }}
    - unless:
      - ls {{ path }}

Apply chezmoi override:
  cmd.run:
    - name: {{ home }}/go/bin/chezmoi apply -S {{ path }}
