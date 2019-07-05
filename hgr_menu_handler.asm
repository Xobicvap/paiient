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
.import DrawLine
.importzp KeyboardValue
.importzp PositionX
.importzp PositionY
.importzp LineEndX
.importzp LineEndY
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
  bne IsDrawLine
  jmp DisplayColorChangePrompt
IsDrawLine:
  cmp #$4C
  bne InputOver
  jmp DrawLineHandler
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


;************************************************************
; DrawLineHandler
;
;   handles... drawing lines!
;************************************************************
DrawLineHandler:
  lda PositionX
  sta LineEndX
  lda PositionY
  sta LineEndY
DoLineMenuHandle: 
  jsr ReadKeyboard
; was there a keyboard hit that was processed?  
  lda KeyboardValue
  and #$80
  beq NoKBHit
  jsr Delay
  sta KEYBOARD_STROBE
  lda KeyboardValue
  and #$7f
  cmp #$49  ; 'I' = move up
  bne IsLineLeft
  jmp MoveLineUp
IsLineLeft:
  cmp #$4A  ; 'J' = move left
  bne IsLineRight
  jmp MoveLineLeft
IsLineRight:  
  cmp #$4B  ; 'K' = move right
  bne IsLineDown
  jmp MoveLineRight
IsLineDown:  
  cmp #$4D  ; 'M' = move down
  bne IsLineEnd
  jmp MoveLineDown
IsLineEnd:
  cmp #$45  ; 'E' = line stop
  beq EndLine
; ugh! this won't work... we need to detect what colors are underneath where the
; line is being drawn!
;  lda CurrentColor
;  sta BackupColor
;  bne NotBlack
;  lda #$00
NoKBHit:
  jmp DoLineMenuHandle
EndLine:
  rts

MoveLineUp:
  ldx LineEndY
  beq NoMoveUp
  dex
  stx LineEndY
  jsr DrawLine
NoMoveUp:
  jmp DoLineMenuHandle

MoveLineLeft:
  ldx LineEndX
  beq NoMoveLeft
  dex
  stx LineEndX
  jsr DrawLine
NoMoveLeft:
  jmp DoLineMenuHandle

MoveLineDown:
  ldx LineEndY
  cpx #$BF
  beq NoMoveDown
  inx
  stx LineEndY
  jsr DrawLine
NoMoveDown:
  jmp DoLineMenuHandle

MoveLineRight:
  ldx LineEndX
  cpx #$8B
  beq NoMoveRight
  inx
  stx LineEndX
  jsr DrawLine
NoMoveRight:
  jmp DoLineMenuHandle
