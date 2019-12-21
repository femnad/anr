home: {{ salt.sdb.get('sdb://osenv/HOME') }}
clone_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/gl' }}
self_clone_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/fm' }}
package_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/dy' }}
tmux: {{ salt.sdb.get('sdb://osenv/TMUX') }}
user: {{ salt.sdb.get('sdb://osenv/USER') }}
virtualenv_dir: {{ '.venv' }}

home_dirs:
  - bin
  - x
  - y
  - z

{% set is_arch = grains['os'] == 'Arch' %}
{% set is_fedora = grains['os'] == 'Fedora' %}
{% set is_laptop = grains['manufacturer'] in ['LENOVO', 'Dell Inc.'] %}
{% set is_ubuntu = grains['os'] == 'Ubuntu' %}
{% set github_user = 'femnad' %}

is_arch: {{ is_arch }}
is_fedora: {{ is_fedora }}
is_laptop: {{ is_laptop }}
is_ubuntu: {{ is_ubuntu }}

packages:
  - alsa-utils
  - autoconf
  - ansible
  - cmake
  - colordiff
  - curl
  - dunst
  - dzen2
  - emacs
  - fish
  - gcc
  - gimp
  - git
  - git-crypt
  - highlight
  - htop
  - jq
  - maim
  - make
  - most
  - mutt
  - pass
  - playerctl
  - pwgen
  - qutebrowser
  - rofi
  - ratpoison
  - rlwrap
  - sbcl
  - sxiv
  - strace
  - thunderbird
  - tig
  - tilix
  - tmux
  - texinfo
  - unzip
  - urlview
  - weechat
  - w3m
  - wget
  - whois
  - wireshark
  - xdotool
  - xsel
  - xautolock
  - zathura
  - zathura-pdf-poppler
  - zeal

  {% if not is_arch %}
  - gnupg2
  - python3-boto
  - python3-botocore
  - python3-boto3
  {% endif %}

  {% if is_laptop %}
  - acpi
  {% endif %}

  {% if is_arch %}
  - gnupg
  - ipython
  - python-virtualenv
  - xorg-server
  - lxdm-gtk3
  - man-db
  - man-pages
  - ttf-dejavu
  - vim
  {% endif %}

  {% if is_ubuntu %}
  - ipython3
  - libmnl-dev
  - libnotify-bin
  - libpython3-dev
  - libssl-dev
  - libx11-dev
  - libxcb-screensaver0-dev
  - libxext-dev
  - libxfixes-dev
  - libclang-dev
  - python3-dev
  - resolvconf
  - surfraw
  - vim-gtk3
  - x11proto-dev
  - x11-utils
  - xfonts-terminus
  {% endif %}

  {% if not (is_ubuntu and grains['osmajorrelease'] < 19) %}
  - ripgrep
  {% endif %}

  {% if is_fedora %}
  - ffmpeg
  - gcc-c++
  - git-crypt
  - java-11-openjdk
  - java-11-openjdk-devel
  - kernel-devel
  - kernel-headers
  - libmnl-devel
  - pinentry-gtk
  - podman
  - python3-devel
  - python3-ipython
  - python3-virtualenv
  - openssl-devel
  - vim-X11
  - vim-enhanced
  - libX11-devel
  - libXfixes-devel
  - terminus-fonts
  - xorg-x11-apps
  - xorg-x11-utils
  - xorg-x11-proto-devel
  {% endif %}

  {% if not is_fedora %}
  - firefox
  {% endif %}

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
  - pkg: github.com/aykamko/tag/...
    unless: tag -V
  - pkg: github.com/googlecloudplatform/gcsfuse
    unless: gcsfuse -v
  - pkg: github.com/rclone/rclone
    unless: rclone version

go_cloned_install:
  - url: https://github.com/mikefarah/yq.git
  - url: https://github.com/boz/kail.git
    path: cmd/kail

go_get_gopath:
  - pkg: github.com/junegunn/fzf
    unless: fzf --version

home_bins:
  - url: https://github.com/femnad/loco/releases/download/0.3.4/bakl
    hash: cee33e7caad5634afe6520de60d4a3680f5fafbe92ad3723dc8e01451e0d2dba
  - url: https://github.com/femnad/loco/releases/download/0.3.4/tosm
    hash: b954689a141ede5526de49d3200f36f0323b73922d9f745d3fe0e8b80c0901c0
  - url: https://github.com/femnad/loco/releases/download/0.3.4/ysnp
    hash: d5c90190b23980827fdc4a640eb4d4f7c52e85ff849426a403e9d6d44e2e6369
  - url: https://github.com/femnad/loco/releases/download/0.3.4/zenv
    hash: 07640220819f7e16ad4438dd1e2b2b7cfa978333e2d5e21df98a7ee169fcd7b9
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
  - url: https://az764295.vo.msecnd.net/stable/9579eda04fdb3a9bba2750f15193e5fafe16b959/code-stable-1576089840.tar.gz
    exec: VSCode-linux-x64/code
    clean: true
    hash: 74a4f977daf4315863ef01c08177dc6bc6b235e47684e3943ce1cd50d0123cfe
  # Undetermined weirdness with packaged Firefox ctrl+t behavior in Ratpoison/Stumpwm
  {% if is_fedora %}
  - url: https://download-installer.cdn.mozilla.net/pub/firefox/releases/70.0.1/linux-x86_64/en-US/firefox-70.0.1.tar.bz2
    exec: firefox/firefox
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
  - url: https://releases.hashicorp.com/terraform/0.12.16/terraform_0.12.16_linux_amd64.zip
    hash: fcc719314660adc66cbd688918d13baa1095301e2e507f9ac92c9e22acf4cc02
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

rpmfusion_releases:
  - free
  - nonfree

unlocked:
  rubidium:

xidlehook_options:
  lithium: --not-when-fullscreen

rust_update: false

skip_rpmfusion:
  francium:
