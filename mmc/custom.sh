#!/bin/sh

# Mark that this runs
if [ ! -e /tmp/custom ]; then
 touch /tmp/custom
 telnetd -p 24 -l /bin/sh
 /tmp/sd/busybox httpd -c /tmp/sd/httpd.conf -h /tmp/sd -p 8080
fi
if [ ! -e /tmp/cleanup`date +%Y%m%d` ]; then
 rm -rf /tmp/cleanup*
 touch /tmp/cleanup`date +%Y%m%d`
 /tmp/sd/cgi-bin/cleanup.cgi > /tmp/cleanup.log
fi


## if offline.sh is not running, run it
#[[ ! `pgrep -f offline.sh` ]] && /tmp/sd/offline.sh &

