;###############################################################
; PAIIeNT!
; 2018 lilin (rhamilton828@gmail.com)
; Licensed under GPL
;
; main program
;
;###############################################################

.import GRAPHICS_ON
.import HIRES_FULLSCREEN
.import HIRES_ON
.import HIRES_PAGE1
.import KEYBOARD_STROBE
.import ClearTextArea
.import ComputeVRAMAddress
.import WritePixelValue
.import ReadKeyboard
.import MenuHandler
.import BlinkCursorOn
.import BlinkCursorOff
.import Delay
.importzp CENTER_X
.importzp PositionX
.importzp CENTER_Y
.importzp PositionY
.importzp CurrentColor
.importzp ColorPending
.importzp KeyboardValue



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;************************************************************
; startup and main loop
;************************************************************

.SEGMENT "CODE"
.ORG $0900
Startup:
  lda GRAPHICS_ON
  lda HIRES_FULLSCREEN
  lda HIRES_ON
  lda HIRES_PAGE1
  
  jsr ClearTextArea
  
  lda #CENTER_X
  sta PositionX
  lda #CENTER_Y
  sta PositionY
  jsr ComputeVRAMAddress
  lda #$03
  sta CurrentColor
  sta ColorPending
  jsr WritePixelValue
RunLoop:
  jsr ReadKeyboard
  jsr MenuHandler
ClearKBStrobeIfHit:  
; was there a keyboard hit that was processed?  
  lda KeyboardValue
  and #$80
  beq NoKBHit
  jsr Delay
  sta KEYBOARD_STROBE
NoKBHit:
  jsr BlinkCursorOff
  jsr Delay
  jsr BlinkCursorOn
  jmp RunLoop
  rts

;************************************************************
; END main loop
;************************************************************