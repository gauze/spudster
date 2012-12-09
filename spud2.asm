
	INCLUDE "VECTREX.I"

arrow_y 	equ $C880 			;spud_start+2  ; y
arrow_x 	equ arrow_y+1     ; x

	org 	$0000  ; start at ...
    fcc    "g GCE k666"
    fcb    $80
    fdb    music8
    fdb    $f850
    fcb    $30
	fcb		-$70		; X
    fcc    "TOTALLY ANNOYING THING"
    fcb    $80,$0

	jsr		arrow_create	; create an arrow
main
	jsr 	Wait_Recal
	jsr 	Intensity_3F
	lda		#127	;
	jsr 	set_scale 	

; test comment out next 3 lines (or actually just the 3rd) and it works
	lda		arrow_y
	cmpa	#0
	bne		arrow_ok
	jsr		arrow_create
arrow_ok
	lda		arrow_x
	cmpa	#-127
	bne		arrow_still_ok
	jsr 	arrow_create
arrow_still_ok
; end test	
	jsr 	move_arrow
	jsr		draw_arrow

	bra 	main			; and ... begin </rizzo>
; functions
draw_arrow
	lda		arrow_y
	ldb		arrow_x
	jsr		Moveto_d
	ldx		#Arrow		
	jsr 	Draw_VLc
	rts
arrow_create
	lda		#126
	sta		arrow_y		; height
	jsr		Random
	suba	#126
	sta		arrow_x  
	rts
move_arrow
	dec		arrow_x
	dec		arrow_y
	rts

set_scale		;scales to content of reg A
	sta		$D004	; VIA t1 cnt lo register.
	rts

; data
Arrow		; only one not it 0x01 terminated format
	fcb 7 
	fcb 0,4 
	fcb 0,-4
	fcb 4,0 
	fcb -4,0 
	fcb 12,12
	fcb 0,4 
	fcb 0,-4 
	fcb 4,0 
