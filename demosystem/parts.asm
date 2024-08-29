;;
; 40 Years Amstrad CPC Mini Demo
; Krusty/Benediction
; May 2024

	
	include once "contract/part1.asm"
	include once "contract/part2.asm"
	include once "contract/fake3.asm"
	
	
	
	; Counter of number of parts. Is updated automatically
PARTS_COUNT = 0
PARTS_DATA  = []

	__DS_ADD_PART__ "part1/part1.o", PART1_LOADING_AREA, false
	__DS_ADD_PART__ "part2/part2.o", PART2_LOADING_AREA, false
	__DS_ADD_PART__ "fake3_orgams/albireo/EFFECT.BIN", FAKE3_LOADING_AREA, true

;	ADD_PART "part2/fake.bin", 0x2000

 	__DS__GENERATE_PARTS_DATA__ (void)
