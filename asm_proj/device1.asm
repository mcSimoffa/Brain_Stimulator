;**********************        РЕГИСТРЫ     ****************************
;r1:r0- используется при умножении и делении
;r3:r2 - значение аккумулятора в формирователе АМ канала ЦАП №0
;r5:r4 - значение аккумулятора в формирователе АМ канала ЦАП №1
;r7:r6 - значение аккумулятора в формирователе АМ канала ЦАП №2
;r9:r8 - значение аккумулятора в формирователе АМ канала ЦАП №3
;r11:r10- значение аккумулятора в формирователе ЧМ левого канала
;r13:r12- значение аккумулятора в формирователе ЧМ правого канала
;r14 0-сброс r15 (нет звука). 1...255 остаточная длительность ноты. 1=64мс.
;r15 биты разрешения гармоник (1-разрешено 0-запрет) и номер редактируемого канала
	;бит0	генерация звука частоты 1600Гц
	;бит1	генерация звука частоты 800Гц
	;бит2	генерация звука частоты 400Гц
	;бит3	генерация звука частоты 200Гц
	;бит4	генерация звука частоты 100Гц
	;бит5   номер редактир канала в меню 1,2 и 3 уровня
	;бит6	импульсы быстрого мигания LED
	;бит7	импульсы медленного мигания LED
;==========================================
;r16-временный
;r17-временный
;r18-временный
;r19-временный
;r20-временный
;r21-временный
;r22-байт состояни светодиодов
;r23-счетчик задержки пользовательского цикла. 1 декремент=512мкс
;r24-временный
;r25-временный
;r26 - флаги выполнения процедуры 0 канала;
	;бит 0 -запущена процедура
	;бит 1 -канал в состоянии паузы (0-пауза 1-нет паузы)
	;бит 2 -плавное нарастание токов активно
	;бит 3 -плавный спад токов активен
	;бит 4 -АМ модуляция постоянной составляющей (0в -  1в +)
	;бит 5 -АМ модуляция импульсного тока (0в -  1в +)
	;бит 6 -ЧМ модуляция импульсного тока (0в -  1в +)
	;бит 7 -свободен
;r27 - флаги выполнения процедуры 1 канала;
;r28-индексные
;r29-индексные
;r30-индексные
;r31-индексные
.equ	Int_Mask_Outside=0b10011010
.equ	Int_Mask_Inside= 0b00000010

.dseg	;***************************  RAM  ************************************
.org $0060
DACstate:	.byte 1	;состояния выходов дельта-ЦАП;$0060
keystate:	.byte 1	;состояние кнопок 1-8 (0 - нажата 1 - отжата)
keynew:		.byte 1  ;флаги кнопок 1-8 изменивших свое состояние (1-изм, 0-старое)
keytime:	.byte 1	;счетчик времени удержанных кнопок 1-8. 1сек=16
;результат BCD в неупакованном коде индикатора (3 в старшей тетрде)
bcdres0:	.byte 1	;$0064	0-й разряд 
bcdres1:	.byte 1 ;$0065  1-разряд BCDB
bcdres2:	.byte 1 ;$0066	2-разряд BCDB
bcdres3:	.byte 1 ;$0067	3-разряд BCDW
bcdres4:	.byte 1 ;$0068	4-разряд BCDW
kanal:		.byte 1 ;-адрес ячейки ($006A...$006F) для работы АЦП (по сути это канал АЦП) 
DACdata0:	.byte 1 ;- задание: постоянная составляющая канал 0 (АЦП №0)
DACdata1:	.byte 1	;- задание: импульсная составляющая канал 0 (АЦП №1)
DACdata2:	.byte 1 ;- задание: постоянная составляющая канал 1 (АЦП №2)
DACdata3:	.byte 1 ;- задание: импульсная составляющая канал 1 (АЦП №3)
amper0:		.byte 1 ;- замер среднего тока канал 0 (АЦП №4)
amper1:		.byte 1 ;- замер среднего тока канал 1 (АЦП №5)
param0:	.byte 12 ;- параметр №0-10.2 канала 0 (от $0070 до $007B включительно)
;0	сила пост тока 			0...128 (5.12мА)
;+1 глубина АМ пост			0...9	(100%)
;+2 частота АМ модуляции   	2...200 (20Гц)
;+3 сила импульсного тока  	0...128 (5.12мА)
;+4 Частота импульсов		10..249 (99.6Гц)
;+5 Длительность импульса	20..249 (9.96мс)
;+6 Девиация частоты ЧМ		0...63  (25.2Гц)
;+7 Модултрующая частота	10..249 (9.96Гц)
;+8 глубина АМ имп			0...9	(100%)
;+9 Частота АМ импульсного	2...200	 (20Гц)
;+10	минуты				0...99
;+11	секунды 			0...59
sec0:	.byte 1	;- остаток секунды канал 0 ($007C)
min0:	.byte 1	;- остаток минуты канал 0
sec1:	.byte 1	;- остаток секунды канал 1
min1:	.byte 1	;- остаток минуты канал 1
param1:	.byte 12 ;- параметр №0-10.2 канала 1 (от $0080 до $008B включительно)

.org $008C	
.byte 4	;свободно
am_data0:
	.byte 1	;0 -верхний предел задания АЦП №0 при АМ
	.byte 1	;+1-нижний предел задания АЦП №0 при АМ
	.byte 2 ;+3:+2 -приращение аккумулятора на 1 такт переполнения
am_data1:	.byte 4
am_data2:	.byte 4
am_data3:	.byte 4
fm_data0:
	.byte 1	; 0 -верхний предел девиации частоты (63)
	.byte 1	;+1-нижний предел девиации частоты  (-63)
	.byte 2 ;+3:+2 -приращение аккумулятора на 1 такт переполнения
	.byte 1 ;+4 мгновенное значение девиации (со знаком) +63...-63
	.byte 1 ;+5 центральная частота (копия param +4)
	.byte 2 ;+7:+6 приращение таймера для длительности импульса
fm_data1:	.byte 8

RTC:		.byte 1	;Real Time Counter-внутренний счетчик времени по модулю 125.+4 каждые 32мс. 125imp=1сек

.cseg	;******************      ПРОГРАММА        ***********************
.include "m8535def.inc"
; тактирование 8МГц

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
;прерывание на переключение импульса канала 0
;длительность 338 такт на расчете паузы или 44 на расчете импульса
;тайминг паузы=5*62500/(центр част+мгнов девиация)
;для избежания переполнения миним частота должна >=5уе (2Гц)
;Валидация не должна пропустить Fmin=Fi-DFi < 5 уе
;пауза должна быть как минимум половина от минимального периода
;Тимп<=1/2(Fi+DFi). Расчет в уе^ Timp<=31250/(Fi+DFi) - должна проверить процедура валидации
;модулирующая частота должна быть вчетверо меньше Fmin=Fi-DFi
;Частота вызовов 5импульсов(*64) на каждые 0,04мс
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
	sbis	PIND,4		;пропустить если началась пауза(бит OC1B=1)
	rjmp	CH1_Signal_1
;сгенерировано начало паузы
	
	ldi 	r16,Int_Mask_Inside
	out 	TIMSK,r16
	sei		;разрешить прерывания только от совпадение Т0
		
	lds		r16,fm_data0+5	;центральная частота
	lds		r17,fm_data0+4	;мгновенная девиация
	sbrs	r17,7			;девиация отрицательна ? - пропуск
	rjmp	CH1_PositivDirect_Deviation
	neg		r17
	sub		r16,r17			;r16=текущая частота=центр-девиация
	clr		r17
	rjmp	CH1_timing_calculate
CH1_PositivDirect_Deviation:
	add		r16,r17
	clr		r17
	adc		r17,r17		;r17:r16=центр част+мгнов девиация
CH1_timing_calculate:
	ldi		r19,high(62500)
	ldi		r18,low(62500)
	movw	r0,r18
	rcall	divide16	;r19:r18=62500/(центр част+мгнов девиация)
	movw	r16,r18
	lsl		r18
	rol		r19		;*2
	lsl		r18
	rol		r19		;*4
	add		r16,r18
	adc		r17,r19	;r17:r16=5*62500/(центр част+мгнов девиация)
	lds		r18,fm_data0+6	;длительность импульса
	lds		r19,fm_data0+7
	sub		r16,r18
	sbc		r17,r19		;длительность паузы=период-длительность импульса

	cli
	ldi 	r18,Int_Mask_Outside
	out 	TIMSK,r18

	rjmp	OCR1B_Modified
CH1_Signal_1:				;Начался жалящий импульс
	lds		r16,fm_data0+6	;приращение	
	lds		r17,fm_data0+7
OCR1B_Modified:
	in		r18,OCR1BL		;предыдущее значение	
	in		r19,OCR1BH
	add		r18,r16
	adc		r19,r17			;новое значение
	out		OCR1BH,r19
	out		OCR1BL,r18		;сохранить в регистре сравнения
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
;прерывание на переключение импульса канала 1
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
	sbis	PIND,5		;пропустить если началась пауза(бит OC1A=1)
	rjmp	CH2_Signal_1
;сгенерировано начало паузы
	
	ldi 	r16,Int_Mask_Inside
	out 	TIMSK,r16
	sei		;разрешить прерывания только от совпадение Т0
		
	lds		r16,fm_data1+5	;центральная частота
	lds		r17,fm_data1+4	;мгновенная девиация
	sbrs	r17,7			;девиация отрицательна ? - пропуск
	rjmp	CH2_PositivDirect_Deviation
	neg		r17
	sub		r16,r17			;r16=текущая частота=центр-девиация
	clr		r17
	rjmp	CH2_timing_calculate
CH2_PositivDirect_Deviation:
	add		r16,r17
	clr		r17
	adc		r17,r17		;r17:r16=центр част+мгнов девиация
CH2_timing_calculate:
	ldi		r19,high(62500)
	ldi		r18,low(62500)
	movw	r0,r18
	rcall	divide16	;r19:r18=62500/(центр част+мгнов девиация)
	movw	r16,r18
	lsl		r18
	rol		r19		;*2
	lsl		r18
	rol		r19		;*4
	add		r16,r18
	adc		r17,r19	;r17:r16=5*62500/(центр част+мгнов девиация)
	lds		r18,fm_data1+6	;длительность импульса
	lds		r19,fm_data1+7
	sub		r16,r18
	sbc		r17,r19		;длительность паузы=период-длительность импульса

	cli
	ldi 	r18,Int_Mask_Outside
	out 	TIMSK,r18

	rjmp	OCR1A_Modified
CH2_Signal_1:				;Начался жалящий импульс
	lds		r16,fm_data1+6	;приращение	
	lds		r17,fm_data1+7
OCR1A_Modified:
	in		r18,OCR1AL		;предыдущее значение	
	in		r19,OCR1AH
	add		r18,r16
	adc		r19,r17			;новое значение
	out		OCR1AH,r19
	out		OCR1AL,r18		;сохранить в регистре сравнения
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
;быстрое прерывание для просчета модуляций
;период вызова 64мкс (512 тактов)
;длительность 146 тактов максимум
;-----------------------------------------------
TIM0_COMP:
		push	r16
		in		r16,sreg
		push	r16
		push	r17

;------------ проверка включения левого канала -----------------
		ldi		r16,0b00001111	;высветить включение, паузу, плавный рост/спад
		and		r16,r26
		cpi		r16,0b00000011
		breq	_Start_DAC0
		rjmp	_Start_RightCH

