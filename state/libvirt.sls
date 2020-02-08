{% set user = pillar['user'] %}

Install Libvirt and qemu:
  pkg.installed:
    - pkgs: {{ pillar['libvirt_packages'] | tojson }}

Set Libvirtd socket owner:
  file.line:
    - name: /etc/libvirt/libvirtd.conf
    - content: unix_sock_group = "libvirt"
    - after: '#unix_sock_group = "libvirt"'
    - mode: replace

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
