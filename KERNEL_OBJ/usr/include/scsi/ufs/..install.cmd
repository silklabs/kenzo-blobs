cmd_/ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/scsi/ufs/.install := /bin/bash /ws/kenzo/device/kernel/scripts/headers_install.sh /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/scsi/ufs /ws/kenzo/device/kernel/include/uapi/scsi/ufs ioctl.h ufs.h; /bin/bash /ws/kenzo/device/kernel/scripts/headers_install.sh /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/scsi/ufs /ws/kenzo/device/kernel/include/scsi/ufs ; /bin/bash /ws/kenzo/device/kernel/scripts/headers_install.sh /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/scsi/ufs /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/include/generated/uapi/scsi/ufs ; for F in ; do echo "\#include <asm-generic/$$F>" > /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/scsi/ufs/$$F; done; touch /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/scsi/ufs/.install
