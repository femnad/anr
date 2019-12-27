Install qmk packages:
  pkg.installed:
     - pkgs: {{ pillar['qmk_packages'] | tojson }}
