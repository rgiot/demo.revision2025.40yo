;;
; How lucky we are, Krusty offered us this memory space.
; We can use it right from init and reuse it eache time the part is restarted
PART1_AVAILABLE_MEMORY_SPACE_FIRST_BYTE equ 0x4000
PART1_AVAILABLE_MEMORY_SPACE_SIZE equ 0x1000
PART1_AVAILABLE_MEMORY_SPACE_LAST_BYTE equ PART1_AVAILABLE_MEMORY_SPACE_FIRST_BYTE - PART1_AVAILABLE_MEMORY_SPACE_SIZE - 1
PART1_DATA_BANK = 0xc5

;;
; Loading area
; XXX no idea yet if we have to force it
PART1_LOADING_AREA equ 0x100
