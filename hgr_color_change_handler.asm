;###############################################################
; PAIIeNT!
; 2018 lilin (rhamilton828@gmail.com)
; Licensed under GPL
;
; menu handler for changing colors
;
;###############################################################

.export HandleColorMenu
.importzp KeyboardValue
.importzp ColorPending

;************************************************************
; HandleColorMenu
; (destroys A)
;
;   similar to the other menu handler, this is a submenu
;   for when user has opted to change colors
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

;************************************************************
; END HandleColorMenu
;************************************************************


;************************************************************
; ChangeColorBlack
; (destroys A)
;
;   writes aforementioned color to ColorPending
;************************************************************
  
ChangeColorBlack:
  lda #$00
  sta ColorPending
  rts

;************************************************************
; END ChangeColorBlack
;************************************************************


;************************************************************
; ChangeColorWhite
; (destroys A)
;
;   writes aforementioned color to ColorPending
;************************************************************

  ChangeColorWhite:
  lda #$03
  sta ColorPending
  rts

;************************************************************
; END ChangeColorWhite
;************************************************************


;************************************************************
; ChangeColorMagenta
; (destroys A)
;
;   writes aforementioned color to ColorPending
;************************************************************

ChangeColorMagenta:
  lda #$01
  sta ColorPending
  rts

;************************************************************
; END ChangeColorMagenta
;************************************************************


;************************************************************
; ChangeColorGreen
; (destroys A)
;
;   writes aforementioned color to ColorPending
;************************************************************

ChangeColorGreen:
  lda #$02
  sta ColorPending
  rts

;************************************************************
; END ChangeColorGreen
;************************************************************  


;************************************************************
; ChangeColorBlue
; (destroys A)
;
;   writes aforementioned color to ColorPending
;************************************************************

ChangeColorBlue:
  lda #$81
  sta ColorPending
  rts

;************************************************************
; END ChangeColorBlue
;************************************************************


;************************************************************
; ChangeColorOrange
; (destroys A)
;
;   writes aforementioned color to ColorPending
;************************************************************

ChangeColorOrange:
  lda #$82
  sta ColorPending
  rts  

;************************************************************
; END ChangeColorOrange
;************************************************************