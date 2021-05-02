base:
  sudo:
    - packages
    - sudo
    - cleanup
    {% if pillar['is_fedora'] %}
    - flatpak
    {% endif %}
  self:
    - archives
    - self
    - go-packages
    - python-packages
    - rust-packages
    - update
    - vim
  private:
    - private
    - clone
    - user-services
  dev:
    - keyboardio
    - latex
    - qmk
