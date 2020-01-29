home: {{ salt.sdb.get('sdb://osenv/HOME') }}
clone_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/gl' }}
self_clone_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/fm' }}
package_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/dy' }}
tmux: {{ salt.sdb.get('sdb://osenv/TMUX') }}
user: {{ salt.sdb.get('sdb://osenv/USER') }}
virtualenv_dir: {{ '.venv' }}
display: {{ salt.sdb.get('sdb://osenv/DISPLAY') }}

home_dirs:
  - bin
  - x
  - y
  - z

unwanted_dirs:
  - Documents
  - Downloads
  - Music
  - Pictures
  - Public
  - Templates
  - Videos

{% set is_arch = grains['os'] == 'Arch' %}
{% set is_debian = grains['os'] == 'Debian' %}
{% set is_fedora = grains['os'] == 'Fedora' %}
{% set is_laptop = grains['manufacturer'] in ['LENOVO', 'Dell Inc.'] %}
{% set is_ubuntu = grains['os'] == 'Ubuntu' %}
{% set github_user = 'femnad' %}

is_arch: {{ is_arch }}
is_debian: {{ is_debian }}
is_fedora: {{ is_fedora }}
is_laptop: {{ is_laptop }}
is_ubuntu: {{ is_ubuntu }}
is_debian_or_ubuntu: {{ is_debian or is_ubuntu }}

castles:
  - https://gitlab.com/femnad/base.git
  - https://gitlab.com/femnad/basic.git
  - https://gitlab.com/femnad/disposable.git
  - https://github.com/femnad/homebin.git
  - https://gitlab.com/femnad/homeless.git

go_install:
  - https://github.com/zaquestion/lab

go_path: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/sc/go' }}

go_get:
  - pkg: github.com/femnad/stuff/cmd/...
  - pkg: github.com/femnad/rabn/cmd/rabn
    unless: rabn --version
  - pkg: github.com/femnad/moih
    unless: moih --version
    version: 0.1.1
  - pkg: github.com/aykamko/tag/...
    unless: tag -V
  - pkg: github.com/googlecloudplatform/gcsfuse
    unless: gcsfuse -v
  - pkg: github.com/rclone/rclone
    unless: rclone version
  - pkg: github.com/femnad/passfuse
  - pkg: github.com/github/hub
    unless: hub --version

go_cloned_install:
  - name: mikefarah/yq
    unless: yq -V
  - name: boz/kail
    path: cmd/kail
    unless: kail version
  - name: twpayne/chezmoi
    unless: chezmoi --version

go_get_gopath:
  - pkg: github.com/junegunn/fzf
    unless: fzf --version

home_bins:
  - url: https://github.com/femnad/loco/releases/download/0.3.4/bakl
    hash: cee33e7caad5634afe6520de60d4a3680f5fafbe92ad3723dc8e01451e0d2dba
  - url: https://github.com/femnad/loco/releases/download/0.3.4/tosm
    hash: b954689a141ede5526de49d3200f36f0323b73922d9f745d3fe0e8b80c0901c0
  - url: https://github.com/femnad/loco/releases/download/0.4.0/ysnp
    hash: 4316aab0e137b980d96d86a643c5be5eef6f79fa7c0dbc7ea2cc0865c28b4e1d
  - url: https://github.com/femnad/loco/releases/download/0.3.4/zenv
    hash: 07640220819f7e16ad4438dd1e2b2b7cfa978333e2d5e21df98a7ee169fcd7b9
  - url: https://github.com/femnad/loco/releases/download/0.5.2/clom
    hash: 50c84ff06dd72488e18c4e2210064f4be97b38d49fc1b68f7d9be5550aa7f1d1
  - url: https://storage.googleapis.com/kubernetes-release/release/v1.16.0/bin/linux/amd64/kubectl
    hash: 4fc8a7024ef17b907820890f11ba7e59a6a578fa91ea593ce8e58b3260f7fb88

vim_dirs:
  - autoload
  - plugged
  - swap

mutt_dirs:
  - eb
  - fm
  - gm

archives:
  - url: https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz
    exec: go/bin/go
    clean: true
    hash: 0804bf02020dceaa8a7d7275ee79f7a142f1996bfd0c39216ccb405f93f994c0
    name: go
  - url: https://vscode-update.azurewebsites.net/1.41.1/linux-x64/stable
    exec: VSCode-linux-x64/code
    clean: true
    hash: 2a2353ea85b5a3d729e0134ff36b29461bb4264b708786e2486927b7f3c06601
    format: tar
  # Undetermined weirdness with packaged Firefox ctrl+t behavior in Ratpoison/Stumpwm
  {% if is_fedora or is_debian %}
  - url: https://download-installer.cdn.mozilla.net/pub/firefox/releases/72.0.1/linux-x86_64/en-US/firefox-72.0.1.tar.bz2
    exec: firefox/firefox
    hash: 6f81b12986d9b4b45d64b8921009addfae36f49b41b6ba2637402239e71733d6
    clean: true
  {% endif %}
  # 2019.1.4? don't ask
  - url: https://download.jetbrains.com/idea/ideaIC-2019.1.4.tar.gz
    exec: idea-IC-191.8026.42/bin/idea.sh
  - url: https://download.jetbrains.com/go/goland-2019.3.tar.gz
    exec: GoLand-2019.3/bin/goland.sh
  - url: https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz
    exec: google-cloud-sdk/bin/gcloud
    name: gcloud
  - url: https://github.com/crystal-lang/crystal/releases/download/0.32.0/crystal-0.32.0-1-linux-x86_64.tar.gz
    exec: crystal-0.32.0-1/bin/crystal
    bin_links:
      - shards
    hash: 608db8d2a2296792022dad7a351ca96496e2565fbf16ac0172a66f6720d601eb

binary_only_archives:
  - url: https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_linux_amd64.zip
    hash: a549486112f5350075fb540cfd873deb970a9baf8a028a86ee7b4472fc91e167
    name: terraform
  - url: https://releases.hashicorp.com/vault/1.3.0/vault_1.3.0_linux_amd64.zip
    hash: d89b8a317831b06f2a32c56cb86071d058b09d9317b416bb509ce3d01e912eb3
  - url: https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v3.4.0/kustomize_v3.4.0_linux_amd64.tar.gz
    hash: eabfa641685b1a168c021191e6029f66125be94449b60eb12843da8df3b092ba

cargo:
  - crate: fd-find
    unless: fd -V
  {% if (is_ubuntu and grains['osmajorrelease'] < 19) %}
  - crate: ripgrep
  {% endif %}
  - crate: bat
  - crate: git-delta
    unless: delta -V
  {% if is_laptop %}
  - crate: xidlehook
    bins: true
  {% endif %}

github_keys: {{ salt.sdb.get('sdb://github-lookup/keys?user=' + github_user) | tojson }}

python_pkgs:
  - name: git+https://github.com/ranger/ranger.git@1188d40862ebc629e6d29ae879b777437aed7a16
    venv: ranger
    reqs:
      - ueberzug

clone_compile:
  - repo: https://github.com/jpmens/jo.git
    unless: jo -v

rpmfusion_releases:
  - free
  - nonfree

unlocked:
  kalium:
  rubidium:

xidlehook_options:
  lithium: --not-when-fullscreen

rust_update: false

skip_rpmfusion:
  francium:

clone_link:
  - repo: thameera/vimv
  - repo: johanhaleby/kubetail

services_to_disable:
  {% if is_debian %}
  - wicd
  {% endif %}

chezmoi_base_repo: https://gitlab.com/femnad/chezmoi.git
chezmoi_base_path: .local/share/chezmoi
