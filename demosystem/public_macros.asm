DS_FRAME_COUNTER_ADDRESS equ 0x0008+1
DS_SELECTED_BANK_ADDRESS equ 0xdead

DS_COMMAND_INSTALL_INTERRUPTED_MUSIC equ 0 
DS_COMMAND_STOP_INTERRUPTED_MUSIC equ 1
DS_COMMAND_LAUNCH_NEXT_PART equ 2

; TODO automatize the update of this vklue
demo_system_selected_bank equ 0x18 ; XXX manually setup the right value as soon as it changes

	;;
	; Launch a slow command in the demo system
	; Modified: everything
	macro DS_LAUNCH_COMMAND cmd
		ld a, {cmd}
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
		DS_LAUNCH_COMMAND DS_COMMAND_INSTALL_INTERRUPTED_MUSIC
	endm


	macro DS_STOP_INTERRUPTED_MUSIC
		DS_LAUNCH_COMMAND DS_COMMAND_STOP_INTERRUPTED_MUSIC
	endm

	macro DS_LAUNCH_NEXT_PART
		DS_LAUNCH_COMMAND DS_COMMAND_LAUNCH_NEXT_PART
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
	; Modified B
	macro DS_SELECT_BANK_FROM_A
		print  "Be sure DS_SELECT_BANK_FROM_A is executed with current bank IS NOT C4"
		ld b, 0x7f : out (c), a
		ld (demo_system_selected_bank), a ; TODO hardcode the address for the others
	endm


	macro DS_SELECT_BANK bank
		ld a, {bank}
		DS_SELECT_BANK_FROM_A (void)
	endm