TARGET = $(notdir $(realpath .))
ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

SERIAL_PORT ?= /dev/tty.oak

ARDUINO_HOME ?=  $(ROOT_DIR)/OakCore
ARDUINO_ARCH = oak
ARDUINO_BOARD ?= ESP8266_OAK
ARDUINO_VARIANT ?= oak
ARDUINO_VERSION ?= 10605
#ESPTOOL_VERBOSE ?= -vv

BOARDS_TXT  = $(ARDUINO_HOME)/boards.txt
PARSE_BOARD = $(ROOT_DIR)/bin/ard-parse-boards
PARSE_BOARD_OPTS = --boards_txt=$(BOARDS_TXT)
PARSE_BOARD_CMD = $(PARSE_BOARD) $(PARSE_BOARD_OPTS)

VARIANT = $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) build.variant)
MCU   = $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) build.mcu)
SERIAL_BAUD   = $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) upload.speed)
F_CPU = $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) build.f_cpu)
FLASH_SIZE ?= $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) build.flash_size)
FLASH_MODE ?= $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) build.flash_mode)
FLASH_FREQ ?= $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) build.flash_freq)
UPLOAD_RESETMETHOD = $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) upload.resetmethod)
UPLOAD_SPEED = $(shell $(PARSE_BOARD_CMD) $(ARDUINO_VARIANT) upload.speed)

# sketch-specific
USER_LIBDIR ?= ./libraries

XTENSA_TOOLCHAIN ?= $(ROOT_DIR)/xtensa-lx106-elf/bin/
ESPRESSIF_SDK = $(ARDUINO_HOME)/tools/sdk
ESPTOOL ?= $(ROOT_DIR)/bin/esptool2
ESPOTA ?= $(ARDUINO_HOME)/tools/espota.py

BUILD_OUT = ./build.$(ARDUINO_VARIANT)

