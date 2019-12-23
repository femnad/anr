base:
  self:
    - all
    - clone
    - vim
  self-sudo:
    - compile
    {% if pillar['is_fedora']
    - flatpak
    {% endif %}
    - minikube
    - packages
    - python-packages
    - rust-packages
    - all-sudo
  private:
    - private
  shadow:
    - shadow
  steam:
    - steam
