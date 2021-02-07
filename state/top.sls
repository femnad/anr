base:
  latex:
    - latex
  passfuser:
    - gcsfuse
    - passfuse-gcp
  self-dev:
    - minikube
  self:
    - all
    - all-sudo
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
  sudo-dev:
    - docker
    - keyboardio-sudo
    - libvirt
    - qmk
  private:
    - private
    - clone
  shadow:
    - shadow
  steam:
    - steam
