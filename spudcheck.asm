;; Spudster's Revenge - a Play in 3 acts by Brian Mastrobuono (gauze@rifug.org)
	INCLUDE "VECTREX.I"
	INCLUDE "data.i"
;
;; -- variables general game
current_song equ musa    ; junk.
;
;

;;; player (Spud) values
score 		equ $C881		; 6 bytes as defined in BIOS routine Add_Score_?
level 		equ score+6
spuds_left 	equ level+1
spud_ypos 	equ spuds_left+1  ; y
spud_xpos	equ spud_ypos+1   ; x
spud_coord  equ spud_ypos     ; for Object hit routine load into Y-reg
;
;;; states of other game objects (non-player)
spudstate 	equ spud_xpos+1 
mollystate 	equ spudstate+1
joypressed 	equ mollystate+1
live_arrow 	equ joypressed+1
arrow_y 	equ live_arrow+1  ; y
arrow_x 	equ arrow_y+1     ; x
arrow_coor  equ arrow_y		  ; for Object_Hit routines load into X-Reg

intlevel equ arrow_x+1
brightdir equ intlevel+1
coord		equ brightdir+1
maxbright	equ coord+2
;
;
;
	org 	$0000  ; start at ...
;; *** Init block
;
    fcc    "g GCE k666"
    fcb    $80
    fdb    current_song
    fdb    $f850
    fcb    $30		; X
	fcb	   -$70		; Y
    fcc    "SPUDSTER'S REVENGE"
    fcb    $80
	fcb		$0
;;# end of magic init block.
	jsr 	setup			; sets up what hardware to use and stuff
	jsr 	titlescreen		; wait for button press here before game start
;
main
;	jsr		start_one_vectrex_round	 ; needed?
	jsr 	Wait_Recal
	jsr 	Intensity_3F
	lda		#127	;
	jsr 	scale 	
;	jsr		DP_to_D0
	lda 	#0
;	jsr		guys_left
;
;	jsr		sound_update
;	jsr 	joystick_crap
;

	jsr		draw_post
;	jsr		draw_molly
;	jsr		draw_spud

;	jsr 	check_arrow_hit
;	lda 	live_arrow  	;check if there is an arrow
;	beq		arrow_create	; make new one if not
;	jsr 	move_arrow
;	jsr		draw_arrow
;;	jsr		check_for_score	; put this routine in above maybe
	bra 	main			; and ... begin

; *** end of main ***
;	
level_up
	rts
;
draw_arrow
;	ldb 	#$CC 		; bitmap for...
;	stb 	VIA_cntl 	; ~BLANK low and ~ZERO low
	lda		arrow_y
	ldb		arrow_x
	jsr		Moveto_d
	ldx		#Arrow		;movhi: #_Arrow -> R:x
	jsr 	Draw_VLc
	rts
;
check_arrow_hit
	lda		arrow_y
	bpl		arrow_ok
	lda		#0
	sta		live_arrow
arrow_ok
	rts
;
draw_post
;	ldb 	#$CC 	; bitmap for...
;	stb 	$D00C 	; ~BLANK low and ~ZERO low
	lda		#127
	jsr		scale	
	ldd		#0
	jsr		Moveto_d
;	jsr		DP_to_D0
	jsr		Intensity_3F
	ldx		#Post	
	jsr 	Draw_VLc
	rts
;
draw_molly
	lda		#83
	jsr 	scale 	
	ldx		#Molly	
	jsr 	Draw_VLp
	rts
;
draw_spud
	lda		#127	;movqi: #127 -> R:a
	jsr 	scale 	
	ldb 	#$CC 	; bitmap for...
	stb 	$D00C 	; ~BLANK low and ~ZERO low
	lda		spud_xpos
	jsr 	Moveto_d
	ldx		#Spud	;movhi: #_Spud -> R:x
	jsr 	Draw_VLp
	rts
;
sound_update
	rts
;
arrow_create
	lda		#1
	sta		live_arrow	;
	lda		#0
	sta		arrow_y		; height
;	jsr 	Random	
	sta		arrow_x  	; get random x coord
	rts
;
move_arrow
	dec		arrow_x
	dec		arrow_y
	rts
;
joystick_crap
	rts
;
;check_for_score
;	lda 	spud_xpos
;	suba	#52
;	bne		no_score
;	lda		Vec_Btn_State
;	bita	#$01					; is btn 1 pressed?
;	bne		no_score
;	inc		score		; score here
;	lda		#%0000001
;	ldx 	score
;	jsr		Add_Score_a		
;	lda		#1
;	sta		mollystate
;	sta		spudstate
;no_score
;	rts
;
do_ow
	ldu		#owstr	
	lda 	#0
	ldb		#36	
	jsr 	Print_Str_d 	; print_str_d
	rts
