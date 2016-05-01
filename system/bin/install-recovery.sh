#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/bootdevice/by-name/recovery:34407758:1f4caf6f15d1ee54f9152e130104d58d97c459a7; then
  applypatch -b /system/etc/recovery-resource.dat EMMC:/dev/block/bootdevice/by-name/boot:33721674:bf5d61ecd25d0026e768f6258f320640385976fd EMMC:/dev/block/bootdevice/by-name/recovery 1f4caf6f15d1ee54f9152e130104d58d97c459a7 34407758 bf5d61ecd25d0026e768f6258f320640385976fd:/system/recovery-from-boot.p && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
