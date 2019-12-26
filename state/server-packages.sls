Packages:
  pkg.installed:
    - pkgs: {{ pillar['packages'] | tojson }}
