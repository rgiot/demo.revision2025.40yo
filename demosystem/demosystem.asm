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

	include once "demosystem/config.asm"
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
	; WARNING this is not compatible with the firmware
	; TODO use this very same code for the 3 steps
	; - init with firmware (interruptions are cut, ix/iy saved)
	; - init after firmware (interruption are cut, we don't care of ix/iy)
	; - demo play (the current version)
demo_system_private_launch_next_part
	ld ix, data.table
.table_pointer equ $-2
.read_values
	ld l, (ix + 0)
	ld h, (ix + 1)
	ld a, h : or l
	jr nz, .go_on
	ld ix, data.table
	jr .read_values
.go_on
	
	ld e, (ix + 4)
	ld d, (ix + 5)

	push de


	ld c, (ix + 2)
	ld b, (ix + 3)

	; HL = Address of the part in C1 memory space
	; BC = Number of bytes to copy
	; DE = Address of the part in 0x100-0xbfff
	ldir

	; compute the address of the demo
	pop hl
	inc hl : inc hl : inc hl : inc hl ; move at the appropriate location
	ld e, (hl) : inc hl : ld d, (hl)

	; setup properly the stack to finish the execution of the DS routines and call the demo
	pop bc 		; remove the return of call demo_system_handle_command
	push de    	; store the demo address
	push bc 	; restore the return of the call
	ret ; continue the execution; the appropriate demo will be launched
;;
; Probably bet to do it after cutting the interruptions
demo_system_private_init_player
	switch SELECTED_MUSIC_PLAYER
	case MUSIC_PLAYER_AKM
		; XXX Do not play song properly for an unknown reason
		; XXX BUT do not care now as this player will not be used
		ld hl, PLY_AKM_Play : ld (rst1.music_routine), hl
		ld hl, music : xor a
		jp PLY_AKM_Init
		break
	case MUSIC_PLAYER_CHP
		; XXX properly works with warhawack now
		; XXX but not at all with square roots music
		; TODO remove this uneeded indirection
		jp chip_play
		break
	default
		fail "Player unhandled: ", SELECTED_MUSIC_PLAYER
	endswitch


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

	ADD_PART "part1/part1.o", PART1_LOADING_AREA
;	ADD_PART "part2/fake.bin", 0x2000

	; Automatically create the information to launch them
.table
	repeat PARTS_COUNT, part_nb ; XXX first loop starts with part_nb = 1 as with rasm XXX I am not sure to keep this beahavior in basm
		dw part{{part_nb}}_before_binary		; Address of the part
		dw part{{part_nb}}_binary_length		; Length of the part
		dw part{{part_nb}}_destination			; destination of the part
	endr
	dw 0


	print "====== MUSIC ======"
 

	switch SELECTED_MUSIC_PLAYER
		case MUSIC_PLAYER_AKM

				include "music/Lookool_playerconfig.asm"
			music_player
				include "music/Lookool.asm"
			music
				include "music/PlayerAkm_basm.asm"
			music_end

				print "Music from ", {hex4}music_player, " to ", {hex4}(music_end-1)
				break

		case MUSIC_PLAYER_CHP
			writepsg ; A=BYTE,C=REG.; -
				push bc
				ld b,$F4
				out (c),c
				ld bc,$F6C0;SELECT
				out (c),c
				dw $71ED;CPC PLUS!
				ld b,$F4
				out (c),a
				ld bc,$F680;UPDATE
				out (c),c
				dw $71ED;CPC PLUS!
				pop bc
				ret

			CHIPNSFX_FLAG = 0 + 4 + 256
			chipnsfx
				include "music/chipnsfx.z80"
			music
				include "music/WARHAWK.asm"
			chip_song_a = song_a
			chip_song_b = song_b
			chip_song_c = song_c
				break
			
		default 
			fail "player unhandled"
	endswitch

	print "Demosystem stops at ", {hex4}$