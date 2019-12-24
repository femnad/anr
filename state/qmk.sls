{% set target = pillar['self_clone_dir'] + '/qmk_firmare' %}

Install qmk packages:
  pkg.installed:
     - pkgs: {{ pillar['qmk_packages'] | tojson }}
