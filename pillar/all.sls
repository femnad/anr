{% set home = salt.sdb.get('sdb://osenv/HOME') %}
home: {{ home }}
clone_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/gl' }}
self_clone_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/fm' }}
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

go_path: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/sc/go' }}

go_get:
  - pkg: github.com/femnad/stuff/cmd/...
  - pkg: github.com/femnad/rabn/cmd/rabn
    unless: rabn --version
  - pkg: github.com/aykamko/tag/...
    unless: tag -V
  - pkg: github.com/dustinkirkland/golang-petname/cmd/petname
    unless: petname
  - pkg: github.com/twpayne/chezmoi
    unless: chezmoi --version

go_cloned_install:
  - name: mikefarah/yq
    unless: yq --version
  - name: charmbracelet/glow
    unless: glow -v
  - name: junegunn/fzf
    unless: fzf --version

home_bins:
  - url: https://github.com/femnad/leth/releases/download/v0.2.0/leth
  - url: https://github.com/femnad/moih/releases/download/v0.4.0/moih

vim_dirs:
  - autoload
  - plugged
  - swap

mutt_dirs:
  - fm

cargo:
  - crate: fd-find
    unless: fd -V
  - crate: bat
  - crate: git-delta
    unless: delta -V
  - crate: xidlehook
    bins: true
  - crate: alacritty
    unless: alacritty -V
  - crate: bottom
    unless: btm -V

cargo_clone: []

github_keys: {{ salt.sdb.get('sdb://github-lookup/keys?user=' + github_user) | tojson }}

rpmfusion_releases:
  - free
  - nonfree

xidlehook_socket: {{ home }}/.local/share/xidlehook/xidlehook.sock
xidlehook_default_duration: 600
xidlehook_durations:
  natrium: 3600
  lithium: 3600

clone_link:
  - repo: thameera/vimv

chezmoi_base_repo: https://gitlab.com/femnad/chezmoi.git
chezmoi_base_path: .local/share/chezmoi

global_npm_packages:
  - name: pyright
    unless: --version

python_pkgs:
  - name: yapf
  - name: pyinfra
    reqs:
      - pyyaml
