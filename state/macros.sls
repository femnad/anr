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

{% macro install_from_archive(archive) %}
Install {{ archive.name | default(archive.url) }}:
  archive.extracted:
    - name: {{ package_dir }}
    - source: {{ archive.url }}
  {% if archive.hash is defined %}
      - source_hash: {{ archive.hash }}
      - source_hash_update: true
  {% else %}
    - skip_verify: true
  {% endif %}
  {% if archive.clean is defined %}
    - clean: {{ archive.clean }}
  {% endif %}
  {% if archive.format is defined %}
      - archive_format: {{ archive.format }}
  {% endif %}
      - trim_output: true
  {% set basename = archive.exec.split('/')[-1] %}
  file.symlink:
    - name: {{ home_bin }}/{{ basename }}
    - target: {{ package_dir }}/{{ archive.exec }}

{% if archive.bin_links is defined %}
  {% for bin_link in archive.bin_links %}
Link {{ bin_link }}:
  file.symlink:
    - name: {{ home_bin }}/{{ bin_link }}
    - target: {{ package_dir }}/{{ salt['file.dirname'](archive.exec) }}/{{ bin_link }}
  {% endfor %}
{% endif %}
{% endmacro %}