_Start_DAC0:	;левый канал включен
;------   АМ   для  ЦАП  №0  -------------------
		lds		r16,am_data0+2	;приращение дробного счетчика
		lds		r17,am_data0+3
		add		r2,r16			;аккумулировать выдержку
		adc		r3,r17
		brcc	_Start_DAC1		;не требуется изменение задания ЦАП0 - переход к ЦАП1
		sbrs	r26,4			;бит АМc в + установлен ? - пропуск
		rjmp	_AMDown0		;не установлен - модуляция вниз
		;модуляция вверх
		lds		r16,DACdata0	;текущее значение задания ЦАП
		lds		r17,am_data0	;верхний предел
		cpse	r16,r17			;сравнить текущее с верхним пределом
		rjmp	_NoUpLim0		;не достигнут верх
		cbr		r26,16			;достигнуто ограничение-сменить направление модуляции
		rjmp	_Start_DAC1
_NoUpLim0:		;не достигнуто  ограничение вверх
		inc		r16				
		sts		DACdata0,r16	;дать это задание ЦАП
		rjmp	_Start_DAC1
_AMDown0:	;модуляция вниз
		lds		r16,DACdata0
		lds		r17,am_data0+1	;нижний предел
		cpse	r16,r17			;сравнить с нижним пределом
		rjmp	_NoDownLim0		;не достигнуто ограничение
		sbr		r26,16			;достигнуто - установить направление модуляции вверх
		rjmp	_Start_DAC1
_NoDownLim0:	;не достигнуто  ограничение
		dec		r16
		sts		DACdata0,r16	;дать это задание ЦАП

;------   АМ   для  ЦАП  №1  -------------------
_Start_DAC1:	;АМ в канале ЦАП №1
		lds		r16,am_data1+2	;приращение дробного счетчика
		lds		r17,am_data1+3
		add		r4,r16			;аккумулировать выдержку
		adc		r5,r17
		brcc	_Start_FM0		;не требуется изменение задания ЦАП
		sbrs	r26,5			;бит АМи в + установлен ? - пропуск
		rjmp	_AMDown1		;не установлен - модуляция вниз
		;модуляция вверх
		lds		r16,DACdata1	;текущее значение задания ЦАП
		lds		r17,am_data1	;верхний предел
		cpse	r16,r17			;сравнить текущее с верхним пределом
		rjmp	_NoUpLim1		;не достигнут верх
		cbr		r26,32			;достигнуто ограничение-сменить направление модуляции
		rjmp	_Start_FM0
_NoUpLim1:	;не достигнуто  ограничение
		inc		r16				
		sts		DACdata1,r16	;дать это задание ЦАП
		rjmp	_Start_FM0
_AMDown1:	;модуляция вниз
		lds		r16,DACdata1
		lds		r17,am_data1+1	;нижний предел
		cpse	r16,r17			;сравнить с нижним пределом
		rjmp	_NoDownLim1		;не достигнуто ограничение
		sbr		r26,32			;достигнуто - установить направление модуляции вверх
		rjmp	_Start_FM0
_NoDownLim1:	;не достигнуто  ограничение
		dec		r16
		sts		DACdata1,r16	;дать это задание ЦАП

;------   ЧМ   в левом канале   -------------------
_Start_FM0:	;FM в канале 0	
		lds		r16,fm_data0+2	;приращение дробного счетчика
		lds		r17,fm_data0+3
		add		r10,r16			;аккумулировать выдержку
		adc		r11,r17
		brcc	_Start_RightCH	;не требуется изменение коэфф деления таймера Т1 
		sbrs	r26,6			;бит FM в + установлен ? - пропуск
		rjmp	_FMDown0		;не установлен - модуляция вниз по частоте
		;модуляция вверх по частоте
		lds		r16,fm_data0+4	;текущее значение девиации частоты
		lds		r17,fm_data0	;верхний предел
		cpse	r16,r17			;сравнить текущее с верхним пределом
		rjmp	_NoUpFMLim0		;не достигнут верх
		cbr		r26,64			;достигнуто ограничение-сменить направление модуляции
		rjmp	_Start_RightCH
_NoUpFMLim0:	;не достигнуто  ограничение девиации вверх
		inc		r16				
		sts		fm_data0+4,r16	;сохранить начение девиации
		rjmp	_Start_RightCH
_FMDown0:		;модуляция вниз
		lds		r16,fm_data0+4	;текущее значение девиации частоты
		lds		r17,fm_data0+1	;нижний предел
		cpse	r16,r17			;сравнить с нижним пределом
		rjmp	_NoDownFMLim0	;не достигнуто ограничение
		sbr		r26,64			;достигнуто - установить направление модуляции вверх
		rjmp	_Start_RightCH
_NoDownFMLim0:	;не достигнуто  ограничение
		dec		r16
		sts		fm_data0+4,r16	;сохранить начение девиации
		
		
_Start_RightCH:	

;------------ проверка включения правого канала -----------------
		ldi		r16,0b00001111	;высветить включение, паузу, плавный рост/спад
		and		r16,r27
		cpi		r16,0b00000011
		breq	_Start_DAC2
		rjmp	_ENDI
;------   АМ   для  ЦАП  №2  -------------------
_Start_DAC2:	;АМ в канале ЦАП №2
		lds		r16,am_data2+2	;приращение дробного счетчика
		lds		r17,am_data2+3
		add		r6,r16			;аккумулировать выдержку
		adc		r7,r17
		brcc	_Start_DAC3		;не требуется изменение задания ЦАП
		sbrs	r27,4			;бит АМc в + установлен ? - пропуск
		rjmp	_AMDown2		;не установлен - модуляция вниз
		;модуляция вверх
		lds		r16,DACdata2	;текущее значение задания ЦАП
		lds		r17,am_data2	;верхний предел
		cpse	r16,r17			;сравнить текущее с верхним пределом
		rjmp	_NoUpLim2		;не достигнут верх
		cbr		r27,16			;достигнуто ограничение-сменить направление модуляции
		rjmp	_Start_DAC3
_NoUpLim2:		;не достигнуто ограничение верх
		inc		r16				
		sts		DACdata2,r16	;дать это задание ЦАП
		rjmp	_Start_DAC3
_AMDown2:	;модуляция вниз
		lds		r16,DACdata2
		lds		r17,am_data2+1	;нижний предел
		cpse	r16,r17			;сравнить с нижним пределом
		rjmp	_NoDownLim2		;не достигнуто ограничение
		sbr		r27,16			;достигнуто - установить направление модуляции вверх
		rjmp	_Start_DAC3
_NoDownLim2:	;не достигнуто  ограничение
		dec		r16
		sts		DACdata2,r16	;дать это задание ЦАП

;------   АМ   для  ЦАП  №3  -------------------
_Start_DAC3:	;АМ в канале ЦАП №3
		lds		r16,am_data3+2	;приращение дробного счетчика
		lds		r17,am_data3+3
		add		r8,r16			;аккумулировать выдержку
		adc		r9,r17
		brcc	_Start_FM1		;не требуется изменение задания ЦАП
		sbrs	r27,5			;бит АМи в + установлен ? - пропуск
		rjmp	_AMDown3		;не установлен - модуляция вниз
		;модуляция вверх
		lds		r16,DACdata3	;текущее значение задания ЦАП
		lds		r17,am_data3	;верхний предел
		cpse	r16,r17			;сравнить текущее с верхним пределом
		rjmp	_NoUpLim3		;не достигнут верх
		cbr		r27,32			;достигнуто ограничение-сменить направление модуляции
		rjmp	_Start_FM1
_NoUpLim3:	;не достигнуто  ограничение верх
		inc		r16				
		sts		DACdata3,r16	;дать это задание ЦАП
		rjmp	_Start_FM1
_AMDown3:	;модуляция вниз
		lds		r16,DACdata3
		lds		r17,am_data3+1	;нижний предел
		cpse	r16,r17			;сравнить с нижним пределом
		rjmp	_NoDownLim3		;не достигнуто ограничение
		sbr		r27,32			;достигнуто - установить направление модуляции вверх
		rjmp	_Start_FM1
_NoDownLim3:	;не достигнуто  ограничение
		dec		r16
		sts		DACdata3,r16	;дать это задание ЦАП				

_Start_FM1:

;------   ЧМ   в правом канале   -------------------
		lds		r16,fm_data1+2	;приращение дробного счетчика
		lds		r17,fm_data1+3
		add		r12,r16			;аккумулировать выдержку
		adc		r13,r17
		brcc	_ENDI			;не требуется изменение коэфф деления таймера Т1 
		sbrs	r27,6			;бит FM в + установлен ? - пропуск
		rjmp	_FMDown1		;не установлен - модуляция вниз по частоте
		;модуляция вверх по частоте
		lds		r16,fm_data1+4	;текущее значение девиации частоты
		lds		r17,fm_data1	;верхний предел
		cpse	r16,r17			;сравнить текущее с верхним пределом
		rjmp	_NoUpFMLim1		;не достигнут верх
		cbr		r27,64			;достигнуто ограничение-сменить направление модуляции
		rjmp	_ENDI
_NoUpFMLim1:	;не достигнуто  ограничение девиации вверх
		inc		r16				
		sts		fm_data1+4,r16	;сохранить начение девиации
		rjmp	_ENDI
_FMDown1:		;модуляция вниз
		lds		r16,fm_data1+4	;текущее значение девиации частоты
		lds		r17,fm_data1+1	;нижний предел
		cpse	r16,r17			;сравнить с нижним пределом
		rjmp	_NoDownFMLim1	;не достигнуто ограничение
		sbr		r27,64			;достигнуто - установить направление модуляции вверх
		rjmp	_ENDI
_NoDownFMLim1:	;не достигнуто  ограничение
		dec		r16
		sts		fm_data1+4,r16	;сохранить начение девиации

_ENDI:
		pop		r17
		pop		r16
		out		sreg,r16
		pop		r16
		reti

;------------------------------------------------------------
ADC_CC:
;расчет номера канала АЦП для следующего запуска
;kanal приходит с номером для которого начато новое преобразование
	push	r16
	in		r16,sreg
	push	r16
	push	r17
	push	r18
	push	r29
	push	r28
	lds		r28,kanal
	in		r16,PINB	;чтение состояния порта B
	andi	r16,$0F		;затираем B4...B7
	lds		r18,DACstate
	or		r18,r16		;сводим в r18 байт выходного сигнала порта B
	ldi		r16,$FF		;порт B все выходы
	out		DDRB,r16

	ldi 	r16,Int_Mask_Inside
	out 	TIMSK,r16
	sei		;разрешить прерывания только от совпадение Т0
	
	dec		r28			;расчет номера ячейки для канала с завершенным АЦП
	cpi		r28,DACdata0
	brsh	CnanNumModuloDown		;канал не отрицательный ? (>=DACdata0)
	subi	r28,256-6	;если отрицательный то +6
CnanNumModuloDown:
	clr		r29
	ld		r16,Y		;прочесть задание
	in		r17,ADCH	;Прочесть замер напряжения	
	cp		r17,r16		;факт < задания ? - установка флага C=1
	in		r16,sreg	;сохранение SREG
	bst		r16,0		;сохранить С во флаге Т
	cpi		r28,DACdata0		;это канал 0 ?
	breq	ChanIs1
	cpi		r28,DACdata1		;это канал 1 ?
	breq	ChanIs2
	cpi		r28,DACdata2		;это канал 2 ?
	breq	ChanIs3
	cpi		r28,DACdata3		;это канал 3 ?
	breq	ChanIs4
	st		Y,r17		;для каналов 4 и 5 сохраняем результат АЦП
	rjmp	EndSelectChanDAC
