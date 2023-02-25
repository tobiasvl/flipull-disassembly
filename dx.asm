GDMA:
    ld a, $C8
    ldh [$FF51], a
    ld a, $00
    ldh [$FF52], a
    ld a, $98
    ldh [$FF53], a
    ld a, $00
    ldh [$FF54], a
    ld a, 35
    ldh [$FF55], a

    ld a, 3
    ld [rVBK], a
    ld [rSVBK], a
    ld a, $D8
    ldh [$FF51], a
    ld a, $00
    ldh [$FF52], a
    ld a, $98
    ldh [$FF53], a
    ld a, $00
    ldh [$FF54], a
    ld a, 35
    ldh [$FF55], a
    ld  a, [rCurrentVBK]
    ld [rVBK], a
    ld a, [rCurrentSVBK]
    ld [rSVBK], a
    ret

VBlankInterruptHandlerDX::
    ldh  a, [$FF9D]                               ; $0206: $F0 $9D
    cp   $04                                      ; $0208: $FE $04
    jr   z, .jr_000_0288                          ; $020A: $28 $7C

    cp   $07                                      ; $020C: $FE $07
    jp   nc, .Jump_000_03CC                       ; $020E: $D2 $CC $03

    cp   $03                                      ; $0211: $FE $03
    jp   nz, .vBlankDone                          ; $0213: $C2 $C3 $03

    ldh  a, [$FF97]                               ; $0216: $F0 $97
    cp   $00                                      ; $0218: $FE $00
    jr   z, .jr_000_025E                          ; $021A: $28 $42

    call GDMA


.jr_000_025E:
    call GDMA
;    call Call_000_3029_DX                            ; $025E: $CD $29 $30
;    ld   hl, $C827                                ; $0261: $21 $27 $98
;    ld   de, wScore+6                             ; $0264: $11 $26 $C1
;    ld   b, $07                                   ; $0267: $06 $07
;    call MemCpyDEtoHLReverse                      ; $0269: $CD $AC $2D
;    ld   hl, $C8EF                                ; $026C: $21 $EF $98
;    ld   b, $04                                   ; $026F: $06 $04
;    ld   de, hMinutes                             ; $0271: $11 $CE $FF
;    call MemCpyDEtoHLReverse                      ; $0274: $CD $AC $2D
;    ld   hl, $C950                         ; $0277: $21 $50 $99
;    ld   b, $02                                   ; $027A: $06 $02
;    call MemCpyDEtoHLReverse                      ; $027C: $CD $AC $2D
;    ld   hl, $C9D1                         ; $027F: $21 $D1 $99
;    ldh  a, [hSBlocksRemaining]                   ; $0282: $F0 $C5
;    ld   [hl], a                                  ; $0284: $77
    jp   .vBlankDone                              ; $0285: $C3 $C3 $03

.jr_000_0288:
    ldh  a, [$FF97]                               ; $0288: $F0 $97
    cp   $01                                      ; $028A: $FE $01
    jp   z, .Jump_000_037B                        ; $028C: $CA $7B $03

    ldh  a, [$FFA0]                               ; $028F: $F0 $A0
    cp   $02                                      ; $0291: $FE $02
    jp   c, .Jump_000_0367                        ; $0293: $DA $67 $03

    jp   z, .Jump_000_033A                        ; $0296: $CA $3A $03

    cp   $04                                      ; $0299: $FE $04
    jr   c, .jr_000_02FE                          ; $029B: $38 $61

    jr   z, .jr_000_02D4                          ; $029D: $28 $35

    cp   $05                                      ; $029F: $FE $05
    jr   z, .jr_000_02A9                          ; $02A1: $28 $06

    ;call Call_000_3029_DX                            ; $02A3: $CD $29 $30
    call GDMA
    jp   .vBlankDone                              ; $02A6: $C3 $C3 $03


.jr_000_02A9:
    ld   hl, $98A1                                ; $02A9: $21 $A1 $98
    ld   de, SorryText                            ; $02AC: $11 $C6 $39
    ld   b, $0C                                   ; $02AF: $06 $0C
    call MemCpyDEtoHLShort                        ; $02B1: $CD $B6 $2D
    ld   hl, $98C1                                ; $02B4: $21 $C1 $98
    ld   de, YouHaveText                          ; $02B7: $11 $D2 $39
    ld   b, $0C                                   ; $02BA: $06 $0C
    call MemCpyDEtoHLShort                        ; $02BC: $CD $B6 $2D
    ld   hl, $98E1                                ; $02BF: $21 $E1 $98
    ld   de, NoNextMoveText                       ; $02C2: $11 $DE $39
    ld   b, $0C                                   ; $02C5: $06 $0C
    call MemCpyDEtoHLShort                        ; $02C7: $CD $B6 $2D
    ld   hl, $99CB                                ; $02CA: $21 $CB $99
    ;ld   a, [$C00A]                               ; $02CD: $FA $0A $C0
    ;ld   [hl], a                                  ; $02D0: $77
    jp   .blankPalettesInPlayArea;.vBlankDone                              ; $02D1: $C3 $C3 $03


.jr_000_02D4:
    ld   hl, $9961                                ; $02D4: $21 $61 $99
    ld   de, ClearBonusText                       ; $02D7: $11 $AE $39
    ld   b, $0C                                   ; $02DA: $06 $0C
    call MemCpyDEtoHLShort                        ; $02DC: $CD $B6 $2D
    ld   hl, $9988                                ; $02DF: $21 $88 $99
    ld   de, $C113                                ; $02E2: $11 $13 $C1
    ld   b, $04                                   ; $02E5: $06 $04
    call MemCpyDEtoHLReverse                      ; $02E7: $CD $AC $2D
    ld   hl, $9827                                ; $02EA: $21 $27 $98
    ld   de, wScore+6                             ; $02ED: $11 $26 $C1
    ld   b, $07                                   ; $02F0: $06 $07
    call MemCpyDEtoHLReverse                      ; $02F2: $CD $AC $2D
    ld   hl, $99D1;vSBlockCount                         ; $02F5: $21 $D1 $99
    ldh  a, [hSBlocksRemaining]                   ; $02F8: $F0 $C5
    ld   [hl], a                                  ; $02FA: $77
    jp   .blankPalettesInPlayArea;.vBlankDone                              ; $02FB: $C3 $C3 $03


.jr_000_02FE:
    ldh  a, [$FFA6]                               ; $02FE: $F0 $A6
    bit  7, a                                     ; $0300: $CB $7F
    jp   nz, .vBlankDone                          ; $0302: $C2 $C3 $03

    ld   hl, $9921                                ; $0305: $21 $21 $99
    ld   de, TimeBonusText                        ; $0308: $11 $96 $39
    ld   b, $0C                                   ; $030B: $06 $0C
    call MemCpyDEtoHLShort                        ; $030D: $CD $B6 $2D
    ld   hl, $9941                                ; $0310: $21 $41 $99
    ld   de, X10Text                              ; $0313: $11 $A2 $39
    ld   b, $0C                                   ; $0316: $06 $0C
    call MemCpyDEtoHLShort                        ; $0318: $CD $B6 $2D
    ld   hl, $9827                                ; $031B: $21 $27 $98
    ld   de, wScore+6                             ; $031E: $11 $26 $C1
    ld   b, $07                                   ; $0321: $06 $07
    call MemCpyDEtoHLReverse                      ; $0323: $CD $AC $2D
    ld   hl, $98EF                                ; $0326: $21 $EF $98
    ld   de, hMinutes                             ; $0329: $11 $CE $FF
    ld   b, $04                                   ; $032C: $06 $04
    call MemCpyDEtoHLReverse                      ; $032E: $CD $AC $2D
    ld   hl, $99D1                         ; $0331: $21 $D1 $99
    ldh  a, [hSBlocksRemaining]                   ; $0334: $F0 $C5
    ld   [hl], a                                  ; $0336: $77
    jp   .blankPalettesInPlayArea;.vBlankDone                              ; $0337: $C3 $C3 $03


