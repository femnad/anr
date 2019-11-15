home: {{ salt.sdb.get('sdb://osenv/HOME') }}
clone_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/gl' }}
package_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/dy' }}

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
  {% if is_laptop %}
  - acpi
  {% endif %}
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
  {% if is_fedora %}
  - gcc-c++
  {% endif %}
  {% if not is_arch %}
  - gnupg2
  {% else %}
  - gnupg
  {% endif %}
  - htop
  {% if is_arch %}
  - ipython
  - python-virtualenv
  {% else %}
  - ipython3
  {% endif %}
  - jq
  {% if not (is_fedora or is_arch) %}
  - libnotify-bin
  {% endif %}
  - make
  - mutt
  {% if is_arch %}
  - lxdm-gtk3
  - man-db
  - man-pages
  {% endif %}
  - pass
  {% if is_fedora %}
  - pinentry-gtk
  {% endif %}
  {% if is_ubuntu %}
  - python3-dev
  - libpython3-dev
  - libx11-dev
  - libxfixes-dev
  - x11proto-dev
  {% endif %}
  {% if not is_arch %}
  - python3-boto
  - python3-botocore
  - python3-boto3
  {% endif %}
  {% if not (is_ubuntu and grains['osmajorrelease'] < 19) %}
  - ripgrep
  {% endif %}
  - rofi
  - ratpoison
  {% if is_ubuntu %}
  - xfonts-terminus
  - stumpwm
  {% endif %}
  {% if is_fedora %}
  - python3-devel
  - python3-virtualenv
  - vim-X11
  - vim-enhanced
  {% elif is_arch %}
  - vim
  {% else %}
  - vim-gtk3
  {% endif %}
  - sxiv
  - strace
  - tig
  - tilix
  - tmux
  {% if is_arch %}
  - ttf-dejavu
  {% endif %}
  - unzip
  {% if is_fedora %}
  - libX11-devel
  - libXfixes-devel
  - sbcl
  - terminus-fonts
  - xorg-x11-apps
  - xorg-x11-utils
  - xorg-x11-proto-devel
  {% elif not is_arch %}
  - x11-utils
  {% endif %}
  - w3m
  - wget
  - xdotool
  {% if is_arch %}
  - xorg-server
  {% endif %}
  - xsel
  - texinfo
  - urlview
  - zathura
  - zathura-pdf-poppler
  - zeal

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
  - url: https://az764295.vo.msecnd.net/stable/86405ea23e3937316009fc27c9361deee66ffbf5/code-stable-1573064450.tar.gz
    exec_dir: VSCode-linux-x64
    hash: 4fa1ae53452e76aebca3665c74b542aa19414c4804da8a910d869ef07c70b2cb
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
