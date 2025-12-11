#!/bin/bash
if [[ $# -eq 0 ]]; then
	echo "Enter file with groups: $0 <file>"
	exit 1
fi

GROUPS_FILE=$1

if [[ ! -f "$GROUPS_FILE" ]]; then
	echo "File not found"
	exit 1
fi

while IFS=' ' read -r group_name description; do
    	[[ -z "$group_name" || "$group_name" =~ ^[[:space:]]*# ]]
	samba-tool group add "$group_name" --description="$description"

	if [[ $? -ne 0 ]]; then
		echo " '$group_name' not created.. error: $?" 
	else
		echo "Group '$group_name'created with description $description...\nCreating new group..."
	fi
done < "$GROUPS_FILE"
