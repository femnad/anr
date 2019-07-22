{% set go_base = pillar['package_dir'] + '/go' %}
{% set go_bin = go_base + '/bin/go' %}
{% set home = pillar['home'] %}

go:
  archive.extracted:
    - name: {{ pillar['package_dir'] }}
    - source: https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz
    - source_hash: 66d83bfb5a9ede000e33c6579a91a29e6b101829ad41fffb5c5bb6c900e109d9
    - clean: true
    - trim_output: true

rust:
  archive.extracted:
    - name: {{ pillar['package_dir'] }}
    - source: https://static.rust-lang.org/dist/rust-1.36.0-x86_64-unknown-linux-gnu.tar.gz
    - source_hash: 15e592ec52f14a0586dcebc87a957e472c4544e07359314f6354e2b8bd284c55
    - clean: true
    - trim_output: true

{% for pkg in pillar['go_install'] %}
{% set name = pkg.split('/')[-1].split('.')[0] %}
{% set target = pillar['clone_dir'] + '/' + name %}
Install Go Package {{ name }}:
  git.cloned:
    - name: {{ pkg }}
    - target: {{ target }}
  cmd.run:
    - name: {{ go_bin}} install
    - cwd: {{ target }}
    - require:
        - go
{% endfor %}

{% for pkg in pillar['go_get'] %}
Go get {{ pkg }}:
  cmd.run:
    - name: {{ go_bin }} get -u {{ pkg }}
    - require:
      - go
{% endfor %}

{% for pkg in pillar['go_get_gopath'] %}
{% set name = pkg.split('/')[-1] %}
{% set gopath = pillar['go_path'] %}
Go get {{ pkg }}:
  environ.setenv:
    - name: GOPATH
    - value: {{ gopath }}
  cmd.run:
    - name: {{ go_bin }} get -u {{ pkg }}
    - require:
      - go
  file.copy:
    - name: {{ home }}/bin/{{ name }}
    - source: {{ gopath }}/bin/{{ name }}
{% endfor %}

{% set homeshick_repos = home + '/.homesick/repos' %}
{% set homeshick = homeshick_repos + '/homeshick' %}
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
    - target: {{ homeshick_repos + '/' + castle_name }}
  cmd.run:
    - name: {{ homeshick_bin }} link -b {{ castle_name }}
    - required:
        - homeshick
{% endfor %}

Vim Plug:
  file.managed:
    - name: {{ home }}/.vim/autoload/plug.vim
    - source: https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    - skip_verify: true

Tilix schemes:
{% set target = pillar['clone_dir'] + '/Tilix-Themes' %}
  git.cloned:
    - name: https://github.com/storm119/Tilix-Themes.git
    - target: {{ target }}
  file.directory:
    - name: {{ home }}/.config/tilix/schemes
    - makedirs: true
  cmd.run:
    - name: find {{ target }} -name '*.json' -exec mv '{}' {{ home }}/.config/tilix/schemes \;

{% for bin in pillar['home_bins'] %}
Download {{ bin.url }}:
  file.managed:
    - name: {{ home }}/bin/{{ bin.url.split('/')[-1] }}
    - source: {{ bin.url }}
    - source_hash: {{ bin.hash }}
    - mode: 755
{% endfor %}
