;;
; This snapshot is here to test if the idea of the demo system works.
; As it is a nightmare to use system routines from a bare snapshot; such init is currently disabled.
; TODO see how we can build reliable snapshots using the firmware. Do we have to improve assemblers ? or the learn to create snapshots ? ;) No time to check now
; Krusty / Benediction / April 2024
	
	
	include once "demosystem/public_macros.asm"
	include once "demosystem/private_macros.asm"


	; Here include the whole demosystem
SELECTED_PAGE = 1
	bankset SELECTED_PAGE
page1_start equ 0xc000
	include "demosystem/demosystem.asm"
page1_length = $ - page1_start



	; Here include the small memory area that has to be used by the parts
SELECTED_PAGE = 0
	bankset SELECTED_PAGE

	; Tiny bootstrap to launch the demo
	org 0x8000
	run $
page0_start
	include "demosystem/demosystem_init.asm"
page0_length = $ - page0_start

	print "PAGE0: ", {hex}page0_length, " bytes from ", {hex}page0_start
	print "PAGE1: ", {hex}page1_length, " bytes from ", {hex}page1_start


	bankset 0
	save "page0.o", page0_start, page0_length
	
	bankset 1
	save "page1.o", page1_start, page1_length
	save "page1_without_music_and_parts.o", page1_start, demosystem_code_only_length
	save "page1_without_parts.o", page1_start, demosystem_code_and_music_length