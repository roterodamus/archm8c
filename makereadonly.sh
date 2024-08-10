#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Backup fstab
cp /etc/fstab /etc/fstab.bak
echo "Backup of /etc/fstab created at /etc/fstab.bak"

# Get the UUID of the root filesystem
ROOT_UUID=$(blkid -s UUID -o value)
if [ -z "$ROOT_UUID" ]; then
    echo "Could not find UUID for the root filesystem."
    exit 1
fi

# Modify /etc/fstab to mount root as read-only
if grep -q "UUID=$ROOT_UUID" /etc/fstab; then
    sed -i "s|^UUID=$ROOT_UUID .*|UUID=$ROOT_UUID / ext4 ro,noatime 0 1|" /etc/fstab
    echo "Updated /etc/fstab to mount root as read-only."
else
    echo "UUID=$ROOT_UUID / ext4 ro,noatime 0 1" >> /etc/fstab
    echo "Added entry to /etc/fstab to mount root as read-only."
fi

# Create remount scripts
cat << 'EOF' > /usr/local/bin/remount_rw.sh
#!/bin/bash
mount -o remount,rw /
EOF

cat << 'EOF' > /usr/local/bin/remount_ro.sh
#!/bin/bash
mount -o remount,ro /
EOF

# Make the scripts executable
chmod +x /usr/local/bin/remount_rw.sh
chmod +x /usr/local/bin/remount_ro.sh

echo "Remount scripts created and made executable."

# Inform the user
echo "Configuration complete."
echo "Use the following commands to remount the root filesystem:"
echo "To remount as read-write: sudo /usr/local/bin/remount_rw.sh"
echo "To remount as read-only: sudo /usr/local/bin/remount_ro.sh"