ChanIs1:
	bld		r18,4		;факт<задания - разряд4=1. Иначе=0
	dec		r23			;пользовательский таймер на уменьшение 4000/32/13/6=1600Гц
	mov		r16,r15		;извлечь маску гармоник звука
	and		r16,r23		;проявить отмеченные для звука биты
	andi	r16,0b00011111	;вуалировать незначащие биты
	breq	Buzzer_Low
	sbi		PORTA,7		;фронт на зуммер
	rjmp	Buzzer_High
Buzzer_Low:	
	cbi		PORTA,7		;спад на зуммер	
Buzzer_High:
	rjmp	EndSelectChanDAC
ChanIs2:
	bld		r18,5		;факт<задания - разряд5=1. Иначе=0
	rjmp	EndSelectChanDAC				
ChanIs3:
	bld		r18,6		;факт<задания - разряд6=1. Иначе=0
	rjmp	EndSelectChanDAC
ChanIs4:
	bld		r18,7		;факт<задания - разряд7=1. Иначе=0
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
	cbi		PORTB,3			;записать в регистр 74HC573
	ldi		r16,0b00001111	;B0..B3 выходы B4...B7 входы(опрос клавиатурной матрицы)
	out		DDRB,r16		;Порт В
	ldi		r16,$F0			;подтягивающие резисторы B4...B7 включить
	or		r16,r18			;восстановить B0..B3			;
	out		PORTB,r16
	ldi		r16,$F0
	and		r18,r16			;оставить в r18 только информацию о выходах ЦАП
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
;цикличность 128мкс*250=32мс  (30,4раз в сек)
;максимальная длительность ???
;ведется обратный отсчет длительности ноты RTC
;при достижении 0 нота маскируется на 31 (нет звука)
;идет обратный отсчет времени процедуры активных каналов.
;при достижении 0 снимается флаг активности процедуры в соответствующем канале 
;------------------------------------------------------------
;опрос клавиатуры 30 раз в сек (каждые 32мск)
		cbi		PORTD,0
		sbi		PORTD,1
		sbi		PORTD,2		;1-я линия опроса
;сохранение состояние попутно используется как задержка на 9 тактов
		push	r16
		in		r16,sreg
		push	r16
		push	r17
		push	r18

		in		r17,PINB	;опрос младшей тетрады 
		swap	r17			;перенести в младшую тетраду
		andi	r17,$0F		;обнулить старшую тетраду
		sbi		PORTD,0		;2-я линия опроса	
		cbi		PORTD,2
;слежение за остаточной длительностью ноты попутно используется как задержка на 3 такт
		dec		r14			;отсчет длительности ноты
		brne	soundon		;если не закончилась - перейти
		ldi		r16,0b11100000	;закончилась - замаскировать
		and		r15,r16			;звук
soundon:
		nop
		nop
		nop
		in		r18,PINB	;опрос старшей тетрады
		andi	r18,$F0		;обнулить младшую тетраду
		or		r17,r18		;свести в r17 8 кнопок
		lds		r18,keystate;прочесть предыдущие значения кнопок
		eor		r18,r17		;изменившие состояние кнопки будут 1
		sts		keystate,r17;обновить текущее состояние нажатий
		sts		keynew,r18	;обновить флаги кнопок, изменивших свое состояние
		or		r17,r18		;получить информацию начато ли удерживание
		lds		r18,keytime	;извлечь счетчик времени удержания кнопки
		cpi		r17,$FF		;если меньше чем FF, то начата попытка удержания клавиши
		brne	Key_Is_Drop		;удержаниe ? - перейти
		clr		r18			;обнулить счетчик времени удержания
		rjmp	endkb
Key_Is_Drop:
		sbrs	r18,5		;прошло 32 цикла ?(1сек)
		inc		r18			;не прошло - исполнить прошло - перейти
endkb:						;прошло
		sts		keytime,r18		;сохранить значение счетчика на место
		sbi		PORTD,2

		ldi 	r16,Int_Mask_Inside
		out 	TIMSK,r16
		sei		;разрешить прерывания только от совпадение Т0

;анализ плавных нарастаний и спадов
		clt	;сбросить флаг Т как признак завершения плавного спада
		sbrs	r26,3		;проверка активности плавного спада канал 0
		rjmp	CH0_analis_of_Growth		;неактивен - перейти
		lds		r16,DACdata0	;задание с учетом плавных
		tst		r16			;=0?
		breq	DAC_CH0_Is0	;=0 - перейти
		dec		r16
		set
		sts		DACdata0,r16
DAC_CH0_Is0:
		lds		r16,DACdata1	;задание с учетом плавных
		tst		r16			;=0?
		breq	DAC_CH1_Is0		;=0 - перейти
		dec		r16
		set
		sts		DACdata1,r16
DAC_CH1_Is0:
		brts	CH0_analis_of_Growth	;если был хотя-бы 1 плавный спад, то перейти
		andi	r26,0b11110111	;не было спадов - сброс флага плавного спада

CH0_analis_of_Growth:	
		clt		;сброить флаг Т как признак завершения плавного роста
		sbrs	r26,2		;проверка активности плавного роста канал 0
		rjmp	CH2_analis_Decline		;неактивен - перейти
		lds		r16,DACdata0	;задание с учетом плавных
		lds		r17,param0	;исходное задание
		cp		r16,r17		;r16 сравнить с r17  ?
		brsh	DAC_CH0_IsMax		;r16>=r17 - перейти
		inc		r16			;r16<r17 (недоросло)
		set					;отметить флаг Т как "плавный рост не завершен"
		sts		DACdata0,r16
DAC_CH0_IsMax:
		lds		r16,DACdata1	;задание с учетом плавных
		lds		r17,param0+3;исходное задание
		cp		r16,r17		;r16 сравнить с r17  ?
		brsh	DAC_CH1_IsMax		;r16>=r17 - перейти
		inc		r16			;r16<r17 (недоросло)
		set					;отметить флаг Т как "плавный рост не завершен"
		sts		DACdata1,r16
DAC_CH1_IsMax:
		brts	CH2_analis_Decline		;если был хотя-бы 1 плавный рост, то перейти
		andi	r26,0b11111011	;не было ростов - сброс флага плавного роста
CH2_analis_Decline:
		clt	;сбросить флаг Т как признак завершения плавного спада
		sbrs	r27,3		;проверка активности плавного спада канал 1
		rjmp	CHR_analis_of_Growth		;неактивен - перейти
		lds		r16,DACdata2		;задание с учетом плавных
		tst		r16			;=0?
		breq	DAC_CH2_Is0		;=0 - перейти
		dec		r16
		set
		sts		DACdata2,r16
DAC_CH2_Is0:
		lds		r16,DACdata3		;задание с учетом плавных
		tst		r16			;=0?
		breq	DAC_CH3_Is0		;=0 - перейти
		dec		r16
		set
		sts		DACdata3,r16
DAC_CH3_Is0:
		brts	CHR_analis_of_Growth	;если был хотя-бы 1 плавный спад, то перейти
		andi	r27,0b11110111	;не было спадов - сброс флага плавного спада
CHR_analis_of_Growth:
		clt		;сброст=ит флаг Т как признак завершения плавного роста
		sbrs	r27,2		;проверка активности плавного роста канал 1
		rjmp	Ltim_16		;неактивен - перейти
		lds		r16,DACdata2	;задание с учетом плавных
		lds		r17,param1		;исходное задание
		cp		r16,r17		;r16 сравнить с r17  ?
		brsh	Ltim_14		;r16>=r17 - перейти
		inc		r16			;r16<r17 (недоросло)
		set
		sts		DACdata2,r16
Ltim_14:
		lds		r16,DACdata3	;задание с учетом плавных
		lds		r17,param1+3;исходное задание
		cp		r16,r17		;r16 сравнить с r17  ?
		brsh	Ltim_13		;r16>=r17 - перейти
		inc		r16			;r16<r17 (недоросло)
		set
		sts		DACdata3,r16
Ltim_13:
		brts	Ltim_16		;если был хотя-бы 1 плавный рост, то перейти
		andi	r27,0b11111011	;не было ростов - сброс флага плавного роста
Ltim_16:

;подсчет импульсов для формирования секундных интервалов
		ldi		r18,256-4
		lds		r16,RTC
		bst		r16,3		;импульсы быстрого мигания
		bld		r15,6		;сохранить в r15.6
		bst		r16,6		;импульсы медленного мигания
		bld		r15,7		;сохранить в r15.7
		sub		r16,r18		;отсчет секундных интервалов (+4)
		ldi		r18,125
		cp		r16,r18		;не прошла 1 сек ?
		sts		RTC,r16
		brlo	run125		;переход
		sub		r16,r18		;прошла 1 сек - вычесть
		sts		RTC,r16
;обратный отсчет в таймерах		
		sbrs	r26,1		;процедура в 0 канале не на паузе?
		rjmp	kan2		;пауза активна - перейти
		;уменьшить таймер левого канала на 1 сек
		lds		r16,sec0	;прочитать остаток времени
		lds		r17,min0
		subi	r16,1		;уменьшение на секунду остатка в канале 0
		brsh	kan1end		;секунды не сделали заем ? -перейти
		ldi		r16,59		;сделали - установить 59 секунд
		sbci	r17,0		;вычесть минуты (был перенос в секундах)
		brsh	kan1end		;в минутах нет переноса - перейти
		ldi		r26,0b00001000	;процедура стоп и пауза, плавный спад
		ldi		r18,10			;320мсек
		mov		r14	,r18
		set
		bld		r15,0			;частота 1600Гц

kan1end:
		sts		sec0,r16	;вернуть обновленный остаток времени
		sts		min0,r17
kan2:
		sbrs	r27,1		;процедура в 1 канале не на паузе?
		rjmp	run125		;пауза активна - перейти	
		;уменьшить таймер правого канала на 1 сек 
		lds		r16,sec1	;r16-секунды r17-минуты канала 1
		lds		r17,min1
		subi	r16,1		;уменьшение на секунду остатка в канале 1
		brsh	kan2end		;секунды не сделали заем ? -перейти
		ldi		r16,59		;сделали - установить 59 секунд
		sbci	r17,0		;вычесть минуты (был перенос в секундах)
		brsh	kan2end		;в минутах нет переноса - перейти
		ldi		r27,0b00001000	;процедура стоп и пауза, плавный спад
		ldi		r18,10		;320мсек
		mov		r14	,r18
		set
		bld		r15,0			;частота 1600Гц