.Jump_000_033A:
    ldh  a, [$FFA6]                               ; $033A: $F0 $A6
    bit  5, a                                     ; $033C: $CB $6F
    jr   z, .jr_000_0353                          ; $033E: $28 $13

    ld   hl, $98E1                                ; $0340: $21 $E1 $98
    ld   de, PerfectText                          ; $0343: $11 $8A $39
    ld   b, $0C                                   ; $0346: $06 $0C
    call MemCpyDEtoHLShort                        ; $0348: $CD $B6 $2D
    ld   hl, $99D1                         ; $034B: $21 $D1 $99
    ldh  a, [hSBlocksRemaining]                   ; $034E: $F0 $C5
    ld   [hl], a                                  ; $0350: $77
    jr   .jr_000_035E                             ; $0351: $18 $0B

.jr_000_0353:
    ld   hl, $98E1                                ; $0353: $21 $E1 $98
    ld   de, ClearText                            ; $0356: $11 $7E $39
    ld   b, $0C                                   ; $0359: $06 $0C
    call MemCpyDEtoHLShort                        ; $035B: $CD $B6 $2D

.jr_000_035E:
    ld   hl, $99CB                                ; $035E: $21 $CB $99
    ld   a, [$C00A]                               ; $0361: $FA $0A $C0
    ld   [hl], a                                  ; $0364: $77
    jr   .vBlankDone                              ; $0365: $18 $5C

.Jump_000_0367:
    ld   hl, $98E1                                ; $0367: $21 $E1 $98
    ld   de, TimeUpText                           ; $036A: $11 $BA $39
    ld   b, $0C                                   ; $036D: $06 $0C
    call MemCpyDEtoHLShort                        ; $036F: $CD $B6 $2D
    ld   hl, $99CB                                ; $0372: $21 $CB $99
    ;ld   a, [$C00A]                               ; $0375: $FA $0A $C0
    ;ld   [hl], a                                  ; $0378: $77
    jr   .vBlankDone                              ; $0379: $18 $48

.Jump_000_037B:
    ldh  a, [$FFA0]                               ; $037B: $F0 $A0
    cp   $00                                      ; $037D: $FE $00
    jr   z, .vBlankDone                           ; $037F: $28 $42

    cp   $03                                      ; $0381: $FE $03
    jr   nc, .vBlankDone                          ; $0383: $30 $3E

    ldh  a, [$FFA8]                               ; $0385: $F0 $A8
    bit  4, a                                     ; $0387: $CB $67
    jr   z, .jr_000_039D                          ; $0389: $28 $12
;
;    ld   hl, $FFD7                                ; $038B: $21 $D7 $FF
;    ld   a, [hl+]                                 ; $038E: $2A
;    ld   b, a                                     ; $038F: $47
;    ld   a, [hl+]                                 ; $0390: $2A
;    ld   e, a                                     ; $0391: $5F
;    ld   a, [hl+]                                 ; $0392: $2A
;    ld   d, a                                     ; $0393: $57
;    ld   a, $2B                                   ; $0394: $3E $2B
;
;:   ld   [de], a                                  ; $0396: $12
;    inc  de                                       ; $0397: $13
;    dec  b                                        ; $0398: $05
;    jr   nz, :-                                   ; $0399: $20 $FB

    jr   .jr_000_03A0                             ; $039B: $18 $03

.jr_000_039D:
    call GDMA
;    call Call_000_3029_DX                            ; $039D: $CD $29 $30

.jr_000_03A0:
    ;ld   hl, $98F0                    ; $03A0: $21 $F0 $98
    ;ld   de, hBlocksInitial+1                     ; $03A3: $11 $C1 $FF
    ;ld   b, $02                                   ; $03A6: $06 $02
    ;call MemCpyDEtoHLReverse                      ; $03A8: $CD $AC $2D
    ;ld   hl, $9950                         ; $03AB: $21 $50 $99
    ;ld   de, hBlocks+1                            ; $03AE: $11 $CA $FF
    ;ld   b, $02                                   ; $03B1: $06 $02
    ;call MemCpyDEtoHLReverse                      ; $03B3: $CD $AC $2D
    ;ld   hl, $99D1                         ; $03B6: $21 $D1 $99
    ;ldh  a, [hSBlocksRemaining]                   ; $03B9: $F0 $C5
    ;ld   [hl], a                                  ; $03BB: $77
    ;ld   hl, $99CB                                ; $03BC: $21 $CB $99
    ;ld   a, [$C00A]                               ; $03BF: $FA $0A $C0
    ;ld   [hl], a                                  ; $03C2: $77

.vBlankDone:
    ld   a, $01                                   ; $03C3: $3E $01
    ldh  [hVBlankDone], a                         ; $03C5: $E0 $91
    pop  hl                                       ; $03C7: $E1
    pop  de                                       ; $03C8: $D1
    pop  bc                                       ; $03C9: $C1
    pop  af                                       ; $03CA: $F1
    reti                                          ; $03CB: $D9

.Jump_000_03CC:
    jp   nz, .Jump_000_046C                       ; $03CC: $C2 $6C $04

    ldh  a, [$FF97]                               ; $03CF: $F0 $97
    cp   $00                                      ; $03D1: $FE $00
    jr   z, :+                                    ; $03D3: $28 $06

    ldh  a, [$FFA8]                               ; $03D5: $F0 $A8
    bit  3, a                                     ; $03D7: $CB $5F
    jr   z, :++                                   ; $03D9: $28 $48

:   ld   hl, $9861                                ; $03DB: $21 $61 $98
    ld   de, BlankText                            ; $03DE: $11 $66 $39
    ld   b, $0A                                   ; $03E1: $06 $0A
    call MemCpyDEtoHLShort                        ; $03E3: $CD $B6 $2D
    ld   hl, $9881                                ; $03E6: $21 $81 $98
    ld   de, PushText                             ; $03E9: $11 $2A $39
    ld   b, $0A                                   ; $03EC: $06 $0A
    call MemCpyDEtoHLShort                        ; $03EE: $CD $B6 $2D
    ld   hl, $98A1                                ; $03F1: $21 $A1 $98
    ld   de, BlankText                            ; $03F4: $11 $66 $39
    ld   b, $0A                                   ; $03F7: $06 $0A
    call MemCpyDEtoHLShort                        ; $03F9: $CD $B6 $2D
    ld   hl, $98C1                                ; $03FC: $21 $C1 $98
    ld   de, StartText                            ; $03FF: $11 $36 $39
    ld   b, $0A                                   ; $0402: $06 $0A
    call MemCpyDEtoHLShort                        ; $0404: $CD $B6 $2D
    ld   hl, $98E1                                ; $0407: $21 $E1 $98
    ld   de, BlankText                            ; $040A: $11 $66 $39
    ld   b, $0A                                   ; $040D: $06 $0A
    call MemCpyDEtoHLShort                        ; $040F: $CD $B6 $2D
    ld   hl, $9901                                ; $0412: $21 $01 $99
    ld   de, ToText                               ; $0415: $11 $42 $39
    ld   b, $0A                                   ; $0418: $06 $0A
    call MemCpyDEtoHLShort                        ; $041A: $CD $B6 $2D
    jp   .blankPalettesInPlayArea;.vBlankDone                              ; $0421: $18 $A0

:   ld   hl, $9861                                ; $0423: $21 $61 $98
    ld   de, BlankText                            ; $0426: $11 $66 $39
    ld   b, $0A                                   ; $0429: $06 $0A
    call MemCpyDEtoHLShort                        ; $042B: $CD $B6 $2D
    ld   hl, $9881                                ; $042E: $21 $81 $98
    ld   de, BlankText                            ; $0431: $11 $66 $39
    ld   b, $0A                                   ; $0434: $06 $0A
    call MemCpyDEtoHLShort                        ; $0436: $CD $B6 $2D
    ld   hl, $98A1                                ; $0439: $21 $A1 $98
    ld   de, BlankText                            ; $043C: $11 $66 $39
    ld   b, $0A                                   ; $043F: $06 $0A
    call MemCpyDEtoHLShort                        ; $0441: $CD $B6 $2D
    ld   hl, $98C1                                ; $0444: $21 $C1 $98
    ld   de, BlankText                            ; $0447: $11 $66 $39
    ld   b, $0A                                   ; $044A: $06 $0A
    call MemCpyDEtoHLShort                        ; $044C: $CD $B6 $2D
    ld   hl, $98E1                                ; $044F: $21 $E1 $98
    ld   de, BlankText                            ; $0452: $11 $66 $39
    ld   b, $0A                                   ; $0455: $06 $0A
    call MemCpyDEtoHLShort                        ; $0457: $CD $B6 $2D
    ld   hl, $9901                                ; $045A: $21 $01 $99
    ld   de, PauseText                            ; $045D: $11 $72 $39
    ld   b, $0A                                   ; $0460: $06 $0A
    call MemCpyDEtoHLShort                        ; $0462: $CD $B6 $2D
    jp   .blankPalettesInPlayArea;p   .vBlankDone                              ; $0469: $C3 $C3 $03

