
	include "vectrex.i"

sfx_pointer	equ	$c880		
sfx_status	equ	$c882	
													
	org	0

	db "g GCE 2014", $80 
	dw music1 	
	db $F8, $50, $20, -$45	
	db "SFXTEST",$80
	db 0

init:
	ldd #$0000 					; init sfx vars
	std	sfx_pointer
	sta sfx_status
	
	jsr Read_Btns  				; init button read

loopforever:
	jsr Wait_Recal				; wait for vector refresh

	lda	#0						; Y-coordinate
	ldb	#-80					; X-coordinate
	ldu	#message1				; print message
	jsr Print_Str_d


	lda sfx_status				; check if sfx to play
	beq checkbuttons
	jsr sfx_doframe	

checkbuttons:
	jsr Read_Btns        	    ; get button status
    cmpa #$00           	    ; is a button pressed?
    beq loopforever     	    ; no, than loop

checkbutton1:     
    bita #$01                	; test for button 1
    beq checkbutton2     		; if not pressed jump

    ldx #sfx1					; play sfx1
	stx sfx_pointer
	lda #$01
	sta sfx_status  
	bra loopforever 

checkbutton2:
    bita #$02					; test for button 2
    beq checkbutton3          	; if not pressed jump

    ldx #sfx2					; play sfx2
	stx sfx_pointer
	lda #$01
	sta sfx_status 
	bra loopforever
          
checkbutton3:
    bita #$04					; test for button 3
    beq checkbutton4			; if not pressed jump

    ldx #sfx3					; play sfx3
	stx sfx_pointer
	lda #$01
	sta sfx_status
	bra loopforever

checkbutton4:
    bita #$08					; test for button 4
    beq loopforever 			; if not pressed jump

    ldx #sfx4					; play sfx4
	stx sfx_pointer
	lda #$01
	sta sfx_status   
	bra loopforever


sfx_doframe:
	ldu sfx_pointer				; get current frame pointer
	ldb ,u
	cmpb #$D0					; check first flag byte D0
	bne sfx_checktonefreq		; no match - continue to process frame
	ldb 1,u
	cmpb #$20					; check second flag byte 20
	beq sfx_endofeffect			; match - end of effect found so stop playing

sfx_checktonefreq:
	leay 1,u 					; init Y as pointer to next data or flag byte

	ldb ,u 						; check if need to set tone freq
	bitb #%00100000				; if bit 5 of B is set
	beq sfx_checknoisefreq			; skip as no tone freq data

	ldb 1,u						; get next data byte and copy to tone freq reg4
 	lda #$04
 	jsr Sound_Byte 				; set tone freq

	ldb 2,u						; get next data byte and copy to tone freq reg5
 	lda #$05
 	jsr Sound_Byte 				; set tone freq

	leay 2,y					; increment pointer to next data/flag byte 

sfx_checknoisefreq:
	ldb ,u						; check if need to set noise freq
	bitb #%01000000				; if bit 6 of B is only set
	beq	sfx_checkvolume				; skip as no noise freq data

	ldb ,y						; get next data byte and copy to noise freq reg
	lda #$06
	jsr Sound_Byte 				; set noise freq

	leay 1,y					; increment pointer to next flag byte

sfx_checkvolume:
	ldb ,u						; set volume on channel 3		
	andb #%00001111				; get volume from bits 0-3
	lda #$0A              		; set reg10
	jsr Sound_Byte 				; Set volume

sfx_checktonedisable:
	ldb ,u						; check disable tone channel 3
	bitb #%00010000				; if bit 4 of B is set disable the tone
	beq sfx_enabletone
sfx_disabletone:
	ldb $C807					; set bit2 in reg7
	orb #%00000100		
	lda #$07
 	jsr Sound_Byte 				; disable tone
	bra sfx_checknoisedisable
sfx_enabletone:
	ldb $C807					; clear bit2 in reg7
	andb #%11111011	
	lda #$07
 	jsr Sound_Byte 				; enable tone
							
sfx_checknoisedisable:
	ldb ,u						; check disable noise
	bitb #%10000000				; if bit7 of B is set disable noise
	beq sfx_enablenoise
sfx_disablenoise:
	ldb $C807					; set bit5 in reg7
	orb #%00100000
	lda #$07
 	jsr Sound_Byte 				; disable noise
	bra sfx_nextframe
sfx_enablenoise:
	ldb $C807					; clear bit5 in reg 7
	andb #%11011111		
	lda #$07
 	jsr Sound_Byte				; enable noise

sfx_nextframe:
	sty sfx_pointer				; update frame pointer to next flag byte in Y
	rts

sfx_endofeffect:

	ldb #$00					; set volume off channel 3	
	lda #$0A              		; set reg1sf0
	jsr Sound_Byte 				; Set volume

	ldd #$0000 					; reset sfx
	std	sfx_pointer
	sta sfx_status
	rts

message1:
	fcc	"PRESS 1-4"
	fcb	$80

