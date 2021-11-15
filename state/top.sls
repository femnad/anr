base:
  sudo:
    - packages
    - sudo
    - cleanup
    {% if pillar['is_fedora'] %}
    - flatpak
    {% endif %}
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
