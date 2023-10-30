#!/bin/bash

usage() {
  cat <<EOF
  Usage: fmount [disk] [mount location]
  Example: fmount /dev/sdb1 /mounts/data
  EOF
}

if [[ $# == 0 ]]; then
  usage
fi

TO_MOUNT="$1"
MOUNT_LOCATION="$2"
ID=$(blkid | grep $TO_MOUNT | awk -F '"' '{print $6}')
FINAL_ADDITION="UUID="$ID"  "$MOUNT_LOCATION"  "$FILESYSTEM"  defaults 0 0"
echo "$FINAL_ADDITION" >> /etc/fstab
