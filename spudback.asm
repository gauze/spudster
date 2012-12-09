
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;< Spudster's Revenge - a Play in 3 acts                            <
;> by Brian Mastrobuono (gauze@rifug.org)                           >
;<	copyright 2002 GNU GPL licensed, use as you wish as long as     <
;>  your changes in source form are made public                     >
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; best viewed with vim :set ts=4  (www.vim.org)

;		BIOS ROUTINES and other crap
	INCLUDE "VECTREX.I"
;
;; -- variables general game
current_song equ music8    ; junk.

;;; player (Spud) values
score 		equ $C880		;7 bytes as defined in BIOS routine Add_Score_?
level 		equ score+7
spuds_left 	equ level+1
spud_ypos 	equ spuds_left+1  ; y
spud_xpos	equ spud_ypos+1   ; x
spud_coor  equ spud_ypos     ; for Object hit routine load into Y-reg

;;; states of other game objects (non-player)
spudstate 	equ spud_xpos+1 
mollystate 	equ spudstate+1
joypressed 	equ mollystate+1
spud_start 	equ joypressed+1
arrow_y 	equ spud_start+2  ; y
arrow_x 	equ arrow_y+1     ; x
arrow_coor  equ arrow_y		  ; for Object_Hit routines load into X
;								this routine take 2 bytes args

intlevel equ arrow_x+1
brightdir equ intlevel+1
coord		equ brightdir+1
maxbright	equ coord+2
minbright	equ	maxbright+1
count		equ minbright+1
;
;
;
	org 	0  ; start at ...
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

