#!/bin/bash
echo "==================================================="
echo "         BEGINNING rsync to OfflineBackup"
echo "==================================================="
# This script checks for a drive with specified UUID and mounts it to a specified location
# It then runs rsync if the drive is successfully mounted, and unmounts the drive after rsync completes
    mount_point="fill data here"
    UUID="fill data here"
    source="fill data here"
    
# Check if the drive is connected
if [ -e /dev/disk/by-uuid/"UUID" ]; then
    # Mount the partition to /mnt/backup
    if ! grep -qs "$mount_point" /proc/mounts; then
        mount /dev/disk/by-uuid/"UUID" "$mount_point"
        if ! grep -qs "$mount_point" /proc/mounts; then
            echo "Failed to mount the drive"
            exit 1
        fi
    fi

    # Run rsync job
    rsync -aPAX --exclude "aquota.group" --exclude "aquota.user" --delete "$source/" "$mount_point/"
    # Use sync command to ensure all data is written to the disk
    sync
    # Add a 5 second delay before unmounting
    sleep 5
    # Unmount the drive after rsync completes
    umount "$mount_point"
    echo "Job complete"
else
    echo "Backup drive not connected"
fi

cleanup() {
    # Unmount the drive before exiting
    if grep -qs "$mount_point" /proc/mounts; then
        umount "$mount_point"
        echo "Drive unmounted before exit"
    fi
}

trap cleanup EXIT

sleep 10
exit
