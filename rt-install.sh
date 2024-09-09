#!/bin/bash

# Copy the config files
mkdir -p ~/.config/i3
cp config ~/.config/i3/

mkdir -p ~/.local/share/m8c
cp config.ini ~/.local/share/m8c/

# Update the package database & Install git
sudo pacman -Syu --noconfirm

sudo pacman -S --noconfirm git qpwgraph pavucontrol unclutter xorg-xrandr antimicrox bluez bluez-utils blueberry linux-rt linux-rt-headers rtkit realtime-privileges

sudo systemctl enable bluetooth
# Clone the yay repository
git clone http://aur.archlinux.org/yay.git

# Change directory to yay
cd yay || { echo "Failed to enter yay directory"; exit 1; }

# Build and install yay
makepkg -si --noconfirm

# Add the current user to the groups
sudo groupadd -r autologin
sudo usermod -aG autologin "$USER"
sudo usermod -aG realtime "$USER"
sudo usermod -aG audio "$USER"
sudo usermod -aG uucp "$USER"

# Configure LightDM for autologin
LIGHTDM_CONF="/etc/lightdm/lightdm.conf"

if ! grep -q "autologin-user=$USER" "$LIGHTDM_CONF"; then
    echo "Configuring LightDM for autologin..."
    sudo bash -c "echo '[Seat:*]' >> $LIGHTDM_CONF"
    sudo bash -c "echo 'autologin-user=$USER' >> $LIGHTDM_CONF"
    sudo bash -c "echo 'autologin-user-timeout=0' >> $LIGHTDM_CONF"
fi
# Get the index of the real-time kernel entry
RT_KERNEL_INDEX=$(grep -n "linux-rt" /boot/grub/grub.cfg | cut -d: -f1 | head -n 1)

if [ -n "$RT_KERNEL_INDEX" ]; then
    # Adjust the index for grub-set-default (0-based index)
    DEFAULT_INDEX=$((RT_KERNEL_INDEX - 1))
    echo "Setting the real-time kernel as the default in GRUB (index: $DEFAULT_INDEX)..."
    sudo grub-set-default "$DEFAULT_INDEX"
else
    echo "Real-time kernel entry not found in GRUB configuration."
fi

# Change GRUB timeout to 0
GRUB_CONF="/etc/default/grub"

if grep -q "^GRUB_TIMEOUT=" "$GRUB_CONF"; then
    sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' "$GRUB_CONF"
else
    echo "GRUB_TIMEOUT=0" | sudo tee -a "$GRUB_CONF"
fi

# Update GRUB configuration
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Download m8c using yay
yay -S --noconfirm m8c xpadneo-dkms

# Restart the computer
echo "Restarting the computer..."
sudo reboot
