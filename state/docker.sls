{% if pillar['is_fedora'] %}
Revert to Cgroups v1:
  pkg.installed:
    - name: grubby
  cmd.run:
    - name: grubby --update-kernel=ALL --args=systemd.unified_cgroup_hierarchy=0

Install Docker CE:
  cmd.run:
    - name: dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    - unless:
      - docker version
  pkg.installed:
    - pkgs:
      - docker-ce
      - docker-compose
  service.running:
    - name: docker
    - enable: true
  user.present:
    - name: {{ pillar['user'] }}
    - groups:
        - docker
    - remove_groups: False
{% endif %}
