;Storage adresses
XPOSB	   	EQU	    	0x20000400
YPOSB	   	EQU	    	0x20000420
YPOSBITB   	EQU	    	0x20000440	
XPOSC	   	EQU	    	0x20000460
YPOSC	   	EQU	    	0x20000480
YPOSBITC   	EQU	    	0x20000500	

;Nested Vector Interrupt Controller registers
NVIC_EN0_INT19		EQU 0x00080000 ; Interrupt 30 enable
NVIC_EN0			EQU 0xE000E100 ; IRQ 0 to 31 Set Enable Register
NVIC_PRI7			EQU 0xE000E41C ; IRQ 28 to 31 Priority Register

;GPIO Registers
GPIO_PORTF_DATA		EQU 0x40025044 ; Access BIT&BIT4
GPIO_PORTF_DIR 		EQU 0x40025400 ; Port Direction
GPIO_PORTF_AFSEL	EQU 0x40025420 ; Alt Function enable
GPIO_PORTF_DEN 		EQU 0x4002551C ; Digital Enable
GPIO_PORTF_AMSEL 	EQU 0x40025528 ; Analog enable
GPIO_PORTF_PCTL 	EQU 0x4002552C ; Alternate Functions
GPIO_PORTF_PUR_R	EQU	0x40025510
GPIO_PORTF_LOCK_R   EQU	0x40025520
GPIO_PORTF_CR       EQU 0x40025524
GPIO_PORTF_IS       EQU 0x40025404
GPIO_PORTF_IBE      EQU 0x40025408
GPIO_PORTF_IEV      EQU 0x4002540C
GPIO_PORTF_IM 		EQU 0x40025410
GPIO_PORTF_ICR      EQU 0x4002541C
GPIO_PORTF_RIS      EQU 0x40025414


;System Registers
SYSCTL_RCGCGPIO 	EQU 0x400FE608 ; GPIO Gate Control
;---------------------------------------------------
					
			AREA 	routines, CODE, READONLY
			THUMB
			EXPORT	GPIO_Init
			EXPORT	My_GPIOPortF_Handler
			EXTERN	Outship
			EXTERN	Sampl
			EXTERN	SetXYNokia
			EXTERN	OutBUNokia
			EXTERN	OutBLNokia
			EXTERN  OutCUNokia
			EXTERN  OutCLNokia

;---------------------------------------------------				
My_GPIOPortF_Handler
			PUSH	{R0-R5,LR}
			LDR		R1,=GPIO_PORTF_RIS
			LDR		R0,[R1]
			ANDS	R0,#1
			BNE		insertc
			BEQ		insertb
			B		exit
			
insertc		BL		Sampl
			MOV		R0, #55		;Map the ADC value to the (6-70) for x axis  
			MUL		R4, R0
			MOV		R0,	#4095
			UDIV	R4, R0
			ADD		R4, #9
			LDR		R1,=XPOSC
			MOV		R3, #4
			MUL		R3, R9
			ADD		R1, R3
			STR		R4,[R1]
			MOV		R0, #24		;Map the ADC value to the (8-40) for y axis
			MUL		R5, R0
			MOV		R0, #4095
			UDIV	R5, R0
			ADD		R5, #2			;R5 has Ypos(0-32)
			MOV 	R2, R5			;R2 will be used as remainder
			MOV		R0, #8
			UDIV	R5, R0
			MUL		R1, R5, R0
			SUB		R2, R1			;R2 contains remainder
			ADD		R5, #1			;R5 has Ypos(1-5)
			LDR		R1,=YPOSBITC
			MOV		R3, #4
			MUL		R3, R9
			ADD		R1, R3
			STR		R2,[R1]
			LDR		R1,=YPOSC
			MOV		R3, #4
			MUL		R3, R9
			ADD		R1, R3	
			STR		R5,[R1]
			ADD 	R9, #1
			B		exit
			
