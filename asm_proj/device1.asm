;**********************        ��������     ****************************
;r1:r0- ������������ ��� ��������� � �������
;r3:r2 - �������� ������������ � ������������� �� ������ ��� �0
;r5:r4 - �������� ������������ � ������������� �� ������ ��� �1
;r7:r6 - �������� ������������ � ������������� �� ������ ��� �2
;r9:r8 - �������� ������������ � ������������� �� ������ ��� �3
;r11:r10- �������� ������������ � ������������� �� ������ ������
;r13:r12- �������� ������������ � ������������� �� ������� ������
;r14 0-����� r15 (��� �����). 1...255 ���������� ������������ ����. 1=64��.
;r15 ���� ���������� �������� (1-��������� 0-������) � ����� �������������� ������
	;���0	��������� ����� ������� 1600��
	;���1	��������� ����� ������� 800��
	;���2	��������� ����� ������� 400��
	;���3	��������� ����� ������� 200��
	;���4	��������� ����� ������� 100��
	;���5   ����� �������� ������ � ���� 1,2 � 3 ������
	;���6	�������� �������� ������� LED
	;���7	�������� ���������� ������� LED
;==========================================
;r16-���������
;r17-���������
;r18-���������
;r19-���������
;r20-���������
;r21-���������
;r22-���� �������� �����������
;r23-������� �������� ����������������� �����. 1 ���������=512���
;r24-���������
;r25-���������
;r26 - ����� ���������� ��������� 0 ������;
	;��� 0 -�������� ���������
	;��� 1 -����� � ��������� ����� (0-����� 1-��� �����)
	;��� 2 -������� ���������� ����� �������
	;��� 3 -������� ���� ����� �������
	;��� 4 -�� ��������� ���������� ������������ (0� -  1� +)
	;��� 5 -�� ��������� ����������� ���� (0� -  1� +)
	;��� 6 -�� ��������� ����������� ���� (0� -  1� +)
	;��� 7 -��������
;r27 - ����� ���������� ��������� 1 ������;
;r28-���������
;r29-���������
;r30-���������
;r31-���������
.equ	Int_Mask_Outside=0b10011010
.equ	Int_Mask_Inside= 0b00000010

.dseg	;***************************  RAM  ************************************
.org $0060
DACstate:	.byte 1	;��������� ������� ������-���;$0060
keystate:	.byte 1	;��������� ������ 1-8 (0 - ������ 1 - ������)
keynew:		.byte 1  ;����� ������ 1-8 ���������� ���� ��������� (1-���, 0-������)
keytime:	.byte 1	;������� ������� ���������� ������ 1-8. 1���=16
;��������� BCD � ������������� ���� ���������� (3 � ������� ������)
bcdres0:	.byte 1	;$0064	0-� ������ 
bcdres1:	.byte 1 ;$0065  1-������ BCDB
bcdres2:	.byte 1 ;$0066	2-������ BCDB
bcdres3:	.byte 1 ;$0067	3-������ BCDW
bcdres4:	.byte 1 ;$0068	4-������ BCDW
kanal:		.byte 1 ;-����� ������ ($006A...$006F) ��� ������ ��� (�� ���� ��� ����� ���) 
DACdata0:	.byte 1 ;- �������: ���������� ������������ ����� 0 (��� �0)
DACdata1:	.byte 1	;- �������: ���������� ������������ ����� 0 (��� �1)
DACdata2:	.byte 1 ;- �������: ���������� ������������ ����� 1 (��� �2)
DACdata3:	.byte 1 ;- �������: ���������� ������������ ����� 1 (��� �3)
amper0:		.byte 1 ;- ����� �������� ���� ����� 0 (��� �4)
amper1:		.byte 1 ;- ����� �������� ���� ����� 1 (��� �5)
param0:	.byte 12 ;- �������� �0-10.2 ������ 0 (�� $0070 �� $007B ������������)
;0	���� ���� ���� 			0...128 (5.12��)
;+1 ������� �� ����			0...9	(100%)
;+2 ������� �� ���������   	2...200 (20��)
;+3 ���� ����������� ����  	0...128 (5.12��)
;+4 ������� ���������		10..249 (99.6��)
;+5 ������������ ��������	20..249 (9.96��)
;+6 �������� ������� ��		0...63  (25.2��)
;+7 ������������ �������	10..249 (9.96��)
;+8 ������� �� ���			0...9	(100%)
;+9 ������� �� �����������	2...200	 (20��)
;+10	������				0...99
;+11	������� 			0...59
sec0:	.byte 1	;- ������� ������� ����� 0 ($007C)
min0:	.byte 1	;- ������� ������ ����� 0
sec1:	.byte 1	;- ������� ������� ����� 1
min1:	.byte 1	;- ������� ������ ����� 1
param1:	.byte 12 ;- �������� �0-10.2 ������ 1 (�� $0080 �� $008B ������������)

.org $008C	
.byte 4	;��������
am_data0:
	.byte 1	;0 -������� ������ ������� ��� �0 ��� ��
	.byte 1	;+1-������ ������ ������� ��� �0 ��� ��
	.byte 2 ;+3:+2 -���������� ������������ �� 1 ���� ������������
am_data1:	.byte 4
am_data2:	.byte 4
am_data3:	.byte 4
fm_data0:
	.byte 1	; 0 -������� ������ �������� ������� (63)
	.byte 1	;+1-������ ������ �������� �������  (-63)
	.byte 2 ;+3:+2 -���������� ������������ �� 1 ���� ������������
	.byte 1 ;+4 ���������� �������� �������� (�� ������) +63...-63
	.byte 1 ;+5 ����������� ������� (����� param +4)
	.byte 2 ;+7:+6 ���������� ������� ��� ������������ ��������
fm_data1:	.byte 8

RTC:		.byte 1	;Real Time Counter-���������� ������� ������� �� ������ 125.+4 ������ 32��. 125imp=1���

.cseg	;******************      ���������        ***********************
.include "m8535def.inc"
; ������������ 8���

 	rjmp 	RESET 		;Reset Handler
 	reti	 			;EXT_INT0 	; IRQ0 Handler
 	reti	 			;EXT_INT1 	; IRQ1 Handler
 	rjmp	TIM2_COMP 	;Timer2 Compare Handler
 	reti				;Timer2 Overflow Handler
 	reti	 			;TIM1_CAPT 	; Timer1 Capture HaWGM00 6 51ndler
 	rjmp 	TIM1_COMPA 	;Timer1 Compare A Handler
 	rjmp	TIM1_COMPB 	;Timer1 Compare B Handler
 	reti	 			;TIM1_OVF 	; Timer1 Overflow Handler
 	reti 				;TIM0_OVF 	; Timer0 Overflow Handler
 	reti				;SPI_STC 	; SPI Transfer Complete Handler
 	reti	 			;USART_RXC 	; USART RX Complete Handler
 	reti	 			;USART_UDRE 	; UDR Empty Handler
 	reti	 			;USART_TXC 	; USART TX Complete Handler
 	rjmp 	ADC_CC 		;ADC Conversion Complete Handler
 	reti	 			;EE_RDY 		; EEPROM Ready Handler
 	reti	 			;ANA_COMP 	; Analog Comparator Handler
 	reti	 			;TWSI 		; Two-wire Serial Interface Handler
 	reti	 			;EXT_INT2 	; IRQ2 Handler
 	rjmp	TIM0_COMP 	;Timer0 Compare Handler
 	reti	 			;SPM_RDY 	; Store Program Memory Ready Handler


;-----------------------------------------------
;���������� �� ������������ �������� ������ 0
;������������ 338 ���� �� ������� ����� ��� 44 �� ������� ��������
;������� �����=5*62500/(����� ����+����� ��������)
;��� ��������� ������������ ����� ������� ������ >=5�� (2��)
;��������� �� ������ ���������� Fmin=Fi-DFi < 5 ��
;����� ������ ���� ��� ������� �������� �� ������������ �������
;����<=1/2(Fi+DFi). ������ � ��^ Timp<=31250/(Fi+DFi) - ������ ��������� ��������� ���������
;������������ ������� ������ ���� �������� ������ Fmin=Fi-DFi
;������� ������� 5���������(*64) �� ������ 0,04��
;-----------------------------------------------
TIM1_COMPB:
	push	r16
	in		r16,sreg
	push	r16
	push	r17
	push	r18
	push	r19
	push	r0
	push	r1
	sbis	PIND,4		;���������� ���� �������� �����(��� OC1B=1)
	rjmp	CH1_Signal_1
;������������� ������ �����
	
	ldi 	r16,Int_Mask_Inside
	out 	TIMSK,r16
	sei		;��������� ���������� ������ �� ���������� �0
		
	lds		r16,fm_data0+5	;����������� �������
	lds		r17,fm_data0+4	;���������� ��������
	sbrs	r17,7			;�������� ������������ ? - �������
	rjmp	CH1_PositivDirect_Deviation
	neg		r17
	sub		r16,r17			;r16=������� �������=�����-��������
	clr		r17
	rjmp	CH1_timing_calculate
CH1_PositivDirect_Deviation:
	add		r16,r17
	clr		r17
	adc		r17,r17		;r17:r16=����� ����+����� ��������
CH1_timing_calculate:
	ldi		r19,high(62500)
	ldi		r18,low(62500)
	movw	r0,r18
	rcall	divide16	;r19:r18=62500/(����� ����+����� ��������)
	movw	r16,r18
	lsl		r18
	rol		r19		;*2
	lsl		r18
	rol		r19		;*4
	add		r16,r18
	adc		r17,r19	;r17:r16=5*62500/(����� ����+����� ��������)
	lds		r18,fm_data0+6	;������������ ��������
	lds		r19,fm_data0+7
	sub		r16,r18
	sbc		r17,r19		;������������ �����=������-������������ ��������

	cli
	ldi 	r18,Int_Mask_Outside
	out 	TIMSK,r18

	rjmp	OCR1B_Modified
CH1_Signal_1:				;������� ������� �������
	lds		r16,fm_data0+6	;����������	
	lds		r17,fm_data0+7
OCR1B_Modified:
	in		r18,OCR1BL		;���������� ��������	
	in		r19,OCR1BH
	add		r18,r16
	adc		r19,r17			;����� ��������
	out		OCR1BH,r19
	out		OCR1BL,r18		;��������� � �������� ���������
	pop		r1
	pop		r0
	pop		r19
	pop		r18
	pop		r17
	pop		r16
	out		sreg,r16
	pop		r16
reti

;-----------------------------------------------
;���������� �� ������������ �������� ������ 1
;-----------------------------------------------
TIM1_COMPA:
	push	r16
	in		r16,sreg
	push	r16
	push	r17
	push	r18
	push	r19
	push	r0
	push	r1
	sbis	PIND,5		;���������� ���� �������� �����(��� OC1A=1)
	rjmp	CH2_Signal_1
;������������� ������ �����
	
	ldi 	r16,Int_Mask_Inside
	out 	TIMSK,r16
	sei		;��������� ���������� ������ �� ���������� �0
		
	lds		r16,fm_data1+5	;����������� �������
	lds		r17,fm_data1+4	;���������� ��������
	sbrs	r17,7			;�������� ������������ ? - �������
	rjmp	CH2_PositivDirect_Deviation
	neg		r17
	sub		r16,r17			;r16=������� �������=�����-��������
	clr		r17
	rjmp	CH2_timing_calculate
CH2_PositivDirect_Deviation:
	add		r16,r17
	clr		r17
	adc		r17,r17		;r17:r16=����� ����+����� ��������
CH2_timing_calculate:
	ldi		r19,high(62500)
	ldi		r18,low(62500)
	movw	r0,r18
	rcall	divide16	;r19:r18=62500/(����� ����+����� ��������)
	movw	r16,r18
	lsl		r18
	rol		r19		;*2
	lsl		r18
	rol		r19		;*4
	add		r16,r18
	adc		r17,r19	;r17:r16=5*62500/(����� ����+����� ��������)
	lds		r18,fm_data1+6	;������������ ��������
	lds		r19,fm_data1+7
	sub		r16,r18
	sbc		r17,r19		;������������ �����=������-������������ ��������

	cli
	ldi 	r18,Int_Mask_Outside
	out 	TIMSK,r18

	rjmp	OCR1A_Modified
CH2_Signal_1:				;������� ������� �������
	lds		r16,fm_data1+6	;����������	
	lds		r17,fm_data1+7
