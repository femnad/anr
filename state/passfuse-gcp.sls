{% from 'macros.sls' import systemd_user_service with context %}

{% set home = pillar['home'] %}
{% set go_bin = home + '/go/bin' %}

{% set passfuse_gcp_exec = go_bin + '/passfuse -p ' + pillar['passfuse_prefix'] + ' -m ' + home + pillar['passfuse_mount_path'] + ' -u 600' %}
{{ systemd_user_service('passfuse-gcp', 'passfuse for GCP', passfuse_gcp_exec, enabled=False, started=False) }}