kan2end:
		sts		sec1,r16		;вернуть обновленный остаток времени
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
;                                Основная программа
;----------------------------------------------------------------------------------------------
;**********************************************************************************************
RESET:	
		ldi 	r16,high(ramend) 
		out	 	SPH,r16 	  	; Set Stack Pointer to top of RAM
		ldi 	r16,low(ramend)
		out 	SPL,r16

		ldi		r16,0b00100000	;канал 0, выравнивание слева, внешний ИОН
		out		ADMUX,r16		;АЦП
		in		r16,SFIOR
		andi	r16,0b00011111	;стереть разряды ADTS регистра SFIOR
		out		SFIOR,r16
		ldi		r16,0b11101110	;непрерывное f=8000/64=125кГц. Запуск сразу
		out		ADCSRA,r16		;параметры АЦП

		ldi 	r16,Int_Mask_Outside 	;совпадение Т0,T1A,T1B,T2
		out 	TIMSK,r16		;разрешить

		ldi 	r16,0b00001010	;clk/8(T=1us) сброс при совпадении
		out 	TCCR0,r16		;настройка таймера T0
		ldi		r16,64			;1мкс*64=64мкс (каждые 512 тактов)
		out		OCR0,r16

		ldi 	r16,0b00001111	;T=1/(8*10^6*1024)=128us , CTC
		out 	TCCR2,r16		;настройка таймера T2
		ldi		r16,249			;128us*250=32мсек
		out		OCR2,r16

		
		ldi		r16,0b00000000	;normal,отключен от OCC1B и OCC1A (будет инверсия OCC1B и OCC1A 0b01010000)
		out 	TCCR1A,r16		;настройка таймера T1
		ldi		r16,0b00000011	;Т1 запуск с 8е6/64=125кГц,normal,
		out 	TCCR1B,r16	
		clr		r16				;Обнулить
		out 	OCR1AH,r16		;начальные
		out 	OCR1AL,r16		;значения
		out 	OCR1BH,r16		;регистров
		out 	OCR1BL,r16		;сравнения
		
		ldi		r16,0b11000000	;A0...A5 входы A6 A7 выходы
		out		DDRA,r16		;Порт А
		ldi		r16,0b00000000	;подтягивающие резисторы
		out		PORTA,r16		;отключить от PORTA

		ldi		r16,0b00001111	;B0..B3 выходы B4...B7 входы(опрос клавиатурной матрицы)
		out		DDRB,r16		;Порт В
		ldi		r16,$F0			;подтягивающие резисторы включить
		out		PORTB,r16

		ldi		r16,0			;все входы
		out		DDRC,r16		;Порт С
		ser		r16				;подтягивающие резисторы
		out		PORTC,r16		;ко входам

		ldi		r16,0b11111111	;все выходы (D0...D2 -опрос клав матр) 
		out		DDRD,r16		;Порт D
		
		ldi		r16,0b00110111	;D0...D2 = 1 
		out		PORTD,r16		;На выходах D

		clr		r15				;регистр звука: нет звука
		sei		;включить прерывания

;пауза для старта АЦП с каналом 0, чтобы переключать на ходу, заодно очистка ОЗУ
		clr		r17		
		ldi		r30,$6A  	;от $006A 
		ldi		r16,$A0		;до $00A0
		clr		r31		
paus20:	st		Z+,r17
		cpse	r30,r16	
		rjmp	paus20

		ldi		r16,DACdata1		;подготавливаем переключение АЦП	
		sts		kanal,r16		 	;на канал 1
		ldi		r16,0b00100001
		out		ADMUX,r16

;чтение умолчаний параметров из ПЗУ	канала 0	
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
;чтение умолчаний параметров из ПЗУ	канала 1		
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
;переброска параметров №10(время) из дефолтного хранилища в рабочее
		lds		r16,param0+11
		sts		sec0,r16
		lds		r16,param0+10
		sts		min0,r16

		lds		r16,param1+11
		sts		sec1,r16
		lds		r16,param1+10
		sts		min1,r16
;гашение светодиодов
		clr		r22
		rcall	OUT_LED
;выключение каналов при старте
		clr		r26
		clr		r27
								
		
;------------------------------------------------------
;  инициализация ЖКИ
;------------------------------------------------------
		ldi		r23,30		;пауза 30*0.5=15ms
		rcall	Waitt
		rcall	SEND30
		ldi		r23,8		;пауза 8*0.5=4ms
		rcall	Waitt
		rcall	SEND30
		ldi		r23,1		;пауза 1*0.5=0.5ms
		rcall	Waitt
		rcall	SEND30 
		ldi		r16,0b00111000	;двухстрочный режим 8 битная шина
		rcall	writeI
		ldi		r16,0b00001100	;вывод изображения, курсор не виден
		rcall	writeI
		ldi		r16,0b00000110	;автосдвиг курсора вправо,без сдвига экрана
		rcall	writeI
		rcall	Start_test		;диагностика выходных цепей
		sbi		PORTD,3			;Включить реле (готовность выходов проверена)

clrscr:
		ldi		r16,0x01		;очистка экрана	
		rcall	writeI
;----------------------	
;главное меню УРОВЕНЬ 0
;----------------------
LEVEL_0:
		;1 строка
		ldi		r18,0		;№ отображаемого параметра меню 2 уровня
		ldi		r16,0b10000000	;курсор в 0 позицию
		rcall	writeI
		ldi		r16,$30	;0
		rcall	writeD
		ldi		r16,$29	;)
		rcall	writeD
		ldi		r16,$49	;I
		rcall	writeD
		ldi		r16,$3D	;=
		rcall	writeD
		lds		r16,amper0	;средний ток канал 0
		cpi		r16,250
		brlo	strom0_is_range
;нештатная ситуация - увеличение тока свыше 10мА
		ldi		r18,$30		;номер канала где превышен ток
Big_Strom:
		cbi		PORTD,3			;Выключить реле (авария)
		ldi		r16,0x01		;очистка экрана	
		rcall	writeI
		ldi		r17,8			;8 символов Ошибка №
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
		ldi		r16,0b11000000	;курсор в 64 позицию
		rcall	writeI
		ldi		r17,13			;13 символов Превышен ток
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
		cli				;запрет прерываний
halt0:	rjmp	halt0	;останов наглухо
strom0_is_range:
		clr		r17
		lsl		r16
		rol		r17
		lsl		r16
		rol		r17
		rcall	BCDW		;двоично-десят косвенное r31:r30
		lds		r16,bcdres2
		rcall	writeD
		ldi		r16,$2E	;.
		rcall	writeD
		lds		r16,bcdres1
		rcall	writeD
		lds		r16,bcdres0
		rcall	writeD
		ldi		r16,$20	;пробел
		rcall	writeD
		ldi		r16,$54	;T
		rcall	writeD
		ldi		r16,$3D	;=
		rcall	writeD
		lds		r16,min0;минуты канала 0
		rcall	BCDB	;двоично-десят косвенное r31:r30
		ld		r16,-Z
		rcall	writeD
		ld		r16,-Z
		rcall	writeD
		ldi		r16,$3A	;двоеточие
		rcall	writeD
		lds		r16,sec0	;секунды канала 0
		rcall	BCDB	;двоично-десят косвенное r31:r30
		ld		r16,-Z
		rcall	writeD
		ld		r16,-Z
		rcall	writeD


	;2 строка
		ldi		r16,0b11000000	;курсор в 64 позицию
		rcall	writeI
		ldi		r16,$31	;1
		rcall	writeD
		ldi		r16,$29	;)
		rcall	writeD
		ldi		r16,$49	;I
		rcall	writeD
		ldi		r16,$3D	;=
		rcall	writeD
		lds		r16,amper1	;средний ток канал 1
		cpi		r16,250
		brlo	strom1_is_range
		ldi		r18,$31		;номер канала где превышен ток
		rjmp	Big_Strom
strom1_is_range:
		clr		r17
		lsl		r16
		rol		r17
		lsl		r16
		rol		r17
		rcall	BCDW		;двоично-десят косвенное r31:r30
		lds		r16,bcdres2
		rcall	writeD
		ldi		r16,$2E	;.
		rcall	writeD
		lds		r16,bcdres1
		rcall	writeD
		lds		r16,bcdres0
		rcall	writeD
		ldi		r16,$20	;пробел
		rcall	writeD
		ldi		r16,$54	;T
		rcall	writeD
		ldi		r16,$3D	;=
		rcall	writeD
		lds		r16,min1;минуты канала 1
		rcall	BCDB	;двоично-десят косвенное r31:r30
		ld		r16,-Z
		rcall	writeD
		ld		r16,-Z
		rcall	writeD
		ldi		r16,$3A	;двоеточие
		rcall	writeD
		lds		r16,sec1;секунды канала 1
		rcall	BCDB	;двоично-десят косвенное r31:r30
		ld		r16,-Z
		rcall	writeD
		ld		r16,-Z
		rcall	writeD

; обновление состояний светодиодов
		ldi		r22,0b00010001
		ldi		r16,0b01110000	;высветить модуляции
		and		r16,r26			;левого канала
		lsl		r16
		or		r22,r16
		ldi		r16,0b01110000	;высветить модуляции
		and		r16,r27			;правого канала
		lsr		r16
		lsr		r16
		lsr		r16
		or		r22,r16
	;зеленый канала 0
		sbrc	r26,0		;процедура выключена ?
		rjmp	Left_CH_On		;включена - перейти
		lds		r16,param0+11;выключена - поставить значения времени по умолчанию
		sts		sec0,r16
		lds		r16,param0+10
		sts		min0,r16	
		cbr		r22,16		;погасить зеленый LED левого канала
		rjmp	Left_CH_Not_Paused
Left_CH_On:
		sbrc	r26,1		;процедура на паузе ?
		rjmp	Left_CH_Not_Paused		;не на паузе - перейти
		bst		r15,7		;медленные мигания
		bld		r22,4		;зеленому светодиоду
Left_CH_Not_Paused:
		ldi		r16,0b00001100
		and		r16,r26		;плавный рост/спад включен?	
		breq	Left_CH_Not_Growth		;нет - перейти
		bst		r15,6		;быстрые мигания
		bld		r22,4		;зеленому светодиоду
Left_CH_Not_Growth:
	;зеленый канала 1
		sbrc	r27,0		;процедура вывключена ?
		rjmp	Right_CH_On		;включена - перейти
		lds		r16,param1+11;выключена - поставить значения времени по умолчанию
		sts		sec1,r16
		lds		r16,param1+10
		sts		min1,r16	
		cbr		r22,0b00000001	;погасить зеленый LED правого канала
		rjmp	Right_CH_Not_Paused
Right_CH_On:
		sbrc	r27,1		;процедура на паузе ?
		rjmp	Right_CH_Not_Paused		;не на паузе - перейти
		bst		r15,7		;медленные мигания
		bld		r22,0		;зеленому светодиоду
Right_CH_Not_Paused:
		ldi		r16,0b00001100
		and		r16,r27		;плавный рост/спад включен?	
		breq	Right_CH_Not_Growth		;нет - перейти
		bst		r15,6		;быстрые мигания
		bld		r22,0		;зеленому светодиоду
Right_CH_Not_Growth:
		rcall	OUT_LED

;опрос клавиатуры
		rcall	KBRD		;прочитать клавиатуру
		cpi		r20,0b11000000	;нажаты вправо и влево вместе ?
		brne	Is_Not_Pressed_Left_Right
		rcall	SaveParam
		rjmp	clrscr
Is_Not_Pressed_Left_Right:		;------------- запуск левого канала
		cpi		r20,0b00000010	;нажата пуск левого канала ?
		brne	Is_Not_Pressed_Leftstart
		ldi		r16,3
		and		r16,r26			;высветить биты запуска и паузы
		brne	Left_CH_Already_Running	;<>0 запущена или на паузе - перейти
		ldi		r16,10			;не запущена 
		mov		r14	,r16		;вкл сигнал о запуске 320мсек
		set
		bld		r15,0			;частота 1600Гц
		bld		r15,2			;частота  400Гц

		lds		r20,param0		;амплитуда 0...128
		lds		r21,param0+2	;частота модуляции 10...200
		lds		r24,param0+1	;глубина модуляции 0...10
		ldi		r31,high(am_data0)
		ldi		r30,low(am_data0)
		rcall	CALC			;расчет параметров модуляции канала ЦАП №0

		lds		r20,param0+3	;амплитуда 0...128
		lds		r21,param0+9	;частота модуляции 10...200
		lds		r24,param0+8	;глубина модуляции 0...10
		ldi		r31,high(am_data1)
		ldi		r30,low(am_data1)
		rcall	CALC			;расчет параметров модуляции канала ЦАП №1
		lds		r20,param0+4	;Fimp
		lds		r21,param0+7	;FMFi
		lds		r24,param0+6	;FMDi
		ldi		r31,high(fm_data0)
		ldi		r30,low(fm_data0)
		rcall	FMCALC
		lds		r16,param0+5	;на 0,04мс жалящего импульса приходится
		ldi		r17,5			;5 импульсов таймера Т1
		cli
		mul		r16,r17			;r1:r0=приращение к регистру сравнения
		std		Z+6,r0
		std		Z+7,r1
		sei
