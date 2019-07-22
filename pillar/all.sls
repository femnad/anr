home: {{ salt.sdb.get('sdb://osenv/HOME') }}
clone_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/gl' }}
package_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/dy' }}

packages:
  - emacs
  - fish
  - firefox
  - lightdm
  - pass
  - stumpwm
  - vim-gtk3
  - tilix
  - tmux

castles:
  - https://gitlab.com/femnad/base.git
  - https://gitlab.com/femnad/basic.git
  - https://gitlab.com/femnad/disposable.git
  - https://github.com/femnad/homebin.git

go_install:
  - https://github.com/junegunn/fzf.git

go_get:
  - github.com/femnad/stuff
