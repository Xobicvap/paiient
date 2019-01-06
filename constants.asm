;###############################################################
; PAIIeNT!
; 2018 lilin (rhamilton828@gmail.com)
; Licensed under GPL
;
; constants and symbols
;
;###############################################################

.export KEYBOARD_READ
.export KEYBOARD_STROBE
.export GRAPHICS_ON
.export GRAPHICS_OFF
.export HIRES_FULLSCREEN
.export HIRES_MIXED
.export HIRES_PAGE1
.export HIRES_ON
.export LookupOffsetLo
.export LookupOffsetHi
.export ColorMessageLine1
.export ColorMessageLine2
.export ColorPrompt

.exportzp CENTER_X
.exportzp CENTER_Y
.exportzp PIXEL_DIVISOR
.exportzp VRAM_ADDR_HI
.exportzp VRAM_ADDR_LO
.exportzp BLACK
.exportzp COLOR1
.exportzp COLOR2
.exportzp WHITE
.exportzp MIXED_TEXT_LO
.exportzp MIXED_TEXT_HI
.exportzp BLINKY_SPACE
.exportzp SPACE
.exportzp COLON

.exportzp TextPtr_Lo
.exportzp TextPtr_Hi
.exportzp TextAddr_Lo
.exportzp TextAddr_Hi
.exportzp LineNumber

.exportzp BoxAddrOffset_Lo
.exportzp BoxAddrOffset_Hi
.exportzp BoxSetStart_Lo
.exportzp VramOffset
.exportzp LineOffset
.exportzp VramWork
.exportzp LineInBox

.exportzp Result
.exportzp Product_Hi
.exportzp Remainder
.exportzp Product_Lo
.exportzp Multiplicand1
.exportzp Divisor
.exportzp Multiplicand2

.exportzp BackupColor
.exportzp X_Left
.exportzp X_Right
.exportzp Y_Up
.exportzp Y_Down
.exportzp Start_X
.exportzp Start_Y

.exportzp Vram_Lo
.exportzp Vram_Hi
.exportzp PositionX
.exportzp PositionY
.exportzp PixelLoc
.exportzp CurrentColor
.exportzp ColorWorkValue
.exportzp ColorPending
.exportzp KeyboardValue

; soft switches
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
Result            = $50
Product_Hi        = $51
Remainder         = $52
Product_Lo        = $53
Multiplicand1     = $53
Divisor           = $54
Multiplicand2     = $55

BackupColor       = $C0
X_Left            = $C1
X_Right           = $C2
Y_Up              = $C3
Y_Down            = $C4
Start_X           = $C5
Start_Y           = $C6


Vram_Lo           = $EB
Vram_Hi           = $EC
PositionX         = $ED
PositionY         = $EE
PixelLoc          = $EF
CurrentColor      = $FA
ColorWorkValue    = $FB
ColorPending      = $FC
KeyboardValue     = $FD

; data
LookupOffsetLo:
.byte   $00, $28, $50

LookupOffsetHi:
.byte   $00, $04, $08, $0C, $10, $14, $18, $1C

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