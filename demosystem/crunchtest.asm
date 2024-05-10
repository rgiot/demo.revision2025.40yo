;;
; 40 Years Amstrad CPC Mini Demo
; Krusty/Benediction
; April, May 2024



;max_available = 512


	include "demosystem/config.asm"

part1_start
	INCSHRINKLER "part1/part1.o"
part1_end equ $ -1
part1_size = part1_end - part1_start + 1


music_start
	LZSHRINKLER
			include "demosystem/music.asm"
	LZCLOSE
music_end equ $ -1
music_size = music_end - music_start + 1


demo_system_start
	LZSHRINKLER
		incbin "page0.o"
		incbin "page1_without_music_and_parts.o"
	LZCLOSE
demo_system_end equ $ -1
demo_system_size = demo_system_end - demo_system_start + 1


NB_BYTES = 0
USED_BYTES = 0

	MACRO CHECK part, max_available

		if {part}_size > {max_available}
			CODE = "[NOK]"
		else
			CODE = "[ OK]"
		endif

		print CODE, " {part} SIZE: ", {part}_size, " over ", {max_available}, " available => ", {max_available}-{part}_size, " bytes available for something else"

		USED_BYTES += {part}_size
		NB_BYTES += {max_available}
	ENDM


	MACRO CHECK_TOTAL
		if USED_BYTES > NB_BYTES
			CODE = "[NOK]"
		else
			CODE = "[ OK]"
		endif	

		print CODE, " TOTAL SIZE: ", USED_BYTES, " over ", NB_BYTES, " available => ", NB_BYTES-USED_BYTES, " bytes available for bootstrap loader"

	ENDM

	print "SIZE check with individual compression (figures will different in the whole system; especially because loader is missing as well as part table)"
	CHECK part1, 512
	CHECK music, 512 // say half of data is used by music
	CHECK demo_system, 512 // and other half by demosystem


	CHECK_TOTAL (void)