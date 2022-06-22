.nolist
.include "/opt/microchip/mplabx/v6.00/packs/Microchip/ATtiny_DFP/2.7.128/avrasm/inc/tn85def.inc"
.list

.ESEG

.DSEG

.CSEG
.org 0x00
                    RJMP            RESET

.org INT0addr
                    RETI

.org PCI0addr
                    RETI

.org OC1Aaddr
                    RETI

.org OVF1addr
                    RETI

.org OVF0addr
                    RJMP            TIMER0_OVF_vect

.org ERDYaddr
                    RETI

.org ACIaddr
                    RETI

.org ADCCaddr
                    RETI

.org OC1Baddr
                    RETI

.org OC0Aaddr
                    RETI

.org OC0Baddr
                    RETI

.org WDTaddr
                    RETI

.org USI_STARTaddr
                    RETI

.org USI_OVFaddr
                    RETI



TIMER0_OVF_vect:    IN              R18, SREG                       ; store the contents of SREG on the stack
                    PUSH            R18

                    INC             R19                             ; increment the overflow counter and only pass if it is equal to 4
                    SBRS            R19, 2
                    RETI

                    EOR             R19, R19                        ; clear the coutner and toggle the LED
                    EOR             R17, R16
                    OUT             PORTB, R17

                    POP             R18                             ; restore the contents of SREG from the stack and return
                    OUT             SREG, R18
                    RETI


RESET:              LDI             R16, LOW(RAMEND)                ; set up stack pointer
                    OUT             SPL, R16
                    LDI             R16, HIGH(RAMEND)
                    OUT             SPH, R16

                    LDI             R16, (1<<PB4)                   ; set PB4 as output
                    OUT             DDRB, R16

                    EOR             R18, R18                        ; set timer to normal mode
                    OUT             TCCR0A, R18

                    LDI             R18, (1<<CS02)|(1<<CS00)        ; set prescaler to 1024 (also starts the timer)
                    OUT             TCCR0B, R18

                    LDI             R18, (1<<TOIE0)                 ; enable timer overflow interrupt and enable global interrupts
                    OUT             TIMSK, R18
                    SEI

                    LDI             R18, (1<<SE)                    ; put the attiny in IDLE sleep mode
                    OUT             MCUCR, R18
GOTOSLEEP:          SLEEP
                    RJMP            GOTOSLEEP
