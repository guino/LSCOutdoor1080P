#!/bin/sh

# Mount SD on location that won't be umounted by device
mkdir -p /tmp/sd
mount /dev/mmcblk0p1 /tmp/sd

# Mark that this runs
if [ ! -e /tmp/sd/hack ]; then
 touch /tmp/sd/hack
fi

# If we don't have a copy of the application yet
if [ ! -e /tmp/sd/anyka_ipc ]; then
 cp /usr/bin/anyka_ipc /tmp/sd
fi

# Remove AP mode file
rm -f /tmp/_ht_ap_mode.conf

# Reset wifi to client mode (same as it wifi_driver would have done)
killall udhcpd
ifconfig wlan0 0.0.0.0
touch /tmp/wifi_is_8188

# If we have a patched application, use it
if [ -e /tmp/sd/anyka_ipc_rtsp ]; then
 echo "export LD_LIBRARY_PATH=/lib:/usr/lib:/tmp/sd" > /tmp/anyka_ipc_rtsp
 echo "echo 'tilt_total_steps = 2200' >> /tmp/_ht_hw_settings.ini" >> /tmp/anyka_ipc_rtsp
 echo "/tmp/sd/anyka_ipc_rtsp 2>&1 | /tmp/sd/log_parser.sh /dev/null" >> /tmp/anyka_ipc_rtsp
 chmod +x /tmp/anyka_ipc_rtsp
 cp /usr/local/_ht_hw_settings.ini /tmp/
 mount --bind /tmp/_ht_hw_settings.ini /etc/config/_ht_hw_settings.ini
 mount --bind /tmp/anyka_ipc_rtsp /usr/bin/anyka_ipc
fi

# Run custom.sh on SD card every 10 seconds (like we do on other devices)
(while true; do /tmp/sd/custom.sh; sleep 10; done ) < /dev/null >& /dev/null &