.Jump_000_046C:
    cp   $09                                      ; $046C: $FE $09
    jp   nc, .Jump_000_050F                       ; $046E: $D2 $0F $05

    ldh  a, [$FF97]                               ; $0471: $F0 $97
    cp   $00                                      ; $0473: $FE $00
    jr   z, .jr_000_047D                          ; $0475: $28 $06

    ldh  a, [$FFA8]                               ; $0477: $F0 $A8
    bit  3, a                                     ; $0479: $CB $5F
    jr   z, .jr_000_04C6                          ; $047B: $28 $49

.jr_000_047D:
    ld   hl, $9921                                ; $047D: $21 $21 $99
    ld   de, BlankText                            ; $0480: $11 $66 $39
    ld   b, $0A                                   ; $0483: $06 $0A
    call MemCpyDEtoHLShort                        ; $0485: $CD $B6 $2D
    ld   hl, $9941                                ; $0488: $21 $41 $99
    ld   de, ContinueText                         ; $048B: $11 $4E $39
    ld   b, $0A                                   ; $048E: $06 $0A
    call MemCpyDEtoHLShort                        ; $0490: $CD $B6 $2D
    ld   hl, $9961                                ; $0493: $21 $61 $99
    ld   de, BlankText                            ; $0496: $11 $66 $39
    ld   b, $0A                                   ; $0499: $06 $0A
    call MemCpyDEtoHLShort                        ; $049B: $CD $B6 $2D
    ld   hl, $9981                                ; $049E: $21 $81 $99
    ld   de, GameText                             ; $04A1: $11 $5A $39
    ld   b, $0A                                   ; $04A4: $06 $0A
    call MemCpyDEtoHLShort                        ; $04A6: $CD $B6 $2D
    ld   hl, $99A1                                ; $04A9: $21 $A1 $99
    ld   de, BlankText                            ; $04AC: $11 $66 $39
    ld   b, $0A                                   ; $04AF: $06 $0A
    call MemCpyDEtoHLShort                        ; $04B1: $CD $B6 $2D
    ld   hl, $99C1                                ; $04B4: $21 $C1 $99
    ld   de, BlankText                            ; $04B7: $11 $66 $39
    ld   b, $0A                                   ; $04BA: $06 $0A
    call MemCpyDEtoHLShort                        ; $04BC: $CD $B6 $2D
    ;ld   a, $07                                   ; $04BF: $3E $07
    ;ldh  [$FF9D], a                               ; $04C1: $E0 $9D
    jr   .blankPalettesInPlayArea; p   .vBlankDone                              ; $04C3: $C3 $C3 $03

.jr_000_04C6:
    ld   hl, $9921                                ; $04C6: $21 $21 $99
    ld   de, BlankText                            ; $04C9: $11 $66 $39
    ld   b, $0A                                   ; $04CC: $06 $0A
    call MemCpyDEtoHLShort                        ; $04CE: $CD $B6 $2D
    ld   hl, $9941                                ; $04D1: $21 $41 $99
    ld   de, BlankText                            ; $04D4: $11 $66 $39
    ld   b, $0A                                   ; $04D7: $06 $0A
    call MemCpyDEtoHLShort                        ; $04D9: $CD $B6 $2D
    ld   hl, $9961                                ; $04DC: $21 $61 $99
    ld   de, BlankText                            ; $04DF: $11 $66 $39
    ld   b, $0A                                   ; $04E2: $06 $0A
    call MemCpyDEtoHLShort                        ; $04E4: $CD $B6 $2D
    ld   hl, $9981                                ; $04E7: $21 $81 $99
    ld   de, BlankText                            ; $04EA: $11 $66 $39
    ld   b, $0A                                   ; $04ED: $06 $0A
    call MemCpyDEtoHLShort                        ; $04EF: $CD $B6 $2D
    ld   hl, $99A1                                ; $04F2: $21 $A1 $99
    ld   de, BlankText                            ; $04F5: $11 $66 $39
    ld   b, $0A                                   ; $04F8: $06 $0A
    call MemCpyDEtoHLShort                        ; $04FA: $CD $B6 $2D
    ld   hl, $99C1                                ; $04FD: $21 $C1 $99
    ld   de, BlankText                            ; $0500: $11 $66 $39
    ld   b, $0A                                   ; $0503: $06 $0A
    call MemCpyDEtoHLShort                        ; $0505: $CD $B6 $2D
    ;ld   a, $07                                   ; $0508: $3E $07
    ;ldh  [$FF9D], a                               ; $050A: $E0 $9D
    ;jp   .vBlankDone                  

.blankPalettesInPlayArea:
    ldh  a, [hIE2]
    cp   $11
    jp   nz, .vBlankDone

    ldh  [rVBK], a
    ld  [rCurrentVBK], a
    ;ld a, 3
    ;ldh  [rSVBK], a
    ;ld  [rCurrentSVBK], a

    ; TODO This is $FF in Japan
    ld a, $7F
    ldh [$FF51], a
    ld a, $00
    ldh [$FF52], a
    ld a, $99
    ldh [$FF53], a
    ld a, $20
    ldh [$FF54], a
    ld a, 8
    ldh [$FF55], a

    ldh  [rVBK], a            ; $050C: $C3 $C3 $03
    ld  [rCurrentVBK], a
    ;ld  a, [rCurrentSVBK]
    ;ldh  [rSVBK], a
    jp .vBlankDone

.Jump_000_050F:
    jr   nz, .jr_000_055A                         ; $050F: $20 $49

    ld   hl, $9861                                ; $0511: $21 $61 $98
    ld   de, $C861                                ; $0514: $11 $61 $C8
    ld   b, $07                                   ; $0517: $06 $07
    call DrawFromWRAM                             ; $0519: $CD $C2 $30
    ld   hl, $9881                                ; $051C: $21 $81 $98
    ld   de, $C881                                ; $051F: $11 $81 $C8
    ld   b, $0A                                   ; $0522: $06 $0A
    call DrawFromWRAM                             ; $0524: $CD $C2 $30
    ld   hl, $98A1                                ; $0527: $21 $A1 $98
    ld   de, $C8A1                                ; $052A: $11 $A1 $C8
    ld   b, $07                                   ; $052D: $06 $07
    call DrawFromWRAM                             ; $052F: $CD $C2 $30
    ld   hl, $98C1                                ; $0532: $21 $C1 $98
    ld   de, $C8C1                                ; $0535: $11 $C1 $C8
    ld   b, $0A                                   ; $0538: $06 $0A
    call DrawFromWRAM                             ; $053A: $CD $C2 $30
    ld   hl, $98E1                                ; $053D: $21 $E1 $98
    ld   de, $C8E1                                ; $0540: $11 $E1 $C8
    ld   b, $07                                   ; $0543: $06 $07
    call DrawFromWRAM                             ; $0545: $CD $C2 $30
    ld   hl, $9901                                ; $0548: $21 $01 $99
    ld   de, $C901                                ; $054B: $11 $01 $C9
    ld   b, $0A                                   ; $054E: $06 $0A
    call DrawFromWRAM                             ; $0550: $CD $C2 $30
    ;ld   a, $0A                                   ; $0553: $3E $0A
    ;ldh  [$FF9D], a                               ; $0555: $E0 $9D
    jp   .vBlankDone                              ; $0557: $C3 $C3 $03


.jr_000_055A:
    call GDMA

    jp .vBlankDone



