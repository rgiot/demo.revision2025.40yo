;;
; Example of simple part that relies on the demo system and it s automatic music play
; No init are used for this part
;
; Of course parts can be written with any assembler as soon as the API contracts are respected.
; I'm pretty sure my files are rasm compatible


	include "kit/public_macros.asm"
	include "contract/part1.asm"

	org PART1_LOADING_AREA

;;
; Each part must start with these 3 jump blocks
; So systematically 6 bytes that compress badly are lost
; In case no init is used, set the address to demo_system_address_of_a_ret
part1
	dw init_assets_with_firmware  ; System has not been killed yet, it is then possible to use it to build/compute stuff
	               				 ; this is called one time just after deo launched
	dw init_assets_without_firmware ; Some other init may prfere a killed system.
	                                ; it is better to lost 3 bytes rather than plenty more by saving firmware state
	dw play_part ;

;;
; First stage init.
; Print a string using the firmware
init_assets_with_firmware
	ld hl, .txt
.loop
		ld a, (hl) : inc hl
		or a : ret z
		call 0xbb5a
		jr .loop
.txt db 12, 10, 10, 10, 10, 10, 10, 10, 10, 10, "Part 1 uses firmware in first init stage, then clears some screen area in second stage. It's effect only consists in writting random bytes in the first 256 bytes of screen. Music is played under interruption by the system."
   db 10, 13
	db 0

;; 
; Second stage init.
; Clear some bytes on screen
init_assets_without_firmware
	ld hl, 0xc000 + 80 * 5
	ld de, 0xc000 + 80 * 5 + 1
	ld bc, 256
	ld (hl), 255
	ldir
	ret



;;
; A fake part that write random things on memory screen
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

	; Only a limit amount of  frames is allowed (init included)
	; so we loop only if the system gives the authorization
	DS_CHECK_IF_MUST_LEAVE (void)
	jp nz, .frame_loop

.leave
	; cleanup the mess
	ld hl, 0xc000
	ld de, 0xc000 + 1
	ld bc, 256
	ld (hl), l
	ldir

	if 0

		; lost lots of time to see the screen cleanup
		ld b, 50*3
	.slow_down
			push bc
				DS_WAIT_VSYNC (void)
				halt
				halt
			pop bc
		djnz .slow_down
	endif
	

	; music is already under interruption, so there is no need to activate it again
	DS_LAUNCH_NEXT_PART (void)
