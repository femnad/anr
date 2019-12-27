base:
  self:
    - all
    - clone
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
  shadow:
    - shadow
  steam:
    - steam
