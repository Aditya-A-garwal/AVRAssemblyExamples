#include <avr/io.h>

.section .data

.section .bss

.section .text

.org 0x00
                    RJMP            RESET

.org 0x02
                    RETI

.org 0x04
                    RETI

.org 0x06
                    RETI

.org 0x08
                    RETI

.org 0x0A
                    RJMP            TIMER0_OVF_vect

.org 0x0C
                    RETI

.org 0x0E
                    RETI

.org 0x10
                    RETI

.org 0x12
                    RETI

.org 0x14
                    RETI

.org 0x16
                    RETI

.org 0x18
                    RETI

.org 0x1A
                    RETI

.org 0x1C
                    RETI


TIMER0_OVF_vect:    IN              R18, _SFR_IO_ADDR (SREG)        ; store the contents of SREG on the stack
                    PUSH            R18

                    INC             R19                             ; increment the overflow counter and only pass if it is equal to 4
                    SBRS            R19, 2
                    RETI

                    EOR             R19, R19                        ; clear the coutner and toggle the LED
                    EOR             R17, R16
                    OUT             PORTB, R17

                    POP             R18                             ; restore the contents of SREG from the stack and return
                    OUT             _SFR_IO_ADDR (SREG), R18
                    RETI


RESET:              LDI             R16, lo8 (RAMEND)               ; set up stack pointer (RAMEND = 0x025f)
                    OUT             _SFR_IO_ADDR (SPL), R16
                    LDI             R16, hi8 (RAMEND)
                    OUT             _SFR_IO_ADDR (SPH), R16

                    LDI             R16, (1<<PB4)                   ; set PB4 as output
                    OUT             DDRB, R16

                    EOR             R18, R18                        ; set timer to normal mode
                    OUT             _SFR_IO_ADDR (TCCR0A), R18

                    LDI             R18, (1<<CS02)|(1<<CS00)        ; set prescaler to 1024 (also starts the timer)
                    OUT             _SFR_IO_ADDR (TCCR0B), R18

                    LDI             R18, (1<<TOIE0)                 ; enable timer overflow interrupt and enable global interrupts
                    OUT             _SFR_IO_ADDR (TIMSK), R18
                    SEI

                    LDI             R18, (1<<SE)                    ; put the attiny in IDLE sleep mode
                    OUT             _SFR_IO_ADDR (MCUCR), R18
GOTOSLEEP:          SLEEP
                    RJMP            GOTOSLEEP
