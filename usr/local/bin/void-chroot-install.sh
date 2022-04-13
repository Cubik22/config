#!/bin/sh

echo "have you cloned this repository in /mnt (/mnt/root/cloned-config)?"
echo "have you mounted /mnt and /mnt/boot and other partitions?"
echo "if reinstalling remember to clean stuff in /mnt/boot"
echo "run this script from the directory it is in (cloned-config/usr/local/bin)"
echo "if download of packages is slow stop the script and edit it choosing a faster repo (1, 2 or 3)"
echo

# wait for input
printf "press any key to continue... "
read -r input
unset input
echo

# set xbps variables
xbpsconf=/mnt/etc/xbps.d
ignorefile="$xbpsconf"/ignorepkg.conf

# create xbpsconf directory
mkdir -p "$xbpsconf"

# set packages to be ignored as dependecy
# also add in /etc/xbps.d/ignorepkg.conf
cat << EOF > "$ignorefile"
# add also in /usr/local/bin/void-chroot-install.sh
ignorepkg=linux-firmware-amd
# ignorepkg=linux-firmware-nvidia
ignorepkg=sudo
ignorepkg=btrfs-progs
ignorepkg=xfsprogs
ignorepkg=f2fs-tools
ignorepkg=wpa_supplicant
ignorepkg=dhcpcd
ignorepkg=NetworkManager
ignorepkg=connman
ignorepkg=pulseaudio
ignorepkg=nvi
ignorepkg=vim
ignorepkg=gvim
ignorepkg=xorg-server-xwayland
EOF

repo1="https://alpha.de.repo.voidlinux.org/current"
repo2="https://repo-fi.voidlinux.org/current"
repo3="https://mirrors.servercentral.com/voidlinux/current"
repo4="https://repo-us.voidlinux.org/current"

packages_folder="../../../etc/config/xbps-packages"

# install non free repository in order to install intel-ucode
echo | XBPS_ARCH=x86_64 xbps-install -S -y -r /mnt -R "$repo1" -R "$repo2" -R "$repo3" -R "$repo4" void-repo-nonfree

# install intel-ucode
echo | XBPS_ARCH=x86_64 xbps-install -S -y -r /mnt -R "$repo1" -R "$repo2" -R "$repo3" -R "$repo4" intel-ucode

# install normal base packages
echo | XBPS_ARCH=x86_64 xbps-install -S -y -r /mnt -R "$repo1" -R "$repo2" -R "$repo3" -R "$repo4" $(cat "$packages_folder/base")

# install python base packages
echo | XBPS_ARCH=x86_64 xbps-install -S -y -r /mnt -R "$repo1" -R "$repo2" -R "$repo3" -R "$repo4" $(cat "$packages_folder/python")

# install normal devel packages
echo | XBPS_ARCH=x86_64 xbps-install -S -y -r /mnt -R "$repo1" -R "$repo2" -R "$repo3" -R "$repo4" $(cat "$packages_folder/devel")

# install fontforge devel packages
echo | XBPS_ARCH=x86_64 xbps-install -S -y -r /mnt -R "$repo1" -R "$repo2" -R "$repo3" -R "$repo4" $(cat "$packages_folder/fontforge")

# install octave base packages
echo | XBPS_ARCH=x86_64 xbps-install -S -y -r /mnt -R "$repo1" -R "$repo2" -R "$repo3" -R "$repo4" $(cat "$packages_folder/octave-base")

# install octave devel packages
echo | XBPS_ARCH=x86_64 xbps-install -S -y -r /mnt -R "$repo1" -R "$repo2" -R "$repo3" -R "$repo4" $(cat "$packages_folder/octave-devel")

# in order to have network (set manually after)
# cp /etc/resolv.conf /mnt/etc/resolv.conf
# cp /etc/hosts /mnt/etc/hosts

# mount pseudo-filesystems
mount --rbind /sys /mnt/sys && mount --make-rslave /mnt/sys
mount --rbind /dev /mnt/dev && mount --make-rslave /mnt/dev
mount --rbind /proc /mnt/proc && mount --make-rslave /mnt/proc

# chroot into the new installation
echo "if you have cloned this repository not in /mnt copy it there (/mnt/root) before entering chroot"
echo "entering chroot:"
echo "PS1=\"(chroot)# \" chroot /mnt/ /bin/bash"
