{% if pillar['is_arch'] %}
Break dependency cycles:
  pkg.latest:
    - pkgs:
      - freetype2
      - mesa
      - ffmpeg
{% endif %}

Up-to-date packages:
  pkg.uptodate:
    - refresh: true

Packages:
  pkg.installed:
    - pkgs: {{ pillar['packages'] | tojson }}
