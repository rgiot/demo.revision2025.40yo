;;
; Example of part that 
; - does some inits
; - manually plays the music
; - make use of the data space in the banks
;
; Of course parts can be written with any assembler as soon as the API contracts are respected.
; I'm pretty sure my files are rasm compatible


	include "contract/part1.asm"
	include "demosystem/public_macros.asm"

FOREVER_VARIABLE_SPACE equ PART2_AVAILABLE_MEMORY_SPACE_SIZE
VARIABLE1_RELATIVE_POSITION equ 0 ; 

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

	ld hl, 0xbeef
	ld (FOREVER_VARIABLE_SPACE + VARIABLE1_RELATIVE_POSITION + 0), hl

	ld bc, 0x7f00 + 0xc0 : 	out (c), c

	ld hl, .msg
.loop
	ld a, (hl) : or a : ret z
	inc hl
	call 0xbb5a
	jr .loop
.msg db "Part 1 uses system there", 0

;;
; This init is done when firmware is not used
init_assets_without_firmware
	assert $<0x4000

	; Some fake data storage to replace the previous one
	ld bc, 0x7f00 + PART2_DATA_BANK : out (c), c
	ld hl, 0xbeef
	ld (FOREVER_VARIABLE_SPACE + VARIABLE1_RELATIVE_POSITION + 0), hl
	ld bc, 0x7f00 + 0xc0 : out (c), c

	assert $<0x4000
	ret

play_part
.init
	; play with the data stored
	DS_SELECT_BANK PART2_DATA_BANK
	ld hl, (FOREVER_VARIABLE_SPACE + VARIABLE1_RELATIVE_POSITION + 0)
	inc (hl)

	ld hl, (FOREVER_VARIABLE_SPACE + VARIABLE1_RELATIVE_POSITION + 0)
	dec (hl)

	DS_SELECT_BANK 0xc0
	DS_STOP_INTERRUPTED_MUSIC (void)


.frame_loop
	DS_WAIT_VSYNC (void)
	DS_PLAY_MUSIC (void)


	jp .frame_loop

.leave
	DS_INSTALL_INTERRUPTED_MUSIC (void)
	DS_LAUNCH_NEXT_PART (void)
