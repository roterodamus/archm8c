#!/bin/bash

# Update the package database
sudo pacman -Syu --noconfirm

# Install git
sudo pacman -S --noconfirm git qpwgraph pavucontrol

# Clone the yay repository
git clone http://aur.archlinux.org/yay.git

# Change directory to yay
cd yay || { echo "Failed to enter yay directory"; exit 1; }

# Build and install yay
makepkg -si --noconfirm

# Add the current user to the uucp group
sudo usermod -aG uucp "$USER"

# Add the current user to the autologin group
sudo groupadd -r autologin
sudo usermod -aG autologin "$USER"

# Configure LightDM for autologin
LIGHTDM_CONF="/etc/lightdm/lightdm.conf"

if ! grep -q "autologin-user=$USER" "$LIGHTDM_CONF"; then
    echo "Configuring LightDM for autologin..."
    sudo bash -c "echo '[Seat:*]' >> $LIGHTDM_CONF"
    sudo bash -c "echo 'autologin-user=$USER' >> $LIGHTDM_CONF"
    sudo bash -c "echo 'autologin-user-timeout=0' >> $LIGHTDM_CONF"
fi

# Download m8c using yay
yay -S --noconfirm m8c

# Copy the config file to ~/.config/i3/
CONFIG_FILE="config"
DEST_DIR="$HOME/.config/i3"

# Print the current directory and list files
echo "Current directory: $(pwd)"
echo "Files in the current directory:"
ls -l

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Check if the config file exists and copy it
if [[ -f "$CONFIG_FILE" ]]; then
    cp "$CONFIG_FILE" "$DEST_DIR/"
    echo "Copied $CONFIG_FILE to $DEST_DIR/"
else
    echo "Warning: $CONFIG_FILE does not exist in the current directory."
fi

# Clean up by removing the yay directory
cd .. || exit
rm -rf yay

# Restart the computer
echo "Restarting the computer..."
#sudo reboot

echo "Script completed successfully!"
