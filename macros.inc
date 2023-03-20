; GBC palette entry
; usage: 
;    rgb   #F8F888, #000000, #10A840, #F8B888
; outputs:
;    db   $FF, $47, $00, $00, $A2, $22, $FF, $46
macro rgb
    REPT _NARG
      REDEF eval EQUS STRRPL("\1", "#", "$")
      REDEF arg EQU {eval}
      redef red equ ((arg & $FF0000) >> 16) / 8
      redef grn equ ((arg & $00FF00) >>  8) / 8
      redef blu equ ((arg & $0000FF) >>  0) / 8
      dw (red) + (grn) << 5 + (blu) << 10
      SHIFT 1
    ENDR
endm

