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
    - user-services
    - vim
  private:
    - private
    - clone
  dev:
    - docker
    - keyboardio
    - latex
    - libvirt
    - minikube
    - qmk
