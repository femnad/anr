#!/usr/bin/env bash
set -euo pipefail

current=$(git remote get-url origin)
replaced=$(echo $current | sed -r 's_https://(.*)/(.*)_git@\1:\2_')
git remote set-url origin $replaced
