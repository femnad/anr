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

{% from 'macros.sls' import install_from_archive with context %}

{{ install_from_archive(pillar['arduino'], user) }}

Clone and initialise Keyboardio hardware bundle:
  git.latest:
    - name: https://github.com/keyboardio/Kaleidoscope.git
    - target: {{ clone_dir }}/Kaleidoscope
  cmd.run:
    - name: make setup
    - cwd: {{ clone_dir }}/Kaleidoscope

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

{{ clone_self_repo(repo, user) }}
