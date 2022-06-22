.nolist
.include "/opt/microchip/mplabx/v6.00/packs/Microchip/ATtiny_DFP/2.7.128/avrasm/inc/tn85def.inc"
.list

.ESEG

.DSEG

.CSEG
.org 0x00
                    LDI             R16, (1<<PB4)
                    LDI             R17, (1<<PB4)
                    OUT             DDRB, R16

LOOP:               OUT             PORTB, R16
                    RCALL           DELAY_1S
                    EOR             R16, R17
                    RJMP            LOOP

DELAY_1S:

                    LDI             R20, 4
DELAY1:             LDI             R21, 250
DELAY2:             LDI             R22, 250
DELAY3:             DEC             R22
                    NOP
                    BRNE            DELAY3

                    DEC             r21
                    BRNE            DELAY2

                    DEC             r20
                    BRNE            DELAY1

                    RET
