#!/usr/bin/env bash
set -euEo pipefail

KNOWN_HOSTS="${HOME}/.ssh/known_hosts"

function does_host_key_exist() {
    host="$1"

    if ! [ -f "$KNOWN_HOSTS" ]
    then
        return 1
    fi

    grep "$host" "$KNOWN_HOSTS"
}

function add_host_key() {
    host="$1"

    ssh-keyscan "$host" >> "$KNOWN_HOSTS"
}

function main() {
    if [ $# -ne 1 ]
    then
        echo "usage: $(basename $0) <hostname>"
        exit 1
    fi

    host="$1"

    if does_host_key_exist "$host"
    then
        return
    fi

    add_host_key "$host"
}

main $@
