;;
; How lucky we are, Krusty offered us this memory space.
; We can use it right from init and reuse it eache time the part is restarted
FAKE3_AVAILABLE_MEMORY_SPACE_FIRST_BYTE equ 0x5000
FAKE3_AVAILABLE_MEMORY_SPACE_SIZE equ 0x1000
FAKE3_AVAILABLE_MEMORY_SPACE_LAST_BYTE equ FAKE3_AVAILABLE_MEMORY_SPACE_FIRST_BYTE - FAKE3_AVAILABLE_MEMORY_SPACE_SIZE - 1
FAKE3_DATA_BANK = 0xc6

;;
; Loading area
; XXX no idea yet if we have to force it
FAKE3_LOADING_AREA equ DS_DEFAULT_LOADING_AREA
