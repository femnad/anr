base:
  sudo:
    - main
    - packages
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
    - services
  private:
    - private
    - clone
  dev:
    - latex
  sudo-dev:
    - qmk
