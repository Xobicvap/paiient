;###############################################################
; PAIIeNT!
; 2018 lilin (rhamilton828@gmail.com)
; Licensed under GPL
;
; HGR drawing module
;
;###############################################################


; constants
KEYBOARD_READ     = $C000
KEYBOARD_STROBE   = $C010
GRAPHICS_ON       = $C050
GRAPHICS_OFF      = $C051
HIRES_FULLSCREEN  = $C052
HIRES_PAGE1       = $C054
HIRES_ON          = $C057

; HGR screen is, once again, 140 x 192 (0-139, 0-191)
; thus, center of screen is 70 (46), 96 (5f)
CENTER_X          = $46
CENTER_Y          = $5F
PIXEL_DIVISOR     = $07
VRAM_ADDR_HI      = $20
VRAM_ADDR_LO      = $00
BLACK             = $00
COLOR1            = $01
COLOR2            = $02
WHITE             = $03

; zero page RAM locations
BoxAddrOffset_Lo  = $06
BoxAddrOffset_Hi  = $07
BoxSetStart_Lo    = $08
LineOffset        = $09
LineInBox         = $1E

; storage for math routines; some are conserved to save ZP space
Dividend          = $50
Quotient          = $50
Product_Hi        = $51
; remainder is NOT set during division! must set from acc, AFTER division!
Remainder         = $52
Product_Lo        = $53
Multiplicand1     = $53
Divisor           = $54
Multiplicand2     = $55

Vram_Lo           = $EB
Vram_Hi           = $EC
PositionX         = $ED
PositionY         = $EE
PixelLoc          = $EF
CurrentColor      = $FA
ColorWorkValue    = $FB
KeyboardValue     = $FC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;************************************************************
; startup and main loop
;************************************************************

.SEGMENT "CODE"
.ORG $0900
Startup:
  lda GRAPHICS_ON
  lda HIRES_FULLSCREEN
  lda HIRES_ON
  lda HIRES_PAGE1
  
  lda #CENTER_X
  sta PositionX
  lda #CENTER_Y
  sta PositionY
  jsr ComputeVRAMAddress
  lda #$01
  sta CurrentColor
  jsr WritePixelValue
RunLoop:
  jsr ReadKeyboard
  lda KeyboardValue
  and #$80
  beq NoKBHit
  jsr Delay
  sta KEYBOARD_STROBE
NoKBHit:
  jmp RunLoop
  rts

;************************************************************
; END main loop
;************************************************************

  
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


;************************************************************
; TranslateYPosition
;
; calculates VRAM address to write to for the Y position
; (destroys A,X)
;   in a nutshell:
;   1. gets the "box #" (see comments) within a "box set"
;   2. gets the address of this box within box set, adds to VRAM base
;   3. gets the address of the box set, adds to VRAM base
;   4. gets the offset of the line within the box, adds to VRAM base
;************************************************************

TranslateYPosition:
  lda PositionY
  sta Dividend
    ; we're dividing y by 8 here to get the "box #".
    ; apple ii video memory can be divided into 24 "boxes" of 8 lines each.
    ; they're not contiguous because Steve Wozniak And The Quest For Reduced Chips (TM)
    ; ... but can be grouped into 3 sets of 8 boxes
  lda #$8
  sta Divisor
  jsr Divide8Bit
    ; accumulator is remainder if > 0; put in LineInBox
  sta Remainder
  bit Remainder
  bne SetLineInBox
    ; else set 0 as line in box  
  lda #$00
SetLineInBox:
  sta LineInBox
  
ComputeBoxAddressOffset:
    ; quotient of position y / 8 = box #
  lda Quotient
    ; get 3 lowest bits of box # to get box number within box set
    ; each "box set" is numbered 0-2; we compute the address for the box set later
  and #$07
  sta Multiplicand1
  lda #$80
  sta Multiplicand2
    ; multiply box # (within box set) times $80 to get the base address
    ; example: box 1 starts at $2080, box 3 starts at 2180, box 4 at 2200, etc   
  jsr Multiply16BitProduct
  lda Product_Hi
  clc 
  adc #VRAM_ADDR_HI
  sta Vram_Hi
  lda Product_Lo
  clc
  adc #VRAM_ADDR_LO
  sta Vram_Lo
  
ComputeBoxSetStartOffset:
    ; now we're reading the box # (the current Quotient)
    ; and dividing by 8 to get the nearest box set #. remember there are 3, numbered 0-2
    ; and each 8 boxes is a box set. thus box 7 is box set 0, box 8 is box set 1,
    ; box 15 is box set 1, box 17 is box set 2, etc.
    ;
    ; box set number only adds to lo byte of VRAM address 
    ;
    ; quotient is the same as dividend, so no need to set it
  lda #$8
  sta Divisor
  jsr Divide8Bit
  lda Quotient
  beq ComputeLineOffset
  sta Multiplicand1
  lda #$28
  sta Multiplicand2
  jsr Multiply16BitProduct
  lda Product_Lo
  clc
  adc Vram_Lo
  sta Vram_Lo
    ; each line within a box is $400 apart; compute the offset
ComputeLineOffset:  
  lda LineInBox
  beq EndComputeY
  sta Multiplicand1
  lda #4
  sta Multiplicand2
  jsr Multiply16BitProduct
  lda Product_Lo
  clc
  adc Vram_Hi
  sta Vram_Hi
EndComputeY:
  rts

