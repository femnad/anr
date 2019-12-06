base:
  self:
    - all
  self-sudo:
    - compile
    - packages
    - python-packages
    - all-sudo
  private:
    - private
  shadow:
    - shadow
