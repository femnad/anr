clonees: []

self_clonees:
  - repo: ansible-roles
  - repo: casastrap
  - repo: loco
  - repo: geheim
    git_crypt: true
  - repo: qmk_firmware
    submodule: true
    remotes:
      - url: git@github.com:qmk/qmk_firmware.git
        name: upstream
    force: true
  - repo: passfuse
  - repo: bors
  - repo: sqrt26.com
    submodule: true
