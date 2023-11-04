#!/bin/bash

# Define the usage function
usage() {
    cat <<EOF

Usage: fmount [disk] [mount location]
Example: fmount /dev/sdb1 /mounts/data

EOF
}

# Check if the number of arguments is equal to 2, otherwise print usage
if [[ $# != 2 ]]; then
    usage
    exit 1
fi

# Assign arguments to variables
TO_MOUNT="$1"
MOUNT_LOCATION="$2"

# Check if the mount location directory exists, offer to create it if not
if [[ ! -d "$MOUNT_LOCATION" ]]; then
    echo -n "The directory $MOUNT_LOCATION does not exist. Create directory? (yes/no): "
    read USER_DECISION
    if [[ ! "$USER_DECISION" =~ ^(no|No|n|o)$ ]]; then
        mkdir -p "$MOUNT_LOCATION"
        if [[ $? -ne 0 ]]; then
            echo "Directory creation failed. Exiting."
            exit 1
        fi
    else
        echo "OK. As directory does not exist, fmount cannot continue. Terminating."
        exit 1
    fi
fi

# Get UUID and FILESYSTEM for the disk
ID=$(blkid -s UUID -o value "$TO_MOUNT")
FILESYSTEM=$(blkid -s TYPE -o value "$TO_MOUNT")

# Check if we successfully retrieved UUID and FILESYSTEM
if [[ -z "$ID" || -z "$FILESYSTEM" ]]; then
    echo "Unable to find UUID or FILESYSTEM for $TO_MOUNT. Exiting."
    exit 1
fi

# Append the new fstab entry
FINAL_ADDITION="UUID=$ID	$MOUNT_LOCATION	$FILESYSTEM	defaults	0	0"
echo "Adding $FINAL_ADDITION to /etc/fstab. " | sudo tee -a /etc/fstab > /dev/null

# Verify the fstab entries
if [[ ! sudo findmnt --verify > /dev/null 2>&1 ]]; then
    echo "Errors detected in mount verification. Undoing addition to /etc/fstab."
    echo "Faulty entry: $FINAL_ADDITION"
    # Using 'tac' to reverse the lines (making the last line first) and 'sed' to delete the first occurrence
    sudo tac /etc/fstab | sed '0,/^UUID=$ID\s/ s///' | tac | sudo tee /etc/fstab > /dev/null
    exit 1
fi

# Mount the filesystem
if [[ ! sudo mount "$MOUNT_LOCATION" ]] ; then
    echo "Failed to mount $MOUNT_LOCATION. Check /etc/fstab for incorrect entries."
    exit 1
fi

echo "Mount successful."
