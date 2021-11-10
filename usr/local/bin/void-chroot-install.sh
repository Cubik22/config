#!/bin/sh

echo "have you cloned this repository already in /mnt (/mnt/root)?"
echo "have you mounted /mnt and /mnt/boot and other partitions?"
echo "if reinstalling remember to clean stuff in /mnt/boot"
echo "run this script from the directory it is in (cloned-config/usr/local/bin)"
echo "if download of packages is slow stop the script and edit it choosing a faster repo (1, 2 or 3)"
echo

# wait for input
printf "press any key to continue... "
read input
echo

# set xbps variables
xbpsconf=/mnt/etc/xbps.d
ignorefile="$xbpsconf"/ignorepkg.conf

# create xbpsconf directory
mkdir -p $xbpsconf

# set packages to be ignored as dependecy
# also add in /etc/xbps.d/ignorepkg.conf
echo "ignorepkg=linux-firmware-amd" 		 > $ignorefile
echo "# ignorepkg=linux-firmware-nvidia" 	>> $ignorefile
echo "ignorepkg=sudo" 						>> $ignorefile
echo "ignorepkg=btrfs-progs" 				>> $ignorefile
echo "ignorepkg=xfsprogs" 					>> $ignorefile
echo "ignorepkg=f2fs-tools" 				>> $ignorefile
echo "ignorepkg=wpa_supplicant" 			>> $ignorefile
echo "ignorepkg=dhcpcd" 					>> $ignorefile
echo "ignorepkg=NetworkManager" 			>> $ignorefile
echo "ignorepkg=connman" 					>> $ignorefile
echo "ignorepkg=pulseaudio" 				>> $ignorefile
echo "ignorepkg=nvi" 						>> $ignorefile
echo "ignorepkg=vim"						>> $ignorefile
echo "ignorepkg=gvim"						>> $ignorefile

repo1="https://alpha.de.repo.voidlinux.org/current/musl"
repo2="https://mirrors.servercentral.com/voidlinux/current/musl"
repo3="https://alpha.us.repo.voidlinux.org/current/musl"

# install non free repository in order to install intel-ucode
echo | XBPS_ARCH=x86_64-musl xbps-install -S -y -r /mnt -R $repo1 -R $repo2 -R $repo3 void-repo-nonfree

# install normal base packages
echo | XBPS_ARCH=x86_64-musl xbps-install -S -y -r /mnt -R $repo1 -R $repo2 -R $repo3 $(cat ../../../etc/config/xbps-packages-base)

# install octave base packages
echo | XBPS_ARCH=x86_64-musl xbps-install -S -y -r /mnt -R $repo1 -R $repo2 -R $repo3 $(cat ../../../etc/config/xbps-packages-octave-base)

# install normal devel packages
echo | XBPS_ARCH=x86_64-musl xbps-install -S -y -r /mnt -R $repo1 -R $repo2 -R $repo3 $(cat ../../../etc/config/xbps-packages-devel)

# install octave devel packages
# echo | XBPS_ARCH=x86_64-musl xbps-install -S -y -r /mnt -R $repo1 -R $repo2 -R $repo3 $(cat ../../../etc/config/xbps-packages-octave-devel)

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
