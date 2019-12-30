base:
  passfuser:
    - gcsfuse
    - passfuse-gcp
  self:
    - all
    - minikube
    - python-packages
    - rust-packages
    - vim
  self-sudo:
    - all-sudo
    - compile
    {% if pillar['is_fedora'] %}
    - flatpak
    {% endif %}
    - libvirt
    - packages
    - qmk
  private:
    - private
    - clone
  shadow:
    - shadow
  steam:
    - steam
