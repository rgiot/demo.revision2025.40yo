
	;;
	; set bank 3 of page 1 at memory 0xc0000. The rest is untouched
	; Modified: bc
	macro __DS_SELECT_DS_MEMORY_CONF__
		ld bc, 0x7f00 + 0xc1
		out (c), c
	endm

	;; If an interruption occurs, it is necessary to come back to the demosystem memory configuration
	; Hence the selected demo configuration has to be saved and restore after handling the command
	macro __DS_BACKUP_MEMORY_CONF_SELECT_DS_MEMORY_CONF_AND_FIX_IT__
		__DS_SELECT_DS_MEMORY_CONF__ (void)
		ld a, (demo_system_selected_bank_true_value)
		ld (restore_memory_conf.backup_memory_configuration), a
		ld a, 0xc1
		ld (demo_system_selected_bank_true_value),a 
	endm

	;;
	; set memory as userexpects
	; (jump the the appropriate place in music play stuff)
	macro __DS_RESTORE_USER_MEMORY_CONF__
		jp rst1.restore
	endm