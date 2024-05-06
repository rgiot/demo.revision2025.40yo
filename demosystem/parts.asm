
	include once "contract/part1.asm"
	include once "contract/part2.asm"
	
	
	
	; Counter of number of parts. Is updated automatically
PARTS_COUNT = 0
PARTS_DATA  = []

	__DS_ADD_PART__ "part1/part1.o", PART1_LOADING_AREA
	__DS_ADD_PART__ "part2/part2.o", PART2_LOADING_AREA

;	ADD_PART "part2/fake.bin", 0x2000

 	__DS__GENERATE_PARTS_DATA__ (void)