OCR1A_Modified:
	in		r18,OCR1AL		;���������� ��������	
	in		r19,OCR1AH
	add		r18,r16
	adc		r19,r17			;����� ��������
	out		OCR1AH,r19
	out		OCR1AL,r18		;��������� � �������� ���������
	pop		r1
	pop		r0
	pop		r19
	pop		r18
	pop		r17
	pop		r16
	out		sreg,r16
	pop		r16
reti

;-----------------------------------------------
;������� ���������� ��� �������� ���������
;������ ������ 64��� (512 ������)
;������������ 146 ������ ��������
;-----------------------------------------------
TIM0_COMP:
		push	r16
		in		r16,sreg
		push	r16
		push	r17

;------------ �������� ��������� ������ ������ -----------------
		ldi		r16,0b00001111	;��������� ���������, �����, ������� ����/����
		and		r16,r26
		cpi		r16,0b00000011
		breq	_Start_DAC0
		rjmp	_Start_RightCH

_Start_DAC0:	;����� ����� �������
;------   ��   ���  ���  �0  -------------------
		lds		r16,am_data0+2	;���������� �������� ��������
		lds		r17,am_data0+3
		add		r2,r16			;�������������� ��������
		adc		r3,r17
		brcc	_Start_DAC1		;�� ��������� ��������� ������� ���0 - ������� � ���1
		sbrs	r26,4			;��� ��c � + ���������� ? - �������
		rjmp	_AMDown0		;�� ���������� - ��������� ����
		;��������� �����
		lds		r16,DACdata0	;������� �������� ������� ���
		lds		r17,am_data0	;������� ������
		cpse	r16,r17			;�������� ������� � ������� ��������
		rjmp	_NoUpLim0		;�� ��������� ����
		cbr		r26,16			;���������� �����������-������� ����������� ���������
		rjmp	_Start_DAC1
_NoUpLim0:		;�� ����������  ����������� �����
		inc		r16				
		sts		DACdata0,r16	;���� ��� ������� ���
		rjmp	_Start_DAC1
_AMDown0:	;��������� ����
		lds		r16,DACdata0
		lds		r17,am_data0+1	;������ ������
		cpse	r16,r17			;�������� � ������ ��������
		rjmp	_NoDownLim0		;�� ���������� �����������
		sbr		r26,16			;���������� - ���������� ����������� ��������� �����
		rjmp	_Start_DAC1
_NoDownLim0:	;�� ����������  �����������
		dec		r16
		sts		DACdata0,r16	;���� ��� ������� ���

;------   ��   ���  ���  �1  -------------------
_Start_DAC1:	;�� � ������ ��� �1
		lds		r16,am_data1+2	;���������� �������� ��������
		lds		r17,am_data1+3
		add		r4,r16			;�������������� ��������
		adc		r5,r17
		brcc	_Start_FM0		;�� ��������� ��������� ������� ���
		sbrs	r26,5			;��� ��� � + ���������� ? - �������
		rjmp	_AMDown1		;�� ���������� - ��������� ����
		;��������� �����
		lds		r16,DACdata1	;������� �������� ������� ���
		lds		r17,am_data1	;������� ������
		cpse	r16,r17			;�������� ������� � ������� ��������
		rjmp	_NoUpLim1		;�� ��������� ����
		cbr		r26,32			;���������� �����������-������� ����������� ���������
		rjmp	_Start_FM0
_NoUpLim1:	;�� ����������  �����������
		inc		r16				
		sts		DACdata1,r16	;���� ��� ������� ���
		rjmp	_Start_FM0
_AMDown1:	;��������� ����
		lds		r16,DACdata1
		lds		r17,am_data1+1	;������ ������
		cpse	r16,r17			;�������� � ������ ��������
		rjmp	_NoDownLim1		;�� ���������� �����������
		sbr		r26,32			;���������� - ���������� ����������� ��������� �����
		rjmp	_Start_FM0
_NoDownLim1:	;�� ����������  �����������
		dec		r16
		sts		DACdata1,r16	;���� ��� ������� ���

;------   ��   � ����� ������   -------------------
_Start_FM0:	;FM � ������ 0	
		lds		r16,fm_data0+2	;���������� �������� ��������
		lds		r17,fm_data0+3
		add		r10,r16			;�������������� ��������
		adc		r11,r17
		brcc	_Start_RightCH	;�� ��������� ��������� ����� ������� ������� �1 
		sbrs	r26,6			;��� FM � + ���������� ? - �������
		rjmp	_FMDown0		;�� ���������� - ��������� ���� �� �������
		;��������� ����� �� �������
		lds		r16,fm_data0+4	;������� �������� �������� �������
		lds		r17,fm_data0	;������� ������
		cpse	r16,r17			;�������� ������� � ������� ��������
		rjmp	_NoUpFMLim0		;�� ��������� ����
		cbr		r26,64			;���������� �����������-������� ����������� ���������
		rjmp	_Start_RightCH
_NoUpFMLim0:	;�� ����������  ����������� �������� �����
		inc		r16				
		sts		fm_data0+4,r16	;��������� ������� ��������
		rjmp	_Start_RightCH
_FMDown0:		;��������� ����
		lds		r16,fm_data0+4	;������� �������� �������� �������
		lds		r17,fm_data0+1	;������ ������
		cpse	r16,r17			;�������� � ������ ��������
		rjmp	_NoDownFMLim0	;�� ���������� �����������
		sbr		r26,64			;���������� - ���������� ����������� ��������� �����
		rjmp	_Start_RightCH
_NoDownFMLim0:	;�� ����������  �����������
		dec		r16
		sts		fm_data0+4,r16	;��������� ������� ��������
		
		
_Start_RightCH:	

;------------ �������� ��������� ������� ������ -----------------
		ldi		r16,0b00001111	;��������� ���������, �����, ������� ����/����
		and		r16,r27
		cpi		r16,0b00000011
		breq	_Start_DAC2
		rjmp	_ENDI
;------   ��   ���  ���  �2  -------------------
_Start_DAC2:	;�� � ������ ��� �2
		lds		r16,am_data2+2	;���������� �������� ��������
		lds		r17,am_data2+3
		add		r6,r16			;�������������� ��������
		adc		r7,r17
		brcc	_Start_DAC3		;�� ��������� ��������� ������� ���
		sbrs	r27,4			;��� ��c � + ���������� ? - �������
		rjmp	_AMDown2		;�� ���������� - ��������� ����
		;��������� �����
		lds		r16,DACdata2	;������� �������� ������� ���
		lds		r17,am_data2	;������� ������
		cpse	r16,r17			;�������� ������� � ������� ��������
		rjmp	_NoUpLim2		;�� ��������� ����
		cbr		r27,16			;���������� �����������-������� ����������� ���������
		rjmp	_Start_DAC3
_NoUpLim2:		;�� ���������� ����������� ����
		inc		r16				
		sts		DACdata2,r16	;���� ��� ������� ���
		rjmp	_Start_DAC3
_AMDown2:	;��������� ����
		lds		r16,DACdata2
		lds		r17,am_data2+1	;������ ������
		cpse	r16,r17			;�������� � ������ ��������
		rjmp	_NoDownLim2		;�� ���������� �����������
		sbr		r27,16			;���������� - ���������� ����������� ��������� �����
		rjmp	_Start_DAC3
_NoDownLim2:	;�� ����������  �����������
		dec		r16
		sts		DACdata2,r16	;���� ��� ������� ���

;------   ��   ���  ���  �3  -------------------
_Start_DAC3:	;�� � ������ ��� �3
		lds		r16,am_data3+2	;���������� �������� ��������
		lds		r17,am_data3+3
		add		r8,r16			;�������������� ��������
		adc		r9,r17
		brcc	_Start_FM1		;�� ��������� ��������� ������� ���
		sbrs	r27,5			;��� ��� � + ���������� ? - �������
		rjmp	_AMDown3		;�� ���������� - ��������� ����
		;��������� �����
		lds		r16,DACdata3	;������� �������� ������� ���
		lds		r17,am_data3	;������� ������
		cpse	r16,r17			;�������� ������� � ������� ��������
		rjmp	_NoUpLim3		;�� ��������� ����
		cbr		r27,32			;���������� �����������-������� ����������� ���������
		rjmp	_Start_FM1
_NoUpLim3:	;�� ����������  ����������� ����
		inc		r16				
		sts		DACdata3,r16	;���� ��� ������� ���
		rjmp	_Start_FM1
_AMDown3:	;��������� ����
		lds		r16,DACdata3
		lds		r17,am_data3+1	;������ ������
		cpse	r16,r17			;�������� � ������ ��������
		rjmp	_NoDownLim3		;�� ���������� �����������
		sbr		r27,32			;���������� - ���������� ����������� ��������� �����
		rjmp	_Start_FM1
_NoDownLim3:	;�� ����������  �����������
		dec		r16
		sts		DACdata3,r16	;���� ��� ������� ���				

_Start_FM1:

;------   ��   � ������ ������   -------------------
		lds		r16,fm_data1+2	;���������� �������� ��������
		lds		r17,fm_data1+3
		add		r12,r16			;�������������� ��������
		adc		r13,r17
		brcc	_ENDI			;�� ��������� ��������� ����� ������� ������� �1 
		sbrs	r27,6			;��� FM � + ���������� ? - �������
		rjmp	_FMDown1		;�� ���������� - ��������� ���� �� �������
		;��������� ����� �� �������
		lds		r16,fm_data1+4	;������� �������� �������� �������
		lds		r17,fm_data1	;������� ������
		cpse	r16,r17			;�������� ������� � ������� ��������
		rjmp	_NoUpFMLim1		;�� ��������� ����
		cbr		r27,64			;���������� �����������-������� ����������� ���������
		rjmp	_ENDI
_NoUpFMLim1:	;�� ����������  ����������� �������� �����
		inc		r16				
		sts		fm_data1+4,r16	;��������� ������� ��������
		rjmp	_ENDI
_FMDown1:		;��������� ����
		lds		r16,fm_data1+4	;������� �������� �������� �������
		lds		r17,fm_data1+1	;������ ������
		cpse	r16,r17			;�������� � ������ ��������
		rjmp	_NoDownFMLim1	;�� ���������� �����������
		sbr		r27,64			;���������� - ���������� ����������� ��������� �����
		rjmp	_ENDI
_NoDownFMLim1:	;�� ����������  �����������
		dec		r16
		sts		fm_data1+4,r16	;��������� ������� ��������

_ENDI:
		pop		r17
		pop		r16
		out		sreg,r16
		pop		r16
		reti

;------------------------------------------------------------
ADC_CC:
;������ ������ ������ ��� ��� ���������� �������
;kanal �������� � ������� ��� �������� ������ ����� ��������������
	push	r16
	in		r16,sreg
	push	r16
	push	r17
	push	r18
	push	r29
	push	r28
	lds		r28,kanal
	in		r16,PINB	;������ ��������� ����� B
	andi	r16,$0F		;�������� B4...B7
	lds		r18,DACstate
	or		r18,r16		;������ � r18 ���� ��������� ������� ����� B
	ldi		r16,$FF		;���� B ��� ������
	out		DDRB,r16

	ldi 	r16,Int_Mask_Inside
	out 	TIMSK,r16
	sei		;��������� ���������� ������ �� ���������� �0
	
	dec		r28			;������ ������ ������ ��� ������ � ����������� ���
	cpi		r28,DACdata0
	brsh	CnanNumModuloDown		;����� �� ������������� ? (>=DACdata0)
	subi	r28,256-6	;���� ������������� �� +6
CnanNumModuloDown:
	clr		r29
	ld		r16,Y		;�������� �������
	in		r17,ADCH	;�������� ����� ����������	
	cp		r17,r16		;���� < ������� ? - ��������� ����� C=1
	in		r16,sreg	;���������� SREG
	bst		r16,0		;��������� � �� ����� �
	cpi		r28,DACdata0		;��� ����� 0 ?
	breq	ChanIs1
	cpi		r28,DACdata1		;��� ����� 1 ?
	breq	ChanIs2
	cpi		r28,DACdata2		;��� ����� 2 ?
	breq	ChanIs3
	cpi		r28,DACdata3		;��� ����� 3 ?
	breq	ChanIs4
	st		Y,r17		;��� ������� 4 � 5 ��������� ��������� ���
	rjmp	EndSelectChanDAC
ChanIs1:
	bld		r18,4		;����<������� - ������4=1. �����=0
	dec		r23			;���������������� ������ �� ���������� 4000/32/13/6=1600��
	mov		r16,r15		;������� ����� �������� �����
	and		r16,r23		;�������� ���������� ��� ����� ����
	andi	r16,0b00011111	;����������� ���������� ����
	breq	Buzzer_Low
	sbi		PORTA,7		;����� �� ������
	rjmp	Buzzer_High
