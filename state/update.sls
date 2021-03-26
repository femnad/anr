{% set user = pillar['user'] %}

Update Rust:
  cmd.run:
    - name: rustup update stable
    - runas: {{ user }}

Update gcloud:
  cmd.run:
    - name: gcloud components update
    - runas: {{ user }}
