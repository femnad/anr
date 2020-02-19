Remove unwanted packages:
  pkg.removed:
    - pkgs: {{ pillar.get('packages_to_remove', []) | tojson }}

{% for service in pillar.get('service_to_disable', []) %}
Stop and disable unwanted service {{ service }}:
  - service.dead:
    - name: {{ service }}
    - enabled: false
{% endfor %}
