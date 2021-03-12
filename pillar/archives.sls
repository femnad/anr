{% set firefox_version = '86.0.1' %}
{% set crystal_version = '0.34.0' %}
{% set gh_version = '1.5.0' %}
{% set goland_version = '2020.3' %}
{% set pycharm_version = '2020.2.1' %}
{% set tectonic_version = '0.4.1' %}
{% set vscode_version = '1.52.0' %}

{% set is_debian = grains['os'] == 'Debian' %}
{% set is_fedora = grains['os'] == 'Fedora' %}

{# why no work? #}
{#{% set package_dir = salt.sdb.get('sdb://osenv/home') %}#}

{% set package_dir = '/home/femnad/z/dy' %}
package_dir: {{ package_dir }}

archives:
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
    unless: stat {{ package_dir }}/idea-IC-202.6948.69/bin/idea.sh
  - url: https://download.jetbrains.com/go/goland-{{ goland_version }}.tar.gz
    exec: GoLand-{{ goland_version }}/bin/goland.sh
    unless: stat {{ package_dir }}/GoLand-{{ goland_version }}/bin/goland.sh
  - url: https://download-cf.jetbrains.com/python/pycharm-community-{{ pycharm_version }}.tar.gz
    exec: pycharm-community-{{ pycharm_version }}/bin/pycharm.sh
    unless: stat {{ package_dir }}/pycharm-community-{{ pycharm_version }}/bin/pycharm.sh
  - url: https://github.com/cli/cli/releases/download/v{{ gh_version }}/gh_{{ gh_version }}_linux_amd64.tar.gz
    exec: gh_{{ gh_version }}_linux_amd64/bin/gh
    unless: test $(gh --version 2>/dev/null | grep 'gh version' | awk '{print $3}') = {{ gh_version }}

{% set terraform_version = '0.13.3' %}
{% set vault_version = '1.3.0' %}

binary_only_archives:
  - url: https://releases.hashicorp.com/terraform/{{ terraform_version }}/terraform_{{ terraform_version }}_linux_amd64.zip
    name: terraform
    unless: test $(terraform version) == 'Terraform v{{ terraform_version }}'
  - url: https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic%400.4.1/tectonic-0.4.1-x86_64-unknown-linux-gnu.tar.gz
    unless: test $(tectonic --version | awk '{print $2}') = {{ tectonic_version }}

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

