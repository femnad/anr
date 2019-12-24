{% for clonee in pillar['self_clonees'] %}
{% set name = clonee.repo.split('/')[-1].split('.')[0] %}
{% set target = pillar['self_clone_dir'] + '/' + name %}
{% set site = clonee.site | default('github.com') %}
{% set repo = 'git@' + site + ':' + clonee.repo + '.git' %}

Clone self repo {{ name }}:
  git.latest:
    - name: {{ repo }}
    - target: {{ target }}
    {% if clonee.submodule is defined and clonee.submodule %}
    - submodules: true
    {% endif %}

Set username for {{ name }}:
  git.config_set:
    - name: user.name
    - repo: {{ target }}
    - value: fcd

Set email for {{ name }}:
  git.config_set:
    - name: user.email
    - repo: {{ target }}
    - value: {{ pillar['github_email'] }}

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