sfx1:
  fcb $EE,$3C,$0,$C,$AE,$68,$0,$AE,$94,$0
  fcb $AE,$C0,$0,$AE,$EC,$0,$AE,$18,$1,$AE
  fcb $44,$1,$AD,$70,$1,$AD,$3C,$0,$AD,$68
  fcb $0,$AD,$94,$0,$AC,$C0,$0,$AC,$EC,$0
  fcb $AC,$18,$1,$AC,$44,$1,$AB,$70,$1,$AB
  fcb $3C,$0,$AB,$68,$0,$AB,$94,$0,$AA,$C0
  fcb $0,$AA,$EC,$0,$AA,$18,$1,$AA,$44,$1
  fcb $A9,$70,$1,$A9,$3C,$0,$A9,$68,$0,$A9
  fcb $94,$0,$A8,$C0,$0,$A8,$EC,$0,$A8,$18
  fcb $1,$A8,$44,$1,$A7,$70,$1,$A7,$3C,$0
  fcb $A7,$68,$0,$A7,$94,$0,$A6,$C0,$0,$A6
  fcb $EC,$0,$A6,$18,$1,$A6,$44,$1,$A5,$70
  fcb $1,$A5,$3C,$0,$A5,$68,$0,$A5,$94,$0
  fcb $A4,$C0,$0,$A4,$EC,$0,$A4,$18,$1,$A4
  fcb $44,$1,$A3,$70,$1,$A3,$3C,$0,$A3,$68
  fcb $0,$A3,$94,$0,$A2,$C0,$0,$A2,$EC,$0
  fcb $A2,$18,$1,$A2,$44,$1,$A1,$70,$1,$A1
  fcb $3C,$0,$A1,$68,$0,$A1,$94,$0,$A1,$C0
  fcb $0,$A1,$EC,$0,$A1,$18,$1,$A1,$44,$1
  fcb $A1,$70,$1,$A1,$3C,$0,$A1,$68,$0,$A1
  fcb $94,$0,$A1,$C0,$0,$A1,$EC,$0,$A1,$18
  fcb $1,$A1,$44,$1,$A1,$70,$1,$A1,$3C,$0
  fcb $A1,$68,$0,$A1,$94,$0,$A1,$C0,$0,$A1
  fcb $EC,$0,$A1,$18,$1,$A1,$44,$1,$D0,$20
sfx2:
  fcb $6F,$1,$4,$7,$F,$2F,$64,$0,$F,$2E
  fcb $5A,$0,$2E,$5C,$0,$2D,$5F,$0,$2D,$61
  fcb $0,$2C,$64,$0,$2C,$66,$0,$2B,$69,$0
  fcb $2B,$6B,$0,$2A,$6E,$0,$2A,$70,$0,$29
  fcb $73,$0,$29,$75,$0,$28,$78,$0,$28,$7A
  fcb $0,$27,$7D,$0,$27,$7F,$0,$26,$82,$0
  fcb $26,$84,$0,$25,$87,$0,$25,$89,$0,$24
  fcb $8C,$0,$24,$8E,$0,$23,$91,$0,$23,$93
  fcb $0,$22,$96,$0,$22,$98,$0,$21,$9B,$0
  fcb $D0,$20
sfx3:
  fcb $6F,$57,$0,$6,$4E,$C,$4D,$12,$4B,$18
  fcb $4A,$16,$49,$1C,$48,$2,$47,$8,$46,$E
  fcb $45,$14,$44,$1A,$43,$0,$42,$B,$41,$11
  fcb $41,$17,$D0,$20
sfx4:
  fcb $EF,$68,$1,$1A,$EF,$8A,$0,$19,$AF,$D2
  fcb $0,$EF,$DF,$0,$18,$AF,$76,$1,$AF,$BC
  fcb $1,$AF,$E9,$1,$AF,$10,$2,$AF,$35,$0
  fcb $AF,$73,$2,$AF,$98,$2,$AF,$B2,$2,$AF
  fcb $DB,$2,$AF,$6,$3,$EF,$54,$3,$19,$EF
  fcb $98,$3,$1C,$EF,$44,$3,$19,$EF,$7F,$2
  fcb $11,$EF,$F3,$1,$9,$EF,$94,$1,$6,$EF
  fcb $4D,$1,$4,$EF,$13,$1,$7,$EF,$FF,$0
  fcb $19,$EF,$EC,$0,$1B,$EF,$DB,$0,$18,$AF
  fcb $CE,$0,$EF,$6,$7,$17,$AF,$29,$7,$EF
  fcb $70,$7,$16,$AF,$E1,$7,$8F,$8F,$CF,$15
  fcb $8F,$CF,$14,$EF,$38,$0,$13,$AF,$19,$0
  fcb $EF,$11,$0,$12,$EF,$F,$0,$11,$AF,$E
  fcb $0,$CF,$10,$AF,$10,$0,$AF,$14,$0,$EF
  fcb $79,$0,$0,$AF,$7D,$0,$AF,$28,$0,$AF
  fcb $16,$0,$AF,$13,$0,$AF,$10,$0,$8F,$8F
  fcb $AF,$11,$0,$AF,$13,$0,$AF,$14,$0,$AF
  fcb $17,$0,$AF,$19,$0,$AF,$1C,$0,$AF,$20
  fcb $0,$AF,$27,$0,$8F,$AF,$20,$0,$AF,$19
  fcb $0,$AF,$13,$0,$AF,$B,$0,$D0,$20






		






 
