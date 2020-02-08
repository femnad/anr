Add user to dialout/uucp group:
  user.present:
    - name: {{ pillar['user'] }}
    - groups:
        {% if pillar['is_arch'] %}
        - uucp
        {% else %}
        - dialout
        {% endif %}
    - remove_groups: False

Add udev rule:
  file.managed:
    - name: /etc/udev/rules.d/99-kaleidoscope.rules
    - source: salt://udev/kaleidoscope.rules

Reload udevadm rules:
  cmd.run:
    - name: udevadm control -R
    - onchanges:
        - Add udev rule