GameLoopDX::
    call Call_000_3029_PAL_DX
    
    ldh  a, [$FF9D]                               ; $0206: $F0 $9D
    cp   $04                                      ; $0208: $FE $04
    jr   z, .jr_000_0288                          ; $020A: $28 $7C

    cp   $07                                      ; $020C: $FE $07
    jp   nc, .Jump_000_03CC                       ; $020E: $D2 $CC $03

    cp   $03                                      ; $0211: $FE $03
    jp   nz, .vBlankDone                          ; $0213: $C2 $C3 $03

    ldh  a, [$FF97]                               ; $0216: $F0 $97
    cp   $00                                      ; $0218: $FE $00
    jr   z, .jr_000_025E                          ; $021A: $28 $42

    call Call_000_3029_DX                            ; $021C: $CD $29 $30
    ld   hl, $C8F0                    ; $021F: $21 $F0 $98
    ldh  a, [$FFA7]                               ; $0222: $F0 $A7
    bit  4, a                                     ; $0224: $CB $67
    jr   z, :+                                    ; $0226: $28 $0A

    bit  5, a                                     ; $0228: $CB $6F
    jr   nz, :+                                   ; $022A: $20 $06

    ld   a, " "                                   ; $022C: $3E $24
    ld   [hl+], a                                 ; $022E: $22
    ld   [hl], a                                  ; $022F: $77
    jr   :++                                      ; $0230: $18 $08

:   ld   de, hBlocksInitial+1                     ; $0232: $11 $C1 $FF
    ld   b, $02                                   ; $0235: $06 $02
    call MemCpyDEtoHLReverse                      ; $0237: $CD $AC $2D

:   ld   hl, $C950                         ; $023A: $21 $50 $99
    ld   de, hBlocks+1                            ; $023D: $11 $CA $FF
    ld   b, $02                                   ; $0240: $06 $02
    call MemCpyDEtoHLReverse                      ; $0242: $CD $AC $2D
    ld   hl, $C9D1                         ; $0245: $21 $D1 $99
    ldh  a, [$FFA7]                               ; $0248: $F0 $A7
    bit  3, a                                     ; $024A: $CB $5F
    jr   z, :+                                    ; $024C: $28 $0A

    bit  6, a                                     ; $024E: $CB $77
    jr   nz, :+                                   ; $0250: $20 $06

    ld   a, " "                                   ; $0252: $3E $24
    ld   [hl], a                                  ; $0254: $77
    jp   .vBlankDone                              ; $0255: $C3 $C3 $03


:   ldh  a, [hSBlocksRemaining]                   ; $0258: $F0 $C5
    ld   [hl], a                                  ; $025A: $77
    jp   .vBlankDone                              ; $025B: $C3 $C3 $03


.jr_000_025E:
    call Call_000_3029_DX                            ; $025E: $CD $29 $30
    ld   hl, $C827                                ; $0261: $21 $27 $98
    ld   de, wScore+6                             ; $0264: $11 $26 $C1
    ld   b, $07                                   ; $0267: $06 $07
    call MemCpyDEtoHLReverse                      ; $0269: $CD $AC $2D
    ld   hl, $C8EF                                ; $026C: $21 $EF $98
    ld   b, $04                                   ; $026F: $06 $04
    ld   de, hMinutes                             ; $0271: $11 $CE $FF
    call MemCpyDEtoHLReverse                      ; $0274: $CD $AC $2D
    ld   hl, $C950                         ; $0277: $21 $50 $99
    ld   b, $02                                   ; $027A: $06 $02
    call MemCpyDEtoHLReverse                      ; $027C: $CD $AC $2D
    ld   hl, $C9D1                         ; $027F: $21 $D1 $99
    ldh  a, [hSBlocksRemaining]                   ; $0282: $F0 $C5
    ld   [hl], a                                  ; $0284: $77
    jp   .vBlankDone                              ; $0285: $C3 $C3 $03

.jr_000_0288:
    ldh  a, [$FF97]                               ; $0288: $F0 $97
    cp   $01                                      ; $028A: $FE $01
    jp   z, .Jump_000_037B                        ; $028C: $CA $7B $03

    ldh  a, [$FFA0]                               ; $028F: $F0 $A0
    cp   $02                                      ; $0291: $FE $02
    jp   c, .Jump_000_0367                        ; $0293: $DA $67 $03

    jp   z, .Jump_000_033A                        ; $0296: $CA $3A $03

    cp   $04                                      ; $0299: $FE $04
    jr   c, .jr_000_02FE                          ; $029B: $38 $61

    jr   z, .jr_000_02D4                          ; $029D: $28 $35

    cp   $05                                      ; $029F: $FE $05
    jr   z, .jr_000_02A9                          ; $02A1: $28 $06

    call Call_000_3029_DX                            ; $02A3: $CD $29 $30
    jp   .vBlankDone                              ; $02A6: $C3 $C3 $03


.jr_000_02A9:
    ;ld   hl, $C8A1                                ; $02A9: $21 $A1 $98
    ;ld   de, SorryText                            ; $02AC: $11 $C6 $39
    ;ld   b, $0C                                   ; $02AF: $06 $0C
    ;call MemCpyDEtoHLShort                        ; $02B1: $CD $B6 $2D
    ;ld   hl, $C8C1                                ; $02B4: $21 $C1 $98
    ;ld   de, YouHaveText                          ; $02B7: $11 $D2 $39
    ;ld   b, $0C                                   ; $02BA: $06 $0C
    ;call MemCpyDEtoHLShort                        ; $02BC: $CD $B6 $2D
    ;ld   hl, $C8E1                                ; $02BF: $21 $E1 $98
    ;ld   de, NoNextMoveText                       ; $02C2: $11 $DE $39
    ;ld   b, $0C                                   ; $02C5: $06 $0C
    ;call MemCpyDEtoHLShort                        ; $02C7: $CD $B6 $2D
    ;ld   hl, $C9CB                                ; $02CA: $21 $CB $99
    ld   a, [$C00A]                               ; $02CD: $FA $0A $C0
    ld   [hl], a                                  ; $02D0: $77
    jp   .blankPalettesInPlayArea;.vBlankDone                              ; $02D1: $C3 $C3 $03


.jr_000_02D4:
    ;ld   hl, $C961                                ; $02D4: $21 $61 $99
    ;ld   de, ClearBonusText                       ; $02D7: $11 $AE $39
    ;ld   b, $0C                                   ; $02DA: $06 $0C
    ;call MemCpyDEtoHLShort                        ; $02DC: $CD $B6 $2D
    ;ld   hl, $C988                                ; $02DF: $21 $88 $99
    ;ld   de, $C113                                ; $02E2: $11 $13 $C1
    ;ld   b, $04                                   ; $02E5: $06 $04
    ;call MemCpyDEtoHLReverse                      ; $02E7: $CD $AC $2D
    ;ld   hl, $C827                                ; $02EA: $21 $27 $98
    ;ld   de, wScore+6                             ; $02ED: $11 $26 $C1
    ;ld   b, $07                                   ; $02F0: $06 $07
    ;call MemCpyDEtoHLReverse                      ; $02F2: $CD $AC $2D
    ;ld   hl, $C9D1;vSBlockCount                         ; $02F5: $21 $D1 $99
    ;ldh  a, [hSBlocksRemaining]                   ; $02F8: $F0 $C5
    ;ld   [hl], a                                  ; $02FA: $77
    ;jp   .blankPalettesInPlayArea;.vBlankDone                              ; $02FB: $C3 $C3 $03
    jp .vBlankDone


.jr_000_02FE:
    ;ldh  a, [$FFA6]                               ; $02FE: $F0 $A6
    ;bit  7, a                                     ; $0300: $CB $7F
    ;jp   nz, .vBlankDone                          ; $0302: $C2 $C3 $03

    ;ld   hl, $C921                                ; $0305: $21 $21 $99
    ;ld   de, TimeBonusText                        ; $0308: $11 $96 $39
    ;ld   b, $0C                                   ; $030B: $06 $0C
    ;call MemCpyDEtoHLShort                        ; $030D: $CD $B6 $2D
    ;ld   hl, $C941                                ; $0310: $21 $41 $99
    ;ld   de, X10Text                              ; $0313: $11 $A2 $39
    ;ld   b, $0C                                   ; $0316: $06 $0C
    ;call MemCpyDEtoHLShort                        ; $0318: $CD $B6 $2D
    ;ld   hl, $C827                                ; $031B: $21 $27 $98
    ;ld   de, wScore+6                             ; $031E: $11 $26 $C1
    ;ld   b, $07                                   ; $0321: $06 $07
    ;call MemCpyDEtoHLReverse                      ; $0323: $CD $AC $2D
    ;ld   hl, $C8EF                                ; $0326: $21 $EF $98
    ;ld   de, hMinutes                             ; $0329: $11 $CE $FF
    ;ld   b, $04                                   ; $032C: $06 $04
    ;call MemCpyDEtoHLReverse                      ; $032E: $CD $AC $2D
    ;ld   hl, $C9D1                         ; $0331: $21 $D1 $99
    ;ldh  a, [hSBlocksRemaining]                   ; $0334: $F0 $C5
    ;ld   [hl], a                                  ; $0336: $77
    ;jp   .blankPalettesInPlayArea;.vBlankDone                              ; $0337: $C3 $C3 $03
    jp .vBlankDone


