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

	defs 0x0008-$
demo_system_play_music
rst1
	assert $ == 0x0008

	; handle frame counter
	; XXX to be removed if served for nothing. But can still be usefull for handling events in parts or demosystem
	ld hl, 0
.frame_counter equ $ - 2
	assert DS_FRAME_COUNTER_ADDRESS == .frame_counter
	inc hl
	ld (.frame_counter), hl
	
	; select the appropriate bank
	__DS_SELECT_DS_MEMORY_CONF__ (void)

	; really play the music
	call  0xdead 	; really call the player

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
rst4
demosystem_send_command
	assert $ == 0x0020

	__DS_SELECT_DS_MEMORY_CONF__ (void)
	call demo_system_handle_command
	__DS_RESTORE_USER_MEMORY_CONF__ (void)

	print 0x30 - $, " free bytes after RST 4/5"

	assert $ <= 0x0030
	

	defs 0x0030 - $
rst6
	assert $ == 0x0030

	assert $ <= 0x0038
	print 0x38 - $, " free bytes after RST 6"

	defs 0x0038 - $
rst7
	assert $ == 0x0038

	ei
	ret

	print  "Jumplblocs use ", $, " bytes"
	print "WARNING - The memory stack is restricted to  ", {hex4}$,"-0x0100 area. Use another one if it is not enough"
	rend



