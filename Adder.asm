;A 4x12 decoder to 7 segment display is implemented using PORTB
;the inputs are RD0 (LSB), RD1, RD2 and RD3(MSB) for the first Number
;the inputs are RD4 (LSB), RD5, RD6 and RD7(MSB) for the second Number
;the seven outputs are RB0 (LSB) through RB6
;******************Header Files******************************
list		p=16f877a         ; list directive to define processor
#include	P16F877A.INC 	; processor specific variable definitions
#define		BANK_0 BCF STATUS, RP0
#define		BANK_1 BSF STATUS, RP0

;*****************Configuration Bits******************************
__CONFIG _LVP_OFF & _BODEN_OFF & _WDT_OFF & _XT_OSC

;****************Variables Definition*********************************
NumberOne EQU 0x21		;GPR that contains the first number
NumberTwo EQU 0x22		;GPR that contains the second number
Result    EQU 0x23		;GPR that contains the result number
Exception EQU 0x24		;GPR that contains the error number
Temporal  EQU 0x25		;GPR that temporarily stores PORTD
;****************Main Program*****************************
		ORG     0x000		    ;reset vector 
		GOTO    MAIN		    ;goes to main program

    INIT	BANK_1			    ;bank 1
		MOVLW	b'11111111'	    ;mixed input-output port '1' means input
		MOVWF	TRISD
		CLRF	TRISB	    ;whole PORTD is output
		BANK_0			    ;bank 0
		CLRF 	PORTB		    ;PORTD is cleared
		RETURN			    ;leaving initialization subroutine



MAIN		CALL 	INIT

READ_CODE	CALL	SEPARATION	    ;This separates the two numbers
		CALL	ADDITION	    ;It makes a call to the addition
		;ANDLW	0x0F		    ;This preserves RB3, RB2, RB1 and RB0 only
		MOVWF	Exception	    ;We move what is in W to Eception
		BTFSC	Exception, 4	    ;We test if the number is unshowable
		CALL	UnKnown		    ;If true then it shows an U
		CALL	Show_Routine	    ;If false then call the show routine
		GOTO	READ_CODE	    ;It goes back

SEPARATION

		MOVF	PORTD, 0	    ;PORTD data is moved into WREG = 0
		ANDLW	0x0F		    ;a mask preserves RB3, RB2, RB1 and RB0 only
		MOVWF	NumberOne	    ;This saves the first number
		MOVF	PORTD, 0	    ;PortD data is moved into WREG
		MOVWF	Temporal	    ; Stores what is in WREG into Temporal so it can be swaped
		SWAPF	Temporal, 1	    ;It makes a swipe to inver the four MSB to the four LBS
		MOVF	Temporal, 0	    ;PORTD data is moved into WREG = 0
		ANDLW	0x0F		    ;a mask preserves RB7, RB6, RB5 and RB4 only
		MOVWF	NumberTwo	    ;This saves the second number
		RETURN
		
ADDITION
		MOVF	NumberOne, 0	    ;PORTD data is moved into WREG = 0
		ADDWF	NumberTwo, 0	    ;Add W register with register f. IF 0 the result is stored in the W.
		MOVWF	Result
		RETURN

UnKnown
		CLRW		    ;Clear the W
		ADDLW	0xC1	    ;This shows an U of Error
		MOVWF	PORTB
		GoTo	READ_CODE   ;Return to the start

Show_Routine
		
		CALL	LOOKUP_TABLE; Start the shown of the number
		MOVWF	PORTB
		RETURN

LOOKUP_TABLE			    ;this is the code for a common annode
		ADDWF	PCL, 1	    ;This make the programm counter star at 1	
		RETLW	0xC0	    ;0x3F  0
		RETLW	0xF9	    ;0x06  1
		RETLW	0xA4	    ;0x5B  2
		RETLW	0xB0	    ;0x4F  3
		RETLW	0x99	    ;0x64  4
		RETLW	0x92	    ;0x6D  5
		RETLW	0x82	    ;0x7D  6
		RETLW	0xF8	    ;0x07  7
		RETLW	0x80	    ;0x7F  8
		RETLW	0x90	    ;0x6F  9
		RETLW   0x88	    ;	   A
		RETLW	0x83	    ;	   B
		RETLW	0xC6	    ;	   C
		RETLW	0xA1	    ;	   D
		RETLW	0x86	    ;	   E
		RETLW	0x8E	    ;	   F
		

		END                       ;end of program