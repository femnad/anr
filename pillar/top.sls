base:
  L@self,self-sudo,private,shadow:
    - all
  L@self-sudo,shadow:
    - sudo
  private:
    - private