Buzzer_Low:	
	cbi		PORTA,7		;���� �� ������	
Buzzer_High:
	rjmp	EndSelectChanDAC
ChanIs2:
	bld		r18,5		;����<������� - ������5=1. �����=0
	rjmp	EndSelectChanDAC				
ChanIs3:
	bld		r18,6		;����<������� - ������6=1. �����=0
	rjmp	EndSelectChanDAC
ChanIs4:
	bld		r18,7		;����<������� - ������7=1. �����=0
EndSelectChanDAC:
	inc		r28
	inc		r28
	cpi		r28,amper1+1
	brlo	CnanNumModuloUp		
	subi	r28,6
CnanNumModuloUp:
	mov		r16,r28
	subi	r16,DACdata0
	ori		r16,32
	out		ADMUX,r16
	out		PORTB,r18
	sbi		PORTB,3		
	nop
	cbi		PORTB,3			;�������� � ������� 74HC573
	ldi		r16,0b00001111	;B0..B3 ������ B4...B7 �����(����� ������������ �������)
	out		DDRB,r16		;���� �
	ldi		r16,$F0			;������������� ��������� B4...B7 ��������
	or		r16,r18			;������������ B0..B3			;
	out		PORTB,r16
	ldi		r16,$F0
	and		r18,r16			;�������� � r18 ������ ���������� � ������� ���
	sts		kanal,r28
	sts		DACstate,r18

	cli
	ldi 	r16,Int_Mask_Outside
	out 	TIMSK,r16

	pop		r28
	pop		r29
	pop		r18
	pop		r17
	pop		r16
	out		sreg,r16
	pop		r16
	reti


;------------------------------------------------------------
TIM2_COMP:
;����������� 128���*250=32��  (30,4��� � ���)
;������������ ������������ ???
;������� �������� ������ ������������ ���� RTC
;��� ���������� 0 ���� ����������� �� 31 (��� �����)
;���� �������� ������ ������� ��������� �������� �������.
;��� ���������� 0 ��������� ���� ���������� ��������� � ��������������� ������ 
;------------------------------------------------------------
;����� ���������� 30 ��� � ��� (������ 32���)
		cbi		PORTD,0
		sbi		PORTD,1
		sbi		PORTD,2		;1-� ����� ������
;���������� ��������� ������� ������������ ��� �������� �� 9 ������
		push	r16
		in		r16,sreg
		push	r16
		push	r17
		push	r18

		in		r17,PINB	;����� ������� ������� 
		swap	r17			;��������� � ������� �������
		andi	r17,$0F		;�������� ������� �������
		sbi		PORTD,0		;2-� ����� ������	
		cbi		PORTD,2
;�������� �� ���������� ������������� ���� ������� ������������ ��� �������� �� 3 ����
		dec		r14			;������ ������������ ����
		brne	soundon		;���� �� ����������� - �������
		ldi		r16,0b11100000	;����������� - �������������
		and		r15,r16			;����
soundon:
		nop
		nop
		nop
		in		r18,PINB	;����� ������� �������
		andi	r18,$F0		;�������� ������� �������
		or		r17,r18		;������ � r17 8 ������
		lds		r18,keystate;�������� ���������� �������� ������
		eor		r18,r17		;���������� ��������� ������ ����� 1
		sts		keystate,r17;�������� ������� ��������� �������
		sts		keynew,r18	;�������� ����� ������, ���������� ���� ���������
		or		r17,r18		;�������� ���������� ������ �� �����������
		lds		r18,keytime	;������� ������� ������� ��������� ������
		cpi		r17,$FF		;���� ������ ��� FF, �� ������ ������� ��������� �������
		brne	Key_Is_Drop		;��������e ? - �������
		clr		r18			;�������� ������� ������� ���������
		rjmp	endkb
Key_Is_Drop:
		sbrs	r18,5		;������ 32 ����� ?(1���)
		inc		r18			;�� ������ - ��������� ������ - �������
endkb:						;������
		sts		keytime,r18		;��������� �������� �������� �� �����
		sbi		PORTD,2

		ldi 	r16,Int_Mask_Inside
		out 	TIMSK,r16
		sei		;��������� ���������� ������ �� ���������� �0

;������ ������� ���������� � ������
		clt	;�������� ���� � ��� ������� ���������� �������� �����
		sbrs	r26,3		;�������� ���������� �������� ����� ����� 0
		rjmp	CH0_analis_of_Growth		;��������� - �������
		lds		r16,DACdata0	;������� � ������ �������
		tst		r16			;=0?
		breq	DAC_CH0_Is0	;=0 - �������
		dec		r16
		set
		sts		DACdata0,r16
DAC_CH0_Is0:
		lds		r16,DACdata1	;������� � ������ �������
		tst		r16			;=0?
		breq	DAC_CH1_Is0		;=0 - �������
		dec		r16
		set
		sts		DACdata1,r16
DAC_CH1_Is0:
		brts	CH0_analis_of_Growth	;���� ��� ����-�� 1 ������� ����, �� �������
		andi	r26,0b11110111	;�� ���� ������ - ����� ����� �������� �����

CH0_analis_of_Growth:	
		clt		;������� ���� � ��� ������� ���������� �������� �����
		sbrs	r26,2		;�������� ���������� �������� ����� ����� 0
		rjmp	CH2_analis_Decline		;��������� - �������
		lds		r16,DACdata0	;������� � ������ �������
		lds		r17,param0	;�������� �������
		cp		r16,r17		;r16 �������� � r17  ?
		brsh	DAC_CH0_IsMax		;r16>=r17 - �������
		inc		r16			;r16<r17 (���������)
		set					;�������� ���� � ��� "������� ���� �� ��������"
		sts		DACdata0,r16
DAC_CH0_IsMax:
		lds		r16,DACdata1	;������� � ������ �������
		lds		r17,param0+3;�������� �������
		cp		r16,r17		;r16 �������� � r17  ?
		brsh	DAC_CH1_IsMax		;r16>=r17 - �������
		inc		r16			;r16<r17 (���������)
		set					;�������� ���� � ��� "������� ���� �� ��������"
		sts		DACdata1,r16
DAC_CH1_IsMax:
		brts	CH2_analis_Decline		;���� ��� ����-�� 1 ������� ����, �� �������
		andi	r26,0b11111011	;�� ���� ������ - ����� ����� �������� �����
CH2_analis_Decline:
		clt	;�������� ���� � ��� ������� ���������� �������� �����
		sbrs	r27,3		;�������� ���������� �������� ����� ����� 1
		rjmp	CHR_analis_of_Growth		;��������� - �������
		lds		r16,DACdata2		;������� � ������ �������
		tst		r16			;=0?
		breq	DAC_CH2_Is0		;=0 - �������
		dec		r16
		set
		sts		DACdata2,r16
DAC_CH2_Is0:
		lds		r16,DACdata3		;������� � ������ �������
		tst		r16			;=0?
		breq	DAC_CH3_Is0		;=0 - �������
		dec		r16
		set
		sts		DACdata3,r16
DAC_CH3_Is0:
		brts	CHR_analis_of_Growth	;���� ��� ����-�� 1 ������� ����, �� �������
		andi	r27,0b11110111	;�� ���� ������ - ����� ����� �������� �����
CHR_analis_of_Growth:
		clt		;������=�� ���� � ��� ������� ���������� �������� �����
		sbrs	r27,2		;�������� ���������� �������� ����� ����� 1
		rjmp	Ltim_16		;��������� - �������
		lds		r16,DACdata2	;������� � ������ �������
		lds		r17,param1		;�������� �������
		cp		r16,r17		;r16 �������� � r17  ?
		brsh	Ltim_14		;r16>=r17 - �������
		inc		r16			;r16<r17 (���������)
		set
		sts		DACdata2,r16
Ltim_14:
		lds		r16,DACdata3	;������� � ������ �������
		lds		r17,param1+3;�������� �������
		cp		r16,r17		;r16 �������� � r17  ?
		brsh	Ltim_13		;r16>=r17 - �������
		inc		r16			;r16<r17 (���������)
		set
		sts		DACdata3,r16
Ltim_13:
		brts	Ltim_16		;���� ��� ����-�� 1 ������� ����, �� �������
		andi	r27,0b11111011	;�� ���� ������ - ����� ����� �������� �����
Ltim_16:

;������� ��������� ��� ������������ ��������� ����������
		ldi		r18,256-4
		lds		r16,RTC
		bst		r16,3		;�������� �������� �������
		bld		r15,6		;��������� � r15.6
		bst		r16,6		;�������� ���������� �������
		bld		r15,7		;��������� � r15.7
		sub		r16,r18		;������ ��������� ���������� (+4)
		ldi		r18,125
		cp		r16,r18		;�� ������ 1 ��� ?
		sts		RTC,r16
		brlo	run125		;�������
		sub		r16,r18		;������ 1 ��� - �������
		sts		RTC,r16
;�������� ������ � ��������		
		sbrs	r26,1		;��������� � 0 ������ �� �� �����?
		rjmp	kan2		;����� ������� - �������
		;��������� ������ ������ ������ �� 1 ���
		lds		r16,sec0	;��������� ������� �������
		lds		r17,min0
		subi	r16,1		;���������� �� ������� ������� � ������ 0
		brsh	kan1end		;������� �� ������� ���� ? -�������
		ldi		r16,59		;������� - ���������� 59 ������
		sbci	r17,0		;������� ������ (��� ������� � ��������)
		brsh	kan1end		;� ������� ��� �������� - �������
		ldi		r26,0b00001000	;��������� ���� � �����, ������� ����
		ldi		r18,10			;320����
		mov		r14	,r18
		set
		bld		r15,0			;������� 1600��

kan1end:
		sts		sec0,r16	;������� ����������� ������� �������
		sts		min0,r17
kan2:
		sbrs	r27,1		;��������� � 1 ������ �� �� �����?
		rjmp	run125		;����� ������� - �������	
		;��������� ������ ������� ������ �� 1 ��� 
		lds		r16,sec1	;r16-������� r17-������ ������ 1
		lds		r17,min1
		subi	r16,1		;���������� �� ������� ������� � ������ 1
		brsh	kan2end		;������� �� ������� ���� ? -�������
		ldi		r16,59		;������� - ���������� 59 ������
		sbci	r17,0		;������� ������ (��� ������� � ��������)
		brsh	kan2end		;� ������� ��� �������� - �������
		ldi		r27,0b00001000	;��������� ���� � �����, ������� ����
		ldi		r18,10		;320����
		mov		r14	,r18
		set
		bld		r15,0			;������� 1600��
kan2end:
		sts		sec1,r16		;������� ����������� ������� �������
		sts		min1,r17
run125:	
		cli
		ldi 	r16,Int_Mask_Outside
		out 	TIMSK,r16

		pop		r18
		pop		r17
		pop		r16
		out		sreg,r16
		pop		r16
		reti


;**********************************************************************************************
;----------------------------------------------------------------------------------------------
;                                �������� ���������
;----------------------------------------------------------------------------------------------
;**********************************************************************************************
RESET:	
		ldi 	r16,high(ramend) 
		out	 	SPH,r16 	  	; Set Stack Pointer to top of RAM
		ldi 	r16,low(ramend)
		out 	SPL,r16

		ldi		r16,0b00100000	;����� 0, ������������ �����, ������� ���
		out		ADMUX,r16		;���
		in		r16,SFIOR
		andi	r16,0b00011111	;������� ������� ADTS �������� SFIOR
		out		SFIOR,r16
		ldi		r16,0b11101110	;����������� f=8000/64=125���. ������ �����
		out		ADCSRA,r16		;��������� ���

		ldi 	r16,Int_Mask_Outside 	;���������� �0,T1A,T1B,T2
		out 	TIMSK,r16		;���������

		ldi 	r16,0b00001010	;clk/8(T=1us) ����� ��� ����������
		out 	TCCR0,r16		;��������� ������� T0
		ldi		r16,64			;1���*64=64��� (������ 512 ������)
		out		OCR0,r16

		ldi 	r16,0b00001111	;T=1/(8*10^6*1024)=128us , CTC
		out 	TCCR2,r16		;��������� ������� T2
		ldi		r16,249			;128us*250=32����
		out		OCR2,r16

		
		ldi		r16,0b00000000	;normal,�������� �� OCC1B � OCC1A (����� �������� OCC1B � OCC1A 0b01010000)
		out 	TCCR1A,r16		;��������� ������� T1
		ldi		r16,0b00000011	;�1 ������ � 8�6/64=125���,normal,
		out 	TCCR1B,r16	
		clr		r16				;��������
		out 	OCR1AH,r16		;���������
		out 	OCR1AL,r16		;��������
		out 	OCR1BH,r16		;���������
		out 	OCR1BL,r16		;���������
		
		ldi		r16,0b11000000	;A0...A5 ����� A6 A7 ������
		out		DDRA,r16		;���� �
		ldi		r16,0b00000000	;������������� ���������
		out		PORTA,r16		;��������� �� PORTA

		ldi		r16,0b00001111	;B0..B3 ������ B4...B7 �����(����� ������������ �������)
		out		DDRB,r16		;���� �
		ldi		r16,$F0			;������������� ��������� ��������
		out		PORTB,r16

		ldi		r16,0			;��� �����
		out		DDRC,r16		;���� �
		ser		r16				;������������� ���������
		out		PORTC,r16		;�� ������

		ldi		r16,0b11111111	;��� ������ (D0...D2 -����� ���� ����) 
		out		DDRD,r16		;���� D
		
		ldi		r16,0b00110111	;D0...D2 = 1 
		out		PORTD,r16		;�� ������� D

		clr		r15				;������� �����: ��� �����
		sei		;�������� ����������

