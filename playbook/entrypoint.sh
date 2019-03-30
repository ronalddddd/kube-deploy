#!/bin/sh

set -xe

rm -rf /playbook/roles/deployment
cp -R /deployment /playbook/roles/.

ansible-playbook -i hosts playbook.yml --extra-vars "$EXTRA_VARS"
