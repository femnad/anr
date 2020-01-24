{% if pillar['is_fedora'] %}
Install Steam:
  pkg.installed:
    - name: steam
{% elif pillar['is_ubuntu'] %}
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
