# AVRAssemblyExamples
This repository contains example programs for AVR microcontrollers in Assembly (using AVRA/AVRASM2 and avr-as) and C/C++ (using avr-gcc). More examples will be added with time. A Makefile has been included to make the build process more convenient.
The following targets are defined by the Makefile -

* default - Alias for compile, upload, clean
* compile - This compiles the C program
* assemble - This assembles the Assembly program
* upload - Alias for upload-flash
* upload-flash - Uploads the built binary (.hex) to the MCU
* upload-eeprom - Uploads the built binary (.eep.hex) to the MCU's EEPROM
* read-flash - Reads the flash contents into a file
* read-eeprom - Reads the EEPROM contents into a file

Specifics of the built process (such as the CPU frequency, programmer, port) can be changed within the Makefile, and the user is encouraged to do so.
