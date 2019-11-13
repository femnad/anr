{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set package_dir = pillar['package_dir'] %}
{% set user = pillar['user'] %}

Download Shadow:
  archive.extracted:
    - name: {{ package_dir }}/shadow
    - source: https://update.shadow.tech/launcher/prod/linux/ubuntu_18.04/Shadow.zip
    - skip_verify: true
    - enforce_toplevel: false
    - user: {{ user }}
    - group: {{ user }}
  file.symlink:
    - name: {{ home_bin }}/shadow
    - target: {{ package_dir }}/shadow/Shadow.AppImage
    - makedirs: true
    - user: {{ user }}
    - group: {{ user }}

Disable ERTM for Xbox Wireless Controller:
  file.line:
    - name: /etc/modprobe.d/xbox_bt.conf
    - mode: ensure
    - content: options bluetooth disable_ertm=1
    - create: true
