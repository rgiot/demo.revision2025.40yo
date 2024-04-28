;; 
; The maximum number of frames allocated to a demo
; Duration and unit subject to change
NB_FRAMES_BEFORE_LEAVING equ 50*5 ; 50*20



;;
; List of the possible players
MUSIC_PLAYER set 0
MUSIC_PLAYER_AKM next MUSIC_PLAYER
MUSIC_PLAYER_CHP next MUSIC_PLAYER


;;
; List of possible CRTCs
FORCED_CRTC set 0
FORCED_CRTC_0 next FORCED_CRTC
FORCED_CRTC_1 next FORCED_CRTC
FORCED_CRTC_2 next FORCED_CRTC
FORCED_CRTC_3 next FORCED_CRTC
FORCED_CRTC_4 next FORCED_CRTC


;;
; The player really used
SELECTED_MUSIC_PLAYER equ MUSIC_PLAYER_CHP

;;
; The demo is build for a given CRTC
; This allows to get ride of CRTC test
SELECTED_CRTC equ FORCED_CRTC_0
