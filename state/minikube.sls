{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set minikube = home_bin + '/minikube' %}

Download latest minikube:
  file.managed:
    - name: {{ home_bin }}/minikube
    - source: https://github.com/kubernetes/minikube/releases/download/v1.13.0/minikube-linux-amd64
    - skip_verify: true
    - mode: 755

Set default driver:
  cmd.run:
    - name: {{ minikube }} config set driver docker
    - unless:
      - {{ minikube }} config get driver && [ $({{ minikube }} config get driver) == docker ]
    - require:
      - Download latest minikube
