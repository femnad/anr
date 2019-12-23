{% if pillar['is_fedora'] %}
Install Steam:
  pkg.installed:
    - name: steam
{% endif %}
