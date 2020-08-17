{% if pillar['is_fedora'] %}
Install Steam:
  pkg.installed:
    - name: steam
{% elif pillar['is_debian_or_ubuntu'] %}

  {% if pillar['is_debian'] %}
Enable i386 architecture:
  cmd.run:
    - name: dpkg --add-architecture i386
    - unless:
      - dpkg --print-architecture | grep i386
  {% endif %}

Install Steam:
  pkg.installed:
    - sources:
      - steam: https://repo.steampowered.com/steam/archive/precise/steam_latest.deb
Install Steam dependencies:
  pkg.installed:
    - pkgs:
      - libgl1-mesa-dri:i386
      - libgl1-mesa-glx:i386
      - libc6:i386
{% endif %}

Disable ERTM for Xbox Wireless Controller:
  file.managed:
    - name: /etc/modprobe.d/xbox_bt.conf
    - contents: options bluetooth disable_ertm=1
    - makedirs: true
