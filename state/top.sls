base:
  self:
    - all
    - clone
    - vim
  self-sudo:
    - compile
    - minikube
    - packages
    - python-packages
    - rust-packages
    - all-sudo
  private:
    - private
  shadow:
    - shadow