.Jump_000_033A:
    ;ldh  a, [$FFA6]                               ; $033A: $F0 $A6
    ;bit  5, a                                     ; $033C: $CB $6F
    ;jr   z, .jr_000_0353                          ; $033E: $28 $13

    ;ld   hl, $C8E1                                ; $0340: $21 $E1 $98
    ;ld   de, PerfectText                          ; $0343: $11 $8A $39
    ;ld   b, $0C                                   ; $0346: $06 $0C
    ;call MemCpyDEtoHLShort                        ; $0348: $CD $B6 $2D
    ;ld   hl, $C9D1                         ; $034B: $21 $D1 $99
    ;ldh  a, [hSBlocksRemaining]                   ; $034E: $F0 $C5
    ;ld   [hl], a                                  ; $0350: $77
    ;jr   .jr_000_035E                             ; $0351: $18 $0B

;.jr_000_0353:
;    ld   hl, $C8E1                                ; $0353: $21 $E1 $98
;    ld   de, ClearText                            ; $0356: $11 $7E $39
;    ld   b, $0C                                   ; $0359: $06 $0C
;    call MemCpyDEtoHLShort                        ; $035B: $CD $B6 $2D
;
;.jr_000_035E:
;    ld   hl, $C9CB                                ; $035E: $21 $CB $99
;    ld   a, [$C00A]                               ; $0361: $FA $0A $C0
;    ld   [hl], a                                  ; $0364: $77
    jr   .vBlankDone                              ; $0365: $18 $5C

.Jump_000_0367:
    ;ld   hl, $C8E1                                ; $0367: $21 $E1 $98
    ;ld   de, TimeUpText                           ; $036A: $11 $BA $39
    ;ld   b, $0C                                   ; $036D: $06 $0C
    ;call MemCpyDEtoHLShort                        ; $036F: $CD $B6 $2D
    ;ld   hl, $C9CB                                ; $0372: $21 $CB $99
    ld   a, [$C00A]                               ; $0375: $FA $0A $C0
    ld   [hl], a                                  ; $0378: $77
    jr   .vBlankDone                              ; $0379: $18 $48

.Jump_000_037B:
    ldh  a, [$FFA0]                               ; $037B: $F0 $A0
    cp   $00                                      ; $037D: $FE $00
    jr   z, .vBlankDone                           ; $037F: $28 $42

    cp   $03                                      ; $0381: $FE $03
    jr   nc, .vBlankDone                          ; $0383: $30 $3E

    ldh  a, [$FFA8]                               ; $0385: $F0 $A8
    bit  4, a                                     ; $0387: $CB $67
    jr   z, .jr_000_039D                          ; $0389: $28 $12

    ld   hl, $FFD7                                ; $038B: $21 $D7 $FF
    ld   a, [hl+]                                 ; $038E: $2A
    ld   b, a                                     ; $038F: $47
    ld   a, [hl+]                                 ; $0390: $2A
    ld   e, a                                     ; $0391: $5F
    ld   a, [hl+]                                 ; $0392: $2A
    ld   d, a                                     ; $0393: $57
    ld   a, $2B                                   ; $0394: $3E $2B

:   ld   [de], a                                  ; $0396: $12
    inc  de                                       ; $0397: $13
    dec  b                                        ; $0398: $05
    jr   nz, :-                                   ; $0399: $20 $FB

    jr   .jr_000_03A0                             ; $039B: $18 $03

.jr_000_039D:
    call Call_000_3029_DX                            ; $039D: $CD $29 $30

.jr_000_03A0:
    ld   hl, $C8F0                    ; $03A0: $21 $F0 $98
    ld   de, hBlocksInitial+1                     ; $03A3: $11 $C1 $FF
    ld   b, $02                                   ; $03A6: $06 $02
    call MemCpyDEtoHLReverse                      ; $03A8: $CD $AC $2D
    ld   hl, $C950                         ; $03AB: $21 $50 $99
    ld   de, hBlocks+1                            ; $03AE: $11 $CA $FF
    ld   b, $02                                   ; $03B1: $06 $02
    call MemCpyDEtoHLReverse                      ; $03B3: $CD $AC $2D
    ld   hl, $C9D1                         ; $03B6: $21 $D1 $99
    ldh  a, [hSBlocksRemaining]                   ; $03B9: $F0 $C5
    ld   [hl], a                                  ; $03BB: $77
    ld   hl, $C9CB                                ; $03BC: $21 $CB $99
    ld   a, [$C00A]                               ; $03BF: $FA $0A $C0
    ld   [hl], a                                  ; $03C2: $77

.vBlankDone:
    ;xor a
    ;ldh [rIE], a
    ;ld   a, $01                                   ; $03C3: $3E $01
    ;ldh  [hVBlankDone], a                         ; $03C5: $E0 $91
    ;ldh [$FF4D], a
    ;ld a, $30
    ;ldh [rP1], a
    ;stop
    ;pop  hl                                       ; $03C7: $E1
    ;pop  de                                       ; $03C8: $D1
    ;pop  bc                                       ; $03C9: $C1
    ;pop  af                                       ; $03CA: $F1
    ;reti                                          ; $03CB: $D9
    ret


.Jump_000_03CC:
    jp   nz, .Jump_000_046C                       ; $03CC: $C2 $6C $04

    ldh  a, [$FF97]                               ; $03CF: $F0 $97
    cp   $00                                      ; $03D1: $FE $00
    jr   z, :+                                    ; $03D3: $28 $06

    ldh  a, [$FFA8]                               ; $03D5: $F0 $A8
    bit  3, a                                     ; $03D7: $CB $5F
    jr   z, :++                                   ; $03D9: $28 $48

;:   ld   hl, $C861                                ; $03DB: $21 $61 $98
;    ld   de, BlankText                            ; $03DE: $11 $66 $39
;    ld   b, $0A                                   ; $03E1: $06 $0A
;    call MemCpyDEtoHLShort                        ; $03E3: $CD $B6 $2D
;    ld   hl, $C881                                ; $03E6: $21 $81 $98
;    ld   de, PushText                             ; $03E9: $11 $2A $39
;    ld   b, $0A                                   ; $03EC: $06 $0A
;    call MemCpyDEtoHLShort                        ; $03EE: $CD $B6 $2D
;    ld   hl, $C8A1                                ; $03F1: $21 $A1 $98
;    ld   de, BlankText                            ; $03F4: $11 $66 $39
;    ld   b, $0A                                   ; $03F7: $06 $0A
;    call MemCpyDEtoHLShort                        ; $03F9: $CD $B6 $2D
;    ld   hl, $C8C1                                ; $03FC: $21 $C1 $98
;    ld   de, StartText                            ; $03FF: $11 $36 $39
;    ld   b, $0A                                   ; $0402: $06 $0A
;    call MemCpyDEtoHLShort                        ; $0404: $CD $B6 $2D
;    ld   hl, $C8E1                                ; $0407: $21 $E1 $98
;    ld   de, BlankText                            ; $040A: $11 $66 $39
;    ld   b, $0A                                   ; $040D: $06 $0A
;    call MemCpyDEtoHLShort                        ; $040F: $CD $B6 $2D
;    ld   hl, $C901                                ; $0412: $21 $01 $99
;    ld   de, ToText                               ; $0415: $11 $42 $39
;    ld   b, $0A                                   ; $0418: $06 $0A
;    call MemCpyDEtoHLShort                        ; $041A: $CD $B6 $2D
:
    ld   a, $08                                   ; $041D: $3E $08
    ldh  [$FF9D], a                               ; $041F: $E0 $9D
    jp   .blankPalettesInPlayArea;.vBlankDone                              ; $0421: $18 $A0

