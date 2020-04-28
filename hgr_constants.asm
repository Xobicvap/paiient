;###############################################################
; PAIIeNT!
; 2018 lilin (rhamilton828@gmail.com)
; Licensed under GPL
;
; lookup offsets for high byte of VRAM address in HGR mode
;
;###############################################################

.export LookupOffsetHi

LookupOffsetHi:
.byte   $00, $04, $08, $0C, $10, $14, $18, $1C
