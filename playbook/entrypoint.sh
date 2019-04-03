#!/bin/sh

set -xe

rm -rf /playbook/roles/deployment
cp -R /deployment /playbook/roles/.

ansible-playbook -i hosts --vault-id /playbook/vault-password.sh --extra-vars "$EXTRA_VARS" playbook.yml -vvv
