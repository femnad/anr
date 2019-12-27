{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}

Download latest minikube:
  file.managed:
    - name: {{ home_bin }}/minikube
    - source: https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    - source_hash: cbd526d64531266d42f02667339d3c53e5a399e3abebda63c96b0bbd6b7e935d
    - mode: 755

Set default driver:
  cmd.run:
    - name: minikube config set vm-driver kvm2
    - unless:
      - minikube config get vm-driver && [ $(minikube config get vm-driver) == kvm2 ]
