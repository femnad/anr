{% set is_arch = grains['os'] == 'Arch' %}
{% set is_fedora = grains['os'] == 'Fedora' %}
{% set is_ubuntu = grains['os'] == 'Ubuntu' %}

packages:
  - autoconf
  - ansible
  - cmake
  - colordiff
  - curl
  - fish
  - gcc
  - git
  - git-crypt
  - highlight
  - htop
  - jq
  - make
  - most
  - pwgen
  - rlwrap
  - strace
  - tig
  - tmux
  - texinfo
  - unzip
  - w3m
  - wget
  - whois

  {% if is_arch %}
  - ipython
  - python-virtualenv
  - man-db
  - man-pages
  - vim
  {% endif %}

  {% if is_ubuntu %}
  - ipython3
  - libpython3-dev
  - libssl-dev
  - libclang-dev
  - python3-dev
  - surfraw
  {% endif %}

  {% if not (is_ubuntu and grains['osmajorrelease'] < 19) %}
  - ripgrep
  {% endif %}

  {% if is_fedora %}
  - gcc-c++
  - python3-devel
  - python3-ipython
  - python3-virtualenv
  - openssl-devel
  {% endif %}
