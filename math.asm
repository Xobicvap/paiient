;###############################################################
; PAIIeNT!
; 2018 lilin (rhamilton828@gmail.com)
; Licensed under GPL
;
; math routines (currently just a division routine modified
; from what is shown at:
; http://forums.nesdev.com/viewtopic.php?f=2&t=11336  )
;
;###############################################################

.export DivideBy7WithRemainder
.export TimesTable7
.importzp Result
.importzp Remainder


;************************************************************
; DivideBy7WithRemainder
; (destroys A, X, Y)
;
;   quick and dirty division routine to get X position
;   and the pixel being affected
;************************************************************  

DivideBy7WithRemainder:
  tay
  sta Result
  lsr
  lsr
  lsr
  adc Result
  ror
  lsr
  lsr
  adc Result
  ror
  lsr
  lsr
  sta Result
  tax
  lda TimesTable7, x
  sta Remainder
  tya
  sec
  sbc Remainder
  tax
  sta Remainder
  rts

;************************************************************
; END DivideBy7WithRemainder
;************************************************************   


;************************************************************
; SafeSubtract
; (destroys A, X, Y)
;
;   subtraction without having to worry about negatives
;   
;************************************************************  

SafeSubtract:
  lda Subtrahend
  sec
  sbc Minuend
  bcs CarryS
  sta Subtrahend
  lda #$ff
  sec
  sbc Subtrahend
  tax
  inx
  txa
CarryS:
  rts

;************************************************************
; END DivideBy7WithRemainder
;************************************************************   
  
TimesTable7:
.byte  $00, $07, $0E, $15, $1C, $23, $2A, $31, $38, $3F
.byte  $46, $4D, $54, $5B, $62, $69, $70, $77, $7E, $85