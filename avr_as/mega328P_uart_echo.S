#include <avr/io.h>

.section .bss


.section .data


.section .text
.org 0x00

                    ; initialize the UART to read/write mode
                    RCALL           UART_INIT

                    ; print an initial message
                    LDI             ZL, lo8 (HELLO_STRING)
                    LDI             ZH, hi8 (HELLO_STRING)
                    RCALL           UART_WRITE_STR

LOOP:
                    ; read the next character from the UART
                    RCALL           UART_READ_CHAR

                    ; echo the read character back to the UART
                    MOV             R20, R0
                    RCALL           UART_WRITE_CHAR

                    ; keep looping
                    RJMP            LOOP



HELLO_STRING:       .ascii          "Starting Echo Program\x0A\x00\x00"
HELLO_LEN_LABEL:    .equ            HELLO_LEN, (HELLO_LEN_LABEL - HELLO_STRING)


; initializes the UART to 9600 BAUD at a frequency of 16 MHz
UART_INIT:
                    .equ            BAUD_RATE,        (9600)
                    .equ            BAUD_PRESCALER,   (16000000 / (BAUD_RATE * 16))

                    ; save the states of R16 and R17
                    PUSH            R16
                    PUSH            R17

                    ; initialize UART to 9600 baud
                    LDI             R16, lo8 (BAUD_PRESCALER)
                    LDI             R17, hi8 (BAUD_PRESCALER)
                    STS             UBRR0L, R16
                    STS             UBRR0H, R17

                    ; enable transmitter and reciever modes
                    LDI             R16, (1<<TXEN0)|(1<<RXEN0)
                    STS             UCSR0B, R16

                    ; restore the states of R16 and R17 and return
                    POP             R17
                    POP             R16
                    RET


; writes a single character to the UART
; R20 should have the character (single byte) to send
UART_WRITE_CHAR:
                    ; save the state of R16
                    PUSH            R16
UART_WRITE_CHAR_LOOP:
                    ; wait for the write buffer to become empty (bit UDRE0 of UCSR0A register should be set)
                    LDS             R16, UCSR0A
                    SBRS            R16, UDRE0
                    RJMP            UART_WRITE_CHAR_LOOP

                    ; copy the argument to the UDR0 register to be sent out
                    STS             UDR0, R20

                    ; restore the state of R16 and return
                    POP             R16
                    RET


; writes a NULL terminated string to the UART
UART_WRITE_STR:

                    ; save the states of R16 and R17
                    PUSH            R16
                    PUSH            R17

UART_WRITE_STR_LOOP:

                    ; load the current byte/character pointed to be Z and increment the Z pointer
                    LPM             R16, Z+

                    ; if the current character is 0/NULL, return from the routine since the string has been used
                    CPI             R16, 0
                    BREQ            UART_WRITE_STR_END

UART_WRITE_STR_CHAR:
                    ; wait for the write buffer to become empty (bit UDRE0 of UCSR0A register should be set)
                    LDS             R17, UCSR0A
                    SBRS            R17, UDRE0
                    RJMP            UART_WRITE_STR_CHAR

                    ; copy the current character to the UDR0 register to send it out and jump back to the start
                    STS             UDR0, R16
                    RJMP            UART_WRITE_STR_LOOP

UART_WRITE_STR_END:
                    ; restore the states of R16 and R17 and return
                    POP             R17
                    POP             R16
                    RET


; writes a buffer of a given length (<256) to the UART
; the Z register pair should have the address of the buffer
; R20 should have the length of the buffer
UART_WRITE_BUFF:

                    ; save the states of R16 and R17
                    PUSH            R16
                    PUSH            R17

UART_WRITE_BUFF_LOOP:

                    ; load the current byte/character pointed to be Z and increment the Z pointer
                    LPM             R16, Z+

                    ; check if the remaining size of the string is non-zero and return if it is
                    CPI             R20, 0
                    BREQ            UART_WRITE_BUFF_END

UART_WRITE_BUFF_CHAR:

                    ; wait for the write buffer to become empty (bit UDRE0 of UCSR0A register should be set)
                    LDS             R17, UCSR0A
                    SBRS            R17, UDRE0
                    RJMP            UART_WRITE_BUFF_CHAR

                    ; copy the current character to the UDR0 register to send it out and jump back to the start
                    STS             UDR0, R16
                    DEC             R20
                    RJMP            UART_WRITE_BUFF_LOOP

UART_WRITE_BUFF_END:
                    ; restore the states of R16 and R17 and return
                    POP             R17
                    POP             R16
                    RET


; reades a single character from the UART
; R0 will have the result
UART_READ_CHAR:

                    ; save the state of R16
                    PUSH            R16

UART_READ_CHAR_WAIT:

                    ; wait till a character is in the buffer
                    LDS             R16, UCSR0A
                    SBRS            R16, RXC0
                    RJMP            UART_READ_CHAR_WAIT

                    ; read the character
                    LDS             R0, UDR0

                    ; restore the state of R16 and return
                    POP             R16
                    RET
