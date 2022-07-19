# Default values have been used for the port, programmer and filename. The user is encourages to override these (either through the command line or by changing the values in the Makefile directly)
# Other values such as the CPU frequency, LED pin may be changed as well.
# The default Assembler used is avr-as and you can switch to avrasm/avra by defining the variable "AVRASM".

COMPILE		= avr-gcc
OBJCOPY		= avr-objcopy
LINK		= avr-ld
SIZE		= avr-size

FILENAME	= main

PROGRAMMER	= stk500v1
PORT		= /dev/ttyUSB0
BAUD		= 19200

# ---------- ATmega328P (Arduino UNO) ----------

# DEVICE		= atmega328p
# F_CPU		= 16000000UL
# LED_PIN		= PB5

# ------------------------------

# ---------- ATtiny85 ----------

DEVICE		= attiny85
F_CPU		= 1000000UL
LED_PIN		= PB1

# ------------------------------


default: compile upload clean

compile:
	$(COMPILE) -Os -Wall -mmcu=$(DEVICE) -DF_CPU=$(F_CPU) -DLED_PIN=$(LED_PIN) -c $(FILENAME).c -o build/$(FILENAME).o
	$(COMPILE) -Wall -mmcu=$(DEVICE) build/$(FILENAME).o -o build/$(FILENAME).elf
	$(OBJCOPY) -O ihex build/$(FILENAME).elf build/$(FILENAME).hex
	$(SIZE) --format=avr --mcu=$(DEVICE) build/$(FILENAME).elf

ifdef AVRASM

assemble:
	avra $(FILENAME).S
	rm $(FILENAME).S.cof
	mv $(FILENAME).S.obj build/$(FILENAME).o
	mv $(FILENAME).S.hex build/$(FILENAME).hex
	mv $(FILENAME).S.eep.hex build/$(FILENAME).eep.hex

else

assemble:
	$(COMPILE) -mmcu=$(DEVICE) -D__SFR_OFFSET=0 -DF_CPU=$(F_CPU) -DLED_PIN=$(LED_PIN) -E $(FILENAME).S -o build/$(FILENAME).s
	$(COMPILE) -mmcu=$(DEVICE) -nostdlib -g build/$(FILENAME).s -o build/$(FILENAME).o
	$(LINK) -o build/$(FILENAME).elf build/$(FILENAME).o
	$(OBJCOPY) build/$(FILENAME).elf build/$(FILENAME).hex -O ihex
	$(SIZE) --format=avr --mcu=$(DEVICE) build/$(FILENAME).elf
	rm -f build/$(FILENAME).s

endif

upload: upload-flash

upload-flash:
	avrdude -v -p $(DEVICE) -c $(PROGRAMMER) -P $(PORT) -b $(BAUD) -U flash:w:build/$(FILENAME).hex:i

upload-eeprom:
	avrdude -v -p $(DEVICE) -c $(PROGRAMMER) -P $(PORT) -b $(BAUD) -U eeprom:w:build/$(FILENAME).eep.hex:i

read-flash:
	avrdude -v -p $(DEVICE) -c $(PROGRAMMER) -P $(PORT) -b $(BAUD) -U flash:r:build/$(FILENAME)_read.hex:d

read-eeprom:
	avrdude -v -p $(DEVICE) -c $(PROGRAMMER) -P $(PORT) -b $(BAUD) -U eeprom:r:build/$(FILENAME)_read.eep.hex:d

clean:
	rm -f build/$(FILENAME).o
	rm -f build/$(FILENAME).elf
	rm -f build/$(FILENAME).hex
	rm -f build/$(FILENAME).eep.hex
	rm -f build/$(FILENAME)_read.hex
	rm -f build/$(FILENAME)_read.eep.hex
