#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}" || realpath "${BASH_SOURCE[0]}")")

main() {
    local provider="${INPUT_PROVIDER}"
    local command="${INPUT_COMMAND}"

    [ "$INPUT_NAME" ] && export CLUSTER_NAME="$INPUT_NAME"
    [ "$INPUT_SIZE" ] && export CLUSTER_SIZE="$INPUT_SIZE"
    [ "$INPUT_MACHINE" ] && export CLUSTER_MACHINE="$INPUT_MACHINE"
    [ "$INPUT_REGION" ] && export CLUSTER_REGION="$INPUT_REGION"
    [ "$INPUT_REGISTRY" ] && export CLUSTER_REGISTRY="$INPUT_REGISTRY"

    export CLUSTER_PROVIDER="$provider"

    if [ ! -e /tmp/.cluster-provider-setup-$provider ] ; then
        "$SCRIPT_DIR/providers.sh" "setup"
        touch /tmp/.cluster-provider-setup-$provider
    fi

    "$SCRIPT_DIR/providers.sh" "$command"
    "$SCRIPT_DIR/providers.sh" "get-env"
}

main