;����� ��� ������ ��� � ������� 0, ����� ����������� �� ����, ������ ������� ���
		clr		r17		
		ldi		r30,$6A  	;�� $006A 
		ldi		r16,$A0		;�� $00A0
		clr		r31		
paus20:	st		Z+,r17
		cpse	r30,r16	
		rjmp	paus20

		ldi		r16,DACdata1		;�������������� ������������ ���	
		sts		kanal,r16		 	;�� ����� 1
		ldi		r16,0b00100001
		out		ADMUX,r16

;������ ��������� ���������� �� ���	������ 0	
		ldi		r25,high(default_0)
		ldi		r24,low(default_0)
		ldi		r30,param0
		clr		r31
rdrom0:
		rcall	EEREAD
		st		Z+,r16
		adiw	r24,1
		cpi		r30,param0+12
		brne	rdrom0
;������ ��������� ���������� �� ���	������ 1		
		ldi		r25,high(default_1)
		ldi		r24,low(default_1)
		ldi		r30,param1
		clr		r31
rdrom1:
		rcall	EEREAD
		st		Z+,r16
		adiw	r24,1
		cpi		r30,param1+12
		brne	rdrom1
;���������� ���������� �10(�����) �� ���������� ��������� � �������
		lds		r16,param0+11
		sts		sec0,r16
		lds		r16,param0+10
		sts		min0,r16

		lds		r16,param1+11
		sts		sec1,r16
		lds		r16,param1+10
		sts		min1,r16
;������� �����������
		clr		r22
		rcall	OUT_LED
;���������� ������� ��� ������
		clr		r26
		clr		r27
								
		
;------------------------------------------------------
;  ������������� ���
;------------------------------------------------------
		ldi		r23,30		;����� 30*0.5=15ms
		rcall	Waitt
		rcall	SEND30
		ldi		r23,8		;����� 8*0.5=4ms
		rcall	Waitt
		rcall	SEND30
		ldi		r23,1		;����� 1*0.5=0.5ms
		rcall	Waitt
		rcall	SEND30 
		ldi		r16,0b00111000	;������������ ����� 8 ������ ����
		rcall	writeI
		ldi		r16,0b00001100	;����� �����������, ������ �� �����
		rcall	writeI
		ldi		r16,0b00000110	;��������� ������� ������,��� ������ ������
		rcall	writeI
		rcall	Start_test		;����������� �������� �����
		sbi		PORTD,3			;�������� ���� (���������� ������� ���������)

clrscr:
		ldi		r16,0x01		;������� ������	
		rcall	writeI
;----------------------	
;������� ���� ������� 0
;----------------------
LEVEL_0:
		;1 ������
		ldi		r18,0		;� ������������� ��������� ���� 2 ������
		ldi		r16,0b10000000	;������ � 0 �������
		rcall	writeI
		ldi		r16,$30	;0
		rcall	writeD
		ldi		r16,$29	;)
		rcall	writeD
		ldi		r16,$49	;I
		rcall	writeD
		ldi		r16,$3D	;=
		rcall	writeD
		lds		r16,amper0	;������� ��� ����� 0
		cpi		r16,250
		brlo	strom0_is_range
;��������� �������� - ���������� ���� ����� 10��
		ldi		r18,$30		;����� ������ ��� �������� ���
Big_Strom:
		cbi		PORTD,3			;��������� ���� (������)
		ldi		r16,0x01		;������� ������	
		rcall	writeI
		ldi		r17,8			;8 �������� ������ �
		ldi		r25,high(error)
		ldi		r24,low(error)
err01_1:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	err01_1
		ldi		r16,$31	;1
		rcall	writeD
		ldi		r16,0b11000000	;������ � 64 �������
		rcall	writeI
		ldi		r17,13			;13 �������� �������� ���
		ldi		r25,high(err1)
		ldi		r24,low(err1)
err01_2:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	err01_2
		mov		r16,r18
		rcall	writeD
		cli				;������ ����������
halt0:	rjmp	halt0	;������� �������
strom0_is_range:
		clr		r17
		lsl		r16
		rol		r17
		lsl		r16
		rol		r17
		rcall	BCDW		;�������-����� ��������� r31:r30
		lds		r16,bcdres2
		rcall	writeD
		ldi		r16,$2E	;.
		rcall	writeD
		lds		r16,bcdres1
		rcall	writeD
		lds		r16,bcdres0
		rcall	writeD
		ldi		r16,$20	;������
		rcall	writeD
		ldi		r16,$54	;T
		rcall	writeD
		ldi		r16,$3D	;=
		rcall	writeD
		lds		r16,min0;������ ������ 0
		rcall	BCDB	;�������-����� ��������� r31:r30
		ld		r16,-Z
		rcall	writeD
		ld		r16,-Z
		rcall	writeD
		ldi		r16,$3A	;���������
		rcall	writeD
		lds		r16,sec0	;������� ������ 0
		rcall	BCDB	;�������-����� ��������� r31:r30
		ld		r16,-Z
		rcall	writeD
		ld		r16,-Z
		rcall	writeD


	;2 ������
		ldi		r16,0b11000000	;������ � 64 �������
		rcall	writeI
		ldi		r16,$31	;1
		rcall	writeD
		ldi		r16,$29	;)
		rcall	writeD
		ldi		r16,$49	;I
		rcall	writeD
		ldi		r16,$3D	;=
		rcall	writeD
		lds		r16,amper1	;������� ��� ����� 1
		cpi		r16,250
		brlo	strom1_is_range
		ldi		r18,$31		;����� ������ ��� �������� ���
		rjmp	Big_Strom
strom1_is_range:
		clr		r17
		lsl		r16
		rol		r17
		lsl		r16
		rol		r17
		rcall	BCDW		;�������-����� ��������� r31:r30
		lds		r16,bcdres2
		rcall	writeD
		ldi		r16,$2E	;.
		rcall	writeD
		lds		r16,bcdres1
		rcall	writeD
		lds		r16,bcdres0
		rcall	writeD
		ldi		r16,$20	;������
		rcall	writeD
		ldi		r16,$54	;T
		rcall	writeD
		ldi		r16,$3D	;=
		rcall	writeD
		lds		r16,min1;������ ������ 1
		rcall	BCDB	;�������-����� ��������� r31:r30
		ld		r16,-Z
		rcall	writeD
		ld		r16,-Z
		rcall	writeD
		ldi		r16,$3A	;���������
		rcall	writeD
		lds		r16,sec1;������� ������ 1
		rcall	BCDB	;�������-����� ��������� r31:r30
		ld		r16,-Z
		rcall	writeD
		ld		r16,-Z
		rcall	writeD

; ���������� ��������� �����������
		ldi		r22,0b00010001
		ldi		r16,0b01110000	;��������� ���������
		and		r16,r26			;������ ������
		lsl		r16
		or		r22,r16
		ldi		r16,0b01110000	;��������� ���������
		and		r16,r27			;������� ������
		lsr		r16
		lsr		r16
		lsr		r16
		or		r22,r16
	;������� ������ 0
		sbrc	r26,0		;��������� ��������� ?
		rjmp	Left_CH_On		;�������� - �������
		lds		r16,param0+11;��������� - ��������� �������� ������� �� ���������
		sts		sec0,r16
		lds		r16,param0+10
		sts		min0,r16	
		cbr		r22,16		;�������� ������� LED ������ ������
		rjmp	Left_CH_Not_Paused
Left_CH_On:
		sbrc	r26,1		;��������� �� ����� ?
		rjmp	Left_CH_Not_Paused		;�� �� ����� - �������
		bst		r15,7		;��������� �������
		bld		r22,4		;�������� ����������
Left_CH_Not_Paused:
		ldi		r16,0b00001100
		and		r16,r26		;������� ����/���� �������?	
		breq	Left_CH_Not_Growth		;��� - �������
		bst		r15,6		;������� �������
		bld		r22,4		;�������� ����������
Left_CH_Not_Growth:
	;������� ������ 1
		sbrc	r27,0		;��������� ���������� ?
		rjmp	Right_CH_On		;�������� - �������
		lds		r16,param1+11;��������� - ��������� �������� ������� �� ���������
		sts		sec1,r16
		lds		r16,param1+10
		sts		min1,r16	
		cbr		r22,0b00000001	;�������� ������� LED ������� ������
		rjmp	Right_CH_Not_Paused
Right_CH_On:
		sbrc	r27,1		;��������� �� ����� ?
		rjmp	Right_CH_Not_Paused		;�� �� ����� - �������
		bst		r15,7		;��������� �������
		bld		r22,0		;�������� ����������
Right_CH_Not_Paused:
		ldi		r16,0b00001100
		and		r16,r27		;������� ����/���� �������?	
		breq	Right_CH_Not_Growth		;��� - �������
		bst		r15,6		;������� �������
		bld		r22,0		;�������� ����������
Right_CH_Not_Growth:
		rcall	OUT_LED

;����� ����������
		rcall	KBRD		;��������� ����������
		cpi		r20,0b11000000	;������ ������ � ����� ������ ?
		brne	Is_Not_Pressed_Left_Right
		rcall	SaveParam
		rjmp	clrscr
Is_Not_Pressed_Left_Right:		;------------- ������ ������ ������
		cpi		r20,0b00000010	;������ ���� ������ ������ ?
		brne	Is_Not_Pressed_Leftstart
		ldi		r16,3
		and		r16,r26			;��������� ���� ������� � �����
		brne	Left_CH_Already_Running	;<>0 �������� ��� �� ����� - �������
		ldi		r16,10			;�� �������� 
		mov		r14	,r16		;��� ������ � ������� 320����
		set
		bld		r15,0			;������� 1600��
		bld		r15,2			;�������  400��

		lds		r20,param0		;��������� 0...128
		lds		r21,param0+2	;������� ��������� 10...200
		lds		r24,param0+1	;������� ��������� 0...10
		ldi		r31,high(am_data0)
		ldi		r30,low(am_data0)
		rcall	CALC			;������ ���������� ��������� ������ ��� �0

		lds		r20,param0+3	;��������� 0...128
		lds		r21,param0+9	;������� ��������� 10...200
		lds		r24,param0+8	;������� ��������� 0...10
		ldi		r31,high(am_data1)
		ldi		r30,low(am_data1)
		rcall	CALC			;������ ���������� ��������� ������ ��� �1
		lds		r20,param0+4	;Fimp
		lds		r21,param0+7	;FMFi
		lds		r24,param0+6	;FMDi
		ldi		r31,high(fm_data0)
		ldi		r30,low(fm_data0)
		rcall	FMCALC
		lds		r16,param0+5	;�� 0,04�� �������� �������� ����������
		ldi		r17,5			;5 ��������� ������� �1
		cli
		mul		r16,r17			;r1:r0=���������� � �������� ���������
		std		Z+6,r0
		std		Z+7,r1
		sei
Left_CH_Already_Running:	
		sbi		PORTD,4			;OCC1B=1 (���������� ��������� �����)
		in		r16,TCCR1A		;������������� 
		ori		r16,0b00010000	;����� OCC1B
		out 	TCCR1A,r16		;������� T1
		ori		r26,0b00000111	;���������, � ������� ������ ����
		andi	r26,0b11110111	;�������� ������� ����
		rjmp	LEVEL_0

