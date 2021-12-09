# config

my config files for Void Linux with River

## instructions


```
# mount necessary partitions (/, /boot, maybe /home)

# clone this repository in /root/cloned-config of the new system
# probably /mnt/root/cloned-config
git clone https://github.com/lbia/config.git /mnt/root/cloned-config

cd /mnt/root/cloned-config/usr/local/bin

./void-chroot-install.sh

PS1="(chroot)# " chroot /mnt/ /bin/bash

cd /root/cloned-config

usr/local/bin/void-chroot-after.sh
