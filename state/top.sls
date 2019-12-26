base:
  self:
    - all
    - clone
    - vim
  self-sudo:
    - all-sudo
    - compile
    {% if pillar['is_fedora']
    - flatpak
    {% endif %}
    - minikube
    - packages
    - python-packages
    - qmk
    - rust-packages
  private:
    - private
  server:
    - server-packages
  shadow:
    - shadow
  steam:
    - steam
