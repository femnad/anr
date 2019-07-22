home: {{ salt.sdb.get('sdb://osenv/HOME') }}
clone_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/gl' }}
package_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/dy' }}

packages:
  - ansible
  - dzen2
  - emacs
  - fish
  - firefox
  - gnupg2
  - lightdm
  - pass
  - python3-boto
  - python3-botocore
  - python3-boto3
  - rofi
  - stumpwm
  - vim-gtk3
  - tilix
  - tmux
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

go_get_gopath:
  - github.com/junegunn/fzf

home_bins:
  - url: https://github.com/femnad/loco/releases/download/untagged-54ba4752f764e03bbdbc/ysnp
    hash: 7402098eee98d892845b83cdd563e998eaac2307afa84fc2e214746c90dcabd2
