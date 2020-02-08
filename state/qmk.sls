Install qmk packages:
  pkg.installed:
     - pkgs: {{ pillar['qmk_packages'] | tojson }}

Add Udev rule for teensy:
  file.managed:
    - name: /etc/udev/rules.d/49-teensy.rules
    - source: salt://udev/teensy.rules.j2
    - template: jinja
    - context:
      user: {{ pillar['user'] }}

Reload teensy udevadm rules:
  cmd.run:
    - name: udevadm control -R
    - onchanges:
        - Add Udev rule for teensy

{% if pillar['is_debian_or_ubuntu'] %}
Uninstall modem manager:
  pkg.removed:
    - name: modemmanager
{% endif %}
