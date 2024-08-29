 ; ;;
 ; ; 40 Years Amstrad CPC Mini Demo
 ; ; Krusty/Benediction
 ; ; April, May, August 2024
 ; ;;
 ; ; Example of part that 
 ; ; - does some inits
 ; ; - manually plays the music
 ; ; - make use of the data space in the banks
 ; ;
 ; ; Of course parts can be written with any assembler as soon as the API contracts are respected.
 ; ; I'm pretty sure my files are rasm compatible
 ; START Included from ../kit/public_macros.asm
 ; ;;
 ; ; 40 Years Amstrad CPC Mini Demo
 ; ; Krusty/Benediction
 ; ; April, May 2024
 ; ; August 2024: minor rewrite to ease orgams conversion
ORGAMS_TEST=0
DS_DEFAULT_LOADING_AREA EQU &1000
DS_FRAME_COUNTER_ADDRESS EQU &0008+1
DS_SELECTED_BANK_ADDRESS EQU &dead
DS_COMMAND_INSTALL_INTERRUPTED_MUSIC EQU 0
DS_COMMAND_STOP_INTERRUPTED_MUSIC EQU 1
DS_COMMAND_LAUNCH_NEXT_PART EQU 2
 ; ; TODO automatize the update of this vklue
demo_system_selected_bank EQU &1b
 ; ; XXX manually setup the right value as soon as it changes
demo_system_address_of_a_ret EQU &6a
 ; ; XXX manually setup the right value as soon as it changes
demo_system_part_must_leave EQU &36
 ; ; XXX manually setup the right value as soon as it changes
demo_system_selected_crtc EQU &37
 ; ;;
 ; ; We wil lbuild one version of the demo per CRTC.
 ; ; This allows to get ride of CRTC tests and multiple code.
 ; ; hoewever if a particpant wants to provide a single binary, this macro set the forced CRTC in register A
	MACRO DS_GET_FORCED_CRTC 
	ld a,(demo_system_selected_crtc)
	ENDM
 ; ;;
 ; ; Each part has to leave after a given amount of frames has pass.
 ; ; set Z if the participant must leave its part
	MACRO DS_CHECK_IF_MUST_LEAVE 
	ld a,(demo_system_part_must_leave)
	or a
	ENDM
 ; ;;
 ; ; Launch a slow command in the demo system
 ; ; Modified: possibly everything
	MACRO DS_LAUNCH_COMMAND cmd
	ld e,cmd*2
	rst 4
	ENDM
 ; ;;
 ; ; Wait the vsync signal
 ; ; Modified: A, B
	MACRO DS_WAIT_VSYNC 
	rst 0
	ENDM
 ; ;;
 ; ; Play the music
 ; ; Modified: everything
	MACRO DS_PLAY_MUSIC 
	rst 1
	ENDM
 ; ;;
 ; ; Install the player under interruption
 ; ; Modified: everything
	MACRO DS_INSTALL_INTERRUPTED_MUSIC 
	DS_LAUNCH_COMMAND(DS_COMMAND_INSTALL_INTERRUPTED_MUSIC)
	ENDM
	MACRO DS_STOP_INTERRUPTED_MUSIC 
	DS_LAUNCH_COMMAND(DS_COMMAND_STOP_INTERRUPTED_MUSIC)
	ENDM
 ; ;;
 ; ; Give the control to the demo system to launch the next part
 ; ; Here we do not do rst 4 but jump.
 ; ; The demosystem will put the part address on the stack
	MACRO DS_LAUNCH_NEXT_PART 
	ld e,2*DS_COMMAND_LAUNCH_NEXT_PART
	jp &0020
 ; ; demosystem_send_command
	ENDM
 ; ;;
 ; ; Store in HL the number of spend frames since beginning
 ; ; Modified: HL
	MACRO DS_GET_FRAME_COUNTER_IN_HL 
	ld hl,(DS_FRAME_COUNTER_ADDRESS)
	ENDM
 ; ;;
 ; ; Specify a selected bank to come back after playing the music
 ; ; Input: A the bank of interest
 ; ; Modified: B
	MACRO DS_SELECT_BANK_FROM_A 
 ; ;  ; print  "Be sure DS_SELECT_BANK_FROM_A is executed with current bank IS NOT C4"
	ld (demo_system_selected_bank),a
 ; ; TODO hardcode the address for the others
	ld b,&7f
	out (c),a
	ENDM
 ; ;;
 ; ; Modifed: A, B
	MACRO DS_SELECT_BANK gabank
	ld a,gabank
	DS_SELECT_BANK_FROM_A()
	ENDM
 ; ;;
 ; ; Check, with orgams if there are error while assembling
 ; ; If there is no failure there is still no gurantee that the generate code is ok...
	IF ORGAMS_TEST
	DS_SELECT_BANK(196)
	DS_GET_FRAME_COUNTER_IN_HL()
	DS_LAUNCH_NEXT_PART()
	DS_STOP_INTERRUPTED_MUSIC()
	DS_INSTALL_INTERRUPTED_MUSIC()
	DS_PLAY_MUSIC()
	DS_WAIT_VSYNC()
	DS_CHECK_IF_MUST_LEAVE()
	DS_GET_FORCED_CRTC()

	END


 ; STOP Included from ../kit/public_macros.asm

 ; START Included from ../contract/fake3.asm
 ; ;;
 ; ; How lucky we are, Krusty offered us this memory space.
 ; ; We can use it right from init and reuse it eache time the part is restarted
