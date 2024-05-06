	assert SELECTED_PAGE == 0

	; TODO do the init related to the firmware code called by each part
	; Find a way to do it using few memory space (jumpblocs are not yet installed at that moment)


	; install the stack in 0x100 space and the jump blocs in 0x0000
	; firmware cannot be used anymore
	assert $>=0x100

	assert $ == 0x8000, "You need to modify linker.asm then"


	; Init the parts that requires some firmware stuff
	; XXX here it is quite problematic because we cannot use the demosystem to handle everything. So the code of the part on the code of the init must cohabit.
	; No idea how to handle that properly 
	;   - force parts to not use a specific place ?
	;   - force firmware init code to be executed at a specific address ?
	;In the current version we load the linker in 0x8000, so the part cannot use this area during this specific init
	; we need to cut interruptions while copying the part data in memory
	repeat PARTS_COUNT
		; copy the part in memory and get its address
		di
			ld bc, 0x7f00 + 0xc1 : out (c), c
			call demo_system_private_launch_next_part.copy_next_part_in_memory
			ld hl, (demo_system_private_launch_next_part.part_loaded_at)
			ld bc, 0x7f00 + 0xc0 : out (c), c
		ei

		; retreive the address of the firmware init stuff
		; add 0 to hl
		ld e, (hl) : inc hl : ld d, (hl)
		ld (@address_to_call), de

		; and call it
		call 0xdead
@address_to_call equ $-2
	endr ; praise the cruncher

	di
		; set up stack
		ld sp, 0x100

		; set up the jumpblocks
		ld hl, jumpbloc_data
		ld de, 0x0000
		ld bc, jumploc_data_length
		ldir

	ei
	

	;  Do the inits that are not related to the firwmare code
	repeat PARTS_COUNT
		; copy the part in memory and get its address
		di
			ld bc, 0x7f00 + 0xc1 : out (c), c
			call demo_system_private_launch_next_part.copy_next_part_in_memory
			ld hl, (demo_system_private_launch_next_part.part_loaded_at)
			ld bc, 0x7f00 + 0xc0 : out (c), c
		ei

		; retreive the address of the firmware init stuff
		ld de, 2*1 : add hl, de
		ld e, (hl) : inc hl : ld d, (hl)
		ld (@address_to_call2), de

		; and call it
		call 0xdead
@address_to_call2 equ $-2
	endr ; praise the cruncher


	;; TODO try various writting of these to earn plenty of bytes. loop instead of duplications ? more code from the demosystem ?


	di
		; Install the music under interruption.
		; Each part starts with the music played under interruption
		DS_INSTALL_INTERRUPTED_MUSIC (void)
	ei

	DS_LAUNCH_NEXT_PART (void) ; Jump to the demo loader
	                           ; During the first round, it will do the second kind of init
							   ; Then it will do the real demo stuff


;;
; the code that needs to copy pasted in 0x0000-0x0100 memory zone
jumpbloc_data
	include "demosystem/jumpblocs.asm"
jumploc_data_length = $-jumpbloc_data