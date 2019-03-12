	name		asc2bcdAndHex
	cseg		at 	0x0000 	
	
	ptrHex		equ	0x2020
	ptrBCD		equ	0x2010
	ptrData		equ	0x2000
	
	ptrBufHun	equ	0x60
	ptrBufTen	equ	0x5f
	ptrBufOne	equ	0x5e
	
	sum16AH		equ 	0x21
	sum16AL		equ	0x20
	
	sum16BH		equ	0x23
	sum16BL		equ	0x22
	
	sum16EH		equ	0x25
	sum16EL		equ	0x24
	
; Initialisierung des Speichers ;

	mov	dptr,	#ptrData
	mov	a,	#'2'
	movx	@dptr,	a
	inc 	dptr
	inc	a
	movx	@dptr,	a
	inc	dptr
	inc	a
	movx	@dptr,	a

; Main ;
	
	acall	asc2bcdAndHex

loop_forever:	jmp 	loop_forever
				
; Ascii zu BCD und Ascii zu HEX konverter;
			
asc2bcdAndHex:	mov	dptr,	#ptrData
		mov	r1,	#ptrBufHun
		mov	r2,	#3d	; counter
genDigit:	movx	a,	@dptr	; lade Ascii Zeichen
		inc	dptr		; pointer ++
		clr	c		; sicherheitshalber
		subb	a,#'0'		; ungeprüfte Annahme : Akku enthält eine Ziffer
		mov	@r1,a		; in int. ram puffern
		dec	r1
		djnz	r2,genDigit	; nach der schleife ist die 1st ziffer in 0x60 die 2te in 0x5f und die 3te in 0x5e
	
		mov	dptr,#ptrBCD	; pointer auf location für bcd setzen
		mov	a,ptrBufHun	; wieder zur ersten ziffer
		movx	@dptr,a		; 1ste ziffer wegschreiben
		inc	dptr
		mov	a,ptrBufTen	; zehnerstelle laden
		swap 	a		; an richtige Stelle schieben
		orl	a,ptrBufOne	; einer einfügen
		movx	@dptr,a		; 2te + 3te ziffer wegschreiben
	
		mov	a,ptrBufHun
		mov	b,#100d
		mul	ab
		mov	sum16BL,a	; back up result speicherplatz für 16bit addition
		mov	sum16BH,b	; dito
		mov	a,ptrBufTen
		mov	b,#10d
		mul	ab
		add	a,ptrBufOne	; a=zehnerst * 10 + einer
		mov 	sum16AL,a	; speichern für 16 bit addition
		mov	sum16AH,#0d
		acall 	_16BitAdd	; alten 16bit additionscode ausführen
		mov	dptr,#ptrHex	; pointer auf hex
		mov	a,sum16EL
		movx	@dptr,a
		inc 	dptr
		mov	a,sum16EH
		movx	@dptr,a
				
stop_completly:	ret	

_16BitAdd:		mov 	psw,#0d
			mov	a,sum16AL
			mov	b,sum16BL
			addc	a,b
			mov	sum16EL,a
			mov 	a,sum16AH
			mov	b,sum16BH
			addc	a,b
			mov	sum16EH,a
			ret
			end