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
{% if pillar['is_debian'] %}
  sysctl.present:
    - name: kernel.unprivileged_userns_clone
    - value: 1
    - config: /etc/sysctl.d/84-userns-clone.conf
{% endif %}

Disable ERTM for Xbox Wireless Controller:
  file.managed:
    - name: /etc/modprobe.d/xbox_bt.conf
    - contents: options bluetooth disable_ertm=1
    - makedirs: true

{% if (grains['gpus'] | selectattr('vendor', 'equalto', 'intel') | list | length) > 0 %}
{% if pillar['is_fedora'] %}
Install Intel VA Driver:
  pkg.installed:
    - name: libva-intel-driver
{% endif %}
{% endif %}
