;;
; RST routines that can be called by the parts
;
; - RST 0 / DS_WAIT_VSYNC (void) / demo_system_wait_vsync => wait vsync
; - RST 1 / DS_PLAY_MUSIC (void) / call demo_system_play_music => play music and handle frame counter. Of course player is unstable
; - RST 4 / DS_INSTALL_INTERRUPTED_MUSIC => install the interrupted player
;


	assert SELECTED_PAGE == 0
	

	print "====== JUMPBLOCS ======"

	; vsync wait
	rorg 0x0000
rst0
demo_system_wait_vsync
	ld b, 0xf5
.loop
	in a, (c)
	rra
	jr nc, .loop
	ret



	print 0x8 - $, " free bytes after RST 0"
	; play music manually and increase frame counter
	assert $ <= 0x0008

	; DS_PLAY_MUSIC (void)
	defs 0x0008-$
demo_system_play_music
rst1
	assert $ == 0x0008

	; handle frame counter
	; XXX to be removed if served for nothing. But can still be usefull for handling events in parts or demosystem
	; Duration should be a power of two to not be bohtered by overflow
	ld hl, 0
.frame_counter equ $ - 2
	assert DS_FRAME_COUNTER_ADDRESS == .frame_counter
	inc hl
	ld (.frame_counter), hl
	call demo_system_check_if_must_leave
	; select the appropriate bank
	; we assume the user has properly used the system and we'll go back to the approrpriate memory conf after
	__DS_SELECT_DS_MEMORY_CONF__ (void)

	; From now,  0xc000 contains the music and demosystem data
	; really play the music (first frame is derved to init the player)
	call  demo_system_private_init_player 	; really call the player
.music_routine equ $-2

.restore
demo_system_restore_bank
	; return to the appropriate memory configuration
	ld bc, 0x7f00 + 0xc0 ; TODO check if it is the right configuration
demo_system_selected_bank_true_value equ $-2
	assert demo_system_selected_bank_true_value == demo_system_selected_bank, "You need to manually modify demo_system_selected_bank in public_macros.asm to match demo_system_selected_bank_true_value"
	out (c), c

	ret


	print 0x20 - $, " free bytes after RST 1/2/3"

	assert $ <= 0x0020
	


	defs 0x0020 - $
	;;
	; Send a command to the demosystem
	; The command number multiplied by two is set up in register e
	; XXX it is not possbile to call demosystem_send_command recursively
rst4
demosystem_send_command
	assert $ == 0x0020

	__DS_BACKUP_MEMORY_CONF_SELECT_DS_MEMORY_CONF_AND_FIX_IT__ (void)
	call demo_system_handle_command
	jp restore_memory_conf

; Flag set to 0 when a part needs to leave (part installataion reset it to 1)
	assert demo_system_part_must_leave == $
	db 0

	print 0x38 - $, " free bytes after RST 4/5/6"

	assert $ <= 0x0038
	

	defs 0x0038 - $
rst7
demosystem_interruption_handling
	assert $ == 0x0038
	; by default, we do nothing BUT we have an extra jump in comparison to standard 
	; CPC routines by default
	; XXX if you want to remove this jump, backup it !
	jp demosystem_interrupted_code.leave_interrupted_code
.jump_address equ $ -2

/**
 * Original author: Longshot
 * Adapted (just some labels in fact) to better fir my coding practices
 * http://cpcrulez.free.fr/coding_logon36.htm
 *
 * TODO rewrite if we can earn some bytes
 *
 * This is the interrupted code that plays the music.
 * It is still possible to do more by patching .TABINT and adding dedicated code
 */
demosystem_interrupted_code
        PUSH AF              ; sauvegarde de quelques registrcs
        PUSH DE
        PUSH HL
        PUSH BC
        LD      HL,.COUNTI    ; compteur Inter
        LD      B ,0F5H         ; gestion periode compteur
        IN A,(C)
        RRA
        JR      NC, .NEXTI
        LD      (HL),0FFH       ; 1ere Inter
.NEXTI
        INC     (HL)            ; Num Inter+l (1/300 x 6)
		LD      A,0
.COUNTI equ $-1
        CP      6               ; verif pas de pb ( Cas
        JR      C, .OK          ; de CRTC bizarroides )
        XOR A
.OK
        SLA     A               ; x 2 + TabVectInt
        LD      C,A
        LD      B,0
        LD      HL,.TABINT
        ADD     HL,BC

        LD      A,(HL)          ; donne Ptr VeetNum
        INC     HL
        LD      H,(HL)
        LD      L,A
        LD      BC, .RETOUR       ; adresse retOUr
        PUSH    BC
        JP      (HL)            ; saut VectNum

		; TODO check if it is not better to duplicate that
.RETOUR
        POP BC
        POP HL
        POP DE
        POP AF
.leave_interrupted_code
        EI

		assert demo_system_address_of_a_ret == $, "Need to update public_macros.asm"
        RET

;;
; This table could be patched to play what the user wants
.TABINT  DW INT1
        DW INT2
        DW INT3
        DW INT4
        DW INT5
        DW INT6
        DW INT2 


/**
 * First interruption serves to play music.
 . Others (set by default) do nothing 
 */
INT1

    ; Save registers
    push ix, iy
    exx : push hl : push bc : push de : exx
    ex af,af' 
    push af
    ex af,af'

    DS_PLAY_MUSIC (void)

    ; Restore registers
    ex af, af' 
    pop af
    ex af, af'
    exx : pop de : pop bc : pop hl : exx
    pop iy, ix

INT2
INT3
INT4
INT5
INT6
    RET


restore_memory_conf
		ld a, 0xc0
.backup_memory_configuration equ $-1
	ld (demo_system_selected_bank_true_value),a 
	__DS_RESTORE_USER_MEMORY_CONF__ (void)
	ret

;;
; A part must leave when the allocated amount of time as span.
; This code seems over-complex, but its is supposed to properly handle overflow issue of the counter
demo_system_check_if_must_leave
	BREAKPOINT
	ld bc, (rst1.frame_counter)
	ld hl, 0xdead
.limit equ $-2
	or a
	sbc hl, bc
	ld a, h
	or l
	ret nz
	xor a : ld (demo_system_part_must_leave), a
	ret


STACK_SIZE equ 0x100-$

	print  "Jumplblocs use ", $, " bytes from 0x0000 to ", {hex4}($-1)
	print "WARNING - The memory stack is restricted to  ", {hex4}$,"-0x0100 area (", STACK_SIZE, " bytes). Use another one if it is not enough"

	if STACK_SIZE < 0x38
		print "WARNING - a stack size of ", STACK_SIZE, " is too small for targhan"
	endif
	if STACK_SIZE < 30
		print "WARNING - a stack size of ", STACK_SIZE, " is too small for roudoudou"
	endif
	rend



