#include <avr/io.h>

.section .bss

.section .data

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
                    RETI

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
                    RJMP            TIMER1_OVF_vect

.org 0x1C
                    RETI

.org 0x1E
                    RETI

.org 0x20
                    RETI

.org 0x22
                    RETI

.org 0x24
                    RETI

.org 0x26
                    RETI

.org 0x28
                    RETI

.org 0x2A
                    RETI

.org 0x2C
                    RETI

.org 0x2E
                    RETI

.org 0x30
                    RETI

.org 0x32
                    RETI


TIMER1_OVF_vect:    IN              R18, _SFR_IO_ADDR (SREG)        ; store the contents of SREG on the stack
                    PUSH            R18

                    EOR             R17, R16
                    OUT             _SFR_IO_ADDR (PORTB), R17

                    POP             R18                             ; restore the contents of SREG from the stack and return
                    OUT             _SFR_IO_ADDR (SREG), R18
                    RETI


RESET:              LDI             R16, lo8 (RAMEND)               ; set up stack pointer
                    OUT             _SFR_IO_ADDR (SPL), R16
                    LDI             R16, hi8 (RAMEND)
                    OUT             _SFR_IO_ADDR (SPH), R16

                    LDI             R16, (1<<PB5)                   ; set PB5 (pin 13 on Arduino UNO with builtin LED) as output
                    OUT             _SFR_IO_ADDR (DDRB), R16

                    EOR             R18, R18                        ; move the value of zero into TCCR1A
                    STS             TCCR1A, R18

                    LDI             R18, (1<<CS12)                  ; set the prescaler for timer 1 to 256
                    STS             TCCR1B, R18

                    LDI             R18, (1<<TOIE1)                 ; enable timer overflow interrupts and enable global interrupts
                    STS             TIMSK1, R18
                    SEI

LOOPFOREVER:        RJMP            LOOPFOREVER
