Latex packages installed:
  pkg.installed:
    - pkgs: {{ pillar['latex_packages'] | tojson }}
