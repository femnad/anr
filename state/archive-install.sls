{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set package_dir = pillar['package_dir'] %}

{% from 'macros.sls' import install_from_archive with context %}

{% for archive in pillar['archives'] %}
{{ install_from_archive(archive) }}
{% endfor %}
