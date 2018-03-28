#!/usr/bin/env bash
#
# Main script that builds TuXXX operating system.
# Based on Debian.
#
# This code is part of TuXXX project
# https://github.com/tuxxx
#

DEBIAN_ARCH="amd64"
DEBIAN_VERSION="stretch"
DEBIAN_MIRROR="http://ftp.us.debian.org/debian/"
MAKE_ISO=false

# Create the minimal debian environment
sudo rm -rf live_boot
mkdir live_boot
sudo debootstrap \
    --arch=$DEBIAN_ARCH \
    --variant=minbase \
    $DEBIAN_VERSION live_boot/chroot \
    $DEBIAN_MIRROR

# Pre-place gtkdialog source codes
sudo mkdir -p live_boot/chroot/opt
sudo mkdir -p live_boot/chroot/usr/local/bin
sudo cp -r opt/gtkdialog live_boot/chroot/opt/
sudo cp -r opt/bridges_gui live_boot/chroot/usr/local/bin/

# Configure the system inside the chroot
cat << EOF | sudo chroot live_boot/chroot
# Set the hostname
echo "tuxxx" > /etc/hostname

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get --assume-yes install xorg jackd2
apt-get --assume-yes install --no-install-recommends linux-image-rt-$DEBIAN_ARCH live-boot systemd-sysv firmware-linux-free sudo nano
apt-get --assume-yes install --no-install-recommends lightdm awesome arandr xterm feh network-manager-gnome xterm iceweasel
apt-get --assume-yes install --no-install-recommends pulseaudio-module-jack mixxx alsa-utils pavucontrol

apt-get --assume-yes install --no-install-recommends gcc autoconf automake make pkg-config libgtk2.0-dev texinfo
cd /opt/gtkdialog
./autogen.sh && make && make install && make clean
apt-get --assume-yes remove gcc autoconf automake make pkg-config libgtk2.0-dev texinfo

# Create user "tuxxx" with password "tuxxx"
useradd --password '$(openssl passwd -1 tuxxx)' --shell /bin/bash --create-home tuxxx
usermod -aG sudo tuxxx

# Mount volume labeled "STORAGE" as home
#rm -rf /home/tuxxx
#echo "LABEL=STORAGE /home/tuxxx vfat auto,rw,user,sync,exec,dev,suid,uid=1000,gid=1000,umask=000" > /etc/fstab

# Auto-login
sed -i 's/#autologin-user=/autologin-user=tuxxx/' /etc/lightdm/lightdm.conf
sed -i 's/#autologin-user-timeout=/autologin-user-timeout=0/' /etc/lightdm/lightdm.conf

# Disable creation of default folders like Pictures, Documents, etc.
sed -i 's/enabled=True/enabled=False/' /etc/xdg/user-dirs.conf

# Disable Xsession error file FIXME: awesome fails to start with this :(
sed -i 's@ERRFILE=\$HOME/.xsession-errors@ERRFILE=/tmp/xsession-errors@' /etc/X11/Xsession
EOF

# Configure Awesome Window Manager.
sudo rm -rf live_boot/chroot/etc/xdg/awesome
sudo cp -r config_files/awesome live_boot/chroot/etc/xdg/

# Build and install Alsa-JACK Bridges utility
sudo cp -r opt/bridges_gui live_boot/chroot/usr/local/bin/

# Clean-up unnecessary stuff that hogs space
cat << EOF | sudo chroot live_boot/chroot
apt-get --assume-yes autoremove
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF

# Prepare files for UEFI boot partition.
mkdir -p live_boot/image/{live,isolinux}
(cd live_boot && \
    rm -f image/live/filesystem.squashfs
    sudo mksquashfs chroot image/live/filesystem.squashfs -e boot
    cp chroot/boot/vmlinuz-* image/live/vmlinuz1
    cp chroot/boot/initrd.img-* image/live/initrd1
)

# Create an ISO (for testing in virtual machine, false by default)
if [ "$MAKE_ISO" = true ]; then
    cp -f /usr/lib/ISOLINUX/isolinux.bin live_boot/image/isolinux/ && \
    cp -f /usr/lib/syslinux/modules/bios/ldlinux.c32 live_boot/image/isolinux/ && \
    cp -f config_files/isolinux.cfg live_boot/image/isolinux/ && \
    genisoimage \
        -rational-rock \
        -volid SYSTEM \
        -cache-inodes \
        -joliet \
        -hfs \
        -full-iso9660-filenames \
        -b isolinux/isolinux.bin \
        -c isolinux/boot.cat \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        -output tuxxx.iso \
        live_boot/image
fi