:
;:   ld   hl, $C861                                ; $0423: $21 $61 $98
;    ld   de, BlankText                            ; $0426: $11 $66 $39
;    ld   b, $0A                                   ; $0429: $06 $0A
;    call MemCpyDEtoHLShort                        ; $042B: $CD $B6 $2D
;    ld   hl, $C881                                ; $042E: $21 $81 $98
;    ld   de, BlankText                            ; $0431: $11 $66 $39
;    ld   b, $0A                                   ; $0434: $06 $0A
;    call MemCpyDEtoHLShort                        ; $0436: $CD $B6 $2D
;    ld   hl, $C8A1                                ; $0439: $21 $A1 $98
;    ld   de, BlankText                            ; $043C: $11 $66 $39
;    ld   b, $0A                                   ; $043F: $06 $0A
;    call MemCpyDEtoHLShort                        ; $0441: $CD $B6 $2D
;    ld   hl, $C8C1                                ; $0444: $21 $C1 $98
;    ld   de, BlankText                            ; $0447: $11 $66 $39
;    ld   b, $0A                                   ; $044A: $06 $0A
;    call MemCpyDEtoHLShort                        ; $044C: $CD $B6 $2D
;    ld   hl, $C8E1                                ; $044F: $21 $E1 $98
;    ld   de, BlankText                            ; $0452: $11 $66 $39
;    ld   b, $0A                                   ; $0455: $06 $0A
;    call MemCpyDEtoHLShort                        ; $0457: $CD $B6 $2D
;    ld   hl, $C901                                ; $045A: $21 $01 $99
;    ld   de, PauseText                            ; $045D: $11 $72 $39
;    ld   b, $0A                                   ; $0460: $06 $0A
;    call MemCpyDEtoHLShort                        ; $0462: $CD $B6 $2D
    ld   a, $08                                   ; $0465: $3E $08
    ldh  [$FF9D], a                               ; $0467: $E0 $9D
    jp   .blankPalettesInPlayArea;p   .vBlankDone                              ; $0469: $C3 $C3 $03


.Jump_000_046C:
    cp   $09                                      ; $046C: $FE $09
    jp   nc, .Jump_000_050F                       ; $046E: $D2 $0F $05

    ldh  a, [$FF97]                               ; $0471: $F0 $97
    cp   $00                                      ; $0473: $FE $00
    jr   z, .jr_000_047D                          ; $0475: $28 $06

    ldh  a, [$FFA8]                               ; $0477: $F0 $A8
    bit  3, a                                     ; $0479: $CB $5F
    jr   z, .jr_000_04C6                          ; $047B: $28 $49

.jr_000_047D:
;    ld   hl, $C921                                ; $047D: $21 $21 $99
;    ld   de, BlankText                            ; $0480: $11 $66 $39
;    ld   b, $0A                                   ; $0483: $06 $0A
;    call MemCpyDEtoHLShort                        ; $0485: $CD $B6 $2D
;    ld   hl, $C941                                ; $0488: $21 $41 $99
;    ld   de, ContinueText                         ; $048B: $11 $4E $39
;    ld   b, $0A                                   ; $048E: $06 $0A
;    call MemCpyDEtoHLShort                        ; $0490: $CD $B6 $2D
;    ld   hl, $C961                                ; $0493: $21 $61 $99
;    ld   de, BlankText                            ; $0496: $11 $66 $39
;    ld   b, $0A                                   ; $0499: $06 $0A
;    call MemCpyDEtoHLShort                        ; $049B: $CD $B6 $2D
;    ld   hl, $C981                                ; $049E: $21 $81 $99
;    ld   de, GameText                             ; $04A1: $11 $5A $39
;    ld   b, $0A                                   ; $04A4: $06 $0A
;    call MemCpyDEtoHLShort                        ; $04A6: $CD $B6 $2D
;    ld   hl, $C9A1                                ; $04A9: $21 $A1 $99
;    ld   de, BlankText                            ; $04AC: $11 $66 $39
;    ld   b, $0A                                   ; $04AF: $06 $0A
;    call MemCpyDEtoHLShort                        ; $04B1: $CD $B6 $2D
;    ld   hl, $C9C1                                ; $04B4: $21 $C1 $99
;    ld   de, BlankText                            ; $04B7: $11 $66 $39
;    ld   b, $0A                                   ; $04BA: $06 $0A
;    call MemCpyDEtoHLShort                        ; $04BC: $CD $B6 $2D
    ld   a, $07                                   ; $04BF: $3E $07
    ldh  [$FF9D], a                               ; $04C1: $E0 $9D
    jr   .blankPalettesInPlayArea; p   .vBlankDone                              ; $04C3: $C3 $C3 $03


.jr_000_04C6:
    ;ld   hl, $C921                                ; $04C6: $21 $21 $99
    ;ld   de, BlankText                            ; $04C9: $11 $66 $39
    ;ld   b, $0A                                   ; $04CC: $06 $0A
    ;call MemCpyDEtoHLShort                        ; $04CE: $CD $B6 $2D
    ;ld   hl, $C941                                ; $04D1: $21 $41 $99
    ;ld   de, BlankText                            ; $04D4: $11 $66 $39
    ;ld   b, $0A                                   ; $04D7: $06 $0A
    ;call MemCpyDEtoHLShort                        ; $04D9: $CD $B6 $2D
    ;ld   hl, $C961                                ; $04DC: $21 $61 $99
    ;ld   de, BlankText                            ; $04DF: $11 $66 $39
    ;ld   b, $0A                                   ; $04E2: $06 $0A
    ;call MemCpyDEtoHLShort                        ; $04E4: $CD $B6 $2D
    ;ld   hl, $C981                                ; $04E7: $21 $81 $99
    ;ld   de, BlankText                            ; $04EA: $11 $66 $39
    ;ld   b, $0A                                   ; $04ED: $06 $0A
    ;call MemCpyDEtoHLShort                        ; $04EF: $CD $B6 $2D
    ;ld   hl, $C9A1                                ; $04F2: $21 $A1 $99
    ;ld   de, BlankText                            ; $04F5: $11 $66 $39
    ;ld   b, $0A                                   ; $04F8: $06 $0A
    ;call MemCpyDEtoHLShort                        ; $04FA: $CD $B6 $2D
    ;ld   hl, $C9C1                                ; $04FD: $21 $C1 $99
    ;ld   de, BlankText                            ; $0500: $11 $66 $39
    ;ld   b, $0A                                   ; $0503: $06 $0A
    ;call MemCpyDEtoHLShort                        ; $0505: $CD $B6 $2D
    ;ld   a, $07                                   ; $0508: $3E $07
    ;ldh  [$FF9D], a                               ; $050A: $E0 $9D
    jp   .vBlankDone                  
    
.blankPalettesInPlayArea:
    ldh  a, [hIE2]
    cp   $11
    jp   nz, .vBlankDone

    ;ldh  [rVBK], a
    ;ld  [rCurrentVBK], a
    ld a, 3
    ldh  [rSVBK], a
    ld  [rCurrentSVBK], a

    ; TODO This is $FF in Japan
    ld a, $7F
    ldh [$FF51], a
    ld a, $00
    ldh [$FF52], a
    ld a, $D9
    ldh [$FF53], a
    ld a, $20
    ldh [$FF54], a
    ld a, 8
    ldh [$FF55], a

    xor  a
    ;ldh  [rVBK], a            ; $050C: $C3 $C3 $03
    ;ld  [rCurrentVBK], a
    ldh  [rSVBK], a
    ld  [rCurrentSVBK], a
    jp .vBlankDone


