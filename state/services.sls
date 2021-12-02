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

{% set xidlehook_socket = pillar['xidlehook_socket'] %}

{% set xidlehook_exec = home + "/.cargo/bin/xidlehook --timer 600 '" + home_bin + "/lock-me-maybe' ''" %}
{% set xidlehook_env = default_display_env %}
{% set xidlehook_options = {'Restart': 'always', 'RestartSec': 5} %}

Ensure xidlehook socket dir:
  file.directory:
    - name: {{ dirname(xidlehook_socket) }}
    - makedirs: true

{{ systemd_user_service('xidlehook', 'Xidlehook daemon', xidlehook_exec, user, environment=xidlehook_env, options=xidlehook_options) }}

{% if pillar['is_laptop'] %}

{% set rojo_options = {'Restart': 'always', 'RestartSec': 5} %}
{% set rojo_bin = home_bin + '/rojo -w 10 -c 5 -a poweroff' %}
{{ systemd_user_service('rojo', 'Upower based battery monitoring script', rojo_bin, user, environment=default_display_env, options=rojo_options) }}

{% endif %} # is laptop

{% from 'systemd-macros.sls' import ensure_user_service %}

{% if is_fedora %}
{{ ensure_user_service('pulseaudio') }}
{% endif %}

{{ ensure_user_service('clipmenud') }}
{{ ensure_user_service('ssh-agent') }}
{% set ssh_agent_env = {'SSH_AUTH_SOCK': '%t/ssh-agent.socket'} %}
{{ systemd_user_service('ssh-agent', 'SSH authentication agent', '/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK', user, environment=ssh_agent_env) }}
