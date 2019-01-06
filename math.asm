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
  
  
TimesTable7:
.byte  $00, $07, $0E, $15, $1C, $23, $2A, $31, $38, $3F
.byte  $46, $4D, $54, $5B, $62, $69, $70, $77, $7E, $85