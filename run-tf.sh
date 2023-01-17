#!/usr/bin/env bash
 
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
 
# Always run from the location of this script
cd "$DIR" || exit 1
 
if [ $# -gt 0 ]; then
    if [ "$1" == "init" ] ; then
        terraform -chdir=./infra/deploy "$@" -var-file=config/variables.tfvars -backend-config=config/backend.tf
    elif [ "$1" == "plan" ] || [ "$1" == "apply" ] || [ "$1" == "destroy" ]; then
        terraform -chdir=./infra/deploy "$@" -var-file=config/variables.tfvars
    else
        terraform -chdir=./infra/deploy "$@"
    fi
fi
 
# Head back to original location to avoid surprises
cd - || exit 1
