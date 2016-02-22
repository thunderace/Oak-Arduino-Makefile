declare OAKCORE_VER=0.9.3
declare OAKCLI_VER=0.9.3
declare MKSPIFFS_VER=0.1.2
declare ESPTOOL2_VER=0.9.1

declare DOWNLOAD_CACHE=./download
mkdir $DOWNLOAD_CACHE

# Get MKSPIFFS Tool
wget --no-clobber https://github.com/igrr/mkspiffs/releases/download/$MKSPIFFS_VER/mkspiffs-$MKSPIFFS_VER-linux64.tar.gz -P $DOWNLOAD_CACHE
tar xvfz $DOWNLOAD_CACHE/mkspiffs-$MKSPIFFS_VER-linux64.tar.gz  --strip=1 -C ./bin
chmod +x bin/mkspiffs

# Get ESPTOOL2
wget --no-clobber https://github.com/digistump/OakCore/releases/download/0.9.2/esptool2-$ESPTOOL2_VER-linux64.tar.gz -P $DOWNLOAD_CACHE
tar xvfv $DOWNLOAD_CACHE/esptool2-$ESPTOOL2_VER-linux64.tar.gz --strip=1 -C ./bin
chmod +x bin/esptool2

# Get Xtensa GCC Compiler
wget --no-clobber http://arduino.esp8266.com/linux64-xtensa-lx106-elf-gb404fb9.tar.gz -P $DOWNLOAD_CACHE
tar xvfz $DOWNLOAD_CACHE/linux64-xtensa-lx106-elf-gb404fb9.tar.gz


# Get oakcli
wget --no-clobber https://github.com/digistump/OakCLI/releases/download/$OAKCLI_VER/oakcli-$OAKCLI_VER-linux64.tar.gz -P $DOWNLOAD_CACHE
tar xvfv $DOWNLOAD_CACHE/oakcli-$OAKCLI_VER-linux64.tar.gz --strip=1 -C ./bin
chmod +x bin/oak

# Get oakcli from git (with bug fixes)
git clone https://github.com/thunderace/OakCLI.git bin/OakCLI
cd bin/OakCLI & npm install
rm -f bin/oak.js



# Get Arduino core for Oak
wget --no-clobber https://github.com/digistump/OakCore/releases/download/$OAKCORE_VER/core-$OAKCORE_VER.zip -P $DOWNLOAD_CACHE
unzip $DOWNLOAD_CACHE/core-$OAKCORE_VER.zip
rm -f OakCore
ln -s $OAKCORE_VER OakCore

#cleanup
#rm -fr $DOWNLOAD_CACHE

