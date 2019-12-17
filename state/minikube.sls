{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}
{% set user = pillar['user'] %}

Download latest minikube:
  file.managed:
    - name: {{ home_bin }}/minikube
    - source: https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    - source_hash: cbd526d64531266d42f02667339d3c53e5a399e3abebda63c96b0bbd6b7e935d
    - mode: 755
    - user: {{ user }}
    - group: {{ user }}

Install Libvirt and qemu:
  pkg.installed:
    - pkgs:
      - libvirt
      - qemu

Set Libvirtd socket owner:
  file.line:
    - name: /etc/libvirt/libvirtd.conf
    - content: unix_sock_group = "libvirt"
    - after: '#unix_sock_group = "libvirt"'
    - mode: insert

Add user to libvirt group:
  user.present:
    - name: {{ user }}
    - groups:
        - libvirt
    - remove_groups: False

Start libvirtd service:
  service.running:
    - name: libvirtd
    - watch:
      - file: /etc/libvirt/libvirtd.conf

Set default driver:
  cmd.run:
    - name: minikube config set vm-driver kvm2
    - runas: {{ user }}
    - unless:
      - minikube config get vm-driver && [ $(minikube config get vm-driver) == kvm2 ]
