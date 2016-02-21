# Esp8266-Arduino-Makefile
Makefile to build arduino code for ESP8266 under linux (tested on debian X64).
Based on Martin Oldfield arduino makefile : http://www.mjoldfield.com/atelier/2009/02/arduino-cli.html

## Changelog
02/18/2016 :
- new x86 and x64 linux install
- cleanup
-

08/12/2015 :
- add install script for 32 bit linux
- update to esp8266-2.0.0-rc2

04/11/2015 :
- use zip file from official link (http://arduino.esp8266.com/staging/package_esp8266com_index.json)
- ESP8266 git submodule removed
- remove $(ARDUINO_CORE)/variants/$(VARIANT) to include path (not needed)

08/10/2015 : 
- add $(ARDUINO_CORE)/variants/$(VARIANT) to include path for nodemcuv2

29/09/2015 : 
- fix README for third party tools installation
- move post-installation out of the makefile

23/09/2015 : 
- working dependencies
- multiple ino files allowed
- core & spiffs objects build in their own directories
- autodetect system and user libs used by the sketch
- Makefile renamed to esp8266Arduino.mk

## Installation
- Clone this repository : `git clone --recursive https://github.com/thunderace/Esp8266-Arduino-Makefile.git`
- Install third party tools : for 64 bits linux `cd Esp8266-Arduino-Makefile && chmod+x install-x86_64-pc-linux-gnu.sh && ./install-x86_64-pc-linux-gnu.sh && cd ..` 
                              for 32 bits linux : `cd Esp8266-Arduino-Makefile && chmod+x install-i686-pc-linux-gnu.sh && ./install-i686-pc-linux-gnu.sh && cd ..` 
- In your sketch directory place a Makefile that defines anything that is project specific and put this line at the end `include /path_to_Esp8266-Arduino-Makefile_directory/esp8266Arduino.mk` (see example)
- `make upload` should build your sketch and upload it...

#dependencies
- this project install the lastest stable  esp8266/Arduino repository (2.0.0) and the last stagging esptool and xtensa-lx106 toolchain

## TODO
- build user libs in their own directory to avoid problems with multiple files with same name.


