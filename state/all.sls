{% set go_base = pillar['package_dir'] + '/go' %}
{% set go_bin = go_base + '/bin/go' %}
{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set clone_dir = pillar['clone_dir'] %}
{% set cargo = home + '/.cargo/bin/cargo' %}
{% set package_dir = pillar['package_dir'] %}
{% set host = grains['host'] %}
{% set user = pillar['user'] %}

{% set is_debian = grains['os'] == 'Debian' %}
{% set is_fedora = pillar['is_fedora'] %}

{% for dir in pillar['home_dirs'] %}
Home Dir {{ dir }}:
  file.directory:
    - name: {{ home }}/{{ dir }}
    - makedirs: true
    - user: {{ user }}
    - group: {{ user }}
{% endfor %}

{% for file in pillar['unwanted_files'] %}
Remove {{ file }}:
  file.absent:
    - name: {{ home }}/{{ file }}
{% endfor %}

{% from 'macros.sls' import install_from_archive with context %}
{% from 'macros.sls' import dirname %}

{{ install_from_archive(pillar['gcloud_package'], user=user) }}

Enable gsutil:
  {% set gcloud_bin = dirname(pillar['gcloud_package'].exec) %}
  cmd.run:
    - name: {{ home_bin }}/gcloud components install gsutil
    - require:
      - Install gcloud
    - unless: gcloud components list | grep -E 'Installed.*gsutil'
  file.symlink:
    - name: {{ home_bin }}/gsutil
      target: {{ package_dir }}/{{ gcloud_bin }}/gsutil

Initialize chezmoi base:
  cmd.run:
    - name: {{ home }}/go/bin/chezmoi init {{ pillar['chezmoi_base_repo'] }}
    - unless:
      - ls {{ home + '/' + pillar['chezmoi_base_path'] }}
    - runas: {{ user }}

Apply chezmoi base:
  cmd.run:
    - name: {{ home }}/go/bin/chezmoi apply
    - runas: {{ user }}

Tilix schemes:
{% set target = pillar['clone_dir'] + '/Tilix-Themes' %}
  git.cloned:
    - name: https://github.com/storm119/Tilix-Themes.git
    - target: {{ target }}
    - user: {{ user }}
  file.directory:
    - name: {{ home }}/.config/tilix/schemes
    - makedirs: true
    - user: {{ user }}
    - group: {{ user }}
  cmd.run:
    - name: find {{ target }} -name '*.json' -exec cp '{}' {{ home }}/.config/tilix/schemes \;
    - runas: {{ user }}

{% for prefix in pillar['mutt_dirs'] %}
  {% for cache in ['header', 'message'] %}
mutt init {{ prefix }} {{ cache }}:
  file.directory:
    - name: {{ home }}/.mutt/{{ prefix }}{{ cache }}
    - makedirs: true
    - user: {{ user }}
    - group: {{ user }}
  {% endfor %}
{% endfor %}

{% for archive in pillar['binary_only_archives'] %}
Download binary archive {{ archive.name | default(archive.url) }}:
  archive.extracted:
    - name: {{ home_bin }}
    - source: {{ archive.url }}
    {% if archive.hash is defined %}
    - source_hash: {{ archive.hash }}
    - source_hash_update: true
    {% else %}
    - skip_verify: true
    {% endif %}
    - enforce_toplevel: false
    - overwrite: true
    {% if archive.unless is defined %}
    - unless: {{ archive.unless }}
    {% endif %}
    - user: {{ user }}
    - group: {{ user }}
{% endfor %}

{% for bin in pillar['home_bins'] %}
  {% set exec_name = bin.url.split('/')[-1] %}
Download {{ exec_name }}:
  file.managed:
    - name: {{ home_bin }}/{{ exec_name }}
    - source: {{ bin.url }}
    {% if bin.hash is defined %}
    - source_hash: {{ bin.hash }}
    {% else %}
    - skip_verify: true
    {% endif %}
    - makedirs: true
    - mode: 0755
    - user: {{ user }}
    - group: {{ user }}

{% endfor %}

Build Ratpoison helpers:
  cmd.run:
    - name: {{ go_bin }} get github.com/femnad/ratilf/cmd/...
    - onlyif:
      - ratpoison -v
    - runas: {{ user }}

Stumpwm contrib:
  git.cloned:
    - name: https://github.com/stumpwm/stumpwm-contrib.git
    - target: {{ clone_dir }}/stumpwm-contrib
    - user: {{ user }}
  file.symlink:
    - name: {{ home_bin }}/stumpish
    - target: {{ clone_dir }}/stumpwm-contrib/util/stumpish/stumpish
    - user: {{ user }}
    - group: {{ user }}

Clone Tmux plugin manager:
  git.cloned:
    - name: https://github.com/tmux-plugins/tpm
    - target: {{ home }}/.tmux/plugins/tpm
    - user: {{ user }}
  {% if pillar['tmux'].startswith('/tmp/tmux-') %}
  cmd.run:
    - name: tmux run-shell {{ home }}/.tmux/plugins/tpm/bin/install_plugins
    - runas: {{ user }}
  {% endif %}

{% for key in pillar['github_keys'] %}
Add GitHub key {{ key.id }} as authorized:
  file.append:
    - name: {{ home }}/.ssh/authorized_keys
    - text: {{ key.key }}
{% endfor %}

Initialize Jedi for Emacs:
  cmd.run:
    - name: emacs -nw --load ~/.emacs --batch --eval '(jedi:install-server)'
    - unless:
      - ls ~/.emacs.d/elpa/jedi-core* -d
    - runas: {{ user }}

{% set pass_helper_path = home + '/go/src/github.com/docker/docker-credential-helpers' %}
Install Docker pass credential helper:
  git.cloned:
    - name: https://github.com/docker/docker-credential-helpers.git
    - target: {{ pass_helper_path }}
    - unless:
      - {{ home_bin }}/docker-credential-pass version
    - user: {{ user }}
  cmd.run:
    - name: {{ go_bin }} build -o {{ home_bin }}/docker-credential-pass pass/cmd/main_linux.go
    - cwd: {{ pass_helper_path }}
    - unless:
      - {{ home_bin }}/docker-credential-pass version
    - runas: {{ user }}

{% from 'macros.sls' import basename %}

{% for item in pillar['clone_link'] %}
{% set target = clone_dir + '/' + basename(item.repo) %}
{% set link = item.link | default(basename(item.repo)) %}
Clone and link {{ item.repo }}:
  git.latest:
    - name: https://{{ item.host | default('github.com') }}/{{ item.repo }}.git
    - target: {{ target }}
    - user: {{ user }}
  file.symlink:
    - name: {{ home_bin }}/{{ link }}
    - target: {{ target }}/{{ link }}
    - mode: 0755
    - user: {{ user }}
    - group: {{ user }}
{% endfor %}

# fedora: Undetermined weirdness with packaged Firefox ctrl+t behavior in Ratpoison/Stumpwm
# debian: Only firefox-esr
{% if is_fedora or is_debian %}
Copy Firefox desktop file:
  file.managed:
    - name: {{ home }}/.local/share/applications/firefox.desktop
    - source: salt://desktop/firefox.desktop
    - makedirs: true
    - user: {{ user }}
    - group: {{ user }}
{% endif %}
