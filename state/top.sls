base:
  self:
    - packages
    - archive-install
    - all
    - cleanup
    - compile
    {% if pillar['is_fedora'] %}
    - flatpak
    {% endif %}
    - go-packages
    - python-packages
    - rust-packages
    - update
    - vim
  user:
    - private
    - clone
    - user-services
  dev:
    - keyboardio
    - latex
    - qmk
