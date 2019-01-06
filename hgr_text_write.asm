;###############################################################
; PAIIeNT!
; 2018 lilin (rhamilton828@gmail.com)
; Licensed under GPL
;
; HGR text writing
;
;###############################################################

.export ClearTextArea
.export WriteLine
.export WritePrompt
.export DetermineTextAreaAddr
.importzp SPACE
.importzp BLINKY_SPACE
.importzp COLON
.importzp MIXED_TEXT_LO
.importzp MIXED_TEXT_HI
.importzp TextPtr_Lo
.importzp TextPtr_Hi
.importzp TextAddr_Lo
.importzp TextAddr_Hi
.importzp LineNumber

;************************************************************
; ClearTextArea
; (destroys A,X)
;
;  Writes the space character to $0400-$07FF, thus
;  clearing the text area 
;************************************************************
  
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

;************************************************************
; END ClearTextArea
;************************************************************


;************************************************************
; WriteLine
; (destroys A,Y)
;
;   writes data from (text ptr),y to specified text page
;   address until a null byte is found in data or $25 bytes
;   have been written 
;   usage: write address of text data ptr to TextPtr, then call
;************************************************************
  
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

;************************************************************
; END ClearTextArea
;************************************************************


;************************************************************
; WritePrompt
; (destroys A,Y)
;
;   Writes the prompt (": (blinky space)") to the text page
;************************************************************

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

;************************************************************
; END WritePrompt
;************************************************************


;************************************************************
; DetermineTextAreaAddr
; (destroys A,X)
;
;   Determines the current text area address to write to
;************************************************************

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

;************************************************************
; END DetermineTextAreaAddr
;************************************************************
