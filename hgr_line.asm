;###############################################################
; PAIIeNT!
; 2018 lilin (rhamilton828@gmail.com)
; Licensed under GPL
;
; bresenham's line drawing algorithm for HGR
;
;###############################################################

.import WritePixelValue
.import ComputeVRAMAddress
.import Add16Bit
.import Subtract16Bit
.import Sign16Bit
.import DoubleValue9Bit
.import DeltaCalculation
.export DrawLine
.importzp IncVal
.importzp BackupX
.importzp BackupY
.importzp PositionY
.importzp PositionX
.importzp LineEndX
.importzp LineEndY
.importzp Word1
.importzp DeltaX
.importzp DeltaY
.importzp DeltaX2
.importzp DeltaY2
.importzp Temp1
.importzp Temp2
.importzp Delta


;************************************************************
; DrawLine
; (destroys A, X, Y)
;
;   draws a line according to PositionX/Y and LineEndX/Y
; 
;************************************************************  
DrawLine:
  jsr SetupDeltas
  lda DeltaX
  beq DoVerticalLine
  lda DeltaY
  beq DoHorizontalLine
  jsr BresenhamLineDraw
  rts
DoVerticalLine:
  jsr VerticalLine
  rts
DoHorizontalLine:
  jsr HorizontalLine
  rts

;************************************************************
; END DrawLine
;************************************************************

;************************************************************
; SetupDeltas
; (destroys A, X)
;
;   calculates delta value and sign for X and Y
; 
;************************************************************  
SetupDeltas:
  lda PositionX
  sta Temp1
  lda LineEndX
  sta Temp2
  jsr DeltaCalculation
  stx DeltaXSign
  sta DeltaX
  ; copy delta x into Word 1 (low byte of temp word) for
  ; purposes of DoubleValue9Bit
  ; no value for x or y in HGR will be > 384, thus we only
  ; need 9 bits to store the result
  sta Word1
  jsr DoubleValue9Bit
  sta DeltaXTimes2
  stx DeltaXTimes2+1

  lda PositionY
  sta Temp1
  lda LineEndY
  sta Temp2
  jsr DeltaCalculation
  stx DeltaYSign
  sta DeltaY
  sta Word1
  jsr DoubleValue9Bit
  sta DeltaXTimes2
  stx DeltaXTimes2+1
  rts

;************************************************************  
; END SetupDeltas
;************************************************************


;************************************************************  
; HorizontalLine
; (destroys A, X, Y due to use of ComputeVRAMAddress)
;
;    draws... a horizontal line
;************************************************************
HorizontalLine:
  ; delta y is zero
  lda PositionX
  sta BackupX
  lda #$01
  sta IncVal
  lda DeltaXSign
  ; it's assumed we know this is a point (dx = dy = 0) so beq
  ; is not a thing here
  bpl DrawHorizontal
  lda #$FF
  sta IncVal
DrawHorizontal:
  lda PositionX
  clc
  adc IncVal
  sta PositionX
  cmp LineEndX
  beq EndHorizontal
  jsr ComputeVRAMAddress
  jsr WritePixelValue
EndHorizontal:
  lda BackupX
  sta PositionX
  rts

;************************************************************  
; END HorizontalLine
;************************************************************


;************************************************************  
; VerticalLine
; (also destroys A, X, Y)
;
;   draws a vertical line. pretty much identical aside
;   from Y vars instead of X vars
;************************************************************
VerticalLine:
  ; delta x is zero
  ; and yes, this is all basically copypasta from HorizontalLine
  ; other alternative is to use indirection etc and that's slower
  ; this whole project is an attempt at speed being more important
  ; than code size
  lda PositionY
  sta BackupY
  lda #$01
  sta IncVal
  lda DeltaYSign
  bpl DrawVertical
  lda #$FF
  sta IncVal
DrawVertical:
  lda PositionY
  clc
  adc IncVal
  sta PositionY
  cmp LineEndY
  beq EndVertical
  jsr ComputeVRAMAddress
  jsr WritePixelValue
  clc
  bcc DrawVertical
EndVertical:
  lda BackupY
  sta PositionY
  rts
  
;************************************************************  
; END VerticalLine
;************************************************************


;************************************************************  
; BresenhamLineDraw
; (destroys A,X,Y due to ComputeVRAMAddress)
;
;    probably inefficient, but i'll take it
;************************************************************

BresenhamLineDraw:
  lda #$00
  sta Temp3
  lda DeltaY
  cmp DeltaX
  bcc NoInterchange
  ldx DeltaX
  sta DeltaX
  txa
  sta DeltaY
  lda #$01
  sta Temp3
NoInterchange:
  lda DeltaX
  sta Word2
  jsr DoubleValue9Bit
  sta DeltaXTimes2
  stx DeltaXTimes2+1
  ; do this last so we have the values in A and X already
  lda DeltaY
  jsr DoubleValue9Bit
  sta DeltaYTimes2
  stx DeltaYTimes2+1

  ; calculate error term
  sta Word1
  stx Word1+1
  ldx #$00
  stx Word2+1

  jsr Subtract16Bit
  lda Word1
  sta BresError
  lda Word1+1
  sta BresError+1

  ; since e = 2dy - dx, and b = 2dy - 2dx... just do the same subtraction again :)
  jsr Subtract16Bit
  lda Word1
  sta BresTerm_B
  lda Word1+1
  sta BresTerm_B

  ; backup positions
  lda PositionX
  sta BackupX
  lda PositionY
  sta BackupY

  lda #$01
  sta IncVal
  clc
  adc DeltaX
  sta DeltaX

BresenhamLoop:
  lda BresError
  sta Word1
  lda BresError+1
  sta Word1+1
  bpl AddToBoth
  lda BresTerm_A
  sta Word2
  lda BresTerm_A+1
  sta Word2+1
  jsr Add16Bit
  lda Word1
  sta BresError
  lda Word1+1
  sta BresError+1
  ldx #$00
  lda Interchange
  beq AddX
AddY:
  lda DeltaYSign
  clc
  adc PositionY
  sta PositionY
  txa
  beq Plot
AddX:
  lda DeltaXSign
  clc
  adc PositionX
  sta PositionX
  txa
  beq Plot
  bne Plot
AddToBoth:
  lda BresTerm_B
  sta Word2
  lda BresTerm_B+1
  sta Word2+1
  jsr Add16Bit
  lda Word1
  sta BresError
  lda Word1+1
  sta BresError+1
  ldx #$01
  bne AddY
Plot:
  jsr ComputeVRAMAddress
  jsr WritePixelValue
  inc DeltaX
  ; do we need this?
  lda IncVal
  cmp DeltaX
  bcc BresenhamLoop
  rts

;************************************************************  
; END BresenhamLineDraw
;************************************************************
