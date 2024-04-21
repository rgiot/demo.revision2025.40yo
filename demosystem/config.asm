;; 
; The maximum number of frames allocated to a demo
; Duration and unit subject to change
NB_FRAMES_BEFORE_LEAVING equ 50*20


;;
; List of the possible players
MUSIC_PLAYER set 0
MUSIC_PLAYER_AKM next MUSIC_PLAYER
MUSIC_PLAYER_CHP next MUSIC_PLAYER


;;
; The player really used
SELECTED_MUSIC_PLAYER equ MUSIC_PLAYER_CHP