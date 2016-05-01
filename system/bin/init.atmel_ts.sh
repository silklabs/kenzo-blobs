#!/system/bin/sh

sleep 2

#insmod /data/temp/mxt.ko

cd /sys/bus/i2c/devices/4-004a
sleep 2

#chown root root *
chmod 666 t19
chmod 666 update_cfg
chmod 666 update_fw

#format: [family id]_[variant id]_[version]_[build].fw
#format: [family id]_[variant id]_[version]_[build].raw

#update firmware
echo "A4_15_2.2_AA.fw" > update_fw

#update new config
echo "A4_15_2.2_AA.raw" > update_cfg

#enable plugin
#
#format: pl enable [hex]
#[0] : CAL
#[1] : MSC
#[2] : PI
#[3] : CLIP
#[4] : WDG
#[7] : PLUG PAUSE
echo "wd enable 3" > plugin
echo "pl enable 12" > plugin

#PTC auto tune (should enable MSC above,sleep 5s for tune complete)
#[0] : tune not store
#[1] : tune and store
#[2] : re-tune and not store
#[3] : re-tune and store
#[other value] : report tune status 
#echo "msc ptc tune 1" > plugin

chmod 440 t19
chmod 440 update_cfg
chmod 440 update_fw

