home: {{ salt.sdb.get('sdb://osenv/HOME') }}
clone_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/gl' }}
package_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/dy' }}

packages:
  - alsa-utils
  - autoconf
  - ansible
  - cmake
  - dzen2
  - emacs
  - fish
  - firefox
  - gnupg2
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
  - url: https://github.com/femnad/loco/releases/download/untagged-54ba4752f764e03bbdbc/ysnp
    hash: 7402098eee98d892845b83cdd563e998eaac2307afa84fc2e214746c90dcabd2

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

python:
  - name: ranger
    package: ranger-fm

cargo:
  - crate: fd-find
    exec: fd
