
	;;
	; set bank 3 of page 1 at memory 0xc0000. The rest is untouched
	; Modified: bc
	macro __DS_SELECT_DS_MEMORY_CONF__
		ld bc, 0x7f00 + 0xc3 ; TODO check if it is the right configuration
		out (c), c
	endm

	;;
	; set memory as userexpects
	; (jump the the appropriate place in music play stuff)
	macro __DS_RESTORE_USER_MEMORY_CONF__
		jp rst1.restore
	endm