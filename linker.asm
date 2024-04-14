	org 0x1000
	run $

first_byte

shrinked_page0_start
	LZSHRINKLER
		incbin "page0.o"
	LZCLOSE
shrinked_page0_length equ $-shrinked_page0_start

shrinked_page1_start
	LZSHRINKLER
		incbin "page1.o"
	LZCLOSE
shrinked_page1_length equ $-shrinked_page1_start

	include "demosystem/deshrink.asm"


nb_bytes = $-first_byte
	print nb_bytes , " currently used"
	print 4096 - nb_bytes, " remaining"