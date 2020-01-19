Remove unwanted packages:
  pkg.removed:
    - pkgs: {{ pillar['packages_to_remove'] | default([]) | tojson }}
