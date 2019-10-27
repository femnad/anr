home: {{ salt.sdb.get('sdb://osenv/HOME') }}
clone_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/gl' }}
package_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/dy' }}

home_dirs:
  - bin
  - x
  - y
  - z

{% set is_fedora = grains['os'] == 'Fedora' %}
{% set is_arch = grains['os'] == 'Arch' %}
is_arch: {{ is_arch }}

packages:
  - alsa-utils
  - autoconf
  - ansible
  - cmake
  - curl
  - dunst
  - dzen2
  - emacs
  - fish
  - firefox
  - gcc
  {% if not is_arch %}
  - gnupg2
  {% else %}
  - gnupg
  {% endif %}
  - htop
  - jq
  {% if not (is_fedora or is_arch) %}
  - libnotify-bin
  {% endif %}
  - lxdm
  - make
  - mutt
  - pass
  {% if not is_arch %}
  - python3-boto
  - python3-botocore
  - python3-boto3
  {% endif %}
  - ripgrep
  - rofi
  {% if is_fedora or is_arch %}
  # too lazy to compile Stumpwm
  - ratpoison
  {% else %}
  - stumpwm
  {% endif %}
  {% if is_fedora %}
  - vim-X11
  {% elif is_arch %}
  - vim
  {% else %}
  - vim-gtk3
  {% endif %}
  - sxiv
  - tig
  - tilix
  - tmux
  {% if is_arch %}
  - ttf-dejavu
  {% endif %}
  {% if is_fedora %}
  - xorg-x11-utils
  {% elif not is_arch %}
  - x11-utils
  {% endif %}
  - w3m
  - wget
  - xdotool
  - xorg-server
  - texinfo
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
  - url: https://az764295.vo.msecnd.net/stable/2213894ea0415ee8c85c5eea0d0ff81ecc191529/code-stable-1562627471.tar.gz
    exec_dir: VSCode-linux-x64
    exec: code

binary_only_archives:
  - https://releases.hashicorp.com/terraform/0.12.6/terraform_0.12.6_linux_amd64.zip

cargo:
  - crate: fd-find
    exec: fd
