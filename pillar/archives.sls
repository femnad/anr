{% set firefox_version = '97.0' %}
{% set gh_version = '2.5.0' %}
{% set goland_version = '2021.3.3' %}
{% set tectonic_version = '0.8.0' %}
{% set terraform_version = '1.1.5' %}

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
    unless:
      file: {{ package_dir }}/firefox/firefox
  {% endif %}
  - url: https://download.jetbrains.com/go/goland-{{ goland_version }}.tar.gz
    exec: GoLand-{{ goland_version }}/bin/goland.sh
    unless:
      file: {{ package_dir }}/GoLand-{{ goland_version }}/bin/goland.sh
  - url: https://github.com/cli/cli/releases/download/v{{ gh_version }}/gh_{{ gh_version }}_linux_amd64.tar.gz
    exec: gh_{{ gh_version }}_linux_amd64/bin/gh
    unless: test $(gh --version 2>/dev/null | grep 'gh version' | awk '{print $3}') = {{ gh_version }}
  - url: https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz
    exec: google-cloud-sdk/bin/gcloud
    unless: gcloud --version

binary_only_archives:
  - url: https://releases.hashicorp.com/terraform/{{ terraform_version }}/terraform_{{ terraform_version }}_linux_amd64.zip
    unless: test $(terraform version | awk '{print $2}') == 'v{{ terraform_version }}'
    name: terraform
  - url: https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic%40{{ tectonic_version }}/tectonic-{{ tectonic_version }}-x86_64-unknown-linux-gnu.tar.gz
    unless: test $(tectonic --version | awk '{print $2}') = {{ tectonic_version }}
    name: tectonic