Left_CH_Already_Running:	
		sbi		PORTD,4			;OCC1B=1 (установить состояние паузы)
		in		r16,TCCR1A		;задействовать 
		ori		r16,0b00010000	;ножку OCC1B
		out 	TCCR1A,r16		;таймера T1
		ori		r26,0b00000111	;запустить, с плавным ростом тока
		andi	r26,0b11110111	;отменить плавный спад
		rjmp	LEVEL_0

Is_Not_Pressed_Leftstart:		;------------- запуск правого канала
		cpi		r20,0b00001000	;нажата пуск правого канала ?
		brne	Is_Not_Pressed_Rightstart
		ldi		r16,3
		and		r16,r27			;высветить биты запуска и паузы
		brne	Right_CH_Already_Running			;<>0? запущена или на паузе? - перейти
		ldi		r16,10			;не запущена 
		mov		r14	,r16		;вкл сигнал о запуске 320мсек
		set
		bld		r15,0			;частота 1600Гц
		bld		r15,2			;частота  400Гц
		
		lds		r20,param1		;амплитуда 0...128
		lds		r21,param1+2	;частота модуляции 10...200
		lds		r24,param1+1	;глубина модуляции 0...10
		ldi		r31,high(am_data2)
		ldi		r30,low(am_data2)
		rcall	CALC			;расчет параметров модуляции канала ЦАП №2
		lds		r20,param1+3	;амплитуда 0...128
		lds		r21,param1+9	;частота модуляции 10...200
		lds		r24,param1+8	;глубина модуляции 0...10
		ldi		r31,high(am_data3)
		ldi		r30,low(am_data3)
		rcall	CALC		;расчет параметров модуляции правого канала
		lds		r20,param1+4	;Fimp
		lds		r21,param1+7	;FMFi
		lds		r24,param1+6	;FMDi
		ldi		r31,high(fm_data1)
		ldi		r30,low(fm_data1)
		rcall	FMCALC
		lds		r16,param1+5	;на 0,04мс жалящего импульса приходится
		ldi		r17,5			;5 импульсов таймера Т1
		cli
		mul		r16,r17			;r1:r0=приращение к регистру сравнения
		std		Z+6,r0
		std		Z+7,r1
		sei
Right_CH_Already_Running:
		sbi		PORTD,5			;OCC1A=1 (установить состояние паузы)
		in		r16,TCCR1A		;задействовать 
		ori		r16,0b01000000	;ножку OCC1А
		out 	TCCR1A,r16		;таймера T1
		ori		r27,0b00000111	;снть с паузы, с плавным ростом тока
		andi	r27,0b11110111	;отменить плавный спад
		rjmp	LEVEL_0

Is_Not_Pressed_Rightstart:		;------------- обработка останова и паузы левого канала
		cpi		r20,0b00000001	;нажата стоп левого канала ?
		brne	Is_Not_Pressed_LeftStop
		sbrc	r26,1			;процедура в левом канале на паузе ?
		rjmp	Left_CH_IsNot_Paused			;нет паузы - перейти
		sbrs	r26,3			;плавный спад тока еще активен ?
		rjmp	Left_CH_IsNot_Decline	   		;уже нет спада - перейти
		andi	r26,0b11110111	;отменить плавный спад тока (2 нажатие)
		clr		r16				;Резко обнулить
		sts		DACdata0,r16	;обе составляющие 
		sts		DACdata1,r16	;токов левого канала
		rjmp	LEVEL_0
Left_CH_IsNot_Decline:			;сброс процедуры (3 нажатие)
		andi	r26,0b11111100	
		rjmp	LEVEL_0
Left_CH_IsNot_Paused:			;активировать паузу (1 нажатие) 
		andi	r26,0b10001001	;отменить плавное нарастание тока,погасить светодиоды модуляции
		ori		r26,0b00001000	;активировать плавный спад тока
		rjmp	LEVEL_0

Is_Not_Pressed_LeftStop:		;------------- обработка останова и паузы правого канала
		cpi		r20,0b00000100	;нажата стоп правого канала ?
		brne	Is_Not_Pressed_RightStop
		sbrc	r27,1			;процедура в правом канале на паузе ?
		rjmp	Right_CH_IsNot_Paused		;нет паузы - перейти
		sbrs	r27,3			;плавный спад тока еще активен ?
		rjmp	Right_CH_IsNot_Decline	   	;уже нет спада - перейти
		andi	r27,0b11110111	;отменить плавный спад тока (2 нажатие)
		clr		r16				;Резко обнулить
		sts		DACdata2,r16	;обе составляющие 
		sts		DACdata3,r16	;токов правого канала
		rjmp	LEVEL_0
Right_CH_IsNot_Decline:			;сброс процедуры (3 нажатие)
		andi	r27,0b11111100	
		rjmp	LEVEL_0
Right_CH_IsNot_Paused:			;активировать паузу(1 нажатие)
		andi	r27,0b10001001	;отменить плавное нарастание тока,погасить светодиоды модуляции 
		ori		r27,0b00001000	;активировать плавный спад тока
		rjmp	LEVEL_0

Is_Not_Pressed_RightStop:		
		sbrs	r21,5		;сравнить время задержания клавиши с 1сек (32)
		rjmp	LEVEL_0		;<32 - игнорировать нажатие
		cpi		r20,0b00100000	;нажата вниз (S10) ?
		breq	Is_Pressed_Down
		rjmp	LEVEL_0			;не нажата
Is_Pressed_Down:
		rcall	LEVEL_1			;нажата
		rjmp	clrscr


;------------------------------------------------------
;меню выбора канала для настройки параметров
;------------------------------------------------------
LEVEL_1:
		ldi		r16,0b00001101	;вывод изображения, курсор в виде прямоугольника 
		rcall	writeI
		ldi		r16,0x01		;очистка экрана	
		rcall	writeI
		ldi		r16,$30	;0
		rcall	writeD
		ldi		r17,8			;8 символов КАНАЛ
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
		ldi		r17,6			;8 символов
		ldi		r24,low(elab1)
lmnu2:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	lmnu2
		bst		r15,5			;извлечь № редактируемого канала
lmnu3:	
		ldi		r16,0b10000000	;подготовка у установке курсора в запомненную в r15:5 позицию
		bld		r16,0
		bld		r16,3
		rcall	writeI
lmnu5:
		rcall	KBRD
		tst		r21
		brne	lmnu5	;ожидание отпускания длительно нажатой кнопки
waitkb:
		rcall	KBRD
		cpi		r20,0b01000000	;нажата влево ? (S11)
		brne	nonS11
		clt						;курсор в 0 позицию
		rjmp	lmnu3
nonS11:
		cpi		r20,0b10000000	;нажата вправо ? (S12)
		brne	nonS12
		set						;курсор в 9 позицию
		rjmp	lmnu3
nonS12:
		cpi		r20,0b00010000	;нажата вверх ? (S9)
		breq	lmnu4			;возврат в родительское меню
		cpi		r20,0b00100000	;нажата вниз ? (S10)
		brne	waitkb			;нет - к опросу клавиатуры
		bld		r15,5			;сохранить № редактир канала
		rcall	LEVEL_2			;да - в меню 2 уровня
		rjmp	LEVEL_1			;после выхода - вначало меню 1 уровня
lmnu4:	
		bld		r15,5			;сохранить № редактир канала
		ret		

;------------------------------------------------------
;меню выбора параметров
;------------------------------------------------------
LEVEL_2:
		ldi		r16,0b00001100	;вывод изображения, курсор не виден
		rcall	writeI
		ldi		r16,0x01	;очистка экрана	
		rcall	writeI
		ldi		r17,25		;расчет смещения для выборки из ПЗУ
		mul		r18,r17		;смещение = №*25
		movw	r24,r0		;в r25:r24
		ldi		r17,16		;16 символов читать (имя параметра)
lmnu21:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	lmnu21

		ldi		r16,0b11000000	;курсор в начало 2 строки (64 позицию)
		rcall	writeI
		bst		r15,5		;№ редакт канала
		ldi		r16,$30
		bld		r16,0		;вывести
		rcall	writeD
		ldi		r16,$23		;№
		rcall	writeD
		mov		r16,r18
		rcall	BCDB
		ldi		r30,bcdres1
		ld		r16,Z
		rcall	writeD		;вывести № параметра
		ld		r16,-Z
		rcall	writeD
		ldi		r16,$20		;пробел
		rcall	writeD
		ldi		r17,4		;4 символа читать (префикс)
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
		cpi		r20,0b01000000	;нажата влево ? (S11)
		brne	nonleft
		cpi		r18,0			;Номер параметра = 0?
		breq	sound1			;да - перейти
		dec		r18
		rjmp	LEVEL_2
nonleft:
		cpi		r20,0b10000000	;нажата вправо ? (S12)
		brne	nonright
		cpi		r18,10			;Номер параметра = 10?
		breq	sound1			;да - перейти
		inc		r18
		rjmp	LEVEL_2
nonright:
		cpi		r20,0b00100000	;нажата вниз ? (S10)
		brne	nondown
		rcall	LEVEL_3
		rjmp	waitkb2
nondown:
		cpi		r20,0b00010000	;нажата вверх ? (S9)
		breq	lmnu27
		rjmp	waitkb2
sound1:			
		ldi		r16,4			;звук сигнал
		mov		r14,r16			;128мсек
		set
		bld		r15,2			;частота 400Гц
		bld		r15,4			;частота 100Гц
		rjmp	waitkb2
lmnu27:	
		rcall	Valid_Check
		brcc	endl2
		rjmp	LEVEL_2
endl2:
		ret


;--------------------------------------------------
;Меню редактирования параметра
;--------------------------------------------------
LEVEL_3:
		clt		;установка для секунд
lmnu30:	
		ldi		r16,0b11001010
		rcall	writeI
		rcall	PRINT_PARAM		;вывести на экран значение
		ldi		r16,0b00001101	;вывод изображения, курсор в виде прямоугольника 
		rcall	writeI
		ldi		r16,0b11001101	;курсор в 4D (на символ младшего разряда числа)
		brtc	lmnu301
		ldi		r16,0b11001010	;курсор в 4A (на символ старшего разряда числа)
lmnu301:
		rcall	writeI
waitkb3:
		rcall	KBRD
		cpi		r20,0b00010000	;нажата вверх ? (S9)
		brne	lmnu302			
;----- закончить меню 3 уровня --------------
		ldi		r16,0b00001100	;вывод изображения, курсор не виден
		rcall	writeI
		ret
lmnu302:
		cpi		r18,10			;параметр №10 ?
		brne	lmnu33			;нет - перейти
;---- для редактирования параметра 10 -----
		cpi		r20,0b10000000	;нажата вправо ? (S12)
		brne	lmnu31			;нет - перейти
		brtc	lmnu311	        ;активно редактирование секунд ? перейти
		ldi		r17,100			;предел для минут
		ldi		r19,0
lmnu312:
		ld		r16,Y			;корректировка минут в +
		inc		r16
		st		Y,r16
		cp		r16,r17
		brne	lmnu30
		mov		r16,r19
		st		Y,r16
		rjmp	lmnu30
lmnu311:
		ldd		r16,Y+1			;корректировка секунд в +
		inc		r16
		std		Y+1,r16
		cpi		r16,60
		brne	lmnu30
		clr		r16
		std		Y+1,r16
		rjmp	lmnu30

