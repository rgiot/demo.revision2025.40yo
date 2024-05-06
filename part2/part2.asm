;;
; Example of part that 
; - does some inits
; - manually plays the music
; - make use of the data space in the banks
;
; Of course parts can be written with any assembler as soon as the API contracts are respected.
; I'm pretty sure my files are rasm compatible


	include "demosystem/public_macros.asm"
	include "contract/part2.asm"


	org PART2_LOADING_AREA

FOREVER_VARIABLE_SPACE equ PART2_AVAILABLE_MEMORY_SPACE_SIZE
VARIABLE1_RELATIVE_POSITION equ 0 ; a word that change over time
VARIABLE2_RELATIVE_POSITION equ 2 ; a byte to chose the palette

;;
; Each part must start with these 3 jump blocks
; So systematically 6 bytes that compress badly are lost
part2
	dw init_assets_with_firmware ; System has not been killed yet, it is then possible to use it to build/compute stuff
	               				 ; this is called one time just after deo launched
	dw init_assets_without_firmware ; Some other init may prfere a killed system.
	                                ; it is better to lost 3 bytes rather than plenty more by saving firmware state
	dw play_part ;

;;
; the part uses the firmware for some init stuff
init_assets_with_firmware
	; some fake data storage to test memory access
	ld bc, 0x7f00 + PART2_DATA_BANK : out (c), c

	ld hl, 0xdead
	ld (FOREVER_VARIABLE_SPACE + VARIABLE1_RELATIVE_POSITION + 0), hl

	ld bc, 0x7f00 + 0xc0 : 	out (c), c

	ld hl, .msg
.loop
	ld a, (hl) : or a : ret z
	inc hl
	call 0xbb5a
	jr .loop
.msg db 10, "Part 2 uses system and write 0xbeef in its dedicatd space during init 1, then 0xbeef in init 2. The effect continuously change these values one time per call. Music is manually played and its duration is shown. Persistent memory is used to cont the number of runs and select the palette", 0

;;
; This init is done when firmware is not used
init_assets_without_firmware
	assert $<0x4000

	; Some fake data storage to replace the previous one
	ld bc, 0x7f00 + PART2_DATA_BANK : out (c), c
	ld hl, 0xbeef
	ld (FOREVER_VARIABLE_SPACE + VARIABLE1_RELATIVE_POSITION + 0), hl
	ld bc, 0x7f00 + 0xc0 : out (c), c


	xor a
	ld (FOREVER_VARIABLE_SPACE + VARIABLE2_RELATIVE_POSITION ), a

	assert $<0x4000
	ret

play_part
.init
	; play with the data stored
	DS_SELECT_BANK PART2_DATA_BANK
	ld hl, (FOREVER_VARIABLE_SPACE + VARIABLE1_RELATIVE_POSITION + 0)
	inc (hl)

	ld hl, (FOREVER_VARIABLE_SPACE + VARIABLE1_RELATIVE_POSITION + 1)
	dec (hl)


	; deactivate screen display
	ld bc, 0xbc00  + 1 : out (c), c
	ld bc, 0xbd00  + 0 : out (c), c

	DS_SELECT_BANK PART2_DATA_BANK
		ld a, (FOREVER_VARIABLE_SPACE + VARIABLE2_RELATIVE_POSITION + 0)
		inc a : and %11
		ld (FOREVER_VARIABLE_SPACE + VARIABLE2_RELATIVE_POSITION+0 ), a
	DS_SELECT_BANK 0xc0

	DS_STOP_INTERRUPTED_MUSIC (void)


; we play the music a bit later than the vsync.
	; lets hope this 1/2 hlts of difference do not impact the sound experience
.frame_loop
	DS_WAIT_VSYNC (void)

	; Get the persistent data
	DS_SELECT_BANK PART2_DATA_BANK
		ld a, (FOREVER_VARIABLE_SPACE + VARIABLE2_RELATIVE_POSITION+0)
		push af
	DS_SELECT_BANK 0xc0
	pop af
	
	
	; Select the color according to it
	ld d, 0 : ld e, a
	ld hl, .raster_table
	add hl, de
	ld a, (hl)

	; play the music using a different color
	halt : halt
	ld bc, 0x7f10 : out (c), c
	out (c), a
		DS_PLAY_MUSIC (void)
	ld bc, 0x7f10 : out (c), c
	ld bc, 0x7f40 : out (c), c
	halt
	ld bc, 0x7f54 : out (c), c


	; Only a limit amount of  frames is allowed (init included)
	; so we loop only if the system gives the authorization
	DS_CHECK_IF_MUST_LEAVE (void)
	jp nz, .frame_loop

.leave

	; reactivate screen display
	ld bc, 0xbc00  + 1 : out (c), c
	ld bc, 0xbd00  + 80/2 : out (c), c
	

	DS_INSTALL_INTERRUPTED_MUSIC (void)
	DS_LAUNCH_NEXT_PART (void)


.raster_table
	db 0x4b, 0x44, 0x45, 0x44
	assert $< 0x4000
