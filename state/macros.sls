{% set home = pillar['home'] %}

{% macro basename(path) -%}
{{ path.split('/')[-1] }}
{%- endmacro %}

{% macro dirname(path) -%}
{{ '/'.join(path.split('/')[:-1]) }}
{%- endmacro %}

{% macro install_from_archive(archive, user=None) %}
Install {{ archive.name | default(archive.url) }}:
  archive.extracted:
    - name: {{ pillar['package_dir'] }}
    - source: {{ archive.url }}
  {% if archive.hash is defined %}
    - source_hash: {{ archive.hash }}
    - source_hash_update: true
  {% else %}
    - skip_verify: true
  {% endif %}
  {% if archive.clean is defined %}
    - clean: {{ archive.clean }}
  {% endif %}
  {% if archive.format is defined %}
    - archive_format: {{ archive.format }}
  {% endif %}
    - trim_output: true
  {% if user is not none %}
    - user: {{ user }}
    - group: {{ user }}
  {% endif %}
  {% if archive.unless is defined %}
    - unless:
      - {{ archive.unless }}
  {% endif %}
  {% if archive.overwrite is defined %}
    - overwrite: {{ archive.overwrite }}
  {% endif %}
  {% if archive.exec is defined %}
  {% set basename = archive.exec.split('/')[-1] %}
  file.symlink:
    - name: {{ home_bin }}/{{ basename }}
    - target: {{ package_dir }}/{{ archive.exec }}
  {% endif %}

{% if archive.bin_links is defined and archive.exec is defined %}
  {% for bin_link in archive.bin_links %}
Link {{ bin_link }}:
  file.symlink:
    - name: {{ home_bin }}/{{ bin_link }}
    - target: {{ package_dir }}/{{ salt['file.dirname'](archive.exec) }}/{{ bin_link }}
  {% endfor %}
{% endif %}
{% endmacro %}

{% macro clone_self_repo(clonee, user=None) %}
  {% set name = clonee.repo.split('/')[-1].split('.')[0] %}
  {% set target = pillar['self_clone_dir'] + '/' + name %}
  {% set site = clonee.site | default('github.com') %}
  {% set user = clonee.user | default(pillar['github_user']) %}
  {% set url = 'git@{}:{}/{}.git'.format(site, user, clonee.repo) %}

Clone repo {{ name }}:
  git.latest:
    - name: {{ url }}
    - target: {{ target }}
    {% if clonee.rev is defined %}
    - rev: {{ clonee.rev }}
    {% endif %}
    {% if clonee.submodule is defined and clonee.submodule %}
    - submodules: true
    {% endif %}
    {% if clonee.force | default(false) %}
    - force_fetch: true
    - force_reset: true
    {% endif %}
    {% if user is not none %}
    - user: {{ user }}
    {% endif %}
  {% if clonee.git_crypt is defined and clonee.git_crypt %}
  cmd.run:
    - name: git crypt unlock
    - cwd: {{ target }}
    {% if user is not none %}
    - runas: {{ user }}
    {% endif %}
  {% endif %}

  {% if clonee.remotes is defined %}
    {% for remote in clonee.remotes %}

Add remote {{ remote.name }} for {{ name }}:
  cmd.run:
    - name: git remote add {{ remote.name }} {{ remote.url }}
    - cwd: {{ target }}
    {% if user is not none %}
    - runas: {{ user }}
    {% endif %}
    - unless:
      - git remote | grep {{ remote.name }}
  git.latest:
    - name: {{ remote.url }}
    - update_head: false
    - remote: {{ remote.name }}
    - target: {{ target }}
    {% if clonee.force | default(false) %}
    - force_fetch: true
    - force_reset: true
    {% endif %}
    {% if user is not none %}
    - user: {{ user }}
    {% endif %}

    {% endfor %}
  {% endif %}
{% endmacro %}
