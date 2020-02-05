Remove unwanted packages:
  pkg.removed:
    - pkgs: {{ pillar['packages_to_remove'] | default([]) | tojson }}

{% for service in pillar.get('service_to_disable', []) %}
Stop and disable unwanted service {{ service }}:
  - service.dead:
    - name: {{ service }}
    - enabled: false
{% endfor %}
