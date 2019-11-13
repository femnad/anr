{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set package_dir = pillar['package_dir'] %}

Download Shadow:
  archive.extracted:
    - name: {{ package_dir }}/shadow
    - source: https://update.shadow.tech/launcher/prod/linux/ubuntu_18.04/Shadow.zip
    - skip_verify: true
    - enforce_toplevel: false
  file.symlink:
    - name: {{ home_bin }}/shadow
    - target: {{ package_dir }}/shadow/Shadow.AppImage
    - makedirs: true
