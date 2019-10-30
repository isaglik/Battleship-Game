; Nokia5110-ADC.s

; Sets up ADC0 & Seq 1 to work with 
; two analog inputs from PD1-PD0

; ADC Registers
; ADC0 base address EQU 0x40038000
ADC0_ACTSS 		EQU 0x40038000 			; Sample sequencer (ADC0 base address)
ADC0_RIS 		EQU 0x40038004 			; Interrupt status
ADC0_IM 		EQU 0x40038008 			; Interrupt select
ADC0_EMUX		EQU 0x40038014 			; Trigger select
ADC0_PSSI 		EQU 0x40038028 			; Initiate sample
ADC0_SSMUX1 	EQU 0x40038060 			; Input channel select
ADC0_SSCTL1 	EQU 0x40038064 			; Sample sequence control
ADC0_SSFIFO1 	EQU 0x40038068 			; Channel 3 results
ADC0_PC 		EQU 0x40038FC4 			; Sample rate
ADC0_ISC		EQU 0x4003800C 			; Interrupt status clear
ADC0_SAC		EQU	0x40038030			;hardware averaging
; GPIO Registers 
; PORT D base address EQU 0x40007000
PORTD_DEN 		EQU 0x4000751C			; Digital Enable
PORTD_PCTL 		EQU 0x4000752C			; Alternate function select
PORTD_AFSEL 	EQU 0x40007420			; Enable Alt functions
PORTD_AMSEL 	EQU 0x40007528			; Enable analog
			
; System Registers			
RCGCGPIO 		EQU 0x400FE608			; GPIO clock register
RCGCADC 		EQU 0x400FE638			; ADC clock register

			AREA 	routines, CODE, READONLY
			THUMB
			
			EXPORT Sampl
			EXPORT ADC_Init
					
;*****************************************************************
;Samples from PD1 to R4 and PD0 to R5.
Sampl	
	; start sampling routine 
		PUSH	{R0-R3,R6,R7}
		LDR 	R3, =ADC0_RIS   		; interrupt address  
		LDR 	R7, =ADC0_SSFIFO1 		; result address 
		LDR 	R2, =ADC0_PSSI  		; sample sequence initiate address  
		LDR 	R6,= ADC0_ISC 
		
		; initiate sampling by enabling sequencer 1 in ADC0_PSSI 
		LDR 	R0, [R2] 
		ORR 	R0, R0, #0x02   		; set bit 2 for SS1  
		; cleared once sampling is initiated
		STR 	R0, [R2]
	; check for sample complete (bit 2 of ADC0_RIS set) 
waitSam	
		LDR 	R0, [R3]
		ANDS 	R0, R0, #2				;branch fails if the flag is
		BEQ 	waitSam  				;set so data can be read and flag is cleared
						
		
		LDR 	R4,[R7]
		LDR 	R5,[R7]
		MOV 	R0, #2 
		STR 	R0, [R6]   				; clear flag 
		POP		{R0-R3,R6,R7}
		BX 		LR

;*****************************************************************
; PD 1,0 for A/D (AIN 6,7)
ADC_Init				
		PUSH	{R0,R1}
	; Start clocks for features to be used  
		LDR 	R1, =RCGCGPIO 			; Turn GPIO clock on
		LDR 	R0, [R1] 
		ORR 	R0, R0, #0x08 			; enable port D clock  
		STR 	R0, [R1] 
		NOP
		NOP
		NOP  							; Let clock stabilize 
	; Setup GPIO to make PD0-1 input for ADC0 
		LDR 	R1, =PORTD_AFSEL    	; Enable alternate functions
		LDR 	R0, [R1]  
		ORR 	R0, R0, #0x03
		STR 	R0, [R1]  
		LDR 	R1, =PORTD_DEN 			; Disable digital on PD0-1
		LDR 	R0, [R1] 
		BIC 	R0, R0, #0x03 
		STR 	R0, [R1]  
		LDR 	R1, =PORTD_AMSEL 		; Enable analog on PD0-1
		LDR 	R0, [R1] 
		ORR 	R0, R0, #0x01 
		STR 	R0, [R1] 
		
	; ADC initialization for Seq 1 
		LDR 	R1, =RCGCADC  			; Turn on ADC clock  
		LDR 	R0, [R1] 
		ORR 	R0, R0, #0x01   		; set bit 0 to enable ADC0 clock  
		STR 	R0, [R1] 
		
		; small delay
		MOV		R0,#0x0F
waitSSIClk								; allow clock to settle
		SUBS	R0, R0,#0x01
		BNE		waitSSIClk 

		LDR 	R1, =ADC0_ACTSS 		; Disable sequencer while ADC setup 
		LDR 	R0, [R1] 
		BIC 	R0, R0, #0x02   		; clear to disable seq 1  
		STR 	R0, [R1] 
		LDR 	R1, =ADC0_EMUX 			; Select trigger source 
		LDR 	R0, [R1] 
		BIC 	R0, R0, #0x00F0  		; clear bits 4:7 to select processor trigger  
		STR 	R0, [R1]   
		LDR 	R1, =ADC0_SSMUX1 		; Select input channel 
		MOV 	R0, #0x0067 
		STR 	R0,[R1]
		LDR 	R1, =ADC0_SSCTL1 		; Config sample sequence 
		MOV 	R0,#0x0060   			; set bit 1 for sample 2 (IE1, END1)  
		STR 	R0, [R1]  
		LDR 	R1, =ADC0_SAC			; Config sample sequence 
		MOV 	R0,#0x3   			; set bit 1 for sample 2 (IE1, END1)  
		STR 	R0, [R1]    
		LDR 	R1, =ADC0_ACTSS 		; Done with setup, enable sequencer
		LDR 	R0, [R1] 
		ORR 	R0, R0, #0x02   		; set to enable seq'r 1 
		STR 	R0, [R1]   				; sampling enabled but not initiated yet 
		POP		{R0,R1}
		BX 		LR 
 
		
		ALIGN
		END
 
