#!/usr/bin/env bash
set -euo pipefail

current=$(git remote get-url origin)
replaced=$(echo $current | sed -E 's_https://([a-zA-Z0-9.-]+)/([a-zA-Z0-9./-]+.git)_git@\1:\2_')
git remote set-url origin $replaced
