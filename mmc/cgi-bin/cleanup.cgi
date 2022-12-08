#!/bin/sh
echo -e "Content-type: text/plain\r"
echo -e "\r"
SERIAL=123456789
DAYS=90
YEAR=$(date +%Y)
/tmp/sd/busybox find /tmp/sd/DCIM/ -type d -mtime +$DAYS -exec echo rm -rf {} \; -exec rm -rf {} \;
YEAR=$((YEAR-1))
if [ -e /tmp/sd/DCIM/ ]; then
 /tmp/sd/busybox find /tmp/sd/DCIM/ -type d -mtime +$DAYS -exec echo rm -rf {} \; -exec rm -rf {} \;
fi
