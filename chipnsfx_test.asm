
; to get square roots music : bndbuild disc Square\ Roots\ CHP.DSK get CHIP-SQR.BIN
; to build sna : basm chipnsfx_test.asm  --sna -o  chipnsfx.sna && AceDL chipnsfx.sna

	org 0x1000
	run $



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

; song-only and prebuilt  chipnsfx_bss
CHIPNSFX_FLAG = 0 + 4 + 256
chipnsfx
	include "music/chipnsfx.z80"
music
	if 1
		include "music/WARHAWK.asm"
	chip_song_a = song_a
	chip_song_b = song_b
	chip_song_c = song_c
	else
		incbin "music/CHIP-SQR.BIN" ; header is automatically removed
	chip_song_a = music + 0x00
	chip_song_b = music + 0xbb
	chip_song_c = music + 0x16b

	;song_header:
	;	DEFW chip_song_a-$-2
	;	DEFW chip_song_b-$-2
	;	DEFW chip_song_c-$-2
	endif

	print "CHIPNSFX_TOTAL=", CHIPNSFX_TOTAL