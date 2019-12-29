{% set is_arch = grains['os'] == 'Arch' %}
{% set is_fedora = grains['os'] == 'Fedora' %}
{% set is_laptop = grains['manufacturer'] in ['LENOVO', 'Dell Inc.'] %}
{% set is_ubuntu = grains['os'] == 'Ubuntu' %}

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
  {% if not (is_ubuntu and grains['osmajorrelease'] < 19) %}
  - playerctl
  {% endif %}
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
  - libnotify-devel
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

    {% if grains['osmajorrelease'] < 19 %}
  - dconf-cli
  - ripgrep
    {% endif %}

  {% endif %}

  {% if is_fedora %}
  - ffmpeg
  - flatpak
  - gcc-c++
  - git-crypt
  - java-11-openjdk
  - java-11-openjdk-devel
  - kernel-devel
  - kernel-headers
  - libevent-devel
  - libmnl-devel
  - NetworkManager-tui
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

qmk_packages:
  {% if is_fedora %}
  - dfu-util
  - dfu-programmer
  - avr-gcc
  - avr-libc
  - binutils-avr32-linux-gnu
  - arm-none-eabi-gcc-cs
  - arm-none-eabi-binutils-cs
  - arm-none-eabi-newlib
  {% endif %}

libvirt_packages:
  {% if is_fedora %}
  - libvirt
  - qemu
  {% endif %}
