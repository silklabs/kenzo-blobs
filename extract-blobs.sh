#!/bin/bash -e
#
# Extracts blobs off the device attached via ADB that don't already exist in
# $ANDROID_PRODUCT_OUT/system.
#
# Hints:
#   0. Load the blobful system.img on the device, and ensure you're running a
#      -userdebug or -eng boot.img.
#   1. Run |source envsetup.sh| before this script.
#   2. Prepare $ANDROID_PRODUCT_OUT/system by first building with all blobs
#      removed from the tree.
#

if [[ -z $ANDROID_PRODUCT_OUT ]]; then
  echo ANDROID_PRODUCT_OUT undefined.
  exit 1
fi

if [[ ! -d $ANDROID_PRODUCT_OUT ]]; then
  echo ANDROID_PRODUCT_OUT is not a directory: $ANDROID_PRODUCT_OUT
  exit 1
fi

if [[ ! -d $ANDROID_PRODUCT_OUT/system ]]; then
  echo $ANDROID_PRODUCT_OUT/system not a directory
  exit 1
fi

(
  set -x
  rm -rf system/
  adb devices
  adb wait-for-device
  adb root
  adb pull /system system
)

cd system

# Remove all files already in $ANDROID_PRODUCT_OUT/system
for f in $(cd $ANDROID_PRODUCT_OUT/system; find . ! -type d); do
  if [[ -f $f ]]; then
    echo Removing $f
    rm $f
  fi
done

# Don't need any of these things:
rm -rf app/ data-app/ ext/{jeejen,mmi} fonts/ framework/ priv-app/ media/ vendor/app/
rm -rf vendor/{ChinaMobile,ChinaTelecom,ChinaUnicom,CmccPower,CTA,MPCS}
rm -rf bin/ATFWD-daemon
rm -rf bin/qfp-daemon
rm -rf vendor/bin/fidodaemon
rm -rf vendor/bin/mm-pp-daemon

find . -name \*.apk | xargs rm -f
find . -name \*.jar | xargs rm -f
find . -name \*.odex | xargs rm -f

