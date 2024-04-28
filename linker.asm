	org 0x2000

first_byte
	run $

	; As we want to reuse the system, it is mandatory to backup all these registers. Yep lots of space lost here ...
	di
		;;
		; Uncrunch all data and code in memory
		; we expect than crunching the two pages together increase compression ratio
		exx : push ix, hl, de, bc
		ex af, af' : push af
			ld ix, crunched_data
			ld de, 0xc000
			call shrinkler_decrunch
		pop af : ex af, af'
		pop bc, de, hl, ix : exx

		;;
		; Copy page 0 at the appropriate place
		ld hl, 0xc000 + page0_start - crunched_data
		ld de, 0x1000
		ld bc, page0_length
		ldir
		
		;;
		; Copy page 1 at the appropriate place
		ld bc, 0x7fc7 : out (c), c
		ld hl, 0xc000 + page1_start - crunched_data
		ld de, 0x4000
		ld bc, page1_length
		ldir
		ld bc, 0x7fc0 : out (c), c

	ei 

		jp 0x1000

crunched_data
	LZSHRINKLER
page0_start
		incbin "page0.o"
page0_length equ $-page0_start
page1_start
		incbin "page1.o"
page1_length equ $-page1_start
	LZCLOSE
crunched_data_length equ $-crunched_data

	include "demosystem/deshrink.asm"


nb_bytes = $-first_byte

	assert page0_length < 0x1000, "you crash the linker there..."
	assert crunched_data_length < 0x4000, "linker cannot work"

	print "Summary"
	print nb_bytes , " currently used"
	print 4096 - nb_bytes, " remaining"



	save "40.amd", first_byte, nb_bytes, DSK, "40_amd.dsk"