;************************************************************
; END TranslateYPosition
;************************************************************  
  
  
;************************************************************
; TranslateXPosition
;
; calculates offset for VRAM for X position and adds to VRAM address
; (destroys A,X)
;   each line is $28 bytes long and each two bytes describes
;   7 pixels. so:
;     1. divide X position by 7 to get which 2-byte blop
;        (idk what else to call it) we're addressing
;     2. is the remainder non-zero?
;       yes: store the remainder in PixelLoc
;        (example: X = 45, 45 / 7 = 6 remainder 3, so this is
;         blop 6 (byte 12, see below), pixel # 3)
;       no: is X < 7?
;         yes: and X with %1010 to get which pixel this is
;         no: pixel really is 0, store in PixelLoc
;     3. get the quotient of X / 7, shift left 1
;        why? because X / 7 gives you blops, not bytes; 
;        each byte represents 3.5 pixels because reasons.
;        multiply by 2 to get the byte being addressed
;     4. add byte # to VRAM lo byte
;   note that PixelLoc referenced above is the pixel being
;   addressed, which is important when setting the color
;   for that pixel.
;************************************************************

TranslateXPosition:
  lda PositionX
  sta Dividend
  lda #PIXEL_DIVISOR
  sta Divisor
  jsr Divide8Bit
  sta Remainder
  bit Remainder
  bne StoreRemainderAsPixelLoc
  lda PositionX
  cmp #$07
  bmi PositionLessThan7
  ; position is >= 7 but remainder was 0
  lda #$00
  beq StoreRemainderAsPixelLoc
PositionLessThan7:
  and #$06
StoreRemainderAsPixelLoc:
  sta PixelLoc
  lda Quotient
  asl
  clc
  adc Vram_Lo
  sta Vram_Lo
  rts

;************************************************************
; END TranslateXPosition
;************************************************************  


;************************************************************
; ComputeVRAMAddress
;
; (destroys A, X)
;   given a Y and X position (in that order), compute the
;   VRAM address of the pixel to write to
;************************************************************  
  
ComputeVRAMAddress:
  jsr TranslateYPosition
  jsr TranslateXPosition
  rts

;************************************************************
; END ComputeVRAMAddress
;************************************************************  

;************************************************************
; WritePixelValue
;
; (destroys A,X,Y (sorry!)
;   1. load PixelLoc computed during TranslateXPosition
;   2. is PixelLoc == 3?
;     yes: branch to set 3rd pixel (which is different logic
;       entirely because it's part of BOTH bytes in a blop)
;   3. is PixelLoc > 3?
;     yes: branch to set pixel for pixels 4-6 (in byte 2 of blop)
;     no: continue, set pixel for pixels 0-2
;
;   pixels 0-2:
;     get current color, store in work value
;     get PixelLoc; if this is 0, write pixel 1
;     otherwise, set X to PixelLoc (1 or 2), 
;************************************************************  
  
WritePixelValue:
  lda PixelLoc
  cmp #$03
  beq Pixel3
  bpl ShiftLoop4through6
  
ShiftLoop0through2:
  lda CurrentColor
  sta ColorWorkValue
  lda PixelLoc
  beq WritePixel1
  tax  
  lda CurrentColor
ShiftLoop:  
  and #$7f  
  asl
  asl
  dex
  bne ShiftLoop  
  sta ColorWorkValue
WritePixel1:  
  ldy #$00
  lda (Vram_Lo), y
  ora ColorWorkValue
  sta (Vram_Lo), y
  rts
  
ShiftLoop4through6:
  lda CurrentColor
  asl
  sta ColorWorkValue
  lda PixelLoc
  and #$03 ; 100 & 11 = 0, 101 & 11 = 1, 110 & 11 = 10
  tax
  beq WritePixel2
  lda ColorWorkValue
ShiftLoop2:  
  asl
  asl
  dex
  bne ShiftLoop2
  sta ColorWorkValue
WritePixel2:  
  ldy #$01
  lda (Vram_Lo), y
  ora ColorWorkValue
  sta (Vram_Lo), y
  rts
  
Pixel3:
  ldy #$00
  lda CurrentColor
  and #$01
  beq HiPixelByte
  lda #%1000000
  sta ColorWorkValue
  lda (Vram_Lo), y
  ora ColorWorkValue
  sta (Vram_Lo), y
HiPixelByte:
  lda CurrentColor
  and #%10
  beq EndPixel3
  lda #%0000001
  sta ColorWorkValue
  iny
  lda (Vram_Lo), y
  ora ColorWorkValue
  sta (Vram_Lo), y
EndPixel3:
  rts

;************************************************************
; END WritePixelValue
;************************************************************  


;************************************************************
; ReadKeyboard
;
; (destroys A,X)
;   really should be called MenuHandler, I guess, since that's
;   what this does. reads the keyboard read register to see
;   if bit 7 is set; if so, handle whatever key was pressed,
;   if known.
;************************************************************  

ReadKeyboard:
  lda KEYBOARD_READ
  sta KeyboardValue
  and #$80
  bne ProcessKeyboard
  rts

;************************************************************
; END ReadKeyboard
;************************************************************  
  

;************************************************************
; ProcessKeyboard
;
; (destroys A,X)
;   handles keyboard input. the handler branches should really
;   be subroutines, I guess, since if there winds up being a
;   lot of them and they're lengthy, then we risk going out of
;   page and branching to something insane
;************************************************************  
  
ProcessKeyboard:
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
;  cmp #$30
;  beq ChangeToBlack
;  cmp #$31
;  beq ChangeToMagenta
;  cmp #$32
;  beq ChangeToGreen
;  cmp #$33
;  beq ChangeToWhite
;  cmp #$34
;  beq ChangeToBlue
;  cmp #$35
;  beq ChangeToOrange
  rts
  
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

MoveLeft:  
  ldx PositionX
  beq EndMoveLeft
  dex
  stx PositionX  
  jsr ComputeVRAMAddress
  jsr WritePixelValue
EndMoveLeft:
  rts
  
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
  
