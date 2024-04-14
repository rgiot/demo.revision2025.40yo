;;
; This snapshot is here to test if the idea of the demo system works.
; As it is a nightmare to use system routines from a bare snapshot; such init is currently disabled.
; TODO see how we can build reliable snapshots using the firmware. Do we have to improve assemblers ? or the learn to create snapshots ? ;) No time to check now
; Krusty / Benediction / April 2024
	
	
	include once "demosystem/public_macros.asm"
	include once "demosystem/private_macros.asm"

	; Here include the small memory area that has to be used by the parts
SELECTED_PAGE = 0
	bankset SELECTED_PAGE

	; Tiny bootstrap to launch the demo
	org 0x1000
	run $


page0_start

	; TODO do the init related to the firmware code called by each part
	; Find a way to do it using few memory space (jumpblocs are not yet installed at that moment)


	; install the stack in 0x100 space and the jump blocs
	di
		BREAKPOINT

		ld sp, 0x100
		ld hl, jumpbloc_data
		ld de, 0x0000
		ld bc, jumploc_data_length
		ldir
	ei

	; TODO do the init that is not related to the firwmare code

	; TODO install the music under interruption

	; TODO launch the first part. That will itself launch the next one and so on
	jp $

jumpbloc_data
	include "demosystem/jumpblocs.asm"
jumploc_data_length = $-jumpbloc_data


page0_length = $ - page0_start

	; Here include the whole demosystem
SELECTED_PAGE = 1
	bankset SELECTED_PAGE
page1_start equ 0xc000
	include "demosystem/demosystem.asm"
page1_length = $ - page1_start


	print "PAGE0: ", {hex}page0_length, " bytes from ", {hex}page0_start
	print "PAGE1: ", {hex}page1_length, " bytes from ", {hex}page1_start


	save "page0.o", page0_start, page0_length
	save "page1.o", page1_start, page1_length