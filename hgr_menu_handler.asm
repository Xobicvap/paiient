;###############################################################
; PAIIeNT!
; 2018 lilin (rhamilton828@gmail.com)
; Licensed under GPL
;
; menu handler for drawing / changing colors
;
;###############################################################

.export MenuHandler
.import ComputeVRAMAddress
.import WritePixelValue
.import GRAPHICS_OFF
.import GRAPHICS_ON
.import KEYBOARD_STROBE
.import ColorMessageLine1
.import ColorMessageLine2
.import ColorPrompt
.import Delay
.import WriteLine
.import WritePrompt
.import HandleColorMenu
.import ReadKeyboard
.import DetermineTextAreaAddr
.importzp KeyboardValue
.importzp PositionX
.importzp PositionY
.importzp LineNumber
.importzp TextPtr_Lo
.importzp TextPtr_Hi

;************************************************************
; MoveMenuHandler
;
; (destroys A,X)
;   handles keyboard input. handler branches to subroutines
;   for easier... well, handling.
;
;   words start getting really difficult once you're doing 6502
;   for most of a night ^_^
;************************************************************  
  
MenuHandler:
  bne DoMenuHandle
  rts
DoMenuHandle:  
  lda KeyboardValue
  and #$7f
  cmp #$49  ; 'I' = move up
  bne IsLeft
  jmp MoveUp
IsLeft:
  cmp #$4A  ; 'J' = move left
  bne IsRight
  jmp MoveLeft
IsRight:  
  cmp #$4B  ; 'K' = move right
  bne IsDown
  jmp MoveRight
IsDown:  
  cmp #$4D  ; 'M' = move down
  bne IsColorChange
  jmp MoveDown
IsColorChange:
  cmp #$43
  bne InputOver
  jmp DisplayColorChangePrompt
InputOver:
  rts

;************************************************************
; END MenuHandler
;************************************************************


;************************************************************
; MoveUp
; (destroys A, X, Y)
;
;************************************************************  
  
MoveUp:
  ldx PositionY
; don't allow move past y position 0  
  beq EndMoveUp
  dex
  stx PositionY  
  jsr ComputeVRAMAddress
  jsr WritePixelValue
EndMoveUp:  
  rts

;************************************************************
; END MoveUp
;************************************************************


;************************************************************
; MoveDown
; (destroys A, X, Y)
;
;************************************************************  
  
MoveDown:
  ldx PositionY
  inx
  cpx #$C0
  beq EndMoveDown
  stx PositionY  
  jsr ComputeVRAMAddress
  jsr WritePixelValue
EndMoveDown:
  rts

;************************************************************
; END MoveDown
;************************************************************


;************************************************************
; MoveLeft
; (destroys A, X, Y)
;
;************************************************************  
  
MoveLeft:  
  ldx PositionX
  beq EndMoveLeft
  dex
  stx PositionX  
  jsr ComputeVRAMAddress
  jsr WritePixelValue
EndMoveLeft:
  rts

;************************************************************
; END MoveUp
;************************************************************


;************************************************************
; MoveRight
; (destroys A, X, Y)
;
;************************************************************

MoveRight:
  ldx PositionX
  inx 
  cpx #$8C
  beq EndMoveRight
  stx PositionX  
  jsr ComputeVRAMAddress
  jsr WritePixelValue
EndMoveRight:
  rts
  
;************************************************************
; END MoveUp
;************************************************************


;************************************************************
; DisplayColorChangePrompt
; (destroys A, X, Y)
;
;************************************************************

DisplayColorChangePrompt:
  lda GRAPHICS_OFF
; write first line of message  
  lda #$00
  sta LineNumber
  jsr DetermineTextAreaAddr
  lda #<ColorMessageLine1
  sta TextPtr_Lo
  lda #>ColorMessageLine1
  sta TextPtr_Hi
  jsr WriteLine

; next line of message  
  lda #$01
  sta LineNumber
  jsr DetermineTextAreaAddr
  lda #<ColorMessageLine2
  sta TextPtr_Lo
  lda #>ColorMessageLine2
  sta TextPtr_Hi
  jsr WriteLine  
  
; write prompt  
  lda #$02
  sta LineNumber
  jsr DetermineTextAreaAddr
  lda #<ColorPrompt
  sta TextPtr_Lo
  lda #>ColorPrompt
  sta TextPtr_Hi
  jsr WriteLine
  jsr WritePrompt
ColorPromptLoop:
  sta KEYBOARD_STROBE
  jsr Delay
  jsr ReadKeyboard
  jsr HandleColorMenu
  lda KeyboardValue
  and #$80
  beq ColorPromptLoop
  sta KEYBOARD_STROBE
  lda GRAPHICS_ON
  rts

;************************************************************
; END DisplayColorChangePrompt
;************************************************************