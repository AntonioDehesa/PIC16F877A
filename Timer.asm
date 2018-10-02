;The number of TIMER0 overflows is counted
;Overflows are detected using interrupts
;The count of overflows is shown in port B
;******************Header Files******************************
    list    p=16f877a         ; list directive to define processor
    #include  p16f877a.inc  ; processor specific variable definitions
    #define   BANK_0      BCF   STATUS, RP0
    #define   BANK_1      BSF   STATUS, RP0
    #define   Green_On    BSF   PORTD, 0
    #define   Green_Off   BCF   PORTD, 0
    #define   Yellow_On   BSF   PORTD, 1
    #define   Yellow_Off  BCF   PORTD, 1
    #define   Red_On      BSF   PORTD, 2
    #define   Red_Off     BCF   PORTD, 2

;*****************Configuration Bits******************************
    __CONFIG _LVP_OFF & _BODEN_OFF & _WDT_OFF & _XT_OSC

;****************Variables Definition*********************************
    CBLOCK  0x20        ;user?s registers
    W_TEMP
    STATUS_TEMP
    PCLATH_TEMP
    COUNTER_TMR
    COUNTER_RB
    COUNTER
    META_TEMP
    ENDC
;****************Main Program*****************************
    ORG     0x000               ; reset vector
      GOTO    MAIN                ;

    ORG     0x004               ;interrupt vector
    MOVWF   W_TEMP        ;Copy W to TEMP register
    SWAPF   STATUS,W      ;Swap status to be saved into W
    CLRF  STATUS        ;bank 0, regardless of current bank, Clears IRP,RP1,RP
    MOVWF   STATUS_TEMP     ;Save status to bank zero STATUS_TEMP register
    MOVF  PCLATH, W       ;Only required if using pages 1, 2 and/or 3
    MOVWF   PCLATH_TEMP     ;Save PCLATH into W
    CLRF  PCLATH        ;Page zero, regardless of current page
      ;-----
    CALL  ISR
    ;-----
    BSF INTCON, GIE
    MOVF  PCLATH_TEMP, W    ;Restore PCLATH
    MOVWF   PCLATH        ;Move W into PCLATH
    SWAPF   STATUS_TEMP,W     ;Swap STATUS_TEMP register into W
                  ;(sets bank to original state)
    MOVWF   STATUS        ;Move W into STATUS register
    SWAPF   W_TEMP,F      ;Swap W_TEMP
    SWAPF   W_TEMP,W      ;Swap W_TEMP into W
    CLRF  TMR2
    RETFIE              ;end of ISR

ISR:
    BTFSC PIR1, TMR2IF	    ;Se prueba si la interrupcion se ha dado por TMR2
    GOTO  TMR_2		    ;Si ha sido TMR2, se ira a su rutina
    BTFSC   PORTB, 7	    ;Si no, se probara si ha sido el Pin 7 del puerto B
    GOTO  INT_PORTB	    ;Si asi ha sido, se ira a la rutina del Pin 7 del puerto B
    RETURN            ;

INITIALIZE:
    BANK_1
    CLRF	INTCON
    MOVLW   0xFF	    
    MOVWF   TRISB	;Se declara a puerto b como salida
    BSF PIE1, TMR2IE    ;enable interrupt of timer2 is set
    BSF		INTCON, RBIE		;change-of-state interrupt is enabled
    BANK_0
    MOVLW b'01101100'	;Se le da al TMR2 un Postscale de 13
    MOVWF T2CON
    BSF INTCON, PEIE	;Se permiten las interrupciones de periferico
    CLRF  TMR2        ;TIMER2 is cleared
    CLRF  COUNTER_TMR     ;COUNTER_TMR is cleared
    CLRF  PORTB		    ;PORTB is cleared
    CLRF    COUNTER	    ;COUNTER is cleared
    CLRF  COUNTER_RB  ;COUNTER_RB is cleared
    CLRF  META_TEMP
    BSF INTCON, GIE     ;GIE is set
    RETURN            ;leaves subroutine

MAIN:
      CALL  INITIALIZE    ;infinite loop

LOOP
    CALL    Cuenta_920_Milisegundos	;Se llamara a la rutina que cuenta 920 milisegundos
    INCF    COUNTER_TMR			;Una vez saliendo de esta, se incrementa en uno el COUNTER_TMR
    Goto  LOOP
    
Cuenta_920_Milisegundos
    BTFSS COUNTER, 7
    GOTO  Cuenta_920_Milisegundos
    BTFSS COUNTER, 6
    GOTO  Cuenta_920_Milisegundos
    BTFSS COUNTER, 5
    GOTO  Cuenta_920_Milisegundos
    BTFSS COUNTER, 4
    GOTO  Cuenta_920_Milisegundos
    BTFSS COUNTER, 3
    GOTO  Cuenta_920_Milisegundos
    BTFSS COUNTER, 2
    GOTO  Cuenta_920_Milisegundos
    BTFSS COUNTER, 1
    GOTO  Cuenta_920_Milisegundos
    BTFSS COUNTER, 0
    GOTO  Cuenta_920_Milisegundos
    CLRF  COUNTER
    RETURN
INT_PORTB   
    BCF		INTCON, RBIF		;change-of-state interrupt flag is cleared
    INCF    COUNTER_RB
    RETURN
    
TMR_2   
    BCF PIR1, TMR2IF    ;TIMER2 flag is cleared
    INCF    COUNTER, 1
    RETURN    
    
    end