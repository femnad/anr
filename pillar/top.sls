base:
  L@self,sudo,private,shadow,steam,passfuser,self-dev,sudo-dev:
    - all
    - packages
  passfuser:
    - passfuse-secrets
  private:
    - clone
    - private
