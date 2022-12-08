#!/bin/sh

# Mark that this runs
if [ ! -e /tmp/custom ]; then
 touch /tmp/custom
 telnetd -p 24 -l /bin/sh
 /tmp/sd/busybox httpd -c /tmp/sd/httpd.conf -h /tmp/sd -p 8080
fi
