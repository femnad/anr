base:
  self:
    - all
    - clone
    - vim
  self-sudo:
    - compile
    - packages
    - python-packages
    - rust-packages
    - all-sudo
  private:
    - private
  shadow:
    - shadow
