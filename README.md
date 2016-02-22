# WORK IN PROGRESS

# Oak-Arduino-Makefile
Makefile to build arduino code for Oak board under linux (tested on debian X64).

## Changelog
TODO : upload and extensive tests

## Installation
- Clone this repository : `git clone --recursive https://github.com/thunderace/Oak-Arduino-Makefile.git`
- Install third party tools : for 64 bits linux `cd Oak-Arduino-Makefile && sh ./install-x86_64-pc-linux-gnu.sh` 
                              for 32 bits linux : `cd Oak-Arduino-Makefile && sh ./install-i686-pc-linux-gnu.sh` 
- In your sketch directory place a Makefile that defines anything that is project specific and put this line at the end `include /path_to_Oak-Arduino-Makefile_directory/oakArduino.mk` (see example)
- `make upload` should build your sketch and upload it...

##tests
- `cd Oak-Arduino-Makefile/example/start && make upload`

##dependencies
- this project install the lastest stable  oak_core and the last esptool2 and xtensa-lx106 toolchain
- you need nodejs installed
- 
##before upload
You have to run this once : node bin/OakCLI/oak.js in order to configure youe particle access




