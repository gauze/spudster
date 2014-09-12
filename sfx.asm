;sfx_pointer	EQU	$c880		
;sfx_status	EQU	$c882	

;    LDX #sfx4					; play sfx4
;	STX sfx_pointer
;	LDA #$01
;	STA sfx_status   

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
