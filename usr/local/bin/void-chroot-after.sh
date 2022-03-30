#!/bin/sh

echo "execute this script after installation and in chroot"
echo "name this repository /root/cloned-config otherwise the script cannot clone it"
echo

# wait for input
printf "press any key to continue... "
read -r input
echo

# set bare directory
directory="/root/config"

# clone bare repository
git clone --bare /root/cloned-config "$directory"

# create temporary alias
config () {
    /usr/bin/git --git-dir="$directory"/ --work-tree="/" "$@"
}

# backup of configs while copying files in the appropiate places
echo "backing up pre-existing config files"
config checkout 2>&1 | grep -P '\t' | awk '{print $1}' | xargs -i sh -c 'mkdir -pv "/root/backup/""$(dirname {})"; mv "/"{} "/root/backup/"{};'
echo "checking out"
config checkout

# set to not show untracked files
config config status.showUntrackedFiles no

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

# runtime dir
runtime_dir="/run/user/$(id -u)"
mkdir -p "$runtime_dir"
chown -c root:root "$runtime_dir"
chmod -c 700 "$runtime_dir"

# set timezone
# if BIOS/UEFI clock is already set to the correct time use UTC
# if using OpenNTPD set the correct time zone
ln -sf /usr/share/zoneinfo/Etc/GMT-1 /etc/localtime
# ln -sf /usr/share/zoneinfo/Etc/GMT-2 /etc/localtime
# ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
# ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# cp nerd fonts
cp -r /etc/config/fonts/nerd /usr/share/fonts
# link nerd fonts
# mkdir -p /usr/share/fonts/nerd
# ln -s /etc/config/fonts/nerd/* /usr/share/fonts/nerd/

# link services
ln -s /etc/sv/dbus /etc/runit/runsvdir/default/
ln -s /etc/sv/acpid /etc/runit/runsvdir/default/
ln -s /etc/sv/udevd /etc/runit/runsvdir/default/
ln -s /etc/sv/socklog-unix /etc/runit/runsvdir/default/
ln -s /etc/sv/nanoklogd /etc/runit/runsvdir/default/
ln -s /etc/sv/dcron /etc/runit/runsvdir/default/
ln -s /etc/sv/rngd /etc/runit/runsvdir/default/
ln -s /etc/sv/openntpd /etc/runit/runsvdir/default/
ln -s /etc/sv/iwd /etc/runit/runsvdir/default/
ln -s /etc/sv/seatd /etc/runit/runsvdir/default/
ln -s /etc/sv/wireguard /etc/runit/runsvdir/default/
ln -s /etc/sv/bluetoothd /etc/runit/runsvdir/default/
ln -s /etc/sv/tlp /etc/runit/runsvdir/default/
ln -s /etc/sv/sshd /etc/runit/runsvdir/default/

# services to not start by default
touch /etc/sv/wireguard/down
touch /etc/sv/bluetoothd/down
touch /etc/sv/tlp/down
touch /etc/sv/sshd/down

# make sure bluetooth is unblocked
rfkill unblock bluetooth

# do not use bitmap fonts
rm -f /etc/fonts/conf.d/10-scale-bitmap-fonts.conf
rm -f /etc/fonts/conf.d/70-yes-bitmaps.conf

# font config
ln -s /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
ln -s /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
ln -s /usr/share/fontconfig/conf.avail/25-unhint-nonlatin.conf /etc/fonts/conf.d/
ln -s /usr/share/fontconfig/conf.avail/50-user.conf /etc/fonts/conf.d/
ln -s /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/

# create swap file
echo "how many GiB do you want the swap file to be?"
echo "1) 4GiB"
echo "2) 8GiB"
echo "3) 12GiB"
echo "4) 16GiB"
read -r swapsize
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
dd if=/dev/zero of=/swapfile bs=1M count="$swapcount" status=progress
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# set hostname
printf "set hostname: "
read -r hostname
echo "$hostname" > /etc/hostname

cat << EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
EOF

# set root password
echo "set password root"
passwd root
# set root default shell
chsh -s /bin/bash root

# create user
printf "set username: "
read -r username
useradd -m -G wheel,audio,video,input,bluetooth,_seatd,adbusers "$username"
echo "set password $username"
passwd "$username"
# set user default shell
chsh -s /bin/bash "$username"

# edit /etc/default/grub (set GRUB_DISTRIBUTOR)

# install grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Void

# after changing /etc/default/grub run update-grub

# create fstab file from the mounted system
cat /proc/mounts >> /etc/fstab

# modify /etc/fstab
# add /tmp in ram and /swapfile
echo "tmpfs /tmp tmpfs defaults,nosuid,nodev 0 0" >> /etc/fstab
echo "/swapfile none swap defaults 0 0" >> /etc/fstab

echo
echo "remember to edit /etc/fstab"
echo "remove everything except what do you want to mount like (/ /boot) and tmpfs /swapfile"
echo "set / to 0 1 and other filesystem mounted (like /boot) to 0 2"
echo "leave tmpfs and /swapfile to 0 0"
echo "remove errors=remount-ro if using mkinitcpio (in void)"
echo "use blkid to get UUID and set UUID= instead of path"

# locales
echo "uncomment locales in /etc/default/libc-locales"
echo "then generate locales with: xbps-reconfigure -f glibc-locales"

# ensure all installed packages are configured properly
# xbps-reconfigure -fa
echo
echo "remember to run 'xbps-reconfigure -fa' after having removed usb stick and also after reboot"
echo "especially xbps-reconfigure -f linux{VERSION} which runs hooks"

# android
echo
echo "edit /etc/udev/rules.d/51-android.rules for android devices"
echo "run lsusb for vendor id and product id"

# exit chroot
# exit
# reboot with shutdown or normal
# shutdown -r now
# reboot
