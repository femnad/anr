{% set home = pillar['home'] %}

{% macro systemd_user_service(name, description, executable, user, unit={}, environment={}, options={}, enabled=True, started=True) %}
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
    - user: {{ user }}
    - group: {{ user }}

{% if enabled %}
Service {{ name }} enabled:
  cmd.run:
    - name: |
        systemctl --user daemon-reload
        systemctl --user enable {{ name }}
    - runas: {{ user }}
    - unless:
        - test $(systemctl --user is-enabled {{ name }}) = enabled
  {% if user is not none %}
    - runas: {{ user }}
  {% endif %}

{% endif %}

{% if started %}
Service {{ name }} started:
  cmd.run:
    - name: |
        systemctl --user daemon-reload
        systemctl --user start {{ name }}
    - runas: {{ user }}
    - unless:
        - test $(systemctl --user is-active {{ name }}) = active
  {% if user is not none %}
    - runas: {{ user }}
  {% endif %}
{% endif %}

{% endmacro %}

{% macro systemd_user_timer(name, description, enabled=True, started=True, realtime=True, period=None, directives=None) %}
Ensure definition for timer {{ name }}:
  file.managed:
    - name: {{ home }}/.config/systemd/user/{{ name }}.timer
    - makedirs: True
    - source: salt://services/timer.j2
    - template: jinja
    - context:
        timer:
          description: {{ description }}
          realtime: {{ realtime }}
          period: {{ period }}
          directives: {{ directives }}
  {% if user is not none %}
    - user: {{ user }}
    - group: {{ user }}
  {% endif %}

{% if enabled %}
Timer {{ name }} enabled:
  cmd.run:
    - name: |
        systemctl --user daemon-reload
        systemctl --user enable {{ name }}.timer
  {% if user is not none %}
    - runas: {{ user }}
  {% endif %}
    - unless:
        - test $(systemctl --user is-enabled {{ name }}.timer) = enabled
{% endif %}

{% if started %}
Timer {{ name }} started:
  cmd.run:
    - name: |
        systemctl --user daemon-reload
        systemctl --user start {{ name }}.timer
  {% if user is not none %}
    - runas: {{ user }}
  {% endif %}
    - unless:
        - test $(systemctl --user is-active {{ name }}.timer) = active
{% endif %}

{% endmacro %}

{% macro ensure_user_service(name) %}
Enable {{ name }}:
  cmd.run:
    - name: systemctl --user enable {{ name }}
    - unless:
        - test $(systemctl --user is-enabled {{ name }}) = enabled
Start {{ name }}:
  cmd.run:
    - name: systemctl --user start {{ name }}
    - unless:
        - test $(systemctl --user is-active {{ name }}) = active
{% endmacro %}
