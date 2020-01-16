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
    - minikube
  sudo:
    - all-sudo
    - compile
    {% if pillar['is_fedora'] %}
    - flatpak
    {% endif %}
    - packages
  sudo-dev:
    - docker
    - libvirt
    - qmk
  private:
    - private
    - clone
  shadow:
    - shadow
  steam:
    - steam
