#!/bin/bash
if [[ $# -eq 0 ]]; then
	echo "Enter file with users: $0 <file>"
	echo "Template string in file: vmi Вахрамеев Макар [opiti, Domain Admins] 89315051141"
	exit 1
fi

USERS_FILE="$1"

if [[ ! -f "$USERS_FILE" ]]; then
	echo "File not found"
	exit 1
fi

while IFS=' ' read -r user surname name rest; do
    	[[ -z "$user" || "$user" =~ ^[[:space:]]*# ]] && continue

        if [[ "$rest" =~ \[([^]]+)\]([[:space:]]+[0-9]{11})?$ ]]; then
        	groups_raw="${BASH_REMATCH[1]}"
        	number="${BASH_REMATCH[2]:+$(echo "${BASH_REMATCH[2]}" | grep -o '[0-9]\{11\}')}"
  	else
        	groups_raw=""
        	number=$(echo "$rest" | grep -o '[0-9]\{11\}$')
    	fi
	
	echo "Create user $user, set password for him."
  	if samba-tool user add "$user" --given-name="$name" --surname="$surname" --telephone-number="$number"; then

		IFS=',' read -ra GROUP_ARRAY <<< "$groups_raw"
    			for raw_g in "${GROUP_ARRAY[@]}"; do
        		g=$(echo "$raw_g" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
       			echo "Adding $user to '$g'..."
       			samba-tool group addmembers "$g" "$user" || echo "  ✗ '$g' not found"
    		done
    
	else
		echo "Failed to create user..."
	fi

done < "$USERS_FILE"
