;Contador con velocidad varible - Laboratorio de Microcontroladores
;Al reset, comienza con la velocidad media. Su velocidad es indicada por LEDs.
;Hay dos botones RB5 para aumentar la velocidad y RB4 para dismunirla
;El Display se muestra por el puerto C de RC0 a RC6
;******************Header Files******************************
list		p=16f877a         ; list directive to define processor
#include	P16F877A.INC 	; processor specific variable definitions
#define		BANK_0 BCF STATUS, RP0
#define		BANK_1 BSF STATUS, RP0

;* *********Configuration  Bits******************************
__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_ON & _XT_OSC

;*******Variables Definition*********************************
CBLOCK  0x20
L1
L2
L3
LED
VEL
PORT_TMP
W_TEMP
STATUS_TEMP
PCLATH_TEMP
VEL_TEMP
Counter
Counter_Temp
ENDC
;****************Main code*****************************
	ORG     0x000			  ;reset vector
	GOTO    MAIN			  ;go to the main routine

	ORG     0x004            	  ;interrupt vector
		MOVWF 	W_TEMP		  ;Copy W to TEMP register
		SWAPF 	STATUS,W	  ;Swap status to be saved into W
		CLRF 	STATUS		  ;bank 0, regardless of current bank, Clears IRP,RP1,RP
		MOVWF 	STATUS_TEMP	  ;Save status to bank zero STATUS_TEMP register
		MOVF 	PCLATH, W	  ;Only required if using pages 1, 2 and/or 3
		MOVWF 	PCLATH_TEMP       ;Save PCLATH into W
		CLRF 	PCLATH 		  ;Page zero, regardless of current page
    	;-----
		CALL	ISR
		;-----
		MOVF 	PCLATH_TEMP, W 	  ;Restore PCLATH
		MOVWF 	PCLATH 		  ;Move W into PCLATH
		SWAPF 	STATUS_TEMP,W     ;Swap STATUS_TEMP register into W
			;(sets bank to original state)
		MOVWF 	STATUS		  ;Move W into STATUS register
		SWAPF 	W_TEMP,F	  ;Swap W_TEMP
		SWAPF 	W_TEMP,W	  ;Swap W_TEMP into W

		RETFIE

INIT
		BANK_1		          ;bank 1
		MOVLW	b'00110000'	  ;Declaration of RB5 and RB4 as inputs
		MOVWF 	TRISB		  
		CLRF	INTCON
		BSF	INTCON, GIE	  ;interrupts are enabled
		BSF	INTCON, RBIE	  ;change-of-state interrupt is enabled
		CLRF	TRISD		  ;whole PORTD is output
		CLRF	TRISC		  ;whole PORC is output
		BANK_0
		CLRF	PORT_TMP	  ;both user-defined registers are cleared
		CLRF	PORTC
		CLRF	Counter_Temp
		CLRF	VEL
		CLRF	VEL_TEMP
		CLRF	Counter
		MOVLW	0x10		  ;The base velocity allows the change every 0.25 seconds
		MOVWF	VEL
		MOVWF	LED
		MOVWF	PORTD
		RETURN

ISR:
		MOVF	PORTB, 0		;PORTB is copied into WREG
		BCF	INTCON, RBIF		;change-of-state interrupt flag is cleared
		MOVWF	PORT_TMP		;PORT_TMP = PORTB

		BTFSC	PORT_TMP, 5		;RB5 is tested, increments the speed if it is 1
		GOTO	Aumenta_Velocidad		

		BTFSC	PORT_TMP, 4		;RB4 is tested, increments the speed if it is 1
		GOTO	Disminuye_Velocidad	       	

		RETURN

Aumenta_Velocidad
		MOVF	VEL, 0
		ADDLW	0x20
		MOVWF	VEL_TEMP
		BTFSC	VEL_TEMP, 6
		RETURN
		MOVF	VEL, 0
		ADDWF	VEL, 1
		MOVF	VEL, 0
		MOVWF	LED
		RETURN

Disminuye_Velocidad
		MOVF	VEL, 0
		MOVWF	VEL_TEMP
		BTFSC	VEL_TEMP, 1
		RETURN
		RRF	VEL, 1
		RRF	LED, 1
		RETURN

DELAY					     ; Time Delay Routines
		MOVF	VEL, 0               ; Copy Vel to W
		MOVWF	L3                   ; Copy W into L3
     LOOP3
		MOVLW	0xFF                 ; Copy 255 to W
		MOVWF	L2                   ; Copy W into L2
     LOOP2
		MOVLW	0XA2                 ; Copy 162 into W
		MOVWF	L1                   ; Copy W into L1
     LOOP1
		decfsz	L1,F                 ; Decrement L1. If 0 Skip next instruction
		GOTO	LOOP1                ; ELSE Keep counting down

		decfsz	 L2,F                ; Decrement L2. If 0 Skip next instruction
		GOTO	LOOP2                ; ELSE Keep counting down

		decfsz	 L3,F                ; Decrement L2. If 0 Skip next instruction
		GOTO	LOOP3                ; ELSE Keep counting down
		RETURN

MAIN
		CALL	INIT
LOOP
		MOVLW	0x00
		MOVWF	Counter
PLUS_ONE
		MOVF	LED, 0
		MOVWF	PORTD
		MOVF	Counter, 0
		MOVWF	Counter_Temp
		ADDLW	0x06
		MOVWF	Counter_Temp
		BTFSC	Counter_Temp, 4
		GOTO	LOOP
		MOVF	Counter, 0
		CALL	Show_Routine		   ;If false then call the show routine
		INCF	Counter
		CALL	DELAY
		GOTO 	PLUS_ONE		   ;infinite loop

Show_Routine

		CALL	LOOKUP_TABLE;This shows the number on the display using a lookup table
		MOVWF	PORTC
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
END
