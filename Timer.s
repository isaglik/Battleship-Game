
;Nested Vector Interrupt Controller registers
NVIC_EN0_INT19		EQU 0x00080000 ; Interrupt 19 enable
NVIC_EN0			EQU 0xE000E100 ; IRQ 0 to 31 Set Enable Register
NVIC_PRI4			EQU 0xE000E410 ; IRQ 16 to 19 Priority Register
	
; 16/32 Timer Registers
TIMER0_CFG			EQU 0x40030000
TIMER0_TAMR			EQU 0x40030004
TIMER0_CTL			EQU 0x4003000C
TIMER0_IMR			EQU 0x40030018
TIMER0_RIS			EQU 0x4003001C ; Timer Interrupt Status
TIMER0_ICR			EQU 0x40030024 ; Timer Interrupt Clear
TIMER0_TAILR		EQU 0x40030028 ; Timer interval
TIMER0_TAPR			EQU 0x40030038
TIMER0_TAR			EQU	0x40030048 ; Timer register
	
;GPIO Registers
GPIO_PORTA_DATA		EQU	0x400043FC	; Port A Data
GPIO_PORTF_DIR 		EQU 0x40025400 ; Port Direction
GPIO_PORTF_AFSEL	EQU 0x40025420 ; Alt Function enable
GPIO_PORTF_DEN 		EQU 0x4002551C ; Digital Enable
GPIO_PORTF_AMSEL 	EQU 0x40025528 ; Analog enable
GPIO_PORTF_PCTL 	EQU 0x4002552C ; Alternate Functions

;System Registers
SYSCTL_RCGCGPIO 	EQU 0x400FE608 ; GPIO Gate Control
SYSCTL_RCGCTIMER 	EQU 0x400FE604 ; GPTM Gate Control

;SSI registers
SSI0_SR					EQU	0x4000800C

;---------------------------------------------------
second					EQU    62499		
;---------------------------------------------------
					
			AREA 	routines, CODE, READONLY
			THUMB
			EXPORT 	My_Timer0A_Handler
			EXPORT	timer_init
			EXTERN	SetXYNokia
			EXTERN	Out1BNokia
chronometer
		DCB		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3e, 0x51, 0x49, 0x45, 0x3e ;// 0
		DCB		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x42, 0x7f, 0x40, 0x00 ;// 1
		DCB		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x42, 0x61, 0x51, 0x49, 0x46 ;// 2
		DCB		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x21, 0x41, 0x45, 0x4b, 0x31 ;// 3
		DCB		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x14, 0x12, 0x7f, 0x10 ;// 4
		DCB		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x27, 0x45, 0x45, 0x45, 0x39 ;// 5
		DCB		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3c, 0x4a, 0x49, 0x49, 0x30 ;// 6
		DCB		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x71, 0x09, 0x05, 0x03 ;// 7
		DCB		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x36, 0x49, 0x49, 0x49, 0x36 ;// 8
		DCB		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x49, 0x49, 0x29, 0x1e ;// 9
		DCB		0x00, 0x42, 0x7f, 0x40, 0x00, 0x00, 0x3e, 0x51, 0x49, 0x45, 0x3e ;// 10
		DCB		0x00, 0x42, 0x7f, 0x40, 0x00, 0x00, 0x00, 0x42, 0x7f, 0x40, 0x00 ;// 11
		DCB		0x00, 0x42, 0x7f, 0x40, 0x00, 0x00, 0x42, 0x61, 0x51, 0x49, 0x46 ;// 12
		DCB		0x00, 0x42, 0x7f, 0x40, 0x00, 0x00, 0x21, 0x41, 0x45, 0x4b, 0x31 ;// 13
		DCB		0x00, 0x42, 0x7f, 0x40, 0x00, 0x00, 0x18, 0x14, 0x12, 0x7f, 0x10 ;// 14
		DCB		0x00, 0x42, 0x7f, 0x40, 0x00, 0x00, 0x27, 0x45, 0x45, 0x45, 0x39 ;// 15
		DCB		0x00, 0x42, 0x7f, 0x40, 0x00, 0x00, 0x3c, 0x4a, 0x49, 0x49, 0x30 ;// 16
		DCB		0x00, 0x42, 0x7f, 0x40, 0x00, 0x00, 0x01, 0x71, 0x09, 0x05, 0x03 ;// 17
		DCB		0x00, 0x42, 0x7f, 0x40, 0x00, 0x00, 0x36, 0x49, 0x49, 0x49, 0x36 ;// 18
		DCB		0x00, 0x42, 0x7f, 0x40, 0x00, 0x00, 0x06, 0x49, 0x49, 0x29, 0x1e ;// 19
		DCB		0x42, 0x61, 0x51, 0x49, 0x46, 0x00, 0x3e, 0x51, 0x49, 0x45, 0x3e ;// 20


