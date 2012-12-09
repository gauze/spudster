
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;< Spudster's Revenge - a Play in 3 acts                            <
;> by Brian Mastrobuono (gauze@dropdead.org)                        >
;< copyright 2002-2013 GNU GPL licensed, use as you wish as long as <
;> your changes in source form are made public                      >
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; best viewed with vim :set ts=4  (www.vim.org)
;
;#######################################################
;		SUBROUTINES/FUNCTIONS
;#######################################################

arrow_create
	lda		#127
	sta		arrow_y		; height
	jsr 	Random		; positive number 0-255
	asra				; shift right, divide by /2 basically
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
show_level
	ldu		level
	lda		#-20
	ldb		#-100
	jsr		Print_Str_d		
	rts
;
inc_score
	inc		dec_score
	lda		#1
	ldx 	#score
	jsr		Add_Score_a		
	lda		level	; level
	ldb		#50		; 50
	mul				; times 
	cmpd    dec_score
	blt		nope
	inc 	level	
nope	
	rts
;
check_if_score
	jsr		Read_Btns
	lda		Vec_Button_1_1
	beq		no_score
	jsr		inc_score
	lda		#1
	sta		mollystate
	sta		spudstate
no_score
	rts
;
level_up
	inc		level
; add more to increase game speed?
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

arrow_in_bounds
; start of arrow bounds checking 	
; x test
	lda		arrow_x
	cmpa	#-127
	bne		x_ok
	bsr		arrow_create
x_ok
; y test
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
; TODO
; include bow animation?
	rts
;
draw_mollyslegs
	lda 	#83
	jsr		set_scale
;	ldx		#MollysLegs
	ldx		#MollysLegsHum
	jsr		Draw_VLp
	rts
;

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
draw_spudslegs
; TODO
	rts
;
sound_update
; TODO
	rts
;

move_arrow
	dec		arrow_x
	dec		arrow_y
	rts
;
button_push
	
	rts
;

joystick_crap
	jsr		Joy_Digital
	lda     Vec_Joy_1_X  
	beq		done_moving		;end
	bmi		going_left
;
going_right
	lda 	spud_xpos
	cmpa	#53
	beq		done_moving 		; if >= 52 don't move.
	inc		spud_xpos
	inc		spud_xpos
	bra		done_moving		;end
;
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
;
loopy
	jsr 	Delay_3
	ldu		#owstr	
	lda 	#0
	ldb		#36	
	jsr 	Print_Str_d 	 
	dec		count
	bne 	loopy
	rts
;
gameoverloop
	jsr 	Wait_Recal
	jsr 	Intensity_3F
	ldu		#gameoverstr
	lda		#1
	ldb		#206
	jsr 	Print_Str_d 
	jsr		show_score
	jsr 	Read_Btns
	lda     Vec_Button_1_1
	ora     Vec_Button_1_2
	ora		Vec_Button_1_3
	ora		Vec_Button_1_4
	lbne	restart
	bra		gameoverloop
;

;
titlescreen
	lda		%00000000
	jsr		Read_Btns_Mask
	lda		Vec_Button_1_1
	bne 	main	
 	lda     Vec_Button_1_2
   	beq    	no_btn_psh
   	lda     Vec_Button_1_3
   	beq    	no_btn_psh
   	lda     Vec_Button_1_4
   	beq    	no_btn_psh
   	jmp     hidden_msg          ; all 3 buttons pushed
;
no_btn_psh
	clra
	clrb
	jsr		Wait_Recal
	jsr		Intensity_5F
	ldu		#titlestring
	lda		#$30
	ldb		#-$70
	jsr		Print_Str_d
;
;; start variable intensity routine NEED 2 FIX
	lda		brightdir		; Load variable saying which
	bne		up			; direction we're going & test
down	
	dec		intlevel		; load the 'level' of bright
	lda		intlevel		
	cmpa	minbright			;compare it to our threshhold
	beq		changedir2up		; if yes: 
	bra		finish_pulse
;
up
	inc		intlevel
	lda		intlevel
	cmpa	maxbright
	beq		changedir2down
	bra		finish_pulse
;
changedir2up
	lda		#1
	sta		brightdir
	bra		finish_pulse
;
changedir2down
	lda		#0
	sta		brightdir
;
finish_pulse
	lda		intlevel
	jsr		Intensity_a		; set intensity here
; end intensity routine
	ldu		#startstring
	lda		#-50
	ldb		#-110
	jsr		Print_Str_d
	bra 	titlescreen	; if not pushed ... loop
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
	lda 	#1 				; disable for Joy Mux's
	sta		brightdir			; direction 0 down 1 up 
	sta 	Vec_Joy_Mux_1_Y
	sta 	Vec_Joy_Mux_2_X
	sta 	Vec_Joy_Mux_2_Y
	jsr 	Joy_Digital 	; set joymode, not analog.
	lda 	#0
	jsr		vox_init
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
;
set_scale		;scales to content of reg A
	sta		$D004	; VIA t1 cnt lo register.
	rts

