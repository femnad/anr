{% set home = pillar['home'] %}

{% macro systemd_user_service(name, description, executable, unit={}, environment={}, options={}, enabled=True, started=True) %}
Ensure definition for service {{ name }}:
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

{% if enabled %}
Service {{ name }} enabled:
  cmd.run:
    - name: |
        systemctl --user daemon-reload
        systemctl --user enable {{ name }}
    - unless:
        - test $(systemctl --user is-enabled {{ name }}) = enabled
{% endif %}

{% if started %}
Service {{ name }} started:
  cmd.run:
    - name: |
        systemctl --user daemon-reload
        systemctl --user start {{ name }}
    - unless:
        - test $(systemctl --user is-active {{ name }}) = active
{% endif %}

{% endmacro %}

{% macro basename(path) -%}
{{ path.split('/')[-1] }}
{%- endmacro %}
