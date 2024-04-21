	assert SELECTED_PAGE == 0

	; TODO do the init related to the firmware code called by each part
	; Find a way to do it using few memory space (jumpblocs are not yet installed at that moment)


	; install the stack in 0x100 space and the jump blocs in 0x0000
	; firmware cannot be used anymore
	assert $>=0x100
	di
		; set up stack
		ld sp, 0x100

		; set up the jumpblocks
		ld hl, jumpbloc_data
		ld de, 0x0000
		ld bc, jumploc_data_length
		ldir

		; TODO do the inits that are not related to the firwmare code

		; Install the music under interruption.
		; Each part starts with the music played under interruption
		DS_INSTALL_INTERRUPTED_MUSIC (void)
	ei

	DS_LAUNCH_NEXT_PART (void) ; Jump to the demo loader


;;
; the code that needs to copy pasted in 0x0000-0x0100 memory zone
jumpbloc_data
	include "demosystem/jumpblocs.asm"
jumploc_data_length = $-jumpbloc_data