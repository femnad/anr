{% set home = pillar['home'] %}
{% set home_bin = home + '/bin/' %}
{% set cargo_bin = home + '/.cargo/bin' %}

Update Rust:
  cmd.run:
    - name: {{ cargo_bin }}/rustup update stable

Update gcloud:
  cmd.run:
    - name: {{ home_bin }}/gcloud components update
