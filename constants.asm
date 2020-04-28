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
.exportzp VRAM_ADDR_HI
.exportzp VRAM_ADDR_LO
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

.exportzp VramOffset
.exportzp LineOffset
.exportzp VramWork

.exportzp IncVal
.exportzp LineEndX
.exportzp LineEndY
.exportzp DeltaX
.exportzp DeltaY
.exportzp DeltaXTimes2
.exportzp DeltaYTimes2
.exportzp Interchange
.exportzp BackupX
.exportzp BackupY
.exportzp DeltaXSign
.exportzp DeltaYSign

.exportzp Result
.exportzp Remainder
.exportzp Temp1
.exportzp Temp2
.exportzp Temp3
.exportzp Word1
.exportzp Word2

.exportzp BresTerm_A
.exportzp BresTerm_B
.exportzp BresError

.exportzp BackupColor

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
; (these should move to hgr constants. 
; also, these are constants, not zp locations.)
CENTER_X          = $46
CENTER_Y          = $5F
VRAM_ADDR_HI      = $20
VRAM_ADDR_LO      = $00
MIXED_TEXT_LO     = $50
MIXED_TEXT_HI     = $06
BLINKY_SPACE      = $60
SPACE             = $A0
COLON             = $BA


; zero page RAM locations
; monitor uses: $20-3F, $40-49, $4E, $4F, $50-55 (ugh)
; dos 3.3 uses (hex assumed): 26, 27, 2A-2F, 35-39, 
; 40-48, 4A-4D, 67-6A, 6F, 70, AF, B0, CA-CD, D8
;
; so. to be totally safe, let's not use:
; 20-55, 67, 6A, 6F, 70, AF, B0, CA-CD, D8
;
; FREE MEMORY then is: 
; 00-1F, 56-66, 68-69, 6B-6E, 71-AE, B1-C9, CE-D7,
; D9-FF
BackupColor       = $07
VramOffset        = $08
LineOffset        = $09
VramWork          = $09

Result            = $10
Remainder         = $11
Word1             = $10
Temp1             = $11  ; also high byte of Word1
Word2             = $12
Temp2             = $13  ; also high byte of Word2


IncVal            = $14
LineEndX          = $15
LineEndY          = $16
DeltaX            = $17  
DeltaY            = $18
Interchange       = $19
Temp3             = $19
MenuLo            = $1A
MenuHi            = $1B
DeltaXTimes2      = $5A
DeltaYTimes2      = $5C
DeltaXSign        = $5E
DeltaYSign        = $5F

BresTerm_A        = $5C
BresTerm_B        = $60
BresError         = $62

; text variables
TextPtr_Lo        = $C0
TextPtr_Hi        = $C1
TextAddr_Lo       = $C2
TextAddr_Hi       = $C3
LineNumber        = $C4

Vram_Lo           = $EB
Vram_Hi           = $EC
PositionX         = $ED
PositionY         = $EE
PixelLoc          = $EF
CurrentColor      = $FA
ColorWorkValue    = $FB
ColorPending      = $FC
KeyboardValue     = $FD
BackupX           = $FE
BackupY           = $FF

; data
LookupOffsetLo:
.byte   $00, $28, $50

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
