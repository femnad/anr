{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set clone_dir = pillar['clone_dir'] %}
{% set self_clone_dir = pillar['self_clone_dir'] %}
{% set is_fedora = pillar['is_fedora'] %}
{% set host = grains['host'] %}

{% from 'systemd-macros.sls' import systemd_user_service with context %}
{% from 'macros.sls' import dirname %}

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

{% set clom_options = {
  'Restart': 'always',
  'RestartSec': '5s',
  } %}

{{ systemd_user_service('clom', 'clom service', home_bin + '/clom clone_loop', environment=default_display_env, options=clom_options) }}

{{ systemd_user_service('update-gcloud-fish-completions', 'Update gcloud fish completions', '{}/gcloud-fish-completions/update-completions.sh'.format(self_clone_dir), started=False, enabled=False) }}

{% from 'systemd-macros.sls' import systemd_user_timer with context %}
{{ systemd_user_timer('update-gcloud-fish-completions', 'Update gcloud fish completions', period='daily') }}
