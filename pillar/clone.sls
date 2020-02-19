clonees:
  - repo: fish-shell/fish-shell
  - repo: hashicorp/terraform
  - repo: prometheus/prometheus
  - repo: terraform-providers/terraform-provider-google
  - repo: qmk/qmk_firmware

self_clonees:
  - repo: ansible-roles
  - repo: casastrap
  - repo: loco
  - repo: stuff
  - repo: geheim
    git_crypt: true
  - repo: qmk_firmware
    submodule: true
    remotes:
      - url: git@github.com:qmk/qmk_firmware.git
        name: upstream
    force: true
  - repo: meh
  - repo: passfuse
  - repo: bors
  - repo: sqrt26.com
    submodule: true
  - repo: gcloud-fish-completions
