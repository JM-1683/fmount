#!/bin/bash

usage() {
cat <<EOF

Usage: fmount [disk] [mount location]
Example: fmount /dev/sdb1 /mounts/data

EOF
}

if [[ $# != 2 ]]; then
	usage
	exit 1
fi

TO_MOUNT="$1"
MOUNT_LOCATION="$2"
ID=$(blkid | grep $TO_MOUNT | awk -F'"' '{print $4}')
FILESYSTEM=$(blkid | grep $TO_MOUNT | awk -F '"' '{print $6}')
FINAL_ADDITION="UUID="$ID"	"$MOUNT_LOCATION"	"$FILESYSTEM"	defaults 0 0" 
echo "$FINAL_ADDITION" >> /etc/fstab

STATUS=$(findmnt --verify)
if [[ "$STATUS" != "Success, no errors or warnings detected" ]]; then
echo -e "\nErrors detected in mount verification.\nUndoing addition to /etc/fstab of:\n"
echo -e "$FINAL_ADDITION\n"
sed -i '$d' /etc/fstab
fi

