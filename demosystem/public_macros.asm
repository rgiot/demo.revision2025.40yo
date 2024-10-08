;;
; 40 Years Amstrad CPC Mini Demo
; Krusty/Benediction
; April, May 2024
; August 2024: minor rewrite to ease orgams conversion


ORGAMS_TEST=0

DS_DEFAULT_LOADING_AREA equ 0x1000

DS_FRAME_COUNTER_ADDRESS equ 0x0008+1
DS_SELECTED_BANK_ADDRESS equ 0xdead

DS_COMMAND_INSTALL_INTERRUPTED_MUSIC equ 0 
DS_COMMAND_STOP_INTERRUPTED_MUSIC equ 1
DS_COMMAND_LAUNCH_NEXT_PART equ 2

; TODO automatize the update of this vklue
demo_system_selected_bank equ 0x1b 	; XXX manually setup the right value as soon as it changes
demo_system_address_of_a_ret equ 0x6a 	; XXX manually setup the right value as soon as it changes
demo_system_part_must_leave equ 0x36 ; XXX manually setup the right value as soon as it changes

demo_system_selected_crtc equ 0x37

	;;
	; We wil lbuild one version of the demo per CRTC.
	; This allows to get ride of CRTC tests and multiple code.
	; hoewever if a particpant wants to provide a single binary, this macro set the forced CRTC in register A
	macro DS_GET_FORCED_CRTC
		ld a, (demo_system_selected_crtc)
	endm


	;;
	; Each part has to leave after a given amount of frames has pass.
	; set Z if the participant must leave its part
	macro DS_CHECK_IF_MUST_LEAVE
		ld a, (demo_system_part_must_leave)
		or a
	endm

	;;
	; Launch a slow command in the demo system
	; Modified: possibly everything
	macro DS_LAUNCH_COMMAND cmd
		ld e, {cmd}*2
		rst 4
	endm


	;;
	; Wait the vsync signal
	; Modified: A, B
	macro DS_WAIT_VSYNC
		rst 0
	endm

	;;
	; Play the music
	; Modified: everything
	macro DS_PLAY_MUSIC
		rst 1
	endm

	;;
	; Install the player under interruption
	; Modified: everything
	macro DS_INSTALL_INTERRUPTED_MUSIC
		DS_LAUNCH_COMMAND(DS_COMMAND_INSTALL_INTERRUPTED_MUSIC)
	endm


	macro DS_STOP_INTERRUPTED_MUSIC
		DS_LAUNCH_COMMAND(DS_COMMAND_STOP_INTERRUPTED_MUSIC)
	endm

	;;
	; Give the control to the demo system to launch the next part
	; Here we do not do rst 4 but jump.
	; The demosystem will put the part address on the stack
	macro DS_LAUNCH_NEXT_PART
		ld e, 2*DS_COMMAND_LAUNCH_NEXT_PART
		jp 0x0020 ; demosystem_send_command
	endm

	;;
	; Store in HL the number of spend frames since beginning
	; Modified: HL
	macro DS_GET_FRAME_COUNTER_IN_HL
		ld hl, (DS_FRAME_COUNTER_ADDRESS)
	endm


	;;
	; Specify a selected bank to come back after playing the music
	; Input: A the bank of interest
	; Modified: B
	macro DS_SELECT_BANK_FROM_A
		print  "Be sure DS_SELECT_BANK_FROM_A is executed with current bank IS NOT C4"
		ld (demo_system_selected_bank), a ; TODO hardcode the address for the others
		ld b, 0x7f : out (c), a
	endm


	;;
	; Modifed: A, B
	macro DS_SELECT_BANK gabank
		ld A, {gabank}
		DS_SELECT_BANK_FROM_A (void)
	endm


	;;
	; Check, with orgams if there are error while assembling
	; If there is no failure there is still no gurantee that the generate code is ok...
	if ORGAMS_TEST
	  DS_SELECT_BANK(&c4)
	  DS_GET_FRAME_COUNTER_IN_HL()
	  DS_LAUNCH_NEXT_PART()
	  DS_STOP_INTERRUPTED_MUSIC()
	  DS_INSTALL_INTERRUPTED_MUSIC()
	  DS_PLAY_MUSIC()
	  DS_WAIT_VSYNC()
	  DS_CHECK_IF_MUST_LEAVE()
	  DS_GET_FORCED_CRTC()
	endif