base:
  passfuser:
    - gcsfuse
    - passfuse-gcp
  self:
    - all
    - python-packages
    - rust-packages
    - user-services
    - vim
  self-dev:
    - keyboardio
    - minikube
  sudo:
    - all-sudo
    - cleanup
    - compile
    {% if pillar['is_fedora'] %}
    - flatpak
    {% endif %}
    - packages
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
