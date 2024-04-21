;;
; This part has not reserved any memory in the banks.
; So the following labels are not needed
; How lucky are the others
;PART1_AVAILABLE_MEMORY_SPACE_FIRST_BYTE equ 0x4000
;PART1_AVAILABLE_MEMORY_SPACE_SIZE equ 0x1000
;PART1_AVAILABLE_MEMORY_SPACE_LAST_BYTE equ PART1_AVAILABLE_MEMORY_SPACE_FIRST_BYTE - PART1_AVAILABLE_MEMORY_SPACE_SIZE - 1
;PART1_DATA_BANK = 0xc5

;;
; Loading area
; XXX no idea yet if we have to force it TODO need to discuss with the other about that
PART1_LOADING_AREA equ 0x100
