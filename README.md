# fmount
### An exceedingly simple bash script for quickly adding disks to /etc/fstab

Usage: `fmount [disk] [mount location]`
For example: `fmount /dev/sdb1 /whatever/data` will append:

`UUID=the_actual_UUID  /whatever/data  the_filesystem  defaults 0 0`

to /etc/fstab. The filesystem is automatically pulled when the script calls `blkid` and the formatting commands that follow.

An error check is run at the script's end via `findmnt --verify`; if errors are found, the changes to /etc/fstab are undone.