lmnu31:
		cpi		r20,0b01000000	;нажата влево ? (S11)
		brne	lmnu32
		brtc	lmnu321		;активно редактирование секунд ? перейти
		ldi		r17,99		;предел для минут
		ldi		r19,255

lmnu322:
		ld		r16,Y		;корректировка минут в -
		dec		r16
		st		Y,r16
		cp		r16,r19
		brne	lmnu30
		mov		r16,r17
		st		Y,r16
		rjmp	lmnu30
lmnu321:
		ldd		r16,Y+1		;корректировка секунд в -
		dec		r16
		std		Y+1,r16
		cpi		r16,255
		brne	lmnu30
		ldi		r16,59
		std		Y+1,r16
		rjmp	lmnu30
lmnu32:
		cpi		r20,0b00100000	;нажата вниз ? (S10)
		brne	waitkb3
		sbrc	r21,5
wkb3:			
		rjmp	waitkb3	;исполнить кадр если идут авто-нажаия
		brts	lmnu34	;перебор установок минуты или секунды
		set		;установка для минут
		rjmp	lmnu30
lmnu34:
		clt		;установка для секунд
		rjmp	lmnu30

lmnu33:	;---- для редактирования параметров 0...9-----
		cpi		r20,0b01000000	;нажата влево ? (S11)
		brne	lmnu35
		adiw	r24,1
		rcall	EEREAD	;извлечь верхний предел
		mov		r17,r16
		adiw	r24,1
		rcall	EEREAD	;извлечь нижний предел
		mov		r19,r16
		rjmp	lmnu322
lmnu35:
		cpi		r20,0b10000000	;нажата вправо ? (S12)
		brne	wkb3
		adiw	r24,1
		rcall	EEREAD	;извлечь верхний предел
		mov		r17,r16
		inc		r17
		adiw	r24,1
		rcall	EEREAD	;извлечь нижний предел
		mov		r19,r16
		inc		r19
		rjmp	lmnu312

;---------------------------------------------------
;выполнение тестирования на предмет целостности выходных цепей
;и включение реле при исправности
;ошибка №0 - на выходе не устанавливается ноль в исходном остоянии
;---------------------------------------------------
Start_Test:
.equ	ADC_Valid_null=2
		;установка выходов ЦАПов на нулевые напряжения
		clr		r16
		sts		DACdata0,r16
		sts		DACdata1,r16
		sts		DACdata2,r16
		sts		DACdata3,r16

		ldi		r16,0x01		;очистка экрана	
		rcall	writeI
		ldi		r17,7			;16 символов "Тест..."
		ldi		r25,high(teststring)
		ldi		r24,low(teststring)
test1:
		rcall	EEREAD
		ldi		r23,250		;пауза 250*0.5=125ms
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
		ldi		r16,0x01		;очистка экрана	
		rcall	writeI
		ldi		r17,8			;8 символов Ошибка №
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
		ldi		r16,0b11000000	;курсор в 64 позицию
		rcall	writeI
		ldi		r16,$30	;"0"	;№ канала
		rcall	writeD
		ldi		r17,15			;15 символов текст ошибки
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
		ldi		r16,0x01		;очистка экрана	
		rcall	writeI
		ldi		r17,8			;8 символов Ошибка №
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
		ldi		r16,0b11000000	;курсор в 64 позицию
		rcall	writeI
		ldi		r16,$31	;"1"	;№ канала
		rcall	writeD
		ldi		r17,15			;15 символов текст ошибки
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
;проверка на правильность введенных параметров
;Валидация не должна пропустить Fmin=Fi-DFi >= 5 (2Гц)
;пауза должна быть как минимум половина от минимального периода:
;Тимп<=1/2(Fi+DFi). Расчет в уе: Timp<=31250/(Fi+DFi)
;модулирующая частота должна быть в 10p меньше Fmin=Fi-DFi
;---------------------------------------------------
Valid_Check:
		push	r18
		ldi		r16,0x01		;очистка экрана	
		rcall	writeI
		mov		r28,r15			;выделить № редактируемого канала
		andi	r28,0b00100000
		lsr		r28				;r28=#канала*16
		clr		r29
		subi	r28,256-param0	;(256-$70)получить адрес начала блока параметров текущего канала
		ldd		r16,Y+4			;частота импульсов (5...249)
		ldd		r17,Y+6			;девиация			
		sub		r16,r17			;Fi-DFi
		cpi		r16,5
		brsh	probe_err12
		rjmp	ERROR10			;Fi-DFi<5
probe_err12:
		ldd		r19,Y+7			;модулирующая частота (10...249)
		cp		r16,r19
		brsh	probe_err11	
		rjmp	ERROR12
probe_err11:
		ldd		r16,Y+4			;частота импульсов (5...249)
		add		r16,r17			;Fi+DFi
		clr		r17
		adc		r17,r17			;r17:r16=Fi+DFi
		ldi		r18,low(31250)
		ldi		r19,high(31250)
		movw	r0,r18
		rcall	divide16		;r19:r18=31250/(Fi+DFi)
		ldd		r16,Y+5			;длительность импульса
		clr		r17
		cp		r18,r16
		cpc		r19,r17
		brsh	probe_err13
		rjmp	ERROR11			;31250/(Fi+DFi)<Timp
probe_err13:
		ld		r20,Y			;амплитуда 0...255
		ldd		r24,Y+1			;глубина модуляции 0...10
		mul		r20,r24			;L*%mod
		ldi		r16,10
		clr		r17
		rcall	divide16	;A=r19:r18=L*%mod/10
		mov		r19,r20
		add		r19,r18		;max AM
		brcc	probe_err14
		rjmp	ERROR13	
probe_err14:
		ldd		r20,Y+3		;амплитуда 0...128
		ldd		r24,Y+8		;глубина модуляции 0...10
		mul		r20,r24		;L*%mod
		ldi		r16,10
		clr		r17
		rcall	divide16	;A=r19:r18=L*%mod/10
		mov		r19,r20
		add		r19,r18		;max AM
		brcc	No_Error	;отсутствие ошибок
		rjmp	ERROR14	

State_Err_Wait_KB:
		rcall	KBRD
		cpi		r20,0b00010000	;нажата вверх
		brne	State_Err_Wait_KB
		sec		;установкой переноса отметить что имеется ошибка
No_Error:
		pop		r18
		ret

	;обработчики ошибок						
ERROR10:
		ldi		r17,8			;8 символов Ошибка №
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
		ldi		r16,0b11000000	;курсор в 64 позицию
		rcall	writeI
		ldi		r17,13			;13 символов текст ошибки
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
		ldi		r17,8			;8 символов Ошибка №
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
		ldi		r16,0b11000000	;курсор в 64 позицию
		rcall	writeI
		ldi		r17,14			;13 символов текст ошибки
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
		ldi		r17,8			;8 символов Ошибка №
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
		ldi		r16,0b11000000	;курсор в 64 позицию
		rcall	writeI
		ldi		r17,15			;13 символов текст ошибки
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
		ldi		r17,8			;8 символов Ошибка №
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
		ldi		r16,0b11000000	;курсор в 64 позицию
		rcall	writeI
		ldi		r17,14			;14 символов текст ошибки
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
		ldi		r17,8			;8 символов Ошибка №
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
		ldi		r16,0b11000000	;курсор в 64 позицию
		rcall	writeI
		ldi		r17,14			;14 символов текст ошибки
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
;Вывод на индикацию численного значения параметра
;вызывается из меню 2 и 3 уровней
;исходные значения в r15.5 и r18
;---------------------------------------------------
PRINT_PARAM:
		mov		r28,r15			;выделить № редактируемого канала
		andi	r28,0b00100000
		lsr		r28				;r28=#канала*16
		clr		r29
		cpi		r18,10			;это параметр №10 ?
		brne	non10			;нет - переход
	;да - вывод минуты:секунды
		subi	r28,256-(param0+10)	;(256-$7F)	;+$7A
		ld		r16,Y
		ldd		r17,Y+1
		rcall	BCDB
		lds		r16,bcdres1		;десятки минут
		rcall	writeD
		lds		r16,bcdres0		;минуты
		rcall	writeD
		ldi		r16,$3A		; :
		rcall	writeD
		mov		r16,r17
		rcall	BCDB
		lds		r16,bcdres1		;десятки секунд
		rcall	writeD
		lds		r16,bcdres0		;секунды
		rcall	writeD
		rjmp	ppe
non10:
		subi	r28,256-param0	;(256-$70)	;+$70 получить адрес начала блока параметров текущего канала
		add		r28,r18		;получить адрес текущего параметра
		ld		r16,Y		;извлечь значение параметра
		mov		r19,r16		;и сохранить в r19
		ldi		r17,25		;расчет смещения для выборки из ПЗУ
		mul		r18,r17		;смещение = №*25
		movw	r24,r0		;в r25:r24
		adiw	r24,20		;адрес нахождения множителя
		rcall	EEREAD		;извлечь из ПЗУ множитель
		mov		r20,r16		;сохранить для чтения положения десятичной точки
		andi	r16,$0F		;затереть старшую тетраду
		mul		r16,r19		;получить значение для индикации
		movw	r16,r0		;в r17:r16
		rcall	BCDW		;перевести в десятичный вид в код индикатора
		ldi		r30,bcdres3		;адрес самого старшего разряда +1
		swap	r20
		andi	r20,$0F		;получить № знакоместа для десятичной точки
		subi	r20,256-bcdres0	;+$64 (+100)
pp1:	
		cp		r30,r20
		brne	pp2
		ldi		r16,$2E		;символ десятичной точки
		rcall	writeD
pp2:
		ld		r16,-Z
		rcall	writeD
		cpi		r30,bcdres1
		brsh	pp1
		adiw	r24,1
		rcall	EEREAD		;1 символ суффикса
		rcall	writeD
		adiw	r24,1
		rcall	EEREAD		;2 символ суффикса
		rcall	writeD
ppe:
		ret

;------------------------------------------------------
;подпрограмма расчета параметров модуляции
;расчет амплитудных модуляций
;число вызовов TIM0_COMP в секунду Ф=1000000/64=15625
;размах модуляции 2А=2*L*%mod/10
;;вызов Дельта=(2А+1)*f/2/39063
;т.к частота задается от 0 до 200, то формула имеет вид:
;Дельта=(А*Ч+Ч/2)/39063
;модуляция не синус, а линейная, от расчетного минимального,
;до расчетного максимального значения. например при 50% и А=128 от 64  до 192
;расчет минимального значения
;параметры 	r20 - Уровень (L) 0...128
;			r21 -частота модуляции (f) 10...200
;			r24 - глубина модуляции (%mod) 0...9
;возврат:
;Z - ограничение в +
;Z+1 - ограничение в -
;Z+3:Z+2 = приращение амплитуды на 1 вызов TIM0_COMP
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
		std		Z+2,r18		;сохранить величину приращения
		std		Z+3,r19
		ret
_clc1:
		clr		r18
		clr		r19
		rjmp	_clc2




