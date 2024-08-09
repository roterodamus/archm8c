# ArchM8C: A Simple Bash Script for Dirtywave M8 Console

This repository contains a straightforward Bash script that transforms your PC into an "M8C Console" for the Dirtywave M8 or the Dirtywave M8 Headless.

## Prerequisites

This script is designed for use on a fresh Arch Linux system with the following requirements:

- An active internet connection
- A user account with sudo privileges
- GRUB bootloader
- LightDM display manager
- i3 Window Manager
- Git

Install Arch Linux using the `archinstall` script for simplicity.

Or use archinstall with the following config file. 

   ```bash
   archinstall --config https://dpaste.com/8AWVXMAKC.txt
   ```
>1. Select your local mirror location.
>2. Enter disk configuration, use best effort on your desired drive
>3. make a user account with sudo privileges
>4. Select your timezone
>5. Install

> <sub> dpaste available untill 09-Aug-25 </sub>


## Installation Instructions


1. Clone the repository:
   ```bash
   git clone https://github.com/roterodamus/archm8c.git
   ```

2. Navigate to the cloned directory:
   ```bash
   cd archm8c
   ```

3. Make the installation script executable:
   ```bash
   chmod +x install.sh
   ```

4. Run the installation script:
   ```bash
   ./install.sh
   ```

## A very special thanks to:

- Trash80 - [Dirtywave](https://dirtywave.com/)
- [M8C](https://github.com/laamaa/m8c)
- and the entire FOSS Linux community.

   

