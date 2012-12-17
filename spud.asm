
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;< Spudster's Revenge - a Play in 3 acts                            <
;> by Brian Mastrobuono (gauze@dropdead.org)                        >
;< copyright 2002-2013 GNU GPL licensed, use as you wish as long as <
;> your changes in source form are made public                      >
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; best viewed with vim :set ts=4  (www.vim.org)
	title "Spudster's Revenge"
;		BIOS ROUTINES and other crap
	include "VECTREX.I"
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;			VARIABLES
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
current_song equ music8    ; junk.

;;; player (Spud) values
score 		equ $C880		;7 bytes as defined in BIOS routine Add_Score_?
level 		equ score+7
spuds_left 	equ level+1
spud_ypos 	equ spuds_left+1  ; y
spud_xpos	equ spud_ypos+1   ; x
spud_coor	equ spud_ypos     ; for Object hit routine load into Y-reg
spudstate 	equ spud_xpos+1 
mollystate 	equ spudstate+1
spud_start 	equ mollystate+1

; missle
arrow_y 	equ spud_start+2  ; y
arrow_x 	equ arrow_y+1     ; x
arrow_coor  equ arrow_y		  ; for Object_Hit routines load into X
;								this routine take 2 bytes args

intlevel 	equ arrow_x+1
brightdir 	equ intlevel+1
coord		equ brightdir+1
maxbright	equ coord+2
minbright	equ	maxbright+1
count		equ minbright+1
dec_score	equ count+1
highscore	equ	dec_score+7
;


;]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
;|             SETTING UP AND MAIN BLOCK                  |
;[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[
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


	jsr 	setup			; sets up what hardware to use and stuff
restart
	jsr		start
	jsr 	titlescreen		; wait for button press here before start
	jsr		arrow_create	; create an arrow
;
main
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
	jsr 	button_push
;
	jsr		draw_post
	jsr		draw_molly
;
	lda		spud_xpos
	cmpa	#53				; right next 2 molly
	bne		cantscore
	jsr		check_if_score
cantscore
	;jsr		draw_mollysface ; TODO
	jsr		draw_mollyslegs 
	jsr		draw_spud
	;jsr		draw_spudslegs 	; TODO

	jsr		Reset0Int
	jsr		draw_arrow

; collision
	ldx		arrow_coor
	ldy		spud_coor
	lda		#20			; MUST fix ; spud h/2
	ldb		#10			; MUST fix ; spud w/2
	jsr		Obj_Hit
	blo		yer_hit
	bra		yer_ok
yer_hit
	jsr		got_hit
	jsr 	arrow_create
yer_ok

; move the arrow for next loop and 
	lda		level
arrow_speed
	jsr 	move_arrow
	deca 	
	bne arrow_speed	
	jsr 	arrow_in_bounds  ; check if it's at legal pos

; checking for game over condition...
	lda		spuds_left
	lbne	main		; jump to top
	jmp		gameoverloop

; *** end of main ***
;
;#######################################################
;		SUBROUTINES/FUNCTIONS BUNCH OF SHIT
;#######################################################

	include	"functions.i"
	include "vecvox.i"

;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;             DATA SECTION
;********************************************************
	include "data.i"

	end

