{% set go_base = pillar['package_dir'] + '/go' %}
{% set go_bin = go_base + '/bin/go' %}
{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set clone_dir = pillar['clone_dir'] %}
{% set is_fedora = pillar['is_fedora'] %}
{% set cargo = home + '/.cargo/bin/cargo' %}
{% set package_dir = pillar['package_dir'] %}
{% set host = grains['host'] %}
{% set user = pillar['user'] %}

Add user to dialout/uucp group:
  user.present:
    - name: {{ pillar['user'] }}
    - groups:
        {% if pillar['is_arch'] %}
        - uucp
        {% else %}
        - dialout
        {% endif %}
    - remove_groups: False

Add udev rule:
  file.managed:
    - name: /etc/udev/rules.d/99-kaleidoscope.rules
    - source: salt://udev/kaleidoscope.rules

Reload udevadm rules:
  cmd.run:
    - name: udevadm control -R
    - onchanges:
        - Add udev rule

{% from 'macros.sls' import install_from_archive with context %}

{{ install_from_archive(pillar['arduino'], user) }}

Clone and initialise Keyboardio hardware bundle:
  git.latest:
    - name: https://github.com/keyboardio/Kaleidoscope.git
    - target: {{ clone_dir }}/Kaleidoscope
    - user: {{ user }}
  cmd.run:
    - name: make setup
    - cwd: {{ clone_dir }}/Kaleidoscope
    - runas: {{ user }}

{% set repo = {
  'repo': 'Model01-Firmware',
  'submodule': true,
  'branch': 'mevorak',
  'remotes': [
    {'url': 'https://github.com/keyboardio/Model01-Firmware',
     'name': 'upstream',}
    ],
} %}

{% from 'macros.sls' import clone_self_repo with context %}

{{ clone_self_repo(repo, user, http_clone=True) }}
