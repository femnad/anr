{% set user = pillar['user'] %}
{% set home = pillar['home'] %}
{% set home_bin = home + '/bin' %}

{% if pillar['is_fedora'] %}
Install Flatpak Remote:
  cmd.run:
    - name: flatpak remote-add flathub https://flathub.org/repo/flathub.flatpakrepo
    - unless:
        - flatpak remotes | grep -E 'flathub'

Install Spotify via Flatpak:
  cmd.run:
    - name: flatpak install -y flathub com.spotify.Client
    - unless:
        - flatpak list | grep -E '^Spotify'

Add Flatpak Spotify script:
  file.managed:
    - name: {{ home_bin }}/spotify
    - contents: |
        #!/usr/bin/env bash
        flatpak run com.spotify.Client
    - mode: 0755
    - user: {{ user }}
    - group: {{ user }}
{% endif %}
