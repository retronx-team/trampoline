STATIC_LINKING := 0
AR             := ar

ifneq ($(V),1)
   Q := @
endif

ifneq ($(SANITIZER),)
   CFLAGS   := -fsanitize=$(SANITIZER) $(CFLAGS)
   CXXFLAGS := -fsanitize=$(SANITIZER) $(CXXFLAGS)
   LDFLAGS  := -fsanitize=$(SANITIZER) $(LDFLAGS)
endif

platform = libnx

CORE_DIR    += .
TARGET_NAME := trampoline
LIBM		    = -lm

include $(DEVKITPRO)/libnx/switch_rules
TARGET := $(TARGET_NAME)_libretro_$(platform).a
DEFINES := -DSWITCH=1 -D__SWITCH__ -DARM
CFLAGS := $(DEFINES) -fPIE -I$(LIBNX)/include/ -ffunction-sections -fdata-sections -ftls-model=local-exec -specs=$(LIBNX)/switch.specs
CFLAGS += -march=armv8-a -mtune=cortex-a57 -mtp=soft -mcpu=cortex-a57+crc+fp+simd -ffast-math
CXXFLAGS := $(ASFLAGS) $(CFLAGS)
STATIC_LINKING = 1
EXT := a

LDFLAGS += $(LIBM)

ifeq ($(DEBUG), 1)
   CFLAGS += -O0 -g -DDEBUG
   CXXFLAGS += -O0 -g -DDEBUG
else
   CFLAGS += -O3
   CXXFLAGS += -O3
endif

include Makefile.common

OBJECTS := libretro.o

CFLAGS   += -Wall -D__LIBRETRO__ $(fpic)
CXXFLAGS += -Wall -D__LIBRETRO__ $(fpic)

all: $(TARGET)

$(TARGET): $(OBJECTS)
ifeq ($(STATIC_LINKING), 1)
	$(AR) rcs $@ $(OBJECTS)
else
	@$(if $(Q), $(shell echo echo LD $@),)
	$(Q)$(CXX) $(fpic) $(SHARED) $(INCLUDES) -o $@ $(OBJECTS) $(LDFLAGS)
endif

%.o: %.c
	@$(if $(Q), $(shell echo echo CC $<),)
	$(Q)$(CXX) $(CFLAGS) $(fpic) -c -o $@ $<

clean:
	rm -f $(OBJECTS) $(TARGET)

.PHONY: clean

print-%:
	@echo '$*=$($*)'