Is_Not_Pressed_Leftstart:		;------------- ������ ������� ������
		cpi		r20,0b00001000	;������ ���� ������� ������ ?
		brne	Is_Not_Pressed_Rightstart
		ldi		r16,3
		and		r16,r27			;��������� ���� ������� � �����
		brne	Right_CH_Already_Running			;<>0? �������� ��� �� �����? - �������
		ldi		r16,10			;�� �������� 
		mov		r14	,r16		;��� ������ � ������� 320����
		set
		bld		r15,0			;������� 1600��
		bld		r15,2			;�������  400��
		
		lds		r20,param1		;��������� 0...128
		lds		r21,param1+2	;������� ��������� 10...200
		lds		r24,param1+1	;������� ��������� 0...10
		ldi		r31,high(am_data2)
		ldi		r30,low(am_data2)
		rcall	CALC			;������ ���������� ��������� ������ ��� �2
		lds		r20,param1+3	;��������� 0...128
		lds		r21,param1+9	;������� ��������� 10...200
		lds		r24,param1+8	;������� ��������� 0...10
		ldi		r31,high(am_data3)
		ldi		r30,low(am_data3)
		rcall	CALC		;������ ���������� ��������� ������� ������
		lds		r20,param1+4	;Fimp
		lds		r21,param1+7	;FMFi
		lds		r24,param1+6	;FMDi
		ldi		r31,high(fm_data1)
		ldi		r30,low(fm_data1)
		rcall	FMCALC
		lds		r16,param1+5	;�� 0,04�� �������� �������� ����������
		ldi		r17,5			;5 ��������� ������� �1
		cli
		mul		r16,r17			;r1:r0=���������� � �������� ���������
		std		Z+6,r0
		std		Z+7,r1
		sei
Right_CH_Already_Running:
		sbi		PORTD,5			;OCC1A=1 (���������� ��������� �����)
		in		r16,TCCR1A		;������������� 
		ori		r16,0b01000000	;����� OCC1�
		out 	TCCR1A,r16		;������� T1
		ori		r27,0b00000111	;���� � �����, � ������� ������ ����
		andi	r27,0b11110111	;�������� ������� ����
		rjmp	LEVEL_0

Is_Not_Pressed_Rightstart:		;------------- ��������� �������� � ����� ������ ������
		cpi		r20,0b00000001	;������ ���� ������ ������ ?
		brne	Is_Not_Pressed_LeftStop
		sbrc	r26,1			;��������� � ����� ������ �� ����� ?
		rjmp	Left_CH_IsNot_Paused			;��� ����� - �������
		sbrs	r26,3			;������� ���� ���� ��� ������� ?
		rjmp	Left_CH_IsNot_Decline	   		;��� ��� ����� - �������
		andi	r26,0b11110111	;�������� ������� ���� ���� (2 �������)
		clr		r16				;����� ��������
		sts		DACdata0,r16	;��� ������������ 
		sts		DACdata1,r16	;����� ������ ������
		rjmp	LEVEL_0
Left_CH_IsNot_Decline:			;����� ��������� (3 �������)
		andi	r26,0b11111100	
		rjmp	LEVEL_0
Left_CH_IsNot_Paused:			;������������ ����� (1 �������) 
		andi	r26,0b10001001	;�������� ������� ���������� ����,�������� ���������� ���������
		ori		r26,0b00001000	;������������ ������� ���� ����
		rjmp	LEVEL_0

Is_Not_Pressed_LeftStop:		;------------- ��������� �������� � ����� ������� ������
		cpi		r20,0b00000100	;������ ���� ������� ������ ?
		brne	Is_Not_Pressed_RightStop
		sbrc	r27,1			;��������� � ������ ������ �� ����� ?
		rjmp	Right_CH_IsNot_Paused		;��� ����� - �������
		sbrs	r27,3			;������� ���� ���� ��� ������� ?
		rjmp	Right_CH_IsNot_Decline	   	;��� ��� ����� - �������
		andi	r27,0b11110111	;�������� ������� ���� ���� (2 �������)
		clr		r16				;����� ��������
		sts		DACdata2,r16	;��� ������������ 
		sts		DACdata3,r16	;����� ������� ������
		rjmp	LEVEL_0
Right_CH_IsNot_Decline:			;����� ��������� (3 �������)
		andi	r27,0b11111100	
		rjmp	LEVEL_0
Right_CH_IsNot_Paused:			;������������ �����(1 �������)
		andi	r27,0b10001001	;�������� ������� ���������� ����,�������� ���������� ��������� 
		ori		r27,0b00001000	;������������ ������� ���� ����
		rjmp	LEVEL_0

Is_Not_Pressed_RightStop:		
		sbrs	r21,5		;�������� ����� ���������� ������� � 1��� (32)
		rjmp	LEVEL_0		;<32 - ������������ �������
		cpi		r20,0b00100000	;������ ���� (S10) ?
		breq	Is_Pressed_Down
		rjmp	LEVEL_0			;�� ������
Is_Pressed_Down:
		rcall	LEVEL_1			;������
		rjmp	clrscr


;------------------------------------------------------
;���� ������ ������ ��� ��������� ����������
;------------------------------------------------------
LEVEL_1:
		ldi		r16,0b00001101	;����� �����������, ������ � ���� �������������� 
		rcall	writeI
		ldi		r16,0x01		;������� ������	
		rcall	writeI
		ldi		r16,$30	;0
		rcall	writeD
		ldi		r17,8			;8 �������� �����
		ldi		r25,high(elab1)
		ldi		r24,low(elab1)
lmnu1:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	lmnu1

		ldi		r16,$31	;1
		rcall	writeD
		ldi		r17,6			;8 ��������
		ldi		r24,low(elab1)
lmnu2:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	lmnu2
		bst		r15,5			;������� � �������������� ������
lmnu3:	
		ldi		r16,0b10000000	;���������� � ��������� ������� � ����������� � r15:5 �������
		bld		r16,0
		bld		r16,3
		rcall	writeI
lmnu5:
		rcall	KBRD
		tst		r21
		brne	lmnu5	;�������� ���������� ��������� ������� ������
waitkb:
		rcall	KBRD
		cpi		r20,0b01000000	;������ ����� ? (S11)
		brne	nonS11
		clt						;������ � 0 �������
		rjmp	lmnu3
nonS11:
		cpi		r20,0b10000000	;������ ������ ? (S12)
		brne	nonS12
		set						;������ � 9 �������
		rjmp	lmnu3
nonS12:
		cpi		r20,0b00010000	;������ ����� ? (S9)
		breq	lmnu4			;������� � ������������ ����
		cpi		r20,0b00100000	;������ ���� ? (S10)
		brne	waitkb			;��� - � ������ ����������
		bld		r15,5			;��������� � �������� ������
		rcall	LEVEL_2			;�� - � ���� 2 ������
		rjmp	LEVEL_1			;����� ������ - ������� ���� 1 ������
lmnu4:	
		bld		r15,5			;��������� � �������� ������
		ret		

;------------------------------------------------------
;���� ������ ����������
;------------------------------------------------------
LEVEL_2:
		ldi		r16,0b00001100	;����� �����������, ������ �� �����
		rcall	writeI
		ldi		r16,0x01	;������� ������	
		rcall	writeI
		ldi		r17,25		;������ �������� ��� ������� �� ���
		mul		r18,r17		;�������� = �*25
		movw	r24,r0		;� r25:r24
		ldi		r17,16		;16 �������� ������ (��� ���������)
lmnu21:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	lmnu21

		ldi		r16,0b11000000	;������ � ������ 2 ������ (64 �������)
		rcall	writeI
		bst		r15,5		;� ������ ������
		ldi		r16,$30
		bld		r16,0		;�������
		rcall	writeD
		ldi		r16,$23		;�
		rcall	writeD
		mov		r16,r18
		rcall	BCDB
		ldi		r30,bcdres1
		ld		r16,Z
		rcall	writeD		;������� � ���������
		ld		r16,-Z
		rcall	writeD
		ldi		r16,$20		;������
		rcall	writeD
		ldi		r17,4		;4 ������� ������ (�������)
lmnu25:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	lmnu25
		ldi		r16,$3D		;=
		rcall	writeD
		rcall	PRINT_PARAM
waitkb2:
		rcall	KBRD
		cpi		r20,0b01000000	;������ ����� ? (S11)
		brne	nonleft
		cpi		r18,0			;����� ��������� = 0?
		breq	sound1			;�� - �������
		dec		r18
		rjmp	LEVEL_2
nonleft:
		cpi		r20,0b10000000	;������ ������ ? (S12)
		brne	nonright
		cpi		r18,10			;����� ��������� = 10?
		breq	sound1			;�� - �������
		inc		r18
		rjmp	LEVEL_2
nonright:
		cpi		r20,0b00100000	;������ ���� ? (S10)
		brne	nondown
		rcall	LEVEL_3
		rjmp	waitkb2
nondown:
		cpi		r20,0b00010000	;������ ����� ? (S9)
		breq	lmnu27
		rjmp	waitkb2
sound1:			
		ldi		r16,4			;���� ������
		mov		r14,r16			;128����
		set
		bld		r15,2			;������� 400��
		bld		r15,4			;������� 100��
		rjmp	waitkb2
lmnu27:	
		rcall	Valid_Check
		brcc	endl2
		rjmp	LEVEL_2
endl2:
		ret


;--------------------------------------------------
;���� �������������� ���������
;--------------------------------------------------
LEVEL_3:
		clt		;��������� ��� ������
lmnu30:	
		ldi		r16,0b11001010
		rcall	writeI
		rcall	PRINT_PARAM		;������� �� ����� ��������
		ldi		r16,0b00001101	;����� �����������, ������ � ���� �������������� 
		rcall	writeI
		ldi		r16,0b11001101	;������ � 4D (�� ������ �������� ������� �����)
		brtc	lmnu301
		ldi		r16,0b11001010	;������ � 4A (�� ������ �������� ������� �����)
lmnu301:
		rcall	writeI
waitkb3:
		rcall	KBRD
		cpi		r20,0b00010000	;������ ����� ? (S9)
		brne	lmnu302			
;----- ��������� ���� 3 ������ --------------
		ldi		r16,0b00001100	;����� �����������, ������ �� �����
		rcall	writeI
		ret
lmnu302:
		cpi		r18,10			;�������� �10 ?
		brne	lmnu33			;��� - �������
;---- ��� �������������� ��������� 10 -----
		cpi		r20,0b10000000	;������ ������ ? (S12)
		brne	lmnu31			;��� - �������
		brtc	lmnu311	        ;������� �������������� ������ ? �������
		ldi		r17,100			;������ ��� �����
		ldi		r19,0
lmnu312:
		ld		r16,Y			;������������� ����� � +
		inc		r16
		st		Y,r16
		cp		r16,r17
		brne	lmnu30
		mov		r16,r19
		st		Y,r16
		rjmp	lmnu30
lmnu311:
		ldd		r16,Y+1			;������������� ������ � +
		inc		r16
		std		Y+1,r16
		cpi		r16,60
		brne	lmnu30
		clr		r16
		std		Y+1,r16
		rjmp	lmnu30

lmnu31:
		cpi		r20,0b01000000	;������ ����� ? (S11)
		brne	lmnu32
		brtc	lmnu321		;������� �������������� ������ ? �������
		ldi		r17,99		;������ ��� �����
		ldi		r19,255

lmnu322:
		ld		r16,Y		;������������� ����� � -
		dec		r16
		st		Y,r16
		cp		r16,r19
		brne	lmnu30
		mov		r16,r17
		st		Y,r16
		rjmp	lmnu30
lmnu321:
		ldd		r16,Y+1		;������������� ������ � -
		dec		r16
		std		Y+1,r16
		cpi		r16,255
		brne	lmnu30
		ldi		r16,59
		std		Y+1,r16
		rjmp	lmnu30
lmnu32:
		cpi		r20,0b00100000	;������ ���� ? (S10)
		brne	waitkb3
		sbrc	r21,5
wkb3:			
		rjmp	waitkb3	;��������� ���� ���� ���� ����-������
		brts	lmnu34	;������� ��������� ������ ��� �������
		set		;��������� ��� �����
		rjmp	lmnu30
lmnu34:
		clt		;��������� ��� ������
		rjmp	lmnu30

lmnu33:	;---- ��� �������������� ���������� 0...9-----
		cpi		r20,0b01000000	;������ ����� ? (S11)
		brne	lmnu35
		adiw	r24,1
		rcall	EEREAD	;������� ������� ������
		mov		r17,r16
		adiw	r24,1
		rcall	EEREAD	;������� ������ ������
		mov		r19,r16
		rjmp	lmnu322
