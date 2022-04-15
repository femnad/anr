base:
  sudo:
    - base
    - packages
    - cleanup
    {% if pillar['is_fedora'] %}
    - flatpak
    {% endif %}
  user:
    - archives
    - main
    - go
    - python
    - rust
    - update
    - services
  private:
    - private
    - clone
  dev:
    - latex
  sudo-dev:
    - qmk
