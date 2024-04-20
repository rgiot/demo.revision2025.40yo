	assert SELECTED_PAGE == 0

	; TODO do the init related to the firmware code called by each part
	; Find a way to do it using few memory space (jumpblocs are not yet installed at that moment)


	; install the stack in 0x100 space and the jump blocs in 0x0000
	; firmware cannot be used anymore
	assert $>=0x100
	di
		BREAKPOINT
		; set up stack
		ld sp, 0x100

		; set up jumpblocks
		ld hl, jumpbloc_data
		ld de, 0x0000
		ld bc, jumploc_data_length
		ldir

		; TODO do the init that is not related to the firwmare code

		; Install the music under interruption.
		; Each part starts with the music played under interruption
		;BREAKPOINT
		;DS_INSTALL_INTERRUPTED_MUSIC (void)

	ei


	;;
	; Here we try to manually play the music
	; init is automatically called at the first play
.loop
	DS_WAIT_VSYNC (void)
	di
	DS_PLAY_MUSIC (void)
	ei : nop

	halt : halt
	

	jr .loop


	;jp $ ; we expect to hear the music indefinitvely


	; TODO launch the first part. That will itself launch the next one and so on
	; so all the memory used by the demo init can be freed without any issue

;;
; the code that needs to copy pasted in 0x0000-0x0100 memory zone
jumpbloc_data
	include "demosystem/jumpblocs.asm"
jumploc_data_length = $-jumpbloc_data