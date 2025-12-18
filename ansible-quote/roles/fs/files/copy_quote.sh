#!/bin/bash
USERS_FILE="./samba_users.list"

if [[ ! -f "$USERS_FILE" ]]; then
	echo "File not found"
	exit 1
fi

while IFS='' read -r username; do      #-r делает, допустим DOMAIN\User в 'DOMAIN\User' иначе будет '\User'
	edquota -p defuser "$username"
done < "$USERS_FILE"
