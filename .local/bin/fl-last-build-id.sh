#!/bin/bash

set -e
set -o pipefail

if [[ -z "$1" ]] || [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: fl-last-build-id.sh <catalog-name>

Fetches the last_build_id for the given catalog_name.
Prints null if the entity does not exist.
'
    exit
fi


flowctl raw get --table live_specs --query select=last_build_id --query "catalog_name=eq.$1" | jq -r '.[0].last_build_id'
