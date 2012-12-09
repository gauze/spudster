; DATA section
Spud
	fcb 1, 6, 6
	fcb -1, 0, 12
	fcb -1, -6, 6
	fcb -1, -25, -7
	fcb -1, 0, -9
	fcb -1, 25, -7
	fcb 0, -1, 8
	fcb -1, -4, 4
	fcb -1, 4, 4
	fcb -1, -3, -3 
	fcb -1, -2, 0
	fcb -1, 2, 0
	fcb -1, -1, -1
	fcb -1, 1, -1
	fcb -1, -2, 0
	fcb 0, -20, 3
	fcb -1, -2, -1
	fcb -1, -1, 2
	fcb -1, 5, 8
	fcb -1, 2, 1
	fcb -1, -1, -3
	fcb -1, -2, -4
	fcb 0, 10, -9
	fcb -1, 0, 7
	fcb -1, -3, -1
	fcb -1, 3, -1
	fcb -1, 0, -6
	fcb -1, -3, 1
	fcb -1, 3, 1
	fcb 1 
SpudHump 
	fcb 1, 6, 6 
	fcb -1, 0, 12
	fcb -1, -6, 6
	fcb -1, -25, -7
	fcb -1, 0, -9
	fcb -1, 25, -7
	fcb 0, -1, 8
	fcb -1, -4, 4
	fcb -1, 4, 4
	fcb -1, -3, -3
	fcb -1, -2, 0
	fcb -1, 2, 0
	fcb -1, -1, -1
	fcb -1, 1, -1
	fcb -1, -2, 0
	fcb 0, -20, 3
	fcb -1, -2, -1
	fcb -1, -1, 2
	fcb -1, 5, 8
	fcb -1, 2, 1
	fcb -1, -1, -3
	fcb -1, -2, -4
	fcb 0, 10, -9
	fcb -1, 0, 7
	fcb -1, -3, -1
	fcb -1, 3, -1
	fcb -1, 0, -6
	fcb -1, -3, 1
	fcb -1, 3, 1
	fcb 1 
SpudDead 
	fcb 1, 6, 6
	fcb -1, 0, 12
	fcb -1, -6, 6
	fcb -1, -25, -7
	fcb -1, 0, -9
	fcb -1, 25, -7
	fcb 0, -1, 8
	fcb -1, -4, 4
	fcb -1, 4, 4
	fcb -1, -3, -3
	fcb -1, -2, 0
	fcb -1, 2, 0
	fcb -1, -1, -1
	fcb -1, 1, -1
	fcb -1, -2, 0
	fcb 0, -20, 3
	fcb -1, -2, -1
	fcb -1, -1, 2
	fcb -1, 5, 8
	fcb -1, 2, 1
	fcb -1, -1, -3
	fcb -1, -2, -4
	fcb 0, 10, -9
	fcb -1, 0, 7
	fcb -1, -3, -1
	fcb -1, 3, -1
	fcb -1, 0, -6
	fcb -1, -3, 1
	fcb -1, 3, 1
	fcb 1 
Post 
	fcb 0,0, -124
	fcb -1,0, 124
	fcb -1,0, 124
	fcb -1,100, 0
	fcb -1,0, -15
	fcb -1,-99, 0
	fcb	1
Molly 
	fcb 0, 26, -4
	fcb -1, 0, -34
	fcb -1, 7, 4
	fcb -1, 0, 26
	fcb -1, -7, 4
	fcb -1, 23, -13
	fcb -1, -11, -7
	fcb -1, 11, -14
	fcb -1, 1, -13
	fcb -1, 12, 12
	fcb -1, 18, -4
	fcb -1, -5, 15
	fcb -1, 15, 11
	fcb -1, -21, 1
	fcb -1, -9, 13
	fcb -1, -11, -15
	fcb 0, -7, -13
	fcb -1, -9, -3
	fcb -1, -8, -4
	fcb 1
MollysLegs
	fcb 0, 0, 10
	fcb -1, -20, 0
	fcb -1, 0, -10
	fcb -1, 10, 10
	fcb -1, 10, 0
	fcb 0, 0, 10
	fcb -1, -20, 0
	fcb -1, 0, 10
	fcb -1, 10, -10
	fcb 1 
MollysLegsHum 
	fcb 0 , 0 , 10
	fcb -1 , -15 , -15
	fcb -1 , 7 , -7
	fcb -1 , 0 , 12
	fcb 0 , 8 ,25
	fcb -1 , -15 , 15
	fcb -1 , 7 , 7
	fcb -1 , 0 , -12
	fcb 1
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
; TEXT DATA
titlestring
	fcc "SPUDSTER'S REVENGE"
	fcb 	$80
startstring
	fcc " PRESS 1 TO START"
	fcb 	$80
hidden1str
	fcc "CREATED BY"
	fcb 	$80
hidden2str
	fcc "WARREN ROBINETT"
	fcb 	$80
scorestr
	fcc "0000"
	fcb 	$80
owstr
	fcc "OW!!!"
	fcb 	$80
gameoverstr
	fcc "GAME OVER"
	fcb 	$80
playagainstr
	fcc "PRESS 1 TO PLAY AGAIN"
	fcb 	$80
musa
    fdb    $fee8
    fdb    $fbe6
    fcb    $0,$80
    fcb    $0,$80