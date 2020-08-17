{% if pillar['is_arch'] %}
Break dependency cycles:
  pkg.latest:
    - pkgs:
      - freetype2
      - mesa
      - ffmpeg
{% endif %}

{% if pillar['is_fedora'] and grains['host'] not in pillar['skip_rpmfusion'] %}
{% for release in pillar['rpmfusion_releases'] %}
Add Rpmfusion release {{ release }}:
  cmd.run:
    - name: dnf install -y https://download1.rpmfusion.org/{{ release }}/fedora/rpmfusion-{{ release }}-release-{{ grains['osrelease'] }}.noarch.rpm
    - unless:
        - dnf list installed | grep rpmfusion-{{ release }}-release
{% endfor %}
{% endif %}

Up-to-date packages:
  pkg.uptodate:
    - refresh: true

Packages:
  pkg.installed:
    - pkgs: {{ pillar['packages'] | tojson }}
