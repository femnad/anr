{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set clone_dir = pillar['clone_dir'] %}
{% set is_fedora = pillar['is_fedora'] %}
{% set host = grains['host'] %}

{% from 'macros.sls' import systemd_user_service with context %}

Clipmenu cloned:
  git.cloned:
    - name: https://github.com/cdown/clipmenu
    - target: {{ clone_dir }}/clipmenu

{% for bin in ['del', 'menu', 'menud'] %}
Link Clipmenu {{ bin }}:
  file.symlink:
    - name: {{home_bin}}/clip{{ bin }}
    - target: {{ clone_dir }}/clipmenu/clip{{ bin }}
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

{{ systemd_user_service('clipmenud', 'Clipmenud daemon', clipmenud_exec, environment=clipmenud_env, options=clipmenud_options) }}

{% if pillar['is_laptop'] %}
  {% if host not in pillar['unlocked'] %}
    {% set host_specific_options = pillar['xidlehook_options'].get(host, None) %}
    {% if host_specific_options == None %}
      {% set xidlehook_exec = home + "/.cargo/bin/xidlehook --timer 600 'i3lock -e -c 000000' ''" %}
    {% else %}
      {% set xidlehook_exec = home + "/.cargo/bin/xidlehook --timer 600 'i3lock -e -c 000000' '' " + host_specific_options %}
    {% endif %}
    {% set xidlehook_env = default_display_env %}
    {% set xidlehook_options = {'Restart': 'always', 'RestartSec': 5} %}

{{ systemd_user_service('xidlehook', 'Xidlehook daemon', xidlehook_exec, environment=xidlehook_env, options=xidlehook_options) }}

  {% endif %} # host not unlocked

  {% set rossa_dir = clone_dir + '/rossa' %}
Rossa compiled:
  git.cloned:
    - name: https://github.com/femnad/rossa.git
    - target: {{ rossa_dir }}
    - unless:
        - rossa -v
  cmd.run:
    - name: make
    - cwd: {{ rossa_dir }}
    - unless:
        - rossa -v

Rossa installed:
  cmd.run:
    - name: make install
    - cwd: {{ rossa_dir }}
    - unless:
        - rossa -v

  {% set rossa_env = default_display_env %}
  {% set rossa_options = {'Restart': 'always', 'RestartSec': 5} %}
  {% set rossa_exec = home_bin + '/rossa' %}

{{ systemd_user_service('rossa', 'Rossa daemon', rossa_exec, environment=rossa_env, options=rossa_options) }}

{% endif %} # is laptop

{{ systemd_user_service('dsnt', 'dsnt daemon', 'ssh -N dsnt', started=False, enabled=False) }}

{% set clom_options = {
  'Restart': 'always',
  'RestartSec': '5s',
  } %}

{{ systemd_user_service('clom', 'clom service', home_bin + '/clom clone_loop', environment=default_display_env, options=clom_options) }}