base:
  sudo:
    - packages
    - sudo
    - cleanup
  user:
    - archives
    - user
    - go
    - python
    - rust
    - update
    - vim
    - services
  private:
    - private
    - clone
  dev:
    - latex
  sudo-dev:
    - qmk
