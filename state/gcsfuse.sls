{% from 'systemd-macros.sls' import systemd_user_service with context %}

{% set home = pillar['home'] %}
{% set go_bin = home + '/go/bin' %}

{% set passfuse_gcsfuse_exec = go_bin + '/passfuse -p ' + pillar['passfuse_prefix'] + ' -m ' + home + pillar['passfuse_mount_path'] %}

{{ systemd_user_service('passfuse-gcsfuse', 'passfuse for gcsfuse', passfuse_gcsfuse_exec, {'StopWhenUnneeded': 'true'}, enabled=False, started=False) }}

{% set gcsfuse_unit = {'BindsTo': 'passfuse-gcsfuse.service', 'After': 'passfuse-gcsfuse.service'} %}
{% set gcsfuse_exec = go_bin + '/gcsfuse --foreground ' + pillar['gcsfuse_bucket'] + ' ' + home + pillar['gcsfuse_mount_path'] %}
{% set gcsfuse_env = {'GOOGLE_APPLICATION_CREDENTIALS': home + pillar['gcsfuse_credentials_file']} %}
{% set gcsfuse_options = {'Restart': 'on-failure', 'ExecStartPre': 'mkdir -p ' + home + pillar['gcsfuse_mount_path']} %}

{{ systemd_user_service('gcsfuse', 'GCSFuse', gcsfuse_exec, gcsfuse_unit, gcsfuse_env, gcsfuse_options, enabled=False, started=False) }}
