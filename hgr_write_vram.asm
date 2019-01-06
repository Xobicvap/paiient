;###############################################################
; PAIIeNT!
; 2018 lilin (rhamilton828@gmail.com)
; Licensed under GPL
;
; HGR VRAM drawing routines
;
;###############################################################

.export WritePixelValue
.export BlinkCursorOn
.export BlinkCursorOff
.import ComputeVramAddress
.importzp VramWork
.importzp CurrentColor
.importzp BackupColor
.importzp ColorWorkValue
.importzp PixelLoc
.importzp VramOffset
.importzp VramWork
.importzp Vram_Lo
.importzp ColorPending

;************************************************************
; WritePixelValue
;
; (destroys A,X,Y)
;
; A is pixel location (0, 1, 10, 100, 101, 110)
; vram offset = A >>, A >> (i.e. if 100, offset is 1, aka high byte)
; if pixel loc (from Y reg) & 11 is non-zero, shift color left X times,
; where X = pixel loc (01 or 10 after above)
; this gives the value to set. for example:
; color = 10, pixel = 101:
;   101 & 11 = 1; x = 1, for x > 0; x--: asl *2
;   thus 10 << << = 1000
; "but wait!" you say. "that's wrong for pixel 5, which is in the high byte!"
; you're right! so, A = vram offset, if non-zero (1), shift left one more time
;
; now we calculate the bit mask so that we preserve everything at this vram byte
; except the two bits we are going to overwrite
; the bit mask is 11 shifted left once for every pixel (like above; 0 is no shift,
; 1 is 1 shift, etc..) plus once more if we're in the high byte
; then we apply the bit mask to the vram byte via an &, | that value with the
; color work value, then write it to vram
;************************************************************  

WritePixelValue:
  lda #$00
  sta VramWork
  lda CurrentColor
  and #$7f
  sta ColorWorkValue
  jsr ResetPaletteBit
  lda PixelLoc
  tay
  cmp #$03
  bne SinglePixelByteWrite
  jmp DoPixel3
  
SinglePixelByteWrite:
  lsr
  lsr
  sta VramOffset
  tya
  and #$03
  beq WorkValueOffset
  tax
  sta VramWork
  lda ColorWorkValue  
DoColorWorkValueCalc:
  asl
  asl
  dex
  bne DoColorWorkValueCalc
  sta ColorWorkValue
WorkValueOffset:
  lda VramOffset
  beq BitMaskCalcSetup
  lda ColorWorkValue
  asl
  sta ColorWorkValue
BitMaskCalcSetup:
  lda #$03
  ldx VramWork
  beq BitMaskCalc
BitMaskShift:
  asl
  asl
  dex
  bne BitMaskShift
BitMaskCalc:
  eor #$ff
  ldy VramOffset
  beq ApplyBitMask
  sec
  rol
ApplyBitMask:
  and (Vram_Lo), y
  ora ColorWorkValue
  sta (Vram_Lo), y
  rts
  
;************************************************************
; END WritePixelValue
;************************************************************  


;************************************************************
; DoPixel3
;
;
;************************************************************  

DoPixel3:
  lda #$fe
  ldy #$01
  and (Vram_Lo), y
  sta VramWork
  lda ColorWorkValue
  clc
  ror
  ora VramWork
  sta (Vram_Lo), y
  dey
  tya
  ror
  lsr
  sta VramWork
  lda #$bf
  and (Vram_Lo), y
  ora VramWork
  sta (Vram_Lo), y
  rts

;************************************************************
; END DoPixel3
;************************************************************  


;************************************************************
; ResetPaletteBit
; (destroys A, Y)
;
; Set the high bit of both bytes of the current blop to 
; that of the new color, and register the new color as the
; current color.
;************************************************************  

ResetPaletteBit:
  lda ColorPending
  sta CurrentColor
  and #$80
  sta VramWork
  ldy #$01
ResetPaletteBitLoop:
  lda (Vram_Lo), y
  and #$7f
  ora VramWork
  sta (Vram_Lo), y
  dey
  bpl ResetPaletteBitLoop
EndPaletteBitChange:
  rts
  

;************************************************************
; END ResetPaletteBit
;************************************************************


;************************************************************
; BlinkCursorOn
; 
;************************************************************  

BlinkCursorOn:
  lda BackupColor
  sta CurrentColor
  jsr WritePixelValue
  rts
  
;************************************************************
; END BlinkCursorOn
;************************************************************  


;************************************************************
; BlinkCursorOff
; 
;************************************************************  

BlinkCursorOff:
  lda CurrentColor
  sta BackupColor
  beq BlackToWhite
  cmp #$80
  beq BlackToWhite
  
  and #$80
  ora #$00
DoColorWrite:  
  sta CurrentColor
  jsr WritePixelValue
  rts
BlackToWhite:
  and #$80
  ora #$03
  bne DoColorWrite
  
;************************************************************
; END BlinkCursorOff
;************************************************************  