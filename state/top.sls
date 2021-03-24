base:
  self:
    - all
    - archive-install
    - cleanup
    - compile
    {% if pillar['is_fedora'] %}
    - flatpak
    {% endif %}
    - go-packages
    - python-packages
    - packages
    - rust-packages
    - user-services
    - vim
  private:
    - private
    - clone
  dev:
    - docker
    - keyboardio-sudo
    - latex
    - libvirt
    - minikube
    - qmk
