Remove unwanted packages:
  pkg.removed:
    - pkgs: {{ pillar['packages_to_remove'] | default([]) | tojson }}

Stop and disable unwanted services:
  {% for service in pillar['service_to_disable'] %}
  - service.dead:
    - name: {{ service }}
    - enabled: false
  {% endfor %}
