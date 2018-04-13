#!/bin/bash
#
# Main script that builds TuXXX operating system.
# Based on Debian.
#
# This code is part of TuXXX project
# https://github.com/tuxxx
#

# Constants
TUXXX_VERSION="1.0"
DEV_MODE=true #TODO:remove
COMMENT_IF_DEV_MODE=""
if [ "$DEV_MODE" = true ]; then
    COMMENT_IF_DEV_MODE="#"
fi

# Options
DEBIAN_ARCH="amd64"
DEBIAN_MIRROR="http://ftp.us.debian.org/debian/"
for opt in "$@"; do
  case ${opt} in
    --arch=*)
      DEBIAN_ARCH="${opt#*=}" ; shift ;;
    --debian_mirror=*)
      DEBIAN_MIRROR="${opt#*=}" ; shift ;;
  esac
done

die() {
    >&2 echo -e "$@" ; exit 1;
}

# Create a minimal debian environment
rm -rf live_boot
mkdir live_boot
debootstrap \
    --arch=$DEBIAN_ARCH \
    --variant=minbase \
    stretch live_boot/chroot \
    $DEBIAN_MIRROR || \
    die "debootstrap failed!"

# Pre-place gtkdialog & bridges_gui source codes for building in first chroot
mkdir -p live_boot/chroot/opt
cp -r /tuxxx/opt/gtkdialog live_boot/chroot/opt/

mkdir -p live_boot/chroot/usr/local/bin
cp -r /tuxxx/opt/bridges_gui /tuxxx/opt/unmute_all live_boot/chroot/usr/local/bin/

# Configure the system inside the chroot
cat << EOF | chroot live_boot/chroot
# Set the hostname
echo "tuxxx" > /etc/hostname

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get --assume-yes install xorg jackd2
apt-get --assume-yes install --no-install-recommends \
    firmware-linux-free \
    linux-image-rt-$DEBIAN_ARCH \
    live-boot systemd-sysv \
    alsa-utils \
    arandr \
    awesome \
    feh \
    iceweasel \
    lightdm \
    mixxx \
    nano \
    network-manager-gnome \
    pavucontrol \
    pulseaudio-module-jack \
    sudo \
    xterm

# Build gtkdialog from source-code
apt-get --assume-yes install --no-install-recommends gcc autoconf automake make pkg-config libgtk2.0-dev texinfo
cd /opt/gtkdialog
./autogen.sh && make && make install && make clean
apt-get --assume-yes remove gcc autoconf automake make pkg-config libgtk2.0-dev texinfo

# Create user "tuxxx" with password "tuxxx"
useradd --password '\$(openssl passwd -1 tuxxx)' --shell /bin/bash --create-home tuxxx
usermod -aG sudo tuxxx

# Mount volume labeled "STORAGE" as home
${COMMENT_IF_DEV_MODE}rm -rf /home/tuxxx
${COMMENT_IF_DEV_MODE}echo "LABEL=STORAGE /home/tuxxx vfat auto,rw,user,sync,exec,dev,suid,uid=1000,gid=1000,umask=000" > /etc/fstab

# Auto-login
sed -i 's/#autologin-user=/autologin-user=tuxxx/' /etc/lightdm/lightdm.conf
sed -i 's/#autologin-user-timeout=/autologin-user-timeout=0/' /etc/lightdm/lightdm.conf

# Disable creation of default folders like Pictures, Documents, etc.
sed -i 's/enabled=True/enabled=False/' /etc/xdg/user-dirs.conf

# Disable Xsession error file
sed -i 's@ERRFILE=\$HOME/.xsession-errors@ERRFILE=/tmp/xsession-errors@' /etc/X11/Xsession
EOF

[[ $? -eq 0 ]] || \
  die "Failed to configure root filesystem!"

# Configure Awesome Window Manager.
rm -rf live_boot/chroot/etc/xdg/awesome
cp -r /tuxxx/config_files/awesome live_boot/chroot/etc/xdg/

# Clean-u  p unnecessary stuff that hogs space
cat << EOF | chroot live_boot/chroot
apt-get --assume-yes autoremove
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF

[[ $? -eq 0 ]] || \
  die "Failed to clean-up root filesystem!"

# Create Hybrid ISO
mkdir -p live_boot/image/{live,isolinux}
(cd live_boot && \
    rm -f image/live/filesystem.squashfs
    mksquashfs chroot image/live/filesystem.squashfs -e boot || \
        die "Failed to create squashfs!"
    cp chroot/boot/vmlinuz-* image/live/vmlinuz1
    cp chroot/boot/initrd.img-* image/live/initrd1
)

cp -f /usr/lib/ISOLINUX/isolinux.bin live_boot/image/isolinux/ && \
cp -f /usr/lib/syslinux/modules/bios/ldlinux.c32 live_boot/image/ && \
cp -f /tuxxx/config_files/isolinux.cfg live_boot/image/ && \

mkdir -p /build
xorriso -as mkisofs \
    -r -J -joliet-long -l \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -partition_offset 16 -A "TuxxxOS" \
    -b isolinux/isolinux.bin \
    -c isolinux/boot.cat \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -o /build/tuxxx-${TUXXX_VERSION}-${DEBIAN_ARCH}.iso \
    ./live_boot/image