lmnu35:
		cpi		r20,0b10000000	;������ ������ ? (S12)
		brne	wkb3
		adiw	r24,1
		rcall	EEREAD	;������� ������� ������
		mov		r17,r16
		inc		r17
		adiw	r24,1
		rcall	EEREAD	;������� ������ ������
		mov		r19,r16
		inc		r19
		rjmp	lmnu312

;---------------------------------------------------
;���������� ������������ �� ������� ����������� �������� �����
;� ��������� ���� ��� �����������
;������ �0 - �� ������ �� ��������������� ���� � �������� ��������
;---------------------------------------------------
Start_Test:
.equ	ADC_Valid_null=2
		;��������� ������� ����� �� ������� ����������
		clr		r16
		sts		DACdata0,r16
		sts		DACdata1,r16
		sts		DACdata2,r16
		sts		DACdata3,r16

		ldi		r16,0x01		;������� ������	
		rcall	writeI
		ldi		r17,7			;16 �������� "����..."
		ldi		r25,high(teststring)
		ldi		r24,low(teststring)
test1:
		rcall	EEREAD
		ldi		r23,250		;����� 250*0.5=125ms
		rcall	Waitt
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	test1

		lds		r16,amper0
		cpi		r16,ADC_Valid_null
		brsh	Error_Output_Left
		lds		r16,amper1
		cpi		r16,ADC_Valid_null
		brsh	Error_Output_Right
		ret



Error_Output_Left:
		ldi		r16,0x01		;������� ������	
		rcall	writeI
		ldi		r17,8			;8 �������� ������ �
		ldi		r25,high(error)
		ldi		r24,low(error)
err0_1:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	err0_1		
		ldi		r16,$30	;"0"
		rcall	writeD
		ldi		r16,0b11000000	;������ � 64 �������
		rcall	writeI
		ldi		r16,$30	;"0"	;� ������
		rcall	writeD
		ldi		r17,15			;15 �������� ����� ������
		ldi		r25,high(err0)
		ldi		r24,low(err0)
err0_2:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	err0_2
loop1:	
		rjmp	loop1



Error_Output_Right:
		ldi		r16,0x01		;������� ������	
		rcall	writeI
		ldi		r17,8			;8 �������� ������ �
		ldi		r25,high(error)
		ldi		r24,low(error)
err1_1:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	err1_1		
		ldi		r16,$30	;"0"
		rcall	writeD
		ldi		r16,0b11000000	;������ � 64 �������
		rcall	writeI
		ldi		r16,$31	;"1"	;� ������
		rcall	writeD
		ldi		r17,15			;15 �������� ����� ������
		ldi		r25,high(err0)
		ldi		r24,low(err0)
err1_2:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	err1_2
loop2:	
		rjmp	loop2

;---------------------------------------------------
;�������� �� ������������ ��������� ����������
;��������� �� ������ ���������� Fmin=Fi-DFi >= 5 (2��)
;����� ������ ���� ��� ������� �������� �� ������������ �������:
;����<=1/2(Fi+DFi). ������ � ��: Timp<=31250/(Fi+DFi)
;������������ ������� ������ ���� � 10p ������ Fmin=Fi-DFi
;---------------------------------------------------
Valid_Check:
		push	r18
		ldi		r16,0x01		;������� ������	
		rcall	writeI
		mov		r28,r15			;�������� � �������������� ������
		andi	r28,0b00100000
		lsr		r28				;r28=#������*16
		clr		r29
		subi	r28,256-param0	;(256-$70)�������� ����� ������ ����� ���������� �������� ������
		ldd		r16,Y+4			;������� ��������� (5...249)
		ldd		r17,Y+6			;��������			
		sub		r16,r17			;Fi-DFi
		cpi		r16,5
		brsh	probe_err12
		rjmp	ERROR10			;Fi-DFi<5
probe_err12:
		ldd		r19,Y+7			;������������ ������� (10...249)
		cp		r16,r19
		brsh	probe_err11	
		rjmp	ERROR12
probe_err11:
		ldd		r16,Y+4			;������� ��������� (5...249)
		add		r16,r17			;Fi+DFi
		clr		r17
		adc		r17,r17			;r17:r16=Fi+DFi
		ldi		r18,low(31250)
		ldi		r19,high(31250)
		movw	r0,r18
		rcall	divide16		;r19:r18=31250/(Fi+DFi)
		ldd		r16,Y+5			;������������ ��������
		clr		r17
		cp		r18,r16
		cpc		r19,r17
		brsh	probe_err13
		rjmp	ERROR11			;31250/(Fi+DFi)<Timp
probe_err13:
		ld		r20,Y			;��������� 0...255
		ldd		r24,Y+1			;������� ��������� 0...10
		mul		r20,r24			;L*%mod
		ldi		r16,10
		clr		r17
		rcall	divide16	;A=r19:r18=L*%mod/10
		mov		r19,r20
		add		r19,r18		;max AM
		brcc	probe_err14
		rjmp	ERROR13	
probe_err14:
		ldd		r20,Y+3		;��������� 0...128
		ldd		r24,Y+8		;������� ��������� 0...10
		mul		r20,r24		;L*%mod
		ldi		r16,10
		clr		r17
		rcall	divide16	;A=r19:r18=L*%mod/10
		mov		r19,r20
		add		r19,r18		;max AM
		brcc	No_Error	;���������� ������
		rjmp	ERROR14	

State_Err_Wait_KB:
		rcall	KBRD
		cpi		r20,0b00010000	;������ �����
		brne	State_Err_Wait_KB
		sec		;���������� �������� �������� ��� ������� ������
No_Error:
		pop		r18
		ret

	;����������� ������						
ERROR10:
		ldi		r17,8			;8 �������� ������ �
		ldi		r25,high(error)
		ldi		r24,low(error)
err10_1:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	err10_1
		ldi		r16,$31
		rcall	writeD
		ldi		r16,$30
		rcall	writeD
		ldi		r16,0b11000000	;������ � 64 �������
		rcall	writeI
		ldi		r17,13			;13 �������� ����� ������
		ldi		r25,high(err10)
		ldi		r24,low(err10)
err10_2:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	err10_2
		rjmp	State_Err_Wait_KB

ERROR12:
		ldi		r17,8			;8 �������� ������ �
		ldi		r25,high(error)
		ldi		r24,low(error)
err12_1:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	err12_1
		ldi		r16,$31
		rcall	writeD
		ldi		r16,$32
		rcall	writeD
		ldi		r16,0b11000000	;������ � 64 �������
		rcall	writeI
		ldi		r17,14			;13 �������� ����� ������
		ldi		r25,high(err12)
		ldi		r24,low(err12)
err12_2:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	err12_2
		rjmp	State_Err_Wait_KB

ERROR11:
		ldi		r17,8			;8 �������� ������ �
		ldi		r25,high(error)
		ldi		r24,low(error)
err11_1:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	err11_1
		ldi		r16,$31
		rcall	writeD
		ldi		r16,$31
		rcall	writeD
		ldi		r16,0b11000000	;������ � 64 �������
		rcall	writeI
		ldi		r17,15			;13 �������� ����� ������
		ldi		r25,high(err11)
		ldi		r24,low(err11)
err11_2:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	err11_2
		rjmp	State_Err_Wait_KB

ERROR13:
		ldi		r17,8			;8 �������� ������ �
		ldi		r25,high(error)
		ldi		r24,low(error)
err13_1:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	err13_1
		ldi		r16,$31
		rcall	writeD
		ldi		r16,$33
		rcall	writeD
		ldi		r16,0b11000000	;������ � 64 �������
		rcall	writeI
		ldi		r17,14			;14 �������� ����� ������
		ldi		r25,high(err13)
		ldi		r24,low(err13)
err13_2:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	err13_2
		ldi		r16,$49	;I
		rcall	writeD
		ldi		r16,$63	;c
		rcall	writeD
		rjmp	State_Err_Wait_KB

ERROR14:
		ldi		r17,8			;8 �������� ������ �
		ldi		r25,high(error)
		ldi		r24,low(error)
err14_1:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	err14_1
		ldi		r16,$31
		rcall	writeD
		ldi		r16,$34
		rcall	writeD
		ldi		r16,0b11000000	;������ � 64 �������
		rcall	writeI
		ldi		r17,14			;14 �������� ����� ������
		ldi		r25,high(err13)
		ldi		r24,low(err13)
err14_2:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	err14_2
		ldi		r16,$49	;I
		rcall	writeD
		ldi		r16,$69	;i
		rcall	writeD
		rjmp	State_Err_Wait_KB


		
;---------------------------------------------------
;����� �� ��������� ���������� �������� ���������
;���������� �� ���� 2 � 3 �������
;�������� �������� � r15.5 � r18
;---------------------------------------------------
PRINT_PARAM:
		mov		r28,r15			;�������� � �������������� ������
		andi	r28,0b00100000
		lsr		r28				;r28=#������*16
		clr		r29
		cpi		r18,10			;��� �������� �10 ?
		brne	non10			;��� - �������
	;�� - ����� ������:�������
		subi	r28,256-(param0+10)	;(256-$7F)	;+$7A
		ld		r16,Y
		ldd		r17,Y+1
		rcall	BCDB
		lds		r16,bcdres1		;������� �����
		rcall	writeD
		lds		r16,bcdres0		;������
		rcall	writeD
		ldi		r16,$3A		; :
		rcall	writeD
		mov		r16,r17
		rcall	BCDB
		lds		r16,bcdres1		;������� ������
		rcall	writeD
		lds		r16,bcdres0		;�������
		rcall	writeD
		rjmp	ppe
non10:
		subi	r28,256-param0	;(256-$70)	;+$70 �������� ����� ������ ����� ���������� �������� ������
		add		r28,r18		;�������� ����� �������� ���������
		ld		r16,Y		;������� �������� ���������
		mov		r19,r16		;� ��������� � r19
		ldi		r17,25		;������ �������� ��� ������� �� ���
		mul		r18,r17		;�������� = �*25
		movw	r24,r0		;� r25:r24
		adiw	r24,20		;����� ���������� ���������
		rcall	EEREAD		;������� �� ��� ���������
		mov		r20,r16		;��������� ��� ������ ��������� ���������� �����
		andi	r16,$0F		;�������� ������� �������
		mul		r16,r19		;�������� �������� ��� ���������
		movw	r16,r0		;� r17:r16
		rcall	BCDW		;��������� � ���������� ��� � ��� ����������
		ldi		r30,bcdres3		;����� ������ �������� ������� +1
		swap	r20
		andi	r20,$0F		;�������� � ���������� ��� ���������� �����
		subi	r20,256-bcdres0	;+$64 (+100)
pp1:	
		cp		r30,r20
		brne	pp2
		ldi		r16,$2E		;������ ���������� �����
		rcall	writeD
pp2:
		ld		r16,-Z
		rcall	writeD
		cpi		r30,bcdres1
		brsh	pp1
		adiw	r24,1
		rcall	EEREAD		;1 ������ ��������
		rcall	writeD
		adiw	r24,1
		rcall	EEREAD		;2 ������ ��������
		rcall	writeD
ppe:
		ret

;------------------------------------------------------
;������������ ������� ���������� ���������
;������ ����������� ���������
;����� ������� TIM0_COMP � ������� �=1000000/64=15625
;������ ��������� 2�=2*L*%mod/10
;;����� ������=(2�+1)*f/2/39063
;�.� ������� �������� �� 0 �� 200, �� ������� ����� ���:
;������=(�*�+�/2)/39063
;��������� �� �����, � ��������, �� ���������� ������������,
;�� ���������� ������������� ��������. �������� ��� 50% � �=128 �� 64  �� 192
;������ ������������ ��������
;��������� 	r20 - ������� (L) 0...128
;			r21 -������� ��������� (f) 10...200
;			r24 - ������� ��������� (%mod) 0...9
;�������:
;Z - ����������� � +
;Z+1 - ����������� � -
;Z+3:Z+2 = ���������� ��������� �� 1 ����� TIM0_COMP
;-------------------------------------------------------
CALC:
		mul		r20,r24		;L*%mod
		ldi		r16,10
		clr		r17
		rcall	divide16	;A=r19:r18=L*%mod/10
		mov		r19,r20
		add		r19,r18		;max AM
		st		Z,r19
		sub		r20,r18		;min AM
		std		Z+1,r20
		sub		r19,r20		;2A
		breq	_clc1
		inc		r19			;2A+1
		mul		r19,r21		;r1:r0=(2A+1)*f
		lsr		r1			;r1:r0=(2A+1)*f/2
		ror		r0			
		ldi		r17,high(39063)
		ldi		r16,low(39063)
		rcall	ddiv		;r19:r18=(2A+1)*f/2/39063
