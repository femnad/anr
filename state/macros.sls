{% set home = pillar['home'] %}

{% macro systemd_user_service(name, description, executable, unit={}, environment={}, options={}) %}
Running service {{ name }}:
  file.managed:
    - name: {{ home }}/.config/systemd/user/{{ name }}.service
    - makedirs: True
    - source: salt://services/service.j2
    - template: jinja
    - context:
      service:
        unit: {{ unit }}
        description: {{ description }}
        executable: {{ executable }}
        wanted_by: default
        environment: {{ environment }}
        options: {{ options }}
{% endmacro %}
