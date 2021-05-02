{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set clone_dir = pillar['clone_dir'] %}
{% set self_clone_dir = pillar['self_clone_dir'] %}
{% set is_fedora = pillar['is_fedora'] %}
{% set host = grains['host'] %}
{% set user = pillar['user'] %}

{% set default_display_env = {'DISPLAY': ':0'} %}

{% from 'macros.sls' import dirname %}
{% from 'systemd-macros.sls' import systemd_user_service with context %}

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

{% from 'systemd-macros.sls' import ensure_user_service %}

{% if is_fedora %}
{{ ensure_user_service('pulseaudio') }}
{% endif %}

{{ ensure_user_service('clipmenud') }}
{{ ensure_user_service('ssh-agent') }}