;]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
;|             SETTING UP AND MAIN BLOCK                  |
;[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[
	jsr 	setup			; sets up what hardware to use and stuff
top_o_block
	jsr		start
	jsr 	titlescreen		; wait for button press here before start
	jsr		arrow_create	; create an arrow
;
main
;	jsr		start_one_vectrex_round	 ; needed?
	jsr 	Wait_Recal
	jsr 	Intensity_3F
	lda		#127
	jsr 	set_scale 	
	lda 	#0
	jsr		guys_left
	jsr		show_score
;
;	jsr		sound_update
	jsr 	joystick_crap
;

	jsr		draw_post
	jsr		draw_molly
;
	lda		spud_xpos
	cmpa	#52				; right next 2 molly
	bne		cantscore
	jsr		check_if_score
cantscore
	jsr		draw_mollyslegs
;	jsr		draw_mollysface ; must code.
	jsr		draw_spud
;	jsr		draw_spudslegs

	jsr 	arrow_in_bounds  ; check if it's at legal pos
	jsr		Reset0Int
	jsr		draw_arrow

;	jsr 	check_arrow_hit

	ldx		arrow_coor
	ldy		spud_coor
	lda		#10			; MUST fix
	ldb		#20			; MUST fix
	jsr		Obj_Hit
	blo		yer_hit
	bra		yer_ok
yer_hit
	jsr		got_hit
	bsr 	arrow_create
yer_ok

; move the arrow for next loop and 
	jsr 	move_arrow

; checking for game over condition...
	lda		spuds_left
	lbne	in_play
	jmp		gameover
in_play

	bra 	main			; and ... begin </rizzo>

; *** end of main ***
;
;#######################################################
;		SUBROUTINES/FUNCTIONS BUNCH OF SHIT
;#######################################################

	INCLUDE	"functions.i"

arrow_create
	lda		#127
	sta		arrow_y		; height
	jsr 	Random
;	suba	#127 		; not sure if needed
	sta		arrow_x  	; get random x coord
	rts
	
; display score, once per frame ...
show_score
	ldu		#score
	lda		#-10
	ldb		#-100
	jsr		Print_Str_d		
	rts
;
check_if_score
	lda		Vec_Button_1_1
	beq		no_score
	lda		#%00000001
	daa
	tfr		a,b
	clra
	tfr		d,u
	ldx 	[score]
	jsr		Add_Score_a		
	lda		#1
	sta		mollystate
	sta		spudstate
no_score
	rts
;
level_up
	inc		level
; add more shit to increase game speed?
	rts
;
draw_arrow
	lda		arrow_y
	ldb		arrow_x
	jsr		Moveto_d
	ldx		#Arrow		
	jsr 	Draw_VLc
	rts
;
check_arrow_hit
	lda		arrow_y
	bne		arrow_ok
	dec		spuds_left
arrow_ok
	rts
;
arrow_in_bounds
; start of arrow bounds checking 	
; x test
	lda		arrow_x
	cmpa	#-127
	bne		x_ok
	jsr		arrow_create
x_ok
;y test
	lda		arrow_y
	cmpa	#0
	bne		y_ok
	bsr		arrow_create
y_ok
	rts

; end of arrow bounds checking
draw_post
	lda		#127
	jsr		set_scale	
	ldd		#0
	jsr		Moveto_d
	jsr		Intensity_3F
	ldx		#Post	
	jsr 	Draw_VLp
	rts
;
draw_molly
	lda		#83
	jsr 	set_scale 	
	ldx		#Molly	
	jsr 	Draw_VLp
	rts
;
draw_mollysface
	rts
draw_mollyslegs
	lda 	#83
	jsr		set_scale
	ldx		#MollysLegs
	jsr		Draw_VLp
	rts

draw_spud
	lda		#127	
	jsr 	set_scale 	
	jsr		Reset0Int
	lda		spud_ypos
	ldb		spud_xpos
	jsr 	Moveto_d
	ldx		#Spud	
	jsr 	Draw_VLp
	rts
;
sound_update
	rts
;
;
move_arrow
	dec		arrow_x
	dec		arrow_y
	rts
;
joystick_crap
	jsr		Joy_Digital
	lda     Vec_Joy_1_X  
	beq		done_moving		;end
	bmi		going_left
going_right
	lda 	spud_xpos
	cmpa	#53
	beq		done_moving 		; if >= 52 don't move.
	inc		spud_xpos
	inc		spud_xpos
	bra		done_moving		;end
	bra		done_moving 		;end
going_left
	lda		spud_xpos
	cmpa	#-127
	beq		done_moving
	dec		spud_xpos
	dec		spud_xpos
	bra		done_moving
done_moving
	rts
;

; 	Lost a guy ...
got_hit
	dec		spuds_left
	lda		spud_start
	sta		spud_xpos
	lda		#255
	sta		count
loopy
	jsr 	Delay_3
	ldu		#owstr	
	lda 	#0
	ldb		#36	
	jsr 	Print_Str_d 	; print_str_d
	dec		count
	bne 	loopy
	rts
; Obvious. print GO msg, check high score, ask if want to play again ...
gameover
	ldx		[score]			; check for new high score
	ldu		Vec_High_Score 	
	jsr		New_High_Score
gameoverloop
	jsr 	Wait_Recal
	jsr 	Intensity_3F
	ldu		#gameoverstr
	lda		#1
	ldb		#206
	jsr 	Print_Str_d 
	jsr 	Read_Btns
	lda     Vec_Button_1_1
	ora     Vec_Button_1_2
	ora		Vec_Button_1_3
	ora		Vec_Button_1_4
	bne		playagain
	bra		gameoverloop
playagain
	jsr		Warm_Start
;	jmp		top_o_block

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
;; start variable intensity routine NEED 2 FIX
	lda		brightdir			; Load variable saying which
	bne		up				; direction we're going & test
down	
	dec		intlevel			; load the 'level' of bright
	lda		intlevel		
	cmpa	minbright			;compare it to our threshhold
	beq		changedir2up		; if yes: 
	bra		finish_pulse
up
	inc		intlevel
	lda		intlevel
	cmpa	maxbright
	beq		changedir2down
	bra		finish_pulse
changedir2up
	lda		#1
	sta		brightdir
	bra		finish_pulse
changedir2down
	lda		#0
	sta		brightdir
finish_pulse
	lda		intlevel
	jsr		Intensity_a			; set intensity here
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
play_song
	ldb		#1	;movqi: #1 -> R:b
	stx		current_song	;movhi: R:x -> _current_song
	jsr		Do_Sound
	rts		; return from function
;
setup
	lda 	#1 	; enable  joystick 1's x axis, disable all others.
	sta 	Vec_Joy_Mux_1_X 	
	sta		intlevel			; intensity level
	lda		#64
	sta		maxbright 			; max intensity
	lda		#10
	sta		minbright			; min intensity
	lda 	#0 				; disable for Joy Mux's
	sta		brightdir			; direction 0 down 1 up 
	sta 	Vec_Joy_Mux_1_Y
	sta 	Vec_Joy_Mux_2_X
	sta 	Vec_Joy_Mux_2_Y
	jsr 	Joy_Digital 	; set joymode, not analog.
	lda 	#0
	jsr 	Read_Btns		; no idea why this is here.
	jsr 	Wait_Recal
	rts		; return from function

;
start
	lda 	#3
	sta 	spuds_left
;	ldx 	[score]
;	jsr		Clear_Score ; Bios routine yay
	lda		#$30
	sta		score
	sta		score+1
	sta		score+2
	sta		score+3
	sta		score+4
	sta		score+5
	lda		#$80
	sta		score+6
	lda		#0
	sta 	spudstate
	sta 	mollystate
	lda 	#1
	sta 	level
	lda		#-127
	sta		spud_start
	lda 	spud_start	
	sta 	spud_xpos
	lda		#50
	sta		spud_ypos
	rts

; show hidden msg requires reset to escape
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

guys_left 	; display number of 'guys' left
	jsr		Intensity_3F
	lda		#-10 	; fix
	ldb		#65 	; change
	std		coord
	lda		#$69
	ldb		spuds_left	
	ldx 	coord
	jsr		Print_Ships
	rts

set_scale		;scales to content of reg A
	sta		$D004	; VIA t1 cnt lo register.
	rts

;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;             DATA SECTION
;********************************************************
	INCLUDE "data.i"

;	end

	end