FAKE3_AVAILABLE_MEMORY_SPACE_FIRST_BYTE EQU &5000
FAKE3_AVAILABLE_MEMORY_SPACE_SIZE EQU &1000
FAKE3_AVAILABLE_MEMORY_SPACE_LAST_BYTE EQU [FAKE3_AVAILABLE_MEMORY_SPACE_FIRST_BYTE-FAKE3_AVAILABLE_MEMORY_SPACE_SIZE]-1
FAKE3_DATA_BANK=&c6
 ; ;;
 ; ; Loading area
 ; ; XXX no idea yet if we have to force it
FAKE3_LOADING_AREA EQU DS_DEFAULT_LOADING_AREA

 ; STOP Included from ../contract/fake3.asm

	ORG FAKE3_LOADING_AREA
FOREVER_VARIABLE_SPACE EQU FAKE3_AVAILABLE_MEMORY_SPACE_FIRST_BYTE
VARIABLE1_RELATIVE_POSITION EQU 0
 ; ; a word that change over time
VARIABLE2_RELATIVE_POSITION EQU 2
 ; ; a byte to chose the palette
 ; ;;
 ; ; Each part must start with these 3 jump blocks
 ; ; So systematically 6 bytes that compress badly are lost
part2
	WORD init_assets_with_firmware
 ; ; System has not been killed yet, it is then possible to use it to build/compute stuff
 ; ; this is called one time just after deo launched
	WORD init_assets_without_firmware
 ; ; Some other init may prfere a killed system.
 ; ; it is better to lost 3 bytes rather than plenty more by saving firmware state
	WORD play_part
 ; ;
 ; ;;
 ; ; the part uses the firmware for some init stuff
init_assets_with_firmware
 ; ; some fake data storage to test memory access
	ld bc,&7f00+FAKE3_DATA_BANK
	out (c),c
	ld hl,&dead
	ld ([FOREVER_VARIABLE_SPACE+VARIABLE1_RELATIVE_POSITION]+0),hl
	ld bc,&7f00+&c0
	out (c),c
	ld hl,.msg
.loop
	ld a,(hl)
	or a
	ret z
	inc hl
	call &bb5a
	jr .loop
.msg
	BYTE 10,"PART3 is as FAKE3 BUT written in ORGAMS !!",0
 ; ;;
 ; ; This init is done when firmware is not used
init_assets_without_firmware
 ; ;  ; assert $<0x4000
 ; ; Some fake data storage to replace the previous one
	ld bc,&7f00+FAKE3_DATA_BANK
	out (c),c
	ld hl,&beef
	ld ([FOREVER_VARIABLE_SPACE+VARIABLE1_RELATIVE_POSITION]+0),hl
	ld bc,&7f00+&c0
	out (c),c
	xor a
	ld (FOREVER_VARIABLE_SPACE+VARIABLE2_RELATIVE_POSITION),a
 ; ;  ; assert $<0x4000
	ret
play_part
.init
 ; ; play with the data stored
	DS_SELECT_BANK(FAKE3_DATA_BANK)
	ld hl,([FOREVER_VARIABLE_SPACE+VARIABLE1_RELATIVE_POSITION]+0)
	inc (hl)
	ld hl,([FOREVER_VARIABLE_SPACE+VARIABLE1_RELATIVE_POSITION]+1)
	dec (hl)
 ; ; deactivate screen display
	ld bc,&bc00+1
	out (c),c
	ld bc,&bd00+0
	out (c),c
	DS_SELECT_BANK(FAKE3_DATA_BANK)
	ld a,([FOREVER_VARIABLE_SPACE+VARIABLE2_RELATIVE_POSITION]+0)
	inc a
	and 3
	ld ([FOREVER_VARIABLE_SPACE+VARIABLE2_RELATIVE_POSITION]+0),a
	DS_SELECT_BANK(&c0)
	DS_STOP_INTERRUPTED_MUSIC()
 ; ; we play the music a bit later than the vsync.
 ; ; lets hope this 1/2 hlts of difference do not impact the sound experience
.frame_loop
	DS_WAIT_VSYNC()
 ; ; Get the persistent data
	DS_SELECT_BANK(FAKE3_DATA_BANK)
	ld a,([FOREVER_VARIABLE_SPACE+VARIABLE2_RELATIVE_POSITION]+0)
	push af
	DS_SELECT_BANK(&c0)
	pop af
 ; ; Select the color according to it
	ld d,0
	ld e,a
	ld hl,.raster_table
	add hl,de
	ld a,(hl)
 ; ; play the music using a different color
	halt
	halt
	ld bc,&7f10
	out (c),c
	out (c),a
	DS_PLAY_MUSIC()
	ld bc,&7f10
	out (c),c
	ld bc,&7f40
	out (c),c
	halt
	ld bc,&7f4b
	out (c),c
 ; ; Only a limit amount of  frames is allowed (init included)
 ; ; so we loop only if the system gives the authorization
	DS_CHECK_IF_MUST_LEAVE()
	jp nz,.frame_loop
.leave
 ; ; reactivate screen display
	ld bc,&bc00+1
	out (c),c
	ld bc,&bd00+[80/2]
	out (c),c
	DS_INSTALL_INTERRUPTED_MUSIC()
	DS_LAUNCH_NEXT_PART()
.raster_table
	BYTE &4b,&44,&45,&44
 ; ;  ; assert $< 0x4000
