{% set home = pillar['home'] %}
{% set user = pillar['user'] %}
{% set cargo = home + '/.cargo/bin/cargo' %}
{% set cargo_bin = home + '/.cargo/bin' %}

Install Rust:
  file.managed:
    - name: {{ pillar['package_dir'] }}/rustup/rustup-init
    - source: https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init
    - makedirs: true
    - mode: 755
    - skip_verify: true
    - unless:
        - {{ cargo }}
    - user: {{ user }}
    - group: {{ user }}
  cmd.run:
    {% if not pillar.get('rust_update', False) %}
    - name: "echo 1 | {{ pillar['package_dir'] }}/rustup/rustup-init --no-modify-path"
    - unless:
        - {{ cargo }}
    {% else %}
    - name: {{ cargo_bin }}/rustup update
    {% endif %}
    - runas: {{ user }}

{% for crate in pillar['cargo'] %}
Cargo install {{ crate.crate }}:
  cmd.run:
    - name: {{ cargo }} install {{ crate.crate }}{% if crate.bins is defined and crate.bins %} --bins{% endif %}
    {% if not pillar.get('update', False) %}
    - unless:
        - {{ cargo_bin}}/{{ crate.unless | default(crate.crate + ' -V') }}
    {% endif %}
    - runas: {{ user }}
{% endfor %}
