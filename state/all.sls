{% set go_base = pillar['package_dir'] + '/go' %}
{% set go_bin = go_base + '/bin/go' %}

libasound2-dev:
  pkg.installed

Spotifyd:
  git.cloned:
    - name: https://github.com/Spotifyd/spotifyd
    - target: {{ pillar['clone_dir'] }}/spotifyd
  cmd.run:
    - name: cargo build
    - cwd: {{ pillar['clone_dir'] }}/spotifyd
    - require:
        - libasound2-dev

go:
  archive.extracted:
    - name: {{ pillar['home'] }}/z/dy
    - source: https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz
    - source_hash: 66d83bfb5a9ede000e33c6579a91a29e6b101829ad41fffb5c5bb6c900e109d9
    - clean: true
    - trim_output: true

Hub:
  git.cloned:
    - name:   https://github.com/github/hub.git
    - target: {{ pillar['clone_dir'] }}/hub
  cmd.run:
    - name: {{ go_bin}} install
    - cwd: {{ pillar['clone_dir'] }}/hub
    - require:
        - go
