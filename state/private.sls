{% set home = pillar['home'] %}
{% set homeshick_repos = home + '/.homesick/repos/' %}
{% set homeshick_bin = homeshick_repos + 'homeshick/bin/homeshick' %}

{% set common_repo = pillar['chezmoi_common'] %}
{% set common_path = home + '/' + pillar['chezmoi_common_path'] %}

{% set user = pillar['user'] %}

Fetch private key for host:
  cmd.run:
    - name: {{ home }}/bin/moih get --keysecret {{ pillar['moih_key_secret'] }} --bucketname {{ pillar['moih_bucket_name'] }}

{% for host in ['github.com', 'gitlab.com'] %}
Accept host key for {{ host }}:
  cmd.script:
    - source: salt://scripts/accept-host-keys.sh
    - args: {{ host }}
{% endfor %}

Set git origin for base:
  cmd.script:
    - source: salt://scripts/https-to-git.sh
    - cwd: {{ home }}/{{ pillar['chezmoi_base_path'] }}
    - unless:
      - git remote get-url origin | grep git@

{% for overlay_repo, overlay_path in [(common_repo, common_path)] %}
Initialize chezmoi overlay {{ overlay_repo }}:
  cmd.run:
    - name: {{ home }}/bin/chezmoi init -S {{ overlay_path }} {{ overlay_repo }}
    - unless:
      - ls {{ overlay_path }}

Apply chezmoi overlay {{ overlay_repo }}:
  cmd.run:
    - name: {{ home }}/bin/chezmoi apply -S {{ overlay_path }}
{% endfor %}
