#!/usr/bin/env bash
set -euo pipefail

current=$(git remote get-url origin)
replaced=$(echo $current | sed -r 's_https://([a-zA-Z0-9.-])/([a-z-A-Z0-9.-].git)_git@\1:\2.git_')
git remote set-url origin $replaced
