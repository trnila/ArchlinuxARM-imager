# ArchlinuxARM SD card imager

Usage:
```
$ sudo ./write_sdcard.sh /dev/mmcblk0
```

Device can be accessed via USB:
1. CDC ethernet via link-local IPv6 and DNS-SD
   ```
   $ ssh root@alarm.local
   ```
2. ACM serial link
   ```
   $ minicom -D /dev/ttyACM0 -b 115200
   ```