.Jump_000_050F:
    jr   nz, .jr_000_055A                         ; $050F: $20 $49

    ;ld   hl, $9861                                ; $0511: $21 $61 $98
    ;ld   de, $C861                                ; $0514: $11 $61 $C8
    ;ld   b, $07                                   ; $0517: $06 $07
    ;call DrawFromWRAM                             ; $0519: $CD $C2 $30
    ;ld   hl, $9881                                ; $051C: $21 $81 $98
    ;ld   de, $C881                                ; $051F: $11 $81 $C8
    ;ld   b, $0A                                   ; $0522: $06 $0A
    ;call DrawFromWRAM                             ; $0524: $CD $C2 $30
    ;ld   hl, $98A1                                ; $0527: $21 $A1 $98
    ;ld   de, $C8A1                                ; $052A: $11 $A1 $C8
    ;ld   b, $07                                   ; $052D: $06 $07
    ;call DrawFromWRAM                             ; $052F: $CD $C2 $30
    ;ld   hl, $98C1                                ; $0532: $21 $C1 $98
    ;ld   de, $C8C1                                ; $0535: $11 $C1 $C8
    ;ld   b, $0A                                   ; $0538: $06 $0A
    ;call DrawFromWRAM                             ; $053A: $CD $C2 $30
    ;ld   hl, $98E1                                ; $053D: $21 $E1 $98
    ;ld   de, $C8E1                                ; $0540: $11 $E1 $C8
    ;ld   b, $07                                   ; $0543: $06 $07
    ;call DrawFromWRAM                             ; $0545: $CD $C2 $30
    ;ld   hl, $9901                                ; $0548: $21 $01 $99
    ;ld   de, $C901                                ; $054B: $11 $01 $C9
    ;ld   b, $0A                                   ; $054E: $06 $0A
    ;call DrawFromWRAM                             ; $0550: $CD $C2 $30
    ld   a, $0A                                   ; $0553: $3E $0A
    ldh  [$FF9D], a                               ; $0555: $E0 $9D
    jp   .vBlankDone                              ; $0557: $C3 $C3 $03


.jr_000_055A:
    ;ld   hl, $9921                                ; $055A: $21 $21 $99
    ;ld   de, $C921                                ; $055D: $11 $21 $C9
    ;ld   b, $07                                   ; $0560: $06 $07
    ;call DrawFromWRAM                             ; $0562: $CD $C2 $30
    ;ld   hl, $9941                                ; $0565: $21 $41 $99
    ;ld   de, $C941                                ; $0568: $11 $41 $C9
    ;ld   b, $0A                                   ; $056B: $06 $0A
    ;call DrawFromWRAM                             ; $056D: $CD $C2 $30
    ;ld   hl, $9961                                ; $0570: $21 $61 $99
    ;ld   de, $C961                                ; $0573: $11 $61 $C9
    ;ld   b, $07                                   ; $0576: $06 $07
    ;call DrawFromWRAM                             ; $0578: $CD $C2 $30
    ;ld   hl, $9981                                ; $057B: $21 $81 $99
    ;ld   de, $C981                                ; $057E: $11 $81 $C9
    ;ld   b, $0A                                   ; $0581: $06 $0A
    ;call DrawFromWRAM                             ; $0583: $CD $C2 $30
    ;ld   hl, $99A1                                ; $0586: $21 $A1 $99
    ;ld   de, $C9A1                                ; $0589: $11 $A1 $C9
    ;ld   b, $07                                   ; $058C: $06 $07
    ;call DrawFromWRAM                             ; $058E: $CD $C2 $30
    ;ld   hl, $99C1                                ; $0591: $21 $C1 $99
    ;ld   de, $C9C1                                ; $0594: $11 $C1 $C9
    ;ld   b, $07                                   ; $0597: $06 $07
    ;call DrawFromWRAM                             ; $0599: $CD $C2 $30

    ;ldh  a, [hIE2]
    ;cp   $11
    ;jr   nz, .noGBC

    ;ldh  [rVBK], a

    ;ld a, $C9
    ;ldh [$FF51], a
    ;ld a, $20
    ;ldh [$FF52], a
    ;ld a, $99
    ;ldh [$FF53], a
    ;ld a, $20
    ;ldh [$FF54], a
    ;ld a, 8
    ;ldh [$FF55], a

    ;ld   hl, $9921                                ; $055A: $21 $21 $99
    ;ld   de, $C921                                ; $055D: $11 $21 $C9
    ;ld   b, $07                                   ; $0560: $06 $07
    ;call DrawPalFromWRAM                             ; $0562: $CD $C2 $30
    ;ld   hl, $9941                                ; $0565: $21 $41 $99
    ;ld   de, $C941                                ; $0568: $11 $41 $C9
    ;ld   b, $0A                                   ; $056B: $06 $0A
    ;call DrawPalFromWRAM                             ; $056D: $CD $C2 $30
    ;ld   hl, $9961                                ; $0570: $21 $61 $99
    ;ld   de, $C961                                ; $0573: $11 $61 $C9
    ;ld   b, $07                                   ; $0576: $06 $07
    ;call DrawPalFromWRAM                             ; $0578: $CD $C2 $30
    ;ld   hl, $9981                                ; $057B: $21 $81 $99
    ;ld   de, $C981                                ; $057E: $11 $81 $C9
    ;ld   b, $0A                                   ; $0581: $06 $0A
    ;call DrawPalFromWRAM                             ; $0583: $CD $C2 $30
    ;ld   hl, $99A1                                ; $0586: $21 $A1 $99
    ;ld   de, $C9A1                                ; $0589: $11 $A1 $C9
    ;ld   b, $07                                   ; $058C: $06 $07
    ;call DrawPalFromWRAM                             ; $058E: $CD $C2 $30
    ;ld   hl, $99C1                                ; $0591: $21 $C1 $99
    ;ld   de, $C9C1                                ; $0594: $11 $C1 $C9
    ;ld   b, $07                                   ; $0597: $06 $07
    ;call DrawPalFromWRAM                             ; $0599: $CD $C2 $30

    ;xor  a
    ;ldh  [rVBK], a

.noGBC:
    ld   a, $09                                   ; $059C: $3E $09
    ldh  [$FF9D], a                               ; $059E: $E0 $9D
    jp   .vBlankDone                              ; $05A0: $C3 $C3 $03
; End of VBlankInterruptHandler








Call_000_3029_DX:
    ;call Call_000_3029_PAL_DX

    ldh  a, [$FF97]                               ; $3029: $F0 $97
    cp   $00                                      ; $302B: $FE $00
    jr   nz, .jr_000_3050                          ; $302D: $20 $21

;    ld   hl, $9921                                ; $302F: $21 $21 $99
;    ld   de, $C921                                ; $3032: $11 $21 $C9
;    ld   c, $06                                   ; $3035: $0E $06
;
;.nextRow:
;    ld   b, $06                                   ; $3037: $06 $06
;
;.rowLoop:
;    ld   a, [de]                                  ; $3039: $1A
;    cp   $00                                      ; $303A: $FE $00
;    jr   nz, .nextBlock                           ; $303C: $20 $02
;
;    ld   a, $24                                   ; $303E: $3E $24
;
;.nextBlock:
;    ld   [hl+], a                                 ; $3040: $22
;    inc  de                                       ; $3041: $13
;    dec  b                                        ; $3042: $05
;    jr   nz, .rowLoop                             ; $3043: $20 $F4
;
;    dec  c                                        ; $3045: $0D
    ret  z                                        ; $3046: $C8

;    ld   a, l                                     ; $3047: $7D
;    and  $F0                                      ; $3048: $E6 $F0
;    add  $21                                      ; $304A: $C6 $21
;    ld   l, a                                     ; $304C: $6F
;    ld   e, a                                     ; $304D: $5F
;    jr   .nextRow                                 ; $304E: $18 $E7

.jr_000_3050:
    ldh  a, [$FF9C]                               ; $3050: $F0 $9C
    cp   $00                                      ; $3052: $FE $00
    jr   nz, .jr_000_307B                          ; $3054: $20 $25

    ld   a, $01                                   ; $3056: $3E $01
    ldh  [$FF9C], a                               ; $3058: $E0 $9C
;    ld   hl, $9941                                ; $305A: $21 $41 $99
;    ld   de, $C941                                ; $305D: $11 $41 $C9
;    ld   c, $05                                   ; $3060: $0E $05
;
;.jr_000_3062:
;    ld   b, $08                                   ; $3062: $06 $08
;
;.jr_000_3064:
;    ld   a, [de]                                  ; $3064: $1A
;    cp   $00                                      ; $3065: $FE $00
;    jr   nz, .jr_000_306B                          ; $3067: $20 $02
;
;    ld   a, $24                                   ; $3069: $3E $24
;
;.jr_000_306B:
;    ld   [hl+], a                                 ; $306B: $22
;    inc  de                                       ; $306C: $13
;    dec  b                                        ; $306D: $05
;    jr   nz, .jr_000_3064                          ; $306E: $20 $F4
;
;    dec  c                                        ; $3070: $0D
    ret  z                                        ; $3071: $C8

