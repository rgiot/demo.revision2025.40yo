 ; ;;
 ; ; 40 Years Amstrad CPC Mini Demo
 ; ; Krusty/Benediction
 ; ; May 2024
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

 ; ; Only serves to obtain a value for DS_DEFAULT_LOADING_AREA
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

 ; ;;
 ; ; Linker for a single part.
 ; ; No compression needed.
 ; ; Should be easily transfered to any assembler
	ORG &2000
	ENT $
 ; ;  ; BREAKPOINT
first_byte
 ; ;;
 ; ; Copy page 0 at the appropriate place
	ld hl,page0_start
	ld de,&8000
	ld bc,page0_length
	ldir
 ; ;;
 ; ; Copy page 1 at the appropriate place
	ld bc,&7fc7
	out (c),c
	ld hl,page1_start
	ld de,&4000
	ld bc,page1_length
	ldir
	ld bc,&7fc0
	out (c),c
 ; ; Starts the bootstrap procedure
	jp &8000
 ; ; Inject the demosystem that lies on 0x0000
page0_start
	LOAD "PAGE0.BIN"
page0_length EQU $-page0_start
 ; ; Inject the demosystem that lies in 0xc7
page1_start
	LOAD "PAGE1.BIN"
page1_without_parts_length EQU $-page1_start
page1_parts_table
 ; ; Add the missing table to properly lunch the part
	WORD part_location_in_demosystem_space
 ; ; The address of the part in the demoysystem space
	WORD part_length
	WORD FAKE3_LOADING_AREA
 ; ; installation address of the part
	WORD 0
 ; ; end of table
page1_part_location
	LOAD "EFFECT.BIN"
 ; ; ORGAMS header is not correct, we need to manually remove it
part_length EQU $-page1_part_location
part_location_in_demosystem_space EQU [[[[&c000+page1_without_parts_length]+2]+2]+2]+2
page1_length EQU $-page1_start
 ; ;  ; assert $<0x8000, "Bootstrap runs in 0x8000, write another linker then"
binary_length EQU $-first_byte
 ; ;save "FAKE3.BIN", first_byte, binary_length, AMSDOS
 ; ;  ; save "FAKE3.BIN", first_byte, binary_length, DSK, "test_fake3.dsk"
 ; ;  ; print "part_location_in_demosystem_space: ", {hex}part_location_in_demosystem_space
 ; ;  ; print "page1_part_location: ", {hex}page1_part_location
 ; ;  ; print "page1_without_parts_length: ", {hex}page1_without_parts_length