;------------------------------------------------------
;подпрограмма расчета параметров FM модуляции
;в TIM0_COMP расчитываются коэфф таймера Т1
;число вызовов TIM0_COMP в секунду Ф=1000000/64=15625
;Fi_max=Fi+FMDi	Fi_min=Fi-FMDi
;размах частоты модуляции 2FMDi (126 уе)
;количество ступеней изменения частоты за 1 период модуляции Nm=(2FMDi+1)*2
;приращение на 1 вызов Dmi=Nm*FMFi/15625. Упрощаем Dmi=(2FMDi+1)*FMFi/7812.5
;учитывая коэффициенты пропорциональости:
;Dmi=0.4*(2FMD+1)*0.04*FMF/7812.5=(2FMD+1)*FMF/195312=(2FMD+1)*FMF/(4*48828)
;модуляция не синус, а линейная,
;параметры 	r20 - центральная чатстота (Fi)10...249	(4...99,6Гц)
;			r21 -частота модуляции (FMFi) 10...249	(0.4....9.96Гц)
;			r24 - девиация частоты (FMDi) 0...63  	(0...25.2Гц)
;возврат:
;Z - девиация в +
;Z+1 - девиация в -
;Z+3:Z+2 = приращение частоты на 1 вызов TIM0_COMP
;Z+4 текущая девиация (обнуляем для использования в быстром прерывании)
;Z+5 центральная частота как безопасная копия param+4
;-------------------------------------------------------
FMCALC:
		std		Z+5,r20		;центральная частота
		clr		r19			;обнулить
		std		Z+4,r19		;текущую девиацию
		st		Z,r24		;+девиация
		mov		r19,r24
		neg		r19
		std		Z+1,r19		;-девиация
		lsl		r24
		breq	_fmclc1		;переход если девиация=0	
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
		std		Z+2,r18		;сохранить величину приращения
		std		Z+3,r19
		ret
_fmclc1:
		clr		r18
		clr		r19
		rjmp	_fmclc2


;------------------------------------------------------
; Чтение клавиатуры
; новые нажатия в r20
; повторы в r21
; при толчках r20=код свежего нажатия r21=0
; при удержании до 1 сек r20=0 r21=1
; при удержании свыше 1 сек r20=код,включая несвежие нажатия r21=32
;------------------------------------------------------
KBRD:	
		cli					;Запрет прерываний чтобы не обновилась клавиат
		lds		r20,keytime		;извлечь время задержки нажатия
		sbrs	r20,5		;пропустить след если >=32 (2^5)
		rjmp	singl
		dec		r20			;при удержании: отмотать счетчик времени удержания на 2/32сек
		dec		r20
		sts		keytime,r20
		lds		r20,keystate		;нажатые клавиши
		com		r20
		ldi		r21,32
		sei
		ret
singl:			; если удержание не достигло 1 сек
		tst		r20
		breq	lkb1	;удержания нет совсем - перейти
		clr		r20		;не выдавать код вообще
		ldi		r21,1	;удержание показать как 1/32сек
		rjmp	kbex
lkb1:					
		lds		r20,keynew		;новые события
		lds		r21,keystate		;нажатия
		com		r21			;высветить как 1 нажатые клавиши
		and		r20,r21		;только свеженажатые			
		clr		r21
		sts		keynew,r21		;затереть признак свежего нажатия
		lds		r21,keytime		;время удержания
kbex:
		sei					;разрешить прерывания
		ret

;-------------------------------------------------------
;Сохранение в ПЗУ текущих параметров как новых умолчаний
;-------------------------------------------------------
SaveParam:
		ldi		r16,$01		;очистка экрана	
		rcall	writeI
		ldi		r16,0b00001100		;курсор выкл
		rcall	writeI
		ldi		r17,16			;16 символов "запись параметр"
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
		cpi		r20,0b00000010	;нажат пуск левого
		breq	Left_Save_Param
		cpi		r20,0b00001000	;нажат пуск правого
		breq	Right_Save_Param
		cpi		r20,0b00010000	;нажата вверх ? (S9)
		brne	Cicle_Read_Keyb
		ret
Left_Save_Param:	;запись параметров левого канала	
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
		ldi		r16,0b11000000	;курсор в 64 позицию
		rcall	writeI
		ldi		r16,$30	;1
		rcall	writeD
		rjmp	Wait_KBstate_is_Free

Right_Save_Param:	;запись параметров правого канала	
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
		ldi		r16,0b11000000	;курсор в 64 позицию
		rcall	writeI
		ldi		r16,$31	;1
		rcall	writeD
		rjmp	Wait_KBstate_is_Free
		

Wait_KBstate_is_Free:
		ldi		r17,14			;14 символов КАНАЛ сохран
		ldi		r25,high(elab1)
		ldi		r24,low(elab1)
save2:
		rcall	EEREAD
		rcall	writeD
		adiw	r24,1
		dec		r17
		brne	save2
	;ожидание отпускания длительно нажатой кнопки
		ldi		r16,5	;160мсек
		mov		r14,r16	;вкл сигнал о запуске 320мсек
		set
		bld		r15,1	;частота 800Гц
Read_KB_1:
		rcall	KBRD
		tst		r21
		brne	Read_KB_1
		rjmp	Cicle_Read_Keyb	

			
;------------------------------------------------------
;  Чтение байта из EEPROM
;  адрес r25:r24
;  прочитанный байт в r16
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
;  Запись байта в EEPROM
;  адрес r25:r24
;  байт для записи в r16
;------------------------------------------------------
EEWR:
		sbic	EECR,EEWE
		rjmp	EEWR
		cli
		out		EEARH,r25
		out		EEARL,r24
		out		EEDR,r16
		sbi 	EECR,EEMWE 	;Установить флаг EEMWE
		sbi 	EECR,EEWE 	;Начать запись в EEPROM
		sei
		ret

;------------------------------------------------------
;  Вывод информации на LED
;  исходный байт информации в r22
;------------------------------------------------------
OUT_LED:
		push	r17
		ser		r17			;порт С конфигурируем как выход
		out		DDRC,r17
		out		portC,r22	;выставление  на шину
		sbi		portA,6		;фронт LE
		nop					;250ns длительность LE
		cbi		portA,6		;спад LЕ (Фиксация по спаду)
		clr		r17			;конфигурируем как вход
		out		DDRC,r17	;порт С
		ser		r17			;подтягивающие резисторы
		out		PORTC,r17	;ко входам
		pop		r17
		ret


;--------------------------------------------------------
;Генерация паузы длительность r23*0,5us
;--------------------------------------------------------
Waitt:	
		cpi		r23,0
		brne	Waitt
		ret

;--------------------------------------------------------
;подпрограмма записи байта в регистр данных дисплея
;записываемый байт в регистре R16
;--------------------------------------------------------
writeD:	
		push	r17
wrL3:	
		rcall	readI
		sbrc	r17,7
		rjmp	wrL3
		sbi		portB,0		;RS=1 (данные)
		cbi		portB,1		;R/W=0 (запись)
		rjmp	Public_Code

;--------------------------------------------------------
;подпрограмма записи байта в регистр инструкций дисплея
;записываемый байт в регистре R16 
;--------------------------------------------------------
writeI:	push	r17
wrL4:	rcall	readI
		sbrc	r17,7
		rjmp	wrL4
		cbi		portB,0		;RS=0 (команды)
		cbi		portB,1		;R/W=0 (запись)
Public_Code:
		ser		r17			;порт С конфигурируем как выход
		out		DDRC,r17
		out		portC,r16	;выставление команды/данных на шину
		nop
		sbi		portB,2		;фронт Е
		nop					;500ns длительность E
		nop
		cbi		portB,2		;спад Е (запись по спаду)
		clr		r17			;конфигурируем как вход
		out		DDRC,r17	;порт С
		ser		r17			;подтягивающие резисторы
		out		PORTC,r17	;ко входам
		pop		r17
		ret

;--------------------------------------------------------
;подпрограмма чтения регистра состояния дисплея
;считанный байт в регистре R17
;--------------------------------------------------------
readI:	
		cbi		portB,0		;RS=0 (команды)
		sbi		portB,1		;R/W=1 (чтние)
		sbi		portB,2		;E=1
		nop		; пауза
		nop
		in 		r17,PINC	;чтение по фронту
		cbi		portB,2		;E=0
		nop
		cbi		portB,1		;R/W=0
		ret

;--------------------------------------------------------
;отправка кода 0x30 на LCD без подтверждения
;разрушает r16
;--------------------------------------------------------

SEND30:
		cbi		PORTB,0		;RS=0 (обмен командами)
		cbi		PORTB,1		;RW=0 (запись в ЖКИ)
		cbi		PORTB,2		;E=0 (нет разрешения)
		ser		r16
		out		DDRC,r16	;порт С на выход
		ldi		r16,0x30	;однострочный с 8 битной шиной
		out		portC,r16	;установить на выводах С
		nop
		sbi		portB,2		;фронт на вход Е ЖКИ
		nop					;500ns длительность E
		nop
		cbi		portB,2		;спад на входе Е
		clr		r16			;конфигурируем на вход
		out		DDRC,r16	;порт С
		ser		r16			;подтягивающие резисторы
		out		PORTC,r16	;ко входам
		ret

;------------------------------------------------------------		
;Двоично-десятичное преобразование байта r16 в двоично-десятичный r19:r18
;r16 сохраняется
;------------------------------------------------------------
BCDB:	push	r21
		push	r24
		push	r18
		push	r19
		push	r16

		clr		r18				;очистка
		clr		r19				;регистров приемника BCD
		ldi		r24,8			;число сдвигов
internb:
		mov 	r21,r18
		rcall	BCD_sub			;сделать двоично-десятичную коррекцию
		mov 	r18,r21
		mov 	r21,r19
		rcall	BCD_sub			;сделать двоично-десятичную коррекцию
		mov 	r19,r21
		lsl		r16				;сдвиг младшего байта источника
		rol		r18				;в байты результата	
		rol		r19
		dec		r24
		brne	internb
		clr		r31
		ldi		r30,bcdres2		;адрес страшего символа
		ori		r19,$30		;преобразование в код индикатора
		st		Z,r19
		mov		r19,r18		;выделить второй разряд	
		swap	r19			;в младшую тетраду
		andi	r19,$0F		;очистить старшую
		ori		r19,$30		;преобразование в код индикатора
		st		-Z,r19	
		mov		r19,r18		;выделить третий разряд	
		andi	r19,$0F		;очистить старшую тетраду
		ori		r19,$30		;преобразование в код индикатора
		st		-Z,r19
		ldi		r30,bcdres2		;адрес страшего символа
		pop		r16
		pop		r19
		pop		r18
		pop		r24
		pop		r21
		ret


;------------------------------------------------------------		
;Двоично-десятичное преобразование слова r17:r16
;------------------------------------------------------------
BCDW:	push	r18
		push	r19
		push	r20	
		push	r21
		push	r24
		clr		r18				;очистка
		clr		r19				;регистров приемника BCD
		clr		r20
		ldi		r24,16			;число сдвигов
internw:
		mov 	r21,r18			;первому байту результата
		rcall	BCD_sub			;сделать двоично-десятичную коррекцию
		mov 	r18,r21
		mov 	r21,r19			;второму байту результата
		rcall	BCD_sub			;сделать двоично-десятичную коррекцию
		mov 	r19,r21
		mov 	r21,r20			;третьему байту результата
		rcall	BCD_sub			;сделать двоично-десятичную коррекцию
		mov 	r20,r21
		lsl		r16				;сдвиг младшего байта источника
		rol		r17				;в старший байт источника
		rol		r18				;и в байты результата	
		rol		r19
		rol		r20
		dec		r24
		brne	internw
		
		clr		r31
		ldi		r30,bcdres4	;адрес 4 символа
		ori		r20,$30		;преобразование в код индикатора
		st		Z,r20

		mov		r20,r19		;выделить 3 разряд	
		swap	r20			;в младшую тетраду
		andi	r20,$0F		;очистить старшую
		ori		r20,$30		;преобразование в код индикатора
		st		-Z,r20	
		mov		r20,r19		;выделить 2 разряд	
		andi	r20,$0F		;очистить старшую тетраду
		ori		r20,$30		;преобразование в код индикатора
		st		-Z,r20		

		mov		r19,r18		;выделить 1 разряд	
		swap	r19			;в младшую тетраду
		andi	r19,$0F		;очистить старшую
		ori		r19,$30		;преобразование в код индикатора
		st		-Z,r19	
		mov		r19,r18		;выделить 0 разряд	
		andi	r19,$0F		;очистить старшую тетраду
		ori		r19,$30		;преобразование в код индикатора
		st		-Z,r19
		ldi		r30,bcdres4	;адрес страшего символа
		pop		r24
		pop		r21
		pop		r20
		pop		r19
		pop		r18
		ret

