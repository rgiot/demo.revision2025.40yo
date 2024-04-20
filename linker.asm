	org 0x1000
	run $

first_byte

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
	print nb_bytes , " currently used"
	print 4096 - nb_bytes, " remaining"