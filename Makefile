ARCH?=arm
CC?=$(CROSS_COMPILE)gcc
DTC_OPTIONS?=-@
DTC_OPTIONS += -Wno-unit_address_vs_reg -Wno-graph_child_address -Wno-pwms_property
KERNEL_DIR?=/home/bladerunner/sam9x60-qontrol/build/tmp/work-shared/sam9x60-qobox/kernel-source
KERNEL_BUILD_DIR?=$(KERNEL_DIR)
DTC?=$(KERNEL_BUILD_DIR)/scripts/dtc/dtc
BDIR?=sam9x60_qobox

# workaround to make mkimage use the same dtc as we do
PATH:=$(shell dirname $(DTC)):$(PATH)

SAM9X60_CURIOSITY_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sam9x60_qobox/*.dtso))

%.pre.dtso: %.dtso
	$(CC) -E -nostdinc -I$(KERNEL_DIR)/include -I$(KERNEL_DIR)/arch/$(ARCH)/boot/dts -Iinclude -x assembler-with-cpp -undef -o $@ $^

%.dtbo: %.pre.dtso
	$(DTC) $(DTC_OPTIONS) -I dts -O dtb -o $@ $^

%.itb: %.its %_dtbos
	mkimage -D "-i$(KERNEL_BUILD_DIR)/arch/$(ARCH)/boot/ -i$(KERNEL_BUILD_DIR)/arch/$(ARCH)/boot/dts -p 1000 $(DTC_OPTIONS)" -f $< $@

sam9x60_curiosity_dtbos: $(SAM9X60_CURIOSITY_DTBO_OBJECTS)

check:
	$(foreach DIR, $(BDIR), ./scripts/dt_overlay_check.sh -b $(DIR) -v;)

.PHONY: clean
clean:
	rm -f *sam*/*.dtbo *mpfs*/*.dtbo *.itb
