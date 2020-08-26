{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set clone_dir = pillar['clone_dir'] %}
{% set user = pillar['user'] %}

Install qmk packages:
  pkg.installed:
     - pkgs: {{ pillar['qmk_packages'] | tojson }}

Add Udev rule for teensy:
  file.managed:
    - name: /etc/udev/rules.d/49-teensy.rules
    - source: salt://udev/teensy.rules.j2
    - template: jinja
    - context:
      user: {{ pillar['user'] }}

Reload teensy udevadm rules:
  cmd.run:
    - name: udevadm control -R
    - onchanges:
        - Add Udev rule for teensy

{% if pillar['is_debian_or_ubuntu'] %}
Uninstall modem manager:
  pkg.removed:
    - name: modemmanager
{% endif %}

{% if pillar['is_fedora'] %}
Compile teensy_cli:
  git.latest:
    - name: https://github.com/PaulStoffregen/teensy_loader_cli.git
    - target: {{ clone_dir }}/teensy_loader_cli
    - user: {{ user }}
  cmd.run:
    - name: make
    - cwd: {{ clone_dir }}/teensy_loader_cli
    - runas: {{ user }}
  file.copy:
    - name: {{ home_bin }}/teensy_loader_cli
    - source: {{ clone_dir }}/teensy_loader_cli/teensy_loader_cli
{% endif %}

{% set repo = {
  'repo': 'qmk_firmware',
  'submodule': true,
  'remotes': [
    {
      'url': 'git@github.com:qmk/qmk_firmware.git',
       'name': 'upstream',
    }
  ],
  'force': true,
} %}

{% from 'macros.sls' import clone_self_repo with context %}

{{ clone_self_repo(repo, user) }}
