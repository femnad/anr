libasound2-dev:
  pkg.installed

Spotifyd:
  git.cloned:
    - name: https://github.com/Spotifyd/spotifyd
    - target: {{ pillar['clone_dir'] }}/spotifyd
  cmd.run:
    - name: cargo build
    - cwd: {{ pillar['clone_dir'] }}/spotifyd
    - require:
        - libasound2-dev