CORE_SSRC = $(wildcard $(ARDUINO_HOME)/cores/$(ARDUINO_ARCH)/*.S)
CORE_SRC = $(wildcard $(ARDUINO_HOME)/cores/$(ARDUINO_ARCH)/*.c)
CORE_CXXSRC = $(wildcard $(ARDUINO_HOME)/cores/$(ARDUINO_ARCH)/*.cpp)
# there are c files in subdirectories
CORE_SRC += $(wildcard $(ARDUINO_HOME)/cores/$(ARDUINO_ARCH)/*/*.c)
# there are cpp files in subdirectories
CORE_CXXSRC += $(wildcard $(ARDUINO_HOME)/cores/$(ARDUINO_ARCH)/*/*.cpp)
# for ESP8266Wifi
CORE_CXXSRC += $(wildcard $(ARDUINO_HOME)/cores/$(ARDUINO_ARCH)/*/src/*.cpp)
CORE_CXXSRC += $(wildcard $(ARDUINO_HOME)/variants/$(ARDUINO_ARCH)/*.cpp)


CORE_OBJS = $(addprefix $(BUILD_OUT)/core/, \
	$(notdir $(CORE_SSRC:.S=.S.o) $(CORE_SRC:.c=.c.o) $(CORE_CXXSRC:.cpp=.cpp.o)))

#autodetect arduino libs and user libs
LOCAL_SRCS = $(USER_SRC) $(USER_CXXSRC) $(LIB_INOSRC) $(USER_HSRC) $(USER_HPPSRC)
ifndef ARDUINO_LIBS
    # automatically determine included libraries
    ARDUINO_LIBS = $(sort $(filter $(notdir $(wildcard $(ARDUINO_HOME)/libraries/*)), \
        $(shell sed -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS))))
endif

ifndef USER_LIBS
    # automatically determine included user libraries
    USER_LIBS = $(sort $(filter $(notdir $(wildcard $(USER_LIBDIR)/*)), \
        $(shell sed -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS))))
endif


# arduino libraries
ALIBDIRS = $(sort $(dir $(wildcard \
	$(ARDUINO_LIBS:%=$(ARDUINO_HOME)/libraries/%/*.c) \
	$(ARDUINO_LIBS:%=$(ARDUINO_HOME)/libraries/%/*.cpp) \
	$(ARDUINO_LIBS:%=$(ARDUINO_HOME)/libraries/%/src/*.c) \
	$(ARDUINO_LIBS:%=$(ARDUINO_HOME)/libraries/%/src/*.cpp))))

# user libraries and sketch code
ULIBDIRS = $(sort $(dir $(wildcard \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/*.c) \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/src/*.c) \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/src/*/*.c) \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/*.cpp) \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/src/*/*.cpp) \
	$(USER_LIBS:%=$(USER_LIBDIR)/%/src/*.cpp))))

USRCDIRS = .
# all sources
LIB_SRC = $(wildcard $(addsuffix /*.c,$(ULIBDIRS))) \
	$(wildcard $(addsuffix /*.c,$(ALIBDIRS)))
LIB_CXXSRC = $(wildcard $(addsuffix /*.cpp,$(ULIBDIRS))) \
	$(wildcard $(addsuffix /*.cpp,$(ALIBDIRS)))

USER_SRC = $(wildcard $(addsuffix /*.c,$(USRCDIRS)))
USER_CXXSRC = $(wildcard $(addsuffix /*.cpp,$(USRCDIRS))) \

USER_HSRC = $(wildcard $(addsuffix /*.h,$(USRCDIRS)))
USER_HPPSRC = $(wildcard $(addsuffix /*.hpp,$(USRCDIRS)))


LIB_INOSRC = $(wildcard $(addsuffix /*.ino,$(USRCDIRS)))

# object files
OBJ_FILES = $(addprefix $(BUILD_OUT)/,$(notdir $(LIB_SRC:.c=.c.o) $(LIB_CXXSRC:.cpp=.cpp.o) $(LIB_INOSRC:.ino=.ino.o) $(USER_SRC:.c=.c.o) $(USER_CXXSRC:.cpp=.cpp.o)))

DEFINES = $(USER_DEFINE) -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ \
	-DF_CPU=$(F_CPU) -DARDUINO=$(ARDUINO_VERSION) \
	-DARDUINO_$(ARDUINO_BOARD) -DESP8266 \
	-DARDUINO_ARCH_$(shell echo "$(ARDUINO_ARCH)" | tr '[:lower:]' '[:upper:]') \
	-I$(ESPRESSIF_SDK)/include

CORE_INC = $(ARDUINO_HOME)/cores/$(ARDUINO_ARCH) \
	$(ARDUINO_HOME)/variants/$(VARIANT)
CORE_INC += $(ARDUINO_HOME)/cores/$(ARDUINO_ARCH)/spiffs
CORE_INC += $(ARDUINO_HOME)/cores/$(ARDUINO_ARCH)/OakParticle
CORE_INC += $(ARDUINO_HOME)/cores/$(ARDUINO_ARCH)/ESP8266WiFi/src
#CORE_INC += $(ARDUINO_HOME)/cores/$(ARDUINO_ARCH)/ESP8266WiFi/src/include

INCLUDES = $(CORE_INC:%=-I%) $(ALIBDIRS:%=-I%) $(ULIBDIRS:%=-I%)
VPATH = . $(CORE_INC) $(ALIBDIRS) $(ULIBDIRS)

ASFLAGS = -c -g -x assembler-with-cpp -MMD $(DEFINES)

CFLAGS = -c -Os -Wpointer-arith -Wno-implicit-function-declaration -Wl,-EL \
	-fno-inline-functions -nostdlib -mlongcalls -mtext-section-literals \
	-falign-functions=4 -MMD -std=gnu99 -ffunction-sections -fdata-sections

CXXFLAGS = -c -Os -mlongcalls -mtext-section-literals -fno-exceptions \
	-fno-rtti -falign-functions=4 -std=c++11 -MMD

LDFLAGS = -nostdlib -Wl,--gc-sections -Wl,--no-check-sections -u call_user_start -Wl,-static -Wl,-wrap,system_restart_local -Wl,-wrap,register_chipv6_phy

CC := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-gcc
CXX := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-g++
AR := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-ar
LD := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-gcc
OBJDUMP := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-objdump
SIZE := $(XTENSA_TOOLCHAIN)xtensa-lx106-elf-size
CAT	= cat

.PHONY: all arduino dirs clean upload

all: show_variables dirs core libs bin size

show_variables:
	$(info [ARDUINO_LIBS] : $(ARDUINO_LIBS))
	$(info [USER_LIBS] : $(USER_LIBS))

dirs:
	@mkdir -p $(BUILD_OUT)
	@mkdir -p $(BUILD_OUT)/core

clean:
	rm -rf $(BUILD_OUT)

core: dirs $(BUILD_OUT)/core/core.a

libs: dirs $(OBJ_FILES)

bin: $(BUILD_OUT)/$(TARGET).bin

$(BUILD_OUT)/core/%.o: $(ARDUINO_HOME)/cores/$(ARDUINO_ARCH)/%.c
	$(CC) $(DEFINES) $(CORE_INC:%=-I%) $(CFLAGS) -o $@ $<

$(BUILD_OUT)/spiffs/%.o: $(ARDUINO_HOME)/cores/$(ARDUINO_ARCH)/spiffs/%.c
	$(CC) $(DEFINES) $(CORE_INC:%=-I%) $(CFLAGS) -o $@ $<

$(BUILD_OUT)/core/%.o: $(ARDUINO_HOME)/cores/$(ARDUINO_ARCH)/%.cpp
	$(CXX) $(DEFINES) $(CORE_INC:%=-I%) $(CXXFLAGS) -o $@ $<

$(BUILD_OUT)/core/%.S.o: $(ARDUINO_HOME)/cores/$(ARDUINO_ARCH)/%.S
	$(CC) $(ASFLAGS) -o $@ $<

$(BUILD_OUT)/core/core.a: $(CORE_OBJS)
	$(AR) cru $@ $(CORE_OBJS)

$(BUILD_OUT)/core/%.c.o: %.c
	$(CC) $(DEFINES) $(CFLAGS) $(INCLUDES) -o $@ $<

$(BUILD_OUT)/core/%.cpp.o: %.cpp
	$(CXX) $(DEFINES) $(CXXFLAGS) $(INCLUDES) $< -o $@

$(BUILD_OUT)/%.c.o: %.c
	$(CC) $(DEFINES) $(CFLAGS) $(INCLUDES) -o $@ $<

$(BUILD_OUT)/%.ino.o: %.ino
	$(CXX) -x c++ $(DEFINES) $(CXXFLAGS) $(INCLUDES) $< -o $@

$(BUILD_OUT)/%.cpp.o: %.cpp
	$(CXX) $(DEFINES) $(CXXFLAGS) $(INCLUDES) $< -o $@

# ultimately, use our own ld scripts ...
$(BUILD_OUT)/$(TARGET).elf: core libs
	$(LD) $(LDFLAGS) -L$(ESPRESSIF_SDK)/lib \
		-L$(ESPRESSIF_SDK)/ld -T$(ESPRESSIF_SDK)/ld/eagle.flash.4m.ld \
		-o $@ -Wl,--start-group $(OBJ_FILES) $(BUILD_OUT)/core/core.a \
		-lm -lgcc -lhal -lphy -lnet80211 -llwip -lwpa -lmain -lpp -lsmartconfig \
		-lwps -lcrypto \
		-Wl,--end-group -L$(BUILD_OUT)

size : $(BUILD_OUT)/$(TARGET).elf
		$(SIZE) -A $(BUILD_OUT)/$(TARGET).elf | grep -E '^(?:\.text|\.data|\.rodata|\.irom0\.text|)\s+([0-9]+).*'

#-quiet -bin -boot2 -4096 -iromchksum "{build.path}/{build.project_name}.elf" "{build.path}/{build.project_name}.bin" .text .data .rodata
#	$(ESPTOOL) -eo $(ARDUINO_HOME)/bootloaders/eboot/eboot.elf -bo $(BUILD_OUT)/$(TARGET).bin \


$(BUILD_OUT)/$(TARGET).bin: $(BUILD_OUT)/$(TARGET).elf
	$(ESPTOOL) -quiet -bin -boot2 -4096 -iromchksum \
		$(BUILD_OUT)/$(TARGET).elf \
		$(BUILD_OUT)/$(TARGET).bin \
		.text .data .rodata

upload: $(BUILD_OUT)/$(TARGET).bin size
	$(ESPTOOL) $(ESPTOOL_VERBOSE) -cd $(UPLOAD_RESETMETHOD) -cb $(UPLOAD_SPEED) -cp $(SERIAL_PORT) -ca 0x00000 -cf $(BUILD_OUT)/$(TARGET).bin

ota: $(BUILD_OUT)/$(TARGET).bin
	$(ESPOTA) 192.168.1.184 8266 $(BUILD_OUT)/$(TARGET).bin

term:
	minicom -D $(SERIAL_PORT) -b $(UPLOAD_SPEED)

print-%: ; @echo $* = $($*)

-include $(OBJ_FILES:.o=.d)
