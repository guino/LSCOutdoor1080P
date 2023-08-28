#!/bin/sh

echo "${0}: starting $(date)" >> /tmp/offline.log

# If no hosts file, leave
if [ ! -e /tmp/sd/hosts ]; then
 echo "${0}: no hosts file found on card. Not doing anything" >> /tmp/offline.log
 exit 0
fi

# Wait for date to be corrected
while [ `date +%s` -lt 1645543474 ]; do
 date >> /tmp/offline.log
 sleep 1
done

# Block internet access to tuya servers
if [ "$(mount | grep -c /etc/hosts)" -eq "0" ]; then
  mount --bind /tmp/sd/hosts /etc/hosts 2>&1 >> /tmp/offline.log
fi
echo "${0}: blocked hosts" >> /tmp/offline.log
# Wait for connection to be dropped
while [ `netstat -ntu 2>&1 | grep -v 127.0.0.1 | grep -v ":24\|:554\|:6668" | grep -c ESTABLISHED` -gt 0 ]; do
 # For each non-telnet established IP
 #   port 24 : telnet
 #   port 554: rtsp stream
 #   port 6668: app stream
 for ip in `netstat -ntu 2>&1 | grep -v 127.0.0.1 | grep -v ":24\|:554\|:6668" | grep ESTABLISHED | awk '{print $5}' | awk -F: '{print $1}'`; do
  echo "${0}: checking $ip" >> /tmp/offline.log
  if [ "`route -n | grep -c $ip`" == "0" ]; then
   route add -net $ip netmask 255.255.255.255 gw 127.0.0.1  2>&1 >> /tmp/offline.log
   echo "${0}: blocked $ip" >> /tmp/offline.log
  fi
 done
done

echo "${0} done $(date)" >> /tmp/offline.log
