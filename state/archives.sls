{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set package_dir = pillar['package_dir'] %}
{% set user = pillar['user'] %}

{% from 'macros.sls' import install_from_archive with context %}

{% for archive in pillar['archives'] %}
{{ install_from_archive(archive, user=user) }}
{% endfor %}

{% for archive in pillar['binary_only_archives'] %}
Download binary archive {{ archive.name | default(archive.url) }}:
  archive.extracted:
    - name: {{ home_bin }}
    - source: {{ archive.url }}
    {% if archive.hash is defined %}
    - source_hash: {{ archive.hash }}
    - source_hash_update: true
    {% else %}
    - skip_verify: true
    {% endif %}
    - enforce_toplevel: false
    - overwrite: true
    {% if archive.unless is defined %}
    - unless: {{ archive.unless }}
    {% endif %}
    - user: {{ user }}
    - group: {{ user }}
{% endfor %}
