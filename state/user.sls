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
{% set is_ubuntu = pillar['is_ubuntu'] %}
{% set is_debian_or_ubuntu = is_debian or is_ubuntu %}

{% for dir in pillar['home_dirs'] %}
Home Dir {{ dir }}:
  file.directory:
    - name: {{ home }}/{{ dir }}
    - makedirs: true
    - user: {{ user }}
    - group: {{ user }}
{% endfor %}

{% for path in pillar['unwanted_dirs'] %}
Remove {{ path }}:
  file.absent:
    - name: {{ home }}/{{ path }}
{% endfor %}

{% from 'macros.sls' import install_from_archive with context %}
{% from 'macros.sls' import dirname %}

Enable gsutil:
  cmd.run:
    - name: {{ home_bin }}/gcloud components install gsutil
    - unless:
        file: {{ package_dir }}/google-cloud-sdk/bin/gsutil
  file.symlink:
    - name: {{ home_bin }}/gsutil
      target: {{ package_dir }}/google-cloud-sdk/bin/gsutil

Initialize chezmoi base:
  cmd.run:
    - name: {{ home }}/go/bin/chezmoi init {{ pillar['chezmoi_base_repo'] }}
    - unless:
      - ls {{ home + '/' + pillar['chezmoi_base_path'] }}
    - runas: {{ user }}

Apply chezmoi base:
  cmd.run:
    - name: {{ home }}/bin/chezmoi apply --force
    - runas: {{ user }}
    - require:
      - Initialize chezmoi base

{% for prefix in pillar['mutt_dirs'] %}
  {% for cache in ['header', 'message'] %}
Mutt init cache directory {{ prefix }} {{ cache }}:
  file.directory:
    - name: {{ home }}/.mutt/{{ prefix }}{{ cache }}
    - makedirs: true
    - user: {{ user }}
    - group: {{ user }}
  {% endfor %}
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