;    ld   a, l                                     ; $3072: $7D
;    and  $F0                                      ; $3073: $E6 $F0
;    add  $21                                      ; $3075: $C6 $21
;    ld   l, a                                     ; $3077: $6F
;    ld   e, a                                     ; $3078: $5F
;    jr   .jr_000_3062                              ; $3079: $18 $E7

.jr_000_307B:
    ld   a, $00                                   ; $307B: $3E $00
    ldh  [$FF9C], a                               ; $307D: $E0 $9C
;    ld   hl, $9861                                ; $307F: $21 $61 $98
;    ld   de, $C861                                ; $3082: $11 $61 $C8
;    ld   c, $05                                   ; $3085: $0E $05
;
;.jr_000_3087:
;    ld   b, $06                                   ; $3087: $06 $06
;
;.jr_000_3089:
;    ld   a, [de]                                  ; $3089: $1A
;    cp   $00                                      ; $308A: $FE $00
;    jr   nz, .jr_000_3090                          ; $308C: $20 $02
;
;    ld   a, $24                                   ; $308E: $3E $24
;
;.jr_000_3090:
;    ld   [hl+], a                                 ; $3090: $22
;    inc  de                                       ; $3091: $13
;    dec  b                                        ; $3092: $05
;    jr   nz, .jr_000_3089                          ; $3093: $20 $F4
;
;    dec  c                                        ; $3095: $0D
;    jr   z, :+                                    ; $3096: $28 $09
;
;    ld   a, l                                     ; $3098: $7D
;    and  $F0                                      ; $3099: $E6 $F0
;    add  $21                                      ; $309B: $C6 $21
;    ld   l, a                                     ; $309D: $6F
;    ld   e, a                                     ; $309E: $5F
;    jr   .jr_000_3087                              ; $309F: $18 $E6

;:   ld   hl, $9901                                ; $30A1: $21 $01 $99
;    ld   de, $C901                                ; $30A4: $11 $01 $C9
;    ld   c, $02                                   ; $30A7: $0E $02
;
;:   ld   b, $06                                   ; $30A9: $06 $06
;
;:   ld   a, [de]                                  ; $30AB: $1A
;    cp   $00                                      ; $30AC: $FE $00
;    jr   nz, :+                                   ; $30AE: $20 $02
;
;    ld   a, " "                                   ; $30B0: $3E $24
;
;:   ld   [hl+], a                                 ; $30B2: $22
;    inc  de                                       ; $30B3: $13
;    dec  b                                        ; $30B4: $05
;    jr   nz, :--                                  ; $30B5: $20 $F4
;
;    dec  c                                        ; $30B7: $0D
    ret  z                                        ; $30B8: $C8
;
;    ld   a, l                                     ; $30B9: $7D
;    and  $F0                                      ; $30BA: $E6 $F0
;    add  $21                                      ; $30BC: $C6 $21
;    ld   l, a                                     ; $30BE: $6F
;    ld   e, a                                     ; $30BF: $5F
;    jr   :---                                     ; $30C0: $18 $E7








Call_000_3029_PAL_DX:
    ld a, 3
    ld [rSVBK], a
    ld [rCurrentSVBK], a

    ldh  a, [$FF97]                               ; $3029: $F0 $97
    cp   $00                                      ; $302B: $FE $00
    
    jr   nz, .jr_000_3050                          ; $302D: $20 $21

    ld   hl, $D921                                ; $302F: $21 $21 $99
    ld   de, $C921                                ; $3032: $11 $21 $C9
    ld   c, $06                                   ; $3035: $0E $06

.nextRow:
    ld   b, $06                                   ; $3037: $06 $06

.rowLoop:
    ld   a, [de]                                  ; $3039: $1A
    and a, 7

.nextBlock:
    ld   [hl+], a                                 ; $3040: $22
    inc  de                                       ; $3041: $13
    dec  b                                        ; $3042: $05
    jr   nz, .rowLoop                             ; $3043: $20 $F4

    dec  c                                        ; $3045: $0D
    jr  z, .return                                        ; $3046: $C8

    ld   a, l                                     ; $3047: $7D
    and  $F0                                      ; $3048: $E6 $F0
    add  $21                                      ; $304A: $C6 $21
    ld   l, a                                     ; $304C: $6F
    ld   e, a                                     ; $304D: $5F
    jr   .nextRow                                 ; $304E: $18 $E7

.jr_000_3050:
    ldh  a, [$FF9C]                               ; $3050: $F0 $9C
    cp   $00                                      ; $3052: $FE $00
    jr   nz, .jr_000_307B                          ; $3054: $20 $25

    ;ld   a, $01                                   ; $3056: $3E $01
    ;ldh  [$FF9C], a                               ; $3058: $E0 $9C
    ld   hl, $D941                                ; $305A: $21 $41 $99
    ld   de, $C941                                ; $305D: $11 $41 $C9
    ld   c, $05                                   ; $3060: $0E $05

.jr_000_3062:
    ld   b, $08                                   ; $3062: $06 $08

.jr_000_3064:
    ld   a, [de]                                  ; $3064: $1A
    and a, 7

.jr_000_306B:
    ld   [hl+], a                                 ; $306B: $22
    inc  de                                       ; $306C: $13
    dec  b                                        ; $306D: $05
    jr   nz, .jr_000_3064                          ; $306E: $20 $F4

    dec  c                                        ; $3070: $0D
    jr z, .return                                        ; $3071: $C8

    ld   a, l                                     ; $3072: $7D
    and  $F0                                      ; $3073: $E6 $F0
    add  $21                                      ; $3075: $C6 $21
    ld   l, a                                     ; $3077: $6F
    ld   e, a                                     ; $3078: $5F
    jr   .jr_000_3062                              ; $3079: $18 $E7

.jr_000_307B:
    ;ld   a, $00                                   ; $307B: $3E $00
    ;ldh  [$FF9C], a                               ; $307D: $E0 $9C
    ld   hl, $D861                                ; $307F: $21 $61 $98
    ld   de, $C861                                ; $3082: $11 $61 $C8
    ld   c, $05                                   ; $3085: $0E $05

.jr_000_3087:
    ld   b, $06                                   ; $3087: $06 $06

.jr_000_3089:
    ld   a, [de]                                  ; $3089: $1A
    and a, 7

.jr_000_3090:
    ld   [hl+], a                                 ; $3090: $22
    inc  de                                       ; $3091: $13
    dec  b                                        ; $3092: $05
    jr   nz, .jr_000_3089                          ; $3093: $20 $F4

    dec  c                                        ; $3095: $0D
    jr   z, :+                                    ; $3096: $28 $09

    ld   a, l                                     ; $3098: $7D
    and  $F0                                      ; $3099: $E6 $F0
    add  $21                                      ; $309B: $C6 $21
    ld   l, a                                     ; $309D: $6F
    ld   e, a                                     ; $309E: $5F
    jr   .jr_000_3087                              ; $309F: $18 $E6

:   ld   hl, $D901                                ; $30A1: $21 $01 $99
    ld   de, $C901                                ; $30A4: $11 $01 $C9
    ld   c, $02                                   ; $30A7: $0E $02

:   ld   b, $06                                   ; $30A9: $06 $06

:   ld   a, [de]                                  ; $30AB: $1A
    and a, 7

:   ld   [hl+], a                                 ; $30B2: $22
    inc  de                                       ; $30B3: $13
    dec  b                                        ; $30B4: $05
    jr   nz, :--                                  ; $30B5: $20 $F4

    dec  c                                        ; $30B7: $0D
    jr z, .return                                        ; $30B8: $C8

    ld   a, l                                     ; $30B9: $7D
    and  $F0                                      ; $30BA: $E6 $F0
    add  $21                                      ; $30BC: $C6 $21
    ld   l, a                                     ; $30BE: $6F
    ld   e, a                                     ; $30BF: $5F
    jr   :---                                     ; $30C0: $18 $E7

.return:
    xor a
    ld [rSVBK], a
    ld  [rCurrentSVBK], a
    ret