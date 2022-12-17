#!/bin/sh
echo -e "Content-type: text/plain\r"
echo -e "\r"
echo ${REQUEST_URI}
TMP=${REQUEST_URI#*dist=};
DIST=${TMP%&*}
TMP=${REQUEST_URI#*dir=};
DIR=${TMP%&*}
PID=$(pgrep anyka_ipc)
echo DIST=$DIST DIR=$DIR PID=$PID

if [ "$DIR" == "up" ] || [ "$DIR" == "down" ]; then
 ADDR=431684
else
 ADDR=431614
fi

if [ "$DIR" == "down" ] || [ "$DIR" == "left" ]; then
 VAL=ffa60000
else
 VAL=5b0000
fi

if [ "$PID" != "" ] && [ "$DIR" != "" ]; then
 /tmp/sd/motor $PID $ADDR 40046d40 $VAL $DIST 2>/dev/null
fi
