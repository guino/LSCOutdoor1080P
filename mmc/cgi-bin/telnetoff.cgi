#!/bin/sh
echo -e "Content-type: text/plain\r"
echo -e "\r"
echo -e "Telnet has been disabled\r"
killall telnetd
