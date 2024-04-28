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

	MACRO CHECK part, max_available

		if {part}_size > {max_available}
			CODE = "[NOK]"
		else
			CODE = "[ OK]"
		endif

		print CODE, " {part} SIZE: ", {part}_size, " / ", {max_available}-{part}_size, " bytes remaining"
	ENDM


	CHECK part1, 512
	CHECK music, 1024