_clc2:
		std		Z+2,r18		;��������� �������� ����������
		std		Z+3,r19
		ret
_clc1:
		clr		r18
		clr		r19
		rjmp	_clc2




;------------------------------------------------------
;������������ ������� ���������� FM ���������
;� TIM0_COMP ������������� ����� ������� �1
;����� ������� TIM0_COMP � ������� �=1000000/64=15625
;Fi_max=Fi+FMDi	Fi_min=Fi-FMDi
;������ ������� ��������� 2FMDi (126 ��)
;���������� �������� ��������� ������� �� 1 ������ ��������� Nm=(2FMDi+1)*2
;���������� �� 1 ����� Dmi=Nm*FMFi/15625. �������� Dmi=(2FMDi+1)*FMFi/7812.5
;�������� ������������ �����������������:
;Dmi=0.4*(2FMD+1)*0.04*FMF/7812.5=(2FMD+1)*FMF/195312=(2FMD+1)*FMF/(4*48828)
;��������� �� �����, � ��������,
;��������� 	r20 - ����������� �������� (Fi)10...249	(4...99,6��)
;			r21 -������� ��������� (FMFi) 10...249	(0.4....9.96��)
;			r24 - �������� ������� (FMDi) 0...63  	(0...25.2��)
;�������:
;Z - �������� � +
;Z+1 - �������� � -
;Z+3:Z+2 = ���������� ������� �� 1 ����� TIM0_COMP
;Z+4 ������� �������� (�������� ��� ������������� � ������� ����������)
;Z+5 ����������� ������� ��� ���������� ����� param+4
;-------------------------------------------------------
FMCALC:
		std		Z+5,r20		;����������� �������
		clr		r19			;��������
		std		Z+4,r19		;������� ��������
		st		Z,r24		;+��������
		mov		r19,r24
		neg		r19
		std		Z+1,r19		;-��������
		lsl		r24
		breq	_fmclc1		;������� ���� ��������=0	
		inc		r24			;r24=2FMDi+1
		mul		r24,r21		;r1:r0=(2FMD+1)*FMF
		lsr		r1
		ror		r0			;/2
		lsr		r1
		ror		r0			;/4
		ldi		r17,high(48828)
		ldi		r16,low(48828)
		rcall	ddiv		;r19:r18=(2FMD+1)*FMF/4/48828
_fmclc2:
		std		Z+2,r18		;��������� �������� ����������
		std		Z+3,r19
		ret
_fmclc1:
		clr		r18
		clr		r19
		rjmp	_fmclc2


;------------------------------------------------------
; ������ ����������
; ����� ������� � r20
; ������� � r21
; ��� ������� r20=��� ������� ������� r21=0
; ��� ��������� �� 1 ��� r20=0 r21=1
; ��� ��������� ����� 1 ��� r20=���,������� �������� ������� r21=32
;------------------------------------------------------
KBRD:	
		cli					;������ ���������� ����� �� ���������� �������
		lds		r20,keytime		;������� ����� �������� �������
		sbrs	r20,5		;���������� ���� ���� >=32 (2^5)
		rjmp	singl
		dec		r20			;��� ���������: �������� ������� ������� ��������� �� 2/32���
		dec		r20
		sts		keytime,r20
		lds		r20,keystate		;������� �������
		com		r20
		ldi		r21,32
		sei
		ret
singl:			; ���� ��������� �� �������� 1 ���
		tst		r20
		breq	lkb1	;��������� ��� ������ - �������
		clr		r20		;�� �������� ��� ������
		ldi		r21,1	;��������� �������� ��� 1/32���
		rjmp	kbex
lkb1:					
		lds		r20,keynew		;����� �������
		lds		r21,keystate		;�������
		com		r21			;��������� ��� 1 ������� �������
		and		r20,r21		;������ ������������			
		clr		r21
		sts		keynew,r21		;�������� ������� ������� �������
		lds		r21,keytime		;����� ���������
kbex:
		sei					;��������� ����������
		ret

;-------------------------------------------------------
;���������� � ��� ������� ���������� ��� ����� ���������
;-------------------------------------------------------
SaveParam:
		ldi		r16,$01		;������� ������	
		rcall	writeI
		ldi		r16,0b00001100		;������ ����
		rcall	writeI
		ldi		r17,16			;16 �������� "������ ��������"
		ldi		r25,high(savep)
		ldi		r24,low(savep)
save1:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	save1
Cicle_Read_Keyb:
		rcall	KBRD
		cpi		r20,0b00000010	;����� ���� ������
		breq	Left_Save_Param
		cpi		r20,0b00001000	;����� ���� �������
		breq	Right_Save_Param
		cpi		r20,0b00010000	;������ ����� ? (S9)
		brne	Cicle_Read_Keyb
		ret
Left_Save_Param:	;������ ���������� ������ ������	
		ldi		r25,high(default_0)
		ldi		r24,low(default_0)
		ldi		r30,param0
		clr		r31
wrrom0:
		ld		r16,Z+
		rcall	EEWR
		adiw	r24,1
		cpi		r30,param0+12
		brne	wrrom0
		ldi		r16,0b11000000	;������ � 64 �������
		rcall	writeI
		ldi		r16,$30	;1
		rcall	writeD
		rjmp	Wait_KBstate_is_Free

Right_Save_Param:	;������ ���������� ������� ������	
		ldi		r25,high(default_1)
		ldi		r24,low(default_1)
		ldi		r30,param1
		clr		r31
wrrom1:
		ld		r16,Z+
		rcall	EEWR
		adiw	r24,1
		cpi		r30,param1+12
		brne	wrrom1
		ldi		r16,0b11000000	;������ � 64 �������
		rcall	writeI
		ldi		r16,$31	;1
		rcall	writeD
		rjmp	Wait_KBstate_is_Free
		

Wait_KBstate_is_Free:
		ldi		r17,14			;14 �������� ����� ������
		ldi		r25,high(elab1)
		ldi		r24,low(elab1)
save2:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	save2
	;�������� ���������� ��������� ������� ������
		ldi		r16,5	;160����
		mov		r14,r16	;��� ������ � ������� 320����
		set
		bld		r15,1	;������� 800��
Read_KB_1:
		rcall	KBRD
		tst		r21
		brne	Read_KB_1
		rjmp	Cicle_Read_Keyb	

			
;------------------------------------------------------
;  ������ ����� �� EEPROM
;  ����� r25:r24
;  ����������� ���� � r16
;------------------------------------------------------
EEREAD:
		sbic	EECR,EEWE
		rjmp	EEREAD
		out		EEARH,r25
		out		EEARL,r24
		sbi		EECR,EERE
		in		r16,EEDR
		ret

;------------------------------------------------------
;  ������ ����� � EEPROM
;  ����� r25:r24
;  ���� ��� ������ � r16
;------------------------------------------------------
EEWR:
		sbic	EECR,EEWE
		rjmp	EEWR
		cli
		out		EEARH,r25
		out		EEARL,r24
		out		EEDR,r16
		sbi 	EECR,EEMWE 	;���������� ���� EEMWE
		sbi 	EECR,EEWE 	;������ ������ � EEPROM
		sei
		ret

;------------------------------------------------------
;  ����� ���������� �� LED
;  �������� ���� ���������� � r22
;------------------------------------------------------
OUT_LED:
		push	r17
		ser		r17			;���� � ������������� ��� �����
		out		DDRC,r17
		out		portC,r22	;�����������  �� ����
		sbi		portA,6		;����� LE
		nop					;250ns ������������ LE
		cbi		portA,6		;���� L� (�������� �� �����)
		clr		r17			;������������� ��� ����
		out		DDRC,r17	;���� �
		ser		r17			;������������� ���������
		out		PORTC,r17	;�� ������
		pop		r17
		ret


;--------------------------------------------------------
;��������� ����� ������������ r23*0,5us
;--------------------------------------------------------
Waitt:	
		cpi		r23,0
		brne	Waitt
		ret

;--------------------------------------------------------
;������������ ������ ����� � ������� ������ �������
;������������ ���� � �������� R16
;--------------------------------------------------------
writeD:	
		push	r17
wrL3:	
		rcall	readI
		sbrc	r17,7
		rjmp	wrL3
		sbi		portB,0		;RS=1 (������)
		cbi		portB,1		;R/W=0 (������)
		rjmp	Public_Code

;--------------------------------------------------------
;������������ ������ ����� � ������� ���������� �������
;������������ ���� � �������� R16 
;--------------------------------------------------------
writeI:	push	r17
wrL4:	rcall	readI
		sbrc	r17,7
		rjmp	wrL4
		cbi		portB,0		;RS=0 (�������)
		cbi		portB,1		;R/W=0 (������)
Public_Code:
		ser		r17			;���� � ������������� ��� �����
		out		DDRC,r17
		out		portC,r16	;����������� �������/������ �� ����
		nop
		sbi		portB,2		;����� �
		nop					;500ns ������������ E
		nop
		cbi		portB,2		;���� � (������ �� �����)
		clr		r17			;������������� ��� ����
		out		DDRC,r17	;���� �
		ser		r17			;������������� ���������
		out		PORTC,r17	;�� ������
		pop		r17
		ret

;--------------------------------------------------------
;������������ ������ �������� ��������� �������
;��������� ���� � �������� R17
;--------------------------------------------------------
readI:	
		cbi		portB,0		;RS=0 (�������)
		sbi		portB,1		;R/W=1 (�����)
		sbi		portB,2		;E=1
		nop		; �����
		nop
		in 		r17,PINC	;������ �� ������
		cbi		portB,2		;E=0
		nop
		cbi		portB,1		;R/W=0
		ret

;--------------------------------------------------------
;�������� ���� 0x30 �� LCD ��� �������������
;��������� r16
;--------------------------------------------------------

SEND30:
		cbi		PORTB,0		;RS=0 (����� ���������)
		cbi		PORTB,1		;RW=0 (������ � ���)
		cbi		PORTB,2		;E=0 (��� ����������)
		ser		r16
		out		DDRC,r16	;���� � �� �����
		ldi		r16,0x30	;������������ � 8 ������ �����
		out		portC,r16	;���������� �� ������� �
		nop
		sbi		portB,2		;����� �� ���� � ���
		nop					;500ns ������������ E
		nop
		cbi		portB,2		;���� �� ����� �
		clr		r16			;������������� �� ����
		out		DDRC,r16	;���� �
		ser		r16			;������������� ���������
		out		PORTC,r16	;�� ������
		ret

;------------------------------------------------------------		
;�������-���������� �������������� ����� r16 � �������-���������� r19:r18
;r16 �����������
;------------------------------------------------------------
BCDB:	push	r21
		push	r24
		push	r18
		push	r19
		push	r16

		clr		r18				;�������
		clr		r19				;��������� ��������� BCD
		ldi		r24,8			;����� �������
internb:
		mov 	r21,r18
		rcall	BCD_sub			;������� �������-���������� ���������
		mov 	r18,r21
		mov 	r21,r19
		rcall	BCD_sub			;������� �������-���������� ���������
		mov 	r19,r21
		lsl		r16				;����� �������� ����� ���������
		rol		r18				;� ����� ����������	
		rol		r19
		dec		r24
		brne	internb
		clr		r31
		ldi		r30,bcdres2		;����� �������� �������
		ori		r19,$30		;�������������� � ��� ����������
		st		Z,r19
		mov		r19,r18		;�������� ������ ������	
		swap	r19			;� ������� �������
		andi	r19,$0F		;�������� �������
		ori		r19,$30		;�������������� � ��� ����������
		st		-Z,r19	
		mov		r19,r18		;�������� ������ ������	
		andi	r19,$0F		;�������� ������� �������
		ori		r19,$30		;�������������� � ��� ����������
		st		-Z,r19
		ldi		r30,bcdres2		;����� �������� �������
		pop		r16
		pop		r19
		pop		r18
		pop		r24
		pop		r21
		ret


;------------------------------------------------------------		
;�������-���������� �������������� ����� r17:r16
;------------------------------------------------------------
BCDW:	push	r18
		push	r19
		push	r20	
		push	r21
		push	r24
		clr		r18				;�������
		clr		r19				;��������� ��������� BCD
		clr		r20
		ldi		r24,16			;����� �������
