#!/bin/bash

PROGNAME=$(basename $0)
LANG=

PROJECTPATH=$1

if test -z "$PROJECTPATH"; then
    echo "Usage: $PROGNAME <PROJECTPATH>" 1>&2
    exit 1
fi

if test -e "$PROJECTPATH"; then
    echo "$PROGNAME: directory '$PROJECTPATH' already exists" 1>&2
    exit 2
fi


get_abs_path() {
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

SCRIPT_ABS_PATH=$(get_abs_path $0)


mkdir -vp $PROJECTPATH
pushd $PROJECTPATH >/dev/null

for d in playbooks {group,host}_vars roles; do
    mkdir -v $d
done



function write_out() {
    sed -rn -e '/^={20}[[:space:]]*'"$1"'/,/={20}/p' $SCRIPT_ABS_PATH |
    sed -r -e 1d -e '$d' \
	>$1

    echo "$PROGNAME: created '$1'"
}


for f in ansible.cfg .envrc inventory; do
    write_out $f
done

exit 0


==================== ansible.cfg ====================
[defaults]
inventory = ./inventory
interpreter_python = /usr/bin/python3

#host_key_checking = False

stdout_callback = yaml

gathering = smart
fact_caching = jsonfile
fact_caching_connection = ~/.ansible/fact_cache
fact_caching_timeout = 86400

retry_files_enabled = yes
retry_files_save_path = ~/.ansible/retry-files

force_handlers = true
nocows = true

roles_path = ./roles

vault_id_match = true

ansible_managed = "Managed by ansible, don't make changes here!"

[ssh_connection]
#pipelining = true
==================== .envrc ====================
export ANSIBLE_CONFIG=$(expand_path ansible.cfg)
==================== inventory ====================
# Add your inventory hosts here.
====================
