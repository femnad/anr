home: {{ salt.sdb.get('sdb://osenv/HOME') }}
clone_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/gl' }}
package_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/dy' }}

home_dirs:
  - bin
  - x
  - y
  - z

packages:
  - alsa-utils
  - autoconf
  - ansible
  - cmake
  - dunst
  - dzen2
  - emacs
  - fish
  - firefox
  - gnupg2
  - jq
  - lightdm
  - mutt
  - pass
  - python3-boto
  - python3-botocore
  - python3-boto3
  - ripgrep
  - rofi
  - stumpwm
  - vim-gtk3
  - tig
  - tilix
  - tmux
  - x11-utils
  - xdotool
  - texinfo
  - zathura
  - zathura-pdf-poppler
  - zeal

castles:
  - https://gitlab.com/femnad/base.git
  - https://gitlab.com/femnad/basic.git
  - https://gitlab.com/femnad/disposable.git
  - https://github.com/femnad/homebin.git

go_install: []
go_path: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/sc/go' }}

go_get:
  - github.com/femnad/stuff/...
  - github.com/aykamko/tag/...

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
  - https://az764295.vo.msecnd.net/stable/2213894ea0415ee8c85c5eea0d0ff81ecc191529/code-stable-1562627471.tar.gz

cargo:
  - crate: fd-find
    exec: fd
