{% set firefox_version = '80.0' %}
{% set crystal_version = '0.34.0' %}
{% set goland_version = '2020.2.2' %}
{% set pycharm_version = '2020.2.1' %}
{% set vscode_version = '1.49.2' %}

package_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/dy' }}

archives:
  - url: https://vscode-update.azurewebsites.net/{{ vscode_version }}/linux-x64/stable
    exec: VSCode-linux-x64/bin/code
    clean: true
    format: tar
    unless: test $(code --version) = {{ vscode_version }}
  # fedora: Undetermined weirdness with packaged Firefox ctrl+t behavior in Ratpoison/Stumpwm
  # debian: Only firefox-esr
  {% if is_fedora or is_debian %}
  - url: https://download-installer.cdn.mozilla.net/pub/firefox/releases/{{ firefox_version }}/linux-x86_64/en-US/firefox-{{ firefox_version }}.tar.bz2
    exec: firefox/firefox
    clean: true
    unless: which firefox
  {% endif %}
  - url: https://download.jetbrains.com/idea/ideaIC-2020.2.1.tar.gz
    exec: idea-IC-202.6948.69/bin/idea.sh
  - url: https://download.jetbrains.com/go/goland-{{ goland_version }}.tar.gz
    exec: GoLand-{{ goland_version }}/bin/goland.sh
  - url: https://download-cf.jetbrains.com/python/pycharm-community-{{ pycharm_version }}.tar.gz
    exec: pycharm-community-{{ pycharm_version }}/bin/pycharm.sh
  - url: https://github.com/crystal-lang/crystal/releases/download/{{ crystal_version }}/crystal-{{ crystal_version }}-1-linux-x86_64.tar.gz
    exec: crystal-{{ crystal_version }}-1/bin/crystal
    bin_links:
      - shards
  - url: https://github.com/cli/cli/releases/download/v1.0.0/gh_1.0.0_linux_amd64.tar.gz
    exec: gh_1.0.0_linux_amd64/bin/gh

{% set terraform_version = '0.13.3' %}
{% set vault_version = '1.3.0' %}

binary_only_archives:
  - url: https://releases.hashicorp.com/terraform/{{ terraform_version }}/terraform_{{ terraform_version }}_linux_amd64.zip
    hash: 602d2529aafdaa0f605c06adb7c72cfb585d8aa19b3f4d8d189b42589e27bf11
    name: terraform
    unless: test $(terraform version) == 'Terraform v{{ terraform_version }}'

gcloud_package:
  url: https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz
  exec: google-cloud-sdk/bin/gcloud
  name: gcloud

{% set go = {
  'version': '1.15',
  'checksum': '2d75848ac606061efe52a8068d0e647b35ce487a15bb52272c427df485193602',
  }
%}

go_release:
  url: https://dl.google.com/go/go{{ go.version }}.linux-amd64.tar.gz
  exec: go/bin/go
  clean: true
  hash: {{ go.checksum }}
  name: go

