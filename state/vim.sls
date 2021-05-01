{% set home = pillar['home'] %}
{% set user = pillar['user'] %}

{% for dir in pillar['vim_dirs'] %}
Initialize directory {{ dir }}:
  file.directory:
    - name: {{ home }}/.vim/{{ dir }}
    - makedirs: true
    - user: {{ user }}
    - group: {{ user }}
{% endfor %}

VimPlug:
  file.managed:
    - name: {{ home }}/.vim/autoload/plug.vim
    - source: https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    - skip_verify: true
    - makedirs: true
    - user: {{ user }}
    - group: {{ user }}
  cmd.run:
    - name: vim -c ":PlugInstall" -c ":quitall"
    - unless:
      - ls {{ home }}/.vim/plugged/YouCompleteMe/third_party/ycmd
    - runas: {{ user }}

Module:
  cmd.run:
    - name: git submodule update --init --recursive
    - cwd: {{ home }}/.vim/plugged/YouCompleteMe
    - require:
      - VimPlug
    - unless:
      - ls {{ home }}/.vim/plugged/YouCompleteMe/third_party/ycmd
    - runas: {{ user }}

YouCompleteMe:
  cmd.run:
    - name: python3 ./install.py --rust-completer --go-completer
    - cwd: {{ home }}/.vim/plugged/YouCompleteMe
    - require:
      - Module
    - unless:
      - ls {{ home }}/.vim/plugged/YouCompleteMe/python/ycm/__pycache__/__init__.cpython-37.pyc
    - runas: {{ user }}
