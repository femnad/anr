base:
  L@self,self-sudo,private,shadow,steam,passfuser:
    - all
    - packages
  passfuser:
    - passfuse-secrets
  private:
    - clone
    - private
