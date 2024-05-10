
	include "../kit/public_macros.asm" ; Only serves to obtain a value for DS_DEFAULT_LOADING_AREA
	include "../contract/part1.asm"

	;;
	; Linker for a single part.
	; No compression needed.
	; Should be easily transfered to any assembler
	org 0x2000

	run $

first_byte

	;;
	; Copy page 0 at the appropriate place
	ld hl, page0_start
	ld de, 0x8000
	ld bc, page0_length
	ldir

	;;
	; Copy page 1 at the appropriate place
	ld bc, 0x7fc7 : out (c), c
	ld hl, page1_start
	ld de, 0x4000
	ld bc, page1_length
	ldir
	ld bc, 0x7fc0 : out (c), c

	; Starts the bootstrap procedure
	jp 0x8000





		; Inject the demosystem that lies on 0x0000
page0_start
		incbin "../kit/page0.o"
page0_length equ $-page0_start

		; Inject the demosystem that lies in 0xc7
page1_start
		incbin "../kit/page1_without_parts.o"
page1_without_parts_length equ $ - page1_start
page1_parts_table
		; Add the missing table to properly lunch the part
		dw part_location_in_demosystem_space ; The address of the part in the demoysystem space
		dw part_length
		dw PART1_LOADING_AREA ; installation address of the part
		dw 0 ; end of table
page1_part_location
		incbin "part1.o"

part_length equ $-page1_part_location
part_location_in_demosystem_space equ 0xc000 + page1_without_parts_length  + 2 + 2 + 2 + 2
page1_length equ $-page1_start


	assert $<0x8000, "Bootstrap runs in 0x8000, write another linker then"

binary_length equ $-first_byte

	save "TEST.BIN", first_byte, binary_length, AMSDOS
	save "TEST.BIN", first_byte, binary_length, DSK, "test_part1.dsk"



	print "part_location_in_demosystem_space: ", {hex}part_location_in_demosystem_space
	print "page1_part_location: ", {hex}page1_part_location
	print "page1_without_parts_length: ", {hex}page1_without_parts_length