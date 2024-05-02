#!/bin/bash
if [ -z "$1" ]; then
  echo Usage: "$0" /dev/mmcblkX
  exit 1
fi

set -ex
DEV=$1
MNT="mnt"

cleanup() {
  umount "$MNT/boot" || true
  umount "$MNT" || true
}

trap cleanup EXIT

(
  echo o # create dos partion table
  echo -e "n\np\n1\n\n+500M" # add primary partion 1
  echo -e "t\nc\n" # partition type W95 FAT32 (LBA)
  echo -e "n\np\n2\n\n\n" # add primary partion 2 with rest of space
  echo w # save table
) | fdisk "$DEV" --noauto-pt --wipe-partitions always

mkfs.fat "$DEV"p1
mkfs.ext4 "$DEV"p2

mkdir -p "$MNT"
mount "$DEV"p2 "$MNT"
mkdir -p "$MNT/boot"
mount "$DEV"p1 "$MNT/boot"

curl -L http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz | tar -xpzf - -C "$MNT" || true # fails on FAT32 missing permissions functionality

sed -i 's/mmcblk0/mmcblk1/g' "$MNT/etc/fstab"

# allow only ssh key auth and root user
sed -Ei 's/#?PermitRootLogin.+/PermitRootLogin prohibit-password/' "$MNT/etc/ssh/sshd_config"
sed -Ei 's/#?PasswordAuthentication.+/PasswordAuthentication no/' "$MNT/etc/ssh/sshd_config"

if [ -f ~/.ssh/id_rsa.pub ]; then
  mkdir -p "$MNT/root/.ssh"
  cp ~/.ssh/id_rsa.pub $MNT/root/.ssh/authorized_keys
  chmod -R 600 "$MNT/root/.ssh"
fi

sync

echo "Image written"
