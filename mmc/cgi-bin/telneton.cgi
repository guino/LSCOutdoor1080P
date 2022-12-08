#!/bin/sh
echo -e "Content-type: text/plain\r"
echo -e "\r"
echo -e "Telnet has been enabled\r"
telnetd -p 24 -l /bin/sh
