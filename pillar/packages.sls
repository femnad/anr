{% set is_arch = grains['os'] == 'Arch' %}
{% set is_debian = grains['os'] == 'Debian' %}
{% set is_fedora = grains['os'] == 'Fedora' %}
{% set is_laptop = grains['manufacturer'] in ['LENOVO', 'Dell Inc.'] %}
{% set is_ubuntu = grains['os'] == 'Ubuntu' %}

{% set is_debian_or_ubuntu = is_debian or is_ubuntu %}

packages:
  - acpi
  - alsa-utils
  - at
  - autoconf
  - ansible
  - bpftrace
  - brightnessctl
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
  - mpv
  - most
  - mutt
  - npm
  - pass
  - playerctl
  - pwgen
  - qutebrowser
  - ripgrep
  - rofi
  - ranger
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
  - wireguard-tools
  - wireshark
  - xdotool
  - xsel
  - zathura
  - zathura-pdf-poppler
  - zeal

  {% if not is_arch %}
  - gnupg2
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
  - apt-listchanges
  - dconf-cli
  - dnsutils
  - gettext
  - golang
  - ipython3
  - libmnl-dev
  - libevent-dev
  - libfontconfig1-dev
  - libnotify-bin
  - libnotify-dev
  - libpython3-dev
  - libssl-dev
  - libtool
  - libtool-bin
  - libx11-dev
  - libxcb-render0-dev
  - libxcb-screensaver0-dev
  - libxcb-shape0-dev
  - libxcb-xfixes0-dev
  - libxext-dev
  - libxfixes-dev
  - libclang-dev
  - ncal
  - network-manager
  - pavucontrol
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
  - automake
  - dnf-automatic
  - ffmpeg
  - flatpak
  - fontconfig-devel
  - gcc-c++
  - git-crypt
  - java-17-openjdk
  - java-17-openjdk-devel
  - kernel-devel
  - kernel-headers
  - libevent-devel
  - libmnl-devel
  - libnotify-devel
  - libtool
  - libX11-devel
  - libXfixes-devel
  - NetworkManager-tui
  - neovim
  - pinentry-gtk
  - pipewire-pulseaudio
  - pipewire-utils
  - podman
  - python3-devel
  - python3-ipython
  - python3-virtualenv
  - openssl-devel
  - ruby-devel
  - rubygem-irb
  - sqlite
  - vim-X11
  - terminus-fonts
  - terminus-fonts-legacy-x11
  - upower
  - wmname
  - xev
  - xmodmap
  - xorg-x11-proto-devel
  - xprop
  - xrandr
  - xsetroot
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
  - hidapi
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
