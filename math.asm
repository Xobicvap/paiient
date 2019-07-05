;###############################################################
; PAIIeNT!
; 2018 lilin (rhamilton828@gmail.com)
; Licensed under GPL
;
; math routines (DivideBy7WithRemainder is modified
; from what is shown at:
; http://forums.nesdev.com/viewtopic.php?f=2&t=11336  )
;
;###############################################################

.export DivideBy7WithRemainder
.export TimesTable7
.export UnsignedComparison
.export DeltaCalculation
.export Add16Bit
.export Subtract16Bit
.export DoubleValue9Bit
.importzp Result
.importzp Remainder
.importzp Temp1
.importzp Temp2
.importzp Temp3
.importzp Word1
.importzp Word2

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
; DoubleValue9Bit 
; (destroys A,X)
;
;   9-bit doubling of value. It's only 9 bits because thus
;   far that's all I need (for computing 2dx or 2dy, which
;   can never be > (2 * 191)
;
;   Low byte in A
;   High byte in X (0 or 1)
;   calling code saves to desired location
;************************************************************   

DoubleValue9Bit:
  ldx #$00
  asl
  bcc EndDouble
  inx
EndDouble:
  rts

;************************************************************
; END 
;************************************************************   


;************************************************************
; Add16Bit
; (destroys A)
;
;   Self-explanatory; adds 2 16-bit numbers 
;************************************************************   

Add16Bit:
  lda Word1
  clc
  adc Word2
  sta Word1
  lda Word1+1
  adc Word2+1
  sta Word1+1
  rts

;************************************************************
; END Add16Bit 
;************************************************************   


;************************************************************
; Subtract16Bit 
; (destroys A)
;
;   Self-explanatory; subtracts Word2 from Word1
;************************************************************   

Subtract16Bit:
  lda Word1
  sec
  sbc Word2
  sta Word1
  lda Word1+1
  ; wait, do we need sec here? or is carry already set
  sbc Word2+1
  sta Word1+1
  rts

;************************************************************
; END Subtract16Bit
;************************************************************


;************************************************************
; Sign16Bit
; (destroys A)
;   
;    If the high byte of Word1 is negative, so is the number
;************************************************************   

Sign16Bit:
  lda Word1+1
  and #$80
  ; non-zero if high byte is negative
  rts

;************************************************************
; END Sign16Bit
;************************************************************


;************************************************************
; AbsoluteValueByte
; (destroys A)
;   
;    Gets the 2's complement of a negative number
;************************************************************   

AbsoluteValueByte:
  lda Temp1
  bpl HasAbsoluteValue
  lda #$00
  sec
  sbc Temp1
  clc
  adc #$01
HasAbsoluteValue:  
  rts

;************************************************************
; END AbsoluteValue Byte
;************************************************************


;************************************************************
; UnsignedComparison
; (destroys A)
;   
;    Store v1 in Temp1, v2 in Temp2
;    Result of CMP: if carry clear, v1 < v2
;                   if equals, v1 = v2
;                   if carry set, v1 > v2
;    Result in Temp3
;************************************************************

UnsignedComparison:
  lda Temp1
  cmp Temp2
  bcs V1_GTE
  ; v1 < v2, thus v2 - v1 will be positive
  lda #$01
  sta Temp3
  rts 
V1_GTE:
  beq V1_Equals_V2
V1_GT_V2:
  lda #$ff
  sta Temp3
  rts 
V1_Equals_V2:
  lda #$00
  sta Temp3
  rts 

;************************************************************
; END UnsignedComparison
;************************************************************


;************************************************************
; DeltaCalculation
; (destroys A, X)
;   
;    Store v1 in Temp1, v2 in Temp2
;    Result in A
;    Sign value in X
;************************************************************

DeltaCalculation:
  lda Temp2
  sec
  sbc Temp1
  tax
  jsr UnsignedComparison
  bmi ConvertNegativeDelta
ReturnDelta:
  ldx Temp3
  rts
ConvertNegativeDelta:
  txa
  jsr TwosComplement
  sec
  bcs ReturnDelta

;************************************************************
; END DeltaCalculation
;************************************************************


;************************************************************
; TwosComplement
; (destroys A)
;   
;    Gets two's complement of number
;    Use when given the two's complement from an 8-bit
;    subtraction to get (provided you know the sign via
;    UnsignedComparison) the real negative number
;
;    Before calling, set A to value to get complement of
;    A then holds the complement
;    
;************************************************************

TwosComplement:
  eor #$FF
  clc
  adc #$01
  rts

;************************************************************
; END TwosComplement
;************************************************************


TimesTable7:
.byte  $00, $07, $0E, $15, $1C, $23, $2A, $31, $38, $3F
.byte  $46, $4D, $54, $5B, $62, $69, $70, $77, $7E, $85
