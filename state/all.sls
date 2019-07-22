{% set go_base = pillar['package_dir'] + '/go' %}
{% set go_bin = go_base + '/bin/go' %}
{% set home = pillar['home'] %}

go:
  archive.extracted:
    - name: {{ home }}/z/dy
    - source: https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz
    - source_hash: 66d83bfb5a9ede000e33c6579a91a29e6b101829ad41fffb5c5bb6c900e109d9
    - clean: true
    - trim_output: true

Hub:
  git.cloned:
    - name: https://github.com/github/hub.git
    - target: {{ pillar['clone_dir'] }}/hub
  cmd.run:
    - name: {{ go_bin}} install
    - cwd: {{ pillar['clone_dir'] }}/hub
    - require:
        - go

{% set homeshick = home + '/.homeshick/repos/homeshick' %}
{% set homeshick_bin = homeshick + '/bin/homeshick' %}

homeshick:
  git.cloned:
    - name: https://github.com/andsens/homeshick.git
    - target: {{ homeshick }}

{% for castle in pillar['castles'] %}
{% set castle_name = castle.split('/')[-1].split('.')[0] %}
Add castle {{ castle }}:
  git.cloned:
    - name: {{ castle }}
    - target: {{ home + '/.homeshick/repos/' + castle_name }}
  cmd.run:
    - name: {{ homeshick_bin }} -b {{ castle_name }}
    - cwd: {{ homeshick }}
    - required:
        - homeshick
{% endfor %}