;---------------------------------------------------					
My_Timer0A_Handler		
			CMP R11, #0
			BNE count
			MOV R11, #20
count			
		PUSH	{R0-R4,LR}
		MOV		R0,#72					; set X position to the right
		MOV		R1,#0					; and Y to the up 
		BL		SetXYNokia				; using setXY routine		
		LDR		R1,=GPIO_PORTA_DATA		; set PA6 high for Data
		LDR		R0,[R1]
		ORR		R0,#0x40
		STR		R0,[R1]
		LDR		R1,=chronometer				; load address of chronometer table

		MOV		R3,#0x0B       				; calculate offset of number
		MUL		R2,R11,R3
		ADD		R1,R1,R2
		PUSH	{R5}					; save state of R5
		MOV		R0,#0x0B				; 5 bytes in every char
sendByte		
		LDRB	R5,[R1],#1				;Out1BNokia takes 
		BL		Out1BNokia				; send each byte of number
		SUBS	R0,R0,#1
		BNE		sendByte
waitDone		
		LDR		R1,=SSI0_SR				; wait until SSI is done
		LDR		R0,[R1]
		ANDS	R0,R0,#0x10
		BNE		waitDone
		SUB		R11, #1			;To count 20 times
			
exit		LDR R1, =TIMER0_ICR  ;Clear the interrupt flags
			LDR R2, [R1]
			ORR R2, R2, #0x03
			STR R2, [R1]	
		POP		{R5}
		POP		{R0-R4,LR}	
			BX 	LR 
;---------------------------------------------------

timer_init	
			LDR R1, =SYSCTL_RCGCGPIO ; start GPIO clock
			LDR R0, [R1]
			ORR R0, R0, #0x20 ; set bit 5 for port F
			STR R0, [R1]
			NOP ; allow clock to settle
			NOP
			NOP
			LDR R1, =GPIO_PORTF_DIR ; set direction of PF2
			LDR R0, [R1]
			ORR R0, R0, #0x04 ; set bit2 for output
			STR R0, [R1]
			LDR R1, =GPIO_PORTF_AFSEL ; regular port function
			LDR R0, [R1]
			BIC R0, R0, #0x04
			STR R0, [R1]
			LDR R1, =GPIO_PORTF_PCTL ; no alternate function
			LDR R0, [R1]
			BIC R0, R0, #0x00000F00
			STR R0, [R1]
			LDR R1, =GPIO_PORTF_AMSEL ; disable analog
			MOV R0, #0
			STR R0, [R1]
			LDR R1, =GPIO_PORTF_DEN ; enable port digital
			LDR R0, [R1]
			ORR R0, R0, #0x04
			STR R0, [R1]
		
			LDR R1, =SYSCTL_RCGCTIMER ; Start Timer0
			LDR R2, [R1]
			ORR R2, R2, #0x01
			STR R2, [R1]
			NOP ; allow clock to settle
			NOP
			NOP
			LDR R1, =TIMER0_CTL ; disable timer during setup 
			LDR R2, [R1]
			BIC R2, R2, #0x01
			STR R2, [R1]
			LDR R1, =TIMER0_CFG ; set 16 bit mode
			MOV R2, #0x04
			STR R2, [R1]
			LDR R1, =TIMER0_TAMR
			MOV R2, #0x02 ; set to periodic, count down, edge count mode
			STR R2, [R1]
			LDR R1, =TIMER0_TAILR ; initialize match clocks
			LDR R2, =second			;62500*256=16 MHz
			STR R2, [R1]
			LDR R1, =TIMER0_TAPR
			MOV R2, #255 ; divide clock by 256 to
			STR R2, [R1] ; get 16us clocks
			LDR R1, =TIMER0_IMR ; enable timeout interrupt
			MOV R2, #0x01
			STR R2, [R1]
; Configure interrupt priorities
; Timer0A is interrupt #19.
; Interrupts 16-19 are handled by NVIC register PRI4.
; Interrupt 19 is controlled by bits 31:29 of PRI4.
; set NVIC interrupt 19 to priority 2
			LDR R1, =NVIC_PRI4
			LDR R2, [R1]
			AND R2, R2, #0x00FFFFFF ; clear interrupt 19 priority
			ORR R2, R2, #0x40000000 ; set interrupt 19 priority to 2
			STR R2, [R1]
; NVIC has to be enabled
; Interrupts 0-31 are handled by NVIC register EN0
; Interrupt 19 is controlled by bit 19
; enable interrupt 19 in NVIC
			LDR R1, =NVIC_EN0
			MOVT R2, #0x08 ; set bit 19 to enable interrupt 19
			STR R2, [R1]
; Enable timer
			LDR R1, =TIMER0_CTL
			LDR R2, [R1]
			ORR R2, R2, #0x03 ; set bit0 to enable
			STR R2, [R1] ; and bit 1 to stall on debug
			
;SET a counter for chronometer
			MOV R11, #20
			BX LR ; return
			END