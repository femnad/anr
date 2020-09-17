{% if pillar['is_fedora'] %}
Revert to Cgroups v1:
  pkg.installed:
    - name: grubby
  cmd.run:
    - name: grubby --update-kernel=ALL --args=systemd.unified_cgroup_hierarchy=0
  {% if grains['osrelease'] == '31' %}
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
  {% elif grains['osrelease'] == '32' %}
Firewall Trusted Zone for Docker:
  cmd.run:
    - name: firewall-cmd --permanent --zone=trusted --add-interface=docker0

Local connections for Docker:
  cmd.run:
    - name: firewall-cmd --permanent --zone=FedoraWorkstation --add-masquerade

Install Moby et al:
  pkg.installed:
    - pkgs:
      - moby-engine
  user.present:
    - name: {{ pillar['user'] }}
    - groups:
        - docker
    - remove_groups: False
  {% endif %}

{% elif pillar['is_debian'] %}
Install Docker CE:
  pkgrepo.managed:
    - humanname: docker
    - name: deb [arch=amd64] https://download.docker.com/linux/debian {{ grains['oscodename'] }} stable
    - files: /etc/apt/sources.list.d/docker.list
    - key_url: https://download.docker.com/linux/debian/gpg
  pkg.installed:
    - name: docker-ce
{% endif %}
