.nolist
.include "/opt/microchip/mplabx/v6.00/packs/Microchip/ATmega_DFP/2.4.131/avrasm/inc/m328Pdef.inc"
.list

.ESEG

.DSEG

.CSEG
.org 0x00
                    RJMP            RESET

.org INT0addr
                    RETI

.org INT1addr
                    RETI

.org PCI0addr
                    RETI

.org PCI1addr
                    RETI

.org PCI2addr
                    RETI

.org WDTaddr
                    RETI

.org OC2Aaddr
                    RETI

.org OC2Baddr
                    RETI

.org OVF2addr
                    RETI

.org ICP1addr
                    RETI

.org OC1Aaddr
                    RETI

.org OC1Baddr
                    RETI

.org OVF1addr
                    RJMP            TIMER1_OVF_vect

.org OC0Aaddr
                    RETI

.org OC0Baddr
                    RETI

.org OVF0addr
                    RETI

.org SPIaddr
                    RETI

.org URXCaddr
                    RETI

.org UDREaddr
                    RETI

.org UTXCaddr
                    RETI

.org ADCCaddr
                    RETI

.org ERDYaddr
                    RETI

.org ACIaddr
                    RETI

.org TWIaddr
                    RETI

.org SPMRaddr
                    RETI


TIMER1_OVF_vect:    IN              R18, SREG                       ; store the contents of SREG on the stack
                    PUSH            R18

                    EOR             R17, R16
                    OUT             PORTB, R17

                    POP             R18                             ; restore the contents of SREG from the stack and return
                    OUT             SREG, R18
                    RETI


RESET:              LDI             R16, LOW(RAMEND)                ; set up stack pointer
                    OUT             SPL, R16
                    LDI             R16, HIGH(RAMEND)
                    OUT             SPH, R16

                    LDI             R16, (1<<PB5)                   ; set PB5 (pin 13 on Arduino UNO with builtin LED) as output
                    OUT             DDRB, R16

                    EOR             R18, R18                        ; move the value of zero into TCCR1A
                    STS             TCCR1A, R18

                    LDI             R18, (1<<CS12)                  ; set the prescaler for timer 1 to 256
                    STS             TCCR1B, R18

                    LDI             R18, (1<<TOIE1)                 ; enable timer overflow interrupts and enable global interrupts
                    STS             TIMSK1, R18
                    SEI

LOOPFOREVER:        RJMP            LOOPFOREVER
