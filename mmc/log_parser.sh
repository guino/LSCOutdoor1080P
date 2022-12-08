#!/bin/sh

#DEBUG_FILE=/tmp/sd/output.log
DEBUG_FILE=$1


# contains(string, substring)
#
# Returns 0 if the specified string contains the specified substring,
# otherwise returns 1.
contains() {
    string="$1"
    substring="$2"
    if test "${string#*$substring}" != "$string"
    then
        return 0    # $substring is in $string
    else
        return 1    # $substring is not in $string
    fi
}

main() {
    IFS='$\n'
    echo -n "" > $DEBUG_FILE
    while true; do
	read -r BUF;
	if [ $? -ne 0 ]; then
	    sleep 1;
	    continue
	fi
	if contains "$BUF" " start new event"; then
	    #echo "motion detected"
            /tmp/sd/mosquitto_pub -h 127.0.0.1 -m "detected" -t home/doorbell
	elif contains "$BUF" "##doorbell_push 3"; then
	    #echo "doorbell push button"
            /tmp/sd/mosquitto_pub -h 127.0.0.1 -m "pushed" -t home/doorbell
	#else
	    #echo "Unknown cmd: $BUF"
	fi
	echo $BUF >> $DEBUG_FILE
    done
}

main

