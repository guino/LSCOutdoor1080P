#!/bin/sh
echo -en "Content-Type: text/plain\r\n\r\n"
/tmp/sd/busybox ls -a -Xp ..${REQUEST_URI#${SCRIPT_NAME}}