internw:
		mov 	r21,r18			;������� ����� ����������
		rcall	BCD_sub			;������� �������-���������� ���������
		mov 	r18,r21
		mov 	r21,r19			;������� ����� ����������
		rcall	BCD_sub			;������� �������-���������� ���������
		mov 	r19,r21
		mov 	r21,r20			;�������� ����� ����������
		rcall	BCD_sub			;������� �������-���������� ���������
		mov 	r20,r21
		lsl		r16				;����� �������� ����� ���������
		rol		r17				;� ������� ���� ���������
		rol		r18				;� � ����� ����������	
		rol		r19
		rol		r20
		dec		r24
		brne	internw
		
		clr		r31
		ldi		r30,bcdres4	;����� 4 �������
		ori		r20,$30		;�������������� � ��� ����������
		st		Z,r20

		mov		r20,r19		;�������� 3 ������	
		swap	r20			;� ������� �������
		andi	r20,$0F		;�������� �������
		ori		r20,$30		;�������������� � ��� ����������
		st		-Z,r20	
		mov		r20,r19		;�������� 2 ������	
		andi	r20,$0F		;�������� ������� �������
		ori		r20,$30		;�������������� � ��� ����������
		st		-Z,r20		

		mov		r19,r18		;�������� 1 ������	
		swap	r19			;� ������� �������
		andi	r19,$0F		;�������� �������
		ori		r19,$30		;�������������� � ��� ����������
		st		-Z,r19	
		mov		r19,r18		;�������� 0 ������	
		andi	r19,$0F		;�������� ������� �������
		ori		r19,$30		;�������������� � ��� ����������
		st		-Z,r19
		ldi		r30,bcdres4	;����� �������� �������
		pop		r24
		pop		r21
		pop		r20
		pop		r19
		pop		r18
		ret

;------------------------------------------------------------
;�������-���������� ��������� ���� ������ 
;���������� �� BCDB ��� �� BCDW
;r21 �������
;------------------------------------------------------------
BCD_sub:
		push	r16
;�������� ������� �������<5
		mov		r16,r21
		andi	r16,0b00001111	;�������� ������� �������
		cpi		r16,5			; 5
		brlo	skip1
		ldi		r16,3			;��������� BCD
		add		r21,r16
skip1:	
;�������� ������� �������<5
		mov		r16,r21
		andi	r16,0b11110000	;�������� ������� �������
		cpi		r16,80			; 80
		brlo	skip2
		ldi		r16,48			;��������� BCD
		add		r21,r16
skip2:	pop		r16
		ret	

;-------------------------------------------
;������� 16 ���������� �� 16 ���������
;������� 	r1:r0
;�������� 	r17:r16
;�������  	r19:r18
;������� �� �����������
;--------------------------------------------
divide16:
		push	r20
	;������� �������� r19:r18
		ser		r18
		ser		r19
		ldi		r20,1	;������� �������
sdvig:
		inc		r20	;������� ����� �������
		lsl		r16	;�������� ��������
		rol		r17
		brcs	ldiv4	;������ �������
		cp		r0,r16	;������� ���� ������� �� ������
		cpc		r1,r17	;������ ���������
		brcc	sdvig	;������� ������- �������
		lsr		r17		;����������
ldiv3:
		ror		r16		;����� �� 1 ���
		dec		r20		;���������� � ������� �������
		clc
ldiv2:
		clt
		brcc	ldiv5	;���� ����� ������ �������� ��� �������� - �������
		set		;���� ��� ������� - ������� ���� �
ldiv5:
		sub		r0,r16	;��������
		sbc		r1,r17
		brcc	ldiv1	;�� ���� �������� - �������
		clc		
		brts	ldiv1	;��� ���������� ����� � ��������� ���� ��� �������� �������!
		add		r0,r16	;��������������� ��������� �� ���������
		adc		r1,r17
		sec				;��������������� ���� ��������
ldiv1:
		rol		r18		;�������� ���� �������� � ���������
		rol		r19
		lsl		r0		;�������� �������
		rol		r1
		dec		r20
		brne	ldiv2
		com		r18
		com		r19
		pop		r20
		ret

ldiv4:	
		ror		r17
		rjmp	ldiv3
;-------------------------------------------
;������� ������� 16 ���������� �� 16 ���������
;������� ������ ���� ������ ��������, �.� ����� ����� �� �����������
;������� 	r1:r0
;�������� 	r17:r16
;�������  	r19:r18 (������ ������� �����)
;������� �� �����������
;--------------------------------------------
ddiv:
		push	r20
	;������� �������� r19:r18
		ldi		r18,$ff
		ldi		r19,$ff
		clr		r20	;������� �������
		rjmp	ldiv13
ldiv12:
		sub		r0,r16	;��������
		sbc		r1,r17
		brcc	ldiv11	;�� ���� �������� - �������
		clc				;�������� ������� ��� ����� �� ����
		brts	ldiv11	;����� ��� �������� "1" - �������
		add		r0,r16	;��������������� ��������� �� ���������
		adc		r1,r17
		sec				;��������������� ���� ��������
ldiv11:
		rol		r18		;�������� ���� �������� � ���������
		rol		r19
ldiv13:	
		lsl		r0		;�������� �������
		rol		r1
		clt
		brcc	ldiv10
		set				;�������� ������� � T
ldiv10:	
		inc		r20
		cpi		r20,17
		brne	ldiv12
		com		r18
		com		r19
		pop		r20
		ret

;----------------------------
;��������� ���� �������
;���������� �� ����� ����� �� ������� 19:18
;-----------------------------
mydisp:
		movw	r16,r18
		rcall	bcdw
		ldi		r16,0x01		;������� ������	
		rcall	writeI
		ld		r16,Z
		rcall	writeD
		ld		r16,-Z
		rcall	writeD
		ld		r16,-Z
		rcall	writeD
		ld		r16,-Z
		rcall	writeD
		ld		r16,-Z
		rcall	writeD
FFFG:	rjmp	fffg


.eseg
;���������������� ��������� �����-������ (��������)
param:
.db $43,$B8,$BB,$61,$20,$BE,$6F,$63,$BF,$2E,$20,$BF,$6F,$BA,$61,$20 ;(0) "���� ����. ����"
.db $20,$20,$49,$63	;"  I�"
.db $22				;������� ����� 2 ������� (����� ����), *2
.db $6D,$41			;"mA"
.db 255				;255*2=5,10�� -���� �������� ���������� ������������
.db 255				;����������� ��������-1

.db $A1,$BB,$79,$B2,$B8,$BD,$61,$20,$41,$4D,$20,$BE,$6F,$63,$BF,$2E ;"������� �� ����."
.db $41,$4D,$44,$63	;"AMDc"
.db $0A	;������� ���, ��������� �� 10
.db $20,$25			;" %"
.db 9	;100% -������� �� ��� ���������� ������������
.db 255				;����������� ��������-1

.db $AB,$61,$63,$BF,$6F,$BF,$61,$20,$41,$4D,$20,$BE,$6F,$63,$BF,$2E ;"������� �� ����."
.db $41,$4D,$46,$63	;"AMFc"
.db $11	;������� ����� 1 �������,
.db $A1,$E5			;"��"
.db 200	;20�� -������� �� ��� ���������� ������������
.db 1				;����������� ��������-1= 0.2��

.db $43,$B8,$BB,$61,$20,$B8,$BC,$BE,$2E,$20,$BF,$6F,$BA,$61,$20,$20 ;"���� ���. ����"
.db $20,$20,$49,$69	;"  Ii"
.db $24	;������� ����� 2 �������, *4
.db $6D,$41			;"mA"
.db 249	;249*4=9,96�� -���� �������� ���������� ������������
.db 255				;����������� ��������-1

.db $AB,$61,$63,$BF,$6F,$BF,$61,$20,$A5,$BC,$BE,$2D,$63,$6F,$B3,$20 ;"������� ���-��� "
.db $46,$B8,$BC,$BE	;"F���"
.db $14	;������� ����� 1 �������, *4
.db $A1,$E5			;"��"
.db 249	;249*4=99,6�� -������� ���������� ���������
.db 9				;����������� �������� -1= 4��

.db $E0,$BB,$B8,$BF,$65,$BB,$C4,$BD,$2E,$A5,$BC,$BE,$2D,$63,$6F,$B3;"������������ ���-���"
.db $54,$B8,$BC,$BE	;"����"
.db $24	;������� ����� 2 �������, *4
.db $BC,$63			;"��"
.db 249	;249*4=9.96�� -������������ ��������
.db 19				;����������� ��������-1= 0.8��

.db $E0,$65,$B3,$B8,$61,$E5,$B8,$C7,$20,$AB,$4D,$20,$A5,$BC,$BE,$2E ;"�������� �� ���."
.db $46,$4D,$44,$69	;"FMDi"
.db $14	;������� ����� 1 �������, *4
.db $A1,$E5			;"��"
.db 63	;25,2�� -�������� ������� ���������� ���������
.db 255				;����������� ��������-1

.db $4D,$6F,$E3,$79,$BB,$B8,$70,$2E,$AB,$61,$63,$BF,$6F,$BF,$61,$20 ;"�������.������� "
.db $46,$4D,$46,$69	;"FMFi"
.db $24	;������� ����� 2 �������, *4
.db $A1,$E5			;"��"
.db 249	;249*4=9,96�� -������������ ������� ��
.db 9				;����������� ��������-1= 0.4��

.db $A1,$BB,$79,$B2,$B8,$BD,$61,$20,$41,$4D,$20,$A5,$BC,$BE,$79,$BB ;"������� �� �����"
.db $41,$4D,$44,$69	;"AMDi"
.db $0A	;������� ���, ��������� �� 10
.db $20,$25			;" %"
.db 9	;100% -������� �� ��� ���������� ������������
.db 255				;����������� ��������-1

.db $AB,$61,$63,$BF,$6F,$BF,$61,$20,$41,$4D,$20,$A5,$BC,$BE,$79,$BB ;"������� �� �����"
.db $41,$4D,$46,$69	;"AMFi"
.db $11	;������� ����� 1 �������
.db $A1,$E5			;"��"
.db 200	;20�� -������� �� ��� ���������� ������������
.db 1				;����������� ��������-1= 0.2��

proc_time:	
.db $42,$70,$65,$BC,$C7,$20,$BE,$70,$6F,$E5,$65,$E3,$79,$70,$C3,$20 ;"����� ���������"
.db $54,$BE,$70,$E5	; "����"  �������

default_0:	;��������� �� ��������� ������ 0
.db 128	;128*2=2.56�� 
.db 0	;0% 
.db 60	;6.0�� 
.db 64	;64*4=2.56�� 
.db 200	;200*4=80.0�� 
.db 100	;100*4=4.00��
.db 50	;50*4=20.0��
.db 80	;80*4=3.20�� 
.db 0	;0% 
.db 20	;2�� 
.db 02	;01min
.db 20	;10 sec

default_1:	;��������� �� ��������� ������ 1
.db 20	;20*2=0.40��
.db 1	;10% 
.db 70	;7.0��
.db 100	;100*4=4.00��
.db 240	;240*4=96.0��
.db 50	;50*4=2.00�� 
.db 60	;60*4=24.0��
.db 20	;20*4=0,80��
.db 0	;��� ���������
.db 70	;7��
.db 02	;01min
.db 30	;50 sec

elab1:
.db $20,$4B,$41,$48,$41,$A7,$20,$20	;�����
.db $63,$6F,$78,$70,$61,$BD
error:
.db $4F,$C1,$B8,$B2,$BA,$61,$20,$4E	;������ � (8��������)
err10:
.db $46,$B8,$BC,$BE,$2D,$46,$4D,$44,$69,$3C,$32,$A1,$E5			;F���-FMDi<2�� (13��������)
err11:
.db $32,$54,$69,$3E,$31,$2F,$28,$46,$69,$2B,$46,$4D,$44,$69,$29	;2�i>1/(Fi+FMDi) (15��������)
err12:
.db $31,$30,$46,$4D,$46,$69,$3E,$46,$69,$2D,$46,$4D,$44,$69		;10FMFi>Fi-FMDi (14��������)
savep:
.db $A4,$61,$BE,$B8,$63,$C4,$20,$BE,$61,$70,$61,$BC,$65,$BF,$70,$2E	;������ ��������.
teststring:
.db $54,$65,$63,$BF,$2E,$2E,$2E	;����...
err0:
.db $42,$C3,$78,$6F,$E3,$20,$BD,$65,$B8,$63,$BE,$70,$61,$B3,$2E ;����� ����������
err1:
.db $A8,$70,$65,$B3,$C3,$C1,$65,$BD,$20,$54,$6F,$BA,$20		;�������� ��� (13����)
err13:
.db $A8,$65,$70,$65,$BC,$6F,$E3,$79,$BB,$C7,$E5,$B8,$C7,$20;������������� (14)
