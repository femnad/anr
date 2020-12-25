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
  - playerctl
  - pwgen
  - qutebrowser
  - ripgrep
  - rofi
  - ranger
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
  - xorg
  - x11-apps
  - x11-session-utils
  - xinit
  {% endif %}

  {% if is_debian or is_ubuntu %}

    {% if is_laptop %}
  - libnotify-dev
    {% endif %}

  - apt-listchanges
  - dconf-cli
  - dnsutils
  - ipython3
  - libmnl-dev
  - libevent-dev
  - libfontconfig1-dev
  - libnotify-bin
  - libpython3-dev
  - libssl-dev
  - libx11-dev
  - libxcb-render0-dev
  - libxcb-screensaver0-dev
  - libxcb-shape0-dev
  - libxcb-xfixes0-dev
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

  {% endif %}

  {% if is_fedora %}
  - dnf-automatic
  - ffmpeg
  - flatpak
  - fontconfig-devel
  - gcc-c++
  - git-crypt
  - java-11-openjdk
  - java-11-openjdk-devel
  - kernel-devel
  - kernel-headers
  - libevent-devel
  - libmnl-devel
  - libnotify-devel
  - NetworkManager-tui
  - pinentry-gtk
  - podman
  - pulseaudio-module-bluetooth
  - python3-devel
  - python3-ipython
  - python3-virtualenv
  - openssl-devel
  - sqlite
  - vim-X11
  - libX11-devel
  - libXfixes-devel
  - terminus-fonts
  - wireguard-tools
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
  - arm-none-eabi-binutils-cs
  - arm-none-eabi-gcc-cs
  - arm-none-eabi-newlib
  - avr-binutils
  - avr-gcc
  - avr-libc
  - avrdude
  - binutils-avr32-linux-gnu
  - clang
  - dfu-util
  - dfu-programmer
  - glibc-headers
  - kernel-devel
  - kernel-headers
  - libusb-devel
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
  {% endif %}

latex_packages:
  {% if is_fedora %}
  - texlive-latex
  - texlive-metafont
  - texlive-mfware
  - texlive-parskip
  - texlive-updmap-map
  {% endif %}
