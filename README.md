## Root and customization for LSC Outdoor 1080P and LSC Rotating 1080P cameras

### TL;DR

You can jump to the **Conclusion** section all the way at the bottom if you just want to the steps to root the camera (and don't care about the details on how we got to them).

#### Summary

I created this repo to catalog information related to the LSC 1080P outdoor and rotating cameras since it cannot be rooted with information from my previous projects as it has different bootloader and rootfs. The firmware version currently available is 2.10.36 at the time of writing this, however that update may only be available if your tuya account is on european servers -- my devices originally came with 2.10.22 (Outdoor) and 2.10.28 (Rotating) and it did not give me any options to update the firmware on the north america servers.

#### Hardware

This is what the devices looks like (Other brand devices may look similar with the same hardware/software in them):

![Outdoor](https://user-images.githubusercontent.com/8442196/192149609-a1c3d70a-bea6-484f-955d-09eca376161f.png)
![Rotating](https://camo.githubusercontent.com/a26262eba0bc5b682dad1c2be2cf5f191dc3e96e2a138e6928e0530bb5bac07d/68747470733a2f2f7777772e616374696f6e2e636f6d2f5f6e6578742f696d6167652f3f75726c3d6874747073253341253246253246616374696f6e2e636f6d253246686f73746564617373657473253246434d5341727469636c65496d6167657325324637342532463237253246333030373332355f383731323837393135313231302d3131315f30335f32303232303832333132343933392e706e6726773d36343026713d3735)

#### Initial work and Credits

I have to give credit to [EpicLPer](https://github.com/EpicLPer) for obtaining the firmware dump from the device and helping with a lot of testing (https://github.com/guino/Merkury1080P/issues/42). Most of my findings were done with that firmware dump.

#### Root access

After review of the main scripts on the device we found that we can enable telnet by creating a blank file called `_ht_av_tuning.conf` and a file called `shadow` in the SD card with the credentials to be used for telnet (see original post [here](https://github.com/guino/Merkury1080P/issues/42#issuecomment-1317802613)):
```
root:$1$M2qq8yA.$oasb2xrzUG0EVpDuaCBNW1:18943:0:99999:7:::
```
Then just boot the device with the SD card inserted and port 23 (telnet) should be open. 
The root login with the above shadow file is `root` with password: `telnet`

**WARNING:** I discourage you from leaving these files in the SD card as it will cause part of the flash to be written everytime the device boots which could cause problems long term -- these files should really be for anyone wishing to access the camera temporarily.

#### Customization

I later found that the startup script runs a `hostapd` file from the SD card if a `_ht_ap_mode.conf` exists, but the device would not connect to the wifi with that alone. It took compiling a native executable `hostapd` file to get it to run anything on the device and along with some scripting to 'restore' the client mode wifi on the device so it would work normally after our custom code executes.

Basically the flow is: hostapd -> hack.sh -> custom.sh and modified/patched main application (in parallel).

The customizations done to this device are:
* Added RTSP with audio (which took at lot of work)
* Added motion notification support (MQTT/etc)
* Added download feature (download video files remotely)
* Added upload feature (upload files to SD card remotely)
* Added customized clean up of files in SD card

There's no 'fixed buffer' for JPEG images on this device, so there's no easy way to make mjped/snap functions as we have on other devices. If you're looking for that, you can check [this repository](https://github.com/guino/rtsp2jpeg) to obtain similar features from the RTSP stream.

There's also no function (like in older devices) to play an audio file on demand, so play.cgi is also unavailable. It may be possible (again with a lot of work) to inject some code into an unused aread of the memory so that it monitors and calls the audio playback function on the device. If you're interested in seeing that, please let me know as I don't plan to work on this unless there's enough demand to justify the work.

#### Review

This is a quick review of pros and cons of these devices:

##### Pros
* Inexpensive (The rotating camera was $25)
* Rootable and customizeble with RTSP and mqtt

##### Cons
* Recordings are in non-standard .media file format (can be viewed without audio on mplayer and VLC after forcing H264 demuxer)
* We may be running 2.10.36 for a long time because I don't plan to do all the patch work on another version (I did not see any problems running 2.10.36 on other firmware versions)
* No current method for 'snapshot' (snap.cgi/mjpeg.cgi) -- look at rtsp2jpeg repo for an alternative
* No current method for on demand audio playback (play.cgi)

#### Conclusion 

If you want any of the features listed in the 'Customization' (RTSP, Motion notfication, download/upload, cleanup) that can be done in one of 2 ways:

##### Option 1 -- This option **REQUIRES** your device to be on version 2.10.36

This option is simple:
1. Download the repository files (from the Code->Download ZIP button above) or clone it with git.
2. Extract the zip on a computer and copy the contents of the `mmc` directory into the SD card (it should have been FAT32 formatted).
3. SEPARATELY download busybox from this link to the SD card: https://github.com/guino/LSC1080P/blob/main/mmc/busybox?raw=true
4. On the SD card, adjust http.conf, log_parser.sh (if using motion detection), and adjust cleanup.cgi to your needs.
5. Insert the SD card on the device while powered off, let it boot up normally.
6. Wait until you can see the device online on the phone app, then power off device, take the SD card out and insert it on your computer.
7. Go to https://www.marcrobledo.com/RomPatcher.js/ DO NOT CLICK ON CREATOR MODE
8. Click ‘choose file’ in front of ‘ROM file’ and select the original anyka_ipc file in the root of the SD card.
9. VERIFY that the md5 value displayed matches this: `5ac1f462bf039ec3c6c0a31d27ae652a` (if it doesn't: stop!)
10. Click ‘choose file’ in front of ‘Patch file’ and select the anyca_ipc_rtsp.zip you got from on steps 1-2
11. Click ‘apply patch’ and save/download the file to the computer (the default file name will likely be anyka_ipc)
12. Rename the file saved/downloaded on on step 11 to `anyka_ipc_rtsp` (make sure it has no .txt or any extension) and place it on the root of the SD card
13. Verify the size of anyka_ipc_rtsp is exactly the same as the size of the anyka_ipc downloaded on the SD card (which should be a few megabytes)
14. Properly eject/unmount the SD card from computer (i.e. windows using the tray icons, linux umount command, etc)
15. Insert SD card to device and power it on
16. Wait for it to boot - it may take a little longer than usual due to the wifi setup stuff. Wait for it to show online in the phone app (which should work normally) then you should be able to view the RTSP feed on `rtsp://ip/main_ch`.

##### Option 2 -- If you're not on 2.10.36

If you're on an older version and can update to 2.10.36, that would be the quickest way to get everything working. If for some reason you can't or don't want to update to 2.10.36 you can follow the steps below to extract the required files.

Before you start you will need binwalk for this to work -- it is available for download in most linux distributions and there's an article on how to run it in windows [here](https://blog.eldernode.com/install-and-use-binwalk-on-windows/).

1. Follow steps 1 thru 6 from Option 1 above.
2. Download the 2.10.36 update file from tuya servers on this [link](https://fireware.tuyaeu.com:1443/smart/firmware/upgrade/ay1541668973821t35pE/165966791961ed11009a7.bin).
3. Run `binwalk -e -M 165966791961ed11009a7.bin`) to extract the update contents
4. Locate the anyka_ipc file under `_165966791961ed11009a7.bin.extracted/_usr.sqsh4.extracted/squashfs-root/bin/anyka_ipc` -- copy it to the root of the SD card (overwriting the anyka_ipc file already there).
5. Locate the libavssdkbeta.so file under `_165966791961ed11009a7.bin.extracted/_usr.sqsh4.extracted/squashfs-root/lib/libavssdkbeta.so` -- copy it to the root of the SD card.
6. Follow steps 7 thru 16 from Option 1 above.

NOTE: I don't believe I'm allowed to host files from the manufacturer without their perimission so that is why you have to download and extract them yourself. Feel free to drop me a line if you need some help with the process.

#### Telnet notes

Telnet is on by default on port 24 (`telnet IP 24`) using the process above -- there will NOT be a password. If you wish to disable telnet you can comment out (or remove) the line `telnetd -p 24 -l /bin/sh` in custom.sh. The reason why we're using a passwordless telnet is to prevent writing to the flash memory on every boot. I have also provided two scripts that allow you to turn tenlet on/off regardless of what you use by default (user/password is what's configured in httpd.conf):
```
http://user:password@ip:8080/cgi-bin/telneton.cgi
http://user:password@ip:8080/cgi-bin/telneton.cgi
```

#### PTZ Notes (rotatable camera)
For the rotatable camera I made a basic PTZ control page you can access under:
```
http://user:password@ip:8080/ptz.html
```
You can send direct commands from other applications to control the motors with this URL:
```
http://user:password@ip:8080/cgi-bin/motor.cgi?dir=X&dist=N
```
The `dir` parameter defines direction of the motion and should be either `up`, `down`, `left` or `right`
The `dist` parameter defines how much to move, should be a value between 1 and probably 50 (I recommend 10).
I put together rather quickly and did not do a lot of testing so try it out and feel free to review the source (motor.c)

#### Final note

If you'd like more details about the whole process or have any issues, open an issue in github and we can discuss it further!

If you'd like to buy me a beer/coffee in appreciation of the effort/time I put in to make the above possible, feel free to:
http://paypal.me/wbbo

cash app: $wbbo

Enjoy!
