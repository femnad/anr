{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set clone_dir = pillar['clone_dir'] %}
{% set self_clone_dir = pillar['self_clone_dir'] %}
{% set is_fedora = pillar['is_fedora'] %}
{% set host = grains['host'] %}
{% set user = pillar['user'] %}

{% from 'macros.sls' import dirname %}
{% from 'systemd-macros.sls' import systemd_user_service with context %}

Clipmenu cloned:
  git.cloned:
    - name: https://github.com/cdown/clipmenu
    - target: {{ clone_dir }}/clipmenu
    - user: {{ user }}

{% for bin in ['ctl', 'del', 'menu', 'menud'] %}
Link Clipmenu {{ bin }}:
  file.symlink:
    - name: {{home_bin}}/clip{{ bin }}
    - target: {{ clone_dir }}/clipmenu/clip{{ bin }}
    - user: {{ user }}
    - group: {{ user }}
{% endfor %}

{% if is_fedora %}
  # unwilligness to investigate flock issues in Fedora
  {% for bin in ['del', 'menu', 'menud'] %}
Clipmenu {{ bin }} modified:
  file.line:
    - name: {{ clone_dir }}/clipmenu/clip{{ bin }}
    - mode: insert
    - content: CM_DIR={{ home }}/.cache/clipmenu
    - after: '#!/usr/bin/env bash'
    - user: {{ user }}
    - group: {{ user }}
  {% endfor %}

Clipmenud cache directory:
  file.directory:
    - name: {{ home }}/.cache/clipmenu
{% endif %}

{% set default_display_env = {'DISPLAY': ':0'} %}

{% if is_fedora %}
  {% set clipmenud_env = {'DISPLAY': ':0', 'CM_DIR': home + '/.cache/clipmenu'} %}
{% else %}
  {% set clipmenud_env = default_display_env %}
{% endif %}

{% set clipmenud_options = {
  'Restart': 'always',
  'RestartSec': '500ms',
  'MemoryDenyWriteExecute': 'yes',
  'NoNewPrivileges': 'yes',
  'ProtectControlGroups': 'yes',
  'ProtectKernelTunables': 'yes',
  'RestrictAddressFamilies': '',
  'RestrictRealtime': 'yes',
} %}
{% set clipmenud_exec = home_bin + '/clipmenud' %}

{{ systemd_user_service('clipmenud', 'Clipmenud daemon', clipmenud_exec, user, environment=clipmenud_env, options=clipmenud_options) }}

{% if pillar['is_laptop'] %}

  {% set xidlehook_socket = pillar['xidlehook_socket'] %}

  {% if host not in pillar['unlocked'] %}
    {% set xidlehook_exec = home + "/.cargo/bin/xidlehook --timer 600 '" + home_bin + "/lock-me-maybe' ''" %}
    {% set host_specific_options = pillar['xidlehook_options'].get(host, None) %}
    {% if host_specific_options is not none %}
      {% set xidlehook_exec = xidlehook_exec + ' ' + host_specific_options %}
    {% endif %}
    {% set xidlehook_env = default_display_env %}
    {% set xidlehook_options = {'Restart': 'always', 'RestartSec': 5} %}

Ensure xidlehook socket dir:
  file.directory:
    - name: {{ dirname(xidlehook_socket) }}
    - makedirs: true

{{ systemd_user_service('xidlehook', 'Xidlehook daemon', xidlehook_exec, user, environment=xidlehook_env, options=xidlehook_options) }}

  {% endif %} # host not unlocked

{{ systemd_user_service('rojo', 'Upower based battery monitoring script', home_bin + '/rojo', user, environment=default_display_env) }}

{% endif %} # is laptop

{% if is_fedora %}
Enable pulseaudio:
  cmd.run:
    - name: systemctl --user enable pulseaudio
    - unless:
        - test $(systemctl --user is-enabled pulseaudio) = enabled
Start pulseaudio:
  cmd.run:
    - name: systemctl --user enable pulseaudio
    - unless:
        - test $(systemctl --user is-active pulseaudio) = active
{% endif %}
