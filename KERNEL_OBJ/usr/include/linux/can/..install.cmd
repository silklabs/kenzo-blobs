cmd_/ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/linux/can/.install := /bin/bash /ws/kenzo/device/kernel/scripts/headers_install.sh /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/linux/can /ws/kenzo/device/kernel/include/uapi/linux/can bcm.h error.h gw.h netlink.h raw.h; /bin/bash /ws/kenzo/device/kernel/scripts/headers_install.sh /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/linux/can /ws/kenzo/device/kernel/include/linux/can ; /bin/bash /ws/kenzo/device/kernel/scripts/headers_install.sh /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/linux/can /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/include/generated/uapi/linux/can ; for F in ; do echo "\#include <asm-generic/$$F>" > /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/linux/can/$$F; done; touch /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/linux/can/.install
