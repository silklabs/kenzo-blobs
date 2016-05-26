LOCAL_PATH := $(dir $(lastword $(MAKEFILE_LIST)))

SYSTEM_BLOBS := $(shell find $(LOCAL_PATH)system)
SYSTEM_BLOBS_COPY_FILES := \
  $(foreach BLOB,$(SYSTEM_BLOBS),$(BLOB):/$(BLOB:$(LOCAL_PATH)%=%))

PRODUCT_COPY_FILES += $(SYSTEM_BLOBS_COPY_FILES)

# Use a blob kernel because sadly the complete source is not currently known
TARGET_PREBUILT_KERNEL := $(LOCAL_PATH)/boot/kernel
PRODUCT_COPY_FILES += $(LOCAL_PATH)/boot/dtb:dt.img
TARGET_KERNEL_DLKM_DISABLE := true

# Yikes! Many CAF components want kernel headers, fake them out with something
#        hopefully close to what the blob kernel exports.  These headers where
#        obtained from https://github.com/MiCode/Xiaomi_Kernel_OpenSource/tree/kenzo-l-oss
$(shell mkdir -p out/target/product/msm8952_64/obj/KERNEL_OBJ/usr)
$(shell ln -sf $(abspath $(LOCAL_PATH)/KERNEL_OBJ/usr/include) out/target/product/msm8952_64/obj/KERNEL_OBJ/usr)

