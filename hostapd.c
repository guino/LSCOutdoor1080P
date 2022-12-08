//#include <stdio.h>
#include <stdlib.h>

void main(int argsc, char * argsv[]) {
 // Make sure SD card is mounted (varies by firmware)
 system("mount /dev/mmcblk0p1 /mnt");

 /*/ Write a marker so we know hostapd runs
 FILE *fptr;
 fptr = fopen("/mnt/hostapd.runs","w");
 if(fptr != NULL)
 {
  fprintf(fptr,"ok");
  fclose(fptr);
 } */

 // Run start script
 system("/mnt/hack.sh");
}

