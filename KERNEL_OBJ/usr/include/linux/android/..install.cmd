cmd_/ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/linux/android/.install := /bin/bash /ws/kenzo/device/kernel/scripts/headers_install.sh /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/linux/android /ws/kenzo/device/kernel/include/uapi/linux/android binder.h; /bin/bash /ws/kenzo/device/kernel/scripts/headers_install.sh /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/linux/android /ws/kenzo/device/kernel/include/linux/android ; /bin/bash /ws/kenzo/device/kernel/scripts/headers_install.sh /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/linux/android /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/include/generated/uapi/linux/android ; for F in ; do echo "\#include <asm-generic/$$F>" > /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/linux/android/$$F; done; touch /ws/kenzo/device/out/target/product/msm8952_64/obj/KERNEL_OBJ/usr/include/linux/android/.install
