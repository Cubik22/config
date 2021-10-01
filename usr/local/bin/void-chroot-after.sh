#!/bin/sh

echo "execute this script after installation and in chroot"
echo

# wait for input
read -p "press any key to continue... " input
echo

# set variables
username="lollo"

directory="/root/config"
backup="/root/backup"

# clone bare repository
git clone --bare https://github.com/cubik22/config "$directory"

# create temporary alias
config () {
	/usr/bin/git --git-dir="$directory"/ --work-tree="/" "$@"
}

# backup of configs while copying files in the appropiate places
echo "backing up pre-existing config files"
config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} "$backup"/{}

# set to not show untracked files
config config status.showUntrackedFiles no

# where cargo install packages by default
export CARGO_HOME=/usr/local

# install rust bitwarden client
cargo install rbw

rbw unlock

# set to track upstram 
config push --set-upstream origin main

# remove README from HOME and set git to not track in locale
rm -f /README.md
config update-index --assume-unchanged /README.md

# integrate alsa in pipewire
mkdir -p /etc/alsa/conf.d
ln -s /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d
ln -s /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d

# make sure /etc/doas.conf is owned by root and is read only
chown -c root:root /etc/doas.conf
chmod -c 0400 /etc/doas.conf

# link doas to sudo
ln -s /usr/bin/doas /usr/bin/sudo

# set timezone
# if BIOS/UEFI clock is already set to the correct time use UTC
# if using OpenNTPD set the correct time zone
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
#ln -sf /usr/share/zoneinfo/Etc/GMT+2 /etc/localtime
#ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# link services
ln -s /etc/sv/dbus /etc/runit/runsvdir/default/
ln -s /etc/sv/acpid /etc/runit/runsvdir/default/
ln -s /etc/sv/udevd /etc/runit/runsvdir/default/
ln -s /etc/sv/openntpd /etc/runit/runsvdir/default/
ln -s /etc/sv/dcron /etc/runit/runsvdir/default/
ln -s /etc/sv/iwd /etc/runit/runsvdir/default/
ln -s /etc/sv/bluetoothd /etc/runit/runsvdir/default/
ln -s /etc/sv/seatd /etc/runit/runsvdir/default/

# set unused tty not to start by default
touch /etc/sv/agetty-tty6/down
touch /etc/sv/agetty-tty5/down
touch /etc/sv/agetty-tty4/down

# set bluetooth not to start by default
touch /etc/sv/bluetoothd/down

# make sure bluetooth is unblocked
rfkill unblock bluetooth

# create swap file
echo "how many GiB do you want the swap file to be?"
echo "1) 4GiB"
echo "2) 8GiB"
echo "3) 12GiB"
echo "4) 16GiB"
read swapsize
if [ "$swapsize" = "1" ]; then
	swapcount=4096
elif [ "$swapsize" = "2" ]; then
	swapcount=8192
elif [ "$swapsize" = "3" ]; then
	swapcount=12288
elif [ "$swapsize" = "4" ]; then
	swapcount=16384
else
	swapcount=4096
fi
echo "creating swap file of $swapcount MiB"
dd if=/dev/zero of=/swapfile bs=1M count=$swapcount status=progress
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# set root password
echo "set password root"
passwd root
# set root default shell
chsh -s /bin/bash root

# create user
useradd -m -G wheel,audio,video,input,bluetooth,_seatd $username
echo "set password $username"
passwd $username
# set user default shell
chsh -s /bin/bash $username

# edit /etc/default/grub (set GRUB_DISTRIBUTOR)

# install grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# after changing /etc/default/grub run update-grub

# create fstab file from the mounted system
cat /proc/mounts >> /etc/fstab

# modify /etc/fstab
# add /tmp in ram and /swapfile
echo "tmpfs /tmp tmpfs defaults,nosuid,nodev 0 0" >> /etc/fstab
echo "/swapfile none swap defaults 0 0" >> /etc/fstab

echo
echo "remember to edit /etc/fstab"
echo "remove everything except / /boot tmpfs /swapfile"
echo "set / and /boot to 0 1 and 0 2"
echo "remove errors=remount-ro if using mkinitcpio"
echo "use blkid to get UUID and set UUID= instead of path"
echo

# ensure all installed packages are configured properly
#xbps-reconfigure -fa
echo "remember to run 'xbps-reconfigure -fa' also after reboot"
echo "especially xbps-reconfigure -f linux{VERSION} which runs hooks"

# exit chroot
#exit
# reboot with shutdown or normal
#shutdown -r now
#reboot