;
gameover
	jsr 	Wait_Recal
	jsr 	Intensity_3F
	ldu		#gameoverstr	;movhi: #LC6 -> R:u
	lda		#1
	ldb		#206	;movqi: #206 -> R:b
	jsr 	Print_Str_d 	; print_str_d
	ldx		score
	ldu		$CBEB 	; Default location?
	jsr		New_High_Score
	rts
;
;playagain
;	jsr 	Wait_Recal
;	clra		;movqi: ZERO -> R:a
;	ldb		#206	;movqi: #206 -> R:b
;	ldu		#playagainstr	;movhi: #LC6 -> R:u
;	jsr 	Print_Str_d 	; print_str_d
;	lda		#211	;movqi: #211 -> R:a
;	ldb		#146	;movqi: #146 -> R:b
;	ldu		#playagainstr	;movhi: #LC7 -> R:u
;	jsr 	Print_Str_d 	; print_str_d
;	lda 	#0
;	jsr 	Read_Btns_Mask
;	jsr 	Joy_Digital 	; joy_digital
;	clra		
;	clrb	; D=0
;	rts		; return from function

;
titlescreen
	jsr		Read_Btns
 	lda     Vec_Button_1_2
    beq    	no_btn_psh
    lda     Vec_Button_1_3
    beq    	no_btn_psh
    lda     Vec_Button_1_4
    beq    	no_btn_psh
    jmp     hidden_msg          ; all 3 buttons pushed
no_btn_psh
	jsr		Wait_Recal
	jsr		Intensity_5F
	ldu		#titlestring
	lda		#$30
	ldb		#-$70
	jsr		Print_Str_d
;; start variable intensity routine
	lda		brightdir
	beq		down
up
	lda		#1				; lame ass pulsing thing
	adda	intlevel		; add 2 to intensity level
	cmpa	maxbright
	beq		changedirectiondown
	bra		finish_pulse
down	
	lda		#1
	suba	intlevel
	beq		changedirectionup
	bra		finish_pulse
changedirectionup
	lda		#1
	sta		brightdir
	bra		finish_pulse
changedirectiondown
	lda		#0
	sta		brightdir
	bra		finish_pulse
finish_pulse
	sta		intlevel		; save int
	jsr		Intensity_a		; set
; end intensity routine
	ldu		#startstring
	lda		#-50
	ldb		#-110
	jsr		Print_Str_d
	jsr		Read_Btns
	lda		Vec_Button_1_1
	lbne 	main	
	bra 	no_btn_psh	; if not pushed ... loop
	rts

;
;play_song
;	ldb		#1	;movqi: #1 -> R:b
;	stx		current_song	;movhi: R:x -> _current_song
;	jsr		Do_Sound
;	rts		; return from function
;
setup
	lda 	#1 	; enable  joystick 1's x axis, disable all others.
	sta 	Vec_Joy_Mux_1_X 	
	sta		brightdir
	sta		intlevel
	lda		#64
	sta		maxbright
	lda 	#0 	; disable
	sta 	Vec_Joy_Mux_1_Y
	sta 	Vec_Joy_Mux_2_X
	sta 	Vec_Joy_Mux_2_Y
	jsr 	Joy_Digital 	; set joymode, not analog.
	lda 	#0
	jsr 	Read_Btns	
	jsr 	Wait_Recal
	
;;	lda 	#0		; left over from C ... not needed?
;;	jsr     Read_Btns_Mask	
;;	jsr 	Wait_Recal
	jsr 	start
	rts		; return from function
;
hidden_msg
	jsr		Intensity_3F
	jsr		Wait_Recal
	ldu		#hidden1str
	lda		#0			
	ldb		#-60	
	jsr 	Print_Str_d 	
	ldu		#hidden2str	
	lda		#-20	
	ldb		#-76
	jsr 	Print_Str_d 
	bra		hidden_msg ; no escape
;
;start_one_vectrex_round
;	ldb		#200	;movqi: #200 -> R:b
;	tfr 	b,dp 	; set dp to b (dp is direct page reg)
;	pshs 	y 	; save y register to HW stack
;	ldu		current_song	;movhi: _current_song -> R:u
;	jsr 	Init_Music_chk
;	puls 	y 	; restore y register
;	jsr 	Wait_Recal 	; wait_recal
;	jsr 	Do_Sound 	; do_sound
;	rts		; return from function
start
	lda 	#3
	sta 	spuds_left
	ldd 	#0
	ldx 	score
	jsr		Clear_Score ; Bios routine yay
	lda		#0
	sta 	live_arrow
	sta 	spudstate
	sta 	mollystate
	lda 	#1
	sta 	level
	lda 	#-127
	sta 	spud_xpos
	rts

;	show guys left !
;guys_left 	; display number of 'guys' left
;	jsr		Intensity_3F
;	lda		#43 	; change
;	ldb		#32 	; fix
;	std		coord
;	lda		#$69
;	ldb		spuds_left	
;	ldx 	coord
;	jsr		Print_Ships
;	rts

scale		;scales to content of reg A
	sta		$D004	; VIA t1 cnt lo register.
	rts
;
end
	end

;	end
