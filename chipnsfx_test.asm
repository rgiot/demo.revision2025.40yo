
; to get square roots music : bndbuild disc Square\ Roots\ CHP.DSK get CHIP-SQR.BIN
; to build sna : bndbuild basm chipnsfx_test.asm  --sna -o  chipnsfx.sna --override --lst chipnsfx_test.lst && AceDL chipnsfx.sna 

	org 0x4000
	run $


first_byte



	di
		ld hl, 0xc9fb
		ld (0x38), hl
		ld sp, $
	ei

	ld bc, 0xbc00  + 1 : out (c), c
	ld bc, 0xbd00  + 0 : out (c), c

	; song prebuilt/ no need to init
	;ld hl, song_header
	;call chip_song

loop

	ld b, 0xf5
	in a, (c)
	rra
	jr nc, loop


	halt
	halt
	ld bc, 0x7f10 : out (c), c
	ld bc, 0x7f4b : out (c), c

	call chip_play


	ld bc, 0x7f10 : out (c), c
	ld bc, 0x7f40 : out (c), c

	ld b, 100
wait defs 60
	djnz wait

	jp loop





writepsg ; A=BYTE,C=REG.; -
	push bc
	ld b,$F4
	out (c),c
	ld bc,$F6C0;SELECT
	out (c),c
	dw $71ED;CPC PLUS!
	ld b,$F4
	out (c),a
	ld bc,$F680;UPDATE
	out (c),c
	dw $71ED;CPC PLUS!
	pop bc
	ret

CHIPNSFX_FLAG = 0 + 4 + 256 + 512
chipnsfx
	include "music/chipnsfx.z80"
music
	include "music/4k08_final_tj.asm"
chip_song_a = song_a
chip_song_b = song_b
chip_song_c = song_c

	print "CHIPNSFX_TOTAL=", CHIPNSFX_TOTAL

length = $-first_byte 

	save "SQR.BIN", first_byte, length, DSK, "SQR.DSK"
	save "SQR.BIN", first_byte, length, AMSDOS
	SAVE "ZICPLY.BIN", writepsg, $-writepsg