;------------------------------------------------------------
;двоично-десятичная коррекция двух тетрад 
;вызывается из BCDB или из BCDW
;r21 операнд
;------------------------------------------------------------
BCD_sub:
		push	r16
;проверки младшей тетрады<5
		mov		r16,r21
		andi	r16,0b00001111	;выделить младшую тетраду
		cpi		r16,5			; 5
		brlo	skip1
		ldi		r16,3			;коррекция BCD
		add		r21,r16
skip1:	
;проверки старшей тетрады<5
		mov		r16,r21
		andi	r16,0b11110000	;выделить старшую тетраду
		cpi		r16,80			; 80
		brlo	skip2
		ldi		r16,48			;коррекция BCD
		add		r21,r16
skip2:	pop		r16
		ret	

;-------------------------------------------
;деление 16 разрядного на 16 разрядное
;делимое 	r1:r0
;делитель 	r17:r16
;частное  	r19:r18
;Делимое не сохраняется
;--------------------------------------------
divide16:
		push	r20
	;очистка частного r19:r18
		ser		r18
		ser		r19
		ldi		r20,1	;счетчик сдвигов
sdvig:
		inc		r20	;считаем число сдвигов
		lsl		r16	;сдвигаем делитель
		rol		r17
		brcs	ldiv4	;возник перенос
		cp		r0,r16	;ожидаем пока делимое не станет
		cpc		r1,r17	;меньше делителья
		brcc	sdvig	;делимое больше- переход
		lsr		r17		;откатываем
ldiv3:
		ror		r16		;сдвиг на 1 шаг
		dec		r20		;откатываем и счетчик сдвигов
		clc
ldiv2:
		clt
		brcc	ldiv5	;если после сдвига делимого нет переноса - перейти
		set		;если был перенос - пометим флаг Т
ldiv5:
		sub		r0,r16	;вычитаем
		sbc		r1,r17
		brcc	ldiv1	;не было переноса - переход
		clc		
		brts	ldiv1	;при помеченном флаге Т вычитание было БЕЗ переноса железно!
		add		r0,r16	;восстанавливаем состояние до вычитания
		adc		r1,r17
		sec				;восстанавливаем флаг переноса
ldiv1:
		rol		r18		;вдвинуть флаг переноса в результат
		rol		r19
		lsl		r0		;сдвинуть делимое
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
;Дробное деление 16 разрядного на 16 разрядное
;делимое должно быть меньше делителя, т.к целая часть не сохраняется
;делимое 	r1:r0
;делитель 	r17:r16
;частное  	r19:r18 (только дробная часть)
;Делимое не сохраняется
;--------------------------------------------
ddiv:
		push	r20
	;очистка частного r19:r18
		ldi		r18,$ff
		ldi		r19,$ff
		clr		r20	;счетчик сдвигов
		rjmp	ldiv13
ldiv12:
		sub		r0,r16	;вычитаем
		sbc		r1,r17
		brcc	ldiv11	;не было переноса - переход
		clc				;сбросить перенос как будто не было
		brts	ldiv11	;ранее был выдвинут "1" - переход
		add		r0,r16	;восстанавливаем состояние до вычитания
		adc		r1,r17
		sec				;восстанавливаем флаг переноса
ldiv11:
		rol		r18		;вдвинуть флаг переноса в результат
		rol		r19
ldiv13:	
		lsl		r0		;сдвинуть делимое
		rol		r1
		clt
		brcc	ldiv10
		set				;копируем перенос в T
ldiv10:	
		inc		r20
		cpi		r20,17
		brne	ldiv12
		com		r18
		com		r19
		pop		r20
		ret

;----------------------------
;процедура дяля отладки
;отображает на экран число из регпары 19:18
;-----------------------------
mydisp:
		movw	r16,r18
		rcall	bcdw
		ldi		r16,0x01		;очистка экрана	
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
;параметрирование процедуры ввода-вывода (смещение)
param:
.db $43,$B8,$BB,$61,$20,$BE,$6F,$63,$BF,$2E,$20,$BF,$6F,$BA,$61,$20 ;(0) "Сила пост. тока"
.db $20,$20,$49,$63	;"  Iс"
.db $22				;запятая после 2 символа (сотые доли), *2
.db $6D,$41			;"mA"
.db 255				;255*2=5,10мА -макс значение постоянной составляющей
.db 255				;минимальное значение-1

.db $A1,$BB,$79,$B2,$B8,$BD,$61,$20,$41,$4D,$20,$BE,$6F,$63,$BF,$2E ;"Глубина АМ пост."
.db $41,$4D,$44,$63	;"AMDc"
.db $0A	;запятой нет, умножение на 10
.db $20,$25			;" %"
.db 9	;100% -глубина АМ для постоянной составляющей
.db 255				;минимальное значение-1

.db $AB,$61,$63,$BF,$6F,$BF,$61,$20,$41,$4D,$20,$BE,$6F,$63,$BF,$2E ;"Частота АМ пост."
.db $41,$4D,$46,$63	;"AMFc"
.db $11	;запятая после 1 символа,
.db $A1,$E5			;"Гц"
.db 200	;20Гц -Частота АМ для постоянной составляющей
.db 1				;минимальное значение-1= 0.2Гц

.db $43,$B8,$BB,$61,$20,$B8,$BC,$BE,$2E,$20,$BF,$6F,$BA,$61,$20,$20 ;"Сила имп. тока"
.db $20,$20,$49,$69	;"  Ii"
.db $24	;запятая после 2 символа, *4
.db $6D,$41			;"mA"
.db 249	;249*4=9,96мА -макс значение импульсной составляющей
.db 255				;минимальное значение-1

.db $AB,$61,$63,$BF,$6F,$BF,$61,$20,$A5,$BC,$BE,$2D,$63,$6F,$B3,$20 ;"Частота имп-сов "
.db $46,$B8,$BC,$BE	;"Fимп"
.db $14	;запятая после 1 символа, *4
.db $A1,$E5			;"Гц"
.db 249	;249*4=99,6Гц -Частота следования импульсов
.db 9				;минимальное значение -1= 4Гц

.db $E0,$BB,$B8,$BF,$65,$BB,$C4,$BD,$2E,$A5,$BC,$BE,$2D,$63,$6F,$B3;"Длительность имп-сов"
.db $54,$B8,$BC,$BE	;"Тимп"
.db $24	;запятая после 2 символа, *4
.db $BC,$63			;"мс"
.db 249	;249*4=9.96мс -длительность импульса
.db 19				;минимальное значение-1= 0.8мс

.db $E0,$65,$B3,$B8,$61,$E5,$B8,$C7,$20,$AB,$4D,$20,$A5,$BC,$BE,$2E ;"Девиация ЧМ имп."
.db $46,$4D,$44,$69	;"FMDi"
.db $14	;запятая после 1 символа, *4
.db $A1,$E5			;"Гц"
.db 63	;25,2Гц -Девиация частоты следования импульсов
.db 255				;минимальное значение-1

.db $4D,$6F,$E3,$79,$BB,$B8,$70,$2E,$AB,$61,$63,$BF,$6F,$BF,$61,$20 ;"Модулир.частота "
.db $46,$4D,$46,$69	;"FMFi"
.db $24	;запятая после 2 символа, *4
.db $A1,$E5			;"Гц"
.db 249	;249*4=9,96Гц -Модулирующая частота ФМ
.db 9				;минимальное значение-1= 0.4Гц

.db $A1,$BB,$79,$B2,$B8,$BD,$61,$20,$41,$4D,$20,$A5,$BC,$BE,$79,$BB ;"Глубина АМ импул"
.db $41,$4D,$44,$69	;"AMDi"
.db $0A	;запятой нет, умножение на 10
.db $20,$25			;" %"
.db 9	;100% -глубина АМ для импульсной составляющей
.db 255				;минимальное значение-1

.db $AB,$61,$63,$BF,$6F,$BF,$61,$20,$41,$4D,$20,$A5,$BC,$BE,$79,$BB ;"Частота АМ импул"
.db $41,$4D,$46,$69	;"AMFi"
.db $11	;запятая после 1 символа
.db $A1,$E5			;"Гц"
.db 200	;20Гц -Частота АМ для импульсной составляющей
.db 1				;минимальное значение-1= 0.2Гц

proc_time:	
.db $42,$70,$65,$BC,$C7,$20,$BE,$70,$6F,$E5,$65,$E3,$79,$70,$C3,$20 ;"Время процедуры"
.db $54,$BE,$70,$E5	; "Тпрц"  префикс

default_0:	;параметры по умолчанию канала 0
.db 128	;128*2=2.56мА 
.db 0	;0% 
.db 60	;6.0Гц 
.db 64	;64*4=2.56мА 
.db 200	;200*4=80.0Гц 
.db 100	;100*4=4.00мс
.db 50	;50*4=20.0Гц
.db 80	;80*4=3.20Гц 
.db 0	;0% 
.db 20	;2Гц 
.db 02	;01min
.db 20	;10 sec

default_1:	;параметры по умолчанию канала 1
.db 20	;20*2=0.40мА
.db 1	;10% 
.db 70	;7.0Гц
.db 100	;100*4=4.00мА
.db 240	;240*4=96.0Гц
.db 50	;50*4=2.00мс 
.db 60	;60*4=24.0Гц
.db 20	;20*4=0,80Гц
.db 0	;нет модуляции
.db 70	;7Гц
.db 02	;01min
.db 30	;50 sec

elab1:
.db $20,$4B,$41,$48,$41,$A7,$20,$20	;КАНАЛ
.db $63,$6F,$78,$70,$61,$BD
error:
.db $4F,$C1,$B8,$B2,$BA,$61,$20,$4E	;Ошибка № (8символов)
err10:
.db $46,$B8,$BC,$BE,$2D,$46,$4D,$44,$69,$3C,$32,$A1,$E5			;Fимп-FMDi<2Гц (13символов)
err11:
.db $32,$54,$69,$3E,$31,$2F,$28,$46,$69,$2B,$46,$4D,$44,$69,$29	;2Тi>1/(Fi+FMDi) (15символов)
err12:
.db $31,$30,$46,$4D,$46,$69,$3E,$46,$69,$2D,$46,$4D,$44,$69		;10FMFi>Fi-FMDi (14символов)
savep:
.db $A4,$61,$BE,$B8,$63,$C4,$20,$BE,$61,$70,$61,$BC,$65,$BF,$70,$2E	;запись параметр.
teststring:
.db $54,$65,$63,$BF,$2E,$2E,$2E	;Тест...
err0:
.db $42,$C3,$78,$6F,$E3,$20,$BD,$65,$B8,$63,$BE,$70,$61,$B3,$2E ;Выход неисправен
err1:
.db $A8,$70,$65,$B3,$C3,$C1,$65,$BD,$20,$54,$6F,$BA,$20		;Превышен ток (13симв)
err13:
.db $A8,$65,$70,$65,$BC,$6F,$E3,$79,$BB,$C7,$E5,$B8,$C7,$20;Перемодуляция (14)
