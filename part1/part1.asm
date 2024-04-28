;;
; Example of simple part that relies on the demo system and it s automatic music play
; No init are used for this part
;
; Of course parts can be written with any assembler as soon as the API contracts are respected.
; I'm pretty sure my files are rasm compatible


	include "contract/part1.asm"
	include "demosystem/public_macros.asm"

	org PART1_LOADING_AREA

;;
; Each part must start with these 3 jump blocks
; So systematically 6 bytes that compress badly are lost
part1
	dw init_assets_with_firmware  ; System has not been killed yet, it is then possible to use it to build/compute stuff
	               				 ; this is called one time just after deo launched
	dw demo_system_address_of_a_ret ; Some other init may prfere a killed system.
	                                ; it is better to lost 3 bytes rather than plenty more by saving firmware state
	dw play_part ;

;;
; First stage init.
init_assets_with_firmware
	ld hl, .txt
.loop
		ld a, (hl) : inc hl
		or a : ret z
		call 0xbb5a
		jr .loop
.txt db "Frimware init of part 1", 0


play_part
	; todo register a gunction to leave properly

	; just a garbage effect to verify we loop and play the music
	ld hl, 0xc000
.frame_loop

	ld b, 50
.code_loop
		ld a, r
		ld (hl), a
		inc l
	djnz .code_loop

	DS_CHECK_IF_MUST_LEAVE (void)
	jp nz, .frame_loop

.leave
	; cleanup the mess
	ld hl, 0xc000
	ld de, 0xc000 + 1
	ld bc, 256
	ld (hl), l
	ldir


	; lost lots of time to see the screen cleanup
	ld b, 50*3
.slow_down
		push bc
			DS_WAIT_VSYNC (void)
			halt
			halt
		pop bc
	djnz .slow_down

	; music is already under interruption, so there is no need to activate it again
	DS_LAUNCH_NEXT_PART (void)
