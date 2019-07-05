;###############################################################
; PAIIeNT!
; 2018 lilin (rhamilton828@gmail.com)
; Licensed under GPL
;
; math routines from the 6502org wiki
;
;###############################################################


.export Divide8Bit
.export Multiply16BitProduct
.import Dividend
.import Divisor
.import Multiplicand1
.import Multiplicand2
.import Product_Hi

;************************************************************
; Divide8Bit
;
; 8-bit division routine (destroys X, returns remainder as A)
;  monitor division routine at FB81 doesn't seem to work right;
;  use this one from the 6502org wiki
;************************************************************
  
Divide8Bit:
  lda #$00
  ldx #$08
  asl Dividend
L1:
  rol
  cmp Divisor
  bcc L2
  sbc Divisor
L2:
  rol Dividend
  dex
  bne L1
  rts
  
;************************************************************
; END Divide8Bit
;************************************************************  


;************************************************************
; Multiply16BitProduct
;
; multiply two 8-bit numbers to get a 16-bit product
; (destroys A,X; note that to save space, Multiplicand1 and
;  Product_Lo are the same)
;   another routine from 6502org wiki
;************************************************************

Multiply16BitProduct:
  lda #$00
  ldx #$08
  lsr Multiplicand1
Loop1:
  bcc Loop2
  clc
  adc Multiplicand2
Loop2:
  ror
  ror Multiplicand1
  dex
  bne Loop1
  sta Product_Hi
  rts

;************************************************************
; END Multiply16BitProduct
;************************************************************  