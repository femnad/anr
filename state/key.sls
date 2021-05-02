{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}

Fetch private key for host:
  cmd.run:
    - name: {{ home_bin }}/moih get --keysecret {{ pillar['moih_key_secret'] }} --bucketname {{ pillar['moih_bucket_name'] }}
