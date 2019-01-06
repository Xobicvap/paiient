;###############################################################
; PAIIeNT!
; 2018 lilin (rhamilton828@gmail.com)
; Licensed under GPL
;
; utility subroutines
;
;###############################################################

.export Delay
.export ReadKeyboard
.import KEYBOARD_READ
.importzp KeyboardValue

;************************************************************
; Delay
; 
; delay routine (destroys Y)
;   this seems to give a reasonable delay when moving etc
;************************************************************
  
Delay:
  ldy #$7f
DelayLoop:
  dey
  bne DelayLoop
  rts

;************************************************************
; END Delay
;************************************************************
  



;************************************************************
; ReadKeyboard
;
; (destroys A)
;   reads the keyboard read register to see if bit 7 is set; 
;   if so, handle whatever key was pressed, if a known input.
;************************************************************  

ReadKeyboard:
  lda KEYBOARD_READ
  sta KeyboardValue
  and #$80
  rts

;************************************************************
; END ReadKeyboard
;************************************************************  