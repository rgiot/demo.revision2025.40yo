;;
; 40 Years Amstrad CPC Mini Demo
; Krusty/Benediction
; April, May 2024


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



	;;
	; Register a new part in the demosystem
	macro __DS_ADD_PART__ fname, address
		PARTS_COUNT += 1
		PARTS_DATA = list_push(PARTS_DATA, [{fname}, {address}])

	endm



	macro __DS__GENERATE_PARTS_DATA__



		; Manually add the parts here. As we copy them in memory each time, we can launch them several times
		print "====== PARTS ======"
		; Automatically create the information to launch them
data_table
		repeat PARTS_COUNT, part_nb ; XXX first loop starts with part_nb = 1 as with rasm XXX I am not sure to keep this beahavior in basm
			dw part{{part_nb}}_before_binary		; Address of the part
			dw part{{part_nb}}_binary_length		; Length of the part
			dw part{{part_nb}}_destination			; destination of the part
		endr
		dw 0

data_parts
		repeat PARTS_COUNT, part_nb ; XXX first loop starts with part_nb = 1 as with rasm XXX I am not sure to keep this beahavior in basm

CURRENT_PART_DATA = list_get(PARTS_DATA, {part_nb}-1)
CURRENT_PART_FNAME = list_get(CURRENT_PART_DATA, 0)
CURRENT_PART_ADDRESS = list_get(CURRENT_PART_DATA, 1)

part{{part_nb}}_destination = CURRENT_PART_ADDRESS
part{{part_nb}}_before_binary = $
		db load(CURRENT_PART_FNAME)
part{{part_nb}}_after_binary = $ 
part{{part_nb}}_binary_length = part{{part_nb}}_after_binary - part{{part_nb}}_before_binary



		print "Add part ", {part_nb}, ": ", \
			{hex}part{{part_nb}}_before_binary, \
			":", \
			{hex}(part{{part_nb}}_after_binary-1)


		endr

	endm