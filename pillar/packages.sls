{% set is_arch = grains['os'] == 'Arch' %}
{% set is_debian = grains['os'] == 'Debian' %}
{% set is_fedora = grains['os'] == 'Fedora' %}
{% set is_laptop = grains['manufacturer'] in ['LENOVO', 'Dell Inc.'] %}
{% set is_ubuntu = grains['os'] == 'Ubuntu' %}

{% set is_debian_or_ubuntu = is_debian or is_ubuntu %}

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
  - i3lock
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
  - ruby
  - sbcl
  - sxiv
  - strace
  - surfraw
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

  {% if is_debian %}
  - chromium
  - lxdm
  - xorg
  - x11-apps
  - x11-session-utils
  - xinit
  {% endif %}

  {% if is_ubuntu %}
  - chromium-browser
  {% endif %}

  {% if is_debian or is_ubuntu %}

    {% if is_laptop %}
  - libnotify-dev
    {% endif %}

  - apt-listchanges
  - dnsutils
  - ipython3
  - libmnl-dev
  - libevent-dev
  - libnotify-bin
  - libpython3-dev
  - libssl-dev
  - libx11-dev
  - libxcb-screensaver0-dev
  - libxext-dev
  - libxfixes-dev
  - libclang-dev
  - network-manager
  - python3-dev
  - resolvconf
  - sqlite3
  - suckless-tools
  - unattended-upgrades
  - vim-gtk3
  - x11proto-dev
  - x11-utils
  - xfonts-terminus

    {% if is_ubuntu and grains['osmajorrelease'] < 19 %}
  - dconf-cli
    {% else %}
  - ripgrep
    {% endif %}

  {% endif %}

  {% if is_fedora %}

    {% if is_laptop %}
  - libnotify-devel
    {% endif %}

  - dnf-automatic
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
  - sqlite
  - vim-X11
  - libX11-devel
  - libXfixes-devel
  - terminus-fonts
  - wmname
  - xorg-x11-apps
  - xorg-x11-utils
  - xorg-x11-proto-devel
  {% endif %}

  {% if not (is_fedora or is_debian)  %}
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
  {% elif is_debian_or_ubuntu %}
  - gcc-avr
  - binutils-avr
  - avr-libc
  - dfu-programmer
  - dfu-util
  - gcc-arm-none-eabi
  - binutils-arm-none-eabi
  - libnewlib-arm-none-eabi
  - teensy-loader-cli
  {% endif %}

libvirt_packages:
  {% if is_fedora %}
  - libvirt
  - qemu
  {% elif is_debian_or_ubuntu %}
  - libvirt-clients
  - libvirt-daemon-system
  - qemu-kvm
  {% endif %}

packages_to_remove:
  {% if is_debian %}
  - exim4-daemon-light
  - firefox-esr
  - lightdm
  - wicd
  {% endif %}
