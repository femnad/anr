home: {{ salt.sdb.get('sdb://osenv/HOME') }}
clone_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/gl' }}
package_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/dy' }}
tmux: {{ salt.sdb.get('sdb://osenv/TMUX') }}

home_dirs:
  - bin
  - x
  - y
  - z

{% set is_arch = grains['os'] == 'Arch' %}
{% set is_fedora = grains['os'] == 'Fedora' %}
{% set is_laptop = grains['manufacturer'] in ['LENOVO'] %}
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
  - firefox
  - gcc
  - htop
  - jq
  - make
  - mutt
  - pass
  - rofi
  - ratpoison
  - sxiv
  - strace
  - tig
  - tilix
  - tmux
  - unzip
  - w3m
  - wget
  - xdotool
  - xsel
  - texinfo
  - urlview
  - zathura
  - zathura-pdf-poppler
  - zeal

  {% if not is_arch %}
  - gnupg2
  - ipython3
  - python3-boto
  - python3-botocore
  - python3-boto3
  - x11-utils
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
  - libnotify-bin
  - libpython3-dev
  - libx11-dev
  - libxfixes-dev
  - python3-dev
  - stumpwm
  - vim-gtk3
  - x11proto-dev
  - xfonts-terminus
  {% endif %}

  {% if not (is_ubuntu and grains['osmajorrelease'] < 19) %}
  - ripgrep
  {% endif %}

  {% if is_fedora %}
  - gcc-c++
  - pinentry-gtk
  - python3-devel
  - python3-virtualenv
  - vim-X11
  - vim-enhanced
  - libX11-devel
  - libXfixes-devel
  - sbcl
  - terminus-fonts
  - xorg-x11-apps
  - xorg-x11-utils
  - xorg-x11-proto-devel
  {% endif %}

castles:
  - https://gitlab.com/femnad/base.git
  - https://gitlab.com/femnad/basic.git
  - https://gitlab.com/femnad/disposable.git
  - https://github.com/femnad/homebin.git
  - https://gitlab.com/femnad/homeless.git

go_install: []
go_path: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/sc/go' }}

go_get:
  - github.com/femnad/stuff/...
  - github.com/aykamko/tag/...
  - github.com/github/hub

go_get_gopath:
  - github.com/junegunn/fzf

home_bins:
  - https://github.com/femnad/loco/releases/download/0.2.0/bakl
  - https://github.com/femnad/loco/releases/download/0.2.0/tosm
  - https://github.com/femnad/loco/releases/download/0.2.0/ysnp
  - https://github.com/femnad/loco/releases/download/0.2.0/zenv

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
    exec_dir: go/bin
    exec: go
    clean: true
    hash: 0804bf02020dceaa8a7d7275ee79f7a142f1996bfd0c39216ccb405f93f994c0
    name: go
  - url: https://az764295.vo.msecnd.net/stable/8795a9889db74563ddd43eb0a897a2384129a619/code-stable-1573664143.tar.gz
    exec_dir: VSCode-linux-x64
    clean: true
    exec: code

binary_only_archives:
  - https://releases.hashicorp.com/terraform/0.12.6/terraform_0.12.6_linux_amd64.zip

cargo:
  - crate: fd-find
    exec: fd
  {% if (is_ubuntu and grains['osmajorrelease'] < 19) %}
  - crate: ripgrep
    exec: rg
  {% endif %}

github_keys: {{ salt.sdb.get('sdb://github-lookup/keys?user=' + github_user) | tojson }}
