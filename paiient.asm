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
HIRES_MIXED       = $C053
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
MIXED_TEXT_LO     = $50
MIXED_TEXT_HI     = $06
BLINKY_SPACE      = $60
SPACE             = $A0
COLON             = $BA

; text variables
TextPtr_Lo        = $C0
TextPtr_Hi        = $C1
TextAddr_Lo       = $C2
TextAddr_Hi       = $C3
LineNumber        = $C4


; zero page RAM locations
BoxAddrOffset_Lo  = $06
BoxAddrOffset_Hi  = $07
BoxSetStart_Lo    = $08
VramOffset        = $08
LineOffset        = $09
VramWork          = $09
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
ColorPending      = $FC
KeyboardValue     = $FD

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
  
  jsr ClearTextArea
  
  lda #CENTER_X
  sta PositionX
  lda #CENTER_Y
  sta PositionY
  jsr ComputeVRAMAddress
  lda #$01
  sta CurrentColor
  sta ColorPending
  jsr WritePixelValue
RunLoop:
  jsr ReadKeyboard
  jsr MenuHandler
ClearKBStrobeIfHit:  
; was there a keyboard hit that was processed?  
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
  ;asl ColorWorkValue
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
  ;cmp CurrentColor
  ;beq EndPaletteBitChange
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
  

;************************************************************
; MenuHandler
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
  bne InputOver
  jmp DisplayColorChangePrompt
InputOver:
  rts

;************************************************************
; END MenuHandler
;************************************************************


;************************************************************
; MoveUp
;
; (destroys A, X, Y)
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
;
; (destroys A, X, Y)
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
;
; (destroys A, X, Y)
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
;
; (destroys A, X, Y)
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
;
; (destroys A, X, Y)
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

  
HandleColorMenu:
  bne DoColorMenu
  rts
DoColorMenu:  
  lda KeyboardValue
  and #$7f
ChangeIsBlack:  
  cmp #$42
  bne ChangeIsWhite
  jsr ChangeColorBlack
ChangeIsWhite:
  cmp #$57
  bne ChangeIsMagenta
  jsr ChangeColorWhite
ChangeIsMagenta:
  cmp #$4d
  bne ChangeIsGreen
  jsr ChangeColorMagenta
ChangeIsGreen:
  cmp #$47
  bne ChangeIsBlue
  jsr ChangeColorGreen
ChangeIsBlue:
  cmp #$4c
  bne ChangeIsOrange
  jsr ChangeColorBlue
ChangeIsOrange:
  cmp #$4f
  bne ChangeIsOver
  jsr ChangeColorOrange
ChangeIsOver:
  rts
  
ChangeColorBlack:
  lda #$00
  sta ColorPending
  rts
  
ChangeColorWhite:
  lda #$03
  sta ColorPending
  rts

ChangeColorMagenta:
  lda #$01
  sta ColorPending
  rts
  
ChangeColorGreen:
  lda #$02
  sta ColorPending
  rts

ChangeColorBlue:
  lda #$81
  sta ColorPending
  rts

ChangeColorOrange:
  lda #$82
  sta ColorPending
  rts  
  
ClearTextArea:
  lda #SPACE
  tax
ClearLoop:
  sta $0400,x
  sta $0500,x
  sta $0600,x
  sta $0700,x
  inx
  bne ClearLoop
  rts  


  
; usage: write address of text data ptr to TextPtr, then call
WriteLine:
  ldy #$00
CopyText:
  lda (TextPtr_Lo), y
  beq CopyIsOver
  sta (TextAddr_Lo), y
  iny
  cpy #$25
  bne CopyText
CopyIsOver:  
  rts
 
WritePrompt:
  lda #COLON
  sta (TextAddr_Lo), y
  iny
  lda #SPACE
  sta (TextAddr_Lo), y
  iny
  lda #BLINKY_SPACE
  sta (TextAddr_Lo), y
  rts  

DetermineTextAreaAddr:
  lda #MIXED_TEXT_HI
  sta TextAddr_Hi
  lda #MIXED_TEXT_LO
  sta TextAddr_Lo
  ldx LineNumber
  beq EndDetermineTextAreaAddr
AddTextLineOffset:
  clc
  adc #$80
  sta TextAddr_Lo
  bcc ToNextAdd
  inc TextAddr_Hi
ToNextAdd:  
  dex
  bne AddTextLineOffset
EndDetermineTextAreaAddr:  
  rts
  
; data
ColorPrompt:
;COLOR: (blinky space)
.byte   $83, $8F, $8C, $8F, $92, $00

ColorMessageLine1:
;(B)LACK  (W)HITE (M)AGENTA
.byte   $A8, $C2, $A9, $CC, $C1, $C3, $CB, $A0
.byte   $A0, $A8, $D7, $A9, $C8, $C9, $D4, $C5
.byte   $A0, $A8, $CD, $A9, $C1, $C7, $C5, $CE
.byte   $D4, $C1, $00

ColorMessageLine2:
;(G)REEN B(L)UE (O)RANGE
.byte   $A8, $C7, $A9, $D2, $C5, $C5, $CE, $A0
.byte   $C2, $A8, $CC, $A9, $D5, $C5, $A0, $A8
.byte   $CF, $A9, $D2, $C1, $CE, $C7, $C5, $00  