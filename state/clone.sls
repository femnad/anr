{% for clonee in pillar['self_clonees'] %}
  {% set name = clonee.repo.split('/')[-1].split('.')[0] %}
  {% set target = pillar['self_clone_dir'] + '/' + name %}
  {% set site = clonee.site | default('github.com') %}
  {% set user = clonee.user | default(pillar['github_user']) %}
  {% set url = 'git@{}:{}/{}.git'.format(site, user, clonee.repo) %}

Clone self repo {{ name }}:
  git.latest:
    - name: {{ url }}
    - target: {{ target }}
    {% if clonee.submodule is defined and clonee.submodule %}
    - submodules: true
    {% endif %}
    {% if clonee.force | default(false) %}
    - force_fetch: true
    - force_reset: true
    {% endif %}
  {% if clonee.git_crypt is defined and clonee.git_crypt %}
  cmd.run:
    - name: git crypt unlock
    - cwd: {{ target }}
  {% endif %}

  {% if clonee.remotes is defined %}
    {% for remote in clonee.remotes %}
Add remote {{ remote.name }} for {{ name }}:
  cmd.run:
    - name: git remote add {{ remote.name }} {{ remote.url }}
    - cwd: {{ target }}
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
    {% endfor %}
  {% endif %}

{% endfor %}

{% for clonee in pillar['clonees'] %}
{% set name = clonee.repo.split('/')[-1].split('.')[0] %}
{% set target = pillar['clone_dir'] + '/' + name %}
{% set site = clonee.site | default('github.com') %}
{% set repo = 'git@' + site + ':' + clonee.repo + '.git' %}

Clone {{ name }}:
  git.cloned:
    - name: {{ repo }}
    - target: {{ target }}
{% endfor %}
