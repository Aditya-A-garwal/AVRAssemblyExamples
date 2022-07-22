.nolist
.include "/opt/microchip/mplabx/v6.00/packs/Microchip/ATmega_DFP/2.4.131/avrasm/inc/m328Pdef.inc"
.list

.ESEG

.DSEG

.CSEG
.org 0x00
                    RCALL           UART_INIT

                    ; write the character 'A' to UART
                    LDI             R20, 'A'
                    RCALL           UART_WRITE_CHAR

                    ; writes the newline to UART
                    LDI             R20, 10
                    RCALL           UART_WRITE_CHAR

                    ; writes the string pointed to by HELLO_STRING to the UART
                    LDI             ZL, LOW (2 * HELLO_STRING)
                    LDI             ZH, HIGH (2 * HELLO_STRING)
                    RCALL           UART_WRITE_STR

                    ; writes the first HELLO_LEN characters of the string pointed to by HELLO_STRING to the UART
                    LDI             ZL, LOW (2 * HELLO_STRING)
                    LDI             ZH, HIGH (2 * HELLO_STRING)
                    LDI             R20, HELLO_LEN
                    RCALL           UART_WRITE_BUFF

                    ; keep spinning the CPU
SPIN:               RJMP            SPIN



HELLO_STRING:       .db             "Hello World!", 10, 0
HELLO_LEN_LABEL:    .equ            HELLO_LEN   = 2 * (HELLO_LEN_LABEL - HELLO_STRING)


; initializes the UART to 9600 BAUD at a frequency of 16 MHz
UART_INIT:
                    .equ            F_CPU           = 16000000
                    .equ            BAUD_RATE       = 9600
                    .equ            BAUD_PRESCALER  = (F_CPU/(BAUD_RATE * 16)) - 1

                    ; initialize UART to 9600 baud
                    LDI             R16, LOW (BAUD_PRESCALER)
                    LDI             R17, HIGH (BAUD_PRESCALER)
                    STS             UBRR0L, R16
                    STS             UBRR0H, R17

                    ; enable transmitter and reciever modes
                    LDI             R16, (1<<TXEN0)|(1<<RXEN0)
                    STS             UCSR0B, R16

                    RET


; writes a single character to the UART
; R20 should have the character (single byte) to send
UART_WRITE_CHAR:
                    ; wait for the write buffer to become empty (bit UDRE0 of UCSR0A register should be set)
                    LDS             R16, UCSR0A
                    SBRS            R16, UDRE0
                    RJMP            UART_WRITE_CHAR

                    ; copy the argument to the UDR0 register to be sent out
                    STS             UDR0, R20

                    RET


; writes a NULL terminated string to the UART
UART_WRITE_STR:
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
                    RJMP            UART_WRITE_STR

UART_WRITE_STR_END:
                    RET


; writes a buffer of a given length (<256) to the UART
; the Z register pair should have the address of the buffer
; R20 should have the length of the buffer
UART_WRITE_BUFF:
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
                    RJMP            UART_WRITE_BUFF

UART_WRITE_BUFF_END:
                    RET
