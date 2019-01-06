;###############################################################
; PAIIeNT!
; 2018 lilin (rhamilton828@gmail.com)
; Licensed under GPL
;
; fast-ish X/Y pos to VRAM address conversion
;
;###############################################################

.export ComputeXPosition
.export ComputeYPosition
.export ComputeVRAMAddress
.importzp PositionY
.importzp PositionX
.importzp Vram_Lo
.importzp Vram_Hi
.importzp PixelLoc
.importzp Result
.import LookupOffsetLo
.import LookupOffsetHi
.import DivideBy7WithRemainder

;************************************************************
; ComputeYPosition
;
; (destroys A,X,Y)
;  possibly faster, no divide version
;  idk if this should assume calling code will set Vram to
;  $2000 or if it should set it itself...  
;************************************************************  

ComputeYPosition:
  ldx #$02
  lda PositionY
  tay
  cmp #$80
  bpl GetOffsetLo
  dex
  cmp #$40
  bpl GetOffsetLo
  dex
GetOffsetLo:
  and #$08
  bne WithOffset
  lda #$00 ; necessary i guess to skip ahead?
  beq ComputeLoOffset
WithOffset:
  lda #$80
ComputeLoOffset:
  sta Vram_Lo
  lda LookupOffsetLo, x
  clc
  adc Vram_Lo
  sta Vram_Lo
  tya
  ldx #$00
  and #$3f
  cmp #$10
  bmi OffsetHiComp
  inx
  cmp #$20
  bmi OffsetHiComp
  inx
  cmp #$30
  bmi OffsetHiComp
  inx
OffsetHiComp:
  clc
  txa
  adc Vram_Hi
  sta Vram_Hi
  tya
  and #$07
  clc
  tax
  lda LookupOffsetHi,X
  adc Vram_Hi
  sta Vram_Hi
  rts
  
;************************************************************
; END ComputeYPosition
;************************************************************    

;************************************************************
; ComputeXPosition
;
; (destroys A,X,Y)
;  given position x, divide by 7 (subroutine provides remainder)
;  to get both the VRAM offset and the pixel within said offset
;************************************************************  
  
ComputeXPosition:
  lda PositionX
  jsr DivideBy7WithRemainder
  lda Result
  asl
  clc
  adc Vram_Lo
  sta Vram_Lo
  stx PixelLoc
  rts

;************************************************************
; END ComputeXPosition
;************************************************************    
  
  
;************************************************************
; ComputeVRAMAddress
;
; (destroys A, +X)
;   given a Y and X position (in that order), compute the
;   VRAM address of the pixel to write to
;************************************************************  
  
ComputeVRAMAddress:
  lda #$20
  sta Vram_Hi
  lda #$00
  sta Vram_Lo
  jsr ComputeYPosition
  jsr ComputeXPosition
  rts

;************************************************************
; END ComputeVRAMAddress
;************************************************************    