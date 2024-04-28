	switch SELECTED_MUSIC_PLAYER
		case MUSIC_PLAYER_AKM

				include "music/Lookool_playerconfig.asm"
			music_player
				include "music/Lookool.asm"
			music
				include "music/PlayerAkm_basm.asm"
			music_end

				print "Music from ", {hex4}music_player, " to ", {hex4}(music_end-1)
				break

		case MUSIC_PLAYER_CHP
			writepsg ; A=BYTE,C=REG.; -
				push bc
				ld b,$F4
				out (c),c
				ld bc,$F6C0;SELECT
				out (c),c
				dw $71ED;CPC PLUS!
				ld b,$F4
				out (c),a
				ld bc,$F680;UPDATE
				out (c),c
				dw $71ED;CPC PLUS!
				pop bc
				ret

			CHIPNSFX_FLAG = 0 + 4 + 256 + 512
			chipnsfx
				include "music/chipnsfx.z80"
			music
				include "music/4k08_final_tj.asm"
			chip_song_a = song_a
			chip_song_b = song_b
			chip_song_c = song_c
				break
			
		default 
			fail "player unhandled"
	endswitch