{% if pillar['is_arch'] %}
Break dependency cycles:
  pkg.latest:
    - pkgs:
      - freetype2
      - mesa
      - ffmpeg
{% endif %}

Packages:
  pkg.latest:
    - pkgs: {{ pillar['packages'] | tojson }}