insertb		BL		Sampl
			MOV		R0, #55		;Map the ADC value to the (6-70) for x axis  
			MUL		R4, R0
			MOV		R0,	#4095
			UDIV	R4, R0
			ADD		R4, #9
			LDR		R1,=XPOSB
			MOV		R3, #4
			MUL		R3, R10
			ADD		R1, R3
			STR		R4,[R1]
			MOV		R0, #24		;Map the ADC value to the (8-40) for y axis
			MUL		R5, R0
			MOV		R0, #4095
			UDIV	R5, R0
			ADD		R5, #2			;R5 has Ypos(0-32)
			MOV 	R2, R5			;R2 will be used as remainder
			MOV		R0, #8
			UDIV	R5, R0
			MUL		R1, R5, R0
			SUB		R2, R1			;R2 contains remainder
			ADD		R5, #1			;R5 has Ypos(1-5)
			LDR		R1,=YPOSBITB
			MOV		R3, #4
			MUL		R3, R10
			ADD		R1, R3
			STR		R2,[R1]
			LDR		R1,=YPOSB
			MOV		R3, #4
			MUL		R3, R10
			ADD		R1, R3
			STR		R5,[R1]
			ADD 	R10, #1
			
exit		LDR		R1,=GPIO_PORTF_ICR
			MOV		R0,#0x11
			STR		R0, [R1]

			POP		{R0-R5,LR}			
						
			BX		LR
;---------------------------------------------------
;---------------------------------------------------
GPIO_Init	
			PUSH	{R0-R5}
			LDR 	R1, =SYSCTL_RCGCGPIO 		; start GPIO clock
			LDR 	R0, [R1]
			ORR 	R0, R0, #0x20 				; set bit 5 for port F
			STR 	R0, [R1]
			NOP 								; allow clock to settle
			NOP	
			NOP	
			LDR 	R1, =GPIO_PORTF_LOCK_R 		;Unlock the ports
			LDR 	R0, =0x4C4F434B
			STR 	R0, [R1] 
			LDR 	R1, =GPIO_PORTF_CR 			; committed  Port F(0:7)
			MOV 	R0, #0xFF                  
			STR 	R0, [R1]
			LDR 	R1, =GPIO_PORTF_DIR 		; set direction of PF2
			LDR 	R0, [R1]
			BIC 	R0, R0, #0x11 				; clear bit4 and bit0 for input
			STR 	R0, [R1]
			LDR 	R1, =GPIO_PORTF_AFSEL 		; regular port function
			LDR 	R0, [R1]
			BIC 	R0, R0, #0x11
			STR 	R0, [R1]
			LDR 	R1, =GPIO_PORTF_AMSEL 		; disable analog
			LDR 	R0, [R1]
			BIC 	R0, R0, #0x11
			STR 	R0, [R1]
			LDR 	R1, =GPIO_PORTF_DEN 		; enable port digital
			LDR 	R0, [R1]
			ORR 	R0, R0, #0x11
			STR 	R0, [R1]
			LDR 	R1, =GPIO_PORTF_PUR_R		;pull ups on pins 0 and 4 of PORT F
			MOV 	R0, #0x11 					
			STR 	R0, [R1] 
			LDR 	R1, =GPIO_PORTF_IS
			LDR 	R2, =GPIO_PORTF_IBE 
			LDR 	R3, =GPIO_PORTF_IEV 
			LDR 	R4, =GPIO_PORTF_IM 
			LDR 	R5, =GPIO_PORTF_ICR 
				
			MOV 	R0, #0x00 
			STR 	R0, [R1]  					;PF is edge-sensitive 
			STR 	R0, [R2]  					;PF is not both edges 
			STR 	R0, [R3]  					;PF4&PF0 is falling edge 
			MOV 	R0, #0x11 					
			STR 	R0, [R4]  					;enable interrupt for PF4&PF0
			STR 	R0, [R5]  					;clear interrupt flag for PF4&PF0
			
			; Configure interrupt priorities
; Timer0A is interrupt #30.
; Interrupts 28-31 are handled by NVIC register PRI7.
; Interrupt 30 is controlled by bits 23:21 of PRI7.
; set NVIC interrupt 30 to priority 3
			LDR 	R1, =NVIC_PRI7
			LDR 	R2, [R1]
			AND 	R2, R2, #0xFF00FFFF ; clear interrupt 30 priority
			ORR 	R2, R2, #0x00600000 ; set interrupt 30 priority to 3
			STR 	R2, [R1]
; NVIC has to be enabled
; Interrupts 0-31 are handled by NVIC register EN0
; Interrupt 30 is controlled by bit 30
; enable interrupt 30 in NVIC
			LDR 	R1, =NVIC_EN0
			MOV		R0, #0
			MOVT 	R0, #0x4000 ; set bit 30 to enable interrupt 30
			LDR		R2, [R1]
			ORR		R2, R0
			STR 	R2, [R1]
			POP		{R0-R5}
			BX 		LR
			ALIGN
			END
			
			

