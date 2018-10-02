;Timer2 is the one that controls the current and future state of the traffic light.
;Timer0 is the one that controls the blinking of the Green light
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
    COUNTER
    COUNTER_S
    META_TEMP
    ;FLAG
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
    CLRF  TMR0
    CLRF  TMR2
    RETFIE              ;end of ISR

ISR:
    BTFSC PIR1, TMR2IF	    ;Checks which timer had the interrupt
    GOTO  TMR_2		    ;if it was Timer2, it will go to TMR_2
    GOTO  TMR_0		    ;if it was Timer0, it will go to TMR_0
    RETURN            ;

INITIALIZE:
    BANK_1
    CLRF  TRISD       ;PORTB is output
    BSF PIE1, TMR2IE    ;enable interrupt of timer2 is set
    MOVLW b'11000010'     ;
    MOVWF OPTION_REG      ;TIMER0 as a timer and prescaler is assigned to WDT
    BANK_0
    MOVLW b'01111101'
    MOVWF T2CON
    BSF INTCON, PEIE
    CLRF  TMR0        ;TIMER0 is cleared
    CLRF  TMR2        ;TIMER2 is cleared
    CLRF  COUNTER     ;counter is cleared
    CLRF  PORTD		;PORTD is cleared
    CLRF  COUNTER_S   ;counter is cleared
    CLRF  META_TEMP
    BSF INTCON, GIE     ;GIE is set
    RETURN            ;leaves subroutine

MAIN:
      CALL  INITIALIZE    ;infinite loop

LOOP
    Green_On       ;Green light is on for 4 seconds
    Call  Cuenta_4_Segundos	;Delay Cuenta_4_Segundos es llamado
    Call  Blink		    ;Blink es llamado
    Green_Off      ;Provisonal
    Yellow_On      ;Yellow light is on for 4 seconds
    BANK_1
    BSF PIE1, TMR2IE    ;enable interrupt of timer2 is set
    BANK_0
    BCF INTCON, T0IE    ;enable interrupt of timer0 is set
    Call  Cuenta_4_Segundos
    Yellow_Off
    Red_On         ;Red light is on for 4 seconds
    Call  Cuenta_4_Segundos
    Red_Off
    Goto  LOOP
    
Blink   
    BANK_1
    BCF PIE1, TMR2IE    ;enable interrupt of timer2 is set
    BANK_0
    BSF INTCON, T0IE    ;enable interrupt of timer0 is set
    Green_Off
    Call  Cuenta_Medio_Segundo
    Green_On
    Call  Cuenta_Medio_Segundo
    Green_Off
    Call  Cuenta_Medio_Segundo
    Green_On
    Call  Cuenta_Medio_Segundo
    Green_Off
    Call  Cuenta_Medio_Segundo
    Green_On
    Call  Cuenta_Medio_Segundo
    Green_Off
    Return

Cuenta_Medio_Segundo	    ;Se quedara atorado en este loop hasta que pase el medio segundo
    BTFSS COUNTER_S, 7
    GOTO  Cuenta_Medio_Segundo
    BTFSS COUNTER_S, 6
    GOTO  Cuenta_Medio_Segundo
    BTFSS COUNTER_S, 5
    GOTO  Cuenta_Medio_Segundo
    BTFSS COUNTER_S, 4
    GOTO  Cuenta_Medio_Segundo
    BTFSS COUNTER_S, 3
    GOTO  Cuenta_Medio_Segundo
    BTFSS COUNTER_S, 2
    GOTO  Cuenta_Medio_Segundo
    BTFSS COUNTER_S, 1
    GOTO  Cuenta_Medio_Segundo
    BTFSS COUNTER_S, 0
    GOTO  Cuenta_Medio_Segundo
    CLRF  COUNTER_S
    RETURN        ;infinite loop
    
    
Cuenta_4_Segundos	    ;Se quedara atorado en este loop hasta que pasen los cuatro segundos.
    BTFSS COUNTER, 7
    GOTO  Cuenta_4_Segundos
    BTFSS COUNTER, 6
    GOTO  Cuenta_4_Segundos
    BTFSS COUNTER, 5
    GOTO  Cuenta_4_Segundos
    BTFSS COUNTER, 4
    GOTO  Cuenta_4_Segundos
    BTFSS COUNTER, 3
    GOTO  Cuenta_4_Segundos
    BTFSS COUNTER, 2
    GOTO  Cuenta_4_Segundos
    BTFSS COUNTER, 1
    GOTO  Cuenta_4_Segundos
    BTFSS COUNTER, 0
    GOTO  Cuenta_4_Segundos
    CLRF  COUNTER
    RETURN        ;infinite loop
TMR_0   
    BCF INTCON, T0IF    ;TIMER0 flag is cleared
    MOVF  COUNTER_S,0
    ADDLW 0x01
    MOVWF COUNTER_S
    CLRF  TMR0      ;TIMER0 is cleared
    RETURN
    
TMR_2   BCF PIE1, TMR2IF    ;TIMER2 flag is cleared
    MOVF  COUNTER, 0
    ADDLW 0x01
    MOVWF COUNTER
    RETURN    
    
    end