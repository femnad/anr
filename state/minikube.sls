{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set minikube = home_bin + '/minikube' %}

Download latest minikube:
  file.managed:
    - name: {{ home_bin }}/minikube
    - source: https://github.com/kubernetes/minikube/releases/download/v1.7.2/minikube-linux-amd64
    - source_hash: 9f543f464b4d93a259f7d5a7578edff1316370d45b5a0679b86ed7a61b01634d
    - mode: 755

Set default driver:
  cmd.run:
    - name: {{ minikube }} config set vm-driver kvm2
    - unless:
      - {{ minikube }} config get vm-driver && [ $({{ minikube }} config get vm-driver) == kvm2 ]
    - require:
      - Download latest minikube
