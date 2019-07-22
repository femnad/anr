home: {{ salt.sdb.get('sdb://osenv/HOME') }}
clone_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/gl' }}
package_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/dy' }}

packages:
  - ansible
  - emacs
  - fish
  - firefox
  - gnupg2
  - lightdm
  - pass
  - python3-boto
  - python3-botocore
  - python3-boto3
  - stumpwm
  - vim-gtk3
  - tilix
  - tmux

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
