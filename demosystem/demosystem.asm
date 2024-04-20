;;
; The demo system AS WELL as the UNCRUNCHED part
; will stick in one bank (at list I hope as it seem to be often the case).
; If not, we'll see how to fix that.
;
; Bank is C7 and code will be compiled to run at 0xc000. 
; This will allow to copy paste the parts in any place elsewhere
;
; We assume stack will be elsewhere  bankset 0
;
;
; We assume the following memory configuration
; 0x0000  0x4000  0x8000  0xc000
;   P0B0    P0B1    P0B2    P0B3     / normal configuration
;   P0B0    P0B1    P0B2    P1B3     / demo system configuration 


	assert SELECTED_PAGE == 1


	include once "contract/part1.asm"


; Counter of number of parts. Is updated automatically
PARTS_COUNT = 0

	;;
	; Add a part in the demosystem
	; 1. create the appropriate labels
	; 2. include the binary file
	macro ADD_PART fname, address
		PARTS_COUNT += 1

part{PARTS_COUNT}_destination = {address}
part{PARTS_COUNT}_before_binary = $
		incbin {fname}
part{PARTS_COUNT}_after_binary = $ 
part{PARTS_COUNT}_binary_length = part{PARTS_COUNT}_after_binary - part{PARTS_COUNT}_before_binary


		print "Add part ", PARTS_COUNT, ": ", \
			{hex}part{PARTS_COUNT}_before_binary, \
			":", \
			{hex}(part{PARTS_COUNT}_after_binary-1)
	endm

	
	org 0xc000

;;
; RST 4 has been used to send a command (whose value is multiplied by two) in register E
demo_system_handle_command
	ld d, 0 ; Now de contains the position within the command table
	ld hl, .command_table
	add hl, de
	ld e, (hl)
	if .command_table % 2 == 0
		inc l
	else
		print "demo_system_handle_command.command_table could be better aligned to use inc l instead of inc hl "
		inc hl
	endif
	ld d, (hl)
	ex de, hl
	jp hl ; Yeah, it is not not jp (hl) :()
.command_table
	dw demo_system_private_start_music_under_interruption ; DS_COMMAND_INSTALL_INTERRUPTED_MUSIC
	dw demo_system_private_stop_music_under_interruption ; DS_COMMAND_STOP_INTERRUPTED_MUSIC
	dw demo_system_private_launch_next_part ; DS_COMMAND_LAUNCH_NEXT_PART

	; prequisit stack is properly handled TODO
demo_system_private_launch_next_part
	call 0xdead


;;
; Probably bet to do it after cutting the interruptions
demo_system_private_init_player
	ld hl, PLY_AKM_Play : ld (rst1.music_routine), hl
	ld hl, music : xor a
	jp PLY_AKM_Init


;;
; The music was played manually.
; Now the user expects to automatically play it under interruption.
demo_system_private_start_music_under_interruption
	; Wait next vsync and play the music
	DS_WAIT_VSYNC (void)
	di
	DS_PLAY_MUSIC (void)
	ei : nop
	repeat 5
		halt
	endr
	
	; Install the proper handler for interrupted code
	; Assume demosystem_interrupted_code.TABINT has never been altered
    xor a : ld (demosystem_interrupted_code.COUNTI), a
	ld hl, demosystem_interrupted_code
	ld (demosystem_interruption_handling.jump_address), hl
    ret

;;
; The music was played under interruption.
; Now the user expects to manually play it
demo_system_private_stop_music_under_interruption
	ld hl, demosystem_interrupted_code.leave_interrupted_code
	ld (demosystem_interruption_handling.jump_address), hl
	ret





data

	; Manually add the parts here. As we copy them in memory each time, we can launch them several times
.parts
	print "====== PARTS ======"

	ADD_PART "part1/part1.o", 0x4000
	ADD_PART "part2/fake.bin", 0x2000

	; Automatically create the information to launch them
.table
	repeat PARTS_COUNT, part_nb ; XXX first loop starts with part_nb = 1 as with rasm XXX I am not sure to keep this beahavior in basm
		dw part{{part_nb}}_before_binary		; Address of the part
		dw part{{part_nb}}_binary_length		; Length of the part
		dw part{{part_nb}}_destination			; destination of the part
	endr
	dw 0


	print "====== MUSIC ======"
 
	include "music/Lookool_playerconfig.asm"
music_player
	include "music/Lookool.asm"
music
	include "music/PlayerAkm_basm.asm"
music_end

	print "Music from ", {hex4}music_player, " to ", {hex4}(music_end-1)

	print "Demosystem stops at ", {hex4}$