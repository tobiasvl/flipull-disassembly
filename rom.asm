SECTION "RST 00 Vector", ROM0[$0000]
RST_00::
    jp   JumpTable                                ; $0000: $C3 $9E $2C


SECTION "VBlank Interrupt Vector", ROM0[$0040]
VBlankInterrupt::
    jp   VBlankInterruptHandler                   ; $0040: $C3 $FF $01


SECTION "LCDC Interrupt Vector", ROM0[$0048]
LCDCInterrupt::
    reti                                          ; $0048: $D9


SECTION "Timer Overflow Interrupt Vector", ROM0[$0050]
TimerOverflowInterrupt::
    jp   TimerInterruptHandler                    ; $0050: $C3 $A3 $05


SECTION "Serial Transfer Interrupt Vector", ROM0[$0058]
SerialTransferCompleteInterrupt::
    jp   SerialInterruptHandler                   ; $0058: $C3 $80 $07


SECTION "Joypad Transition Interrupt Vector", ROM0[$0060]
JoypadTransitionInterrupt::
    reti                                          ; $0060: $D9


SECTION "Boot Entry Point", ROM0[$0100]
Boot::
    nop                                           ; $0100: $00
    jp   Init                                     ; $0101: $C3 $50 $01


SECTION "Header", ROM0[$0104]
    NINTENDO_LOGO

HeaderTitle::
    DB   "FLIPULL", $00, $00, $00, $00, $00, $00, $00, $00

    DB   CART_COMPATIBLE_DMG

    ; 0144: New licensee code
    DB   $00, $00

    DB   CART_INDICATOR_GB       
    DB   CART_ROM
    DB   CART_ROM_32KB
    DB   CART_SRAM_NONE

IF "{REGION}" == "JP"
    DB   CART_DEST_JAPANESE 
ELSE
    DB   CART_DEST_NON_JAPANESE 
ENDC

    ; 014B: Old licensee code
    DB   $C0 ; Taito

    DB   $00

    ; 014D: Checksums, these will be set by RGBFIX
    DB   $0E
    DB   $8A, $B0

SETCHARMAP Text

Init::
    call LCDOff                                   ; $0150: $CD $AA $2C
    ld   sp, wStack                               ; $0153: $31 $FF $CF
    call SetUpDMA                                 ; $0156: $CD $33 $2C
    ld   hl, Tiles                                ; $0159: $21 $CE $3A
    ld   de, _VRAM                                ; $015C: $11 $00 $80
    ld   bc, _SCRN0 - _VRAM                       ; $015F: $01 $00 $18
    call MemCpyHLtoDE                             ; $0162: $CD $D9 $2C
    call ClearScreen                              ; $0165: $CD $CA $2C
    ld   de, TitleScreenDrawCommands              ; $0168: $11 $3D $33
    call ExecuteDrawCommands.getNextDrawCommand   ; $016B: $CD $EC $2C
    ld   hl, $FF97                                ; $016E: $21 $97 $FF
    ld   bc, $0075                                ; $0171: $01 $75 $00
    call MemClear                                 ; $0174: $CD $C1 $2C
    ld   hl, _RAM                                 ; $0177: $21 $00 $C0
    ld   bc, $0C00                                ; $017A: $01 $00 $0C
    call MemClear                                 ; $017D: $CD $C1 $2C
    call InitNewGame                              ; $0180: $CD $41 $2D
    ld   a, $01                                   ; $0183: $3E $01
    ldh  [$FFAE], a                               ; $0185: $E0 $AE
    ld   hl, $C9E0                                ; $0187: $21 $E0 $C9
    ld   a, $80                                   ; $018A: $3E $80
    ld   b, $10                                   ; $018C: $06 $10

:   ld   [hl+], a                                 ; $018E: $22
    dec  b                                        ; $018F: $05
    jr   nz, :-                                   ; $0190: $20 $FC

    ld   hl, $C840                                ; $0192: $21 $40 $C8
    ld   a, $80                                   ; $0195: $3E $80
    ld   b, $10                                   ; $0197: $06 $10

:   ld   [hl+], a                                 ; $0199: $22
    dec  b                                        ; $019A: $05
    jr   nz, :-                                   ; $019B: $20 $FC

    ld   hl, BlockSeed                            ; $019D: $21 $EA $39
    ld   de, wBlockRNG                            ; $01A0: $11 $00 $CA
    ld   bc, $0024                                ; $01A3: $01 $24 $00
    call MemCpyHLtoDE                             ; $01A6: $CD $D9 $2C
    ld   hl, vTitleScreenHiScore                  ; $01A9: $21 $49 $99
    ld   de, wHiScore+6                           ; $01AC: $11 $36 $C1
    ld   b, $07                                   ; $01AF: $06 $07
    call MemCpyDEtoHLReverse                      ; $01B1: $CD $AC $2D
    ld   b, $04                                   ; $01B4: $06 $04
    ld   de, ArrowLeftSelectionOAM                ; $01B6: $11 $CE $52
    call MemCpyDEtoWRAM                           ; $01B9: $CD $B3 $2D
    ld   a, $E4                                   ; $01BC: $3E $E4
    ldh  [rBGP], a                                ; $01BE: $E0 $47
    ldh  [rOBP0], a                               ; $01C0: $E0 $48
    ldh  [rOBP1], a                               ; $01C2: $E0 $49
    ld   a, $0D                                   ; $01C4: $3E $0D
    ldh  [rIE], a                                 ; $01C6: $E0 $FF
    ldh  [hIE], a                                 ; $01C8: $E0 $93
    ld   a, $83                                   ; $01CA: $3E $83
    ldh  [rLCDC], a                               ; $01CC: $E0 $40
    ld   a, $40                                   ; $01CE: $3E $40
    ldh  [hCounter], a                            ; $01D0: $E0 $B0
    ld   a, $9C                                   ; $01D2: $3E $9C
    ldh  [hCounter+1], a                          ; $01D4: $E0 $B1
    ld   a, $9A                                   ; $01D6: $3E $9A
    ldh  [$FFB4], a                               ; $01D8: $E0 $B4
    ldh  [$FFB6], a                               ; $01DA: $E0 $B6
    ld   a, $02                                   ; $01DC: $3E $02
    ldh  [$FFB5], a                               ; $01DE: $E0 $B5
    ldh  [$FFB7], a                               ; $01E0: $E0 $B7
    call SerialTransferHandler                    ; $01E2: $CD $25 $31
    ld   a, $01                                   ; $01E5: $3E $01
    ldh  [rTAC], a                                ; $01E7: $E0 $07
    ld   a, $05                                   ; $01E9: $3E $05
    ldh  [rTAC], a                                ; $01EB: $E0 $07
    ei                                            ; $01ED: $FB

:   call ReadJoypad                               ; $01EE: $CD $FC $2B
    call ShuffleBlockRNG                          ; $01F1: $CD $8E $07
    halt                                          ; $01F4: $76

:   ldh  a, [hVBlankDone]                         ; $01F5: $F0 $91
    and  a                                        ; $01F7: $A7
    jr   z, :-                                    ; $01F8: $28 $FB

    xor  a                                        ; $01FA: $AF
    ldh  [hVBlankDone], a                         ; $01FB: $E0 $91
    jr   :--                                      ; $01FD: $18 $EF

VBlankInterruptHandler::
    push af                                       ; $01FF: $F5
    push bc                                       ; $0200: $C5
    push de                                       ; $0201: $D5
    push hl                                       ; $0202: $E5
    call DMARoutine                               ; $0203: $CD $80 $FF
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

    call Call_000_3029                            ; $021C: $CD $29 $30
    ld   hl, vEnemyBlocksCount                    ; $021F: $21 $F0 $98
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

:   ld   hl, vBlocksCount                         ; $023A: $21 $50 $99
    ld   de, hBlocks+1                            ; $023D: $11 $CA $FF
    ld   b, $02                                   ; $0240: $06 $02
    call MemCpyDEtoHLReverse                      ; $0242: $CD $AC $2D
    ld   hl, vSBlockCount                         ; $0245: $21 $D1 $99
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
    call Call_000_3029                            ; $025E: $CD $29 $30
    ld   hl, $9827                                ; $0261: $21 $27 $98
    ld   de, wScore+6                             ; $0264: $11 $26 $C1
    ld   b, $07                                   ; $0267: $06 $07
    call MemCpyDEtoHLReverse                      ; $0269: $CD $AC $2D
    ld   hl, $98EF                                ; $026C: $21 $EF $98
    ld   b, $04                                   ; $026F: $06 $04
    ld   de, hMinutes                             ; $0271: $11 $CE $FF
    call MemCpyDEtoHLReverse                      ; $0274: $CD $AC $2D
    ld   hl, vBlocksCount                         ; $0277: $21 $50 $99
    ld   b, $02                                   ; $027A: $06 $02
    call MemCpyDEtoHLReverse                      ; $027C: $CD $AC $2D
    ld   hl, vSBlockCount                         ; $027F: $21 $D1 $99
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

    call Call_000_3029                            ; $02A3: $CD $29 $30
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
    ld   a, [$C00A]                               ; $02CD: $FA $0A $C0
    ld   [hl], a                                  ; $02D0: $77
    jp   .vBlankDone                              ; $02D1: $C3 $C3 $03


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
    ld   hl, vSBlockCount                         ; $02F5: $21 $D1 $99
    ldh  a, [hSBlocksRemaining]                   ; $02F8: $F0 $C5
    ld   [hl], a                                  ; $02FA: $77
    jp   .vBlankDone                              ; $02FB: $C3 $C3 $03


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
    ld   hl, vSBlockCount                         ; $0331: $21 $D1 $99
    ldh  a, [hSBlocksRemaining]                   ; $0334: $F0 $C5
    ld   [hl], a                                  ; $0336: $77
    jp   .vBlankDone                              ; $0337: $C3 $C3 $03


.Jump_000_033A:
    ldh  a, [$FFA6]                               ; $033A: $F0 $A6
    bit  5, a                                     ; $033C: $CB $6F
    jr   z, .jr_000_0353                          ; $033E: $28 $13

    ld   hl, $98E1                                ; $0340: $21 $E1 $98
    ld   de, PerfectText                          ; $0343: $11 $8A $39
    ld   b, $0C                                   ; $0346: $06 $0C
    call MemCpyDEtoHLShort                        ; $0348: $CD $B6 $2D
    ld   hl, vSBlockCount                         ; $034B: $21 $D1 $99
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
    call Call_000_3029                            ; $039D: $CD $29 $30

.jr_000_03A0:
    ld   hl, vEnemyBlocksCount                    ; $03A0: $21 $F0 $98
    ld   de, hBlocksInitial+1                     ; $03A3: $11 $C1 $FF
    ld   b, $02                                   ; $03A6: $06 $02
    call MemCpyDEtoHLReverse                      ; $03A8: $CD $AC $2D
    ld   hl, vBlocksCount                         ; $03AB: $21 $50 $99
    ld   de, hBlocks+1                            ; $03AE: $11 $CA $FF
    ld   b, $02                                   ; $03B1: $06 $02
    call MemCpyDEtoHLReverse                      ; $03B3: $CD $AC $2D
    ld   hl, vSBlockCount                         ; $03B6: $21 $D1 $99
    ldh  a, [hSBlocksRemaining]                   ; $03B9: $F0 $C5
    ld   [hl], a                                  ; $03BB: $77
    ld   hl, $99CB                                ; $03BC: $21 $CB $99
    ld   a, [$C00A]                               ; $03BF: $FA $0A $C0
    ld   [hl], a                                  ; $03C2: $77

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
    ld   a, $08                                   ; $041D: $3E $08
    ldh  [$FF9D], a                               ; $041F: $E0 $9D
    jr   .vBlankDone                              ; $0421: $18 $A0

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
    ld   a, $08                                   ; $0465: $3E $08
    ldh  [$FF9D], a                               ; $0467: $E0 $9D
    jp   .vBlankDone                              ; $0469: $C3 $C3 $03


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
    ld   a, $07                                   ; $04BF: $3E $07
    ldh  [$FF9D], a                               ; $04C1: $E0 $9D
    jp   .vBlankDone                              ; $04C3: $C3 $C3 $03


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
    ld   a, $07                                   ; $0508: $3E $07
    ldh  [$FF9D], a                               ; $050A: $E0 $9D
    jp   .vBlankDone                              ; $050C: $C3 $C3 $03


.Jump_000_050F:
    jr   nz, .jr_000_055A                         ; $050F: $20 $49

    ; Redraw upper play area (blocks/pipes) after pause
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
    ld   a, $0A                                   ; $0553: $3E $0A
    ldh  [$FF9D], a                               ; $0555: $E0 $9D
    jp   .vBlankDone                              ; $0557: $C3 $C3 $03


.jr_000_055A:
    ; Redraw lower play area after pause
    ld   hl, $9921                                ; $055A: $21 $21 $99
    ld   de, $C921                                ; $055D: $11 $21 $C9
    ld   b, $07                                   ; $0560: $06 $07
    call DrawFromWRAM                             ; $0562: $CD $C2 $30
    ld   hl, $9941                                ; $0565: $21 $41 $99
    ld   de, $C941                                ; $0568: $11 $41 $C9
    ld   b, $0A                                   ; $056B: $06 $0A
    call DrawFromWRAM                             ; $056D: $CD $C2 $30
    ld   hl, $9961                                ; $0570: $21 $61 $99
    ld   de, $C961                                ; $0573: $11 $61 $C9
    ld   b, $07                                   ; $0576: $06 $07
    call DrawFromWRAM                             ; $0578: $CD $C2 $30
    ld   hl, $9981                                ; $057B: $21 $81 $99
    ld   de, $C981                                ; $057E: $11 $81 $C9
    ld   b, $0A                                   ; $0581: $06 $0A
    call DrawFromWRAM                             ; $0583: $CD $C2 $30
    ld   hl, $99A1                                ; $0586: $21 $A1 $99
    ld   de, $C9A1                                ; $0589: $11 $A1 $C9
    ld   b, $07                                   ; $058C: $06 $07
    call DrawFromWRAM                             ; $058E: $CD $C2 $30
    ld   hl, $99C1                                ; $0591: $21 $C1 $99
    ld   de, $C9C1                                ; $0594: $11 $C1 $C9
    ld   b, $07                                   ; $0597: $06 $07
    call DrawFromWRAM                             ; $0599: $CD $C2 $30
    ld   a, $09                                   ; $059C: $3E $09
    ldh  [$FF9D], a                               ; $059E: $E0 $9D
    jp   .vBlankDone                              ; $05A0: $C3 $C3 $03
; End of VBlankInterruptHandler


TimerInterruptHandler::
    push af                                       ; $05A3: $F5
    push bc                                       ; $05A4: $C5
    push de                                       ; $05A5: $D5
    push hl                                       ; $05A6: $E5
    ldh  a, [$FFE2]                               ; $05A7: $F0 $E2
    ld   h, a                                     ; $05A9: $67
    cp   $00                                      ; $05AA: $FE $00
    jr   z, :+                                    ; $05AC: $28 $04

    ldh  a, [$FFE1]                               ; $05AE: $F0 $E1
    jr   :++                                      ; $05B0: $18 $06

:   ldh  a, [$FFE1]                               ; $05B2: $F0 $E1
    cp   $00                                      ; $05B4: $FE $00
    jr   z, .jr_000_0610                          ; $05B6: $28 $58

:   ld   l, a                                     ; $05B8: $6F
    ldh  a, [$FFE3]                               ; $05B9: $F0 $E3
    cp   $00                                      ; $05BB: $FE $00
    jr   z, :+                                    ; $05BD: $28 $07

    dec  a                                        ; $05BF: $3D
    ldh  [$FFE3], a                               ; $05C0: $E0 $E3
    cp   $00                                      ; $05C2: $FE $00
    jr   nz, .jr_000_0610                         ; $05C4: $20 $4A

:   ldh  a, [$FFE4]                               ; $05C6: $F0 $E4
    ldh  [$FFE3], a                               ; $05C8: $E0 $E3

.jr_000_05CA:
    ld   a, [hl+]                                 ; $05CA: $2A
    cp   $FF                                      ; $05CB: $FE $FF
    jr   nz, :+                                   ; $05CD: $20 $08

    ld   a, $00                                   ; $05CF: $3E $00
    ldh  [$FFE2], a                               ; $05D1: $E0 $E2
    ldh  [$FFE1], a                               ; $05D3: $E0 $E1
    jr   .jr_000_0610                             ; $05D5: $18 $39

:   cp   $FE                                      ; $05D7: $FE $FE
    jr   nz, :+                                   ; $05D9: $20 $0B

.jr_000_05DB:
    ld   a, [hl+]                                 ; $05DB: $2A
    ld   b, a                                     ; $05DC: $47
    ldh  [$FFE1], a                               ; $05DD: $E0 $E1
    ld   a, [hl]                                  ; $05DF: $7E
    ldh  [$FFE2], a                               ; $05E0: $E0 $E2
    ld   h, a                                     ; $05E2: $67
    ld   l, b                                     ; $05E3: $68
    jr   .jr_000_05CA                             ; $05E4: $18 $E4

:   cp   $FD                                      ; $05E6: $FE $FD
    jr   nz, :+                                   ; $05E8: $20 $05

    ld   a, [hl+]                                 ; $05EA: $2A
    ldh  [$FFE4], a                               ; $05EB: $E0 $E4
    jr   .jr_000_05CA                             ; $05ED: $18 $DB

:   cp   $FC                                      ; $05EF: $FE $FC
    jr   nz, :+                                   ; $05F1: $20 $05

    pop  hl                                       ; $05F3: $E1
    inc  hl                                       ; $05F4: $23
    inc  hl                                       ; $05F5: $23
    jr   .jr_000_05CA                             ; $05F6: $18 $D2

:   cp   $FB                                      ; $05F8: $FE $FB
    jr   nz, :+                                   ; $05FA: $20 $03

    push hl                                       ; $05FC: $E5
    jr   .jr_000_05DB                             ; $05FD: $18 $DC

:   cp   $F0                                      ; $05FF: $FE $F0
    jr   nz, :+                                   ; $0601: $20 $08

    ld   a, h                                     ; $0603: $7C
    ldh  [$FFE2], a                               ; $0604: $E0 $E2
    ld   a, l                                     ; $0606: $7D
    ldh  [$FFE1], a                               ; $0607: $E0 $E1
    jr   .jr_000_0610                             ; $0609: $18 $05

:   ld   c, a                                     ; $060B: $4F
    ld   a, [hl+]                                 ; $060C: $2A
    ldh  [c], a                                   ; $060D: $E2
    jr   .jr_000_05CA                             ; $060E: $18 $BA

.jr_000_0610:
    ldh  a, [hMusic+1]                            ; $0610: $F0 $DE
    ld   h, a                                     ; $0612: $67
    cp   $00                                      ; $0613: $FE $00
    jr   z, :+                                    ; $0615: $28 $04

    ldh  a, [hMusic]                              ; $0617: $F0 $DD
    jr   :++                                      ; $0619: $18 $06

:   ldh  a, [hMusic]                              ; $061B: $F0 $DD
    cp   $00                                      ; $061D: $FE $00
    jr   z, .jr_000_0689                          ; $061F: $28 $68

:   ld   l, a                                     ; $0621: $6F
    ldh  a, [hMusic+2]                            ; $0622: $F0 $DF
    cp   $00                                      ; $0624: $FE $00
    jr   z, :+                                    ; $0626: $28 $07

    dec  a                                        ; $0628: $3D
    ldh  [hMusic+2], a                            ; $0629: $E0 $DF
    cp   $00                                      ; $062B: $FE $00
    jr   nz, .jr_000_0689                         ; $062D: $20 $5A

:   ldh  a, [hMusicSpeed]                         ; $062F: $F0 $E0
    ldh  [hMusic+2], a                            ; $0631: $E0 $DF

.jr_000_0633:
    ld   a, [hl+]                                 ; $0633: $2A
    cp   $FF                                      ; $0634: $FE $FF
    jr   nz, :+                                   ; $0636: $20 $08

    ld   a, $00                                   ; $0638: $3E $00
    ldh  [hMusic+1], a                            ; $063A: $E0 $DE
    ldh  [hMusic], a                              ; $063C: $E0 $DD
    jr   .jr_000_0689                             ; $063E: $18 $49

:   cp   $FE                                      ; $0640: $FE $FE
    jr   nz, :+                                   ; $0642: $20 $0B

.jr_000_0644:
    ld   a, [hl+]                                 ; $0644: $2A
    ld   b, a                                     ; $0645: $47
    ldh  [hMusic], a                              ; $0646: $E0 $DD
    ld   a, [hl]                                  ; $0648: $7E
    ldh  [hMusic+1], a                            ; $0649: $E0 $DE
    ld   h, a                                     ; $064B: $67
    ld   l, b                                     ; $064C: $68
    jr   .jr_000_0633                             ; $064D: $18 $E4

:   cp   $FD                                      ; $064F: $FE $FD
    jr   nz, :+                                   ; $0651: $20 $05

    ld   a, [hl+]                                 ; $0653: $2A
    ldh  [hMusicSpeed], a                         ; $0654: $E0 $E0
    jr   .jr_000_0633                             ; $0656: $18 $DB

:   cp   $FC                                      ; $0658: $FE $FC
    jr   nz, :+                                   ; $065A: $20 $05

    pop  hl                                       ; $065C: $E1
    inc  hl                                       ; $065D: $23

.jr_000_065E:
    inc  hl                                       ; $065E: $23
    jr   .jr_000_0633                             ; $065F: $18 $D2

:   cp   $FB                                      ; $0661: $FE $FB
    jr   nz, :+                                   ; $0663: $20 $03

    push hl                                       ; $0665: $E5
    jr   .jr_000_0644                             ; $0666: $18 $DC

:   cp   $F0                                      ; $0668: $FE $F0
    jr   nz, :+                                   ; $066A: $20 $08

    ld   a, h                                     ; $066C: $7C
    ldh  [hMusic+1], a                            ; $066D: $E0 $DE
    ld   a, l                                     ; $066F: $7D
    ldh  [hMusic], a                              ; $0670: $E0 $DD
    jr   .jr_000_0689                             ; $0672: $18 $15

:   ld   c, a                                     ; $0674: $4F
    cp   $16                                      ; $0675: $FE $16
    jr   nc, .jr_000_0685                         ; $0677: $30 $0C

    ldh  a, [$FFE2]                               ; $0679: $F0 $E2
    cp   $00                                      ; $067B: $FE $00
    jr   nz, .jr_000_065E                         ; $067D: $20 $DF

    ldh  a, [$FFE1]                               ; $067F: $F0 $E1
    cp   $00                                      ; $0681: $FE $00
    jr   nz, .jr_000_065E                         ; $0683: $20 $D9

.jr_000_0685:
    ld   a, [hl+]                                 ; $0685: $2A
    ldh  [c], a                                   ; $0686: $E2
    jr   .jr_000_0633                             ; $0687: $18 $AA

.jr_000_0689:
    ld   hl, $FFAF                                ; $0689: $21 $AF $FF
    inc  [hl]                                     ; $068C: $34
    ldh  a, [hCounter+1]                          ; $068D: $F0 $B1
    ld   b, a                                     ; $068F: $47
    ldh  a, [hCounter]                            ; $0690: $F0 $B0
    ld   d, a                                     ; $0692: $57
    or   b                                        ; $0693: $B0
    jr   z, .jr_000_06A2                          ; $0694: $28 $0C

    ld   a, d                                     ; $0696: $7A
    cp   $00                                      ; $0697: $FE $00
    jr   nz, :+                                   ; $0699: $20 $01

    dec  b                                        ; $069B: $05

:   dec  a                                        ; $069C: $3D
    ldh  [hCounter], a                            ; $069D: $E0 $B0
    ld   a, b                                     ; $069F: $78
    ldh  [hCounter+1], a                          ; $06A0: $E0 $B1

.jr_000_06A2:
    ldh  a, [$FFB3]                               ; $06A2: $F0 $B3
    ld   b, a                                     ; $06A4: $47
    ldh  a, [$FFB2]                               ; $06A5: $F0 $B2
    ld   d, a                                     ; $06A7: $57
    or   b                                        ; $06A8: $B0
    jr   z, .jr_000_06B7                          ; $06A9: $28 $0C

    ld   a, d                                     ; $06AB: $7A
    cp   $00                                      ; $06AC: $FE $00
    jr   nz, .jr_000_06B1                         ; $06AE: $20 $01

    dec  b                                        ; $06B0: $05

.jr_000_06B1:
    dec  a                                        ; $06B1: $3D
    ldh  [$FFB2], a                               ; $06B2: $E0 $B2
    ld   a, b                                     ; $06B4: $78
    ldh  [$FFB3], a                               ; $06B5: $E0 $B3

.jr_000_06B7:
    ldh  a, [$FF97]                               ; $06B7: $F0 $97
    cp   $01                                      ; $06B9: $FE $01
    jr   nz, .jr_000_06F4                         ; $06BB: $20 $37

    ld   hl, $FFA7                                ; $06BD: $21 $A7 $FF
    bit  4, [hl]                                  ; $06C0: $CB $66
    jr   z, .jr_000_06D9                          ; $06C2: $28 $15

    ldh  a, [$FFBC]                               ; $06C4: $F0 $BC
    dec  a                                        ; $06C6: $3D
    ldh  [$FFBC], a                               ; $06C7: $E0 $BC
    cp   $00                                      ; $06C9: $FE $00
    jr   nz, .jr_000_06D9                         ; $06CB: $20 $0C

    ld   a, $A0                                   ; $06CD: $3E $A0
    ldh  [$FFBC], a                               ; $06CF: $E0 $BC
    bit  5, [hl]                                  ; $06D1: $CB $6E
    set  5, [hl]                                  ; $06D3: $CB $EE
    jr   z, .jr_000_06D9                          ; $06D5: $28 $02

    res  5, [hl]                                  ; $06D7: $CB $AE

.jr_000_06D9:
    bit  3, [hl]                                  ; $06D9: $CB $5E
    jr   z, .return                               ; $06DB: $28 $68

    ldh  a, [$FFBD]                               ; $06DD: $F0 $BD
    dec  a                                        ; $06DF: $3D
    ldh  [$FFBD], a                               ; $06E0: $E0 $BD
    cp   $00                                      ; $06E2: $FE $00
    jr   nz, .return                              ; $06E4: $20 $5F

    ld   a, $A0                                   ; $06E6: $3E $A0
    ldh  [$FFBD], a                               ; $06E8: $E0 $BD
    bit  6, [hl]                                  ; $06EA: $CB $76
    set  6, [hl]                                  ; $06EC: $CB $F6
    jr   z, .return                               ; $06EE: $28 $55

    res  6, [hl]                                  ; $06F0: $CB $B6
    jr   .return                                  ; $06F2: $18 $51

.jr_000_06F4:
    ldh  a, [$FFA6]                               ; $06F4: $F0 $A6
    bit  7, a                                     ; $06F6: $CB $7F
    jr   nz, .jr_000_0700                         ; $06F8: $20 $06

    ldh  a, [$FF9D]                               ; $06FA: $F0 $9D
    cp   $03                                      ; $06FC: $FE $03
    jr   nz, .return                              ; $06FE: $20 $45

.jr_000_0700:
    ldh  a, [$FFA7]                               ; $0700: $F0 $A7
    bit  0, a                                     ; $0702: $CB $47
    jr   nz, .return                              ; $0704: $20 $3F

    ldh  a, [$FFB7]                               ; $0706: $F0 $B7
    ld   b, a                                     ; $0708: $47
    ldh  a, [$FFB6]                               ; $0709: $F0 $B6
    ld   d, a                                     ; $070B: $57
    or   b                                        ; $070C: $B0
    jr   z, .tickClock                            ; $070D: $28 $0E

    ld   a, d                                     ; $070F: $7A
    cp   $00                                      ; $0710: $FE $00
    jr   nz, .jr_000_0715                         ; $0712: $20 $01

    dec  b                                        ; $0714: $05

.jr_000_0715:
    dec  a                                        ; $0715: $3D
    ldh  [$FFB6], a                               ; $0716: $E0 $B6
    ld   a, b                                     ; $0718: $78
    ldh  [$FFB7], a                               ; $0719: $E0 $B7
    jr   .return                                  ; $071B: $18 $28

.tickClock:
    ld   hl, hSeconds                             ; $071D: $21 $CB $FF
    ld   a, [hl]                                  ; $0720: $7E
    cp   $00                                      ; $0721: $FE $00
    jr   nz, .decrement                           ; $0723: $20 $1C

    inc  hl                                       ; $0725: $23
    ld   a, [hl+]                                 ; $0726: $2A
    cp   $00                                      ; $0727: $FE $00
    jr   nz, .decrementSeconds                    ; $0729: $20 $06

    inc  hl                                       ; $072B: $23
    ld   a, [hl]                                  ; $072C: $7E
    cp   $00                                      ; $072D: $FE $00
    jr   z, .return                               ; $072F: $28 $14

.decrementSeconds:
    ld   hl, hSeconds                             ; $0731: $21 $CB $FF
    ld   a, $09                                   ; $0734: $3E $09
    ld   [hl+], a                                 ; $0736: $22
    ld   a, [hl]                                  ; $0737: $7E
    cp   $00                                      ; $0738: $FE $00
    jr   nz, .decrement                           ; $073A: $20 $05

    ld   a, $05                                   ; $073C: $3E $05
    ld   [hl+], a                                 ; $073E: $22
    inc  hl                                       ; $073F: $23
    ld   a, [hl]                                  ; $0740: $7E

.decrement:
    dec  a                                        ; $0741: $3D
    ld   [hl], a                                  ; $0742: $77
    jr   .jr_000_074A                             ; $0743: $18 $05

.return:
    pop  hl                                       ; $0745: $E1
    pop  de                                       ; $0746: $D1
    pop  bc                                       ; $0747: $C1
    pop  af                                       ; $0748: $F1
    reti                                          ; $0749: $D9


.jr_000_074A:
    ld   hl, hSeconds                             ; $074A: $21 $CB $FF
    ld   a, [hl+]                                 ; $074D: $2A
    cp   $00                                      ; $074E: $FE $00
    jr   nz, .jr_000_0773                         ; $0750: $20 $21

    ld   a, [hl+]                                 ; $0752: $2A
    cp   $03                                      ; $0753: $FE $03
    jr   nz, .jr_000_0764                         ; $0755: $20 $0D

    inc  hl                                       ; $0757: $23
    ld   a, [hl]                                  ; $0758: $7E
    cp   $00                                      ; $0759: $FE $00
    jr   nz, .jr_000_0773                         ; $075B: $20 $16

    ld   hl, $FFA7                                ; $075D: $21 $A7 $FF
    set  0, [hl]                                  ; $0760: $CB $C6
    jr   .jr_000_0773                             ; $0762: $18 $0F

.jr_000_0764:
    cp   $00                                      ; $0764: $FE $00
    jr   nz, .jr_000_0773                         ; $0766: $20 $0B

    inc  hl                                       ; $0768: $23
    ld   a, [hl]                                  ; $0769: $7E
    cp   $00                                      ; $076A: $FE $00
    jr   nz, .jr_000_0773                         ; $076C: $20 $05

    ld   hl, $FFA7                                ; $076E: $21 $A7 $FF
    set  1, [hl]                                  ; $0771: $CB $CE

.jr_000_0773:
    ld   hl, $FFB6                                ; $0773: $21 $B6 $FF
    ld   de, $FFB4                                ; $0776: $11 $B4 $FF
    ld   a, [de]                                  ; $0779: $1A
    ld   [hl+], a                                 ; $077A: $22
    inc  de                                       ; $077B: $13
    ld   a, [de]                                  ; $077C: $1A
    ld   [hl], a                                  ; $077D: $77
    jr   .return                                  ; $077E: $18 $C5
; TimerInterruptHandler done


SerialInterruptHandler::
    push af                                       ; $0780: $F5
    push hl                                       ; $0781: $E5
    ld   hl, $FFA8                                ; $0782: $21 $A8 $FF
    set  0, [hl]                                  ; $0785: $CB $C6
    ldh  a, [rSB]                                 ; $0787: $F0 $01
    ldh  [$FFAA], a                               ; $0789: $E0 $AA
    pop  hl                                       ; $078B: $E1
    pop  af                                       ; $078C: $F1
    reti                                          ; $078D: $D9


ShuffleBlockRNG::
    ld   a, [wBlockRNGCounter]                    ; $078E: $FA $30 $CA
    inc  a                                        ; $0791: $3C
    cp   $24                                      ; $0792: $FE $24
    jr   nz, :+                                   ; $0794: $20 $02

    ld   a, $00                                   ; $0796: $3E $00

:   ld   [wBlockRNGCounter], a                    ; $0798: $EA $30 $CA
    ld   hl, wBlockRNG                            ; $079B: $21 $00 $CA
    ld   c, a                                     ; $079E: $4F
    ld   b, $00                                   ; $079F: $06 $00
    add  hl, bc                                   ; $07A1: $09
    push hl                                       ; $07A2: $E5
    ld   a, [hl]                                  ; $07A3: $7E
    ld   d, a                                     ; $07A4: $57
    ldh  a, [$FFAF]                               ; $07A5: $F0 $AF

:   cp   $24                                      ; $07A7: $FE $24
    jr   c, :+                                    ; $07A9: $38 $04

    sub  $24                                      ; $07AB: $D6 $24
    jr   :-                                       ; $07AD: $18 $F8

:   ld   c, a                                     ; $07AF: $4F
    ld   hl, wBlockRNG                            ; $07B0: $21 $00 $CA
    add  hl, bc                                   ; $07B3: $09
    ld   a, [hl]                                  ; $07B4: $7E
    ld   e, a                                     ; $07B5: $5F
    ld   a, d                                     ; $07B6: $7A
    ld   [hl], a                                  ; $07B7: $77
    pop  hl                                       ; $07B8: $E1
    ld   a, e                                     ; $07B9: $7B
    ld   [hl], a                                  ; $07BA: $77
    ldh  a, [$FFA6]                               ; $07BB: $F0 $A6
    bit  7, a                                     ; $07BD: $CB $7F
    jp   nz, Jump_000_1FB4                        ; $07BF: $C2 $B4 $1F

    ldh  a, [$FF9D]                               ; $07C2: $F0 $9D
    cp   $01                                      ; $07C4: $FE $01
    jr   c, jr_000_07E3                           ; $07C6: $38 $1B

    jp   z, Jump_000_0947                         ; $07C8: $CA $47 $09

    cp   $03                                      ; $07CB: $FE $03
    jp   c, Jump_000_0A04                         ; $07CD: $DA $04 $0A

    jp   z, Jump_000_0C14                         ; $07D0: $CA $14 $0C

    cp   $05                                      ; $07D3: $FE $05
    jp   c, Jump_000_13BF                         ; $07D5: $DA $BF $13

    jp   z, Jump_000_12E4                         ; $07D8: $CA $E4 $12

    cp   $07                                      ; $07DB: $FE $07
    jp   c, Jump_000_1B66                         ; $07DD: $DA $66 $1B

    jp   nc, Jump_000_101B                        ; $07E0: $D2 $1B $10

jr_000_07E3:
    ldh  a, [$FFA8]                               ; $07E3: $F0 $A8
    bit  0, a                                     ; $07E5: $CB $47
    jr   z, jr_000_080E                           ; $07E7: $28 $25

    and  $FE                                      ; $07E9: $E6 $FE
    ldh  [$FFA8], a                               ; $07EB: $E0 $A8
    ldh  a, [$FFAA]                               ; $07ED: $F0 $AA
    cp   $FF                                      ; $07EF: $FE $FF
    jr   nz, jr_000_0806                          ; $07F1: $20 $13

    ld   a, $01                                   ; $07F3: $3E $01
    ldh  [$FF97], a                               ; $07F5: $E0 $97
    ld   a, $01                                   ; $07F7: $3E $01
    call Call_000_3148                            ; $07F9: $CD $48 $31
    call SerialTransferHandler                    ; $07FC: $CD $25 $31
    ld   a, $00                                   ; $07FF: $3E $00
    ldh  [$FFAB], a                               ; $0801: $E0 $AB
    jp   Jump_000_0911                            ; $0803: $C3 $11 $09


jr_000_0806:
    cp   $01                                      ; $0806: $FE $01
    jp   z, Jump_000_0908                         ; $0808: $CA $08 $09

    call SerialTransferHandler                    ; $080B: $CD $25 $31

jr_000_080E:
    ldh  a, [hPressedButtonsMask]                 ; $080E: $F0 $8B
    and  $FF                                      ; $0810: $E6 $FF
    jr   nz, jr_000_0839                          ; $0812: $20 $25

    ldh  a, [$FFAE]                               ; $0814: $F0 $AE
    cp   PADF_A                                   ; $0816: $FE $01
    jr   nz, jr_000_0823                          ; $0818: $20 $09

    ld   a, $10                                   ; $081A: $3E $10
    ldh  [hCounter], a                            ; $081C: $E0 $B0
    ld   a, $27                                   ; $081E: $3E $27
    ldh  [hCounter+1], a                          ; $0820: $E0 $B1
    ret                                           ; $0822: $C9


jr_000_0823:
    call Call_000_2EE8                            ; $0823: $CD $E8 $2E
    ret  nz                                       ; $0826: $C0

    ld   hl, $FFA6                                ; $0827: $21 $A6 $FF
    set  7, [hl]                                  ; $082A: $CB $FE
    ld   a, $00                                   ; $082C: $3E $00
    ldh  [$FF97], a                               ; $082E: $E0 $97
    ld   hl, hSBlocksRemaining                    ; $0830: $21 $C5 $FF
    call InitNewGame.continue                     ; $0833: $CD $47 $2D
    jp   StartGame                                ; $0836: $C3 $2D $0A


jr_000_0839:
    ldh  a, [$FFAE]                               ; $0839: $F0 $AE
    cp   PADF_A                                   ; $083B: $FE $01
    ret  z                                        ; $083D: $C8

    ld   a, $01                                   ; $083E: $3E $01
    ldh  [$FFAE], a                               ; $0840: $E0 $AE
    ldh  a, [hPressedButtonsMask]                 ; $0842: $F0 $8B
    cp   PADF_START                               ; $0844: $FE $08
    jr   nz, jr_000_089C                          ; $0846: $20 $54

    ldh  a, [$FF97]                               ; $0848: $F0 $97
    cp   $01                                      ; $084A: $FE $01
    jp   z, Jump_000_08CE                         ; $084C: $CA $CE $08

    call InitNewGame                              ; $084F: $CD $41 $2D

Jump_000_0852:
    call LCDOff                                   ; $0852: $CD $AA $2C
    call ClearScreen                              ; $0855: $CD $CA $2C
    ld   hl, _RAM                                 ; $0858: $21 $00 $C0
    ld   bc, $00A0                                ; $085B: $01 $A0 $00
    call MemClear                                 ; $085E: $CD $C1 $2C
    ld   de, StageNumberDrawCommand               ; $0861: $11 $4E $34
    call ExecuteDrawCommands.getNextDrawCommand   ; $0864: $CD $EC $2C
    ld   hl, $98CC                                ; $0867: $21 $CC $98
    ld   de, hStage+2                             ; $086A: $11 $C8 $FF
    ld   b, $03                                   ; $086D: $06 $03

:   ld   a, [de]                                  ; $086F: $1A
    cp   $00                                      ; $0870: $FE $00
    jr   nz, :+                                   ; $0872: $20 $05

    inc  hl                                       ; $0874: $23
    dec  de                                       ; $0875: $1B
    dec  b                                        ; $0876: $05
    jr   :-                                       ; $0877: $18 $F6

:   call MemCpyDEtoHLReverse                      ; $0879: $CD $AC $2D

Jump_000_087C:
    ld   a, $02                                   ; $087C: $3E $02
    ldh  [$FF9D], a                               ; $087E: $E0 $9D
    ld   a, $00                                   ; $0880: $3E $00
    ldh  [$FF9F], a                               ; $0882: $E0 $9F
    ldh  [$FFA0], a                               ; $0884: $E0 $A0
    ld   a, $83                                   ; $0886: $3E $83
    ldh  [rLCDC], a                               ; $0888: $E0 $40
    ld   a, $00                                   ; $088A: $3E $00
    ldh  [hCounter], a                            ; $088C: $E0 $B0
    ld   a, $10                                   ; $088E: $3E $10
    ldh  [hCounter+1], a                          ; $0890: $E0 $B1
    ldh  a, [hPressedButtonsMask]                 ; $0892: $F0 $8B
    and  $FF                                      ; $0894: $E6 $FF
    ret  z                                        ; $0896: $C8

    ld   a, $01                                   ; $0897: $3E $01
    ldh  [$FFAE], a                               ; $0899: $E0 $AE
    ret                                           ; $089B: $C9


jr_000_089C:
    ld   b, $04                                   ; $089C: $06 $04
    cp   $04                                      ; $089E: $FE $04
    jr   nz, jr_000_08AA                          ; $08A0: $20 $08

    ldh  a, [$FF97]                               ; $08A2: $F0 $97
    cp   $00                                      ; $08A4: $FE $00
    jr   nz, jr_000_08C5                          ; $08A6: $20 $1D

    jr   jr_000_08B3                              ; $08A8: $18 $09

jr_000_08AA:
    cp   $10                                      ; $08AA: $FE $10
    jr   nz, jr_000_08BD                          ; $08AC: $20 $0F

    ldh  a, [$FF97]                               ; $08AE: $F0 $97
    cp   $00                                      ; $08B0: $FE $00
    ret  nz                                       ; $08B2: $C0

jr_000_08B3:
    ld   a, $01                                   ; $08B3: $3E $01
    ldh  [$FF97], a                               ; $08B5: $E0 $97
    ld   de, ArrowRightSelectionOAM               ; $08B7: $11 $D2 $52

jr_000_08BA:
    jp   MemCpyDEtoWRAM                           ; $08BA: $C3 $B3 $2D


jr_000_08BD:
    cp   $20                                      ; $08BD: $FE $20
    ret  nz                                       ; $08BF: $C0

    ldh  a, [$FF97]                               ; $08C0: $F0 $97
    cp   $01                                      ; $08C2: $FE $01
    ret  nz                                       ; $08C4: $C0

jr_000_08C5:
    ld   a, $00                                   ; $08C5: $3E $00
    ldh  [$FF97], a                               ; $08C7: $E0 $97
    ld   de, ArrowLeftSelectionOAM                ; $08C9: $11 $CE $52
    jr   jr_000_08BA                              ; $08CC: $18 $EC

Jump_000_08CE:
    ld   b, $04                                   ; $08CE: $06 $04
    ld   a, $FF                                   ; $08D0: $3E $FF
    call Call_000_3148                            ; $08D2: $CD $48 $31
    call SerialTransferHandler                    ; $08D5: $CD $25 $31
    ld   a, $14                                   ; $08D8: $3E $14
    ldh  [hCounter], a                            ; $08DA: $E0 $B0
    ld   a, $00                                   ; $08DC: $3E $00
    ldh  [hCounter+1], a                          ; $08DE: $E0 $B1

jr_000_08E0:
    ldh  a, [$FFA8]                               ; $08E0: $F0 $A8
    bit  0, a                                     ; $08E2: $CB $47
    jr   nz, jr_000_08F7                          ; $08E4: $20 $11

    call Call_000_2EE8                            ; $08E6: $CD $E8 $2E
    jr   nz, jr_000_08E0                          ; $08E9: $20 $F5

    ld   a, $10                                   ; $08EB: $3E $10
    ldh  [hCounter], a                            ; $08ED: $E0 $B0
    ld   a, $27                                   ; $08EF: $3E $27
    ldh  [hCounter+1], a                          ; $08F1: $E0 $B1
    ld   b, $04                                   ; $08F3: $06 $04
    jr   jr_000_08C5                              ; $08F5: $18 $CE

jr_000_08F7:
    and  $FE                                      ; $08F7: $E6 $FE
    ldh  [$FFA8], a                               ; $08F9: $E0 $A8
    ldh  a, [$FFAA]                               ; $08FB: $F0 $AA
    cp   $01                                      ; $08FD: $FE $01
    jr   z, jr_000_0908                           ; $08FF: $28 $07

    call SerialTransferHandler                    ; $0901: $CD $25 $31
    ld   b, $04                                   ; $0904: $06 $04
    jr   jr_000_08C5                              ; $0906: $18 $BD

Jump_000_0908:
jr_000_0908:
    ld   hl, $FFA8                                ; $0908: $21 $A8 $FF
    set  3, [hl]                                  ; $090B: $CB $DE
    ld   a, $80                                   ; $090D: $3E $80
    ldh  [$FFAB], a                               ; $090F: $E0 $AB

Jump_000_0911:
    call InitNewGame                              ; $0911: $CD $41 $2D
    ld   a, $01                                   ; $0914: $3E $01
    ldh  [$FF9D], a                               ; $0916: $E0 $9D
    ldh  [$FFAE], a                               ; $0918: $E0 $AE
    ld   hl, $FF98                                ; $091A: $21 $98 $FF
    ld   a, $03                                   ; $091D: $3E $03
    ld   [hl+], a                                 ; $091F: $22
    ld   a, $00                                   ; $0920: $3E $00
    ld   [hl+], a                                 ; $0922: $22
    ld   [hl+], a                                 ; $0923: $22
    ld   [hl], a                                  ; $0924: $77
    call LCDOff                                   ; $0925: $CD $AA $2C
    call ClearScreen                              ; $0928: $CD $CA $2C
    ld   hl, _RAM                                 ; $092B: $21 $00 $C0
    ld   bc, $00A0                                ; $092E: $01 $A0 $00
    call MemClear                                 ; $0931: $CD $C1 $2C
    ld   de, SetsDrawCommand                      ; $0934: $11 $E5 $34
    call ExecuteDrawCommands.getNextDrawCommand   ; $0937: $CD $EC $2C
    ld   b, $04                                   ; $093A: $06 $04
    ld   de, OAMBlocks.52E6                       ; $093C: $11 $E6 $52
    call MemCpyDEtoWRAM                           ; $093F: $CD $B3 $2D
    ld   a, $83                                   ; $0942: $3E $83
    ldh  [rLCDC], a                               ; $0944: $E0 $40
    ret                                           ; $0946: $C9


Jump_000_0947:
    ldh  a, [$FFA8]                               ; $0947: $F0 $A8
    bit  3, a                                     ; $0949: $CB $5F
    jr   nz, jr_000_0982                          ; $094B: $20 $35

    bit  0, a                                     ; $094D: $CB $47
    ret  z                                        ; $094F: $C8

    and  $FE                                      ; $0950: $E6 $FE
    ldh  [$FFA8], a                               ; $0952: $E0 $A8
    ldh  a, [$FFAA]                               ; $0954: $F0 $AA
    ld   b, a                                     ; $0956: $47
    and  $E0                                      ; $0957: $E6 $E0
    cp   $60                                      ; $0959: $FE $60
    jr   nz, :+                                   ; $095B: $20 $11

    ld   a, b                                     ; $095D: $78
    and  $1F                                      ; $095E: $E6 $1F
    call LoadAttractModeStage                     ; $0960: $CD $A3 $2D
    ld   a, $01                                   ; $0963: $3E $01
    call Call_000_3148                            ; $0965: $CD $48 $31
    call SerialTransferHandler                    ; $0968: $CD $25 $31
    jp   Jump_000_09DB                            ; $096B: $C3 $DB $09


:   ld   b, $04                                   ; $096E: $06 $04
    call SerialTransferHandler                    ; $0970: $CD $25 $31
    ldh  a, [$FFAA]                               ; $0973: $F0 $AA
    cp   $03                                      ; $0975: $FE $03
    jr   z, jr_000_09A5                           ; $0977: $28 $2C

    cp   $05                                      ; $0979: $FE $05
    jr   z, jr_000_09B3                           ; $097B: $28 $36

    cp   $07                                      ; $097D: $FE $07
    jr   z, jr_000_09C2                           ; $097F: $28 $41

    ret                                           ; $0981: $C9


jr_000_0982:
    ldh  a, [hPressedButtonsMask]                 ; $0982: $F0 $8B
    and  $FF                                      ; $0984: $E6 $FF
    ret  z                                        ; $0986: $C8

    ldh  a, [$FFAE]                               ; $0987: $F0 $AE
    cp   $01                                      ; $0989: $FE $01
    ret  z                                        ; $098B: $C8

    ld   a, $01                                   ; $098C: $3E $01
    ldh  [$FFAE], a                               ; $098E: $E0 $AE
    ldh  a, [hPressedButtonsMask]                 ; $0990: $F0 $8B
    cp   $04                                      ; $0992: $FE $04
    jr   nz, jr_000_09CB                          ; $0994: $20 $35

    ld   b, $04                                   ; $0996: $06 $04
    ldh  a, [$FF98]                               ; $0998: $F0 $98
    cp   $05                                      ; $099A: $FE $05
    jr   c, jr_000_09AE                           ; $099C: $38 $10

    jr   z, jr_000_09BD                           ; $099E: $28 $1D

    ld   a, $03                                   ; $09A0: $3E $03
    call Call_000_3148                            ; $09A2: $CD $48 $31

jr_000_09A5:
    ld   a, $03                                   ; $09A5: $3E $03
    ldh  [$FF98], a                               ; $09A7: $E0 $98
    ld   de, OAMBlocks.52E6                       ; $09A9: $11 $E6 $52
    jr   jr_000_09BA                              ; $09AC: $18 $0C

jr_000_09AE:
    ld   a, $05                                   ; $09AE: $3E $05
    call Call_000_3148                            ; $09B0: $CD $48 $31

jr_000_09B3:
    ld   a, $05                                   ; $09B3: $3E $05
    ldh  [$FF98], a                               ; $09B5: $E0 $98
    ld   de, OAMBlocks.52EA                       ; $09B7: $11 $EA $52

jr_000_09BA:
    jp   MemCpyDEtoWRAM                           ; $09BA: $C3 $B3 $2D


jr_000_09BD:
    ld   a, $07                                   ; $09BD: $3E $07
    call Call_000_3148                            ; $09BF: $CD $48 $31

jr_000_09C2:
    ld   a, $07                                   ; $09C2: $3E $07
    ldh  [$FF98], a                               ; $09C4: $E0 $98
    ld   de, OAMBlocks.52EE                       ; $09C6: $11 $EE $52
    jr   jr_000_09BA                              ; $09C9: $18 $EF

jr_000_09CB:
    cp   $08                                      ; $09CB: $FE $08
    ret  nz                                       ; $09CD: $C0

Jump_000_09CE:
    call Call_000_2D95                            ; $09CE: $CD $95 $2D
    ldh  a, [$FFDA]                               ; $09D1: $F0 $DA
    or   $60                                      ; $09D3: $F6 $60
    call Call_000_3148                            ; $09D5: $CD $48 $31
    call Call_000_3178                            ; $09D8: $CD $78 $31

Jump_000_09DB:
    ld   a, $00                                   ; $09DB: $3E $00
    ldh  [$FFD2], a                               ; $09DD: $E0 $D2
    ldh  [$FFD3], a                               ; $09DF: $E0 $D3
    call Call_000_3312                            ; $09E1: $CD $12 $33
    call LCDOff                                   ; $09E4: $CD $AA $2C
    call ClearScreen                              ; $09E7: $CD $CA $2C
    ld   hl, _RAM                                 ; $09EA: $21 $00 $C0
    ld   bc, $00A0                                ; $09ED: $01 $A0 $00
    call MemClear                                 ; $09F0: $CD $C1 $2C
    ld   de, SetDrawCommand                       ; $09F3: $11 $10 $35
    call ExecuteDrawCommands.getNextDrawCommand   ; $09F6: $CD $EC $2C
    ld   hl, $98EB                                ; $09F9: $21 $EB $98
    ld   de, hStage                               ; $09FC: $11 $C6 $FF
    ld   a, [de]                                  ; $09FF: $1A
    ld   [hl], a                                  ; $0A00: $77
    jp   Jump_000_087C                            ; $0A01: $C3 $7C $08


Jump_000_0A04:
    ldh  a, [$FF97]                               ; $0A04: $F0 $97
    cp   $01                                      ; $0A06: $FE $01
    jp   z, Start2PlayerGame                      ; $0A08: $CA $02 $0B

    ldh  a, [hPressedButtonsMask]                 ; $0A0B: $F0 $8B
    and  $FF                                      ; $0A0D: $E6 $FF
    jr   z, :+                                    ; $0A0F: $28 $18

    ldh  a, [$FFAE]                               ; $0A11: $F0 $AE
    cp   $01                                      ; $0A13: $FE $01
    jr   z, :+                                    ; $0A15: $28 $12

    ld   a, $01                                   ; $0A17: $3E $01
    ldh  [$FFAE], a                               ; $0A19: $E0 $AE
    ldh  a, [hPressedButtonsMask]                 ; $0A1B: $F0 $8B
    cp   $08                                      ; $0A1D: $FE $08
    jr   nz, :+                                   ; $0A1F: $20 $08

    ld   a, $00                                   ; $0A21: $3E $00
    ldh  [hCounter], a                            ; $0A23: $E0 $B0
    ldh  [hCounter+1], a                          ; $0A25: $E0 $B1
    jr   StartGame                                ; $0A27: $18 $04

:   call Call_000_2EE8                            ; $0A29: $CD $E8 $2E
    ret  nz                                       ; $0A2C: $C0

StartGame::
    ld   a, $00                                   ; $0A2D: $3E $00
    ldh  [$FFAD], a                               ; $0A2F: $E0 $AD
    ld   hl, $FFA6                                ; $0A31: $21 $A6 $FF
    res  5, [hl]                                  ; $0A34: $CB $AE
    ldh  a, [$FFA7]                               ; $0A36: $F0 $A7
    and  $F8                                      ; $0A38: $E6 $F8
    ldh  [$FFA7], a                               ; $0A3A: $E0 $A7
    ld   hl, $C860                                ; $0A3C: $21 $60 $C8
    ld   bc, $0170                                ; $0A3F: $01 $70 $01
    call MemClear                                 ; $0A42: $CD $C1 $2C
    ld   a, $80                                   ; $0A45: $3E $80
    ld   hl, $C840                                ; $0A47: $21 $40 $C8
    ld   bc, $0020                                ; $0A4A: $01 $20 $00
    ld   d, $0C                                   ; $0A4D: $16 $0C

:   add  hl, bc                                   ; $0A4F: $09
    ld   [hl], a                                  ; $0A50: $77
    dec  d                                        ; $0A51: $15
    jr   nz, :-                                   ; $0A52: $20 $FB

    call LCDOff                                   ; $0A54: $CD $AA $2C
    call ClearScreen                              ; $0A57: $CD $CA $2C
    ld   hl, _RAM                                 ; $0A5A: $21 $00 $C0
    ld   bc, $00A0                                ; $0A5D: $01 $A0 $00
    call MemClear                                 ; $0A60: $CD $C1 $2C
    ld   de, PlayAreaDrawCommand                  ; $0A63: $11 $EF $33
    call ExecuteDrawCommands.getNextDrawCommand   ; $0A66: $CD $EC $2C
    ldh  a, [$FFC2]                               ; $0A69: $F0 $C2
    and  $1F                                      ; $0A6B: $E6 $1F
    rlca                                          ; $0A6D: $07
    ld   hl, StageDrawCommandsTable               ; $0A6E: $21 $69 $36
    ld   c, a                                     ; $0A71: $4F
    ld   b, $00                                   ; $0A72: $06 $00
    add  hl, bc                                   ; $0A74: $09
    ld   a, [hl+]                                 ; $0A75: $2A
    ld   b, a                                     ; $0A76: $47
    ld   a, [hl]                                  ; $0A77: $7E
    ld   d, a                                     ; $0A78: $57
    ld   e, b                                     ; $0A79: $58
    push de                                       ; $0A7A: $D5
    call ExecuteDrawCommands.getNextDrawCommand   ; $0A7B: $CD $EC $2C
    pop  de                                       ; $0A7E: $D1
    call ExecuteDrawCommandsToWRAM.getNextDrawCommand; $0A7F: $CD $3B $2D
    call Call_000_2DBD                            ; $0A82: $CD $BD $2D
    call Call_000_3029                            ; $0A85: $CD $29 $30
    ld   hl, $9827                                ; $0A88: $21 $27 $98
    ld   de, wScore+6                             ; $0A8B: $11 $26 $C1
    ld   b, $07                                   ; $0A8E: $06 $07
    call MemCpyDEtoHLReverse                      ; $0A90: $CD $AC $2D
    ld   de, hClearCount                          ; $0A93: $11 $D0 $FF
    ld   hl, vClearCount                          ; $0A96: $21 $90 $98
    ld   b, $02                                   ; $0A99: $06 $02
    call MemCpyDEtoHLReverse                      ; $0A9B: $CD $AC $2D
    ld   hl, $98EF                                ; $0A9E: $21 $EF $98
    ld   b, $04                                   ; $0AA1: $06 $04
    call MemCpyDEtoHLReverse                      ; $0AA3: $CD $AC $2D
    ld   hl, vBlocksCount                         ; $0AA6: $21 $50 $99
    ld   b, $02                                   ; $0AA9: $06 $02
    call MemCpyDEtoHLReverse                      ; $0AAB: $CD $AC $2D
    ld   hl, vStageNumber                         ; $0AAE: $21 $AF $99
    ld   b, $03                                   ; $0AB1: $06 $03

:   ld   a, [de]                                  ; $0AB3: $1A
    cp   $00                                      ; $0AB4: $FE $00
    jr   nz, :+                                   ; $0AB6: $20 $05

    inc  hl                                       ; $0AB8: $23
    dec  de                                       ; $0AB9: $1B
    dec  b                                        ; $0ABA: $05
    jr   :-                                       ; $0ABB: $18 $F6

; Initialize blocks, blob, etc
:   call MemCpyDEtoHLReverse                      ; $0ABD: $CD $AC $2D
    ld   hl, vSBlockCount                         ; $0AC0: $21 $D1 $99
    ldh  a, [hSBlocksRemaining]                   ; $0AC3: $F0 $C5
    ld   [hl], a                                  ; $0AC5: $77
    ld   hl, _RAM                                 ; $0AC6: $21 $00 $C0
    ld   a, $80                                   ; $0AC9: $3E $80
    ld   [hl+], a                                 ; $0ACB: $22
    ld   a, $68                                   ; $0ACC: $3E $68
    ld   [hl+], a                                 ; $0ACE: $22
    ld   a, $89                                   ; $0ACF: $3E $89
    ld   [hl+], a                                 ; $0AD1: $22
    ld   a, $00                                   ; $0AD2: $3E $00
    ld   [hl+], a                                 ; $0AD4: $22
    ld   a, $80                                   ; $0AD5: $3E $80
    ld   [hl+], a                                 ; $0AD7: $22
    ld   a, $60                                   ; $0AD8: $3E $60
    ld   [hl+], a                                 ; $0ADA: $22
    ld   a, $82                                   ; $0ADB: $3E $82
    ld   [hl+], a                                 ; $0ADD: $22
    ld   a, $00                                   ; $0ADE: $3E $00
    ld   [hl+], a                                 ; $0AE0: $22
    ld   [hl], a                                  ; $0AE1: $77
    ld   hl, $FFA6                                ; $0AE2: $21 $A6 $FF
    set  0, [hl]                                  ; $0AE5: $CB $C6
    bit  7, [hl]                                  ; $0AE7: $CB $7E
    jr   nz, :+                                   ; $0AE9: $20 $03

    call Call_000_32C1                            ; $0AEB: $CD $C1 $32

:   ld   a, $03                                   ; $0AEE: $3E $03
    ldh  [$FF9D], a                               ; $0AF0: $E0 $9D
    ld   hl, $FFB6                                ; $0AF2: $21 $B6 $FF
    ld   de, $FFB4                                ; $0AF5: $11 $B4 $FF
    ld   a, [de]                                  ; $0AF8: $1A
    ld   [hl+], a                                 ; $0AF9: $22
    inc  de                                       ; $0AFA: $13
    ld   a, [de]                                  ; $0AFB: $1A
    ld   [hl], a                                  ; $0AFC: $77
    ld   a, $83                                   ; $0AFD: $3E $83
    ldh  [rLCDC], a                               ; $0AFF: $E0 $40
    ret                                           ; $0B01: $C9


Start2PlayerGame::
    ldh  a, [$FFA8]                               ; $0B02: $F0 $A8
    bit  3, a                                     ; $0B04: $CB $5F
    jr   nz, :++                                  ; $0B06: $20 $17

    bit  0, a                                     ; $0B08: $CB $47
    ret  z                                        ; $0B0A: $C8

    and  $FE                                      ; $0B0B: $E6 $FE
    ldh  [$FFA8], a                               ; $0B0D: $E0 $A8
    ldh  a, [$FFAA]                               ; $0B0F: $F0 $AA
    cp   $08                                      ; $0B11: $FE $08
    jr   nz, :+                                   ; $0B13: $20 $05

    ld   a, $01                                   ; $0B15: $3E $01
    call Call_000_3148                            ; $0B17: $CD $48 $31

:   call SerialTransferHandler                    ; $0B1A: $CD $25 $31
    jr   jr_000_0B49                              ; $0B1D: $18 $2A

:   ldh  a, [hPressedButtonsMask]                 ; $0B1F: $F0 $8B
    and  $FF                                      ; $0B21: $E6 $FF
    jr   z, :+                                    ; $0B23: $28 $18

    ldh  a, [$FFAE]                               ; $0B25: $F0 $AE
    cp   $01                                      ; $0B27: $FE $01
    jr   z, :+                                    ; $0B29: $28 $12

    ld   a, $01                                   ; $0B2B: $3E $01
    ldh  [$FFAE], a                               ; $0B2D: $E0 $AE
    ldh  a, [hPressedButtonsMask]                 ; $0B2F: $F0 $8B
    cp   $08                                      ; $0B31: $FE $08
    jr   nz, :+                                   ; $0B33: $20 $08

    ld   a, $00                                   ; $0B35: $3E $00
    ldh  [hCounter], a                            ; $0B37: $E0 $B0
    ldh  [hCounter+1], a                          ; $0B39: $E0 $B1
    jr   :++                                      ; $0B3B: $18 $04

:   call Call_000_2EE8                            ; $0B3D: $CD $E8 $2E
    ret  nz                                       ; $0B40: $C0

:   ld   a, $08                                   ; $0B41: $3E $08
    call Call_000_3148                            ; $0B43: $CD $48 $31
    call Call_000_3178                            ; $0B46: $CD $78 $31

jr_000_0B49:
    ld   hl, $C860                                ; $0B49: $21 $60 $C8
    ld   bc, $0170                                ; $0B4C: $01 $70 $01
    call MemClear                                 ; $0B4F: $CD $C1 $2C
    ld   a, $80                                   ; $0B52: $3E $80
    ld   hl, $C840                                ; $0B54: $21 $40 $C8
    ld   bc, $0020                                ; $0B57: $01 $20 $00
    ld   d, $0C                                   ; $0B5A: $16 $0C

:   add  hl, bc                                   ; $0B5C: $09
    ld   [hl], a                                  ; $0B5D: $77
    dec  d                                        ; $0B5E: $15
    jr   nz, :-                                   ; $0B5F: $20 $FB

    ld   hl, $C9E0                                ; $0B61: $21 $E0 $C9
    ld   d, $10                                   ; $0B64: $16 $10

:   ld   [hl+], a                                 ; $0B66: $22
    dec  d                                        ; $0B67: $15
    jr   nz, :-                                   ; $0B68: $20 $FC

    ld   hl, $C840                                ; $0B6A: $21 $40 $C8
    ld   d, $10                                   ; $0B6D: $16 $10

:   ld   [hl+], a                                 ; $0B6F: $22
    dec  d                                        ; $0B70: $15
    jr   nz, :-                                   ; $0B71: $20 $FC

    call LCDOff                                   ; $0B73: $CD $AA $2C
    call ClearScreen                              ; $0B76: $CD $CA $2C
    ld   de, PlayArea2PlayerDrawCommand           ; $0B79: $11 $68 $34
    call ExecuteDrawCommands.getNextDrawCommand   ; $0B7C: $CD $EC $2C
    ld   hl, StageDrawCommandsTable.36A9          ; $0B7F: $21 $A9 $36
    ldh  a, [$FFDA]                               ; $0B82: $F0 $DA
    ld   c, a                                     ; $0B84: $4F
    ld   b, $00                                   ; $0B85: $06 $00
    add  hl, bc                                   ; $0B87: $09
    ld   a, [hl+]                                 ; $0B88: $2A
    ld   e, a                                     ; $0B89: $5F
    ld   a, [hl]                                  ; $0B8A: $7E
    ld   d, a                                     ; $0B8B: $57
    push de                                       ; $0B8C: $D5
    call ExecuteDrawCommands.getNextDrawCommand   ; $0B8D: $CD $EC $2C
    pop  de                                       ; $0B90: $D1
    call ExecuteDrawCommandsToWRAM.getNextDrawCommand; $0B91: $CD $3B $2D
    call Call_000_2DBD                            ; $0B94: $CD $BD $2D
    call Call_000_3029                            ; $0B97: $CD $29 $30
    ld   de, hClearCount                          ; $0B9A: $11 $D0 $FF
    ld   hl, vClearCount                          ; $0B9D: $21 $90 $98
    ld   b, $02                                   ; $0BA0: $06 $02
    call MemCpyDEtoHLReverse                      ; $0BA2: $CD $AC $2D
    ld   hl, vEnemyBlocksCount                    ; $0BA5: $21 $F0 $98
    ld   de, hBlocksInitial+1                     ; $0BA8: $11 $C1 $FF
    ld   b, $02                                   ; $0BAB: $06 $02
    call MemCpyDEtoHLReverse                      ; $0BAD: $CD $AC $2D
    ld   hl, vBlocksCount                         ; $0BB0: $21 $50 $99
    ld   de, hBlocks+1                            ; $0BB3: $11 $CA $FF
    ld   b, $02                                   ; $0BB6: $06 $02
    call MemCpyDEtoHLReverse                      ; $0BB8: $CD $AC $2D
    ld   hl, vStageNumber                         ; $0BBB: $21 $AF $99
    ld   b, $03                                   ; $0BBE: $06 $03

:   ld   a, [de]                                  ; $0BC0: $1A
    cp   $00                                      ; $0BC1: $FE $00
    jr   nz, :+                                   ; $0BC3: $20 $05

    inc  hl                                       ; $0BC5: $23
    dec  de                                       ; $0BC6: $1B
    dec  b                                        ; $0BC7: $05
    jr   :-                                       ; $0BC8: $18 $F6

:   call MemCpyDEtoHLReverse                      ; $0BCA: $CD $AC $2D
    ld   hl, vSBlockCount                         ; $0BCD: $21 $D1 $99
    ld   b, $01                                   ; $0BD0: $06 $01
    call MemCpyDEtoHLReverse                      ; $0BD2: $CD $AC $2D
    ld   hl, _RAM                                 ; $0BD5: $21 $00 $C0
    ld   a, $80                                   ; $0BD8: $3E $80
    ld   [hl+], a                                 ; $0BDA: $22
    ld   a, $68                                   ; $0BDB: $3E $68
    ld   [hl+], a                                 ; $0BDD: $22
    ld   a, $89                                   ; $0BDE: $3E $89
    ld   [hl+], a                                 ; $0BE0: $22
    ld   a, $00                                   ; $0BE1: $3E $00
    ld   [hl+], a                                 ; $0BE3: $22
    ld   a, $80                                   ; $0BE4: $3E $80
    ld   [hl+], a                                 ; $0BE6: $22
    ld   a, $60                                   ; $0BE7: $3E $60
    ld   [hl+], a                                 ; $0BE9: $22
    ld   a, $82                                   ; $0BEA: $3E $82
    ld   [hl+], a                                 ; $0BEC: $22
    ld   a, $00                                   ; $0BED: $3E $00
    ld   [hl+], a                                 ; $0BEF: $22
    ld   [hl], a                                  ; $0BF0: $77
    ld   hl, $FFA6                                ; $0BF1: $21 $A6 $FF
    set  0, [hl]                                  ; $0BF4: $CB $C6
    ldh  a, [$FFA8]                               ; $0BF6: $F0 $A8
    and  $CF                                      ; $0BF8: $E6 $CF
    ldh  [$FFA8], a                               ; $0BFA: $E0 $A8
    ldh  a, [$FFA7]                               ; $0BFC: $F0 $A7
    and  $87                                      ; $0BFE: $E6 $87
    ldh  [$FFA7], a                               ; $0C00: $E0 $A7
    call Call_000_32C1                            ; $0C02: $CD $C1 $32
    ld   a, $03                                   ; $0C05: $3E $03
    ldh  [$FF9D], a                               ; $0C07: $E0 $9D
    ld   a, $83                                   ; $0C09: $3E $83
    ldh  [rLCDC], a                               ; $0C0B: $E0 $40
    ld   a, $00                                   ; $0C0D: $3E $00
    ldh  [hCounter], a                            ; $0C0F: $E0 $B0
    ldh  [hCounter+1], a                          ; $0C11: $E0 $B1
    ret                                           ; $0C13: $C9


Jump_000_0C14:
    ldh  a, [$FF97]                               ; $0C14: $F0 $97
    cp   $01                                      ; $0C16: $FE $01
    jp   z, Jump_000_0D80                         ; $0C18: $CA $80 $0D

    ldh  a, [hPressedButtonsMask]                 ; $0C1B: $F0 $8B
    bit  3, a                                     ; $0C1D: $CB $5F
    jp   nz, Jump_000_0D68                        ; $0C1F: $C2 $68 $0D

    ldh  a, [$FFA7]                               ; $0C22: $F0 $A7
    bit  2, a                                     ; $0C24: $CB $57
    jr   z, jr_000_0C61                           ; $0C26: $28 $39

    call Call_000_2EEF                            ; $0C28: $CD $EF $2E
    ret  nz                                       ; $0C2B: $C0

    ld   hl, $C021                                ; $0C2C: $21 $21 $C0
    ld   bc, $0004                                ; $0C2F: $01 $04 $00
    ld   d, $10                                   ; $0C32: $16 $10

:   ld   a, [hl]                                  ; $0C34: $7E
    sub  $04                                      ; $0C35: $D6 $04
    ld   [hl], a                                  ; $0C37: $77
    add  hl, bc                                   ; $0C38: $09
    dec  d                                        ; $0C39: $15
    jr   nz, :-                                   ; $0C3A: $20 $F8

    ld   hl, $C031                                ; $0C3C: $21 $31 $C0
    ld   a, [hl]                                  ; $0C3F: $7E
    cp   $00                                      ; $0C40: $FE $00
    jr   z, :+                                    ; $0C42: $28 $09

    ld   a, $50                                   ; $0C44: $3E $50
    ldh  [$FFB2], a                               ; $0C46: $E0 $B2
    ld   a, $00                                   ; $0C48: $3E $00
    ldh  [$FFB3], a                               ; $0C4A: $E0 $B3
    ret                                           ; $0C4C: $C9


:   ldh  a, [$FFA7]                               ; $0C4D: $F0 $A7
    and  $FA                                      ; $0C4F: $E6 $FA
    ldh  [$FFA7], a                               ; $0C51: $E0 $A7
    call Call_000_32EB                            ; $0C53: $CD $EB $32
    ld   hl, $C020                                ; $0C56: $21 $20 $C0
    ld   bc, $0040                                ; $0C59: $01 $40 $00
    call MemClear                                 ; $0C5C: $CD $C1 $2C
    jr   jr_000_0CA1                              ; $0C5F: $18 $40

jr_000_0C61:
    bit  1, a                                     ; $0C61: $CB $4F
    jr   z, jr_000_0C7B                           ; $0C63: $28 $16

    ldh  a, [hBlocks+1]                           ; $0C65: $F0 $CA
    cp   $00                                      ; $0C67: $FE $00
    jr   nz, jr_000_0C74                          ; $0C69: $20 $09

    ldh  a, [$FFCF]                               ; $0C6B: $F0 $CF
    ld   hl, hBlocks                              ; $0C6D: $21 $C9 $FF
    cp   [hl]                                     ; $0C70: $BE
    jp   nc, Jump_000_1163                        ; $0C71: $D2 $63 $11

jr_000_0C74:
    ld   a, $01                                   ; $0C74: $3E $01
    ldh  [$FFA0], a                               ; $0C76: $E0 $A0
    jp   Jump_000_11AD                            ; $0C78: $C3 $AD $11


jr_000_0C7B:
    bit  0, a                                     ; $0C7B: $CB $47
    jr   z, jr_000_0CA1                           ; $0C7D: $28 $22

    ld   hl, $FFA7                                ; $0C7F: $21 $A7 $FF
    set  2, [hl]                                  ; $0C82: $CB $D6
    ld   hl, $C020                                ; $0C84: $21 $20 $C0
    ld   de, HurryUpTextOAM                       ; $0C87: $11 $E6 $54
    ld   b, $40                                   ; $0C8A: $06 $40
    call MemCpyDEtoHLShort                        ; $0C8C: $CD $B6 $2D
    call Call_000_3312                            ; $0C8F: $CD $12 $33
    ld   hl, UnknownMusic                         ; $0C92: $21 $44 $67
    call Call_000_332E                            ; $0C95: $CD $2E $33
    ld   a, $50                                   ; $0C98: $3E $50
    ldh  [$FFB2], a                               ; $0C9A: $E0 $B2
    ld   a, $00                                   ; $0C9C: $3E $00
    ldh  [$FFB3], a                               ; $0C9E: $E0 $B3
    ret                                           ; $0CA0: $C9


jr_000_0CA1:
    call Call_000_2FFC                            ; $0CA1: $CD $FC $2F
    ldh  a, [$FF9F]                               ; $0CA4: $F0 $9F
    cp   $00                                      ; $0CA6: $FE $00
    jr   nz, jr_000_0CF2                          ; $0CA8: $20 $48

    ldh  a, [$FFAE]                               ; $0CAA: $F0 $AE
    cp   $01                                      ; $0CAC: $FE $01
    ret  z                                        ; $0CAE: $C8

    ldh  a, [hPressedButtonsMask]                 ; $0CAF: $F0 $8B
    cp   PADF_A                                   ; $0CB1: $FE $01
    jr   z, jr_000_0CD0                           ; $0CB3: $28 $1B

    cp   PADF_B                                   ; $0CB5: $FE $02
    jr   z, jr_000_0CD0                           ; $0CB7: $28 $17

    cp   PADF_UP                                  ; $0CB9: $FE $40
    jr   z, jr_000_0CC6                           ; $0CBB: $28 $09

    cp   PADF_DOWN                                ; $0CBD: $FE $80
    ret  nz                                       ; $0CBF: $C0

    ld   a, $02                                   ; $0CC0: $3E $02
    ldh  [$FF9F], a                               ; $0CC2: $E0 $9F
    jr   jr_000_0CCA                              ; $0CC4: $18 $04

jr_000_0CC6:
    ld   a, $01                                   ; $0CC6: $3E $01
    ldh  [$FF9F], a                               ; $0CC8: $E0 $9F

jr_000_0CCA:
    ld   a, $01                                   ; $0CCA: $3E $01
    ldh  [$FFAE], a                               ; $0CCC: $E0 $AE
    jr   jr_000_0D0B                              ; $0CCE: $18 $3B

jr_000_0CD0:
    ld   hl, $C020                                ; $0CD0: $21 $20 $C0
    call Call_000_30E5                            ; $0CD3: $CD $E5 $30
    ldh  [$FF9E], a                               ; $0CD6: $E0 $9E
    ld   [$C103], a                               ; $0CD8: $EA $03 $C1
    ld   a, $01                                   ; $0CDB: $3E $01
    ldh  [$FFAE], a                               ; $0CDD: $E0 $AE
    ld   a, $03                                   ; $0CDF: $3E $03
    ldh  [$FF9F], a                               ; $0CE1: $E0 $9F
    ld   a, $64                                   ; $0CE3: $3E $64
    ldh  [hCounter], a                            ; $0CE5: $E0 $B0
    ld   a, $00                                   ; $0CE7: $3E $00
    ldh  [hCounter+1], a                          ; $0CE9: $E0 $B1
    ld   hl, UnknownMusic2                        ; $0CEB: $21 $9B $66
    call Call_000_332E                            ; $0CEE: $CD $2E $33
    ret                                           ; $0CF1: $C9


Jump_000_0CF2:
jr_000_0CF2:
    cp   $03                                      ; $0CF2: $FE $03
    jr   c, jr_000_0D0B                           ; $0CF4: $38 $15

    cp   $08                                      ; $0CF6: $FE $08
    jr   nc, jr_000_0D18                          ; $0CF8: $30 $1E

    cp   $07                                      ; $0CFA: $FE $07
    jp   z, Jump_000_10BC                         ; $0CFC: $CA $BC $10

    call Call_000_2EE8                            ; $0CFF: $CD $E8 $2E
    ret  nz                                       ; $0D02: $C0

    ld   a, $00                                   ; $0D03: $3E $00
    ld   [$C008], a                               ; $0D05: $EA $08 $C0
    jp   Jump_000_20F2                            ; $0D08: $C3 $F2 $20


jr_000_0D0B:
    call Call_000_2EE8                            ; $0D0B: $CD $E8 $2E
    ret  nz                                       ; $0D0E: $C0

    ld   hl, UnknownMusic3                        ; $0D0F: $21 $B3 $66
    call Call_000_332E                            ; $0D12: $CD $2E $33
    jp   Jump_000_27F2                            ; $0D15: $C3 $F2 $27


jr_000_0D18:
    call Call_000_2EE8                            ; $0D18: $CD $E8 $2E
    ret  nz                                       ; $0D1B: $C0

    ldh  a, [$FF9F]                               ; $0D1C: $F0 $9F
    cp   $08                                      ; $0D1E: $FE $08
    jr   nz, jr_000_0D3E                          ; $0D20: $20 $1C

    ld   a, $09                                   ; $0D22: $3E $09
    ldh  [$FF9F], a                               ; $0D24: $E0 $9F
    ld   a, $00                                   ; $0D26: $3E $00

jr_000_0D28:
    ld   hl, $C00C                                ; $0D28: $21 $0C $C0
    ld   bc, $0004                                ; $0D2B: $01 $04 $00
    ld   d, $05                                   ; $0D2E: $16 $05

jr_000_0D30:
    ld   [hl], a                                  ; $0D30: $77
    add  hl, bc                                   ; $0D31: $09
    dec  d                                        ; $0D32: $15
    jr   nz, jr_000_0D30                          ; $0D33: $20 $FB

    ld   a, $70                                   ; $0D35: $3E $70
    ldh  [hCounter], a                            ; $0D37: $E0 $B0
    ld   a, $00                                   ; $0D39: $3E $00
    ldh  [hCounter+1], a                          ; $0D3B: $E0 $B1
    ret                                           ; $0D3D: $C9


jr_000_0D3E:
    ldh  a, [$FFBA]                               ; $0D3E: $F0 $BA
    dec  a                                        ; $0D40: $3D
    ldh  [$FFBA], a                               ; $0D41: $E0 $BA
    cp   $00                                      ; $0D43: $FE $00
    jr   z, :+                                    ; $0D45: $28 $08

    ld   a, $08                                   ; $0D47: $3E $08
    ldh  [$FF9F], a                               ; $0D49: $E0 $9F
    ld   a, $40                                   ; $0D4B: $3E $40
    jr   jr_000_0D28                              ; $0D4D: $18 $D9

:   ld   a, $00                                   ; $0D4F: $3E $00
    ldh  [$FF9F], a                               ; $0D51: $E0 $9F
    ld   hl, hSBlocksRemaining                    ; $0D53: $21 $C5 $FF
    dec  [hl]                                     ; $0D56: $35
    ld   a, $82                                   ; $0D57: $3E $82
    ld   [$C006], a                               ; $0D59: $EA $06 $C0
    ld   hl, UnknownMusic4                        ; $0D5C: $21 $4A $68
    call Call_000_332E                            ; $0D5F: $CD $2E $33
    ld   hl, $FFA6                                ; $0D62: $21 $A6 $FF
    set  0, [hl]                                  ; $0D65: $CB $C6
    ret                                           ; $0D67: $C9


Jump_000_0D68:
    ldh  a, [$FFAE]                               ; $0D68: $F0 $AE
    cp   $01                                      ; $0D6A: $FE $01
    ret  z                                        ; $0D6C: $C8

    ld   a, $01                                   ; $0D6D: $3E $01
    ldh  [$FFAE], a                               ; $0D6F: $E0 $AE
    ld   a, $07                                   ; $0D71: $3E $07
    ldh  [$FF9D], a                               ; $0D73: $E0 $9D
    ld   a, $81                                   ; $0D75: $3E $81
    ldh  [rLCDC], a                               ; $0D77: $E0 $40
    ld   hl, UnknownMusic687C                     ; $0D79: $21 $7C $68
    call Call_000_332E                            ; $0D7C: $CD $2E $33
    ret                                           ; $0D7F: $C9


Jump_000_0D80:
    ldh  a, [$FFAB]                               ; $0D80: $F0 $AB
    bit  7, a                                     ; $0D82: $CB $7F
    jr   nz, jr_000_0D93                          ; $0D84: $20 $0D

    ldh  a, [$FFA8]                               ; $0D86: $F0 $A8
    bit  0, a                                     ; $0D88: $CB $47
    jp   z, Jump_000_0E5D                         ; $0D8A: $CA $5D $0E

    call Call_000_29E6                            ; $0D8D: $CD $E6 $29
    jp   Jump_000_0E5D                            ; $0D90: $C3 $5D $0E


jr_000_0D93:
    and  $7F                                      ; $0D93: $E6 $7F
    cp   $00                                      ; $0D95: $FE $00
    jp   z, Jump_000_0E51                         ; $0D97: $CA $51 $0E

    bit  0, a                                     ; $0D9A: $CB $47
    jr   z, jr_000_0DB2                           ; $0D9C: $28 $14

    push af                                       ; $0D9E: $F5
    ld   hl, hBlocks                              ; $0D9F: $21 $C9 $FF
    ld   a, [hl+]                                 ; $0DA2: $2A
    or   $40                                      ; $0DA3: $F6 $40
    call Call_000_3148                            ; $0DA5: $CD $48 $31
    call Call_000_3178                            ; $0DA8: $CD $78 $31
    ld   a, [hl]                                  ; $0DAB: $7E
    or   $40                                      ; $0DAC: $F6 $40
    call Call_000_3148                            ; $0DAE: $CD $48 $31
    pop  af                                       ; $0DB1: $F1

jr_000_0DB2:
    bit  1, a                                     ; $0DB2: $CB $4F
    jr   z, jr_000_0DC6                           ; $0DB4: $28 $10

    ldh  a, [$FFD4]                               ; $0DB6: $F0 $D4
    and  $0F                                      ; $0DB8: $E6 $0F
    or   $20                                      ; $0DBA: $F6 $20
    call Call_000_3148                            ; $0DBC: $CD $48 $31
    call Call_000_3178                            ; $0DBF: $CD $78 $31
    ldh  a, [$FFAA]                               ; $0DC2: $F0 $AA
    jr   jr_000_0DEB                              ; $0DC4: $18 $25

jr_000_0DC6:
    bit  2, a                                     ; $0DC6: $CB $57
    jr   z, jr_000_0DFF                           ; $0DC8: $28 $35

    ldh  a, [$FFD2]                               ; $0DCA: $F0 $D2
    or   $10                                      ; $0DCC: $F6 $10
    call Call_000_3148                            ; $0DCE: $CD $48 $31
    call Call_000_3178                            ; $0DD1: $CD $78 $31
    ldh  a, [$FFAA]                               ; $0DD4: $F0 $AA
    cp   $0B                                      ; $0DD6: $FE $0B
    jr   nz, :+                                   ; $0DD8: $20 $07

    ld   hl, hSBlocksRemaining                    ; $0DDA: $21 $C5 $FF
    inc  [hl]                                     ; $0DDD: $34
    call Call_000_324E                            ; $0DDE: $CD $4E $32

:   ldh  a, [$FFD4]                               ; $0DE1: $F0 $D4
    and  $7F                                      ; $0DE3: $E6 $7F
    call Call_000_3148                            ; $0DE5: $CD $48 $31
    ldh  a, [$FFD2]                               ; $0DE8: $F0 $D2
    dec  a                                        ; $0DEA: $3D

jr_000_0DEB:
    ld   hl, hBlocksInitial                       ; $0DEB: $21 $C0 $FF
    add  [hl]                                     ; $0DEE: $86
    ld   [hl], a                                  ; $0DEF: $77
    cp   $0A                                      ; $0DF0: $FE $0A
    jr   c, :+                                    ; $0DF2: $38 $04

    sub  $0A                                      ; $0DF4: $D6 $0A
    ld   [hl+], a                                 ; $0DF6: $22
    inc  [hl]                                     ; $0DF7: $34

:   call Call_000_321E                            ; $0DF8: $CD $1E $32
    ld   a, $00                                   ; $0DFB: $3E $00
    ldh  [$FFD2], a                               ; $0DFD: $E0 $D2

jr_000_0DFF:
    ldh  a, [$FFAB]                               ; $0DFF: $F0 $AB
    bit  3, a                                     ; $0E01: $CB $5F
    jr   z, :+                                    ; $0E03: $28 $0A

    push af                                       ; $0E05: $F5
    ld   a, $0D                                   ; $0E06: $3E $0D
    call Call_000_3148                            ; $0E08: $CD $48 $31
    call Call_000_3178                            ; $0E0B: $CD $78 $31
    pop  af                                       ; $0E0E: $F1

:   bit  4, a                                     ; $0E0F: $CB $67
    jr   z, :+                                    ; $0E11: $28 $1C

    ld   a, $09                                   ; $0E13: $3E $09
    call Call_000_3148                            ; $0E15: $CD $48 $31
    call Call_000_3178                            ; $0E18: $CD $78 $31
    ld   a, $07                                   ; $0E1B: $3E $07
    ldh  [$FF9D], a                               ; $0E1D: $E0 $9D
    ld   a, $81                                   ; $0E1F: $3E $81
    ldh  [rLCDC], a                               ; $0E21: $E0 $40
    ld   hl, UnknownMusic687C                     ; $0E23: $21 $7C $68
    call Call_000_332E                            ; $0E26: $CD $2E $33
    ld   hl, $FFAB                                ; $0E29: $21 $AB $FF
    res  4, [hl]                                  ; $0E2C: $CB $A6
    ret                                           ; $0E2E: $C9


:   bit  5, a                                     ; $0E2F: $CB $6F
    jr   z, :+                                    ; $0E31: $28 $0D

    call Call_000_319C                            ; $0E33: $CD $9C $31
    ld   a, $0E                                   ; $0E36: $3E $0E
    call Call_000_3148                            ; $0E38: $CD $48 $31
    call Call_000_3178                            ; $0E3B: $CD $78 $31
    jr   jr_000_0E56                              ; $0E3E: $18 $16

:   bit  6, a                                     ; $0E40: $CB $77
    jr   z, jr_000_0E51                           ; $0E42: $28 $0D

    call Call_000_31DC                            ; $0E44: $CD $DC $31
    ld   a, $0F                                   ; $0E47: $3E $0F
    call Call_000_3148                            ; $0E49: $CD $48 $31
    call Call_000_3178                            ; $0E4C: $CD $78 $31
    jr   jr_000_0E56                              ; $0E4F: $18 $05

Jump_000_0E51:
jr_000_0E51:
    ld   a, $00                                   ; $0E51: $3E $00
    call Call_000_3148                            ; $0E53: $CD $48 $31

jr_000_0E56:
    call SerialTransferHandler                    ; $0E56: $CD $25 $31
    ld   a, $00                                   ; $0E59: $3E $00
    ldh  [$FFAB], a                               ; $0E5B: $E0 $AB

Jump_000_0E5D:
    ldh  a, [$FFA8]                               ; $0E5D: $F0 $A8
    bit  3, a                                     ; $0E5F: $CB $5F
    jr   z, jr_000_0E78                           ; $0E61: $28 $15

    ldh  a, [hPressedButtonsMask]                 ; $0E63: $F0 $8B
    bit  PADB_START, a                            ; $0E65: $CB $5F
    jr   z, jr_000_0E78                           ; $0E67: $28 $0F

    ldh  a, [$FFAE]                               ; $0E69: $F0 $AE
    cp   $01                                      ; $0E6B: $FE $01
    ret  z                                        ; $0E6D: $C8

    ld   a, $01                                   ; $0E6E: $3E $01
    ldh  [$FFAE], a                               ; $0E70: $E0 $AE
    ld   hl, $FFAB                                ; $0E72: $21 $AB $FF
    set  4, [hl]                                  ; $0E75: $CB $E6
    ret                                           ; $0E77: $C9


jr_000_0E78:
    ldh  a, [$FF9E]                               ; $0E78: $F0 $9E
    cp   $00                                      ; $0E7A: $FE $00
    jp   z, Jump_000_0F3D                         ; $0E7C: $CA $3D $0F

    call Call_000_2EEF                            ; $0E7F: $CD $EF $2E
    jp   nz, Jump_000_0F3D                        ; $0E82: $C2 $3D $0F

    ldh  a, [$FF9E]                               ; $0E85: $F0 $9E
    cp   $02                                      ; $0E87: $FE $02
    jp   z, Jump_000_0ECA                         ; $0E89: $CA $CA $0E

    ld   hl, $FFD5                                ; $0E8C: $21 $D5 $FF
    ld   a, [hl]                                  ; $0E8F: $7E
    ld   e, a                                     ; $0E90: $5F
    ld   hl, $C01C                                ; $0E91: $21 $1C $C0

jr_000_0E94:
    ld   bc, $0004                                ; $0E94: $01 $04 $00
    add  hl, bc                                   ; $0E97: $09
    push hl                                       ; $0E98: $E5
    ld   a, [hl+]                                 ; $0E99: $2A
    ldh  [$FF8D], a                               ; $0E9A: $E0 $8D
    ld   a, [hl+]                                 ; $0E9C: $2A
    ldh  [$FF8E], a                               ; $0E9D: $E0 $8E
    ld   a, [hl+]                                 ; $0E9F: $2A
    push af                                       ; $0EA0: $F5
    push de                                       ; $0EA1: $D5
    call Call_000_2C4B                            ; $0EA2: $CD $4B $2C
    pop  de                                       ; $0EA5: $D1
    ld   bc, $0020                                ; $0EA6: $01 $20 $00
    add  hl, bc                                   ; $0EA9: $09
    ld   a, [hl]                                  ; $0EAA: $7E
    cp   $00                                      ; $0EAB: $FE $00
    jr   z, jr_000_0EBF                           ; $0EAD: $28 $10

    cp   $81                                      ; $0EAF: $FE $81
    jr   z, jr_000_0EBF                           ; $0EB1: $28 $0C

    pop  af                                       ; $0EB3: $F1
    ld   bc, hMusicSpeed                          ; $0EB4: $01 $E0 $FF
    add  hl, bc                                   ; $0EB7: $09
    ld   [hl], a                                  ; $0EB8: $77
    pop  hl                                       ; $0EB9: $E1
    ld   a, $00                                   ; $0EBA: $3E $00
    ld   [hl], a                                  ; $0EBC: $77
    jr   jr_000_0EC1                              ; $0EBD: $18 $02

jr_000_0EBF:
    pop  af                                       ; $0EBF: $F1
    pop  hl                                       ; $0EC0: $E1

jr_000_0EC1:
    dec  e                                        ; $0EC1: $1D
    jr   nz, jr_000_0E94                          ; $0EC2: $20 $D0

    ld   a, $02                                   ; $0EC4: $3E $02
    ldh  [$FF9E], a                               ; $0EC6: $E0 $9E
    jr   jr_000_0F35                              ; $0EC8: $18 $6B

Jump_000_0ECA:
    ld   hl, $FFD5                                ; $0ECA: $21 $D5 $FF
    ld   a, [hl]                                  ; $0ECD: $7E
    ld   d, a                                     ; $0ECE: $57
    ld   e, a                                     ; $0ECF: $5F
    ld   hl, $C01C                                ; $0ED0: $21 $1C $C0
    ld   bc, $0004                                ; $0ED3: $01 $04 $00

:   add  hl, bc                                   ; $0ED6: $09
    ld   a, [hl]                                  ; $0ED7: $7E
    cp   $00                                      ; $0ED8: $FE $00
    jr   nz, :+                                   ; $0EDA: $20 $14

    dec  d                                        ; $0EDC: $15
    jr   nz, :-                                   ; $0EDD: $20 $F7

    ld   a, $00                                   ; $0EDF: $3E $00
    ldh  [$FF9E], a                               ; $0EE1: $E0 $9E
    call Call_000_2859                            ; $0EE3: $CD $59 $28
    ld   hl, $FFA7                                ; $0EE6: $21 $A7 $FF
    set  7, [hl]                                  ; $0EE9: $CB $FE
    call Call_000_3277                            ; $0EEB: $CD $77 $32
    jr   jr_000_0F3D                              ; $0EEE: $18 $4D

:   ld   hl, $C01C                                ; $0EF0: $21 $1C $C0

jr_000_0EF3:
    ld   bc, $0004                                ; $0EF3: $01 $04 $00
    add  hl, bc                                   ; $0EF6: $09
    ld   a, [hl]                                  ; $0EF7: $7E
    cp   $00                                      ; $0EF8: $FE $00
    jr   z, jr_000_0F32                           ; $0EFA: $28 $36

    add  $04                                      ; $0EFC: $C6 $04
    ld   [hl], a                                  ; $0EFE: $77
    and  $0F                                      ; $0EFF: $E6 $0F
    cp   $00                                      ; $0F01: $FE $00
    jr   z, jr_000_0F09                           ; $0F03: $28 $04

    cp   $08                                      ; $0F05: $FE $08
    jr   nz, jr_000_0F32                          ; $0F07: $20 $29

jr_000_0F09:
    push hl                                       ; $0F09: $E5
    ld   a, [hl+]                                 ; $0F0A: $2A
    ldh  [$FF8D], a                               ; $0F0B: $E0 $8D
    ld   a, [hl+]                                 ; $0F0D: $2A
    ldh  [$FF8E], a                               ; $0F0E: $E0 $8E
    ld   a, [hl+]                                 ; $0F10: $2A
    push af                                       ; $0F11: $F5
    push de                                       ; $0F12: $D5
    call Call_000_2C4B                            ; $0F13: $CD $4B $2C
    pop  de                                       ; $0F16: $D1
    ld   bc, $0020                                ; $0F17: $01 $20 $00
    add  hl, bc                                   ; $0F1A: $09
    ld   a, [hl]                                  ; $0F1B: $7E
    cp   $00                                      ; $0F1C: $FE $00
    jr   z, jr_000_0F30                           ; $0F1E: $28 $10

    cp   $81                                      ; $0F20: $FE $81
    jr   z, jr_000_0F30                           ; $0F22: $28 $0C

    pop  af                                       ; $0F24: $F1
    ld   bc, hMusicSpeed                          ; $0F25: $01 $E0 $FF
    add  hl, bc                                   ; $0F28: $09
    ld   [hl], a                                  ; $0F29: $77
    pop  hl                                       ; $0F2A: $E1
    ld   a, $00                                   ; $0F2B: $3E $00
    ld   [hl], a                                  ; $0F2D: $77
    jr   jr_000_0F32                              ; $0F2E: $18 $02

jr_000_0F30:
    pop  af                                       ; $0F30: $F1
    pop  hl                                       ; $0F31: $E1

jr_000_0F32:
    dec  e                                        ; $0F32: $1D
    jr   nz, jr_000_0EF3                          ; $0F33: $20 $BE

jr_000_0F35:
    ld   a, $30                                   ; $0F35: $3E $30
    ldh  [$FFB2], a                               ; $0F37: $E0 $B2
    ld   a, $00                                   ; $0F39: $3E $00
    ldh  [$FFB3], a                               ; $0F3B: $E0 $B3

Jump_000_0F3D:
jr_000_0F3D:
    ldh  a, [$FF9F]                               ; $0F3D: $F0 $9F
    cp   $00                                      ; $0F3F: $FE $00
    jr   nz, jr_000_0F92                          ; $0F41: $20 $4F

    ldh  a, [$FFAE]                               ; $0F43: $F0 $AE
    cp   $01                                      ; $0F45: $FE $01
    ret  z                                        ; $0F47: $C8

    ldh  a, [$FFA7]                               ; $0F48: $F0 $A7
    bit  7, a                                     ; $0F4A: $CB $7F
    jr   z, jr_000_0F55                           ; $0F4C: $28 $07

    and  $7F                                      ; $0F4E: $E6 $7F
    ldh  [$FFA7], a                               ; $0F50: $E0 $A7
    jp   Jump_000_1208                            ; $0F52: $C3 $08 $12


jr_000_0F55:
    ldh  a, [hPressedButtonsMask]                 ; $0F55: $F0 $8B
    cp   PADF_A                                   ; $0F57: $FE $01
    jr   z, jr_000_0F76                           ; $0F59: $28 $1B

    cp   PADF_B                                   ; $0F5B: $FE $02
    jr   z, jr_000_0F76                           ; $0F5D: $28 $17

    cp   PADF_UP                                  ; $0F5F: $FE $40
    jr   z, jr_000_0F6C                           ; $0F61: $28 $09

    cp   PADF_DOWN                                ; $0F63: $FE $80
    ret  nz                                       ; $0F65: $C0

    ld   a, $02                                   ; $0F66: $3E $02
    ldh  [$FF9F], a                               ; $0F68: $E0 $9F
    jr   jr_000_0F70                              ; $0F6A: $18 $04

jr_000_0F6C:
    ld   a, $01                                   ; $0F6C: $3E $01
    ldh  [$FF9F], a                               ; $0F6E: $E0 $9F

jr_000_0F70:
    ld   a, $01                                   ; $0F70: $3E $01
    ldh  [$FFAE], a                               ; $0F72: $E0 $AE
    jr   jr_000_0FAB                              ; $0F74: $18 $35

jr_000_0F76:
    ld   a, $00                                   ; $0F76: $3E $00
    ld   [$C103], a                               ; $0F78: $EA $03 $C1
    ld   a, $01                                   ; $0F7B: $3E $01
    ldh  [$FFAE], a                               ; $0F7D: $E0 $AE
    ld   a, $03                                   ; $0F7F: $3E $03
    ldh  [$FF9F], a                               ; $0F81: $E0 $9F
    ld   a, $64                                   ; $0F83: $3E $64
    ldh  [hCounter], a                            ; $0F85: $E0 $B0
    ld   a, $00                                   ; $0F87: $3E $00
    ldh  [hCounter+1], a                          ; $0F89: $E0 $B1
    ld   hl, UnknownMusic2                        ; $0F8B: $21 $9B $66
    call Call_000_332E                            ; $0F8E: $CD $2E $33
    ret                                           ; $0F91: $C9


jr_000_0F92:
    cp   $03                                      ; $0F92: $FE $03
    jr   c, jr_000_0FAB                           ; $0F94: $38 $15

    cp   $08                                      ; $0F96: $FE $08
    jr   nc, jr_000_0FB8                          ; $0F98: $30 $1E

    cp   $07                                      ; $0F9A: $FE $07
    jp   z, Jump_000_1208                         ; $0F9C: $CA $08 $12

    call Call_000_2EE8                            ; $0F9F: $CD $E8 $2E
    ret  nz                                       ; $0FA2: $C0

    ld   a, $00                                   ; $0FA3: $3E $00
    ld   [$C008], a                               ; $0FA5: $EA $08 $C0
    jp   Jump_000_20F2                            ; $0FA8: $C3 $F2 $20


jr_000_0FAB:
    call Call_000_2EE8                            ; $0FAB: $CD $E8 $2E
    ret  nz                                       ; $0FAE: $C0

    ld   hl, UnknownMusic3                        ; $0FAF: $21 $B3 $66
    call Call_000_332E                            ; $0FB2: $CD $2E $33
    jp   Jump_000_27F2                            ; $0FB5: $C3 $F2 $27


jr_000_0FB8:
    call Call_000_2EE8                            ; $0FB8: $CD $E8 $2E
    ret  nz                                       ; $0FBB: $C0

    ldh  a, [$FF9F]                               ; $0FBC: $F0 $9F
    cp   $08                                      ; $0FBE: $FE $08
    jr   nz, jr_000_0FDE                          ; $0FC0: $20 $1C

    ld   a, $09                                   ; $0FC2: $3E $09
    ldh  [$FF9F], a                               ; $0FC4: $E0 $9F
    ld   a, $00                                   ; $0FC6: $3E $00

jr_000_0FC8:
    ld   hl, $C00C                                ; $0FC8: $21 $0C $C0
    ld   bc, $0004                                ; $0FCB: $01 $04 $00
    ld   d, $05                                   ; $0FCE: $16 $05

jr_000_0FD0:
    ld   [hl], a                                  ; $0FD0: $77
    add  hl, bc                                   ; $0FD1: $09
    dec  d                                        ; $0FD2: $15
    jr   nz, jr_000_0FD0                          ; $0FD3: $20 $FB

    ld   a, $70                                   ; $0FD5: $3E $70
    ldh  [hCounter], a                            ; $0FD7: $E0 $B0
    ld   a, $00                                   ; $0FD9: $3E $00
    ldh  [hCounter+1], a                          ; $0FDB: $E0 $B1
    ret                                           ; $0FDD: $C9


jr_000_0FDE:
    ldh  a, [$FFBA]                               ; $0FDE: $F0 $BA
    dec  a                                        ; $0FE0: $3D
    ldh  [$FFBA], a                               ; $0FE1: $E0 $BA
    cp   $00                                      ; $0FE3: $FE $00
    jr   z, jr_000_0FEF                           ; $0FE5: $28 $08

    ld   a, $08                                   ; $0FE7: $3E $08
    ldh  [$FF9F], a                               ; $0FE9: $E0 $9F
    ld   a, $40                                   ; $0FEB: $3E $40
    jr   jr_000_0FC8                              ; $0FED: $18 $D9

jr_000_0FEF:
    ld   a, $00                                   ; $0FEF: $3E $00
    ldh  [$FF9F], a                               ; $0FF1: $E0 $9F
    ldh  a, [hSBlocksRemaining]                   ; $0FF3: $F0 $C5
    cp   $00                                      ; $0FF5: $FE $00
    jr   nz, jr_000_0FFF                          ; $0FF7: $20 $06

    ld   hl, $FFAB                                ; $0FF9: $21 $AB $FF
    set  6, [hl]                                  ; $0FFC: $CB $F6
    ret                                           ; $0FFE: $C9


jr_000_0FFF:
    dec  a                                        ; $0FFF: $3D
    ldh  [hSBlocksRemaining], a                   ; $1000: $E0 $C5
    call Call_000_324E                            ; $1002: $CD $4E $32
    ld   a, $82                                   ; $1005: $3E $82
    ld   [$C006], a                               ; $1007: $EA $06 $C0
    ld   hl, $FFA6                                ; $100A: $21 $A6 $FF
    set  0, [hl]                                  ; $100D: $CB $C6
    ld   hl, UnknownMusic4                        ; $100F: $21 $4A $68
    call Call_000_332E                            ; $1012: $CD $2E $33
    ld   hl, $FFAB                                ; $1015: $21 $AB $FF
    set  3, [hl]                                  ; $1018: $CB $DE
    ret                                           ; $101A: $C9


Jump_000_101B:
    ldh  a, [$FF97]                               ; $101B: $F0 $97
    cp   $01                                      ; $101D: $FE $01
    jr   z, jr_000_1055                           ; $101F: $28 $34

    ldh  a, [$FF9D]                               ; $1021: $F0 $9D
    cp   $09                                      ; $1023: $FE $09
    jr   nc, jr_000_104C                          ; $1025: $30 $25

    ldh  a, [$FFAE]                               ; $1027: $F0 $AE
    cp   $01                                      ; $1029: $FE $01
    ret  z                                        ; $102B: $C8

    ldh  a, [hPressedButtonsMask]                 ; $102C: $F0 $8B
    bit  PADB_START, a                            ; $102E: $CB $5F
    ret  z                                        ; $1030: $C8

    ld   a, $01                                   ; $1031: $3E $01
    ldh  [$FFAE], a                               ; $1033: $E0 $AE
    ld   a, $09                                   ; $1035: $3E $09
    ldh  [$FF9D], a                               ; $1037: $E0 $9D
    ld   a, $83                                   ; $1039: $3E $83
    ldh  [rLCDC], a                               ; $103B: $E0 $40
    ld   hl, UnknownMusic687C                     ; $103D: $21 $7C $68
    call Call_000_332E                            ; $1040: $CD $2E $33
    ld   a, $50                                   ; $1043: $3E $50
    ldh  [hCounter], a                            ; $1045: $E0 $B0
    ld   a, $01                                   ; $1047: $3E $01
    ldh  [hCounter+1], a                          ; $1049: $E0 $B1
    ret                                           ; $104B: $C9


jr_000_104C:
    call Call_000_2EE8                            ; $104C: $CD $E8 $2E
    ret  nz                                       ; $104F: $C0

    ld   a, $03                                   ; $1050: $3E $03
    ldh  [$FF9D], a                               ; $1052: $E0 $9D
    ret                                           ; $1054: $C9


jr_000_1055:
    ldh  a, [$FFA8]                               ; $1055: $F0 $A8
    bit  3, a                                     ; $1057: $CB $5F
    jr   z, jr_000_108E                           ; $1059: $28 $33

    ldh  a, [$FF9D]                               ; $105B: $F0 $9D
    cp   $09                                      ; $105D: $FE $09
    jr   nc, jr_000_104C                          ; $105F: $30 $EB

    ldh  a, [$FFAE]                               ; $1061: $F0 $AE
    cp   $01                                      ; $1063: $FE $01
    ret  z                                        ; $1065: $C8

    ldh  a, [hPressedButtonsMask]                 ; $1066: $F0 $8B
    bit  PADB_START, a                            ; $1068: $CB $5F
    ret  z                                        ; $106A: $C8

    ld   a, $01                                   ; $106B: $3E $01
    ldh  [$FFAE], a                               ; $106D: $E0 $AE
    ld   a, $0A                                   ; $106F: $3E $0A
    call Call_000_3148                            ; $1071: $CD $48 $31
    call Call_000_3178                            ; $1074: $CD $78 $31
    ld   a, $09                                   ; $1077: $3E $09
    ldh  [$FF9D], a                               ; $1079: $E0 $9D
    ld   a, $83                                   ; $107B: $3E $83
    ldh  [rLCDC], a                               ; $107D: $E0 $40
    ld   hl, UnknownMusic687C                     ; $107F: $21 $7C $68
    call Call_000_332E                            ; $1082: $CD $2E $33
    ld   a, $50                                   ; $1085: $3E $50
    ldh  [hCounter], a                            ; $1087: $E0 $B0
    ld   a, $01                                   ; $1089: $3E $01
    ldh  [hCounter+1], a                          ; $108B: $E0 $B1
    ret                                           ; $108D: $C9


jr_000_108E:
    ldh  a, [$FF9D]                               ; $108E: $F0 $9D
    cp   $09                                      ; $1090: $FE $09
    jr   nc, jr_000_104C                          ; $1092: $30 $B8

    ldh  a, [$FFA8]                               ; $1094: $F0 $A8
    bit  0, a                                     ; $1096: $CB $47
    ret  z                                        ; $1098: $C8

    and  $FE                                      ; $1099: $E6 $FE
    ldh  [$FFA8], a                               ; $109B: $E0 $A8
    ld   a, $01                                   ; $109D: $3E $01
    call Call_000_3148                            ; $109F: $CD $48 $31
    call SerialTransferHandler                    ; $10A2: $CD $25 $31
    ld   a, $09                                   ; $10A5: $3E $09
    ldh  [$FF9D], a                               ; $10A7: $E0 $9D
    ld   a, $83                                   ; $10A9: $3E $83
    ldh  [rLCDC], a                               ; $10AB: $E0 $40
    ld   hl, UnknownMusic687C                     ; $10AD: $21 $7C $68
    call Call_000_332E                            ; $10B0: $CD $2E $33
    ld   a, $50                                   ; $10B3: $3E $50
    ldh  [hCounter], a                            ; $10B5: $E0 $B0
    ld   a, $01                                   ; $10B7: $3E $01
    ldh  [hCounter+1], a                          ; $10B9: $E0 $B1
    ret                                           ; $10BB: $C9


Jump_000_10BC:
    call Call_000_2EE8                            ; $10BC: $CD $E8 $2E
    ret  nz                                       ; $10BF: $C0

    ldh  a, [$FFA6]                               ; $10C0: $F0 $A6
    bit  2, a                                     ; $10C2: $CB $57
    jr   z, jr_000_10F0                           ; $10C4: $28 $2A

    ldh  a, [$FFBB]                               ; $10C6: $F0 $BB
    dec  a                                        ; $10C8: $3D
    ldh  [$FFBB], a                               ; $10C9: $E0 $BB
    cp   $00                                      ; $10CB: $FE $00
    jr   z, jr_000_10E6                           ; $10CD: $28 $17

    ld   a, [$C002]                               ; $10CF: $FA $02 $C0
    cp   $8F                                      ; $10D2: $FE $8F
    ld   a, $90                                   ; $10D4: $3E $90
    jr   z, :+                                    ; $10D6: $28 $02

    ld   a, $8F                                   ; $10D8: $3E $8F

:   ld   [$C002], a                               ; $10DA: $EA $02 $C0
    ld   a, $64                                   ; $10DD: $3E $64
    ldh  [hCounter], a                            ; $10DF: $E0 $B0
    ld   a, $00                                   ; $10E1: $3E $00
    ldh  [hCounter+1], a                          ; $10E3: $E0 $B1
    ret                                           ; $10E5: $C9


jr_000_10E6:
    ld   a, $89                                   ; $10E6: $3E $89
    ld   [$C002], a                               ; $10E8: $EA $02 $C0
    ld   hl, $FFA6                                ; $10EB: $21 $A6 $FF
    res  2, [hl]                                  ; $10EE: $CB $96

jr_000_10F0:
    ld   a, [$C006]                               ; $10F0: $FA $06 $C0
    cp   $82                                      ; $10F3: $FE $82
    jr   z, jr_000_1135                           ; $10F5: $28 $3E

    ld   hl, $C86C                                ; $10F7: $21 $6C $C8
    ld   d, $0C                                   ; $10FA: $16 $0C

jr_000_10FC:
    ld   a, [hl-]                                 ; $10FC: $3A
    cp   $00                                      ; $10FD: $FE $00
    jr   z, jr_000_10FC                           ; $10FF: $28 $FB

    cp   $82                                      ; $1101: $FE $82
    jr   z, jr_000_10FC                           ; $1103: $28 $F7

    inc  hl                                       ; $1105: $23
    ld   a, [$C006]                               ; $1106: $FA $06 $C0
    cp   [hl]                                     ; $1109: $BE
    jr   z, jr_000_1135                           ; $110A: $28 $29

    ld   a, [hl]                                  ; $110C: $7E
    cp   $87                                      ; $110D: $FE $87
    jr   z, jr_000_1119                           ; $110F: $28 $08

    cp   $81                                      ; $1111: $FE $81
    jr   z, jr_000_1119                           ; $1113: $28 $04

    cp   $80                                      ; $1115: $FE $80
    jr   nz, jr_000_113A                          ; $1117: $20 $21

jr_000_1119:
    push hl                                       ; $1119: $E5
    inc  hl                                       ; $111A: $23

jr_000_111B:
    ld   a, [hl]                                  ; $111B: $7E
    cp   $00                                      ; $111C: $FE $00
    jr   z, jr_000_1128                           ; $111E: $28 $08

    cp   $82                                      ; $1120: $FE $82
    jr   z, jr_000_1128                           ; $1122: $28 $04

    cp   $81                                      ; $1124: $FE $81
    jr   nz, jr_000_112E                          ; $1126: $20 $06

jr_000_1128:
    ld   bc, $0020                                ; $1128: $01 $20 $00
    add  hl, bc                                   ; $112B: $09
    jr   jr_000_111B                              ; $112C: $18 $ED

jr_000_112E:
    ld   a, [$C006]                               ; $112E: $FA $06 $C0
    cp   [hl]                                     ; $1131: $BE
    pop  hl                                       ; $1132: $E1
    jr   nz, jr_000_113A                          ; $1133: $20 $05

jr_000_1135:
    ld   a, $00                                   ; $1135: $3E $00
    ldh  [$FF9F], a                               ; $1137: $E0 $9F
    ret                                           ; $1139: $C9


jr_000_113A:
    ld   bc, $002C                                ; $113A: $01 $2C $00
    add  hl, bc                                   ; $113D: $09
    dec  d                                        ; $113E: $15
    jr   nz, jr_000_10FC                          ; $113F: $20 $BB

    ldh  a, [hBlocks+1]                           ; $1141: $F0 $CA
    cp   $00                                      ; $1143: $FE $00
    jr   nz, jr_000_11A3                          ; $1145: $20 $5C

    ldh  a, [$FFCF]                               ; $1147: $F0 $CF
    ld   hl, hBlocks                              ; $1149: $21 $C9 $FF
    cp   [hl]                                     ; $114C: $BE
    jr   c, jr_000_11A3                           ; $114D: $38 $54

    ld   a, [hl]                                  ; $114F: $7E
    cp   $04                                      ; $1150: $FE $04
    jr   nc, jr_000_1163                          ; $1152: $30 $0F

    ldh  a, [$FFAD]                               ; $1154: $F0 $AD
    cp   $00                                      ; $1156: $FE $00
    jr   nz, jr_000_1163                          ; $1158: $20 $09

    ld   hl, $FFA6                                ; $115A: $21 $A6 $FF
    set  5, [hl]                                  ; $115D: $CB $EE
    ld   hl, hSBlocksRemaining                    ; $115F: $21 $C5 $FF
    inc  [hl]                                     ; $1162: $34

Jump_000_1163:
jr_000_1163:
    call Call_000_3312                            ; $1163: $CD $12 $33
    ld   a, $02                                   ; $1166: $3E $02
    ldh  [$FFA0], a                               ; $1168: $E0 $A0
    ld   a, [$C006]                               ; $116A: $FA $06 $C0
    ld   [$C00A], a                               ; $116D: $EA $0A $C0
    ld   hl, _RAM                                 ; $1170: $21 $00 $C0
    ld   a, $80                                   ; $1173: $3E $80
    ld   [hl+], a                                 ; $1175: $22
    ld   a, $68                                   ; $1176: $3E $68
    ld   [hl+], a                                 ; $1178: $22
    ld   a, $9A                                   ; $1179: $3E $9A
    ld   [hl+], a                                 ; $117B: $22
    ld   a, $00                                   ; $117C: $3E $00
    ld   [hl+], a                                 ; $117E: $22
    ld   [hl+], a                                 ; $117F: $22
    ld   [$C008], a                               ; $1180: $EA $08 $C0
    ld   hl, $C00C                                ; $1183: $21 $0C $C0
    ld   a, $80                                   ; $1186: $3E $80
    ld   [hl+], a                                 ; $1188: $22
    ld   a, $60                                   ; $1189: $3E $60
    ld   [hl+], a                                 ; $118B: $22
    ld   a, $99                                   ; $118C: $3E $99
    ld   [hl+], a                                 ; $118E: $22
    ld   a, $50                                   ; $118F: $3E $50
    ldh  [hCounter], a                            ; $1191: $E0 $B0
    ld   a, $00                                   ; $1193: $3E $00
    ldh  [hCounter+1], a                          ; $1195: $E0 $B1
    ld   a, $03                                   ; $1197: $3E $03
    ldh  [$FFBF], a                               ; $1199: $E0 $BF
    ld   hl, UnknownMusic5FC5                     ; $119B: $21 $C5 $5F
    call Call_000_3309                            ; $119E: $CD $09 $33
    jr   jr_000_11D6                              ; $11A1: $18 $33

jr_000_11A3:
    ldh  a, [hSBlocksRemaining]                   ; $11A3: $F0 $C5
    cp   $00                                      ; $11A5: $FE $00
    jr   nz, jr_000_11E5                          ; $11A7: $20 $3C

    ld   a, $05                                   ; $11A9: $3E $05
    ldh  [$FFA0], a                               ; $11AB: $E0 $A0

Jump_000_11AD:
    ld   a, [$C006]                               ; $11AD: $FA $06 $C0
    ld   [$C00A], a                               ; $11B0: $EA $0A $C0
    ld   hl, _RAM                                 ; $11B3: $21 $00 $C0
    ld   a, $80                                   ; $11B6: $3E $80
    ld   [hl+], a                                 ; $11B8: $22
    ld   a, $68                                   ; $11B9: $3E $68
    ld   [hl+], a                                 ; $11BB: $22
    ld   a, $8C                                   ; $11BC: $3E $8C
    ld   [hl+], a                                 ; $11BE: $22
    ld   a, $00                                   ; $11BF: $3E $00
    ld   [hl+], a                                 ; $11C1: $22
    ld   [$C008], a                               ; $11C2: $EA $08 $C0
    ld   a, $80                                   ; $11C5: $3E $80
    ld   [hl+], a                                 ; $11C7: $22
    ld   a, $60                                   ; $11C8: $3E $60
    ld   [hl+], a                                 ; $11CA: $22
    ld   a, $8B                                   ; $11CB: $3E $8B
    ld   [hl+], a                                 ; $11CD: $22
    ld   a, $00                                   ; $11CE: $3E $00
    ldh  [hCounter], a                            ; $11D0: $E0 $B0
    ld   a, $30                                   ; $11D2: $3E $30
    ldh  [hCounter+1], a                          ; $11D4: $E0 $B1

jr_000_11D6:
    ld   hl, $C020                                ; $11D6: $21 $20 $C0
    call Call_000_30E5                            ; $11D9: $CD $E5 $30
    ldh  [$FF9E], a                               ; $11DC: $E0 $9E
    ldh  [$FF9F], a                               ; $11DE: $E0 $9F
    ld   a, $04                                   ; $11E0: $3E $04
    ldh  [$FF9D], a                               ; $11E2: $E0 $9D
    ret                                           ; $11E4: $C9


jr_000_11E5:
    ld   hl, $C00C                                ; $11E5: $21 $0C $C0
    ld   de, MissTextOAM                          ; $11E8: $11 $F2 $52
    ld   b, $14                                   ; $11EB: $06 $14

:   ld   a, [de]                                  ; $11ED: $1A
    ld   [hl+], a                                 ; $11EE: $22
    inc  de                                       ; $11EF: $13
    dec  b                                        ; $11F0: $05
    jr   nz, :-                                   ; $11F1: $20 $FA

    ld   a, $08                                   ; $11F3: $3E $08
    ldh  [$FF9F], a                               ; $11F5: $E0 $9F
    ld   a, $05                                   ; $11F7: $3E $05
    ldh  [$FFBA], a                               ; $11F9: $E0 $BA
    ld   hl, $FFAD                                ; $11FB: $21 $AD $FF
    inc  [hl]                                     ; $11FE: $34
    ld   a, $70                                   ; $11FF: $3E $70
    ldh  [hCounter], a                            ; $1201: $E0 $B0
    ld   a, $00                                   ; $1203: $3E $00
    ldh  [hCounter+1], a                          ; $1205: $E0 $B1
    ret                                           ; $1207: $C9


Jump_000_1208:
    call Call_000_2EE8                            ; $1208: $CD $E8 $2E
    ret  nz                                       ; $120B: $C0

    ldh  a, [$FFA6]                               ; $120C: $F0 $A6
    bit  2, a                                     ; $120E: $CB $57
    jr   z, jr_000_123C                           ; $1210: $28 $2A

    ldh  a, [$FFBB]                               ; $1212: $F0 $BB
    dec  a                                        ; $1214: $3D
    ldh  [$FFBB], a                               ; $1215: $E0 $BB
    cp   $00                                      ; $1217: $FE $00
    jr   z, jr_000_1232                           ; $1219: $28 $17

    ld   a, [$C002]                               ; $121B: $FA $02 $C0
    cp   $8F                                      ; $121E: $FE $8F
    ld   a, $90                                   ; $1220: $3E $90
    jr   z, jr_000_1226                           ; $1222: $28 $02

    ld   a, $8F                                   ; $1224: $3E $8F

jr_000_1226:
    ld   [$C002], a                               ; $1226: $EA $02 $C0
    ld   a, $64                                   ; $1229: $3E $64
    ldh  [hCounter], a                            ; $122B: $E0 $B0
    ld   a, $00                                   ; $122D: $3E $00
    ldh  [hCounter+1], a                          ; $122F: $E0 $B1
    ret                                           ; $1231: $C9


jr_000_1232:
    ld   a, $89                                   ; $1232: $3E $89
    ld   [$C002], a                               ; $1234: $EA $02 $C0
    ld   hl, $FFA6                                ; $1237: $21 $A6 $FF
    res  2, [hl]                                  ; $123A: $CB $96

jr_000_123C:
    ld   a, [$C006]                               ; $123C: $FA $06 $C0
    cp   $82                                      ; $123F: $FE $82
    jr   z, jr_000_128F                           ; $1241: $28 $4C

    ld   hl, $C86C                                ; $1243: $21 $6C $C8
    ld   d, $0C                                   ; $1246: $16 $0C

jr_000_1248:
    ld   a, [hl-]                                 ; $1248: $3A
    cp   $00                                      ; $1249: $FE $00
    jr   z, jr_000_1248                           ; $124B: $28 $FB

    cp   $82                                      ; $124D: $FE $82
    jr   z, jr_000_1248                           ; $124F: $28 $F7

    inc  hl                                       ; $1251: $23
    ld   a, [$C006]                               ; $1252: $FA $06 $C0
    cp   [hl]                                     ; $1255: $BE
    jr   z, jr_000_1281                           ; $1256: $28 $29

    ld   a, [hl]                                  ; $1258: $7E
    cp   $87                                      ; $1259: $FE $87
    jr   z, jr_000_1265                           ; $125B: $28 $08

    cp   $81                                      ; $125D: $FE $81
    jr   z, jr_000_1265                           ; $125F: $28 $04

    cp   $80                                      ; $1261: $FE $80
    jr   nz, jr_000_1294                          ; $1263: $20 $2F

jr_000_1265:
    push hl                                       ; $1265: $E5
    inc  hl                                       ; $1266: $23

jr_000_1267:
    ld   a, [hl]                                  ; $1267: $7E
    cp   $00                                      ; $1268: $FE $00
    jr   z, jr_000_1274                           ; $126A: $28 $08

    cp   $82                                      ; $126C: $FE $82
    jr   z, jr_000_1274                           ; $126E: $28 $04

    cp   $81                                      ; $1270: $FE $81
    jr   nz, jr_000_127A                          ; $1272: $20 $06

jr_000_1274:
    ld   bc, $0020                                ; $1274: $01 $20 $00
    add  hl, bc                                   ; $1277: $09
    jr   jr_000_1267                              ; $1278: $18 $ED

jr_000_127A:
    ld   a, [$C006]                               ; $127A: $FA $06 $C0
    cp   [hl]                                     ; $127D: $BE
    pop  hl                                       ; $127E: $E1
    jr   nz, jr_000_1294                          ; $127F: $20 $13

jr_000_1281:
    ldh  a, [hBlocks+1]                           ; $1281: $F0 $CA
    cp   $00                                      ; $1283: $FE $00
    jr   nz, jr_000_128F                          ; $1285: $20 $08

    ldh  a, [$FFCF]                               ; $1287: $F0 $CF
    ld   hl, hBlocks                              ; $1289: $21 $C9 $FF
    cp   [hl]                                     ; $128C: $BE
    jr   nc, jr_000_12A9                          ; $128D: $30 $1A

jr_000_128F:
    ld   a, $00                                   ; $128F: $3E $00
    ldh  [$FF9F], a                               ; $1291: $E0 $9F
    ret                                           ; $1293: $C9


jr_000_1294:
    ld   bc, $002C                                ; $1294: $01 $2C $00
    add  hl, bc                                   ; $1297: $09
    dec  d                                        ; $1298: $15
    jr   nz, jr_000_1248                          ; $1299: $20 $AD

    ldh  a, [hBlocks+1]                           ; $129B: $F0 $CA
    cp   $00                                      ; $129D: $FE $00
    jr   nz, jr_000_12AF                          ; $129F: $20 $0E

    ldh  a, [$FFCF]                               ; $12A1: $F0 $CF
    ld   hl, hBlocks                              ; $12A3: $21 $C9 $FF
    cp   [hl]                                     ; $12A6: $BE
    jr   c, jr_000_12AF                           ; $12A7: $38 $06

jr_000_12A9:
    ld   hl, $FFAB                                ; $12A9: $21 $AB $FF
    set  5, [hl]                                  ; $12AC: $CB $EE
    ret                                           ; $12AE: $C9


jr_000_12AF:
    ldh  a, [hSBlocksRemaining]                   ; $12AF: $F0 $C5
    cp   $00                                      ; $12B1: $FE $00
    jr   nz, jr_000_12C5                          ; $12B3: $20 $10

    ld   hl, $FFAB                                ; $12B5: $21 $AB $FF
    bit  2, [hl]                                  ; $12B8: $CB $56
    jr   z, jr_000_12C2                           ; $12BA: $28 $06

    ldh  a, [$FFD2]                               ; $12BC: $F0 $D2
    cp   $04                                      ; $12BE: $FE $04
    jr   nc, jr_000_12C5                          ; $12C0: $30 $03

jr_000_12C2:
    set  6, [hl]                                  ; $12C2: $CB $F6
    ret                                           ; $12C4: $C9


jr_000_12C5:
    ld   hl, $C00C                                ; $12C5: $21 $0C $C0
    ld   de, MissTextOAM                          ; $12C8: $11 $F2 $52
    ld   b, $14                                   ; $12CB: $06 $14

:   ld   a, [de]                                  ; $12CD: $1A
    ld   [hl+], a                                 ; $12CE: $22
    inc  de                                       ; $12CF: $13
    dec  b                                        ; $12D0: $05
    jr   nz, :-                                   ; $12D1: $20 $FA

    ld   a, $08                                   ; $12D3: $3E $08
    ldh  [$FF9F], a                               ; $12D5: $E0 $9F
    ld   a, $05                                   ; $12D7: $3E $05
    ldh  [$FFBA], a                               ; $12D9: $E0 $BA
    ld   a, $70                                   ; $12DB: $3E $70
    ldh  [hCounter], a                            ; $12DD: $E0 $B0
    ld   a, $00                                   ; $12DF: $3E $00
    ldh  [hCounter+1], a                          ; $12E1: $E0 $B1
    ret                                           ; $12E3: $C9


Jump_000_12E4:
    ldh  a, [hCredits]                            ; $12E4: $F0 $C4
    cp   $00                                      ; $12E6: $FE $00
    jp   nz, Jump_000_1368                        ; $12E8: $C2 $68 $13

    ldh  a, [hPressedButtonsMask]                 ; $12EB: $F0 $8B
    and  $FF                                      ; $12ED: $E6 $FF
    jr   z, :+                                    ; $12EF: $28 $18

    ldh  a, [$FFAE]                               ; $12F1: $F0 $AE
    cp   $01                                      ; $12F3: $FE $01
    jr   z, :+                                    ; $12F5: $28 $12

    ld   a, $01                                   ; $12F7: $3E $01
    ldh  [$FFAE], a                               ; $12F9: $E0 $AE
    ldh  a, [hPressedButtonsMask]                 ; $12FB: $F0 $8B
    cp   PADF_START                               ; $12FD: $FE $08
    jr   nz, :+                                   ; $12FF: $20 $08

    ld   a, $00                                   ; $1301: $3E $00
    ldh  [hCounter], a                            ; $1303: $E0 $B0
    ldh  [hCounter+1], a                          ; $1305: $E0 $B1
    jr   jr_000_130D                              ; $1307: $18 $04

:   call Call_000_2EE8                            ; $1309: $CD $E8 $2E
    ret  nz                                       ; $130C: $C0

Jump_000_130D:
jr_000_130D:
    call Call_000_3312                            ; $130D: $CD $12 $33
    ld   a, $00                                   ; $1310: $3E $00
    ldh  [$FF9D], a                               ; $1312: $E0 $9D
    ldh  [$FF9F], a                               ; $1314: $E0 $9F
    ldh  [$FF97], a                               ; $1316: $E0 $97
    ldh  [$FFDC], a                               ; $1318: $E0 $DC
    ldh  [$FFA8], a                               ; $131A: $E0 $A8
    ldh  [$FFA7], a                               ; $131C: $E0 $A7
    ldh  [$FFAB], a                               ; $131E: $E0 $AB
    ldh  a, [$FFA6]                               ; $1320: $F0 $A6
    and  $3F                                      ; $1322: $E6 $3F
    ldh  [$FFA6], a                               ; $1324: $E0 $A6
    ld   a, $01                                   ; $1326: $3E $01
    ldh  [$FFAE], a                               ; $1328: $E0 $AE
    call LCDOff                                   ; $132A: $CD $AA $2C
    call ClearScreen                              ; $132D: $CD $CA $2C
    ld   hl, $C110                                ; $1330: $21 $10 $C1
    ld   bc, $0020                                ; $1333: $01 $20 $00
    call MemClear                                 ; $1336: $CD $C1 $2C
    ld   hl, _RAM                                 ; $1339: $21 $00 $C0
    ld   bc, $00A0                                ; $133C: $01 $A0 $00
    call MemClear                                 ; $133F: $CD $C1 $2C
    ld   de, TitleScreenDrawCommands              ; $1342: $11 $3D $33
    call ExecuteDrawCommands.getNextDrawCommand   ; $1345: $CD $EC $2C
    ld   hl, vTitleScreenHiScore                  ; $1348: $21 $49 $99
    ld   de, wHiScore+6                           ; $134B: $11 $36 $C1
    ld   b, $07                                   ; $134E: $06 $07
    call MemCpyDEtoHLReverse                      ; $1350: $CD $AC $2D
    ld   b, $04                                   ; $1353: $06 $04
    ld   de, ArrowLeftSelectionOAM                ; $1355: $11 $CE $52
    call MemCpyDEtoWRAM                           ; $1358: $CD $B3 $2D
    ld   a, $83                                   ; $135B: $3E $83
    ldh  [rLCDC], a                               ; $135D: $E0 $40
    ld   a, $10                                   ; $135F: $3E $10
    ldh  [hCounter], a                            ; $1361: $E0 $B0
    ld   a, $27                                   ; $1363: $3E $27
    ldh  [hCounter+1], a                          ; $1365: $E0 $B1
    ret                                           ; $1367: $C9


Jump_000_1368:
    ldh  a, [hPressedButtonsMask]                 ; $1368: $F0 $8B
    and  $FF                                      ; $136A: $E6 $FF
    ret  z                                        ; $136C: $C8

    ldh  a, [$FFAE]                               ; $136D: $F0 $AE
    cp   $01                                      ; $136F: $FE $01
    ret  z                                        ; $1371: $C8

    ld   a, $01                                   ; $1372: $3E $01
    ldh  [$FFAE], a                               ; $1374: $E0 $AE
    ldh  a, [hPressedButtonsMask]                 ; $1376: $F0 $8B
    ld   b, $04                                   ; $1378: $06 $04
    cp   PADF_SELECT                              ; $137A: $FE $04
    jr   nz, jr_000_1397                          ; $137C: $20 $19

    ldh  a, [$FFC3]                               ; $137E: $F0 $C3
    cp   $00                                      ; $1380: $FE $00
    jr   nz, jr_000_138E                          ; $1382: $20 $0A

    ld   a, $01                                   ; $1384: $3E $01
    ldh  [$FFC3], a                               ; $1386: $E0 $C3
    ld   de, OAMBlocks.52E2                       ; $1388: $11 $E2 $52

jr_000_138B:
    jp   MemCpyDEtoWRAM                           ; $138B: $C3 $B3 $2D


jr_000_138E:
    ld   a, $00                                   ; $138E: $3E $00
    ldh  [$FFC3], a                               ; $1390: $E0 $C3
    ld   de, OAMBlocks.52DE                       ; $1392: $11 $DE $52
    jr   jr_000_138B                              ; $1395: $18 $F4

jr_000_1397:
    cp   $08                                      ; $1397: $FE $08
    ret  nz                                       ; $1399: $C0

    ldh  a, [$FFC3]                               ; $139A: $F0 $C3
    cp   $01                                      ; $139C: $FE $01
    jp   z, Jump_000_130D                         ; $139E: $CA $0D $13

    call Call_000_3312                            ; $13A1: $CD $12 $33
    ld   hl, $C110                                ; $13A4: $21 $10 $C1
    ld   bc, $0020                                ; $13A7: $01 $20 $00
    call MemClear                                 ; $13AA: $CD $C1 $2C
    ld   hl, hCredits                             ; $13AD: $21 $C4 $FF
    dec  [hl]                                     ; $13B0: $35
    ld   a, $02                                   ; $13B1: $3E $02
    ldh  [hSBlocksRemaining], a                   ; $13B3: $E0 $C5
    ld   a, $00                                   ; $13B5: $3E $00
    ldh  [$FFAC], a                               ; $13B7: $E0 $AC
    call LoadStage                                ; $13B9: $CD $55 $2D
    jp   Jump_000_0852                            ; $13BC: $C3 $52 $08


Jump_000_13BF:
    ldh  a, [$FF97]                               ; $13BF: $F0 $97
    cp   $01                                      ; $13C1: $FE $01
    jp   z, Jump_000_175B                         ; $13C3: $CA $5B $17

    ldh  a, [$FFA0]                               ; $13C6: $F0 $A0
    cp   $02                                      ; $13C8: $FE $02
    jr   c, jr_000_13DE                           ; $13CA: $38 $12

    jp   z, Jump_000_1490                         ; $13CC: $CA $90 $14

    cp   $04                                      ; $13CF: $FE $04
    jp   c, Jump_000_156D                         ; $13D1: $DA $6D $15

    jp   z, Jump_000_162A                         ; $13D4: $CA $2A $16

    cp   $06                                      ; $13D7: $FE $06
    jr   c, jr_000_13DE                           ; $13D9: $38 $03

    jp   z, Jump_000_1707                         ; $13DB: $CA $07 $17

jr_000_13DE:
    ldh  a, [hPressedButtonsMask]                 ; $13DE: $F0 $8B
    and  $FF                                      ; $13E0: $E6 $FF
    jr   z, jr_000_13FC                           ; $13E2: $28 $18

    ldh  a, [$FFAE]                               ; $13E4: $F0 $AE
    cp   $01                                      ; $13E6: $FE $01
    jr   z, jr_000_13FC                           ; $13E8: $28 $12

    ld   a, $01                                   ; $13EA: $3E $01
    ldh  [$FFAE], a                               ; $13EC: $E0 $AE
    ldh  a, [hPressedButtonsMask]                 ; $13EE: $F0 $8B
    cp   PADF_START                               ; $13F0: $FE $08
    jr   nz, jr_000_13FC                          ; $13F2: $20 $08

    ld   a, $00                                   ; $13F4: $3E $00
    ldh  [hCounter], a                            ; $13F6: $E0 $B0
    ldh  [hCounter+1], a                          ; $13F8: $E0 $B1
    jr   jr_000_1419                              ; $13FA: $18 $1D

jr_000_13FC:
    call Call_000_2EE8                            ; $13FC: $CD $E8 $2E
    jr   z, jr_000_1419                           ; $13FF: $28 $18

    ldh  a, [hCounter]                            ; $1401: $F0 $B0
    bit  5, a                                     ; $1403: $CB $6F
    ret  nz                                       ; $1405: $C0

Jump_000_1406:
    ld   a, [$C002]                               ; $1406: $FA $02 $C0
    cp   $8C                                      ; $1409: $FE $8C
    ld   a, $8E                                   ; $140B: $3E $8E
    jr   z, jr_000_1411                           ; $140D: $28 $02

    ld   a, $8C                                   ; $140F: $3E $8C

jr_000_1411:
    ld   [$C002], a                               ; $1411: $EA $02 $C0
    dec  a                                        ; $1414: $3D
    ld   [$C006], a                               ; $1415: $EA $06 $C0
    ret                                           ; $1418: $C9


Jump_000_1419:
jr_000_1419:
    call Call_000_3312                            ; $1419: $CD $12 $33
    ld   hl, wHiScore+6                           ; $141C: $21 $36 $C1
    ld   de, wScore+6                             ; $141F: $11 $26 $C1
    ld   b, $07                                   ; $1422: $06 $07

.compareHiScoreDigit:
    ld   a, [de]                                  ; $1424: $1A
    cp   [hl]                                     ; $1425: $BE
    jr   c, jr_000_143D                           ; $1426: $38 $15

    jr   nz, .newHiScore                          ; $1428: $20 $07

    dec  hl                                       ; $142A: $2B
    dec  de                                       ; $142B: $1B
    dec  b                                        ; $142C: $05
    jr   z, jr_000_143D                           ; $142D: $28 $0E

    jr   .compareHiScoreDigit                     ; $142F: $18 $F3

.newHiScore:
    ld   hl, wScore                               ; $1431: $21 $20 $C1
    ld   de, wHiScore                             ; $1434: $11 $30 $C1
    ld   bc, $0007                                ; $1437: $01 $07 $00
    call MemCpyHLtoDE                             ; $143A: $CD $D9 $2C

jr_000_143D:
    ld   a, $05                                   ; $143D: $3E $05
    ldh  [$FF9D], a                               ; $143F: $E0 $9D
    ld   a, $00                                   ; $1441: $3E $00
    ldh  [$FFA0], a                               ; $1443: $E0 $A0
    call LCDOff                                   ; $1445: $CD $AA $2C
    call ClearScreen                              ; $1448: $CD $CA $2C
    ld   hl, _RAM                                 ; $144B: $21 $00 $C0
    ld   bc, $00A0                                ; $144E: $01 $A0 $00
    call MemClear                                 ; $1451: $CD $C1 $2C
    ld   hl, UnknownMusic6619                     ; $1454: $21 $19 $66
    call Call_000_3309                            ; $1457: $CD $09 $33
    ldh  a, [hCredits]                            ; $145A: $F0 $C4
    cp   $00                                      ; $145C: $FE $00
    jr   z, jr_000_147D                           ; $145E: $28 $1D

    ld   a, $00                                   ; $1460: $3E $00
    ldh  [$FFC3], a                               ; $1462: $E0 $C3
    ld   de, ContinueScreenDrawCommand            ; $1464: $11 $BE $34
    call ExecuteDrawCommands.getNextDrawCommand   ; $1467: $CD $EC $2C
    ldh  a, [hCredits]                            ; $146A: $F0 $C4
    ld   hl, $9971                                ; $146C: $21 $71 $99
    ld   [hl], a                                  ; $146F: $77
    ld   b, $04                                   ; $1470: $06 $04
    ld   de, OAMBlocks.52DE                       ; $1472: $11 $DE $52
    call MemCpyDEtoWRAM                           ; $1475: $CD $B3 $2D
    ld   a, $83                                   ; $1478: $3E $83
    ldh  [rLCDC], a                               ; $147A: $E0 $40
    ret                                           ; $147C: $C9


jr_000_147D:
    ld   de, GameOverDrawCommand                  ; $147D: $11 $5B $34
    call ExecuteDrawCommands.getNextDrawCommand   ; $1480: $CD $EC $2C
    ld   a, $83                                   ; $1483: $3E $83
    ldh  [rLCDC], a                               ; $1485: $E0 $40
    ld   a, $10                                   ; $1487: $3E $10
    ldh  [hCounter], a                            ; $1489: $E0 $B0
    ld   a, $27                                   ; $148B: $3E $27
    ldh  [hCounter+1], a                          ; $148D: $E0 $B1
    ret                                           ; $148F: $C9


Jump_000_1490:
    call Call_000_2EE8                            ; $1490: $CD $E8 $2E
    ret  nz                                       ; $1493: $C0

    ldh  a, [$FFBE]                               ; $1494: $F0 $BE
    cp   $01                                      ; $1496: $FE $01
    jr   z, jr_000_1500                           ; $1498: $28 $66

Jump_000_149A:
    ld   a, [_RAM]                                ; $149A: $FA $00 $C0
    cp   $80                                      ; $149D: $FE $80
    jr   nz, jr_000_14D9                          ; $149F: $20 $38

    ld   a, [$C002]                               ; $14A1: $FA $02 $C0
    cp   $9A                                      ; $14A4: $FE $9A
    jr   nz, jr_000_14BB                          ; $14A6: $20 $13

    ld   a, $89                                   ; $14A8: $3E $89
    ld   [$C002], a                               ; $14AA: $EA $02 $C0
    ld   hl, $C00C                                ; $14AD: $21 $0C $C0
    ld   a, $00                                   ; $14B0: $3E $00
    ld   [hl], a                                  ; $14B2: $77
    ld   hl, UnknownMusic672C                     ; $14B3: $21 $2C $67
    call Call_000_332E                            ; $14B6: $CD $2E $33
    jr   jr_000_14D0                              ; $14B9: $18 $15

jr_000_14BB:
    cp   $89                                      ; $14BB: $FE $89
    jr   nz, jr_000_14D9                          ; $14BD: $20 $1A

    ld   a, $96                                   ; $14BF: $3E $96
    ld   [$C002], a                               ; $14C1: $EA $02 $C0
    ld   hl, $C00C                                ; $14C4: $21 $0C $C0
    ld   a, $78                                   ; $14C7: $3E $78
    ld   [hl+], a                                 ; $14C9: $22
    ld   a, $68                                   ; $14CA: $3E $68
    ld   [hl+], a                                 ; $14CC: $22
    ld   a, $95                                   ; $14CD: $3E $95
    ld   [hl+], a                                 ; $14CF: $22

Jump_000_14D0:
jr_000_14D0:
    ld   a, $11                                   ; $14D0: $3E $11
    ldh  [hCounter], a                            ; $14D2: $E0 $B0
    ld   a, $00                                   ; $14D4: $3E $00
    ldh  [hCounter+1], a                          ; $14D6: $E0 $B1
    ret                                           ; $14D8: $C9


jr_000_14D9:
    ld   a, [_RAM]                                ; $14D9: $FA $00 $C0
    dec  a                                        ; $14DC: $3D
    ld   [_RAM], a                                ; $14DD: $EA $00 $C0
    ld   hl, $C00C                                ; $14E0: $21 $0C $C0
    dec  [hl]                                     ; $14E3: $35
    ld   a, [hl]                                  ; $14E4: $7E
    cp   $74                                      ; $14E5: $FE $74
    jr   nz, jr_000_14F6                          ; $14E7: $20 $0D

    ld   a, $98                                   ; $14E9: $3E $98
    ld   [$C002], a                               ; $14EB: $EA $02 $C0
    ld   hl, $C00E                                ; $14EE: $21 $0E $C0
    ld   a, $97                                   ; $14F1: $3E $97
    ld   [hl], a                                  ; $14F3: $77
    jr   jr_000_14D0                              ; $14F4: $18 $DA

jr_000_14F6:
    cp   $60                                      ; $14F6: $FE $60
    jr   nz, jr_000_14D0                          ; $14F8: $20 $D6

    ld   a, $01                                   ; $14FA: $3E $01
    ldh  [$FFBE], a                               ; $14FC: $E0 $BE
    jr   jr_000_14D0                              ; $14FE: $18 $D0

jr_000_1500:
    ld   a, [_RAM]                                ; $1500: $FA $00 $C0
    cp   $80                                      ; $1503: $FE $80
    jr   nz, jr_000_1551                          ; $1505: $20 $4A

    ld   a, [$C002]                               ; $1507: $FA $02 $C0
    cp   $89                                      ; $150A: $FE $89
    jr   nz, jr_000_1525                          ; $150C: $20 $17

    ld   a, $9A                                   ; $150E: $3E $9A
    ld   [$C002], a                               ; $1510: $EA $02 $C0
    ld   hl, $C00C                                ; $1513: $21 $0C $C0
    ld   a, $80                                   ; $1516: $3E $80
    ld   [hl+], a                                 ; $1518: $22
    ld   a, $60                                   ; $1519: $3E $60
    ld   [hl+], a                                 ; $151B: $22
    ld   a, $99                                   ; $151C: $3E $99
    ld   [hl+], a                                 ; $151E: $22
    ld   a, $00                                   ; $151F: $3E $00
    ldh  [$FFBE], a                               ; $1521: $E0 $BE
    jr   jr_000_1539                              ; $1523: $18 $14

jr_000_1525:
    ld   a, $89                                   ; $1525: $3E $89
    ld   [$C002], a                               ; $1527: $EA $02 $C0
    ld   hl, $C00C                                ; $152A: $21 $0C $C0
    ld   a, $00                                   ; $152D: $3E $00
    ld   [hl], a                                  ; $152F: $77
    ldh  a, [$FFBF]                               ; $1530: $F0 $BF
    dec  a                                        ; $1532: $3D
    ldh  [$FFBF], a                               ; $1533: $E0 $BF
    cp   $00                                      ; $1535: $FE $00
    jr   z, jr_000_1542                           ; $1537: $28 $09

jr_000_1539:
    ld   a, $30                                   ; $1539: $3E $30
    ldh  [hCounter], a                            ; $153B: $E0 $B0
    ld   a, $00                                   ; $153D: $3E $00
    ldh  [hCounter+1], a                          ; $153F: $E0 $B1
    ret                                           ; $1541: $C9


jr_000_1542:
    ldh  [$FFBE], a                               ; $1542: $E0 $BE
    ld   a, $06                                   ; $1544: $3E $06
    ldh  [$FFA0], a                               ; $1546: $E0 $A0
    ld   a, $20                                   ; $1548: $3E $20
    ldh  [hCounter], a                            ; $154A: $E0 $B0
    ld   a, $00                                   ; $154C: $3E $00
    ldh  [hCounter+1], a                          ; $154E: $E0 $B1
    ret                                           ; $1550: $C9


Jump_000_1551:
jr_000_1551:
    inc  a                                        ; $1551: $3C
    ld   [_RAM], a                                ; $1552: $EA $00 $C0
    ld   hl, $C00C                                ; $1555: $21 $0C $C0
    inc  [hl]                                     ; $1558: $34
    ld   a, [hl]                                  ; $1559: $7E
    cp   $78                                      ; $155A: $FE $78
    jp   nz, Jump_000_14D0                        ; $155C: $C2 $D0 $14

    ld   a, $96                                   ; $155F: $3E $96
    ld   [$C002], a                               ; $1561: $EA $02 $C0
    ld   hl, $C00E                                ; $1564: $21 $0E $C0
    ld   a, $95                                   ; $1567: $3E $95
    ld   [hl], a                                  ; $1569: $77
    jp   Jump_000_14D0                            ; $156A: $C3 $D0 $14


Jump_000_156D:
    call Call_000_2EE8                            ; $156D: $CD $E8 $2E
    ret  nz                                       ; $1570: $C0

    ld   hl, hSeconds                             ; $1571: $21 $CB $FF
    ld   a, [hl]                                  ; $1574: $7E
    cp   $00                                      ; $1575: $FE $00
    jr   nz, jr_000_1595                          ; $1577: $20 $1C

    inc  hl                                       ; $1579: $23
    ld   a, [hl+]                                 ; $157A: $2A
    cp   $00                                      ; $157B: $FE $00
    jr   nz, jr_000_1585                          ; $157D: $20 $06

    inc  hl                                       ; $157F: $23
    ld   a, [hl]                                  ; $1580: $7E
    cp   $00                                      ; $1581: $FE $00
    jr   z, jr_000_15E3                           ; $1583: $28 $5E

jr_000_1585:
    ld   hl, hSeconds                             ; $1585: $21 $CB $FF
    ld   a, $09                                   ; $1588: $3E $09
    ld   [hl+], a                                 ; $158A: $22
    ld   a, [hl]                                  ; $158B: $7E
    cp   $00                                      ; $158C: $FE $00
    jr   nz, jr_000_1595                          ; $158E: $20 $05

    ld   a, $05                                   ; $1590: $3E $05
    ld   [hl+], a                                 ; $1592: $22
    inc  hl                                       ; $1593: $23
    ld   a, [hl]                                  ; $1594: $7E

jr_000_1595:
    dec  a                                        ; $1595: $3D
    ld   [hl], a                                  ; $1596: $77
    call Call_000_301A                            ; $1597: $CD $1A $30
    push hl                                       ; $159A: $E5
    ld   hl, UnknownMusic67A9                     ; $159B: $21 $A9 $67
    call Call_000_332E                            ; $159E: $CD $2E $33
    pop  de                                       ; $15A1: $D1
    ld   hl, hSeconds                             ; $15A2: $21 $CB $FF
    ld   a, [hl]                                  ; $15A5: $7E
    cp   $00                                      ; $15A6: $FE $00
    jr   nz, jr_000_15DA                          ; $15A8: $20 $30

    inc  hl                                       ; $15AA: $23
    ld   a, [hl+]                                 ; $15AB: $2A
    cp   $00                                      ; $15AC: $FE $00
    jr   nz, jr_000_15DA                          ; $15AE: $20 $2A

    inc  hl                                       ; $15B0: $23
    ld   a, [hl]                                  ; $15B1: $7E
    cp   $00                                      ; $15B2: $FE $00
    jr   nz, jr_000_15DA                          ; $15B4: $20 $24

    call Call_000_3312                            ; $15B6: $CD $12 $33
    ld   a, e                                     ; $15B9: $7B
    cp   " "                                      ; $15BA: $FE $24
    jr   nz, jr_000_15CD                          ; $15BC: $20 $0F

    ld   a, [de]                                  ; $15BE: $1A
    cp   $02                                      ; $15BF: $FE $02
    jr   z, jr_000_15C7                           ; $15C1: $28 $04

    cp   $05                                      ; $15C3: $FE $05
    jr   nz, jr_000_15D1                          ; $15C5: $20 $0A

jr_000_15C7:
    ld   hl, hSBlocksRemaining                    ; $15C7: $21 $C5 $FF
    inc  [hl]                                     ; $15CA: $34
    jr   jr_000_15D1                              ; $15CB: $18 $04

jr_000_15CD:
    cp   $25                                      ; $15CD: $FE $25
    jr   z, jr_000_15C7                           ; $15CF: $28 $F6

jr_000_15D1:
    ld   a, $64                                   ; $15D1: $3E $64
    ldh  [hCounter], a                            ; $15D3: $E0 $B0
    ld   a, $04                                   ; $15D5: $3E $04
    ldh  [hCounter+1], a                          ; $15D7: $E0 $B1
    ret                                           ; $15D9: $C9


jr_000_15DA:
    ld   a, $20                                   ; $15DA: $3E $20
    ldh  [hCounter], a                            ; $15DC: $E0 $B0
    ld   a, $00                                   ; $15DE: $3E $00
    ldh  [hCounter+1], a                          ; $15E0: $E0 $B1
    ret                                           ; $15E2: $C9


jr_000_15E3:
    ld   a, $64                                   ; $15E3: $3E $64
    ldh  [hCounter], a                            ; $15E5: $E0 $B0
    ld   a, $07                                   ; $15E7: $3E $07
    ldh  [hCounter+1], a                          ; $15E9: $E0 $B1
    ld   hl, UnknownMusic681B                     ; $15EB: $21 $1B $68
    call Call_000_332E                            ; $15EE: $CD $2E $33
    ldh  a, [hBlocks]                             ; $15F1: $F0 $C9
    ld   b, a                                     ; $15F3: $47
    ldh  a, [$FFCF]                               ; $15F4: $F0 $CF
    sub  b                                        ; $15F6: $90
    inc  a                                        ; $15F7: $3C
    ld   [$C113], a                               ; $15F8: $EA $13 $C1
    ld   hl, $C123                                ; $15FB: $21 $23 $C1

jr_000_15FE:
    add  [hl]                                     ; $15FE: $86
    cp   $0A                                      ; $15FF: $FE $0A
    jr   nc, :+                                   ; $1601: $30 $03

    ld   [hl], a                                  ; $1603: $77
    jr   jr_000_160D                              ; $1604: $18 $07

:   sub  $0A                                      ; $1606: $D6 $0A
    ld   [hl+], a                                 ; $1608: $22
    ld   a, $01                                   ; $1609: $3E $01
    jr   jr_000_15FE                              ; $160B: $18 $F1

jr_000_160D:
    ld   a, l                                     ; $160D: $7D
    cp   " "                                      ; $160E: $FE $24
    jr   nz, jr_000_1621                          ; $1610: $20 $0F

    ld   a, [hl]                                  ; $1612: $7E
    cp   $02                                      ; $1613: $FE $02
    jr   z, jr_000_161B                           ; $1615: $28 $04

    cp   $05                                      ; $1617: $FE $05
    jr   nz, jr_000_1625                          ; $1619: $20 $0A

jr_000_161B:
    ld   hl, hSBlocksRemaining                    ; $161B: $21 $C5 $FF
    inc  [hl]                                     ; $161E: $34
    jr   jr_000_1625                              ; $161F: $18 $04

jr_000_1621:
    cp   $25                                      ; $1621: $FE $25
    jr   z, jr_000_161B                           ; $1623: $28 $F6

jr_000_1625:
    ld   a, $04                                   ; $1625: $3E $04
    ldh  [$FFA0], a                               ; $1627: $E0 $A0
    ret                                           ; $1629: $C9


Jump_000_162A:
    call Call_000_2EE8                            ; $162A: $CD $E8 $2E
    ret  nz                                       ; $162D: $C0

    ldh  a, [$FFC2]                               ; $162E: $F0 $C2
    cp   $F9                                      ; $1630: $FE $F9
    jr   nz, jr_000_1644                          ; $1632: $20 $10

    ld   a, $00                                   ; $1634: $3E $00
    ldh  [$FFC2], a                               ; $1636: $E0 $C2
    ld   hl, $FFB4                                ; $1638: $21 $B4 $FF
    ld   a, $9A                                   ; $163B: $3E $9A
    ld   [hl+], a                                 ; $163D: $22
    ld   a, $02                                   ; $163E: $3E $02
    ld   [hl], a                                  ; $1640: $77
    jp   Jump_000_1419                            ; $1641: $C3 $19 $14


jr_000_1644:
    inc  a                                        ; $1644: $3C
    ldh  [$FFC2], a                               ; $1645: $E0 $C2
    ld   hl, $FFB4                                ; $1647: $21 $B4 $FF
    cp   $32                                      ; $164A: $FE $32
    jr   z, jr_000_1660                           ; $164C: $28 $12

    cp   $64                                      ; $164E: $FE $64
    jr   z, jr_000_1666                           ; $1650: $28 $14

    cp   $96                                      ; $1652: $FE $96
    jr   z, jr_000_166C                           ; $1654: $28 $16

    cp   $C8                                      ; $1656: $FE $C8
    jr   nz, jr_000_1673                          ; $1658: $20 $19

    ld   a, $4D                                   ; $165A: $3E $4D
    ld   b, $01                                   ; $165C: $06 $01
    jr   jr_000_1670                              ; $165E: $18 $10

jr_000_1660:
    ld   a, $47                                   ; $1660: $3E $47
    ld   b, $02                                   ; $1662: $06 $02
    jr   jr_000_1670                              ; $1664: $18 $0A

jr_000_1666:
    ld   a, $F4                                   ; $1666: $3E $F4
    ld   b, $01                                   ; $1668: $06 $01
    jr   jr_000_1670                              ; $166A: $18 $04

jr_000_166C:
    ld   a, $A0                                   ; $166C: $3E $A0
    ld   b, $01                                   ; $166E: $06 $01

jr_000_1670:
    ld   [hl+], a                                 ; $1670: $22
    ld   a, b                                     ; $1671: $78
    ld   [hl], a                                  ; $1672: $77

jr_000_1673:
    ld   hl, hStage                               ; $1673: $21 $C6 $FF

.incrementStageNumber:
    inc  [hl]                                     ; $1676: $34
    ld   a, [hl]                                  ; $1677: $7E
    cp   $0A                                      ; $1678: $FE $0A
    jr   nz, .noCarry                             ; $167A: $20 $05

    ld   a, $00                                   ; $167C: $3E $00
    ld   [hl+], a                                 ; $167E: $22
    jr   .incrementStageNumber                    ; $167F: $18 $F5

.noCarry:
    ld   hl, $FFDC                                ; $1681: $21 $DC $FF
    inc  [hl]                                     ; $1684: $34
    ld   a, [hl]                                  ; $1685: $7E
    cp   $03                                      ; $1686: $FE $03
    jr   nz, jr_000_168D                          ; $1688: $20 $03

    ld   a, $00                                   ; $168A: $3E $00
    ld   [hl], a                                  ; $168C: $77

jr_000_168D:
    call LoadStage                                ; $168D: $CD $55 $2D
    jp   Jump_000_0852                            ; $1690: $C3 $52 $08


UnusedTransitionAnimations::
    ldh  a, [hStage+1]                            ; $1693: $F0 $C7
    cp   $00                                      ; $1695: $FE $00
    jp   z, Jump_000_0852                         ; $1697: $CA $52 $08

    ldh  a, [hStage]                              ; $169A: $F0 $C6
    cp   $01                                      ; $169C: $FE $01
    jp   nz, Jump_000_0852                        ; $169E: $C2 $52 $08

    ld   a, $00                                   ; $16A1: $3E $00
    ldh  [$FFA2], a                               ; $16A3: $E0 $A2
    ldh  a, [hStage+1]                            ; $16A5: $F0 $C7
    ldh  [$FFA1], a                               ; $16A7: $E0 $A1
    call LCDOff                                   ; $16A9: $CD $AA $2C
    call ClearScreen                              ; $16AC: $CD $CA $2C
    ld   hl, _RAM                                 ; $16AF: $21 $00 $C0
    ld   bc, $00A0                                ; $16B2: $01 $A0 $00
    call MemClear                                 ; $16B5: $CD $C1 $2C
    ld   de, UnknownDrawCommand8                  ; $16B8: $11 $50 $36
    call ExecuteDrawCommands.getNextDrawCommand   ; $16BB: $CD $EC $2C
    ldh  a, [$FFA1]                               ; $16BE: $F0 $A1
    cp   $02                                      ; $16C0: $FE $02
    jr   c, .transitionStage10                    ; $16C2: $38 $10

    jr   z, .transitionStage20                    ; $16C4: $28 $18

    cp   $03                                      ; $16C6: $FE $03
    jr   z, .transitionStage30                    ; $16C8: $28 $1E

    ld   de, TransitionStage40OAM                 ; $16CA: $11 $CA $53
    ld   b, $30                                   ; $16CD: $06 $30
    call MemCpyDEtoWRAM                           ; $16CF: $CD $B3 $2D
    jr   :+                                       ; $16D2: $18 $1C

.transitionStage10:
    ld   de, TransitionStage10OAM                 ; $16D4: $11 $06 $53
    ld   b, $30                                   ; $16D7: $06 $30
    call MemCpyDEtoWRAM                           ; $16D9: $CD $B3 $2D
    jr   :+                                       ; $16DC: $18 $12

.transitionStage20:
    ld   de, TransitionStage20OAM                 ; $16DE: $11 $42 $53
    ld   b, $20                                   ; $16E1: $06 $20
    call MemCpyDEtoWRAM                           ; $16E3: $CD $B3 $2D
    jr   :+                                       ; $16E6: $18 $08

.transitionStage30:
    ld   de, TransitionStage30OAM                 ; $16E8: $11 $62 $53
    ld   b, $30                                   ; $16EB: $06 $30
    call MemCpyDEtoWRAM                           ; $16ED: $CD $B3 $2D

:   ld   a, $06                                   ; $16F0: $3E $06
    ldh  [$FF9D], a                               ; $16F2: $E0 $9D
    ld   a, $00                                   ; $16F4: $3E $00
    ldh  [$FF9F], a                               ; $16F6: $E0 $9F
    ldh  [$FFA0], a                               ; $16F8: $E0 $A0
    ld   a, $83                                   ; $16FA: $3E $83
    ldh  [rLCDC], a                               ; $16FC: $E0 $40
    ld   a, $50                                   ; $16FE: $3E $50
    ldh  [hCounter], a                            ; $1700: $E0 $B0
    ld   a, $00                                   ; $1702: $3E $00
    ldh  [hCounter+1], a                          ; $1704: $E0 $B1
    ret                                           ; $1706: $C9


Jump_000_1707:
    call Call_000_2EE8                            ; $1707: $CD $E8 $2E
    ret  nz                                       ; $170A: $C0

    ld   hl, $C921                                ; $170B: $21 $21 $C9
    ld   b, $06                                   ; $170E: $06 $06

jr_000_1710:
    ld   a, [hl+]                                 ; $1710: $2A
    cp   $00                                      ; $1711: $FE $00
    jr   z, jr_000_173D                           ; $1713: $28 $28

    cp   $81                                      ; $1715: $FE $81
    jr   z, jr_000_173D                           ; $1717: $28 $24

    cp   $9B                                      ; $1719: $FE $9B
    jr   z, jr_000_1730                           ; $171B: $28 $13

    dec  hl                                       ; $171D: $2B
    ld   a, $9B                                   ; $171E: $3E $9B
    ld   [hl+], a                                 ; $1720: $22
    ld   hl, UnknownMusic67C3                     ; $1721: $21 $C3 $67
    call Call_000_332E                            ; $1724: $CD $2E $33
    ld   a, $A0                                   ; $1727: $3E $A0
    ldh  [hCounter], a                            ; $1729: $E0 $B0
    ld   a, $00                                   ; $172B: $3E $00
    ldh  [hCounter+1], a                          ; $172D: $E0 $B1
    ret                                           ; $172F: $C9


jr_000_1730:
    dec  hl                                       ; $1730: $2B
    ld   a, $00                                   ; $1731: $3E $00
    ld   [hl+], a                                 ; $1733: $22
    ld   a, $20                                   ; $1734: $3E $20
    ldh  [hCounter], a                            ; $1736: $E0 $B0
    ld   a, $00                                   ; $1738: $3E $00
    ldh  [hCounter+1], a                          ; $173A: $E0 $B1
    ret                                           ; $173C: $C9


jr_000_173D:
    dec  b                                        ; $173D: $05
    jr   nz, jr_000_1710                          ; $173E: $20 $D0

    ld   a, l                                     ; $1740: $7D
    and  $F0                                      ; $1741: $E6 $F0
    add  $21                                      ; $1743: $C6 $21
    cp   $E1                                      ; $1745: $FE $E1
    jr   z, jr_000_174E                           ; $1747: $28 $05

    ld   l, a                                     ; $1749: $6F
    ld   b, $06                                   ; $174A: $06 $06
    jr   jr_000_1710                              ; $174C: $18 $C2

jr_000_174E:
    ld   a, $03                                   ; $174E: $3E $03
    ldh  [$FFA0], a                               ; $1750: $E0 $A0
    ld   a, $64                                   ; $1752: $3E $64
    ldh  [hCounter], a                            ; $1754: $E0 $B0
    ld   a, $02                                   ; $1756: $3E $02
    ldh  [hCounter+1], a                          ; $1758: $E0 $B1
    ret                                           ; $175A: $C9


Jump_000_175B:
    ldh  a, [$FFA0]                               ; $175B: $F0 $A0
    cp   $03                                      ; $175D: $FE $03
    jp   nc, Jump_000_1973                        ; $175F: $D2 $73 $19

    ldh  a, [$FFA8]                               ; $1762: $F0 $A8
    bit  3, a                                     ; $1764: $CB $5F
    jp   z, Jump_000_1945                         ; $1766: $CA $45 $19

    ld   a, $80                                   ; $1769: $3E $80
    ldh  [$FFAB], a                               ; $176B: $E0 $AB
    call Call_000_2EEF                            ; $176D: $CD $EF $2E
    jp   nz, Jump_000_18C0                        ; $1770: $C2 $C0 $18

    ld   a, $06                                   ; $1773: $3E $06
    call Call_000_3148                            ; $1775: $CD $48 $31
    call Call_000_3178                            ; $1778: $CD $78 $31

Jump_000_177B:
    call Call_000_3312                            ; $177B: $CD $12 $33
    ldh  a, [$FFA0]                               ; $177E: $F0 $A0
    ldh  [$FF9B], a                               ; $1780: $E0 $9B
    ld   a, $03                                   ; $1782: $3E $03
    ldh  [$FFA0], a                               ; $1784: $E0 $A0
    call LCDOff                                   ; $1786: $CD $AA $2C
    call ClearScreen                              ; $1789: $CD $CA $2C
    ld   hl, _RAM                                 ; $178C: $21 $00 $C0
    ld   bc, $00A0                                ; $178F: $01 $A0 $00
    call MemClear                                 ; $1792: $CD $C1 $2C
    ld   de, BigBlockFrameDrawCommand             ; $1795: $11 $19 $35
    call ExecuteDrawCommands.getNextDrawCommand   ; $1798: $CD $EC $2C
    ldh  a, [$FF9B]                               ; $179B: $F0 $9B
    cp   $01                                      ; $179D: $FE $01
    jr   z, jr_000_17AF                           ; $179F: $28 $0E

    ld   de, YouLoseBigTextDrawCommand            ; $17A1: $11 $35 $36
    call ExecuteDrawCommands.getNextDrawCommand   ; $17A4: $CD $EC $2C
    ld   hl, UnknownMusic6619                     ; $17A7: $21 $19 $66
    call Call_000_3309                            ; $17AA: $CD $09 $33
    jr   jr_000_17BB                              ; $17AD: $18 $0C

jr_000_17AF:
    ld   de, YouWinBigTextDrawCommand             ; $17AF: $11 $1C $36
    call ExecuteDrawCommands.getNextDrawCommand   ; $17B2: $CD $EC $2C
    ld   hl, UnknownMusic6068                     ; $17B5: $21 $68 $60
    call Call_000_3309                            ; $17B8: $CD $09 $33

jr_000_17BB:
    ld   hl, $FF98                                ; $17BB: $21 $98 $FF
    ld   a, [hl+]                                 ; $17BE: $2A
    dec  a                                        ; $17BF: $3D
    cp   $02                                      ; $17C0: $FE $02
    jr   z, :+                                    ; $17C2: $28 $06

    dec  a                                        ; $17C4: $3D
    cp   $03                                      ; $17C5: $FE $03
    jr   z, :+                                    ; $17C7: $28 $01

    dec  a                                        ; $17C9: $3D

:   ld   e, a                                     ; $17CA: $5F
    push de                                       ; $17CB: $D5
    ld   a, [hl+]                                 ; $17CC: $2A
    ld   d, a                                     ; $17CD: $57
    push hl                                       ; $17CE: $E5
    ld   hl, $99C2                                ; $17CF: $21 $C2 $99
    push hl                                       ; $17D2: $E5
    push de                                       ; $17D3: $D5
    cp   $00                                      ; $17D4: $FE $00
    jr   z, jr_000_17FB                           ; $17D6: $28 $23

    pop  de                                       ; $17D8: $D1
    pop  hl                                       ; $17D9: $E1
    push de                                       ; $17DA: $D5

:   ld   a, $A4                                   ; $17DB: $3E $A4
    ld   [hl+], a                                 ; $17DD: $22
    inc  a                                        ; $17DE: $3C
    ld   [hl+], a                                 ; $17DF: $22
    dec  d                                        ; $17E0: $15
    jr   nz, :-                                   ; $17E1: $20 $F8

    pop  de                                       ; $17E3: $D1
    push de                                       ; $17E4: $D5
    push hl                                       ; $17E5: $E5
    ld   hl, $99E2                                ; $17E6: $21 $E2 $99

:   ld   a, $A6                                   ; $17E9: $3E $A6
    ld   [hl+], a                                 ; $17EB: $22
    inc  a                                        ; $17EC: $3C
    ld   [hl+], a                                 ; $17ED: $22
    dec  d                                        ; $17EE: $15
    jr   nz, :-                                   ; $17EF: $20 $F8

    pop  hl                                       ; $17F1: $E1
    pop  de                                       ; $17F2: $D1
    ld   a, e                                     ; $17F3: $7B
    cp   d                                        ; $17F4: $BA
    jr   z, jr_000_1811                           ; $17F5: $28 $1A

    sub  d                                        ; $17F7: $92
    ld   e, a                                     ; $17F8: $5F
    push hl                                       ; $17F9: $E5
    push de                                       ; $17FA: $D5

jr_000_17FB:
:   ld   a, $A0                                   ; $17FB: $3E $A0
    ld   [hl+], a                                 ; $17FD: $22
    inc  a                                        ; $17FE: $3C
    ld   [hl+], a                                 ; $17FF: $22
    dec  e                                        ; $1800: $1D
    jr   nz, :-                                   ; $1801: $20 $F8

    pop  de                                       ; $1803: $D1
    pop  hl                                       ; $1804: $E1
    ld   bc, $0020                                ; $1805: $01 $20 $00
    add  hl, bc                                   ; $1808: $09

:   ld   a, $A2                                   ; $1809: $3E $A2
    ld   [hl+], a                                 ; $180B: $22
    inc  a                                        ; $180C: $3C
    ld   [hl+], a                                 ; $180D: $22
    dec  e                                        ; $180E: $1D
    jr   nz, :-                                   ; $180F: $20 $F8

jr_000_1811:
    pop  hl                                       ; $1811: $E1
    pop  de                                       ; $1812: $D1
    push de                                       ; $1813: $D5
    ld   a, [hl]                                  ; $1814: $7E
    ld   d, a                                     ; $1815: $57
    ld   hl, $99CA                                ; $1816: $21 $CA $99
    push hl                                       ; $1819: $E5
    push de                                       ; $181A: $D5
    cp   $00                                      ; $181B: $FE $00
    jr   z, jr_000_1842                           ; $181D: $28 $23

    pop  de                                       ; $181F: $D1
    pop  hl                                       ; $1820: $E1
    push de                                       ; $1821: $D5

:   ld   a, $C6                                   ; $1822: $3E $C6
    ld   [hl+], a                                 ; $1824: $22
    inc  a                                        ; $1825: $3C
    ld   [hl+], a                                 ; $1826: $22
    dec  d                                        ; $1827: $15
    jr   nz, :-                                   ; $1828: $20 $F8

    pop  de                                       ; $182A: $D1
    push de                                       ; $182B: $D5
    push hl                                       ; $182C: $E5
    ld   hl, $99EA                                ; $182D: $21 $EA $99

:   ld   a, $C8                                   ; $1830: $3E $C8
    ld   [hl+], a                                 ; $1832: $22
    inc  a                                        ; $1833: $3C
    ld   [hl+], a                                 ; $1834: $22
    dec  d                                        ; $1835: $15
    jr   nz, :-                                   ; $1836: $20 $F8

    pop  hl                                       ; $1838: $E1
    pop  de                                       ; $1839: $D1
    ld   a, e                                     ; $183A: $7B
    cp   d                                        ; $183B: $BA
    jr   z, jr_000_1858                           ; $183C: $28 $1A

    sub  d                                        ; $183E: $92
    ld   e, a                                     ; $183F: $5F
    push hl                                       ; $1840: $E5
    push de                                       ; $1841: $D5

jr_000_1842:
:   ld   a, $C2                                   ; $1842: $3E $C2
    ld   [hl+], a                                 ; $1844: $22
    inc  a                                        ; $1845: $3C
    ld   [hl+], a                                 ; $1846: $22
    dec  e                                        ; $1847: $1D
    jr   nz, :-                                   ; $1848: $20 $F8

    pop  de                                       ; $184A: $D1
    pop  hl                                       ; $184B: $E1
    ld   bc, $0020                                ; $184C: $01 $20 $00
    add  hl, bc                                   ; $184F: $09

:   ld   a, $C4                                   ; $1850: $3E $C4
    ld   [hl+], a                                 ; $1852: $22
    inc  a                                        ; $1853: $3C
    ld   [hl+], a                                 ; $1854: $22
    dec  e                                        ; $1855: $1D
    jr   nz, :-                                   ; $1856: $20 $F8

jr_000_1858:
    pop  de                                       ; $1858: $D1
    ld   hl, $FF99                                ; $1859: $21 $99 $FF
    ld   a, [hl+]                                 ; $185C: $2A
    cp   e                                        ; $185D: $BB
    jr   z, jr_000_1864                           ; $185E: $28 $04

    ld   a, [hl+]                                 ; $1860: $2A
    cp   e                                        ; $1861: $BB
    jr   nz, jr_000_1889                          ; $1862: $20 $25

jr_000_1864:
    ld   a, $04                                   ; $1864: $3E $04
    ldh  [$FFA0], a                               ; $1866: $E0 $A0
    ldh  a, [$FF9B]                               ; $1868: $F0 $9B
    cp   $01                                      ; $186A: $FE $01
    jr   nz, jr_000_1878                          ; $186C: $20 $0A

    ld   de, BigBlobOAM2                          ; $186E: $11 $0A $54
    ld   b, $10                                   ; $1871: $06 $10
    call MemCpyDEtoWRAM                           ; $1873: $CD $B3 $2D
    jr   jr_000_18A5                              ; $1876: $18 $2D

jr_000_1878:
    ld   hl, $C020                                ; $1878: $21 $20 $C0
    ld   de, BigFourBlocksOAM                     ; $187B: $11 $42 $54
    ld   b, $40                                   ; $187E: $06 $40
    call MemCpyDEtoHLShort                        ; $1880: $CD $B6 $2D
    ld   a, $00                                   ; $1883: $3E $00
    ldh  [$FFBF], a                               ; $1885: $E0 $BF
    jr   jr_000_189D                              ; $1887: $18 $14

jr_000_1889:
    ld   a, $03                                   ; $1889: $3E $03
    ldh  [$FFA0], a                               ; $188B: $E0 $A0
    ldh  a, [$FF9B]                               ; $188D: $F0 $9B
    cp   $01                                      ; $188F: $FE $01
    jr   nz, jr_000_189D                          ; $1891: $20 $0A

    ld   de, BigBlobOAM1                          ; $1893: $11 $FA $53
    ld   b, $10                                   ; $1896: $06 $10
    call MemCpyDEtoWRAM                           ; $1898: $CD $B3 $2D
    jr   jr_000_18A5                              ; $189B: $18 $08

jr_000_189D:
    ld   de, BigBlobWalkingLeftOAM1               ; $189D: $11 $2A $54
    ld   b, $18                                   ; $18A0: $06 $18
    call MemCpyDEtoWRAM                           ; $18A2: $CD $B3 $2D

jr_000_18A5:
    ld   a, $88                                   ; $18A5: $3E $88
    ldh  [$FFB2], a                               ; $18A7: $E0 $B2
    ld   a, $13                                   ; $18A9: $3E $13
    ldh  [$FFB3], a                               ; $18AB: $E0 $B3
    ld   a, $30                                   ; $18AD: $3E $30
    ldh  [hCounter], a                            ; $18AF: $E0 $B0
    ld   a, $00                                   ; $18B1: $3E $00
    ldh  [hCounter+1], a                          ; $18B3: $E0 $B1
    ldh  [$FFBE], a                               ; $18B5: $E0 $BE
    ld   a, $01                                   ; $18B7: $3E $01
    ldh  [$FFBF], a                               ; $18B9: $E0 $BF
    ld   a, $83                                   ; $18BB: $3E $83
    ldh  [rLCDC], a                               ; $18BD: $E0 $40
    ret                                           ; $18BF: $C9


Jump_000_18C0:
    ldh  a, [$FFA0]                               ; $18C0: $F0 $A0
    cp   $01                                      ; $18C2: $FE $01
    jr   z, jr_000_18F4                           ; $18C4: $28 $2E

Jump_000_18C6:
    call Call_000_2EE8                            ; $18C6: $CD $E8 $2E
    ret  nz                                       ; $18C9: $C0

    ldh  a, [$FFA8]                               ; $18CA: $F0 $A8
    bit  4, a                                     ; $18CC: $CB $67
    jr   z, jr_000_18E9                           ; $18CE: $28 $19

    ldh  a, [$FFD8]                               ; $18D0: $F0 $D8
    ld   l, a                                     ; $18D2: $6F
    ldh  a, [$FFD9]                               ; $18D3: $F0 $D9
    ld   h, a                                     ; $18D5: $67
    cp   $98                                      ; $18D6: $FE $98
    jr   nz, jr_000_18DF                          ; $18D8: $20 $05

    ld   a, l                                     ; $18DA: $7D
    cp   $61                                      ; $18DB: $FE $61
    jr   z, jr_000_18E9                           ; $18DD: $28 $0A

jr_000_18DF:
    ld   bc, hMusicSpeed                          ; $18DF: $01 $E0 $FF
    add  hl, bc                                   ; $18E2: $09
    ld   a, l                                     ; $18E3: $7D
    ldh  [$FFD8], a                               ; $18E4: $E0 $D8
    ld   a, h                                     ; $18E6: $7C
    ldh  [$FFD9], a                               ; $18E7: $E0 $D9

jr_000_18E9:
    ld   a, $50                                   ; $18E9: $3E $50
    ldh  [hCounter], a                            ; $18EB: $E0 $B0
    ld   a, $00                                   ; $18ED: $3E $00
    ldh  [hCounter+1], a                          ; $18EF: $E0 $B1
    jp   Jump_000_1406                            ; $18F1: $C3 $06 $14


Jump_000_18F4:
jr_000_18F4:
    call Call_000_2EE8                            ; $18F4: $CD $E8 $2E
    ret  nz                                       ; $18F7: $C0

IF "{REGION}" == "US"
    push bc                                       ; $18F8: $C5
    ld   hl, $C010                                ; $18F9: $21 $10 $C0
    ld   b, $10                                   ; $18FC: $06 $10
    xor  a                                        ; $18FE: $AF

:   ld   [hl+], a                                 ; $18FF: $22
    dec  b                                        ; $1900: $05
    jr   nz, :-                                   ; $1901: $20 $FC

    pop  bc                                       ; $1903: $C1
ENDC
    ldh  a, [$FFBE]                               ; $1904: $F0 $BE
    cp   $01                                      ; $1906: $FE $01
    jp   nz, Jump_000_149A                        ; $1908: $C2 $9A $14

    ld   a, [_RAM]                                ; $190B: $FA $00 $C0
    cp   $80                                      ; $190E: $FE $80
    jp   nz, Jump_000_1551                        ; $1910: $C2 $51 $15

    ld   a, [$C002]                               ; $1913: $FA $02 $C0
    cp   $89                                      ; $1916: $FE $89
    jr   nz, jr_000_1931                          ; $1918: $20 $17

    ld   a, $9A                                   ; $191A: $3E $9A
    ld   [$C002], a                               ; $191C: $EA $02 $C0
    ld   hl, $C00C                                ; $191F: $21 $0C $C0
    ld   a, $80                                   ; $1922: $3E $80
    ld   [hl+], a                                 ; $1924: $22
    ld   a, $60                                   ; $1925: $3E $60
    ld   [hl+], a                                 ; $1927: $22
    ld   a, $99                                   ; $1928: $3E $99
    ld   [hl+], a                                 ; $192A: $22
    ld   a, $00                                   ; $192B: $3E $00
    ldh  [$FFBE], a                               ; $192D: $E0 $BE
    jr   jr_000_193C                              ; $192F: $18 $0B

jr_000_1931:
    ld   a, $89                                   ; $1931: $3E $89
    ld   [$C002], a                               ; $1933: $EA $02 $C0
    ld   hl, $C00C                                ; $1936: $21 $0C $C0
    ld   a, $00                                   ; $1939: $3E $00
    ld   [hl], a                                  ; $193B: $77

jr_000_193C:
    ld   a, $30                                   ; $193C: $3E $30
    ldh  [hCounter], a                            ; $193E: $E0 $B0
    ld   a, $00                                   ; $1940: $3E $00
    ldh  [hCounter+1], a                          ; $1942: $E0 $B1
    ret                                           ; $1944: $C9


Jump_000_1945:
    ld   a, $00                                   ; $1945: $3E $00
    ldh  [$FFAB], a                               ; $1947: $E0 $AB
    ldh  a, [$FFA8]                               ; $1949: $F0 $A8
    bit  0, a                                     ; $194B: $CB $47
    jr   nz, jr_000_1959                          ; $194D: $20 $0A

jr_000_194F:
    ldh  a, [$FFA0]                               ; $194F: $F0 $A0
    cp   $01                                      ; $1951: $FE $01
    jp   z, Jump_000_18F4                         ; $1953: $CA $F4 $18

    jp   Jump_000_18C6                            ; $1956: $C3 $C6 $18


jr_000_1959:
    and  $FE                                      ; $1959: $E6 $FE
    ldh  [$FFA8], a                               ; $195B: $E0 $A8
    ldh  a, [$FFAA]                               ; $195D: $F0 $AA
    cp   $06                                      ; $195F: $FE $06
    jr   nz, :+                                   ; $1961: $20 $0B

    ld   a, $01                                   ; $1963: $3E $01
    call Call_000_3148                            ; $1965: $CD $48 $31
    call SerialTransferHandler                    ; $1968: $CD $25 $31
    jp   Jump_000_177B                            ; $196B: $C3 $7B $17


:   call SerialTransferHandler                    ; $196E: $CD $25 $31
    jr   jr_000_194F                              ; $1971: $18 $DC

Jump_000_1973:
    ldh  a, [$FFA8]                               ; $1973: $F0 $A8
    bit  3, a                                     ; $1975: $CB $5F
    jr   z, jr_000_19AB                           ; $1977: $28 $32

    call Call_000_2EEF                            ; $1979: $CD $EF $2E
    jp   nz, Jump_000_19E5                        ; $197C: $C2 $E5 $19

    ldh  a, [$FFAE]                               ; $197F: $F0 $AE
    cp   $01                                      ; $1981: $FE $01
    jp   z, Jump_000_19E5                         ; $1983: $CA $E5 $19

    ldh  a, [hPressedButtonsMask]                 ; $1986: $F0 $8B
    bit  PADB_START, a                            ; $1988: $CB $5F
    jp   z, Jump_000_19E5                         ; $198A: $CA $E5 $19

    ld   a, $01                                   ; $198D: $3E $01
    ldh  [$FFAE], a                               ; $198F: $E0 $AE
    ldh  a, [$FFA0]                               ; $1991: $F0 $A0
    cp   $04                                      ; $1993: $FE $04
    jr   z, :+                                    ; $1995: $28 $06

    call Call_000_30F2                            ; $1997: $CD $F2 $30
    jp   Jump_000_09CE                            ; $199A: $C3 $CE $09


:   ld   a, $0C                                   ; $199D: $3E $0C
    call Call_000_3148                            ; $199F: $CD $48 $31
    call Call_000_3178                            ; $19A2: $CD $78 $31
    call SerialTransferHandler                    ; $19A5: $CD $25 $31
    jp   Jump_000_130D                            ; $19A8: $C3 $0D $13


jr_000_19AB:
    ldh  a, [$FFA8]                               ; $19AB: $F0 $A8
    bit  0, a                                     ; $19AD: $CB $47
    jr   z, jr_000_19E5                           ; $19AF: $28 $34

    and  $FE                                      ; $19B1: $E6 $FE
    ldh  [$FFA8], a                               ; $19B3: $E0 $A8
    ldh  a, [$FFAA]                               ; $19B5: $F0 $AA
    ld   b, a                                     ; $19B7: $47
    and  $E0                                      ; $19B8: $E6 $E0
    cp   $60                                      ; $19BA: $FE $60
    jr   nz, :+                                   ; $19BC: $20 $14

    ld   a, b                                     ; $19BE: $78
    and  $1F                                      ; $19BF: $E6 $1F
    call LoadAttractModeStage                     ; $19C1: $CD $A3 $2D
    call Call_000_30F2                            ; $19C4: $CD $F2 $30
    ld   a, $01                                   ; $19C7: $3E $01
    call Call_000_3148                            ; $19C9: $CD $48 $31
    call SerialTransferHandler                    ; $19CC: $CD $25 $31
    jp   Jump_000_09DB                            ; $19CF: $C3 $DB $09


:   ld   a, b                                     ; $19D2: $78
    cp   $0C                                      ; $19D3: $FE $0C
    jr   nz, jr_000_19E2                          ; $19D5: $20 $0B

    ld   a, $01                                   ; $19D7: $3E $01
    call Call_000_3148                            ; $19D9: $CD $48 $31
    call SerialTransferHandler                    ; $19DC: $CD $25 $31
    jp   Jump_000_130D                            ; $19DF: $C3 $0D $13


jr_000_19E2:
    call SerialTransferHandler                    ; $19E2: $CD $25 $31

Jump_000_19E5:
jr_000_19E5:
    ldh  a, [$FFA0]                               ; $19E5: $F0 $A0
    cp   $03                                      ; $19E7: $FE $03
    jp   nz, Jump_000_1A29                        ; $19E9: $C2 $29 $1A

    ldh  a, [$FF9B]                               ; $19EC: $F0 $9B
    cp   $01                                      ; $19EE: $FE $01
    jr   nz, jr_000_19FD                          ; $19F0: $20 $0B

    call Call_000_2EE8                            ; $19F2: $CD $E8 $2E
    ret  nz                                       ; $19F5: $C0

    ld   a, $00                                   ; $19F6: $3E $00
    ldh  [$FFBF], a                               ; $19F8: $E0 $BF
    jp   Jump_000_28C1                            ; $19FA: $C3 $C1 $28


jr_000_19FD:
    call Call_000_2EE8                            ; $19FD: $CD $E8 $2E
    ret  nz                                       ; $1A00: $C0

    ld   bc, $0004                                ; $1A01: $01 $04 $00
    ld   hl, $C002                                ; $1A04: $21 $02 $C0
    ld   a, [hl]                                  ; $1A07: $7E
    ld   de, UnknownTilemap54E0                   ; $1A08: $11 $E0 $54
    cp   $4F                                      ; $1A0B: $FE $4F
    jr   nz, jr_000_1A12                          ; $1A0D: $20 $03

    ld   de, UnknownTilemap54DA                   ; $1A0F: $11 $DA $54

jr_000_1A12:
    ld   a, $06                                   ; $1A12: $3E $06
    push af                                       ; $1A14: $F5

jr_000_1A15:
    ld   a, [de]                                  ; $1A15: $1A
    ld   [hl], a                                  ; $1A16: $77
    add  hl, bc                                   ; $1A17: $09
    inc  de                                       ; $1A18: $13
    pop  af                                       ; $1A19: $F1
    dec  a                                        ; $1A1A: $3D
    jr   z, jr_000_1A20                           ; $1A1B: $28 $03

    push af                                       ; $1A1D: $F5
    jr   jr_000_1A15                              ; $1A1E: $18 $F5

jr_000_1A20:
    ld   a, $00                                   ; $1A20: $3E $00
    ldh  [hCounter], a                            ; $1A22: $E0 $B0
    ld   a, $01                                   ; $1A24: $3E $01
    ldh  [hCounter+1], a                          ; $1A26: $E0 $B1
    ret                                           ; $1A28: $C9


Jump_000_1A29:
    ldh  a, [$FF9B]                               ; $1A29: $F0 $9B
    cp   $01                                      ; $1A2B: $FE $01
    jp   nz, Jump_000_1ADF                        ; $1A2D: $C2 $DF $1A

    call Call_000_2EE8                            ; $1A30: $CD $E8 $2E
    ret  nz                                       ; $1A33: $C0

    ld   bc, $0004                                ; $1A34: $01 $04 $00
    ldh  a, [$FFBF]                               ; $1A37: $F0 $BF
    bit  0, a                                     ; $1A39: $CB $47
    jp   nz, Jump_000_28C1                        ; $1A3B: $C2 $C1 $28

    cp   $04                                      ; $1A3E: $FE $04
    jr   z, jr_000_1AA0                           ; $1A40: $28 $5E

    ld   hl, $C002                                ; $1A42: $21 $02 $C0
    ld   a, [hl]                                  ; $1A45: $7E
    cp   $30                                      ; $1A46: $FE $30
    jr   nz, jr_000_1A54                          ; $1A48: $20 $0A

    ld   de, BigBlobWalkingRightOAM               ; $1A4A: $11 $82 $54
    ld   b, $20                                   ; $1A4D: $06 $20
    call MemCpyDEtoWRAM                           ; $1A4F: $CD $B3 $2D
    jr   jr_000_1A70                              ; $1A52: $18 $1C

jr_000_1A54:
    ld   hl, $C016                                ; $1A54: $21 $16 $C0
    ld   a, [hl]                                  ; $1A57: $7E
    cp   $46                                      ; $1A58: $FE $46
    jr   nz, jr_000_1A79                          ; $1A5A: $20 $1D

    ld   de, UnknownTilemap54CA                   ; $1A5C: $11 $CA $54

jr_000_1A5F:
    ld   hl, $C002                                ; $1A5F: $21 $02 $C0
    ld   a, $08                                   ; $1A62: $3E $08
    push af                                       ; $1A64: $F5

jr_000_1A65:
    ld   a, [de]                                  ; $1A65: $1A
    ld   [hl], a                                  ; $1A66: $77
    add  hl, bc                                   ; $1A67: $09
    inc  de                                       ; $1A68: $13
    pop  af                                       ; $1A69: $F1
    dec  a                                        ; $1A6A: $3D
    jr   z, jr_000_1A70                           ; $1A6B: $28 $03

    push af                                       ; $1A6D: $F5
    jr   jr_000_1A65                              ; $1A6E: $18 $F5

jr_000_1A70:
    ld   a, $A6                                   ; $1A70: $3E $A6
    ldh  [hCounter], a                            ; $1A72: $E0 $B0
    ld   a, $00                                   ; $1A74: $3E $00
    ldh  [hCounter+1], a                          ; $1A76: $E0 $B1
    ret                                           ; $1A78: $C9


jr_000_1A79:
    cp   $4C                                      ; $1A79: $FE $4C
    jr   nz, jr_000_1A82                          ; $1A7B: $20 $05

    ld   de, UnknownTilemap54D2                   ; $1A7D: $11 $D2 $54
    jr   jr_000_1A5F                              ; $1A80: $18 $DD

jr_000_1A82:
    ld   de, BigBlobOAM3                          ; $1A82: $11 $1A $54
    ld   b, $10                                   ; $1A85: $06 $10
    call MemCpyDEtoWRAM                           ; $1A87: $CD $B3 $2D
    ld   hl, $C010                                ; $1A8A: $21 $10 $C0
    ld   bc, $0010                                ; $1A8D: $01 $10 $00
    call MemClear                                 ; $1A90: $CD $C1 $2C
    ld   hl, $FFBF                                ; $1A93: $21 $BF $FF
    inc  [hl]                                     ; $1A96: $34

jr_000_1A97:
    ld   a, $30                                   ; $1A97: $3E $30
    ldh  [hCounter], a                            ; $1A99: $E0 $B0
    ld   a, $00                                   ; $1A9B: $3E $00
    ldh  [hCounter+1], a                          ; $1A9D: $E0 $B1
    ret                                           ; $1A9F: $C9


jr_000_1AA0:
    ld   hl, $C002                                ; $1AA0: $21 $02 $C0
    ld   a, [hl]                                  ; $1AA3: $7E
    cp   $30                                      ; $1AA4: $FE $30
    jr   nz, jr_000_1AB2                          ; $1AA6: $20 $0A

    ld   de, BigBlobWalkingLeftOAM2               ; $1AA8: $11 $A2 $54
    ld   b, $20                                   ; $1AAB: $06 $20
    call MemCpyDEtoWRAM                           ; $1AAD: $CD $B3 $2D
    jr   jr_000_1A70                              ; $1AB0: $18 $BE

jr_000_1AB2:

    ld   hl, $C016                                ; $1AB2: $21 $16 $C0
    ld   a, [hl]                                  ; $1AB5: $7E
    cp   $52                                      ; $1AB6: $FE $52
    jr   nz, :+                                   ; $1AB8: $20 $05

    ld   de, UnknownTilemap54CA                   ; $1ABA: $11 $CA $54
    jr   jr_000_1A5F                              ; $1ABD: $18 $A0

jr_000_1ABF:
:   cp   $4C                                      ; $1ABF: $FE $4C
    jr   nz, :+                                   ; $1AC1: $20 $05

    ld   de, BigBlobTilemaps2                     ; $1AC3: $11 $C2 $54
    jr   jr_000_1A5F                              ; $1AC6: $18 $97

jr_000_1AC8:
:   ld   de, BigBlobOAM2                          ; $1AC8: $11 $0A $54
    ld   b, $10                                   ; $1ACB: $06 $10
    call MemCpyDEtoWRAM                           ; $1ACD: $CD $B3 $2D
    ld   hl, $C010                                ; $1AD0: $21 $10 $C0
    ld   bc, $0010                                ; $1AD3: $01 $10 $00
    call MemClear                                 ; $1AD6: $CD $C1 $2C
    ld   a, $01                                   ; $1AD9: $3E $01
    ldh  [$FFBF], a                               ; $1ADB: $E0 $BF
    jr   jr_000_1A97                              ; $1ADD: $18 $B8

Jump_000_1ADF:
    call Call_000_2EE8                            ; $1ADF: $CD $E8 $2E
    ret  nz                                       ; $1AE2: $C0

    ld   hl, $FFBF                                ; $1AE3: $21 $BF $FF
    inc  [hl]                                     ; $1AE6: $34
    ld   hl, $C020                                ; $1AE7: $21 $20 $C0
    ld   bc, $0004                                ; $1AEA: $01 $04 $00
    ld   d, $10                                   ; $1AED: $16 $10

jr_000_1AEF:
    ld   a, [hl]                                  ; $1AEF: $7E
    cp   $68                                      ; $1AF0: $FE $68
    jr   z, jr_000_1AFA                           ; $1AF2: $28 $06

    add  hl, bc                                   ; $1AF4: $09
    dec  d                                        ; $1AF5: $15
    jr   nz, jr_000_1AEF                          ; $1AF6: $20 $F7

    jr   jr_000_1B0C                              ; $1AF8: $18 $12

jr_000_1AFA:
    ld   bc, $FFF8                                ; $1AFA: $01 $F8 $FF
    add  hl, bc                                   ; $1AFD: $09
    ld   bc, $0004                                ; $1AFE: $01 $04 $00
    ld   a, $A0                                   ; $1B01: $3E $A0
    ld   [hl], a                                  ; $1B03: $77
    add  hl, bc                                   ; $1B04: $09
    ld   [hl], a                                  ; $1B05: $77
    add  hl, bc                                   ; $1B06: $09
    ld   a, $A8                                   ; $1B07: $3E $A8
    ld   [hl], a                                  ; $1B09: $77
    add  hl, bc                                   ; $1B0A: $09
    ld   [hl], a                                  ; $1B0B: $77

jr_000_1B0C:
    ld   hl, $C020                                ; $1B0C: $21 $20 $C0
    ld   d, $04                                   ; $1B0F: $16 $04
    ld   e, $04                                   ; $1B11: $1E $04

jr_000_1B13:
    ld   a, [hl]                                  ; $1B13: $7E
    add  $04                                      ; $1B14: $C6 $04
    ld   [hl], a                                  ; $1B16: $77
    add  hl, bc                                   ; $1B17: $09
    dec  e                                        ; $1B18: $1D
    jr   nz, jr_000_1B13                          ; $1B19: $20 $F8

    ld   e, $04                                   ; $1B1B: $1E $04
    cp   $00                                      ; $1B1D: $FE $00
    jr   nz, jr_000_1B34                          ; $1B1F: $20 $13

    ld   bc, $FFF0                                ; $1B21: $01 $F0 $FF
    add  hl, bc                                   ; $1B24: $09
    ld   bc, $0004                                ; $1B25: $01 $04 $00
    ld   a, $1C                                   ; $1B28: $3E $1C
    ld   [hl], a                                  ; $1B2A: $77
    add  hl, bc                                   ; $1B2B: $09
    ld   [hl], a                                  ; $1B2C: $77
    add  hl, bc                                   ; $1B2D: $09
    ld   a, $24                                   ; $1B2E: $3E $24
    ld   [hl], a                                  ; $1B30: $77
    add  hl, bc                                   ; $1B31: $09
    ld   [hl], a                                  ; $1B32: $77
    add  hl, bc                                   ; $1B33: $09

jr_000_1B34:
    dec  d                                        ; $1B34: $15
    jr   nz, jr_000_1B13                          ; $1B35: $20 $DC

    ldh  a, [$FFBF]                               ; $1B37: $F0 $BF
    cp   $04                                      ; $1B39: $FE $04
    jr   nz, jr_000_1B5D                          ; $1B3B: $20 $20

    ld   a, $00                                   ; $1B3D: $3E $00
    ldh  [$FFBF], a                               ; $1B3F: $E0 $BF
    ld   hl, $C002                                ; $1B41: $21 $02 $C0
    ld   a, [hl]                                  ; $1B44: $7E
    ld   de, UnknownTilemap54E0                   ; $1B45: $11 $E0 $54
    cp   $4F                                      ; $1B48: $FE $4F
    jr   nz, jr_000_1B4F                          ; $1B4A: $20 $03

    ld   de, UnknownTilemap54DA                   ; $1B4C: $11 $DA $54

jr_000_1B4F:
    ld   a, $06                                   ; $1B4F: $3E $06
    push af                                       ; $1B51: $F5

jr_000_1B52:
    ld   a, [de]                                  ; $1B52: $1A
    ld   [hl], a                                  ; $1B53: $77
    add  hl, bc                                   ; $1B54: $09
    inc  de                                       ; $1B55: $13
    pop  af                                       ; $1B56: $F1
    dec  a                                        ; $1B57: $3D
    jr   z, jr_000_1B5D                           ; $1B58: $28 $03

    push af                                       ; $1B5A: $F5
    jr   jr_000_1B52                              ; $1B5B: $18 $F5

jr_000_1B5D:
    ld   a, $40                                   ; $1B5D: $3E $40
    ldh  [hCounter], a                            ; $1B5F: $E0 $B0
    ld   a, $00                                   ; $1B61: $3E $00
    ldh  [hCounter+1], a                          ; $1B63: $E0 $B1
    ret                                           ; $1B65: $C9


Jump_000_1B66:
    call Call_000_2EE8                            ; $1B66: $CD $E8 $2E
    ret  nz                                       ; $1B69: $C0

    ldh  a, [$FFA1]                               ; $1B6A: $F0 $A1
    cp   $03                                      ; $1B6C: $FE $03
    jp   z, Jump_000_1D4F                         ; $1B6E: $CA $4F $1D

    jp   nc, Jump_000_1EB3                        ; $1B71: $D2 $B3 $1E

    cp   $02                                      ; $1B74: $FE $02
    jp   z, Jump_000_1CFF                         ; $1B76: $CA $FF $1C

    ldh  a, [$FFA2]                               ; $1B79: $F0 $A2
    cp   $00                                      ; $1B7B: $FE $00
    jr   nz, jr_000_1B95                          ; $1B7D: $20 $16

Jump_000_1B7F:
    ld   hl, $C002                                ; $1B7F: $21 $02 $C0
    ld   bc, $0004                                ; $1B82: $01 $04 $00
    ld   d, $04                                   ; $1B85: $16 $04

jr_000_1B87:
    ld   a, [hl]                                  ; $1B87: $7E
    add  $24                                      ; $1B88: $C6 $24
    ld   [hl], a                                  ; $1B8A: $77
    add  hl, bc                                   ; $1B8B: $09
    dec  d                                        ; $1B8C: $15
    jr   nz, jr_000_1B87                          ; $1B8D: $20 $F8

    ld   a, $01                                   ; $1B8F: $3E $01
    ldh  [$FFA2], a                               ; $1B91: $E0 $A2
    jr   jr_000_1B99                              ; $1B93: $18 $04

jr_000_1B95:
    cp   $01                                      ; $1B95: $FE $01
    jr   nz, jr_000_1BDD                          ; $1B97: $20 $44

jr_000_1B99:
    ld   hl, $C011                                ; $1B99: $21 $11 $C0
    ld   bc, $0004                                ; $1B9C: $01 $04 $00
    ld   d, $04                                   ; $1B9F: $16 $04

jr_000_1BA1:
    ld   a, [hl]                                  ; $1BA1: $7E
    dec  a                                        ; $1BA2: $3D
    ld   [hl], a                                  ; $1BA3: $77
    add  hl, bc                                   ; $1BA4: $09
    dec  d                                        ; $1BA5: $15
    jr   nz, jr_000_1BA1                          ; $1BA6: $20 $F9

    cp   $50                                      ; $1BA8: $FE $50
    jr   z, jr_000_1BB5                           ; $1BAA: $28 $09

Jump_000_1BAC:
jr_000_1BAC:
    ld   a, $50                                   ; $1BAC: $3E $50
    ldh  [hCounter], a                            ; $1BAE: $E0 $B0
    ld   a, $00                                   ; $1BB0: $3E $00
    ldh  [hCounter+1], a                          ; $1BB2: $E0 $B1
    ret                                           ; $1BB4: $C9


jr_000_1BB5:
    ld   hl, $C002                                ; $1BB5: $21 $02 $C0
    ld   d, $04                                   ; $1BB8: $16 $04

jr_000_1BBA:
    ld   a, [hl]                                  ; $1BBA: $7E
    sub  $24                                      ; $1BBB: $D6 $24
    ld   [hl], a                                  ; $1BBD: $77
    add  hl, bc                                   ; $1BBE: $09
    dec  d                                        ; $1BBF: $15
    jr   nz, jr_000_1BBA                          ; $1BC0: $20 $F8

    ld   hl, $C020                                ; $1BC2: $21 $20 $C0
    ld   d, $04                                   ; $1BC5: $16 $04

jr_000_1BC7:
    ld   a, [hl]                                  ; $1BC7: $7E
    sub  $08                                      ; $1BC8: $D6 $08
    ld   [hl], a                                  ; $1BCA: $77
    add  hl, bc                                   ; $1BCB: $09
    dec  d                                        ; $1BCC: $15
    jr   nz, jr_000_1BC7                          ; $1BCD: $20 $F8

    ld   de, UnknownOAM5336                       ; $1BCF: $11 $36 $53
    ld   b, $0C                                   ; $1BD2: $06 $0C
    call MemCpyDEtoHLShort                        ; $1BD4: $CD $B6 $2D
    ld   a, $02                                   ; $1BD7: $3E $02
    ldh  [$FFA2], a                               ; $1BD9: $E0 $A2
    jr   jr_000_1BAC                              ; $1BDB: $18 $CF

jr_000_1BDD:
    cp   $02                                      ; $1BDD: $FE $02
    jp   nz, Jump_000_1C6B                        ; $1BDF: $C2 $6B $1C

    ld   hl, _RAM                                 ; $1BE2: $21 $00 $C0
    ld   bc, $0004                                ; $1BE5: $01 $04 $00
    ld   d, $04                                   ; $1BE8: $16 $04
    ldh  a, [$FFBE]                               ; $1BEA: $F0 $BE
    cp   $01                                      ; $1BEC: $FE $01
    jr   z, jr_000_1C02                           ; $1BEE: $28 $12

jr_000_1BF0:
    ld   a, [hl]                                  ; $1BF0: $7E
    sub  $02                                      ; $1BF1: $D6 $02
    ld   [hl], a                                  ; $1BF3: $77
    add  hl, bc                                   ; $1BF4: $09
    dec  d                                        ; $1BF5: $15
    jr   nz, jr_000_1BF0                          ; $1BF6: $20 $F8

    cp   $50                                      ; $1BF8: $FE $50
    jr   nz, jr_000_1C23                          ; $1BFA: $20 $27

    ld   a, $01                                   ; $1BFC: $3E $01
    ldh  [$FFBE], a                               ; $1BFE: $E0 $BE
    jr   jr_000_1C23                              ; $1C00: $18 $21

jr_000_1C02:
    ld   a, [hl]                                  ; $1C02: $7E
    add  $02                                      ; $1C03: $C6 $02
    ld   [hl], a                                  ; $1C05: $77
    add  hl, bc                                   ; $1C06: $09
    dec  d                                        ; $1C07: $15
    jr   nz, jr_000_1C02                          ; $1C08: $20 $F8

    cp   $68                                      ; $1C0A: $FE $68
    jr   nz, jr_000_1C23                          ; $1C0C: $20 $15

    ld   hl, $C002                                ; $1C0E: $21 $02 $C0
    ld   d, $04                                   ; $1C11: $16 $04

jr_000_1C13:
    ld   a, [hl]                                  ; $1C13: $7E
    add  $24                                      ; $1C14: $C6 $24
    ld   [hl], a                                  ; $1C16: $77
    add  hl, bc                                   ; $1C17: $09
    dec  d                                        ; $1C18: $15
    jr   nz, jr_000_1C13                          ; $1C19: $20 $F8

    ld   a, $00                                   ; $1C1B: $3E $00
    ldh  [$FFBE], a                               ; $1C1D: $E0 $BE
    ld   a, $03                                   ; $1C1F: $3E $03
    ldh  [$FFA2], a                               ; $1C21: $E0 $A2

Jump_000_1C23:
jr_000_1C23:
    ld   hl, $C011                                ; $1C23: $21 $11 $C0
    ld   bc, $0004                                ; $1C26: $01 $04 $00
    ld   d, $0B                                   ; $1C29: $16 $0B

jr_000_1C2B:
    ld   a, [hl]                                  ; $1C2B: $7E
    dec  a                                        ; $1C2C: $3D
    ld   [hl], a                                  ; $1C2D: $77
    cp   $00                                      ; $1C2E: $FE $00
    jr   nz, jr_000_1C36                          ; $1C30: $20 $04

    dec  hl                                       ; $1C32: $2B
    ld   a, $00                                   ; $1C33: $3E $00
    ld   [hl+], a                                 ; $1C35: $22

jr_000_1C36:
    add  hl, bc                                   ; $1C36: $09
    dec  d                                        ; $1C37: $15
    jr   nz, jr_000_1C2B                          ; $1C38: $20 $F1

    ld   hl, $C031                                ; $1C3A: $21 $31 $C0
    ld   bc, $0004                                ; $1C3D: $01 $04 $00
    ld   a, [hl+]                                 ; $1C40: $2A
    bit  0, a                                     ; $1C41: $CB $47
    jp   nz, Jump_000_1BAC                        ; $1C43: $C2 $AC $1B

    ld   a, [hl]                                  ; $1C46: $7E
    cp   $59                                      ; $1C47: $FE $59
    jr   z, jr_000_1C5D                           ; $1C49: $28 $12

    cp   $5D                                      ; $1C4B: $FE $5D
    jr   z, jr_000_1C5D                           ; $1C4D: $28 $0E

    ld   a, $5D                                   ; $1C4F: $3E $5D
    ld   [hl], a                                  ; $1C51: $77
    add  hl, bc                                   ; $1C52: $09
    ld   a, $5E                                   ; $1C53: $3E $5E
    ld   [hl], a                                  ; $1C55: $77
    add  hl, bc                                   ; $1C56: $09
    ld   a, $24                                   ; $1C57: $3E $24
    ld   [hl], a                                  ; $1C59: $77
    jp   Jump_000_1BAC                            ; $1C5A: $C3 $AC $1B


jr_000_1C5D:
    ld   a, $5A                                   ; $1C5D: $3E $5A
    ld   [hl], a                                  ; $1C5F: $77
    add  hl, bc                                   ; $1C60: $09
    ld   a, $5B                                   ; $1C61: $3E $5B
    ld   [hl], a                                  ; $1C63: $77
    add  hl, bc                                   ; $1C64: $09
    ld   a, $5C                                   ; $1C65: $3E $5C
    ld   [hl], a                                  ; $1C67: $77
    jp   Jump_000_1BAC                            ; $1C68: $C3 $AC $1B


Jump_000_1C6B:
    ld   hl, _RAM                                 ; $1C6B: $21 $00 $C0
    ld   bc, $0003                                ; $1C6E: $01 $03 $00
    ld   d, $04                                   ; $1C71: $16 $04
    cp   $03                                      ; $1C73: $FE $03
    jr   nz, jr_000_1CAD                          ; $1C75: $20 $36

    ldh  a, [$FFBE]                               ; $1C77: $F0 $BE
    cp   $01                                      ; $1C79: $FE $01
    jr   z, jr_000_1C92                           ; $1C7B: $28 $15

jr_000_1C7D:
    ld   a, [hl]                                  ; $1C7D: $7E
    sub  $02                                      ; $1C7E: $D6 $02
    ld   [hl+], a                                 ; $1C80: $22
    ld   a, [hl]                                  ; $1C81: $7E
    dec  a                                        ; $1C82: $3D
    ld   [hl], a                                  ; $1C83: $77
    add  hl, bc                                   ; $1C84: $09
    dec  d                                        ; $1C85: $15
    jr   nz, jr_000_1C7D                          ; $1C86: $20 $F5

    cp   $70                                      ; $1C88: $FE $70
    jr   nz, jr_000_1C23                          ; $1C8A: $20 $97

    ld   a, $01                                   ; $1C8C: $3E $01
    ldh  [$FFBE], a                               ; $1C8E: $E0 $BE
    jr   jr_000_1C23                              ; $1C90: $18 $91

jr_000_1C92:
    ld   a, [hl]                                  ; $1C92: $7E
    add  $02                                      ; $1C93: $C6 $02
    ld   [hl+], a                                 ; $1C95: $22
    ld   a, [hl]                                  ; $1C96: $7E
    dec  a                                        ; $1C97: $3D
    ld   [hl], a                                  ; $1C98: $77
    add  hl, bc                                   ; $1C99: $09
    dec  d                                        ; $1C9A: $15
    jr   nz, jr_000_1C92                          ; $1C9B: $20 $F5

    cp   $60                                      ; $1C9D: $FE $60
    jp   nz, Jump_000_1C23                        ; $1C9F: $C2 $23 $1C

    ld   a, $00                                   ; $1CA2: $3E $00
    ldh  [$FFBE], a                               ; $1CA4: $E0 $BE
    ld   a, $04                                   ; $1CA6: $3E $04
    ldh  [$FFA2], a                               ; $1CA8: $E0 $A2
    jp   Jump_000_1C23                            ; $1CAA: $C3 $23 $1C


jr_000_1CAD:
    cp   $04                                      ; $1CAD: $FE $04
    jr   nz, jr_000_1CEB                          ; $1CAF: $20 $3A

    ldh  a, [$FFBE]                               ; $1CB1: $F0 $BE
    cp   $01                                      ; $1CB3: $FE $01
    jr   z, jr_000_1CCF                           ; $1CB5: $28 $18

jr_000_1CB7:
    ld   a, [hl]                                  ; $1CB7: $7E
    sub  $04                                      ; $1CB8: $D6 $04
    ld   [hl+], a                                 ; $1CBA: $22
    ld   a, [hl]                                  ; $1CBB: $7E
    sub  $02                                      ; $1CBC: $D6 $02
    ld   [hl], a                                  ; $1CBE: $77
    add  hl, bc                                   ; $1CBF: $09
    dec  d                                        ; $1CC0: $15
    jr   nz, jr_000_1CB7                          ; $1CC1: $20 $F4

    cp   $48                                      ; $1CC3: $FE $48
    jp   nz, Jump_000_1C23                        ; $1CC5: $C2 $23 $1C

    ld   a, $01                                   ; $1CC8: $3E $01
    ldh  [$FFBE], a                               ; $1CCA: $E0 $BE
    jp   Jump_000_1C23                            ; $1CCC: $C3 $23 $1C


jr_000_1CCF:
    ld   a, [hl]                                  ; $1CCF: $7E
    add  $04                                      ; $1CD0: $C6 $04
    ld   [hl+], a                                 ; $1CD2: $22
    ld   a, [hl]                                  ; $1CD3: $7E
    sub  $02                                      ; $1CD4: $D6 $02
    ld   [hl], a                                  ; $1CD6: $77
    add  hl, bc                                   ; $1CD7: $09
    dec  d                                        ; $1CD8: $15
    jr   nz, jr_000_1CCF                          ; $1CD9: $20 $F4

    cp   $30                                      ; $1CDB: $FE $30
    jp   nz, Jump_000_1C23                        ; $1CDD: $C2 $23 $1C

    ld   a, $00                                   ; $1CE0: $3E $00
    ldh  [$FFBE], a                               ; $1CE2: $E0 $BE
    ld   a, $05                                   ; $1CE4: $3E $05
    ldh  [$FFA2], a                               ; $1CE6: $E0 $A2
    jp   Jump_000_1C23                            ; $1CE8: $C3 $23 $1C


jr_000_1CEB:
    ld   a, [hl]                                  ; $1CEB: $7E
    sub  $04                                      ; $1CEC: $D6 $04
    ld   [hl+], a                                 ; $1CEE: $22
    ld   a, [hl]                                  ; $1CEF: $7E
    sub  $02                                      ; $1CF0: $D6 $02
    ld   [hl], a                                  ; $1CF2: $77
    add  hl, bc                                   ; $1CF3: $09
    dec  d                                        ; $1CF4: $15
    jr   nz, jr_000_1CEB                          ; $1CF5: $20 $F4

    cp   $00                                      ; $1CF7: $FE $00
    jp   nz, Jump_000_1C23                        ; $1CF9: $C2 $23 $1C

    jp   Jump_000_0852                            ; $1CFC: $C3 $52 $08


Jump_000_1CFF:
    ldh  a, [$FFA2]                               ; $1CFF: $F0 $A2
    cp   $00                                      ; $1D01: $FE $00
    jp   z, Jump_000_1B7F                         ; $1D03: $CA $7F $1B

    cp   $01                                      ; $1D06: $FE $01
    jr   nz, jr_000_1D39                          ; $1D08: $20 $2F

    ld   hl, $C011                                ; $1D0A: $21 $11 $C0
    ld   bc, $0004                                ; $1D0D: $01 $04 $00
    ld   d, $04                                   ; $1D10: $16 $04

jr_000_1D12:
    ld   a, [hl]                                  ; $1D12: $7E
    dec  a                                        ; $1D13: $3D
    ld   [hl], a                                  ; $1D14: $77
    add  hl, bc                                   ; $1D15: $09
    dec  d                                        ; $1D16: $15
    jr   nz, jr_000_1D12                          ; $1D17: $20 $F9

    cp   $00                                      ; $1D19: $FE $00
    jr   z, jr_000_1D26                           ; $1D1B: $28 $09

jr_000_1D1D:
    ld   a, $50                                   ; $1D1D: $3E $50
    ldh  [hCounter], a                            ; $1D1F: $E0 $B0
    ld   a, $00                                   ; $1D21: $3E $00
    ldh  [hCounter+1], a                          ; $1D23: $E0 $B1
    ret                                           ; $1D25: $C9


jr_000_1D26:
    ld   hl, $C002                                ; $1D26: $21 $02 $C0
    ld   d, $04                                   ; $1D29: $16 $04

jr_000_1D2B:
    ld   a, [hl]                                  ; $1D2B: $7E
    sub  $24                                      ; $1D2C: $D6 $24
    ld   [hl], a                                  ; $1D2E: $77
    add  hl, bc                                   ; $1D2F: $09
    dec  d                                        ; $1D30: $15
    jr   nz, jr_000_1D2B                          ; $1D31: $20 $F8

    ld   a, $02                                   ; $1D33: $3E $02
    ldh  [$FFA2], a                               ; $1D35: $E0 $A2
    jr   jr_000_1D1D                              ; $1D37: $18 $E4

jr_000_1D39:
    ld   hl, $C011                                ; $1D39: $21 $11 $C0
    ld   bc, $0004                                ; $1D3C: $01 $04 $00
    ld   d, $04                                   ; $1D3F: $16 $04

jr_000_1D41:
    ld   a, [hl]                                  ; $1D41: $7E
    dec  a                                        ; $1D42: $3D
    ld   [hl], a                                  ; $1D43: $77
    add  hl, bc                                   ; $1D44: $09
    dec  d                                        ; $1D45: $15
    jr   nz, jr_000_1D41                          ; $1D46: $20 $F9

    cp   $90                                      ; $1D48: $FE $90
    jr   nz, jr_000_1D1D                          ; $1D4A: $20 $D1

    jp   Jump_000_0852                            ; $1D4C: $C3 $52 $08


Jump_000_1D4F:
    ldh  a, [$FFA2]                               ; $1D4F: $F0 $A2
    cp   $00                                      ; $1D51: $FE $00
    jr   nz, jr_000_1D62                          ; $1D53: $20 $0D

    ld   a, $01                                   ; $1D55: $3E $01
    ldh  [$FFA2], a                               ; $1D57: $E0 $A2

Jump_000_1D59:
jr_000_1D59:
    ld   a, $A6                                   ; $1D59: $3E $A6
    ldh  [hCounter], a                            ; $1D5B: $E0 $B0
    ld   a, $00                                   ; $1D5D: $3E $00
    ldh  [hCounter+1], a                          ; $1D5F: $E0 $B1
    ret                                           ; $1D61: $C9


jr_000_1D62:
    cp   $01                                      ; $1D62: $FE $01
    jr   nz, jr_000_1DBC                          ; $1D64: $20 $56

    ld   a, $08                                   ; $1D66: $3E $08
    push af                                       ; $1D68: $F5
    ld   hl, $C01E                                ; $1D69: $21 $1E $C0
    ld   a, [hl]                                  ; $1D6C: $7E
    ld   hl, $C002                                ; $1D6D: $21 $02 $C0
    ld   bc, $0004                                ; $1D70: $01 $04 $00
    cp   $33                                      ; $1D73: $FE $33
    jr   nz, jr_000_1D85                          ; $1D75: $20 $0E

    ld   de, BigBlobWalkingRightTilemap           ; $1D77: $11 $9A $53

Jump_000_1D7A:
jr_000_1D7A:
    ld   a, [de]                                  ; $1D7A: $1A
    ld   [hl], a                                  ; $1D7B: $77
    add  hl, bc                                   ; $1D7C: $09
    inc  de                                       ; $1D7D: $13
    pop  af                                       ; $1D7E: $F1
    dec  a                                        ; $1D7F: $3D
    jr   z, jr_000_1D59                           ; $1D80: $28 $D7

    push af                                       ; $1D82: $F5
    jr   jr_000_1D7A                              ; $1D83: $18 $F5

jr_000_1D85:
    cp   $48                                      ; $1D85: $FE $48
    jr   nz, jr_000_1D8E                          ; $1D87: $20 $05

    ld   de, Tilemap53A2                          ; $1D89: $11 $A2 $53
    jr   jr_000_1D7A                              ; $1D8C: $18 $EC

jr_000_1D8E:
    cp   $4E                                      ; $1D8E: $FE $4E
    jr   nz, :+                                   ; $1D90: $20 $05

    ld   de, Tilemap53AA                          ; $1D92: $11 $AA $53
    jr   jr_000_1D7A                              ; $1D95: $18 $E3

:   ld   hl, $C001                                ; $1D97: $21 $01 $C0
    ld   d, $08                                   ; $1D9A: $16 $08

:   ld   a, [hl]                                  ; $1D9C: $7E
    sub  $10                                      ; $1D9D: $D6 $10
    ld   [hl], a                                  ; $1D9F: $77
    add  hl, bc                                   ; $1DA0: $09
    dec  d                                        ; $1DA1: $15
    jr   nz, :-                                   ; $1DA2: $20 $F8

    ld   hl, $FFBE                                ; $1DA4: $21 $BE $FF
    inc  [hl]                                     ; $1DA7: $34
    ld   a, [hl]                                  ; $1DA8: $7E
    cp   $04                                      ; $1DA9: $FE $04
    jr   nz, jr_000_1DB4                          ; $1DAB: $20 $07

    ld   a, $00                                   ; $1DAD: $3E $00
    ld   [hl], a                                  ; $1DAF: $77
    ld   a, $02                                   ; $1DB0: $3E $02
    ldh  [$FFA2], a                               ; $1DB2: $E0 $A2

jr_000_1DB4:
    ld   hl, $C002                                ; $1DB4: $21 $02 $C0
    ld   de, BigBlobTilemaps1                     ; $1DB7: $11 $92 $53
    jr   jr_000_1D7A                              ; $1DBA: $18 $BE

jr_000_1DBC:
    cp   $02                                      ; $1DBC: $FE $02
    jr   nz, jr_000_1E3C                          ; $1DBE: $20 $7C

    ld   hl, _RAM                                 ; $1DC0: $21 $00 $C0
    ld   bc, $0004                                ; $1DC3: $01 $04 $00
    ld   d, $08                                   ; $1DC6: $16 $08
    ldh  a, [$FFBE]                               ; $1DC8: $F0 $BE
    cp   $00                                      ; $1DCA: $FE $00
    jr   nz, jr_000_1DF8                          ; $1DCC: $20 $2A

jr_000_1DCE:
    ld   a, [hl]                                  ; $1DCE: $7E
    sub  $02                                      ; $1DCF: $D6 $02
    ld   [hl], a                                  ; $1DD1: $77
    add  hl, bc                                   ; $1DD2: $09
    dec  d                                        ; $1DD3: $15
    jr   nz, jr_000_1DCE                          ; $1DD4: $20 $F8

    cp   $58                                      ; $1DD6: $FE $58
    jp   nz, Jump_000_1D59                        ; $1DD8: $C2 $59 $1D

    ld   a, $01                                   ; $1DDB: $3E $01
    ldh  [$FFBE], a                               ; $1DDD: $E0 $BE
    ld   hl, $C001                                ; $1DDF: $21 $01 $C0
    ld   d, $0C                                   ; $1DE2: $16 $0C

jr_000_1DE4:
    ld   a, [hl]                                  ; $1DE4: $7E
    sub  $02                                      ; $1DE5: $D6 $02
    ld   [hl], a                                  ; $1DE7: $77
    add  hl, bc                                   ; $1DE8: $09
    dec  d                                        ; $1DE9: $15
    jr   nz, jr_000_1DE4                          ; $1DEA: $20 $F8

    ld   a, $08                                   ; $1DEC: $3E $08
    push af                                       ; $1DEE: $F5
    ld   hl, $C002                                ; $1DEF: $21 $02 $C0
    ld   de, Tilemap53B2                          ; $1DF2: $11 $B2 $53
    jp   Jump_000_1D7A                            ; $1DF5: $C3 $7A $1D


jr_000_1DF8:
    cp   $01                                      ; $1DF8: $FE $01
    jr   nz, jr_000_1E19                          ; $1DFA: $20 $1D

    ld   a, $02                                   ; $1DFC: $3E $02
    ldh  [$FFBE], a                               ; $1DFE: $E0 $BE
    ld   hl, $C001                                ; $1E00: $21 $01 $C0
    ld   d, $0C                                   ; $1E03: $16 $0C

jr_000_1E05:
    ld   a, [hl]                                  ; $1E05: $7E
    add  $02                                      ; $1E06: $C6 $02
    ld   [hl], a                                  ; $1E08: $77
    add  hl, bc                                   ; $1E09: $09
    dec  d                                        ; $1E0A: $15
    jr   nz, jr_000_1E05                          ; $1E0B: $20 $F8

    ld   a, $08                                   ; $1E0D: $3E $08
    push af                                       ; $1E0F: $F5
    ld   hl, $C002                                ; $1E10: $21 $02 $C0
    ld   de, BigBlobTilemaps1                     ; $1E13: $11 $92 $53
    jp   Jump_000_1D7A                            ; $1E16: $C3 $7A $1D


jr_000_1E19:
    ld   a, [hl]                                  ; $1E19: $7E
    add  $02                                      ; $1E1A: $C6 $02
    ld   [hl], a                                  ; $1E1C: $77
    add  hl, bc                                   ; $1E1D: $09
    dec  d                                        ; $1E1E: $15
    jr   nz, jr_000_1E19                          ; $1E1F: $20 $F8

    cp   $68                                      ; $1E21: $FE $68
    jp   nz, Jump_000_1D59                        ; $1E23: $C2 $59 $1D

    ld   a, $00                                   ; $1E26: $3E $00
    ldh  [$FFBE], a                               ; $1E28: $E0 $BE
    ld   a, $03                                   ; $1E2A: $3E $03
    ldh  [$FFA2], a                               ; $1E2C: $E0 $A2
    ld   hl, $C030                                ; $1E2E: $21 $30 $C0
    ld   de, BigSquareBlockOAM1                   ; $1E31: $11 $BA $53
    ld   b, $10                                   ; $1E34: $06 $10
    call MemCpyDEtoHLShort                        ; $1E36: $CD $B6 $2D
    jp   Jump_000_1D59                            ; $1E39: $C3 $59 $1D


jr_000_1E3C:
    cp   $03                                      ; $1E3C: $FE $03
    jr   nz, jr_000_1E8E                          ; $1E3E: $20 $4E

    ld   hl, $C030                                ; $1E40: $21 $30 $C0
    ld   d, $04                                   ; $1E43: $16 $04
    ld   bc, $0003                                ; $1E45: $01 $03 $00
    ldh  a, [$FFBE]                               ; $1E48: $F0 $BE
    cp   $01                                      ; $1E4A: $FE $01
    jr   z, jr_000_1E64                           ; $1E4C: $28 $16

jr_000_1E4E:
    ld   a, [hl]                                  ; $1E4E: $7E
    dec  a                                        ; $1E4F: $3D
    ld   [hl+], a                                 ; $1E50: $22
    ld   a, [hl]                                  ; $1E51: $7E
    dec  a                                        ; $1E52: $3D
    ld   [hl], a                                  ; $1E53: $77
    add  hl, bc                                   ; $1E54: $09
    dec  d                                        ; $1E55: $15
    jr   nz, jr_000_1E4E                          ; $1E56: $20 $F6

    cp   $18                                      ; $1E58: $FE $18
    jp   nz, Jump_000_1D59                        ; $1E5A: $C2 $59 $1D

    ld   a, $01                                   ; $1E5D: $3E $01
    ldh  [$FFBE], a                               ; $1E5F: $E0 $BE
    jp   Jump_000_1D59                            ; $1E61: $C3 $59 $1D


jr_000_1E64:
    ld   a, [hl]                                  ; $1E64: $7E
    inc  a                                        ; $1E65: $3C
    ld   [hl+], a                                 ; $1E66: $22
    ld   a, [hl]                                  ; $1E67: $7E
    dec  a                                        ; $1E68: $3D
    ld   [hl], a                                  ; $1E69: $77
    add  hl, bc                                   ; $1E6A: $09
    dec  d                                        ; $1E6B: $15
    jr   nz, jr_000_1E64                          ; $1E6C: $20 $F6

    ld   hl, $C030                                ; $1E6E: $21 $30 $C0
    ld   a, [hl]                                  ; $1E71: $7E
    cp   $60                                      ; $1E72: $FE $60
    jp   nz, Jump_000_1D59                        ; $1E74: $C2 $59 $1D

    ld   a, $00                                   ; $1E77: $3E $00
    ldh  [$FFBE], a                               ; $1E79: $E0 $BE
    ld   a, $04                                   ; $1E7B: $3E $04
    ldh  [$FFA2], a                               ; $1E7D: $E0 $A2
    ld   hl, $C002                                ; $1E7F: $21 $02 $C0
    ld   bc, $0004                                ; $1E82: $01 $04 $00
    ld   a, $08                                   ; $1E85: $3E $08
    push af                                       ; $1E87: $F5
    ld   de, Tilemap53AA                          ; $1E88: $11 $AA $53
    jp   Jump_000_1D7A                            ; $1E8B: $C3 $7A $1D


jr_000_1E8E:
    ld   hl, $C001                                ; $1E8E: $21 $01 $C0
    ld   bc, $0004                                ; $1E91: $01 $04 $00
    ld   d, $08                                   ; $1E94: $16 $08

jr_000_1E96:
    ld   a, [hl]                                  ; $1E96: $7E
    dec  a                                        ; $1E97: $3D
    ld   [hl], a                                  ; $1E98: $77
    add  hl, bc                                   ; $1E99: $09
    dec  d                                        ; $1E9A: $15
    jr   nz, jr_000_1E96                          ; $1E9B: $20 $F9

    cp   $00                                      ; $1E9D: $FE $00
    jr   z, jr_000_1EB0                           ; $1E9F: $28 $0F

    ld   hl, $C030                                ; $1EA1: $21 $30 $C0
    ld   d, $04                                   ; $1EA4: $16 $04

jr_000_1EA6:
    ld   a, [hl]                                  ; $1EA6: $7E
    dec  a                                        ; $1EA7: $3D
    ld   [hl], a                                  ; $1EA8: $77
    add  hl, bc                                   ; $1EA9: $09
    dec  d                                        ; $1EAA: $15
    jr   nz, jr_000_1EA6                          ; $1EAB: $20 $F9

    jp   Jump_000_1D59                            ; $1EAD: $C3 $59 $1D


jr_000_1EB0:
    jp   Jump_000_0852                            ; $1EB0: $C3 $52 $08


Jump_000_1EB3:
    ldh  a, [$FFA2]                               ; $1EB3: $F0 $A2
    cp   $00                                      ; $1EB5: $FE $00
    jp   z, Jump_000_1B7F                         ; $1EB7: $CA $7F $1B

    cp   $01                                      ; $1EBA: $FE $01
    jr   nz, jr_000_1EDF                          ; $1EBC: $20 $21

    ld   hl, $C011                                ; $1EBE: $21 $11 $C0
    ld   bc, $0004                                ; $1EC1: $01 $04 $00
    ld   d, $04                                   ; $1EC4: $16 $04

jr_000_1EC6:
    ld   a, [hl]                                  ; $1EC6: $7E
    dec  a                                        ; $1EC7: $3D
    ld   [hl], a                                  ; $1EC8: $77
    add  hl, bc                                   ; $1EC9: $09
    dec  d                                        ; $1ECA: $15
    jr   nz, jr_000_1EC6                          ; $1ECB: $20 $F9

    cp   $3B                                      ; $1ECD: $FE $3B
    jr   z, jr_000_1EDA                           ; $1ECF: $28 $09

Jump_000_1ED1:
jr_000_1ED1:
    ld   a, $50                                   ; $1ED1: $3E $50
    ldh  [hCounter], a                            ; $1ED3: $E0 $B0
    ld   a, $00                                   ; $1ED5: $3E $00
    ldh  [hCounter+1], a                          ; $1ED7: $E0 $B1
    ret                                           ; $1ED9: $C9


jr_000_1EDA:
    ld   a, $02                                   ; $1EDA: $3E $02
    ldh  [$FFA2], a                               ; $1EDC: $E0 $A2
    ret                                           ; $1EDE: $C9


jr_000_1EDF:
    cp   $02                                      ; $1EDF: $FE $02
    jr   nz, jr_000_1F36                          ; $1EE1: $20 $53

    ld   hl, $C020                                ; $1EE3: $21 $20 $C0
    ld   bc, $0003                                ; $1EE6: $01 $03 $00
    ld   d, $04                                   ; $1EE9: $16 $04
    ldh  a, [$FFBE]                               ; $1EEB: $F0 $BE
    cp   $00                                      ; $1EED: $FE $00
    jr   nz, jr_000_1F05                          ; $1EEF: $20 $14

jr_000_1EF1:
    ld   a, [hl]                                  ; $1EF1: $7E
    dec  a                                        ; $1EF2: $3D
    ld   [hl+], a                                 ; $1EF3: $22
    ld   a, [hl]                                  ; $1EF4: $7E
    inc  a                                        ; $1EF5: $3C
    ld   [hl], a                                  ; $1EF6: $77
    add  hl, bc                                   ; $1EF7: $09
    dec  d                                        ; $1EF8: $15
    jr   nz, jr_000_1EF1                          ; $1EF9: $20 $F6

    cp   $58                                      ; $1EFB: $FE $58
    jr   nz, jr_000_1ED1                          ; $1EFD: $20 $D2

    ld   a, $01                                   ; $1EFF: $3E $01
    ldh  [$FFBE], a                               ; $1F01: $E0 $BE
    jr   jr_000_1ED1                              ; $1F03: $18 $CC

jr_000_1F05:
    cp   $01                                      ; $1F05: $FE $01
    jr   nz, jr_000_1F1E                          ; $1F07: $20 $15

    inc  hl                                       ; $1F09: $23
    inc  bc                                       ; $1F0A: $03
    ld   d, $04                                   ; $1F0B: $16 $04

jr_000_1F0D:
    ld   a, [hl]                                  ; $1F0D: $7E
    inc  a                                        ; $1F0E: $3C
    ld   [hl], a                                  ; $1F0F: $77
    add  hl, bc                                   ; $1F10: $09
    dec  d                                        ; $1F11: $15
    jr   nz, jr_000_1F0D                          ; $1F12: $20 $F9

    cp   $5C                                      ; $1F14: $FE $5C
    jr   nz, jr_000_1ED1                          ; $1F16: $20 $B9

    ld   a, $02                                   ; $1F18: $3E $02
    ldh  [$FFBE], a                               ; $1F1A: $E0 $BE
    jr   jr_000_1ED1                              ; $1F1C: $18 $B3

jr_000_1F1E:
    ld   a, [hl]                                  ; $1F1E: $7E
    inc  a                                        ; $1F1F: $3C
    ld   [hl+], a                                 ; $1F20: $22
    ld   a, [hl]                                  ; $1F21: $7E
    inc  a                                        ; $1F22: $3C
    ld   [hl], a                                  ; $1F23: $77
    add  hl, bc                                   ; $1F24: $09
    dec  d                                        ; $1F25: $15
    jr   nz, jr_000_1F1E                          ; $1F26: $20 $F6

    cp   $7C                                      ; $1F28: $FE $7C
    jp   nz, Jump_000_1ED1                        ; $1F2A: $C2 $D1 $1E

    ld   a, $00                                   ; $1F2D: $3E $00
    ldh  [$FFBE], a                               ; $1F2F: $E0 $BE
    ld   a, $03                                   ; $1F31: $3E $03
    ldh  [$FFA2], a                               ; $1F33: $E0 $A2
    ret                                           ; $1F35: $C9


jr_000_1F36:
    cp   $03                                      ; $1F36: $FE $03
    jr   nz, jr_000_1F6A                          ; $1F38: $20 $30

    ld   hl, $C020                                ; $1F3A: $21 $20 $C0
    ld   bc, $0004                                ; $1F3D: $01 $04 $00
    ld   d, $04                                   ; $1F40: $16 $04

jr_000_1F42:
    ld   a, [hl]                                  ; $1F42: $7E
    inc  a                                        ; $1F43: $3C
    ld   [hl], a                                  ; $1F44: $77
    add  hl, bc                                   ; $1F45: $09
    dec  d                                        ; $1F46: $15
    jr   nz, jr_000_1F42                          ; $1F47: $20 $F9

    cp   $61                                      ; $1F49: $FE $61
    jr   z, jr_000_1F56                           ; $1F4B: $28 $09

    ld   a, $20                                   ; $1F4D: $3E $20
    ldh  [hCounter], a                            ; $1F4F: $E0 $B0
    ld   a, $00                                   ; $1F51: $3E $00
    ldh  [hCounter+1], a                          ; $1F53: $E0 $B1
    ret                                           ; $1F55: $C9


jr_000_1F56:
    ld   hl, $C002                                ; $1F56: $21 $02 $C0
    ld   bc, $0004                                ; $1F59: $01 $04 $00
    ld   a, $24                                   ; $1F5C: $3E $24
    ld   [hl], a                                  ; $1F5E: $77
    add  hl, bc                                   ; $1F5F: $09
    ld   [hl], a                                  ; $1F60: $77
    ld   a, $04                                   ; $1F61: $3E $04
    ldh  [$FFA2], a                               ; $1F63: $E0 $A2
    ld   a, $0A                                   ; $1F65: $3E $0A
    ldh  [$FFBE], a                               ; $1F67: $E0 $BE
    ret                                           ; $1F69: $C9


jr_000_1F6A:
    ld   hl, $C00A                                ; $1F6A: $21 $0A $C0
    ld   bc, $0004                                ; $1F6D: $01 $04 $00
    ld   a, [hl]                                  ; $1F70: $7E
    cp   $56                                      ; $1F71: $FE $56
    jr   nz, jr_000_1F8C                          ; $1F73: $20 $17

    add  $0D                                      ; $1F75: $C6 $0D
    ld   [hl], a                                  ; $1F77: $77
    add  hl, bc                                   ; $1F78: $09
    ld   a, [hl]                                  ; $1F79: $7E
    add  $0D                                      ; $1F7A: $C6 $0D
    ld   [hl], a                                  ; $1F7C: $77
    ld   hl, $C021                                ; $1F7D: $21 $21 $C0
    ld   d, $04                                   ; $1F80: $16 $04

jr_000_1F82:
    ld   a, [hl]                                  ; $1F82: $7E
    add  $06                                      ; $1F83: $C6 $06
    ld   [hl], a                                  ; $1F85: $77
    add  hl, bc                                   ; $1F86: $09
    dec  d                                        ; $1F87: $15
    jr   nz, jr_000_1F82                          ; $1F88: $20 $F8

    jr   jr_000_1FAB                              ; $1F8A: $18 $1F

jr_000_1F8C:
    sub  $0D                                      ; $1F8C: $D6 $0D
    ld   [hl], a                                  ; $1F8E: $77
    add  hl, bc                                   ; $1F8F: $09
    ld   a, [hl]                                  ; $1F90: $7E
    sub  $0D                                      ; $1F91: $D6 $0D
    ld   [hl], a                                  ; $1F93: $77
    ld   hl, $C021                                ; $1F94: $21 $21 $C0
    ld   d, $04                                   ; $1F97: $16 $04

jr_000_1F99:
    ld   a, [hl]                                  ; $1F99: $7E
    sub  $06                                      ; $1F9A: $D6 $06
    ld   [hl], a                                  ; $1F9C: $77
    add  hl, bc                                   ; $1F9D: $09
    dec  d                                        ; $1F9E: $15
    jr   nz, jr_000_1F99                          ; $1F9F: $20 $F8

    ldh  a, [$FFBE]                               ; $1FA1: $F0 $BE
    dec  a                                        ; $1FA3: $3D
    ldh  [$FFBE], a                               ; $1FA4: $E0 $BE
    cp   $00                                      ; $1FA6: $FE $00
    jp   z, Jump_000_0852                         ; $1FA8: $CA $52 $08

jr_000_1FAB:
    ld   a, $30                                   ; $1FAB: $3E $30
    ldh  [hCounter], a                            ; $1FAD: $E0 $B0
    ld   a, $00                                   ; $1FAF: $3E $00
    ldh  [hCounter+1], a                          ; $1FB1: $E0 $B1
    ret                                           ; $1FB3: $C9


Jump_000_1FB4:
    ldh  a, [$FFA8]                               ; $1FB4: $F0 $A8
    bit  0, a                                     ; $1FB6: $CB $47
    jr   z, jr_000_1FCD                           ; $1FB8: $28 $13

    and  $FE                                      ; $1FBA: $E6 $FE
    ldh  [$FFA8], a                               ; $1FBC: $E0 $A8
    ldh  a, [$FFAA]                               ; $1FBE: $F0 $AA
    cp   $FF                                      ; $1FC0: $FE $FF
    jr   nz, jr_000_1FCA                          ; $1FC2: $20 $06

    call SerialTransferHandler                    ; $1FC4: $CD $25 $31
    jp   Jump_000_130D                            ; $1FC7: $C3 $0D $13


jr_000_1FCA:
    call SerialTransferHandler                    ; $1FCA: $CD $25 $31

jr_000_1FCD:
    ldh  a, [hPressedButtonsMask]                 ; $1FCD: $F0 $8B
    cp   PADF_START                               ; $1FCF: $FE $08
    jp   z, Jump_000_130D                         ; $1FD1: $CA $0D $13

    ldh  a, [$FF9D]                               ; $1FD4: $F0 $9D
    cp   PADF_SELECT                              ; $1FD6: $FE $04
    jp   z, Jump_000_20A2                         ; $1FD8: $CA $A2 $20

    ldh  a, [$FFA7]                               ; $1FDB: $F0 $A7
    bit  1, a                                     ; $1FDD: $CB $4F
    jp   nz, Jump_000_20DC                        ; $1FDF: $C2 $DC $20

    call Call_000_2FFC                            ; $1FE2: $CD $FC $2F
    ldh  a, [$FF9F]                               ; $1FE5: $F0 $9F
    cp   $00                                      ; $1FE7: $FE $00
    jp   nz, Jump_000_0CF2                        ; $1FE9: $C2 $F2 $0C

    ld   a, [$C006]                               ; $1FEC: $FA $06 $C0
    cp   $82                                      ; $1FEF: $FE $82
    jr   nz, jr_000_2034                          ; $1FF1: $20 $41

    ld   a, [_RAM]                                ; $1FF3: $FA $00 $C0
    ldh  [$FF8D], a                               ; $1FF6: $E0 $8D
    ld   a, [$C001]                               ; $1FF8: $FA $01 $C0
    ldh  [$FF8E], a                               ; $1FFB: $E0 $8E
    call Call_000_2C4B                            ; $1FFD: $CD $4B $2C

jr_000_2000:
    ld   a, [hl-]                                 ; $2000: $3A
    cp   $00                                      ; $2001: $FE $00
    jr   z, jr_000_2000                           ; $2003: $28 $FB

    inc  hl                                       ; $2005: $23
    ld   a, $87                                   ; $2006: $3E $87
    cp   [hl]                                     ; $2008: $BE
    jr   z, jr_000_2015                           ; $2009: $28 $0A

    ld   a, $81                                   ; $200B: $3E $81
    cp   [hl]                                     ; $200D: $BE
    jr   z, jr_000_2015                           ; $200E: $28 $05

    ld   a, $80                                   ; $2010: $3E $80
    cp   [hl]                                     ; $2012: $BE
    jr   nz, jr_000_2027                          ; $2013: $20 $12

jr_000_2015:
    inc  hl                                       ; $2015: $23
    ld   bc, $0020                                ; $2016: $01 $20 $00

jr_000_2019:
    add  hl, bc                                   ; $2019: $09
    ld   a, [hl]                                  ; $201A: $7E
    cp   $00                                      ; $201B: $FE $00
    jr   z, jr_000_2019                           ; $201D: $28 $FA

    cp   $81                                      ; $201F: $FE $81
    jr   z, jr_000_2019                           ; $2021: $28 $F6

    cp   $80                                      ; $2023: $FE $80
    jr   z, jr_000_2070                           ; $2025: $28 $49

jr_000_2027:
    ld   a, $03                                   ; $2027: $3E $03
    ldh  [$FF9F], a                               ; $2029: $E0 $9F
    ld   a, $50                                   ; $202B: $3E $50
    ldh  [hCounter], a                            ; $202D: $E0 $B0
    ld   a, $00                                   ; $202F: $3E $00
    ldh  [hCounter+1], a                          ; $2031: $E0 $B1
    ret                                           ; $2033: $C9


jr_000_2034:
    ld   a, [_RAM]                                ; $2034: $FA $00 $C0
    ldh  [$FF8D], a                               ; $2037: $E0 $8D
    ld   a, [$C001]                               ; $2039: $FA $01 $C0
    ldh  [$FF8E], a                               ; $203C: $E0 $8E
    call Call_000_2C4B                            ; $203E: $CD $4B $2C

jr_000_2041:
    ld   a, [hl-]                                 ; $2041: $3A
    cp   $00                                      ; $2042: $FE $00
    jr   z, jr_000_2041                           ; $2044: $28 $FB

    inc  hl                                       ; $2046: $23
    ld   a, [$C006]                               ; $2047: $FA $06 $C0
    cp   [hl]                                     ; $204A: $BE
    jr   z, jr_000_2027                           ; $204B: $28 $DA

    ld   a, $87                                   ; $204D: $3E $87
    cp   [hl]                                     ; $204F: $BE
    jr   z, jr_000_205C                           ; $2050: $28 $0A

    ld   a, $81                                   ; $2052: $3E $81
    cp   [hl]                                     ; $2054: $BE
    jr   z, jr_000_205C                           ; $2055: $28 $05

    ld   a, $80                                   ; $2057: $3E $80
    cp   [hl]                                     ; $2059: $BE
    jr   nz, jr_000_2070                          ; $205A: $20 $14

jr_000_205C:
    inc  hl                                       ; $205C: $23
    ld   bc, $0020                                ; $205D: $01 $20 $00

jr_000_2060:
    add  hl, bc                                   ; $2060: $09
    ld   a, [hl]                                  ; $2061: $7E
    cp   $00                                      ; $2062: $FE $00
    jr   z, jr_000_2060                           ; $2064: $28 $FA

    cp   $81                                      ; $2066: $FE $81
    jr   z, jr_000_2060                           ; $2068: $28 $F6

    ld   a, [$C006]                               ; $206A: $FA $06 $C0
    cp   [hl]                                     ; $206D: $BE
    jr   z, jr_000_2027                           ; $206E: $28 $B7

jr_000_2070:
    ld   a, [_RAM]                                ; $2070: $FA $00 $C0
    cp   $28                                      ; $2073: $FE $28
    jr   nz, jr_000_207E                          ; $2075: $20 $07

    ld   hl, $FFA6                                ; $2077: $21 $A6 $FF
    set  6, [hl]                                  ; $207A: $CB $F6
    jr   jr_000_2095                              ; $207C: $18 $17

jr_000_207E:
    cp   $80                                      ; $207E: $FE $80
    jr   nz, jr_000_2089                          ; $2080: $20 $07

    ld   hl, $FFA6                                ; $2082: $21 $A6 $FF
    res  6, [hl]                                  ; $2085: $CB $B6
    jr   jr_000_208F                              ; $2087: $18 $06

jr_000_2089:
    ldh  a, [$FFA6]                               ; $2089: $F0 $A6
    bit  6, a                                     ; $208B: $CB $77
    jr   nz, jr_000_2095                          ; $208D: $20 $06

jr_000_208F:
    ld   a, $01                                   ; $208F: $3E $01
    ldh  [$FF9F], a                               ; $2091: $E0 $9F
    jr   jr_000_2099                              ; $2093: $18 $04

jr_000_2095:
    ld   a, $02                                   ; $2095: $3E $02
    ldh  [$FF9F], a                               ; $2097: $E0 $9F

jr_000_2099:
    ld   a, $50                                   ; $2099: $3E $50
    ldh  [hCounter], a                            ; $209B: $E0 $B0
    ld   a, $00                                   ; $209D: $3E $00
    ldh  [hCounter+1], a                          ; $209F: $E0 $B1
    ret                                           ; $20A1: $C9


Jump_000_20A2:
    ldh  a, [$FFA0]                               ; $20A2: $F0 $A0
    cp   $01                                      ; $20A4: $FE $01
    jr   z, jr_000_20B7                           ; $20A6: $28 $0F

    cp   $02                                      ; $20A8: $FE $02
    jp   z, Jump_000_1490                         ; $20AA: $CA $90 $14

    cp   $03                                      ; $20AD: $FE $03
    jp   z, Jump_000_20D5                         ; $20AF: $CA $D5 $20

    cp   $06                                      ; $20B2: $FE $06
    jp   z, Jump_000_1707                         ; $20B4: $CA $07 $17

jr_000_20B7:
    call Call_000_2EE8                            ; $20B7: $CD $E8 $2E
    jp   z, Jump_000_130D                         ; $20BA: $CA $0D $13

    ldh  a, [hCounter]                            ; $20BD: $F0 $B0
    bit  5, a                                     ; $20BF: $CB $6F
    ret  nz                                       ; $20C1: $C0

    ld   a, [$C002]                               ; $20C2: $FA $02 $C0
    cp   $8C                                      ; $20C5: $FE $8C
    ld   a, $8E                                   ; $20C7: $3E $8E
    jr   z, jr_000_20CD                           ; $20C9: $28 $02

    ld   a, $8C                                   ; $20CB: $3E $8C

jr_000_20CD:
    ld   [$C002], a                               ; $20CD: $EA $02 $C0
    dec  a                                        ; $20D0: $3D
    ld   [$C006], a                               ; $20D1: $EA $06 $C0
    ret                                           ; $20D4: $C9


Jump_000_20D5:
    call Call_000_2EE8                            ; $20D5: $CD $E8 $2E
    ret  nz                                       ; $20D8: $C0

    jp   Jump_000_130D                            ; $20D9: $C3 $0D $13


Jump_000_20DC:
    ldh  a, [hBlocks+1]                           ; $20DC: $F0 $CA
    cp   $00                                      ; $20DE: $FE $00
    jr   nz, jr_000_20EB                          ; $20E0: $20 $09

    ldh  a, [$FFCF]                               ; $20E2: $F0 $CF
    ld   hl, hBlocks                              ; $20E4: $21 $C9 $FF
    cp   [hl]                                     ; $20E7: $BE
    jp   c, Jump_000_1163                         ; $20E8: $DA $63 $11

jr_000_20EB:
    ld   a, $01                                   ; $20EB: $3E $01
    ldh  [$FFA0], a                               ; $20ED: $E0 $A0
    jp   Jump_000_11AD                            ; $20EF: $C3 $AD $11


Jump_000_20F2:
    ldh  a, [$FF9F]                               ; $20F2: $F0 $9F
    cp   $05                                      ; $20F4: $FE $05
    jp   nc, Jump_000_233E                        ; $20F6: $D2 $3E $23

    cp   $04                                      ; $20F9: $FE $04
    jp   z, Jump_000_229B                         ; $20FB: $CA $9B $22

    ld   a, [$C005]                               ; $20FE: $FA $05 $C0
    sub  $02                                      ; $2101: $D6 $02
    ld   [$C005], a                               ; $2103: $EA $05 $C0
    cp   $5E                                      ; $2106: $FE $5E
    jr   nz, jr_000_210E                          ; $2108: $20 $04

    ld   a, $92                                   ; $210A: $3E $92
    jr   jr_000_2114                              ; $210C: $18 $06

jr_000_210E:
    cp   $5C                                      ; $210E: $FE $5C
    jr   nz, jr_000_212B                          ; $2110: $20 $19

    ld   a, $94                                   ; $2112: $3E $94

jr_000_2114:
    ld   b, a                                     ; $2114: $47
    ld   [$C002], a                               ; $2115: $EA $02 $C0
    ld   hl, $C00C                                ; $2118: $21 $0C $C0
    ld   a, [_RAM]                                ; $211B: $FA $00 $C0
    ld   [hl+], a                                 ; $211E: $22
    ld   a, $60                                   ; $211F: $3E $60
    ld   [hl+], a                                 ; $2121: $22
    ld   a, b                                     ; $2122: $78
    dec  a                                        ; $2123: $3D
    ld   [hl+], a                                 ; $2124: $22
    ld   a, $00                                   ; $2125: $3E $00
    ld   [hl], a                                  ; $2127: $77
    jp   Jump_000_2292                            ; $2128: $C3 $92 $22


jr_000_212B:
    cp   $54                                      ; $212B: $FE $54
    jr   nz, jr_000_213D                          ; $212D: $20 $0E

    ld   a, $89                                   ; $212F: $3E $89
    ld   [$C002], a                               ; $2131: $EA $02 $C0
    ld   hl, $C00C                                ; $2134: $21 $0C $C0
    ld   a, $00                                   ; $2137: $3E $00
    ld   [hl], a                                  ; $2139: $77
    jp   Jump_000_2292                            ; $213A: $C3 $92 $22


jr_000_213D:
    and  $0F                                      ; $213D: $E6 $0F
    cp   $00                                      ; $213F: $FE $00
    jr   z, jr_000_2148                           ; $2141: $28 $05

    cp   $08                                      ; $2143: $FE $08
    jp   nz, Jump_000_2292                        ; $2145: $C2 $92 $22

jr_000_2148:
    ld   a, [$C005]                               ; $2148: $FA $05 $C0
    ldh  [$FF8E], a                               ; $214B: $E0 $8E
    ld   a, [$C004]                               ; $214D: $FA $04 $C0
    ldh  [$FF8D], a                               ; $2150: $E0 $8D
    call Call_000_2C4B                            ; $2152: $CD $4B $2C
    ld   a, [hl]                                  ; $2155: $7E
    cp   $00                                      ; $2156: $FE $00
    jp   z, Jump_000_2256                         ; $2158: $CA $56 $22

    push hl                                       ; $215B: $E5
    ld   hl, UnknownMusic66D2                     ; $215C: $21 $D2 $66
    call Call_000_332E                            ; $215F: $CD $2E $33
    pop  hl                                       ; $2162: $E1
    ld   a, [hl]                                  ; $2163: $7E
    cp   $82                                      ; $2164: $FE $82
    jp   z, Jump_000_2240                         ; $2166: $CA $40 $22

    ldh  a, [$FFA6]                               ; $2169: $F0 $A6
    set  1, a                                     ; $216B: $CB $CF
    ldh  [$FFA6], a                               ; $216D: $E0 $A6
    ld   a, [$C006]                               ; $216F: $FA $06 $C0
    cp   [hl]                                     ; $2172: $BE
    jr   z, .blockMatch                           ; $2173: $28 $08

    cp   $82                                      ; $2175: $FE $82
    jr   nz, .blockMiss                          ; $2177: $20 $0A

    ld   a, [hl]                                  ; $2179: $7E
    ld   [$C006], a                               ; $217A: $EA $06 $C0

.blockMatch:
    call Call_000_30CF                            ; $217D: $CD $CF $30
    jp   Jump_000_2256                            ; $2180: $C3 $56 $22


.blockMiss:
    ldh  a, [$FFA6]                               ; $2183: $F0 $A6
    bit  4, a                                     ; $2185: $CB $67
    jr   z, jr_000_218C                           ; $2187: $28 $03

    inc  hl                                       ; $2189: $23
    jr   jr_000_219C                              ; $218A: $18 $10

jr_000_218C:
    ldh  a, [$FFD1]                               ; $218C: $F0 $D1
    cp   $00                                      ; $218E: $FE $00
    jr   z, jr_000_21A7                           ; $2190: $28 $15

    ld   a, [$C006]                               ; $2192: $FA $06 $C0
    ld   b, a                                     ; $2195: $47
    ld   a, [hl]                                  ; $2196: $7E
    ld   [$C006], a                               ; $2197: $EA $06 $C0
    ld   a, b                                     ; $219A: $78
    ld   [hl+], a                                 ; $219B: $22

jr_000_219C:
    ld   a, $00                                   ; $219C: $3E $00
    cp   [hl]                                     ; $219E: $BE
    jr   nz, jr_000_21A4                          ; $219F: $20 $03

Jump_000_21A1:
    call Call_000_2EF6                            ; $21A1: $CD $F6 $2E

Jump_000_21A4:
jr_000_21A4:
    call Call_000_2F3A                            ; $21A4: $CD $3A $2F

Jump_000_21A7:
jr_000_21A7:
    ld   a, $05                                   ; $21A7: $3E $05
    ldh  [$FF9F], a                               ; $21A9: $E0 $9F
    ldh  a, [$FFA8]                               ; $21AB: $F0 $A8
    bit  6, a                                     ; $21AD: $CB $77
    jr   z, jr_000_21D5                           ; $21AF: $28 $24

    and  $BF                                      ; $21B1: $E6 $BF
    ldh  [$FFA8], a                               ; $21B3: $E0 $A8
    call Call_000_2B8C                            ; $21B5: $CD $8C $2B
    ldh  a, [$FFA8]                               ; $21B8: $F0 $A8
    bit  4, a                                     ; $21BA: $CB $67
    jr   nz, jr_000_21C8                          ; $21BC: $20 $0A

    call Call_000_3277                            ; $21BE: $CD $77 $32
    ld   hl, $FFA7                                ; $21C1: $21 $A7 $FF
    set  7, [hl]                                  ; $21C4: $CB $FE
    jr   jr_000_21D5                              ; $21C6: $18 $0D

jr_000_21C8:
    ld   a, $C1                                   ; $21C8: $3E $C1
    ldh  [$FFD8], a                               ; $21CA: $E0 $D8
    ld   a, $99                                   ; $21CC: $3E $99
    ldh  [$FFD9], a                               ; $21CE: $E0 $D9
    ld   hl, $FFAB                                ; $21D0: $21 $AB $FF
    set  6, [hl]                                  ; $21D3: $CB $F6

jr_000_21D5:
    ld   a, $00                                   ; $21D5: $3E $00
    ldh  [$FFA3], a                               ; $21D7: $E0 $A3
    ldh  [$FFA4], a                               ; $21D9: $E0 $A4
    ldh  [$FFA5], a                               ; $21DB: $E0 $A5
    ld   c, a                                     ; $21DD: $4F
    ld   hl, _RAM                                 ; $21DE: $21 $00 $C0
    ld   a, [$C004]                               ; $21E1: $FA $04 $C0
    cp   [hl]                                     ; $21E4: $BE
    jr   z, jr_000_2201                           ; $21E5: $28 $1A

    ld   b, a                                     ; $21E7: $47
    ld   a, [$C005]                               ; $21E8: $FA $05 $C0
    cp   $10                                      ; $21EB: $FE $10
    jr   z, jr_000_21F5                           ; $21ED: $28 $06

    ld   a, $04                                   ; $21EF: $3E $04
    ldh  [$FFA4], a                               ; $21F1: $E0 $A4
    jr   jr_000_2201                              ; $21F3: $18 $0C

jr_000_21F5:
    ld   a, b                                     ; $21F5: $78
    sub  [hl]                                     ; $21F6: $96

jr_000_21F7:
    inc  c                                        ; $21F7: $0C
    sub  $08                                      ; $21F8: $D6 $08
    cp   $00                                      ; $21FA: $FE $00
    jr   nz, jr_000_21F7                          ; $21FC: $20 $F9

    ld   a, c                                     ; $21FE: $79
    ldh  [$FFA4], a                               ; $21FF: $E0 $A4

jr_000_2201:
    ld   c, $00                                   ; $2201: $0E $00
    ld   hl, $C005                                ; $2203: $21 $05 $C0
    ld   a, [$C001]                               ; $2206: $FA $01 $C0
    sub  [hl]                                     ; $2209: $96

jr_000_220A:
    inc  c                                        ; $220A: $0C
    sub  $08                                      ; $220B: $D6 $08
    cp   $00                                      ; $220D: $FE $00
    jr   nz, jr_000_220A                          ; $220F: $20 $F9

    ld   a, c                                     ; $2211: $79
    ldh  [$FFA5], a                               ; $2212: $E0 $A5
    ld   hl, $C004                                ; $2214: $21 $04 $C0
    ld   a, [_RAM]                                ; $2217: $FA $00 $C0
    cp   [hl]                                     ; $221A: $BE
    jr   nc, jr_000_2239                          ; $221B: $30 $1C

    ld   b, a                                     ; $221D: $47
    ld   a, [$C004]                               ; $221E: $FA $04 $C0
    sub  b                                        ; $2221: $90
    srl  a                                        ; $2222: $CB $3F
    ld   c, a                                     ; $2224: $4F
    ld   a, [$C005]                               ; $2225: $FA $05 $C0
    ld   b, a                                     ; $2228: $47
    ld   a, [$C001]                               ; $2229: $FA $01 $C0
    sub  $10                                      ; $222C: $D6 $10
    sub  b                                        ; $222E: $90
    cp   c                                        ; $222F: $B9
    jr   nc, jr_000_2239                          ; $2230: $30 $07

    ldh  a, [$FFA6]                               ; $2232: $F0 $A6
    or   $08                                      ; $2234: $F6 $08
    ldh  [$FFA6], a                               ; $2236: $E0 $A6
    ret                                           ; $2238: $C9


jr_000_2239:
    ldh  a, [$FFA6]                               ; $2239: $F0 $A6
    and  $F7                                      ; $223B: $E6 $F7
    ldh  [$FFA6], a                               ; $223D: $E0 $A6
    ret                                           ; $223F: $C9


Jump_000_2240:
    ldh  a, [$FFD1]                               ; $2240: $F0 $D1
    cp   $00                                      ; $2242: $FE $00
    jr   nz, jr_000_224C                          ; $2244: $20 $06

    ldh  a, [$FFA6]                               ; $2246: $F0 $A6
    set  4, a                                     ; $2248: $CB $E7
    ldh  [$FFA6], a                               ; $224A: $E0 $A6

jr_000_224C:
    ld   a, $00                                   ; $224C: $3E $00
    ld   [hl], a                                  ; $224E: $77
    ld   hl, hSBlocksRemaining                    ; $224F: $21 $C5 $FF
    inc  [hl]                                     ; $2252: $34
    call Call_000_30DA                            ; $2253: $CD $DA $30

Jump_000_2256:
    ldh  a, [$FF8F]                               ; $2256: $F0 $8F
    ld   h, a                                     ; $2258: $67
    ldh  a, [$FF90]                               ; $2259: $F0 $90
    ld   l, a                                     ; $225B: $6F
    push hl                                       ; $225C: $E5
    inc  hl                                       ; $225D: $23
    ld   a, $00                                   ; $225E: $3E $00
    cp   [hl]                                     ; $2260: $BE
    jr   nz, jr_000_2266                          ; $2261: $20 $03

    call Call_000_2EF6                            ; $2263: $CD $F6 $2E

jr_000_2266:
    pop  hl                                       ; $2266: $E1
    dec  hl                                       ; $2267: $2B
    ld   a, $87                                   ; $2268: $3E $87
    cp   [hl]                                     ; $226A: $BE
    jr   z, jr_000_2288                           ; $226B: $28 $1B

    ld   a, $81                                   ; $226D: $3E $81
    cp   [hl]                                     ; $226F: $BE
    jr   z, jr_000_2277                           ; $2270: $28 $05

    ld   a, $80                                   ; $2272: $3E $80
    cp   [hl]                                     ; $2274: $BE
    jr   nz, jr_000_2292                          ; $2275: $20 $1B

jr_000_2277:
    ld   a, l                                     ; $2277: $7D
    and  $F0                                      ; $2278: $E6 $F0
    cp   $C0                                      ; $227A: $FE $C0
    jp   nz, Jump_000_2288                        ; $227C: $C2 $88 $22

    ld   a, h                                     ; $227F: $7C
    cp   $C9                                      ; $2280: $FE $C9
    jr   nz, jr_000_2288                          ; $2282: $20 $04

    inc  hl                                       ; $2284: $23
    jp   Jump_000_21A1                            ; $2285: $C3 $A1 $21


Jump_000_2288:
jr_000_2288:
    ld   hl, UnknownMusic6864                     ; $2288: $21 $64 $68
    call Call_000_332E                            ; $228B: $CD $2E $33
    ld   a, $04                                   ; $228E: $3E $04
    ldh  [$FF9F], a                               ; $2290: $E0 $9F

Jump_000_2292:
jr_000_2292:
    ld   a, $10                                   ; $2292: $3E $10
    ldh  [hCounter], a                            ; $2294: $E0 $B0
    ld   a, $00                                   ; $2296: $3E $00
    ldh  [hCounter+1], a                          ; $2298: $E0 $B1
    ret                                           ; $229A: $C9


Jump_000_229B:
    ld   a, [$C004]                               ; $229B: $FA $04 $C0
    add  $02                                      ; $229E: $C6 $02
    ld   [$C004], a                               ; $22A0: $EA $04 $C0
    and  $0F                                      ; $22A3: $E6 $0F
    cp   $00                                      ; $22A5: $FE $00
    jr   z, jr_000_22AD                           ; $22A7: $28 $04

    cp   $08                                      ; $22A9: $FE $08
    jr   nz, jr_000_2292                          ; $22AB: $20 $E5

jr_000_22AD:
    ld   a, [$C004]                               ; $22AD: $FA $04 $C0
    ldh  [$FF8D], a                               ; $22B0: $E0 $8D
    ld   a, [$C005]                               ; $22B2: $FA $05 $C0
    ldh  [$FF8E], a                               ; $22B5: $E0 $8E
    call Call_000_2C4B                            ; $22B7: $CD $4B $2C
    ld   a, [hl]                                  ; $22BA: $7E
    cp   $00                                      ; $22BB: $FE $00
    jp   z, Jump_000_2312                         ; $22BD: $CA $12 $23

    cp   $81                                      ; $22C0: $FE $81
    jr   z, jr_000_2312                           ; $22C2: $28 $4E

    push hl                                       ; $22C4: $E5
    ld   hl, UnknownMusic66D2                     ; $22C5: $21 $D2 $66
    call Call_000_332E                            ; $22C8: $CD $2E $33
    pop  hl                                       ; $22CB: $E1
    ld   a, [hl]                                  ; $22CC: $7E
    cp   $82                                      ; $22CD: $FE $82
    jr   z, jr_000_2308                           ; $22CF: $28 $37

    ldh  a, [$FFA6]                               ; $22D1: $F0 $A6
    set  1, a                                     ; $22D3: $CB $CF
    ldh  [$FFA6], a                               ; $22D5: $E0 $A6
    ld   a, [$C006]                               ; $22D7: $FA $06 $C0
    cp   [hl]                                     ; $22DA: $BE
    jr   z, jr_000_22E5                           ; $22DB: $28 $08

    cp   $82                                      ; $22DD: $FE $82
    jr   nz, jr_000_22EA                          ; $22DF: $20 $09

    ld   a, [hl]                                  ; $22E1: $7E
    ld   [$C006], a                               ; $22E2: $EA $06 $C0

jr_000_22E5:
    call Call_000_30CF                            ; $22E5: $CD $CF $30
    jr   jr_000_2312                              ; $22E8: $18 $28

jr_000_22EA:
    ldh  a, [$FFD1]                               ; $22EA: $F0 $D1
    cp   $00                                      ; $22EC: $FE $00
    jp   z, Jump_000_21A7                         ; $22EE: $CA $A7 $21

    ld   a, [$C006]                               ; $22F1: $FA $06 $C0
    ld   b, a                                     ; $22F4: $47
    ld   a, [hl]                                  ; $22F5: $7E
    ld   [$C006], a                               ; $22F6: $EA $06 $C0
    ld   a, b                                     ; $22F9: $78
    ld   [hl], a                                  ; $22FA: $77
    ld   bc, hMusicSpeed                          ; $22FB: $01 $E0 $FF
    add  hl, bc                                   ; $22FE: $09
    ld   a, $00                                   ; $22FF: $3E $00
    cp   [hl]                                     ; $2301: $BE
    jp   z, Jump_000_21A1                         ; $2302: $CA $A1 $21

    jp   Jump_000_21A4                            ; $2305: $C3 $A4 $21


jr_000_2308:
    ld   a, $00                                   ; $2308: $3E $00
    ld   [hl], a                                  ; $230A: $77
    ld   hl, hSBlocksRemaining                    ; $230B: $21 $C5 $FF
    inc  [hl]                                     ; $230E: $34
    call Call_000_30DA                            ; $230F: $CD $DA $30

Jump_000_2312:
jr_000_2312:
    ldh  a, [$FF8F]                               ; $2312: $F0 $8F
    ld   h, a                                     ; $2314: $67
    ldh  a, [$FF90]                               ; $2315: $F0 $90
    ld   l, a                                     ; $2317: $6F
    ld   bc, $0020                                ; $2318: $01 $20 $00
    add  hl, bc                                   ; $231B: $09
    ld   a, $80                                   ; $231C: $3E $80
    cp   [hl]                                     ; $231E: $BE
    jp   nz, Jump_000_2292                        ; $231F: $C2 $92 $22

    push hl                                       ; $2322: $E5
    ld   hl, UnknownMusic6864                     ; $2323: $21 $64 $68
    call Call_000_332E                            ; $2326: $CD $2E $33
    pop  hl                                       ; $2329: $E1
    ldh  a, [$FFD1]                               ; $232A: $F0 $D1
    cp   $00                                      ; $232C: $FE $00
    jp   z, Jump_000_21A7                         ; $232E: $CA $A7 $21

    ld   a, l                                     ; $2331: $7D
    cp   $E1                                      ; $2332: $FE $E1
    jp   nz, Jump_000_21A4                        ; $2334: $C2 $A4 $21

    ld   bc, hMusicSpeed                          ; $2337: $01 $E0 $FF
    add  hl, bc                                   ; $233A: $09
    jp   Jump_000_21A1                            ; $233B: $C3 $A1 $21


Jump_000_233E:
    ld   hl, $C005                                ; $233E: $21 $05 $C0
    ld   a, [$C001]                               ; $2341: $FA $01 $C0
    sub  $08                                      ; $2344: $D6 $08
    cp   [hl]                                     ; $2346: $BE
    jp   nz, Jump_000_23C0                        ; $2347: $C2 $C0 $23

    dec  hl                                       ; $234A: $2B
    ld   a, [_RAM]                                ; $234B: $FA $00 $C0
    cp   [hl]                                     ; $234E: $BE
    jp   nz, Jump_000_23C0                        ; $234F: $C2 $C0 $23

    ld   a, $07                                   ; $2352: $3E $07
    ldh  [$FF9F], a                               ; $2354: $E0 $9F
    ld   hl, UnknownMusic6714                     ; $2356: $21 $14 $67
    call Call_000_332E                            ; $2359: $CD $2E $33
    ldh  a, [$FF97]                               ; $235C: $F0 $97
    cp   $00                                      ; $235E: $FE $00
    jr   z, jr_000_23A0                           ; $2360: $28 $3E

    call Call_000_3277                            ; $2362: $CD $77 $32
    ld   hl, $FFAB                                ; $2365: $21 $AB $FF
    set  0, [hl]                                  ; $2368: $CB $C6
    ldh  a, [hBlocks+1]                           ; $236A: $F0 $CA
    cp   $00                                      ; $236C: $FE $00
    jr   nz, jr_000_237E                          ; $236E: $20 $0E

    ldh  a, [$FFCF]                               ; $2370: $F0 $CF
    ld   hl, hBlocks                              ; $2372: $21 $C9 $FF
    cp   [hl]                                     ; $2375: $BE
    jr   c, jr_000_237E                           ; $2376: $38 $06

    ld   a, $00                                   ; $2378: $3E $00
    ldh  [$FFD3], a                               ; $237A: $E0 $D3
    jr   jr_000_23A0                              ; $237C: $18 $22

jr_000_237E:
    ldh  a, [$FFD3]                               ; $237E: $F0 $D3
    cp   $04                                      ; $2380: $FE $04
    jr   nz, jr_000_238F                          ; $2382: $20 $0B

    ld   a, $00                                   ; $2384: $3E $00
    ldh  [$FFD3], a                               ; $2386: $E0 $D3
    ld   hl, $FFAB                                ; $2388: $21 $AB $FF
    set  1, [hl]                                  ; $238B: $CB $CE
    jr   jr_000_23A0                              ; $238D: $18 $11

jr_000_238F:
    ldh  a, [$FFD2]                               ; $238F: $F0 $D2
    cp   $02                                      ; $2391: $FE $02
    jr   nc, jr_000_239B                          ; $2393: $30 $06

    ld   a, $00                                   ; $2395: $3E $00
    ldh  [$FFD2], a                               ; $2397: $E0 $D2
    jr   jr_000_23A0                              ; $2399: $18 $05

jr_000_239B:
    ld   hl, $FFAB                                ; $239B: $21 $AB $FF
    set  2, [hl]                                  ; $239E: $CB $D6

jr_000_23A0:
    ldh  a, [$FFA6]                               ; $23A0: $F0 $A6
    and  $EC                                      ; $23A2: $E6 $EC
    ldh  [$FFA6], a                               ; $23A4: $E0 $A6
    ld   a, [$C103]                               ; $23A6: $FA $03 $C1
    cp   $00                                      ; $23A9: $FE $00
    jp   nz, Jump_000_2859                        ; $23AB: $C2 $59 $28

    ld   a, $8F                                   ; $23AE: $3E $8F
    ld   [$C002], a                               ; $23B0: $EA $02 $C0
    ldh  a, [$FFA6]                               ; $23B3: $F0 $A6
    or   $04                                      ; $23B5: $F6 $04
    ldh  [$FFA6], a                               ; $23B7: $E0 $A6
    ld   a, $0A                                   ; $23B9: $3E $0A
    ldh  [$FFBB], a                               ; $23BB: $E0 $BB
    jp   Jump_000_2859                            ; $23BD: $C3 $59 $28


Jump_000_23C0:
    ld   hl, $C004                                ; $23C0: $21 $04 $C0
    ldh  a, [$FFA4]                               ; $23C3: $F0 $A4
    cp   $00                                      ; $23C5: $FE $00
    jp   z, Jump_000_2465                         ; $23C7: $CA $65 $24

    cp   $04                                      ; $23CA: $FE $04
    jp   c, Jump_000_279B                         ; $23CC: $DA $9B $27

    ld   a, [_RAM]                                ; $23CF: $FA $00 $C0
    cp   [hl]                                     ; $23D2: $BE
    jr   nc, jr_000_2420                          ; $23D3: $30 $4B

    ld   hl, $C004                                ; $23D5: $21 $04 $C0
    ldh  a, [$FFA6]                               ; $23D8: $F0 $A6
    bit  3, a                                     ; $23DA: $CB $5F
    jr   z, jr_000_23FF                           ; $23DC: $28 $21

    ld   a, [hl]                                  ; $23DE: $7E
    sub  $08                                      ; $23DF: $D6 $08
    ld   [hl+], a                                 ; $23E1: $22
    ld   a, [hl]                                  ; $23E2: $7E
    add  $02                                      ; $23E3: $C6 $02
    ld   [hl], a                                  ; $23E5: $77
    ld   a, [$C103]                               ; $23E6: $FA $03 $C1
    cp   $00                                      ; $23E9: $FE $00
    jr   nz, jr_000_23F6                          ; $23EB: $20 $09

    ld   a, $04                                   ; $23ED: $3E $04
    ldh  [hCounter], a                            ; $23EF: $E0 $B0
    ld   a, $00                                   ; $23F1: $3E $00
    ldh  [hCounter+1], a                          ; $23F3: $E0 $B1
    ret                                           ; $23F5: $C9


jr_000_23F6:
    ld   a, $20                                   ; $23F6: $3E $20
    ldh  [hCounter], a                            ; $23F8: $E0 $B0
    ld   a, $00                                   ; $23FA: $3E $00
    ldh  [hCounter+1], a                          ; $23FC: $E0 $B1
    ret                                           ; $23FE: $C9


jr_000_23FF:
    ld   a, [hl]                                  ; $23FF: $7E
    sub  $04                                      ; $2400: $D6 $04
    ld   [hl+], a                                 ; $2402: $22

jr_000_2403:
    ld   a, [hl]                                  ; $2403: $7E
    add  $02                                      ; $2404: $C6 $02
    ld   [hl], a                                  ; $2406: $77
    ld   a, [$C103]                               ; $2407: $FA $03 $C1
    cp   $00                                      ; $240A: $FE $00
    jr   nz, jr_000_2417                          ; $240C: $20 $09

    ld   a, $02                                   ; $240E: $3E $02
    ldh  [hCounter], a                            ; $2410: $E0 $B0
    ld   a, $00                                   ; $2412: $3E $00
    ldh  [hCounter+1], a                          ; $2414: $E0 $B1
    ret                                           ; $2416: $C9


jr_000_2417:
    ld   a, $10                                   ; $2417: $3E $10
    ldh  [hCounter], a                            ; $2419: $E0 $B0
    ld   a, $00                                   ; $241B: $3E $00
    ldh  [hCounter+1], a                          ; $241D: $E0 $B1
    ret                                           ; $241F: $C9


jr_000_2420:
    jr   nz, jr_000_242E                          ; $2420: $20 $0C

    ld   a, [$C001]                               ; $2422: $FA $01 $C0
    sub  $08                                      ; $2425: $D6 $08
    inc  hl                                       ; $2427: $23
    sub  [hl]                                     ; $2428: $96
    srl  a                                        ; $2429: $CB $3F
    add  [hl]                                     ; $242B: $86
    ldh  [$FFB9], a                               ; $242C: $E0 $B9

jr_000_242E:
    ldh  a, [$FFB9]                               ; $242E: $F0 $B9
    ld   hl, $C005                                ; $2430: $21 $05 $C0
    sub  [hl]                                     ; $2433: $96
    jr   c, jr_000_244D                           ; $2434: $38 $17

    ldh  a, [$FFB9]                               ; $2436: $F0 $B9
    bit  0, a                                     ; $2438: $CB $47
    jr   nz, jr_000_2440                          ; $243A: $20 $04

    sub  $02                                      ; $243C: $D6 $02
    jr   jr_000_2441                              ; $243E: $18 $01

jr_000_2440:
    dec  a                                        ; $2440: $3D

jr_000_2441:
    sub  [hl]                                     ; $2441: $96
    jr   c, jr_000_2403                           ; $2442: $38 $BF

    jr   z, jr_000_2403                           ; $2444: $28 $BD

    dec  hl                                       ; $2446: $2B
    ld   a, [hl]                                  ; $2447: $7E
    sub  $02                                      ; $2448: $D6 $02
    ld   [hl+], a                                 ; $244A: $22
    jr   jr_000_2403                              ; $244B: $18 $B6

jr_000_244D:
    ldh  a, [$FFB9]                               ; $244D: $F0 $B9
    bit  0, a                                     ; $244F: $CB $47
    jr   nz, jr_000_2457                          ; $2451: $20 $04

    add  $02                                      ; $2453: $C6 $02
    jr   jr_000_2459                              ; $2455: $18 $02

jr_000_2457:
    add  $01                                      ; $2457: $C6 $01

jr_000_2459:
    sub  [hl]                                     ; $2459: $96
    jr   z, jr_000_245E                           ; $245A: $28 $02

    jr   nc, jr_000_2403                          ; $245C: $30 $A5

jr_000_245E:
    dec  hl                                       ; $245E: $2B
    ld   a, [hl]                                  ; $245F: $7E
    add  $02                                      ; $2460: $C6 $02
    ld   [hl+], a                                 ; $2462: $22
    jr   jr_000_2403                              ; $2463: $18 $9E

Jump_000_2465:
    ldh  a, [$FFA5]                               ; $2465: $F0 $A5
    cp   $05                                      ; $2467: $FE $05
    jp   c, Jump_000_2738                         ; $2469: $DA $38 $27

    jp   z, Jump_000_26D5                         ; $246C: $CA $D5 $26

    cp   $07                                      ; $246F: $FE $07
    jp   c, Jump_000_2672                         ; $2471: $DA $72 $26

    jp   z, Jump_000_260F                         ; $2474: $CA $0F $26

    cp   $09                                      ; $2477: $FE $09
    jp   c, Jump_000_25AC                         ; $2479: $DA $AC $25

    jp   z, Jump_000_2549                         ; $247C: $CA $49 $25

    cp   $0B                                      ; $247F: $FE $0B
    jr   c, jr_000_24E6                           ; $2481: $38 $63

    ldh  a, [$FFA3]                               ; $2483: $F0 $A3
    cp   $00                                      ; $2485: $FE $00
    jr   nz, jr_000_24B2                          ; $2487: $20 $29

    ld   a, [hl]                                  ; $2489: $7E
    sub  $03                                      ; $248A: $D6 $03
    ld   [hl+], a                                 ; $248C: $22
    ld   a, [hl]                                  ; $248D: $7E
    add  $02                                      ; $248E: $C6 $02
    ld   [hl], a                                  ; $2490: $77
    cp   $20                                      ; $2491: $FE $20
    jr   nz, jr_000_2499                          ; $2493: $20 $04

    ld   a, $01                                   ; $2495: $3E $01
    ldh  [$FFA3], a                               ; $2497: $E0 $A3

jr_000_2499:
    ld   a, [$C103]                               ; $2499: $FA $03 $C1
    cp   $00                                      ; $249C: $FE $00
    jr   nz, jr_000_24A9                          ; $249E: $20 $09

    ld   a, $02                                   ; $24A0: $3E $02
    ldh  [hCounter], a                            ; $24A2: $E0 $B0
    ld   a, $00                                   ; $24A4: $3E $00
    ldh  [hCounter+1], a                          ; $24A6: $E0 $B1
    ret                                           ; $24A8: $C9


jr_000_24A9:
    ld   a, $10                                   ; $24A9: $3E $10
    ldh  [hCounter], a                            ; $24AB: $E0 $B0
    ld   a, $00                                   ; $24AD: $3E $00
    ldh  [hCounter+1], a                          ; $24AF: $E0 $B1
    ret                                           ; $24B1: $C9


jr_000_24B2:
    cp   $01                                      ; $24B2: $FE $01
    jr   nz, jr_000_24C7                          ; $24B4: $20 $11

    ld   a, [hl]                                  ; $24B6: $7E
    dec  a                                        ; $24B7: $3D
    ld   [hl+], a                                 ; $24B8: $22
    ld   a, [hl]                                  ; $24B9: $7E
    add  $02                                      ; $24BA: $C6 $02
    ld   [hl], a                                  ; $24BC: $77
    cp   $38                                      ; $24BD: $FE $38
    jr   nz, jr_000_2499                          ; $24BF: $20 $D8

    ld   a, $02                                   ; $24C1: $3E $02
    ldh  [$FFA3], a                               ; $24C3: $E0 $A3
    jr   jr_000_2499                              ; $24C5: $18 $D2

jr_000_24C7:
    cp   $02                                      ; $24C7: $FE $02
    jr   nz, jr_000_24DC                          ; $24C9: $20 $11

    ld   a, [hl]                                  ; $24CB: $7E
    inc  a                                        ; $24CC: $3C
    ld   [hl+], a                                 ; $24CD: $22
    ld   a, [hl]                                  ; $24CE: $7E
    add  $02                                      ; $24CF: $C6 $02
    ld   [hl], a                                  ; $24D1: $77
    cp   $50                                      ; $24D2: $FE $50
    jr   nz, jr_000_2499                          ; $24D4: $20 $C3

    ld   a, $03                                   ; $24D6: $3E $03
    ldh  [$FFA3], a                               ; $24D8: $E0 $A3
    jr   jr_000_2499                              ; $24DA: $18 $BD

jr_000_24DC:
    ld   a, [hl]                                  ; $24DC: $7E
    add  $03                                      ; $24DD: $C6 $03
    ld   [hl+], a                                 ; $24DF: $22
    ld   a, [hl]                                  ; $24E0: $7E
    add  $02                                      ; $24E1: $C6 $02
    ld   [hl], a                                  ; $24E3: $77
    jr   jr_000_2499                              ; $24E4: $18 $B3

jr_000_24E6:
    ldh  a, [$FFA3]                               ; $24E6: $F0 $A3
    cp   $00                                      ; $24E8: $FE $00
    jr   nz, jr_000_2515                          ; $24EA: $20 $29

    ld   a, [hl]                                  ; $24EC: $7E
    sub  $03                                      ; $24ED: $D6 $03
    ld   [hl+], a                                 ; $24EF: $22
    ld   a, [hl]                                  ; $24F0: $7E
    add  $02                                      ; $24F1: $C6 $02
    ld   [hl], a                                  ; $24F3: $77
    cp   $28                                      ; $24F4: $FE $28
    jr   nz, jr_000_24FC                          ; $24F6: $20 $04

    ld   a, $01                                   ; $24F8: $3E $01
    ldh  [$FFA3], a                               ; $24FA: $E0 $A3

jr_000_24FC:
    ld   a, [$C103]                               ; $24FC: $FA $03 $C1
    cp   $00                                      ; $24FF: $FE $00
    jr   nz, :+                                   ; $2501: $20 $09

    ld   a, $02                                   ; $2503: $3E $02
    ldh  [hCounter], a                            ; $2505: $E0 $B0
    ld   a, $00                                   ; $2507: $3E $00
    ldh  [hCounter+1], a                          ; $2509: $E0 $B1
    ret                                           ; $250B: $C9


:   ld   a, $10                                   ; $250C: $3E $10
    ldh  [hCounter], a                            ; $250E: $E0 $B0
    ld   a, $00                                   ; $2510: $3E $00
    ldh  [hCounter+1], a                          ; $2512: $E0 $B1
    ret                                           ; $2514: $C9


jr_000_2515:
    cp   $01                                      ; $2515: $FE $01
    jr   nz, :+                                   ; $2517: $20 $11

    ld   a, [hl]                                  ; $2519: $7E
    dec  a                                        ; $251A: $3D
    ld   [hl+], a                                 ; $251B: $22
    ld   a, [hl]                                  ; $251C: $7E
    add  $02                                      ; $251D: $C6 $02
    ld   [hl], a                                  ; $251F: $77
    cp   $3C                                      ; $2520: $FE $3C
    jr   nz, jr_000_24FC                          ; $2522: $20 $D8

    ld   a, $02                                   ; $2524: $3E $02
    ldh  [$FFA3], a                               ; $2526: $E0 $A3
    jr   jr_000_24FC                              ; $2528: $18 $D2

:   cp   $02                                      ; $252A: $FE $02
    jr   nz, :+                                   ; $252C: $20 $11

    ld   a, [hl]                                  ; $252E: $7E
    inc  a                                        ; $252F: $3C
    ld   [hl+], a                                 ; $2530: $22
    ld   a, [hl]                                  ; $2531: $7E
    add  $02                                      ; $2532: $C6 $02
    ld   [hl], a                                  ; $2534: $77
    cp   $50                                      ; $2535: $FE $50
    jr   nz, jr_000_24FC                          ; $2537: $20 $C3

    ld   a, $03                                   ; $2539: $3E $03
    ldh  [$FFA3], a                               ; $253B: $E0 $A3
    jr   jr_000_24FC                              ; $253D: $18 $BD

:   ld   a, [hl]                                  ; $253F: $7E
    add  $03                                      ; $2540: $C6 $03
    ld   [hl+], a                                 ; $2542: $22
    ld   a, [hl]                                  ; $2543: $7E
    add  $02                                      ; $2544: $C6 $02
    ld   [hl], a                                  ; $2546: $77
    jr   jr_000_24FC                              ; $2547: $18 $B3

Jump_000_2549:
    ldh  a, [$FFA3]                               ; $2549: $F0 $A3
    cp   $00                                      ; $254B: $FE $00
    jr   nz, jr_000_2578                          ; $254D: $20 $29

    ld   a, [hl]                                  ; $254F: $7E
    sub  $03                                      ; $2550: $D6 $03
    ld   [hl+], a                                 ; $2552: $22
    ld   a, [hl]                                  ; $2553: $7E
    add  $02                                      ; $2554: $C6 $02
    ld   [hl], a                                  ; $2556: $77
    cp   $30                                      ; $2557: $FE $30
    jr   nz, jr_000_255F                          ; $2559: $20 $04

    ld   a, $01                                   ; $255B: $3E $01
    ldh  [$FFA3], a                               ; $255D: $E0 $A3

jr_000_255F:
    ld   a, [$C103]                               ; $255F: $FA $03 $C1
    cp   $00                                      ; $2562: $FE $00
    jr   nz, :+                                   ; $2564: $20 $09

    ld   a, $02                                   ; $2566: $3E $02
    ldh  [hCounter], a                            ; $2568: $E0 $B0
    ld   a, $00                                   ; $256A: $3E $00
    ldh  [hCounter+1], a                          ; $256C: $E0 $B1
    ret                                           ; $256E: $C9


:   ld   a, $10                                   ; $256F: $3E $10
    ldh  [hCounter], a                            ; $2571: $E0 $B0
    ld   a, $00                                   ; $2573: $3E $00
    ldh  [hCounter+1], a                          ; $2575: $E0 $B1
    ret                                           ; $2577: $C9


jr_000_2578:
    cp   $01                                      ; $2578: $FE $01
    jr   nz, jr_000_258D                          ; $257A: $20 $11

    ld   a, [hl]                                  ; $257C: $7E
    dec  a                                        ; $257D: $3D
    ld   [hl+], a                                 ; $257E: $22
    ld   a, [hl]                                  ; $257F: $7E
    add  $02                                      ; $2580: $C6 $02
    ld   [hl], a                                  ; $2582: $77
    cp   $40                                      ; $2583: $FE $40
    jr   nz, jr_000_255F                          ; $2585: $20 $D8

    ld   a, $02                                   ; $2587: $3E $02
    ldh  [$FFA3], a                               ; $2589: $E0 $A3
    jr   jr_000_255F                              ; $258B: $18 $D2

jr_000_258D:
    cp   $02                                      ; $258D: $FE $02
    jr   nz, jr_000_25A2                          ; $258F: $20 $11

    ld   a, [hl]                                  ; $2591: $7E
    inc  a                                        ; $2592: $3C
    ld   [hl+], a                                 ; $2593: $22
    ld   a, [hl]                                  ; $2594: $7E
    add  $02                                      ; $2595: $C6 $02
    ld   [hl], a                                  ; $2597: $77
    cp   $50                                      ; $2598: $FE $50
    jr   nz, jr_000_255F                          ; $259A: $20 $C3

    ld   a, $03                                   ; $259C: $3E $03
    ldh  [$FFA3], a                               ; $259E: $E0 $A3
    jr   jr_000_255F                              ; $25A0: $18 $BD

jr_000_25A2:
    ld   a, [hl]                                  ; $25A2: $7E
    add  $03                                      ; $25A3: $C6 $03
    ld   [hl+], a                                 ; $25A5: $22
    ld   a, [hl]                                  ; $25A6: $7E
    add  $02                                      ; $25A7: $C6 $02
    ld   [hl], a                                  ; $25A9: $77
    jr   jr_000_255F                              ; $25AA: $18 $B3

Jump_000_25AC:
    ldh  a, [$FFA3]                               ; $25AC: $F0 $A3
    cp   $00                                      ; $25AE: $FE $00
    jr   nz, jr_000_25DB                          ; $25B0: $20 $29

    ld   a, [hl]                                  ; $25B2: $7E
    sub  $03                                      ; $25B3: $D6 $03
    ld   [hl+], a                                 ; $25B5: $22
    ld   a, [hl]                                  ; $25B6: $7E
    add  $02                                      ; $25B7: $C6 $02
    ld   [hl], a                                  ; $25B9: $77
    cp   $38                                      ; $25BA: $FE $38
    jr   nz, jr_000_25C2                          ; $25BC: $20 $04

    ld   a, $01                                   ; $25BE: $3E $01
    ldh  [$FFA3], a                               ; $25C0: $E0 $A3

jr_000_25C2:
    ld   a, [$C103]                               ; $25C2: $FA $03 $C1
    cp   $00                                      ; $25C5: $FE $00
    jr   nz, jr_000_25D2                          ; $25C7: $20 $09

    ld   a, $02                                   ; $25C9: $3E $02
    ldh  [hCounter], a                            ; $25CB: $E0 $B0
    ld   a, $00                                   ; $25CD: $3E $00
    ldh  [hCounter+1], a                          ; $25CF: $E0 $B1
    ret                                           ; $25D1: $C9


jr_000_25D2:
    ld   a, $10                                   ; $25D2: $3E $10
    ldh  [hCounter], a                            ; $25D4: $E0 $B0
    ld   a, $00                                   ; $25D6: $3E $00
    ldh  [hCounter+1], a                          ; $25D8: $E0 $B1
    ret                                           ; $25DA: $C9


jr_000_25DB:
    cp   $01                                      ; $25DB: $FE $01
    jr   nz, jr_000_25F0                          ; $25DD: $20 $11

    ld   a, [hl]                                  ; $25DF: $7E
    dec  a                                        ; $25E0: $3D
    ld   [hl+], a                                 ; $25E1: $22
    ld   a, [hl]                                  ; $25E2: $7E
    add  $02                                      ; $25E3: $C6 $02
    ld   [hl], a                                  ; $25E5: $77
    cp   $44                                      ; $25E6: $FE $44
    jr   nz, jr_000_25C2                          ; $25E8: $20 $D8

    ld   a, $02                                   ; $25EA: $3E $02
    ldh  [$FFA3], a                               ; $25EC: $E0 $A3
    jr   jr_000_25C2                              ; $25EE: $18 $D2

jr_000_25F0:
    cp   $02                                      ; $25F0: $FE $02
    jr   nz, jr_000_2605                          ; $25F2: $20 $11

    ld   a, [hl]                                  ; $25F4: $7E
    inc  a                                        ; $25F5: $3C
    ld   [hl+], a                                 ; $25F6: $22
    ld   a, [hl]                                  ; $25F7: $7E
    add  $02                                      ; $25F8: $C6 $02
    ld   [hl], a                                  ; $25FA: $77
    cp   $50                                      ; $25FB: $FE $50
    jr   nz, jr_000_25C2                          ; $25FD: $20 $C3

    ld   a, $03                                   ; $25FF: $3E $03
    ldh  [$FFA3], a                               ; $2601: $E0 $A3
    jr   jr_000_25C2                              ; $2603: $18 $BD

jr_000_2605:
    ld   a, [hl]                                  ; $2605: $7E
    add  $03                                      ; $2606: $C6 $03
    ld   [hl+], a                                 ; $2608: $22
    ld   a, [hl]                                  ; $2609: $7E
    add  $02                                      ; $260A: $C6 $02
    ld   [hl], a                                  ; $260C: $77
    jr   jr_000_25C2                              ; $260D: $18 $B3

Jump_000_260F:
    ldh  a, [$FFA3]                               ; $260F: $F0 $A3
    cp   $00                                      ; $2611: $FE $00
    jr   nz, jr_000_263E                          ; $2613: $20 $29

    ld   a, [hl]                                  ; $2615: $7E
    sub  $03                                      ; $2616: $D6 $03
    ld   [hl+], a                                 ; $2618: $22
    ld   a, [hl]                                  ; $2619: $7E
    add  $02                                      ; $261A: $C6 $02
    ld   [hl], a                                  ; $261C: $77
    cp   $40                                      ; $261D: $FE $40
    jr   nz, jr_000_2625                          ; $261F: $20 $04

    ld   a, $01                                   ; $2621: $3E $01
    ldh  [$FFA3], a                               ; $2623: $E0 $A3

jr_000_2625:
    ld   a, [$C103]                               ; $2625: $FA $03 $C1
    cp   $00                                      ; $2628: $FE $00
    jr   nz, :+                                   ; $262A: $20 $09

    ld   a, $02                                   ; $262C: $3E $02
    ldh  [hCounter], a                            ; $262E: $E0 $B0
    ld   a, $00                                   ; $2630: $3E $00
    ldh  [hCounter+1], a                          ; $2632: $E0 $B1
    ret                                           ; $2634: $C9


:   ld   a, $10                                   ; $2635: $3E $10
    ldh  [hCounter], a                            ; $2637: $E0 $B0
    ld   a, $00                                   ; $2639: $3E $00
    ldh  [hCounter+1], a                          ; $263B: $E0 $B1
    ret                                           ; $263D: $C9


jr_000_263E:
    cp   $01                                      ; $263E: $FE $01
    jr   nz, :+                                   ; $2640: $20 $11

    ld   a, [hl]                                  ; $2642: $7E
    dec  a                                        ; $2643: $3D
    ld   [hl+], a                                 ; $2644: $22
    ld   a, [hl]                                  ; $2645: $7E
    add  $02                                      ; $2646: $C6 $02
    ld   [hl], a                                  ; $2648: $77
    cp   $48                                      ; $2649: $FE $48
    jr   nz, jr_000_2625                          ; $264B: $20 $D8

    ld   a, $02                                   ; $264D: $3E $02
    ldh  [$FFA3], a                               ; $264F: $E0 $A3
    jr   jr_000_2625                              ; $2651: $18 $D2

:   cp   $02                                      ; $2653: $FE $02
    jr   nz, :+                                   ; $2655: $20 $11

    ld   a, [hl]                                  ; $2657: $7E
    inc  a                                        ; $2658: $3C
    ld   [hl+], a                                 ; $2659: $22
    ld   a, [hl]                                  ; $265A: $7E
    add  $02                                      ; $265B: $C6 $02
    ld   [hl], a                                  ; $265D: $77
    cp   $50                                      ; $265E: $FE $50
    jr   nz, jr_000_2625                          ; $2660: $20 $C3

    ld   a, $03                                   ; $2662: $3E $03
    ldh  [$FFA3], a                               ; $2664: $E0 $A3
    jr   jr_000_2625                              ; $2666: $18 $BD

:   ld   a, [hl]                                  ; $2668: $7E
    add  $03                                      ; $2669: $C6 $03
    ld   [hl+], a                                 ; $266B: $22
    ld   a, [hl]                                  ; $266C: $7E
    add  $02                                      ; $266D: $C6 $02
    ld   [hl], a                                  ; $266F: $77
    jr   jr_000_2625                              ; $2670: $18 $B3

Jump_000_2672:
    ldh  a, [$FFA3]                               ; $2672: $F0 $A3
    cp   $00                                      ; $2674: $FE $00
    jr   nz, jr_000_26A1                          ; $2676: $20 $29

    ld   a, [hl]                                  ; $2678: $7E
    sub  $06                                      ; $2679: $D6 $06
    ld   [hl+], a                                 ; $267B: $22
    ld   a, [hl]                                  ; $267C: $7E
    add  $02                                      ; $267D: $C6 $02
    ld   [hl], a                                  ; $267F: $77
    cp   $40                                      ; $2680: $FE $40
    jr   nz, jr_000_2688                          ; $2682: $20 $04

    ld   a, $01                                   ; $2684: $3E $01
    ldh  [$FFA3], a                               ; $2686: $E0 $A3

jr_000_2688:
    ld   a, [$C103]                               ; $2688: $FA $03 $C1
    cp   $00                                      ; $268B: $FE $00
    jr   nz, jr_000_2698                          ; $268D: $20 $09

    ld   a, $02                                   ; $268F: $3E $02
    ldh  [hCounter], a                            ; $2691: $E0 $B0
    ld   a, $00                                   ; $2693: $3E $00
    ldh  [hCounter+1], a                          ; $2695: $E0 $B1
    ret                                           ; $2697: $C9


jr_000_2698:
    ld   a, $10                                   ; $2698: $3E $10
    ldh  [hCounter], a                            ; $269A: $E0 $B0
    ld   a, $00                                   ; $269C: $3E $00
    ldh  [hCounter+1], a                          ; $269E: $E0 $B1
    ret                                           ; $26A0: $C9


jr_000_26A1:
    cp   $01                                      ; $26A1: $FE $01
    jr   nz, jr_000_26B6                          ; $26A3: $20 $11

    ld   a, [hl]                                  ; $26A5: $7E
    dec  a                                        ; $26A6: $3D
    ld   [hl+], a                                 ; $26A7: $22
    ld   a, [hl]                                  ; $26A8: $7E
    add  $02                                      ; $26A9: $C6 $02
    ld   [hl], a                                  ; $26AB: $77
    cp   $4C                                      ; $26AC: $FE $4C
    jr   nz, jr_000_2688                          ; $26AE: $20 $D8

    ld   a, $02                                   ; $26B0: $3E $02
    ldh  [$FFA3], a                               ; $26B2: $E0 $A3
    jr   jr_000_2688                              ; $26B4: $18 $D2

jr_000_26B6:
    cp   $02                                      ; $26B6: $FE $02
    jr   nz, jr_000_26CB                          ; $26B8: $20 $11

    ld   a, [hl]                                  ; $26BA: $7E
    inc  a                                        ; $26BB: $3C
    ld   [hl+], a                                 ; $26BC: $22
    ld   a, [hl]                                  ; $26BD: $7E
    add  $02                                      ; $26BE: $C6 $02
    ld   [hl], a                                  ; $26C0: $77
    cp   $58                                      ; $26C1: $FE $58
    jr   nz, jr_000_2688                          ; $26C3: $20 $C3

    ld   a, $03                                   ; $26C5: $3E $03
    ldh  [$FFA3], a                               ; $26C7: $E0 $A3
    jr   jr_000_2688                              ; $26C9: $18 $BD

jr_000_26CB:
    ld   a, [hl]                                  ; $26CB: $7E
    add  $06                                      ; $26CC: $C6 $06
    ld   [hl+], a                                 ; $26CE: $22
    ld   a, [hl]                                  ; $26CF: $7E
    add  $02                                      ; $26D0: $C6 $02
    ld   [hl], a                                  ; $26D2: $77
    jr   jr_000_2688                              ; $26D3: $18 $B3

Jump_000_26D5:
    ldh  a, [$FFA3]                               ; $26D5: $F0 $A3
    cp   $00                                      ; $26D7: $FE $00
    jr   nz, jr_000_2704                          ; $26D9: $20 $29

    ld   a, [hl]                                  ; $26DB: $7E
    sub  $06                                      ; $26DC: $D6 $06
    ld   [hl+], a                                 ; $26DE: $22
    ld   a, [hl]                                  ; $26DF: $7E
    add  $02                                      ; $26E0: $C6 $02
    ld   [hl], a                                  ; $26E2: $77
    cp   $48                                      ; $26E3: $FE $48
    jr   nz, jr_000_26EB                          ; $26E5: $20 $04

    ld   a, $01                                   ; $26E7: $3E $01
    ldh  [$FFA3], a                               ; $26E9: $E0 $A3

jr_000_26EB:
    ld   a, [$C103]                               ; $26EB: $FA $03 $C1
    cp   $00                                      ; $26EE: $FE $00
    jr   nz, jr_000_26FB                          ; $26F0: $20 $09

    ld   a, $02                                   ; $26F2: $3E $02
    ldh  [hCounter], a                            ; $26F4: $E0 $B0
    ld   a, $00                                   ; $26F6: $3E $00
    ldh  [hCounter+1], a                          ; $26F8: $E0 $B1
    ret                                           ; $26FA: $C9


jr_000_26FB:
    ld   a, $10                                   ; $26FB: $3E $10
    ldh  [hCounter], a                            ; $26FD: $E0 $B0
    ld   a, $00                                   ; $26FF: $3E $00
    ldh  [hCounter+1], a                          ; $2701: $E0 $B1
    ret                                           ; $2703: $C9


jr_000_2704:
    cp   $01                                      ; $2704: $FE $01
    jr   nz, jr_000_2719                          ; $2706: $20 $11

    ld   a, [hl]                                  ; $2708: $7E
    dec  a                                        ; $2709: $3D
    ld   [hl+], a                                 ; $270A: $22
    ld   a, [hl]                                  ; $270B: $7E
    add  $02                                      ; $270C: $C6 $02
    ld   [hl], a                                  ; $270E: $77
    cp   $50                                      ; $270F: $FE $50
    jr   nz, jr_000_26EB                          ; $2711: $20 $D8

    ld   a, $02                                   ; $2713: $3E $02
    ldh  [$FFA3], a                               ; $2715: $E0 $A3
    jr   jr_000_26EB                              ; $2717: $18 $D2

jr_000_2719:
    cp   $02                                      ; $2719: $FE $02
    jr   nz, jr_000_272E                          ; $271B: $20 $11

    ld   a, [hl]                                  ; $271D: $7E
    inc  a                                        ; $271E: $3C
    ld   [hl+], a                                 ; $271F: $22
    ld   a, [hl]                                  ; $2720: $7E
    add  $02                                      ; $2721: $C6 $02
    ld   [hl], a                                  ; $2723: $77
    cp   $58                                      ; $2724: $FE $58
    jr   nz, jr_000_26EB                          ; $2726: $20 $C3

    ld   a, $03                                   ; $2728: $3E $03
    ldh  [$FFA3], a                               ; $272A: $E0 $A3
    jr   jr_000_26EB                              ; $272C: $18 $BD

jr_000_272E:
    ld   a, [hl]                                  ; $272E: $7E
    add  $06                                      ; $272F: $C6 $06
    ld   [hl+], a                                 ; $2731: $22
    ld   a, [hl]                                  ; $2732: $7E
    add  $02                                      ; $2733: $C6 $02
    ld   [hl], a                                  ; $2735: $77
    jr   jr_000_26EB                              ; $2736: $18 $B3

Jump_000_2738:
    ldh  a, [$FFA3]                               ; $2738: $F0 $A3
    cp   $00                                      ; $273A: $FE $00
    jr   nz, jr_000_2767                          ; $273C: $20 $29

    ld   a, [hl]                                  ; $273E: $7E
    sub  $0A                                      ; $273F: $D6 $0A
    ld   [hl+], a                                 ; $2741: $22
    ld   a, [hl]                                  ; $2742: $7E
    add  $02                                      ; $2743: $C6 $02
    ld   [hl], a                                  ; $2745: $77
    cp   $4C                                      ; $2746: $FE $4C
    jr   nz, jr_000_274E                          ; $2748: $20 $04

    ld   a, $01                                   ; $274A: $3E $01
    ldh  [$FFA3], a                               ; $274C: $E0 $A3

jr_000_274E:
    ld   a, [$C103]                               ; $274E: $FA $03 $C1
    cp   $00                                      ; $2751: $FE $00
    jr   nz, jr_000_275E                          ; $2753: $20 $09

    ld   a, $02                                   ; $2755: $3E $02
    ldh  [hCounter], a                            ; $2757: $E0 $B0
    ld   a, $00                                   ; $2759: $3E $00
    ldh  [hCounter+1], a                          ; $275B: $E0 $B1
    ret                                           ; $275D: $C9


jr_000_275E:
    ld   a, $10                                   ; $275E: $3E $10
    ldh  [hCounter], a                            ; $2760: $E0 $B0
    ld   a, $00                                   ; $2762: $3E $00
    ldh  [hCounter+1], a                          ; $2764: $E0 $B1
    ret                                           ; $2766: $C9


jr_000_2767:
    cp   $01                                      ; $2767: $FE $01
    jr   nz, jr_000_277C                          ; $2769: $20 $11

    ld   a, [hl]                                  ; $276B: $7E
    dec  a                                        ; $276C: $3D
    ld   [hl+], a                                 ; $276D: $22
    ld   a, [hl]                                  ; $276E: $7E
    add  $02                                      ; $276F: $C6 $02
    ld   [hl], a                                  ; $2771: $77
    cp   $54                                      ; $2772: $FE $54
    jr   nz, jr_000_274E                          ; $2774: $20 $D8

    ld   a, $02                                   ; $2776: $3E $02
    ldh  [$FFA3], a                               ; $2778: $E0 $A3
    jr   jr_000_274E                              ; $277A: $18 $D2

jr_000_277C:
    cp   $02                                      ; $277C: $FE $02
    jr   nz, jr_000_2791                          ; $277E: $20 $11

    ld   a, [hl]                                  ; $2780: $7E
    inc  a                                        ; $2781: $3C
    ld   [hl+], a                                 ; $2782: $22
    ld   a, [hl]                                  ; $2783: $7E
    add  $02                                      ; $2784: $C6 $02
    ld   [hl], a                                  ; $2786: $77
    cp   $5C                                      ; $2787: $FE $5C
    jr   nz, jr_000_274E                          ; $2789: $20 $C3

    ld   a, $03                                   ; $278B: $3E $03
    ldh  [$FFA3], a                               ; $278D: $E0 $A3
    jr   jr_000_274E                              ; $278F: $18 $BD

jr_000_2791:
    ld   a, [hl]                                  ; $2791: $7E
    add  $0A                                      ; $2792: $C6 $0A
    ld   [hl+], a                                 ; $2794: $22
    ld   a, [hl]                                  ; $2795: $7E
    add  $02                                      ; $2796: $C6 $02
    ld   [hl], a                                  ; $2798: $77
    jr   jr_000_274E                              ; $2799: $18 $B3

Jump_000_279B:
    cp   $02                                      ; $279B: $FE $02
    jr   c, jr_000_27E0                           ; $279D: $38 $41

    jr   z, jr_000_27CE                           ; $279F: $28 $2D

    ld   a, [hl]                                  ; $27A1: $7E
    sub  $03                                      ; $27A2: $D6 $03
    ld   [hl+], a                                 ; $27A4: $22
    ld   a, [hl]                                  ; $27A5: $7E
    add  $02                                      ; $27A6: $C6 $02
    ld   [hl], a                                  ; $27A8: $77
    cp   $20                                      ; $27A9: $FE $20
    jr   nz, jr_000_27B5                          ; $27AB: $20 $08

    ld   a, $09                                   ; $27AD: $3E $09
    ldh  [$FFA5], a                               ; $27AF: $E0 $A5

jr_000_27B1:
    ld   a, $00                                   ; $27B1: $3E $00
    ldh  [$FFA4], a                               ; $27B3: $E0 $A4

jr_000_27B5:
    ld   a, [$C103]                               ; $27B5: $FA $03 $C1
    cp   $00                                      ; $27B8: $FE $00
    jr   nz, jr_000_27C5                          ; $27BA: $20 $09

    ld   a, $02                                   ; $27BC: $3E $02
    ldh  [hCounter], a                            ; $27BE: $E0 $B0
    ld   a, $00                                   ; $27C0: $3E $00
    ldh  [hCounter+1], a                          ; $27C2: $E0 $B1
    ret                                           ; $27C4: $C9


jr_000_27C5:
    ld   a, $10                                   ; $27C5: $3E $10
    ldh  [hCounter], a                            ; $27C7: $E0 $B0
    ld   a, $00                                   ; $27C9: $3E $00
    ldh  [hCounter+1], a                          ; $27CB: $E0 $B1
    ret                                           ; $27CD: $C9


jr_000_27CE:
    ld   a, [hl]                                  ; $27CE: $7E
    sub  $04                                      ; $27CF: $D6 $04
    ld   [hl+], a                                 ; $27D1: $22
    ld   a, [hl]                                  ; $27D2: $7E
    add  $02                                      ; $27D3: $C6 $02
    ld   [hl], a                                  ; $27D5: $77
    cp   $18                                      ; $27D6: $FE $18
    jr   nz, jr_000_27B5                          ; $27D8: $20 $DB

    ld   a, $0A                                   ; $27DA: $3E $0A
    ldh  [$FFA5], a                               ; $27DC: $E0 $A5
    jr   jr_000_27B1                              ; $27DE: $18 $D1

jr_000_27E0:
    ld   a, [hl]                                  ; $27E0: $7E
    sub  $02                                      ; $27E1: $D6 $02
    ld   [hl+], a                                 ; $27E3: $22
    ld   a, [hl]                                  ; $27E4: $7E
    add  $02                                      ; $27E5: $C6 $02
    ld   [hl], a                                  ; $27E7: $77
    cp   $18                                      ; $27E8: $FE $18
    jr   nz, jr_000_27B5                          ; $27EA: $20 $C9

    ld   a, $0A                                   ; $27EC: $3E $0A
    ldh  [$FFA5], a                               ; $27EE: $E0 $A5
    jr   jr_000_27B1                              ; $27F0: $18 $BF

Jump_000_27F2:
    ldh  a, [$FF9F]                               ; $27F2: $F0 $9F
    cp   $02                                      ; $27F4: $FE $02
    jr   z, jr_000_282E                           ; $27F6: $28 $36

    ld   a, [_RAM]                                ; $27F8: $FA $00 $C0
    cp   $28                                      ; $27FB: $FE $28
    jr   z, jr_000_2828                           ; $27FD: $28 $29

    sub  $04                                      ; $27FF: $D6 $04
    ld   [_RAM], a                                ; $2801: $EA $00 $C0
    ld   a, [$C004]                               ; $2804: $FA $04 $C0
    sub  $04                                      ; $2807: $D6 $04
    ld   [$C004], a                               ; $2809: $EA $04 $C0
    ld   a, [_RAM]                                ; $280C: $FA $00 $C0
    and  $0F                                      ; $280F: $E6 $0F
    cp   $00                                      ; $2811: $FE $00
    jr   z, jr_000_2822                           ; $2813: $28 $0D

    cp   $08                                      ; $2815: $FE $08
    jr   z, jr_000_2822                           ; $2817: $28 $09

jr_000_2819:
    ld   a, $A0                                   ; $2819: $3E $A0
    ldh  [hCounter], a                            ; $281B: $E0 $B0
    ld   a, $00                                   ; $281D: $3E $00
    ldh  [hCounter+1], a                          ; $281F: $E0 $B1
    ret                                           ; $2821: $C9


jr_000_2822:
    ldh  a, [hPressedButtonsMask]                 ; $2822: $F0 $8B
    bit  PADB_UP, a                               ; $2824: $CB $77
    jr   nz, jr_000_2859                          ; $2826: $20 $31

jr_000_2828:
    ld   a, $00                                   ; $2828: $3E $00
    ldh  [$FF9F], a                               ; $282A: $E0 $9F
    jr   jr_000_2859                              ; $282C: $18 $2B

jr_000_282E:
    ld   a, [_RAM]                                ; $282E: $FA $00 $C0
    cp   $80                                      ; $2831: $FE $80
    jr   z, jr_000_2828                           ; $2833: $28 $F3

    add  $04                                      ; $2835: $C6 $04
    ld   [_RAM], a                                ; $2837: $EA $00 $C0
    ld   a, [$C004]                               ; $283A: $FA $04 $C0
    add  $04                                      ; $283D: $C6 $04
    ld   [$C004], a                               ; $283F: $EA $04 $C0
    ld   a, [_RAM]                                ; $2842: $FA $00 $C0
    and  $0F                                      ; $2845: $E6 $0F
    cp   $00                                      ; $2847: $FE $00
    jr   z, jr_000_2851                           ; $2849: $28 $06

    cp   $08                                      ; $284B: $FE $08
    jr   z, jr_000_2851                           ; $284D: $28 $02

    jr   jr_000_2819                              ; $284F: $18 $C8

jr_000_2851:
    ldh  a, [hPressedButtonsMask]                 ; $2851: $F0 $8B
    bit  PADB_DOWN, a                             ; $2853: $CB $7F
    jr   nz, jr_000_2859                          ; $2855: $20 $02

    jr   jr_000_2828                              ; $2857: $18 $CF

Call_000_2859:
Jump_000_2859:
jr_000_2859:
    ldh  a, [$FF97]                               ; $2859: $F0 $97
    cp   $01                                      ; $285B: $FE $01
    jr   nz, jr_000_2864                          ; $285D: $20 $05

    ldh  a, [$FF9E]                               ; $285F: $F0 $9E
    cp   $00                                      ; $2861: $FE $00
    ret  nz                                       ; $2863: $C0

jr_000_2864:
    ld   a, [_RAM]                                ; $2864: $FA $00 $C0
    ldh  [$FF8D], a                               ; $2867: $E0 $8D
    ld   a, [$C001]                               ; $2869: $FA $01 $C0
    ldh  [$FF8E], a                               ; $286C: $E0 $8E
    call Call_000_2C4B                            ; $286E: $CD $4B $2C

jr_000_2871:
    ld   a, [hl-]                                 ; $2871: $3A
    cp   $00                                      ; $2872: $FE $00
    jr   z, jr_000_2871                           ; $2874: $28 $FB

    inc  hl                                       ; $2876: $23
    ld   a, [hl+]                                 ; $2877: $2A
    cp   $87                                      ; $2878: $FE $87
    jr   z, jr_000_288A                           ; $287A: $28 $0E

    cp   $81                                      ; $287C: $FE $81
    jr   z, jr_000_288A                           ; $287E: $28 $0A

    cp   $80                                      ; $2880: $FE $80
    jr   z, jr_000_288A                           ; $2882: $28 $06

jr_000_2884:
    ld   a, $00                                   ; $2884: $3E $00
    ld   [$C008], a                               ; $2886: $EA $08 $C0
    ret                                           ; $2889: $C9


jr_000_288A:
    ld   bc, $0020                                ; $288A: $01 $20 $00

jr_000_288D:
    add  hl, bc                                   ; $288D: $09
    ld   a, [hl]                                  ; $288E: $7E
    cp   $00                                      ; $288F: $FE $00
    jr   z, jr_000_288D                           ; $2891: $28 $FA

    cp   $81                                      ; $2893: $FE $81
    jr   z, jr_000_288D                           ; $2895: $28 $F6

    cp   $80                                      ; $2897: $FE $80
    jr   z, jr_000_2884                           ; $2899: $28 $E9

    ld   bc, hMusicSpeed                          ; $289B: $01 $E0 $FF

:   add  hl, bc                                   ; $289E: $09
    ld   a, [hl]                                  ; $289F: $7E
    cp   $00                                      ; $28A0: $FE $00
    jr   nz, :-                                   ; $28A2: $20 $FA

    ld   a, h                                     ; $28A4: $7C
    and  $0F                                      ; $28A5: $E6 $0F
    add  $90                                      ; $28A7: $C6 $90
    ldh  [$FF8F], a                               ; $28A9: $E0 $8F
    ld   a, l                                     ; $28AB: $7D
    ldh  [$FF90], a                               ; $28AC: $E0 $90
    call Call_000_2C78                            ; $28AE: $CD $78 $2C
    ld   hl, $C008                                ; $28B1: $21 $08 $C0
    ldh  a, [$FF8D]                               ; $28B4: $F0 $8D
    ld   [hl+], a                                 ; $28B6: $22
    ldh  a, [$FF8E]                               ; $28B7: $F0 $8E
    ld   [hl+], a                                 ; $28B9: $22
    ld   a, $8A                                   ; $28BA: $3E $8A
    ld   [hl+], a                                 ; $28BC: $22
    ld   a, $00                                   ; $28BD: $3E $00
    ld   [hl], a                                  ; $28BF: $77
    ret                                           ; $28C0: $C9


Jump_000_28C1:
    ld   hl, $C002                                ; $28C1: $21 $02 $C0
    ld   bc, $0004                                ; $28C4: $01 $04 $00
    ldh  a, [$FFBE]                               ; $28C7: $F0 $BE
    cp   $00                                      ; $28C9: $FE $00
    jr   nz, jr_000_2922                          ; $28CB: $20 $55

    ld   a, $65                                   ; $28CD: $3E $65
    ld   [hl], a                                  ; $28CF: $77
    inc  a                                        ; $28D0: $3C
    add  hl, bc                                   ; $28D1: $09
    ld   [hl], a                                  ; $28D2: $77
    add  $02                                      ; $28D3: $C6 $02
    add  hl, bc                                   ; $28D5: $09
    ld   [hl], a                                  ; $28D6: $77
    ld   a, $76                                   ; $28D7: $3E $76
    add  hl, bc                                   ; $28D9: $09
    ld   [hl], a                                  ; $28DA: $77
    ld   hl, $C010                                ; $28DB: $21 $10 $C0
    ld   a, $68                                   ; $28DE: $3E $68
    ld   [hl+], a                                 ; $28E0: $22
    ldh  a, [$FFBF]                               ; $28E1: $F0 $BF
    cp   $00                                      ; $28E3: $FE $00
    jr   nz, jr_000_28EB                          ; $28E5: $20 $04

    ld   a, $48                                   ; $28E7: $3E $48
    jr   jr_000_28F5                              ; $28E9: $18 $0A

jr_000_28EB:
    cp   $01                                      ; $28EB: $FE $01
    jr   nz, jr_000_28F3                          ; $28ED: $20 $04

    ld   a, $50                                   ; $28EF: $3E $50
    jr   jr_000_28F5                              ; $28F1: $18 $02

jr_000_28F3:
    ld   a, $40                                   ; $28F3: $3E $40

jr_000_28F5:
    ld   [hl+], a                                 ; $28F5: $22
    ld   a, $67                                   ; $28F6: $3E $67
    ld   [hl+], a                                 ; $28F8: $22
    inc  hl                                       ; $28F9: $23
    ld   a, $68                                   ; $28FA: $3E $68
    ld   [hl+], a                                 ; $28FC: $22
    ldh  a, [$FFBF]                               ; $28FD: $F0 $BF
    cp   $00                                      ; $28FF: $FE $00
    jr   nz, jr_000_2907                          ; $2901: $20 $04

    ld   a, $60                                   ; $2903: $3E $60
    jr   jr_000_2911                              ; $2905: $18 $0A

jr_000_2907:
    cp   $01                                      ; $2907: $FE $01
    jr   nz, jr_000_290F                          ; $2909: $20 $04

    ld   a, $68                                   ; $290B: $3E $68
    jr   jr_000_2911                              ; $290D: $18 $02

jr_000_290F:
    ld   a, $58                                   ; $290F: $3E $58

jr_000_2911:
    ld   [hl+], a                                 ; $2911: $22
    ld   a, $69                                   ; $2912: $3E $69
    ld   [hl+], a                                 ; $2914: $22
    ld   a, $01                                   ; $2915: $3E $01
    ldh  [$FFBE], a                               ; $2917: $E0 $BE
    ld   a, $50                                   ; $2919: $3E $50
    ldh  [hCounter], a                            ; $291B: $E0 $B0
    ld   a, $00                                   ; $291D: $3E $00
    ldh  [hCounter+1], a                          ; $291F: $E0 $B1
    ret                                           ; $2921: $C9


jr_000_2922:
    cp   $01                                      ; $2922: $FE $01
    jp   nz, Jump_000_29AF                        ; $2924: $C2 $AF $29

    ld   a, [hl]                                  ; $2927: $7E
    cp   $65                                      ; $2928: $FE $65
    jr   nz, jr_000_2947                          ; $292A: $20 $1B

    ld   a, $30                                   ; $292C: $3E $30
    ld   d, $04                                   ; $292E: $16 $04

:   ld   [hl], a                                  ; $2930: $77
    add  hl, bc                                   ; $2931: $09
    inc  a                                        ; $2932: $3C
    dec  d                                        ; $2933: $15
    jr   nz, :-                                   ; $2934: $20 $FA

    ld   hl, $C010                                ; $2936: $21 $10 $C0
    ld   a, $00                                   ; $2939: $3E $00
    ld   [hl], a                                  ; $293B: $77
    add  hl, bc                                   ; $293C: $09
    ld   [hl], a                                  ; $293D: $77

Jump_000_293E:
jr_000_293E:
    ld   a, $20                                   ; $293E: $3E $20
    ldh  [hCounter], a                            ; $2940: $E0 $B0
    ld   a, $00                                   ; $2942: $3E $00
    ldh  [hCounter+1], a                          ; $2944: $E0 $B1
    ret                                           ; $2946: $C9


jr_000_2947:
    cp   $30                                      ; $2947: $FE $30
    jr   nz, jr_000_2998                          ; $2949: $20 $4D

    ld   e, $6A                                   ; $294B: $1E $6A
    ld   hl, _RAM                                 ; $294D: $21 $00 $C0
    ld   d, $04                                   ; $2950: $16 $04

:   ld   a, [hl]                                  ; $2952: $7E
    sub  $08                                      ; $2953: $D6 $08
    ld   [hl+], a                                 ; $2955: $22
    inc  hl                                       ; $2956: $23
    ld   a, e                                     ; $2957: $7B
    ld   [hl+], a                                 ; $2958: $22
    inc  a                                        ; $2959: $3C
    ld   e, a                                     ; $295A: $5F
    inc  hl                                       ; $295B: $23
    dec  d                                        ; $295C: $15
    jr   nz, :-                                   ; $295D: $20 $F3

    ld   a, $68                                   ; $295F: $3E $68
    ld   [hl+], a                                 ; $2961: $22
    ldh  a, [$FFBF]                               ; $2962: $F0 $BF
    cp   $00                                      ; $2964: $FE $00
    jr   nz, jr_000_296C                          ; $2966: $20 $04

    ld   a, $50                                   ; $2968: $3E $50
    jr   jr_000_2976                              ; $296A: $18 $0A

jr_000_296C:
    cp   $01                                      ; $296C: $FE $01
    jr   nz, jr_000_2974                          ; $296E: $20 $04

    ld   a, $58                                   ; $2970: $3E $58
    jr   jr_000_2976                              ; $2972: $18 $02

jr_000_2974:
    ld   a, $48                                   ; $2974: $3E $48

jr_000_2976:
    ld   [hl+], a                                 ; $2976: $22
    ld   a, $6E                                   ; $2977: $3E $6E
    ld   [hl+], a                                 ; $2979: $22
    inc  hl                                       ; $297A: $23
    ld   a, $68                                   ; $297B: $3E $68
    ld   [hl+], a                                 ; $297D: $22
    ldh  a, [$FFBF]                               ; $297E: $F0 $BF
    cp   $00                                      ; $2980: $FE $00
    jr   nz, jr_000_2988                          ; $2982: $20 $04

    ld   a, $58                                   ; $2984: $3E $58
    jr   jr_000_2992                              ; $2986: $18 $0A

jr_000_2988:
    cp   $01                                      ; $2988: $FE $01
    jr   nz, jr_000_2990                          ; $298A: $20 $04

    ld   a, $60                                   ; $298C: $3E $60
    jr   jr_000_2992                              ; $298E: $18 $02

jr_000_2990:
    ld   a, $50                                   ; $2990: $3E $50

jr_000_2992:
    ld   [hl+], a                                 ; $2992: $22
    ld   a, $6F                                   ; $2993: $3E $6F
    ld   [hl+], a                                 ; $2995: $22
    jr   jr_000_293E                              ; $2996: $18 $A6

jr_000_2998:
    ld   hl, _RAM                                 ; $2998: $21 $00 $C0
    ld   d, $06                                   ; $299B: $16 $06

jr_000_299D:
    ld   a, [hl]                                  ; $299D: $7E
    sub  $02                                      ; $299E: $D6 $02
    ld   [hl], a                                  ; $29A0: $77
    add  hl, bc                                   ; $29A1: $09
    dec  d                                        ; $29A2: $15
    jr   nz, jr_000_299D                          ; $29A3: $20 $F8

    cp   $50                                      ; $29A5: $FE $50
    jr   nz, jr_000_293E                          ; $29A7: $20 $95

    ld   a, $02                                   ; $29A9: $3E $02
    ldh  [$FFBE], a                               ; $29AB: $E0 $BE
    jr   jr_000_293E                              ; $29AD: $18 $8F

Jump_000_29AF:
    ld   hl, _RAM                                 ; $29AF: $21 $00 $C0
    ld   d, $06                                   ; $29B2: $16 $06

jr_000_29B4:
    ld   a, [hl]                                  ; $29B4: $7E
    add  $02                                      ; $29B5: $C6 $02
    ld   [hl], a                                  ; $29B7: $77
    add  hl, bc                                   ; $29B8: $09
    dec  d                                        ; $29B9: $15
    jr   nz, jr_000_29B4                          ; $29BA: $20 $F8

    cp   $68                                      ; $29BC: $FE $68
    jp   nz, Jump_000_293E                        ; $29BE: $C2 $3E $29

    ld   hl, _RAM                                 ; $29C1: $21 $00 $C0
    ld   d, $04                                   ; $29C4: $16 $04
    ld   e, $30                                   ; $29C6: $1E $30

:   ld   a, [hl]                                  ; $29C8: $7E
    add  $08                                      ; $29C9: $C6 $08
    ld   [hl+], a                                 ; $29CB: $22
    inc  hl                                       ; $29CC: $23
    ld   a, e                                     ; $29CD: $7B
    ld   [hl+], a                                 ; $29CE: $22
    inc  a                                        ; $29CF: $3C
    ld   e, a                                     ; $29D0: $5F
    inc  hl                                       ; $29D1: $23
    dec  d                                        ; $29D2: $15
    jr   nz, :-                                   ; $29D3: $20 $F3

    ld   hl, $C010                                ; $29D5: $21 $10 $C0
    ld   a, $00                                   ; $29D8: $3E $00
    ld   [hl], a                                  ; $29DA: $77
    add  hl, bc                                   ; $29DB: $09
    ld   [hl], a                                  ; $29DC: $77
    ldh  [$FFBE], a                               ; $29DD: $E0 $BE
    ld   hl, $FFBF                                ; $29DF: $21 $BF $FF
    inc  [hl]                                     ; $29E2: $34
    jp   Jump_000_293E                            ; $29E3: $C3 $3E $29


Call_000_29E6:
    and  $FE                                      ; $29E6: $E6 $FE
    ldh  [$FFA8], a                               ; $29E8: $E0 $A8
    ldh  a, [$FFAA]                               ; $29EA: $F0 $AA
    cp   $00                                      ; $29EC: $FE $00
    jr   nz, :+                                   ; $29EE: $20 $06

    ld   hl, $FFAB                                ; $29F0: $21 $AB $FF
    set  7, [hl]                                  ; $29F3: $CB $FE
    ret                                           ; $29F5: $C9


:   bit  6, a                                     ; $29F6: $CB $77
    jr   nz, jr_000_2A5E                          ; $29F8: $20 $64

    bit  5, a                                     ; $29FA: $CB $6F
    jp   nz, Jump_000_2A77                        ; $29FC: $C2 $77 $2A

    bit  4, a                                     ; $29FF: $CB $67
    jp   nz, Jump_000_2AD0                        ; $2A01: $C2 $D0 $2A

    cp   $09                                      ; $2A04: $FE $09
    jr   nz, jr_000_2A1D                          ; $2A06: $20 $15

    ld   a, $01                                   ; $2A08: $3E $01
    call Call_000_3148                            ; $2A0A: $CD $48 $31
    ld   a, $07                                   ; $2A0D: $3E $07
    ldh  [$FF9D], a                               ; $2A0F: $E0 $9D
    ld   a, $81                                   ; $2A11: $3E $81
    ldh  [rLCDC], a                               ; $2A13: $E0 $40
    ld   hl, UnknownMusic687C                     ; $2A15: $21 $7C $68
    call Call_000_332E                            ; $2A18: $CD $2E $33
    jr   jr_000_2A5B                              ; $2A1B: $18 $3E

jr_000_2A1D:
    cp   $0E                                      ; $2A1D: $FE $0E
    jr   nz, jr_000_2A34                          ; $2A1F: $20 $13

    call Call_000_31DC                            ; $2A21: $CD $DC $31
    ld   hl, $C00C                                ; $2A24: $21 $0C $C0
    ld   bc, $0014                                ; $2A27: $01 $14 $00
    call MemClear                                 ; $2A2A: $CD $C1 $2C
    ld   a, $01                                   ; $2A2D: $3E $01
    call Call_000_3148                            ; $2A2F: $CD $48 $31
    jr   jr_000_2A5B                              ; $2A32: $18 $27

jr_000_2A34:
    cp   $0F                                      ; $2A34: $FE $0F
    jr   nz, jr_000_2A4B                          ; $2A36: $20 $13

    call Call_000_319C                            ; $2A38: $CD $9C $31
    ld   hl, $C00C                                ; $2A3B: $21 $0C $C0
    ld   bc, $0014                                ; $2A3E: $01 $14 $00
    call MemClear                                 ; $2A41: $CD $C1 $2C
    ld   a, $01                                   ; $2A44: $3E $01
    call Call_000_3148                            ; $2A46: $CD $48 $31
    jr   jr_000_2A5B                              ; $2A49: $18 $10

jr_000_2A4B:
    cp   $0D                                      ; $2A4B: $FE $0D
    jr   nz, jr_000_2A5B                          ; $2A4D: $20 $0C

    ld   hl, hSBlocksRemaining                    ; $2A4F: $21 $C5 $FF
    inc  [hl]                                     ; $2A52: $34
    call Call_000_324E                            ; $2A53: $CD $4E $32
    ld   a, $01                                   ; $2A56: $3E $01
    call Call_000_3148                            ; $2A58: $CD $48 $31

jr_000_2A5B:
    jp   SerialTransferHandler                    ; $2A5B: $C3 $25 $31


jr_000_2A5E:
    and  $3F                                      ; $2A5E: $E6 $3F
    ld   hl, hBlocksInitial                       ; $2A60: $21 $C0 $FF
    ld   [hl+], a                                 ; $2A63: $22
    ld   a, $01                                   ; $2A64: $3E $01
    call Call_000_3148                            ; $2A66: $CD $48 $31
    call Call_000_3178                            ; $2A69: $CD $78 $31
    ldh  a, [$FFAA]                               ; $2A6C: $F0 $AA
    and  $3F                                      ; $2A6E: $E6 $3F
    ld   [hl], a                                  ; $2A70: $77
    call SerialTransferHandler                    ; $2A71: $CD $25 $31
    jp   Jump_000_321E                            ; $2A74: $C3 $1E $32


Jump_000_2A77:
    and  $0F                                      ; $2A77: $E6 $0F
    or   $80                                      ; $2A79: $F6 $80
    ldh  [$FFD6], a                               ; $2A7B: $E0 $D6
    ld   a, $00                                   ; $2A7D: $3E $00
    ld   [$C008], a                               ; $2A7F: $EA $08 $C0
    ld   hl, $C9C8                                ; $2A82: $21 $C8 $C9
    ld   d, $08                                   ; $2A85: $16 $08

jr_000_2A87:
    ld   a, [hl-]                                 ; $2A87: $3A
    cp   $00                                      ; $2A88: $FE $00
    jr   z, jr_000_2A90                           ; $2A8A: $28 $04

    cp   $81                                      ; $2A8C: $FE $81
    jr   nz, jr_000_2A93                          ; $2A8E: $20 $03

jr_000_2A90:
    dec  d                                        ; $2A90: $15
    jr   jr_000_2A87                              ; $2A91: $18 $F4

jr_000_2A93:
    ld   a, d                                     ; $2A93: $7A
    ldh  [$FFD7], a                               ; $2A94: $E0 $D7
    ldh  [$FFD5], a                               ; $2A96: $E0 $D5
    call Call_000_3148                            ; $2A98: $CD $48 $31
    call SerialTransferHandler                    ; $2A9B: $CD $25 $31
    ldh  a, [$FF9F]                               ; $2A9E: $F0 $9F
    cp   $03                                      ; $2AA0: $FE $03
    jr   z, jr_000_2AA8                           ; $2AA2: $28 $04

    cp   $04                                      ; $2AA4: $FE $04
    jr   nz, jr_000_2AAE                          ; $2AA6: $20 $06

jr_000_2AA8:
    ld   hl, $FFA8                                ; $2AA8: $21 $A8 $FF
    set  6, [hl]                                  ; $2AAB: $CB $F6
    ret                                           ; $2AAD: $C9


jr_000_2AAE:
    call Call_000_2B8C                            ; $2AAE: $CD $8C $2B
    ldh  a, [$FFA8]                               ; $2AB1: $F0 $A8
    bit  4, a                                     ; $2AB3: $CB $67
    jr   nz, jr_000_2AC2                          ; $2AB5: $20 $0B

    call Call_000_3277                            ; $2AB7: $CD $77 $32
    ld   hl, $FFA7                                ; $2ABA: $21 $A7 $FF
    set  7, [hl]                                  ; $2ABD: $CB $FE
    jp   Jump_000_2859                            ; $2ABF: $C3 $59 $28


jr_000_2AC2:
    ld   a, $C1                                   ; $2AC2: $3E $C1
    ldh  [$FFD8], a                               ; $2AC4: $E0 $D8
    ld   a, $99                                   ; $2AC6: $3E $99
    ldh  [$FFD9], a                               ; $2AC8: $E0 $D9
    ld   hl, $FFAB                                ; $2ACA: $21 $AB $FF
    set  6, [hl]                                  ; $2ACD: $CB $F6
    ret                                           ; $2ACF: $C9


Jump_000_2AD0:
    and  $0F                                      ; $2AD0: $E6 $0F
    ldh  [$FFD5], a                               ; $2AD2: $E0 $D5
    cp   $04                                      ; $2AD4: $FE $04
    jr   c, jr_000_2AEB                           ; $2AD6: $38 $13

    ld   hl, hSBlocksRemaining                    ; $2AD8: $21 $C5 $FF
    ld   a, [hl]                                  ; $2ADB: $7E
    cp   $00                                      ; $2ADC: $FE $00
    jr   z, jr_000_2AEB                           ; $2ADE: $28 $0B

    dec  [hl]                                     ; $2AE0: $35
    call Call_000_324E                            ; $2AE1: $CD $4E $32
    ld   a, $0B                                   ; $2AE4: $3E $0B
    call Call_000_3148                            ; $2AE6: $CD $48 $31
    jr   jr_000_2AF0                              ; $2AE9: $18 $05

jr_000_2AEB:
    ld   a, $01                                   ; $2AEB: $3E $01
    call Call_000_3148                            ; $2AED: $CD $48 $31

jr_000_2AF0:
    call Call_000_3178                            ; $2AF0: $CD $78 $31
    ldh  a, [$FFAA]                               ; $2AF3: $F0 $AA
    or   $80                                      ; $2AF5: $F6 $80
    ldh  [$FFD6], a                               ; $2AF7: $E0 $D6
    call SerialTransferHandler                    ; $2AF9: $CD $25 $31
    ld   hl, $FFD5                                ; $2AFC: $21 $D5 $FF
    dec  [hl]                                     ; $2AFF: $35
    ld   a, [hl]                                  ; $2B00: $7E
    push af                                       ; $2B01: $F5
    ld   hl, hBlocks                              ; $2B02: $21 $C9 $FF
    add  [hl]                                     ; $2B05: $86
    ld   [hl], a                                  ; $2B06: $77
    cp   $0A                                      ; $2B07: $FE $0A
    jr   c, jr_000_2B0F                           ; $2B09: $38 $04

    sub  $0A                                      ; $2B0B: $D6 $0A
    ld   [hl+], a                                 ; $2B0D: $22
    inc  [hl]                                     ; $2B0E: $34

jr_000_2B0F:
    ld   hl, $C861                                ; $2B0F: $21 $61 $C8
    push hl                                       ; $2B12: $E5

Jump_000_2B13:
    ld   bc, $0020                                ; $2B13: $01 $20 $00

jr_000_2B16:
    ld   a, [hl]                                  ; $2B16: $7E
    cp   $00                                      ; $2B17: $FE $00
    jr   z, jr_000_2B2D                           ; $2B19: $28 $12

    add  hl, bc                                   ; $2B1B: $09
    ld   a, h                                     ; $2B1C: $7C
    cp   $C9                                      ; $2B1D: $FE $C9
    jr   nz, jr_000_2B16                          ; $2B1F: $20 $F5

    ld   a, l                                     ; $2B21: $7D
    and  $F0                                      ; $2B22: $E6 $F0
    cp   $E0                                      ; $2B24: $FE $E0
    jr   nz, jr_000_2B16                          ; $2B26: $20 $EE

    pop  hl                                       ; $2B28: $E1
    inc  hl                                       ; $2B29: $23
    push hl                                       ; $2B2A: $E5
    jr   jr_000_2B16                              ; $2B2B: $18 $E9

jr_000_2B2D:
    push hl                                       ; $2B2D: $E5

jr_000_2B2E:
    add  hl, bc                                   ; $2B2E: $09
    ld   a, [hl]                                  ; $2B2F: $7E
    cp   $81                                      ; $2B30: $FE $81
    jr   nz, jr_000_2B44                          ; $2B32: $20 $10

jr_000_2B34:
    add  hl, bc                                   ; $2B34: $09
    ld   a, [hl]                                  ; $2B35: $7E
    cp   $81                                      ; $2B36: $FE $81
    jr   z, jr_000_2B34                           ; $2B38: $28 $FA

    cp   $00                                      ; $2B3A: $FE $00
    jr   z, jr_000_2B50                           ; $2B3C: $28 $12

    pop  hl                                       ; $2B3E: $E1
    pop  hl                                       ; $2B3F: $E1
    inc  hl                                       ; $2B40: $23
    push hl                                       ; $2B41: $E5
    jr   jr_000_2B16                              ; $2B42: $18 $D2

jr_000_2B44:
    ld   a, h                                     ; $2B44: $7C
    cp   $C9                                      ; $2B45: $FE $C9
    jr   nz, jr_000_2B2E                          ; $2B47: $20 $E5

    ld   a, l                                     ; $2B49: $7D
    and  $F0                                      ; $2B4A: $E6 $F0
    cp   $E0                                      ; $2B4C: $FE $E0
    jr   nz, jr_000_2B2E                          ; $2B4E: $20 $DE

jr_000_2B50:
    pop  hl                                       ; $2B50: $E1
    ld   a, h                                     ; $2B51: $7C
    and  $0F                                      ; $2B52: $E6 $0F
    add  $90                                      ; $2B54: $C6 $90
    ldh  [$FF8F], a                               ; $2B56: $E0 $8F
    ld   a, l                                     ; $2B58: $7D
    ldh  [$FF90], a                               ; $2B59: $E0 $90
    call Call_000_2C78                            ; $2B5B: $CD $78 $2C
    ld   hl, $C01C                                ; $2B5E: $21 $1C $C0
    ld   bc, $0004                                ; $2B61: $01 $04 $00

jr_000_2B64:
    add  hl, bc                                   ; $2B64: $09
    ld   a, [hl]                                  ; $2B65: $7E
    cp   $00                                      ; $2B66: $FE $00
    jr   nz, jr_000_2B64                          ; $2B68: $20 $FA

    ldh  a, [$FF8D]                               ; $2B6A: $F0 $8D
    ld   [hl+], a                                 ; $2B6C: $22
    ldh  a, [$FF8E]                               ; $2B6D: $F0 $8E
    ld   [hl+], a                                 ; $2B6F: $22
    ldh  a, [$FFD6]                               ; $2B70: $F0 $D6
    ld   [hl+], a                                 ; $2B72: $22
    pop  hl                                       ; $2B73: $E1
    inc  hl                                       ; $2B74: $23
    pop  af                                       ; $2B75: $F1
    dec  a                                        ; $2B76: $3D
    jr   z, jr_000_2B7E                           ; $2B77: $28 $05

    push af                                       ; $2B79: $F5
    push hl                                       ; $2B7A: $E5
    jp   Jump_000_2B13                            ; $2B7B: $C3 $13 $2B


jr_000_2B7E:
    ld   a, $01                                   ; $2B7E: $3E $01
    ldh  [$FF9E], a                               ; $2B80: $E0 $9E
    ld   a, $00                                   ; $2B82: $3E $00
    ldh  [$FFB2], a                               ; $2B84: $E0 $B2
    ldh  [$FFB3], a                               ; $2B86: $E0 $B3
    ld   [$C008], a                               ; $2B88: $EA $08 $C0
    ret                                           ; $2B8B: $C9


Call_000_2B8C:
    ldh  a, [$FFD5]                               ; $2B8C: $F0 $D5
    ld   hl, hBlocks                              ; $2B8E: $21 $C9 $FF
    add  [hl]                                     ; $2B91: $86
    ld   [hl], a                                  ; $2B92: $77
    cp   $0A                                      ; $2B93: $FE $0A
    jr   c, jr_000_2B9B                           ; $2B95: $38 $04

    sub  $0A                                      ; $2B97: $D6 $0A
    ld   [hl+], a                                 ; $2B99: $22
    inc  [hl]                                     ; $2B9A: $34

jr_000_2B9B:
    ld   hl, $C861                                ; $2B9B: $21 $61 $C8

jr_000_2B9E:
    push hl                                       ; $2B9E: $E5
    ld   bc, $0020                                ; $2B9F: $01 $20 $00

jr_000_2BA2:
    ld   a, [hl]                                  ; $2BA2: $7E
    cp   $00                                      ; $2BA3: $FE $00
    jr   z, jr_000_2BB9                           ; $2BA5: $28 $12

    cp   $87                                      ; $2BA7: $FE $87
    jr   z, jr_000_2BB9                           ; $2BA9: $28 $0E

    cp   $81                                      ; $2BAB: $FE $81
    jr   z, jr_000_2BB9                           ; $2BAD: $28 $0A

    cp   $80                                      ; $2BAF: $FE $80
    jr   nz, jr_000_2BBC                          ; $2BB1: $20 $09

    ld   bc, hMusicSpeed                          ; $2BB3: $01 $E0 $FF
    add  hl, bc                                   ; $2BB6: $09
    jr   jr_000_2BED                              ; $2BB7: $18 $34

jr_000_2BB9:
    add  hl, bc                                   ; $2BB9: $09
    jr   jr_000_2BA2                              ; $2BBA: $18 $E6

jr_000_2BBC:
    push hl                                       ; $2BBC: $E5

jr_000_2BBD:
    ld   bc, hMusicSpeed                          ; $2BBD: $01 $E0 $FF
    push hl                                       ; $2BC0: $E5
    pop  de                                       ; $2BC1: $D1
    add  hl, bc                                   ; $2BC2: $09
    ld   a, [hl]                                  ; $2BC3: $7E
    cp   $87                                      ; $2BC4: $FE $87
    jr   z, jr_000_2BD0                           ; $2BC6: $28 $08

    cp   $80                                      ; $2BC8: $FE $80
    jr   z, jr_000_2BD0                           ; $2BCA: $28 $04

    cp   $81                                      ; $2BCC: $FE $81
    jr   nz, jr_000_2BD6                          ; $2BCE: $20 $06

jr_000_2BD0:
    ldh  a, [$FFA8]                               ; $2BD0: $F0 $A8
    or   $10                                      ; $2BD2: $F6 $10
    ldh  [$FFA8], a                               ; $2BD4: $E0 $A8

jr_000_2BD6:
    ld   a, [de]                                  ; $2BD6: $1A
    ld   [hl], a                                  ; $2BD7: $77
    ld   a, h                                     ; $2BD8: $7C
    cp   $C9                                      ; $2BD9: $FE $C9
    jr   nz, jr_000_2BE4                          ; $2BDB: $20 $07

    ld   a, l                                     ; $2BDD: $7D
    and  $F0                                      ; $2BDE: $E6 $F0
    cp   $A0                                      ; $2BE0: $FE $A0
    jr   z, jr_000_2BEC                           ; $2BE2: $28 $08

jr_000_2BE4:
    pop  hl                                       ; $2BE4: $E1
    ld   bc, $0020                                ; $2BE5: $01 $20 $00
    add  hl, bc                                   ; $2BE8: $09
    push hl                                       ; $2BE9: $E5
    jr   jr_000_2BBD                              ; $2BEA: $18 $D1

jr_000_2BEC:
    pop  hl                                       ; $2BEC: $E1

jr_000_2BED:
    ldh  a, [$FFD6]                               ; $2BED: $F0 $D6
    ld   [hl], a                                  ; $2BEF: $77
    ldh  a, [$FFD5]                               ; $2BF0: $F0 $D5
    dec  a                                        ; $2BF2: $3D
    ldh  [$FFD5], a                               ; $2BF3: $E0 $D5
    cp   $00                                      ; $2BF5: $FE $00
    pop  hl                                       ; $2BF7: $E1
    ret  z                                        ; $2BF8: $C8

    inc  hl                                       ; $2BF9: $23
    jr   jr_000_2B9E                              ; $2BFA: $18 $A2

ReadJoypad::
    ld   a, P1F_GET_DPAD                          ; $2BFC: $3E $20
    ldh  [rP1], a                                 ; $2BFE: $E0 $00
    ldh  a, [rP1]                                 ; $2C00: $F0 $00
    ldh  a, [rP1]                                 ; $2C02: $F0 $00
    cpl                                           ; $2C04: $2F
    and  $0F                                      ; $2C05: $E6 $0F
    swap a                                        ; $2C07: $CB $37
    ld   b, a                                     ; $2C09: $47
    ld   a, P1F_GET_BTN                           ; $2C0A: $3E $10
    ldh  [rP1], a                                 ; $2C0C: $E0 $00
    ldh  a, [rP1]                                 ; $2C0E: $F0 $00
    ldh  a, [rP1]                                 ; $2C10: $F0 $00
    ldh  a, [rP1]                                 ; $2C12: $F0 $00
    ldh  a, [rP1]                                 ; $2C14: $F0 $00
    ldh  a, [rP1]                                 ; $2C16: $F0 $00
    ldh  a, [rP1]                                 ; $2C18: $F0 $00
    cpl                                           ; $2C1A: $2F
    and  $0F                                      ; $2C1B: $E6 $0F
    or   b                                        ; $2C1D: $B0
    ld   c, a                                     ; $2C1E: $4F
    ldh  a, [hPressedButtonsMask]                 ; $2C1F: $F0 $8B
    xor  c                                        ; $2C21: $A9
    and  c                                        ; $2C22: $A1
    ldh  [hJoypadState], a                        ; $2C23: $E0 $8C
    ld   a, c                                     ; $2C25: $79
    ldh  [hPressedButtonsMask], a                 ; $2C26: $E0 $8B
    cp   $00                                      ; $2C28: $FE $00
    jr   nz, :+                                   ; $2C2A: $20 $02

    ldh  [$FFAE], a                               ; $2C2C: $E0 $AE

:   ld   a, P1F_GET_NONE                          ; $2C2E: $3E $30
    ldh  [rP1], a                                 ; $2C30: $E0 $00
    ret                                           ; $2C32: $C9


; Copies the DMA routine from ROM to HRAM
SetUpDMA::
    ld   c, LOW(DMARoutine)                       ; $2C33: $0E $80
    ld   b, DMARoutine.end - DMARoutine           ; $2C35: $06 $0A
    ld   hl, DMARoutineCode                       ; $2C37: $21 $41 $2C

:   ld   a, [hl+]                                 ; $2C3A: $2A
    ldh  [c], a                                   ; $2C3B: $E2
    inc  c                                        ; $2C3C: $0C
    dec  b                                        ; $2C3D: $05
    jr   nz, :-                                   ; $2C3E: $20 $FA

    ret                                           ; $2C40: $C9


; DMA routine which copies sprite data
; from $C000-$C09F (WRAM) to $FE00-$FE9F (OAM)
DMARoutineCode::
LOAD "DMA routine", HRAM[_HRAM]
DMARoutine::
    ld   a, HIGH(_RAM)                            ; $2C41: $3E $C0
    ldh  [rDMA], a                                ; $2C43: $E0 $46
    ld   a, $28 ; delay for 4×40 = 160 cycles     ; $2C45: $3E $28

:   dec  a                                        ; $2C47: $3D
    jr   nz, :-                                   ; $2C48: $20 $FD

    ret                                           ; $2C4A: $C9
.end
ENDL


Call_000_2C4B:
    ldh  a, [$FF8D]                               ; $2C4B: $F0 $8D
    sub  $10                                      ; $2C4D: $D6 $10
    srl  a                                        ; $2C4F: $CB $3F
    srl  a                                        ; $2C51: $CB $3F
    srl  a                                        ; $2C53: $CB $3F
    ld   de, $0000                                ; $2C55: $11 $00 $00
    ld   e, a                                     ; $2C58: $5F
    ld   hl, $C800                                ; $2C59: $21 $00 $C8
    ld   b, $20                                   ; $2C5C: $06 $20

jr_000_2C5E:
    add  hl, de                                   ; $2C5E: $19
    dec  b                                        ; $2C5F: $05
    jr   nz, jr_000_2C5E                          ; $2C60: $20 $FC

    ldh  a, [$FF8E]                               ; $2C62: $F0 $8E
    sub  $08                                      ; $2C64: $D6 $08
    srl  a                                        ; $2C66: $CB $3F
    srl  a                                        ; $2C68: $CB $3F
    srl  a                                        ; $2C6A: $CB $3F
    ld   de, $0000                                ; $2C6C: $11 $00 $00
    ld   e, a                                     ; $2C6F: $5F
    add  hl, de                                   ; $2C70: $19
    ld   a, h                                     ; $2C71: $7C
    ldh  [$FF8F], a                               ; $2C72: $E0 $8F
    ld   a, l                                     ; $2C74: $7D
    ldh  [$FF90], a                               ; $2C75: $E0 $90
    ret                                           ; $2C77: $C9


Call_000_2C78:
    ldh  a, [$FF8F]                               ; $2C78: $F0 $8F
    ld   d, a                                     ; $2C7A: $57
    ldh  a, [$FF90]                               ; $2C7B: $F0 $90
    ld   e, a                                     ; $2C7D: $5F
    ld   b, $04                                   ; $2C7E: $06 $04

jr_000_2C80:
    rr   d                                        ; $2C80: $CB $1A
    rr   e                                        ; $2C82: $CB $1B
    dec  b                                        ; $2C84: $05
    jr   nz, jr_000_2C80                          ; $2C85: $20 $F9

    ld   a, e                                     ; $2C87: $7B
    sub  $84                                      ; $2C88: $D6 $84
    and  $FE                                      ; $2C8A: $E6 $FE
    rlca                                          ; $2C8C: $07
    rlca                                          ; $2C8D: $07
    add  $20                                      ; $2C8E: $C6 $20
    ldh  [$FF8D], a                               ; $2C90: $E0 $8D
    ldh  a, [$FF90]                               ; $2C92: $F0 $90
    and  $1F                                      ; $2C94: $E6 $1F
    rla                                           ; $2C96: $17
    rla                                           ; $2C97: $17
    rla                                           ; $2C98: $17
    add  $08                                      ; $2C99: $C6 $08
    ldh  [$FF8E], a                               ; $2C9B: $E0 $8E
    ret                                           ; $2C9D: $C9


; Generic routine for dispatching to a jump table.
; Not used in this game.
JumpTable::
    add  a                                        ; $2C9E: $87
    pop  hl                                       ; $2C9F: $E1
    ld   e, a                                     ; $2CA0: $5F
    ld   d, $00                                   ; $2CA1: $16 $00
    add  hl, de                                   ; $2CA3: $19
    ld   e, [hl]                                  ; $2CA4: $5E
    inc  hl                                       ; $2CA5: $23
    ld   d, [hl]                                  ; $2CA6: $56
    push de                                       ; $2CA7: $D5
    pop  hl                                       ; $2CA8: $E1
    jp   hl                                       ; $2CA9: $E9


LCDOff::
    ldh  a, [rIE]                                 ; $2CAA: $F0 $FF
    ldh  [hIE], a                                 ; $2CAC: $E0 $92
    res  0, a                                     ; $2CAE: $CB $87
    ; Possible bug: Doesn't load A back into rIE, so
    ; interrupts aren't actually disabled here!

; Wait for VBlank
:   ldh  a, [rLY]                                 ; $2CB0: $F0 $44
    cp   $91                                      ; $2CB2: $FE $91
    jr   c, :-                                    ; $2CB4: $38 $FA

    ldh  a, [rLCDC]                               ; $2CB6: $F0 $40
    and  $7F                                      ; $2CB8: $E6 $7F
    ldh  [rLCDC], a                               ; $2CBA: $E0 $40
    ldh  a, [hIE]                                 ; $2CBC: $F0 $92
    ldh  [rIE], a                                 ; $2CBE: $E0 $FF
    ret                                           ; $2CC0: $C9


MemClear::
    ld   a, $00                                   ; $2CC1: $3E $00
    ld   [hl+], a                                 ; $2CC3: $22
    dec  bc                                       ; $2CC4: $0B
    ld   a, c                                     ; $2CC5: $79
    or   b                                        ; $2CC6: $B0
    jr   nz, MemClear                             ; $2CC7: $20 $F8

    ret                                           ; $2CC9: $C9


ClearScreen::
    ld   hl, $9BFF                                ; $2CCA: $21 $FF $9B
    ld   bc, $0400                                ; $2CCD: $01 $00 $04

:   ld   a, $24                                   ; $2CD0: $3E $24
    ld   [hl-], a                                 ; $2CD2: $32
    dec  bc                                       ; $2CD3: $0B
    ld   a, b                                     ; $2CD4: $78
    or   c                                        ; $2CD5: $B1
    jr   nz, :-                                   ; $2CD6: $20 $F8

    ret                                           ; $2CD8: $C9


MemCpyHLtoDE::
    ld   a, [hl+]                                 ; $2CD9: $2A
    ld   [de], a                                  ; $2CDA: $12
    inc  de                                       ; $2CDB: $13
    dec  bc                                       ; $2CDC: $0B
    ld   a, b                                     ; $2CDD: $78
    or   c                                        ; $2CDE: $B1
    jr   nz, MemCpyHLtoDE                         ; $2CDF: $20 $F8

    ret                                           ; $2CE1: $C9


ExecuteDrawCommands::
    inc  de                                       ; $2CE2: $13
    ld   h, a                                     ; $2CE3: $67
    ld   a, [de]                                  ; $2CE4: $1A
    ld   l, a                                     ; $2CE5: $6F
    inc  de                                       ; $2CE6: $13
    ld   a, [de]                                  ; $2CE7: $1A
    inc  de                                       ; $2CE8: $13
    call ExecuteDrawCommand                       ; $2CE9: $CD $F2 $2C

ExecuteDrawCommands.getNextDrawCommand::
    ld   a, [de]                                  ; $2CEC: $1A
    cp   $00                                      ; $2CED: $FE $00
    jr   nz, ExecuteDrawCommands                  ; $2CEF: $20 $F1

    ret                                           ; $2CF1: $C9


ExecuteDrawCommand::
    push af                                       ; $2CF2: $F5
    and  $3F                                      ; $2CF3: $E6 $3F
    ld   b, a                                     ; $2CF5: $47
    pop  af                                       ; $2CF6: $F1
    rlca                                          ; $2CF7: $07
    rlca                                          ; $2CF8: $07
    and  $03                                      ; $2CF9: $E6 $03
    jr   z, .horizontalDraw                       ; $2CFB: $28 $08

    dec  a                                        ; $2CFD: $3D
    jr   z, .horizontalStamp                      ; $2CFE: $28 $0C

    dec  a                                        ; $2D00: $3D
    jr   z, .verticalDraw                         ; $2D01: $28 $10

    jr   .verticalStamp                           ; $2D03: $18 $1B

.horizontalDraw:
    ld   a, [de]                                  ; $2D05: $1A
    ld   [hl+], a                                 ; $2D06: $22
    inc  de                                       ; $2D07: $13
    dec  b                                        ; $2D08: $05
    jr   nz, .horizontalDraw                      ; $2D09: $20 $FA

    ret                                           ; $2D0B: $C9


.horizontalStamp:
    ld   a, [de]                                  ; $2D0C: $1A
    inc  de                                       ; $2D0D: $13

:   ld   [hl+], a                                 ; $2D0E: $22
    dec  b                                        ; $2D0F: $05
    jr   nz, :-                                   ; $2D10: $20 $FC

    ret                                           ; $2D12: $C9


.verticalDraw:
    ld   a, [de]                                  ; $2D13: $1A
    ld   [hl], a                                  ; $2D14: $77
    inc  de                                       ; $2D15: $13
    ld   a, b                                     ; $2D16: $78
    ld   bc, $0020                                ; $2D17: $01 $20 $00
    add  hl, bc                                   ; $2D1A: $09
    ld   b, a                                     ; $2D1B: $47
    dec  b                                        ; $2D1C: $05
    jr   nz, .verticalDraw                        ; $2D1D: $20 $F4

    ret                                           ; $2D1F: $C9


.verticalStamp:
    ld   a, [de]                                  ; $2D20: $1A
    ld   [hl], a                                  ; $2D21: $77
    ld   a, b                                     ; $2D22: $78
    ld   bc, $0020                                ; $2D23: $01 $20 $00
    add  hl, bc                                   ; $2D26: $09
    ld   b, a                                     ; $2D27: $47
    dec  b                                        ; $2D28: $05
    jr   nz, .verticalStamp                       ; $2D29: $20 $F5

    inc  de                                       ; $2D2B: $13
    ret                                           ; $2D2C: $C9


ExecuteDrawCommandsToWRAM::
    inc  de                                       ; $2D2D: $13
    and  $0F                                      ; $2D2E: $E6 $0F
    or   $C0                                      ; $2D30: $F6 $C0
    ld   h, a                                     ; $2D32: $67
    ld   a, [de]                                  ; $2D33: $1A
    ld   l, a                                     ; $2D34: $6F
    inc  de                                       ; $2D35: $13
    ld   a, [de]                                  ; $2D36: $1A
    inc  de                                       ; $2D37: $13
    call ExecuteDrawCommand                       ; $2D38: $CD $F2 $2C

ExecuteDrawCommandsToWRAM.getNextDrawCommand::
    ld   a, [de]                                  ; $2D3B: $1A
    cp   $00                                      ; $2D3C: $FE $00
    jr   nz, ExecuteDrawCommandsToWRAM            ; $2D3E: $20 $ED

    ret                                           ; $2D40: $C9


InitNewGame::
    ld   hl, hCredits                             ; $2D41: $21 $C4 $FF
    ld   a, $03                                   ; $2D44: $3E $03
    ld   [hl+], a                                 ; $2D46: $22

.continue
    ld   a, $02                                   ; $2D47: $3E $02
    ld   [hl+], a                                 ; $2D49: $22
    ld   a, $01                                   ; $2D4A: $3E $01
    ld   [hl+], a                                 ; $2D4C: $22
    ld   a, $00                                   ; $2D4D: $3E $00
    ld   [hl+], a                                 ; $2D4F: $22
    ld   [hl], a                                  ; $2D50: $77
    ldh  [$FFAC], a                               ; $2D51: $E0 $AC
    ldh  [$FFC2], a                               ; $2D53: $E0 $C2

LoadStage::
    ldh  a, [hStage+1]                            ; $2D55: $F0 $C7
    cp   $00                                      ; $2D57: $FE $00
    jr   z, .convertStageNumberToTablePointer     ; $2D59: $28 $08

    ld   b, a                                     ; $2D5B: $47
    ld   a, $00                                   ; $2D5C: $3E $00

.convertStageNumberFromBCD:
    add  $0A                                      ; $2D5E: $C6 $0A
    dec  b                                        ; $2D60: $05
    jr   nz, .convertStageNumberFromBCD           ; $2D61: $20 $FB

.convertStageNumberToTablePointer:
    ld   b, a                                     ; $2D63: $47
    ldh  a, [hStage]                              ; $2D64: $F0 $C6
    add  b                                        ; $2D66: $80
    sub  $01                                      ; $2D67: $D6 $01
    rlca                                          ; $2D69: $07
    ld   hl, StageTable                           ; $2D6A: $21 $0E $3A

.loadStageData
    ld   c, a                                     ; $2D6D: $4F
    ld   b, $00                                   ; $2D6E: $06 $00
    add  hl, bc                                   ; $2D70: $09
    ld   a, [hl+]                                 ; $2D71: $2A
    ld   b, a                                     ; $2D72: $47
    ld   a, [hl]                                  ; $2D73: $7E
    ld   h, a                                     ; $2D74: $67
    ld   l, b                                     ; $2D75: $68
    ld   a, [hl+]                                 ; $2D76: $2A
    ld   c, a                                     ; $2D77: $4F
    ld   a, [hl+]                                 ; $2D78: $2A
    ld   b, a                                     ; $2D79: $47
    ld   a, [hl]                                  ; $2D7A: $7E
    ldh  [hBlocks+1], a                           ; $2D7B: $E0 $CA
    ldh  [hBlocksInitial+1], a                    ; $2D7D: $E0 $C1
    ld   a, b                                     ; $2D7F: $78
    ldh  [hBlocks], a                             ; $2D80: $E0 $C9
    ldh  [hBlocksInitial], a                      ; $2D82: $E0 $C0
    ld   a, c                                     ; $2D84: $79
    ldh  [$FFCF], a                               ; $2D85: $E0 $CF
    ld   hl, hSeconds                             ; $2D87: $21 $CB $FF
    ld   a, $00                                   ; $2D8A: $3E $00
    ld   [hl+], a                                 ; $2D8C: $22
    ld   [hl+], a                                 ; $2D8D: $22
    ld   a, $28                                   ; $2D8E: $3E $28
    ld   [hl+], a                                 ; $2D90: $22
    ld   a, $03                                   ; $2D91: $3E $03
    ld   [hl], a                                  ; $2D93: $77
    ret                                           ; $2D94: $C9


Call_000_2D95:
jr_000_2D95:
    ld   hl, $FFAF                                ; $2D95: $21 $AF $FF
    inc  [hl]                                     ; $2D98: $34
    ld   a, [hl]                                  ; $2D99: $7E
    and  $0F                                      ; $2D9A: $E6 $0F
    rlca                                          ; $2D9C: $07
    ld   hl, $FFDB                                ; $2D9D: $21 $DB $FF
    cp   [hl]                                     ; $2DA0: $BE
    jr   z, jr_000_2D95                           ; $2DA1: $28 $F2

LoadAttractModeStage::
    ldh  [$FFDA], a                               ; $2DA3: $E0 $DA
    ldh  [$FFDB], a                               ; $2DA5: $E0 $DB
    ld   hl, StageTable.3A4E                      ; $2DA7: $21 $4E $3A
    jr   LoadStage.loadStageData                  ; $2DAA: $18 $C1

MemCpyDEtoHLReverse::
    ld   a, [de]                                  ; $2DAC: $1A
    ld   [hl+], a                                 ; $2DAD: $22
    dec  de                                       ; $2DAE: $1B
    dec  b                                        ; $2DAF: $05
    jr   nz, MemCpyDEtoHLReverse                  ; $2DB0: $20 $FA

    ret                                           ; $2DB2: $C9


MemCpyDEtoWRAM::
    ld   hl, _RAM                                 ; $2DB3: $21 $00 $C0

MemCpyDEtoHLShort::
    ld   a, [de]                                  ; $2DB6: $1A
    ld   [hl+], a                                 ; $2DB7: $22
    inc  de                                       ; $2DB8: $13
    dec  b                                        ; $2DB9: $05
    jr   nz, MemCpyDEtoHLShort                    ; $2DBA: $20 $FA

    ret                                           ; $2DBC: $C9


Call_000_2DBD:
    ld   a, $00                                   ; $2DBD: $3E $00
    ld   hl, $CA31                                ; $2DBF: $21 $31 $CA
    ld   [hl+], a                                 ; $2DC2: $22
    ld   [hl+], a                                 ; $2DC3: $22
    ld   [hl+], a                                 ; $2DC4: $22
    ld   [hl+], a                                 ; $2DC5: $22
    ld   [hl], a                                  ; $2DC6: $77
    ld   de, wBlockRNG                            ; $2DC7: $11 $00 $CA
    ldh  a, [hBlocks+1]                           ; $2DCA: $F0 $CA
    cp   $03                                      ; $2DCC: $FE $03
    jp   z, Jump_000_2E7F                         ; $2DCE: $CA $7F $2E

    ld   hl, $C941                                ; $2DD1: $21 $41 $C9
    push hl                                       ; $2DD4: $E5
    ld   b, $05                                   ; $2DD5: $06 $05
    ld   c, b                                     ; $2DD7: $48

jr_000_2DD8:
    ld   hl, $CA31                                ; $2DD8: $21 $31 $CA
    ld   a, [de]                                  ; $2DDB: $1A
    cp   $85                                      ; $2DDC: $FE $85
    jr   z, jr_000_2DEB                           ; $2DDE: $28 $0B

    inc  hl                                       ; $2DE0: $23
    cp   $84                                      ; $2DE1: $FE $84
    jr   z, jr_000_2DEB                           ; $2DE3: $28 $06

    inc  hl                                       ; $2DE5: $23
    cp   $83                                      ; $2DE6: $FE $83
    jr   z, jr_000_2DEB                           ; $2DE8: $28 $01

    inc  hl                                       ; $2DEA: $23

jr_000_2DEB:
    inc  [hl]                                     ; $2DEB: $34
    ld   a, [hl]                                  ; $2DEC: $7E
    cp   $07                                      ; $2DED: $FE $07
    jr   c, jr_000_2E04                           ; $2DEF: $38 $13

    jr   z, jr_000_2DF8                           ; $2DF1: $28 $05

jr_000_2DF3:
    pop  hl                                       ; $2DF3: $E1
    inc  de                                       ; $2DF4: $13
    push hl                                       ; $2DF5: $E5
    jr   jr_000_2DD8                              ; $2DF6: $18 $E0

jr_000_2DF8:
    ld   a, [$CA35]                               ; $2DF8: $FA $35 $CA
    cp   $00                                      ; $2DFB: $FE $00
    jr   nz, jr_000_2DF3                          ; $2DFD: $20 $F4

    add  $01                                      ; $2DFF: $C6 $01
    ld   [$CA35], a                               ; $2E01: $EA $35 $CA

jr_000_2E04:
    pop  hl                                       ; $2E04: $E1
    ld   a, [de]                                  ; $2E05: $1A
    inc  de                                       ; $2E06: $13
    ld   [hl+], a                                 ; $2E07: $22
    push hl                                       ; $2E08: $E5
    dec  b                                        ; $2E09: $05
    jr   nz, jr_000_2DD8                          ; $2E0A: $20 $CC

    pop  hl                                       ; $2E0C: $E1
    ld   a, l                                     ; $2E0D: $7D
    and  $F0                                      ; $2E0E: $E6 $F0
    add  $21                                      ; $2E10: $C6 $21
    ld   l, a                                     ; $2E12: $6F
    push hl                                       ; $2E13: $E5
    ld   b, c                                     ; $2E14: $41
    cp   $E1                                      ; $2E15: $FE $E1
    jr   nz, jr_000_2DD8                          ; $2E17: $20 $BF

    pop  hl                                       ; $2E19: $E1

Jump_000_2E1A:
    ldh  a, [$FFAC]                               ; $2E1A: $F0 $AC
    cp   $00                                      ; $2E1C: $FE $00
    jr   z, jr_000_2E7E                           ; $2E1E: $28 $5E

    ld   d, a                                     ; $2E20: $57
    ldh  a, [hBlocks+1]                           ; $2E21: $F0 $CA
    cp   $03                                      ; $2E23: $FE $03
    jr   z, jr_000_2E33                           ; $2E25: $28 $0C

    ldh  a, [$FFAF]                               ; $2E27: $F0 $AF
    and  $1F                                      ; $2E29: $E6 $1F
    cp   $19                                      ; $2E2B: $FE $19
    jr   c, jr_000_2E4F                           ; $2E2D: $38 $20

    sub  $18                                      ; $2E2F: $D6 $18
    jr   jr_000_2E4F                              ; $2E31: $18 $1C

jr_000_2E33:
    ldh  a, [hBlocks]                             ; $2E33: $F0 $C9
    cp   $00                                      ; $2E35: $FE $00
    jr   nz, jr_000_2E45                          ; $2E37: $20 $0C

    ldh  a, [$FFAF]                               ; $2E39: $F0 $AF
    and  $1F                                      ; $2E3B: $E6 $1F
    cp   $1E                                      ; $2E3D: $FE $1E
    jr   c, jr_000_2E4F                           ; $2E3F: $38 $0E

    sub  $1D                                      ; $2E41: $D6 $1D
    jr   jr_000_2E4F                              ; $2E43: $18 $0A

jr_000_2E45:
    ldh  a, [$FFAF]                               ; $2E45: $F0 $AF
    and  $3F                                      ; $2E47: $E6 $3F
    cp   $24                                      ; $2E49: $FE $24
    jr   c, jr_000_2E4F                           ; $2E4B: $38 $02

    sub  $23                                      ; $2E4D: $D6 $23

jr_000_2E4F:
    ld   hl, $C921                                ; $2E4F: $21 $21 $C9
    ld   c, a                                     ; $2E52: $4F

jr_000_2E53:
    ld   b, c                                     ; $2E53: $41

jr_000_2E54:
    ld   a, [hl+]                                 ; $2E54: $2A
    cp   $82                                      ; $2E55: $FE $82
    jr   z, jr_000_2E54                           ; $2E57: $28 $FB

    cp   $00                                      ; $2E59: $FE $00
    jr   z, jr_000_2E61                           ; $2E5B: $28 $04

    cp   $81                                      ; $2E5D: $FE $81
    jr   nz, jr_000_2E70                          ; $2E5F: $20 $0F

jr_000_2E61:
    ld   a, l                                     ; $2E61: $7D
    and  $F0                                      ; $2E62: $E6 $F0
    add  $21                                      ; $2E64: $C6 $21
    ld   l, a                                     ; $2E66: $6F
    cp   $E1                                      ; $2E67: $FE $E1
    jr   nz, jr_000_2E54                          ; $2E69: $20 $E9

    ld   hl, $C921                                ; $2E6B: $21 $21 $C9
    jr   jr_000_2E54                              ; $2E6E: $18 $E4

jr_000_2E70:
    dec  b                                        ; $2E70: $05
    jr   nz, jr_000_2E54                          ; $2E71: $20 $E1

    dec  hl                                       ; $2E73: $2B
    ld   a, $82                                   ; $2E74: $3E $82
    ld   [hl], a                                  ; $2E76: $77
    dec  d                                        ; $2E77: $15
    jr   nz, jr_000_2E53                          ; $2E78: $20 $D9

    ld   a, $00                                   ; $2E7A: $3E $00
    ldh  [$FFAC], a                               ; $2E7C: $E0 $AC

jr_000_2E7E:
    ret                                           ; $2E7E: $C9


Jump_000_2E7F:
    ld   hl, $C921                                ; $2E7F: $21 $21 $C9
    ldh  a, [hBlocks]                             ; $2E82: $F0 $C9
    cp   $00                                      ; $2E84: $FE $00
    jr   nz, jr_000_2ED1                          ; $2E86: $20 $49

    push hl                                       ; $2E88: $E5
    ld   b, $05                                   ; $2E89: $06 $05
    ld   c, b                                     ; $2E8B: $48

jr_000_2E8C:
    ld   hl, $CA31                                ; $2E8C: $21 $31 $CA
    ld   a, [de]                                  ; $2E8F: $1A
    cp   $85                                      ; $2E90: $FE $85
    jr   z, jr_000_2E9F                           ; $2E92: $28 $0B

    inc  hl                                       ; $2E94: $23
    cp   $84                                      ; $2E95: $FE $84
    jr   z, jr_000_2E9F                           ; $2E97: $28 $06

    inc  hl                                       ; $2E99: $23
    cp   $83                                      ; $2E9A: $FE $83
    jr   z, jr_000_2E9F                           ; $2E9C: $28 $01

    inc  hl                                       ; $2E9E: $23

jr_000_2E9F:
    inc  [hl]                                     ; $2E9F: $34
    ld   a, [hl]                                  ; $2EA0: $7E
    cp   $08                                      ; $2EA1: $FE $08
    jr   c, jr_000_2EB8                           ; $2EA3: $38 $13

    jr   z, jr_000_2EAC                           ; $2EA5: $28 $05

jr_000_2EA7:
    pop  hl                                       ; $2EA7: $E1
    inc  de                                       ; $2EA8: $13
    push hl                                       ; $2EA9: $E5
    jr   jr_000_2E8C                              ; $2EAA: $18 $E0

jr_000_2EAC:
    ld   a, [$CA35]                               ; $2EAC: $FA $35 $CA
    cp   $02                                      ; $2EAF: $FE $02
    jr   nc, jr_000_2EA7                          ; $2EB1: $30 $F4

    add  $01                                      ; $2EB3: $C6 $01
    ld   [$CA35], a                               ; $2EB5: $EA $35 $CA

jr_000_2EB8:
    pop  hl                                       ; $2EB8: $E1
    ld   a, [de]                                  ; $2EB9: $1A
    inc  de                                       ; $2EBA: $13
    ld   [hl+], a                                 ; $2EBB: $22
    push hl                                       ; $2EBC: $E5
    dec  b                                        ; $2EBD: $05
    jr   nz, jr_000_2E8C                          ; $2EBE: $20 $CC

    pop  hl                                       ; $2EC0: $E1
    ld   a, l                                     ; $2EC1: $7D
    and  $F0                                      ; $2EC2: $E6 $F0
    add  $21                                      ; $2EC4: $C6 $21
    ld   l, a                                     ; $2EC6: $6F
    push hl                                       ; $2EC7: $E5
    ld   b, c                                     ; $2EC8: $41
    cp   $E1                                      ; $2EC9: $FE $E1
    jr   nz, jr_000_2E8C                          ; $2ECB: $20 $BF

    pop  hl                                       ; $2ECD: $E1
    jp   Jump_000_2E1A                            ; $2ECE: $C3 $1A $2E


jr_000_2ED1:
    ld   b, $06                                   ; $2ED1: $06 $06
    ld   c, b                                     ; $2ED3: $48

jr_000_2ED4:
    ld   a, [de]                                  ; $2ED4: $1A
    inc  de                                       ; $2ED5: $13
    ld   [hl+], a                                 ; $2ED6: $22
    dec  b                                        ; $2ED7: $05
    jr   nz, jr_000_2ED4                          ; $2ED8: $20 $FA

    ld   a, l                                     ; $2EDA: $7D
    and  $F0                                      ; $2EDB: $E6 $F0
    add  $21                                      ; $2EDD: $C6 $21
    ld   l, a                                     ; $2EDF: $6F
    ld   b, c                                     ; $2EE0: $41
    cp   $E1                                      ; $2EE1: $FE $E1
    jr   nz, jr_000_2ED4                          ; $2EE3: $20 $EF

    jp   Jump_000_2E1A                            ; $2EE5: $C3 $1A $2E


Call_000_2EE8:
    ldh  a, [hCounter]                            ; $2EE8: $F0 $B0
    ld   b, a                                     ; $2EEA: $47
    ldh  a, [hCounter+1]                          ; $2EEB: $F0 $B1
    or   b                                        ; $2EED: $B0
    ret                                           ; $2EEE: $C9


Call_000_2EEF:
    ldh  a, [$FFB2]                               ; $2EEF: $F0 $B2
    ld   b, a                                     ; $2EF1: $47
    ldh  a, [$FFB3]                               ; $2EF2: $F0 $B3
    or   b                                        ; $2EF4: $B0
    ret                                           ; $2EF5: $C9


Call_000_2EF6:
    ldh  a, [$FFA6]                               ; $2EF6: $F0 $A6
    bit  1, a                                     ; $2EF8: $CB $4F
    ret  z                                        ; $2EFA: $C8

    push hl                                       ; $2EFB: $E5
    ld   bc, hMusicSpeed                          ; $2EFC: $01 $E0 $FF

jr_000_2EFF:
    add  hl, bc                                   ; $2EFF: $09
    ld   a, [hl]                                  ; $2F00: $7E
    cp   $00                                      ; $2F01: $FE $00
    jr   z, jr_000_2EFF                           ; $2F03: $28 $FA

jr_000_2F05:
    push hl                                       ; $2F05: $E5
    pop  de                                       ; $2F06: $D1
    pop  hl                                       ; $2F07: $E1
    ld   a, [de]                                  ; $2F08: $1A
    cp   $80                                      ; $2F09: $FE $80
    jr   z, jr_000_2F15                           ; $2F0B: $28 $08

    cp   $87                                      ; $2F0D: $FE $87
    jr   z, jr_000_2F15                           ; $2F0F: $28 $04

    cp   $81                                      ; $2F11: $FE $81
    jr   nz, jr_000_2F1A                          ; $2F13: $20 $05

jr_000_2F15:
    ld   a, $00                                   ; $2F15: $3E $00
    ld   [hl], a                                  ; $2F17: $77
    jr   jr_000_2F21                              ; $2F18: $18 $07

jr_000_2F1A:
    ld   [hl], a                                  ; $2F1A: $77
    ldh  a, [$FFA9]                               ; $2F1B: $F0 $A9
    or   $02                                      ; $2F1D: $F6 $02
    ldh  [$FFA9], a                               ; $2F1F: $E0 $A9

jr_000_2F21:
    ld   a, [hl]                                  ; $2F21: $7E
    cp   $00                                      ; $2F22: $FE $00
    jr   nz, jr_000_2F30                          ; $2F24: $20 $0A

    ldh  a, [$FFA9]                               ; $2F26: $F0 $A9
    bit  1, a                                     ; $2F28: $CB $4F
    ret  z                                        ; $2F2A: $C8

    and  $FD                                      ; $2F2B: $E6 $FD
    ldh  [$FFA9], a                               ; $2F2D: $E0 $A9
    ret                                           ; $2F2F: $C9


jr_000_2F30:
    ld   a, $00                                   ; $2F30: $3E $00
    ld   [de], a                                  ; $2F32: $12
    add  hl, bc                                   ; $2F33: $09
    push hl                                       ; $2F34: $E5
    push de                                       ; $2F35: $D5
    pop  hl                                       ; $2F36: $E1
    add  hl, bc                                   ; $2F37: $09
    jr   jr_000_2F05                              ; $2F38: $18 $CB

Call_000_2F3A:
    ldh  a, [$FFD1]                               ; $2F3A: $F0 $D1
    cp   $00                                      ; $2F3C: $FE $00
    ret  z                                        ; $2F3E: $C8

    ldh  a, [$FFA6]                               ; $2F3F: $F0 $A6
    bit  0, a                                     ; $2F41: $CB $47
    jr   nz, jr_000_2F4F                          ; $2F43: $20 $0A

    ldh  a, [$FFD1]                               ; $2F45: $F0 $D1
    cp   $04                                      ; $2F47: $FE $04
    jr   c, jr_000_2F4F                           ; $2F49: $38 $04

    ld   hl, $FFAC                                ; $2F4B: $21 $AC $FF
    inc  [hl]                                     ; $2F4E: $34

jr_000_2F4F:
    ldh  a, [$FFD1]                               ; $2F4F: $F0 $D1
    ld   b, a                                     ; $2F51: $47
    ld   c, a                                     ; $2F52: $4F
    ld   hl, $C122                                ; $2F53: $21 $22 $C1

jr_000_2F56:
    push hl                                       ; $2F56: $E5
    add  [hl]                                     ; $2F57: $86

jr_000_2F58:
    cp   $0A                                      ; $2F58: $FE $0A
    jr   c, jr_000_2F63                           ; $2F5A: $38 $07

    sub  $0A                                      ; $2F5C: $D6 $0A
    ld   [hl+], a                                 ; $2F5E: $22
    inc  [hl]                                     ; $2F5F: $34
    ld   a, [hl]                                  ; $2F60: $7E
    jr   jr_000_2F58                              ; $2F61: $18 $F5

jr_000_2F63:
    ld   [hl], a                                  ; $2F63: $77
    push hl                                       ; $2F64: $E5
    pop  de                                       ; $2F65: $D1
    ld   a, c                                     ; $2F66: $79
    pop  hl                                       ; $2F67: $E1
    dec  b                                        ; $2F68: $05
    jr   nz, jr_000_2F56                          ; $2F69: $20 $EB

    ldh  a, [$FF97]                               ; $2F6B: $F0 $97
    cp   $01                                      ; $2F6D: $FE $01
    jr   z, jr_000_2F89                           ; $2F6F: $28 $18

    ld   a, e                                     ; $2F71: $7B
    cp   $24                                      ; $2F72: $FE $24
    jr   nz, jr_000_2F85                          ; $2F74: $20 $0F

    ld   a, [de]                                  ; $2F76: $1A
    cp   $02                                      ; $2F77: $FE $02
    jr   z, jr_000_2F7F                           ; $2F79: $28 $04

    cp   $05                                      ; $2F7B: $FE $05
    jr   nz, jr_000_2F89                          ; $2F7D: $20 $0A

jr_000_2F7F:
    ld   hl, hSBlocksRemaining                    ; $2F7F: $21 $C5 $FF
    inc  [hl]                                     ; $2F82: $34
    jr   jr_000_2F89                              ; $2F83: $18 $04

jr_000_2F85:
    cp   $25                                      ; $2F85: $FE $25
    jr   z, jr_000_2F7F                           ; $2F87: $28 $F6

jr_000_2F89:
    ld   hl, $C103                                ; $2F89: $21 $03 $C1
    ld   a, $00                                   ; $2F8C: $3E $00
    ld   [hl+], a                                 ; $2F8E: $22
    ld   [hl], a                                  ; $2F8F: $77
    dec  hl                                       ; $2F90: $2B
    ldh  a, [$FFD1]                               ; $2F91: $F0 $D1
    ld   b, a                                     ; $2F93: $47
    ld   d, a                                     ; $2F94: $57

jr_000_2F95:
    push hl                                       ; $2F95: $E5
    add  [hl]                                     ; $2F96: $86

jr_000_2F97:
    cp   $0A                                      ; $2F97: $FE $0A
    jr   c, jr_000_2FA2                           ; $2F99: $38 $07

    sub  $0A                                      ; $2F9B: $D6 $0A
    ld   [hl+], a                                 ; $2F9D: $22
    inc  [hl]                                     ; $2F9E: $34
    ld   a, [hl]                                  ; $2F9F: $7E
    jr   jr_000_2F97                              ; $2FA0: $18 $F5

jr_000_2FA2:
    ld   [hl], a                                  ; $2FA2: $77
    ld   a, d                                     ; $2FA3: $7A
    pop  hl                                       ; $2FA4: $E1
    dec  b                                        ; $2FA5: $05
    jr   nz, jr_000_2F95                          ; $2FA6: $20 $ED

    ld   a, $00                                   ; $2FA8: $3E $00
    ldh  [$FFD1], a                               ; $2FAA: $E0 $D1
    ld   hl, $FFD3                                ; $2FAC: $21 $D3 $FF
    ld   a, d                                     ; $2FAF: $7A
    cp   $01                                      ; $2FB0: $FE $01
    jr   nz, jr_000_2FB6                          ; $2FB2: $20 $02

    inc  [hl]                                     ; $2FB4: $34
    ret                                           ; $2FB5: $C9


jr_000_2FB6:
    ld   a, $00                                   ; $2FB6: $3E $00
    ld   [hl], a                                  ; $2FB8: $77
    ldh  a, [$FF97]                               ; $2FB9: $F0 $97
    cp   $01                                      ; $2FBB: $FE $01
    ret  z                                        ; $2FBD: $C8

    ld   a, $01                                   ; $2FBE: $3E $01
    ldh  [$FF9E], a                               ; $2FC0: $E0 $9E
    ld   a, $50                                   ; $2FC2: $3E $50
    ldh  [$FFB8], a                               ; $2FC4: $E0 $B8

jr_000_2FC6:
    ld   hl, $C020                                ; $2FC6: $21 $20 $C0
    ld   de, $C104                                ; $2FC9: $11 $04 $C1
    ldh  a, [$FFB8]                               ; $2FCC: $F0 $B8
    ld   [hl+], a                                 ; $2FCE: $22
    ld   b, a                                     ; $2FCF: $47
    ld   a, $20                                   ; $2FD0: $3E $20
    ld   [hl+], a                                 ; $2FD2: $22
    ld   c, a                                     ; $2FD3: $4F
    ld   a, [de]                                  ; $2FD4: $1A
    cp   $00                                      ; $2FD5: $FE $00
    jr   nz, jr_000_2FDB                          ; $2FD7: $20 $02

    dec  de                                       ; $2FD9: $1B
    ld   a, [de]                                  ; $2FDA: $1A

jr_000_2FDB:
    ld   [hl+], a                                 ; $2FDB: $22
    ld   a, $00                                   ; $2FDC: $3E $00
    ld   [hl+], a                                 ; $2FDE: $22

jr_000_2FDF:
    ld   a, e                                     ; $2FDF: $7B
    cp   $01                                      ; $2FE0: $FE $01
    jr   z, jr_000_2FF3                           ; $2FE2: $28 $0F

    ld   a, b                                     ; $2FE4: $78
    ld   [hl+], a                                 ; $2FE5: $22
    ld   a, c                                     ; $2FE6: $79
    add  $08                                      ; $2FE7: $C6 $08
    ld   [hl+], a                                 ; $2FE9: $22
    ld   c, a                                     ; $2FEA: $4F
    dec  de                                       ; $2FEB: $1B
    ld   a, [de]                                  ; $2FEC: $1A
    ld   [hl+], a                                 ; $2FED: $22
    ld   a, $00                                   ; $2FEE: $3E $00
    ld   [hl+], a                                 ; $2FF0: $22
    jr   jr_000_2FDF                              ; $2FF1: $18 $EC

jr_000_2FF3:
    ld   a, $30                                   ; $2FF3: $3E $30
    ldh  [$FFB2], a                               ; $2FF5: $E0 $B2
    ld   a, $00                                   ; $2FF7: $3E $00
    ldh  [$FFB3], a                               ; $2FF9: $E0 $B3
    ret                                           ; $2FFB: $C9


Call_000_2FFC:
    ldh  a, [$FF9E]                               ; $2FFC: $F0 $9E
    cp   $00                                      ; $2FFE: $FE $00
    ret  z                                        ; $3000: $C8

    call Call_000_2EEF                            ; $3001: $CD $EF $2E
    ret  nz                                       ; $3004: $C0

    ldh  a, [$FFB8]                               ; $3005: $F0 $B8
    sub  $01                                      ; $3007: $D6 $01
    ldh  [$FFB8], a                               ; $3009: $E0 $B8
    cp   $44                                      ; $300B: $FE $44
    jr   nz, jr_000_2FC6                          ; $300D: $20 $B7

    ld   hl, $C020                                ; $300F: $21 $20 $C0
    call Call_000_30E5                            ; $3012: $CD $E5 $30
    ld   a, $00                                   ; $3015: $3E $00
    ldh  [$FF9E], a                               ; $3017: $E0 $9E
    ret                                           ; $3019: $C9


Call_000_301A:
    ld   hl, $C121                                ; $301A: $21 $21 $C1

jr_000_301D:
    ld   a, [hl]                                  ; $301D: $7E
    add  $01                                      ; $301E: $C6 $01
    ld   [hl], a                                  ; $3020: $77
    cp   $0A                                      ; $3021: $FE $0A
    ret  nz                                       ; $3023: $C0

    ld   a, $00                                   ; $3024: $3E $00
    ld   [hl+], a                                 ; $3026: $22
    jr   jr_000_301D                              ; $3027: $18 $F4

Call_000_3029:
    ldh  a, [$FF97]                               ; $3029: $F0 $97
    cp   $00                                      ; $302B: $FE $00
    jr   nz, .jr_000_3050                          ; $302D: $20 $21

    ld   hl, $9921                                ; $302F: $21 $21 $99
    ld   de, $C921                                ; $3032: $11 $21 $C9
    ld   c, $06                                   ; $3035: $0E $06

.nextRow:
    ld   b, $06                                   ; $3037: $06 $06

.rowLoop:
    ld   a, [de]                                  ; $3039: $1A
    cp   $00                                      ; $303A: $FE $00
    jr   nz, .nextBlock                           ; $303C: $20 $02

    ld   a, $24                                   ; $303E: $3E $24

.nextBlock:
    ld   [hl+], a                                 ; $3040: $22
    inc  de                                       ; $3041: $13
    dec  b                                        ; $3042: $05
    jr   nz, .rowLoop                             ; $3043: $20 $F4

    dec  c                                        ; $3045: $0D
    ret  z                                        ; $3046: $C8

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

    ld   a, $01                                   ; $3056: $3E $01
    ldh  [$FF9C], a                               ; $3058: $E0 $9C
    ld   hl, $9941                                ; $305A: $21 $41 $99
    ld   de, $C941                                ; $305D: $11 $41 $C9
    ld   c, $05                                   ; $3060: $0E $05

.jr_000_3062:
    ld   b, $08                                   ; $3062: $06 $08

.jr_000_3064:
    ld   a, [de]                                  ; $3064: $1A
    cp   $00                                      ; $3065: $FE $00
    jr   nz, .jr_000_306B                          ; $3067: $20 $02

    ld   a, $24                                   ; $3069: $3E $24

.jr_000_306B:
    ld   [hl+], a                                 ; $306B: $22
    inc  de                                       ; $306C: $13
    dec  b                                        ; $306D: $05
    jr   nz, .jr_000_3064                          ; $306E: $20 $F4

    dec  c                                        ; $3070: $0D
    ret  z                                        ; $3071: $C8

    ld   a, l                                     ; $3072: $7D
    and  $F0                                      ; $3073: $E6 $F0
    add  $21                                      ; $3075: $C6 $21
    ld   l, a                                     ; $3077: $6F
    ld   e, a                                     ; $3078: $5F
    jr   .jr_000_3062                              ; $3079: $18 $E7

.jr_000_307B:
    ld   a, $00                                   ; $307B: $3E $00
    ldh  [$FF9C], a                               ; $307D: $E0 $9C
    ld   hl, $9861                                ; $307F: $21 $61 $98
    ld   de, $C861                                ; $3082: $11 $61 $C8
    ld   c, $05                                   ; $3085: $0E $05

.jr_000_3087:
    ld   b, $06                                   ; $3087: $06 $06

.jr_000_3089:
    ld   a, [de]                                  ; $3089: $1A
    cp   $00                                      ; $308A: $FE $00
    jr   nz, .jr_000_3090                          ; $308C: $20 $02

    ld   a, $24                                   ; $308E: $3E $24

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

:   ld   hl, $9901                                ; $30A1: $21 $01 $99
    ld   de, $C901                                ; $30A4: $11 $01 $C9
    ld   c, $02                                   ; $30A7: $0E $02

:   ld   b, $06                                   ; $30A9: $06 $06

:   ld   a, [de]                                  ; $30AB: $1A
    cp   $00                                      ; $30AC: $FE $00
    jr   nz, :+                                   ; $30AE: $20 $02

    ld   a, " "                                   ; $30B0: $3E $24

:   ld   [hl+], a                                 ; $30B2: $22
    inc  de                                       ; $30B3: $13
    dec  b                                        ; $30B4: $05
    jr   nz, :--                                  ; $30B5: $20 $F4

    dec  c                                        ; $30B7: $0D
    ret  z                                        ; $30B8: $C8

    ld   a, l                                     ; $30B9: $7D
    and  $F0                                      ; $30BA: $E6 $F0
    add  $21                                      ; $30BC: $C6 $21
    ld   l, a                                     ; $30BE: $6F
    ld   e, a                                     ; $30BF: $5F
    jr   :---                                     ; $30C0: $18 $E7

DrawFromWRAM:
:   ld   a, [de]                                  ; $30C2: $1A
    cp   $00                                      ; $30C3: $FE $00
    jr   nz, :+                                   ; $30C5: $20 $02

    ld   a, " "                                   ; $30C7: $3E $24

:   ld   [hl+], a                                 ; $30C9: $22
    inc  de                                       ; $30CA: $13
    dec  b                                        ; $30CB: $05
    jr   nz, :--                                  ; $30CC: $20 $F4

    ret                                           ; $30CE: $C9


Call_000_30CF:
    ldh  [$FFD4], a                               ; $30CF: $E0 $D4
    ld   a, $00                                   ; $30D1: $3E $00
    ld   [hl], a                                  ; $30D3: $77
    ld   hl, $FFD1                                ; $30D4: $21 $D1 $FF
    inc  [hl]                                     ; $30D7: $34
    inc  hl                                       ; $30D8: $23
    inc  [hl]                                     ; $30D9: $34

Call_000_30DA:
    ld   hl, hBlocks                              ; $30DA: $21 $C9 $FF
    cp   [hl]                                     ; $30DD: $BE
    jr   nz, jr_000_30E3                          ; $30DE: $20 $03

    ld   a, $09                                   ; $30E0: $3E $09
    ld   [hl+], a                                 ; $30E2: $22

jr_000_30E3:
    dec  [hl]                                     ; $30E3: $35
    ret                                           ; $30E4: $C9


Call_000_30E5:
    ld   bc, $0004                                ; $30E5: $01 $04 $00
    ld   a, $00                                   ; $30E8: $3E $00
    ld   [hl], a                                  ; $30EA: $77
    add  hl, bc                                   ; $30EB: $09
    ld   [hl], a                                  ; $30EC: $77
    add  hl, bc                                   ; $30ED: $09
    ld   [hl], a                                  ; $30EE: $77
    add  hl, bc                                   ; $30EF: $09
    ld   [hl], a                                  ; $30F0: $77
    ret                                           ; $30F1: $C9


Call_000_30F2:
    ld   hl, $FFC2                                ; $30F2: $21 $C2 $FF
    inc  [hl]                                     ; $30F5: $34
    ld   hl, hStage                               ; $30F6: $21 $C6 $FF

.incrementStageNumber:
    inc  [hl]                                     ; $30F9: $34
    ld   a, [hl]                                  ; $30FA: $7E
    cp   $0A                                      ; $30FB: $FE $0A
    jr   nz, .noCarry                             ; $30FD: $20 $05

    ld   a, $00                                   ; $30FF: $3E $00
    ld   [hl+], a                                 ; $3101: $22
    jr   .incrementStageNumber                    ; $3102: $18 $F5

.noCarry:
    ld   hl, $FFDC                                ; $3104: $21 $DC $FF
    inc  [hl]                                     ; $3107: $34
    ld   a, [hl]                                  ; $3108: $7E
    cp   $03                                      ; $3109: $FE $03
    jr   nz, jr_000_3110                          ; $310B: $20 $03

    ld   a, $00                                   ; $310D: $3E $00
    ld   [hl], a                                  ; $310F: $77

jr_000_3110:
    ld   a, $00                                   ; $3110: $3E $00
    ldh  [$FF9F], a                               ; $3112: $E0 $9F
    ldh  [$FFA0], a                               ; $3114: $E0 $A0
    ldh  [$FFAC], a                               ; $3116: $E0 $AC
    ld   a, $02                                   ; $3118: $3E $02
    ldh  [hSBlocksRemaining], a                   ; $311A: $E0 $C5
    ld   hl, _RAM                                 ; $311C: $21 $00 $C0
    ld   bc, $00A0                                ; $311F: $01 $A0 $00
    jp   MemClear                                 ; $3122: $C3 $C1 $2C


SerialTransferHandler::
    ldh  a, [rSC]                                 ; $3125: $F0 $02
    bit  7, a                                     ; $3127: $CB $7F
    jr   z, jr_000_312F                           ; $3129: $28 $04

    and  $7F                                      ; $312B: $E6 $7F
    ldh  [rSC], a                                 ; $312D: $E0 $02

jr_000_312F:
    bit  0, a                                     ; $312F: $CB $47
    jr   z, jr_000_313D                           ; $3131: $28 $0A

    and  $FE                                      ; $3133: $E6 $FE
    ldh  [rSC], a                                 ; $3135: $E0 $02
    ld   a, $20                                   ; $3137: $3E $20

jr_000_3139:
    nop                                           ; $3139: $00
    dec  a                                        ; $313A: $3D
    jr   nz, jr_000_3139                          ; $313B: $20 $FC

jr_000_313D:
    ld   a, $00                                   ; $313D: $3E $00
    ldh  [rSB], a                                 ; $313F: $E0 $01
    ldh  a, [rSC]                                 ; $3141: $F0 $02
    or   $80                                      ; $3143: $F6 $80
    ldh  [rSC], a                                 ; $3145: $E0 $02
    ret                                           ; $3147: $C9


Call_000_3148:
    ld   c, a                                     ; $3148: $4F
    ld   a, $FF                                   ; $3149: $3E $FF

jr_000_314B:
    nop                                           ; $314B: $00
    nop                                           ; $314C: $00
    dec  a                                        ; $314D: $3D
    jr   nz, jr_000_314B                          ; $314E: $20 $FB

    ldh  a, [rSC]                                 ; $3150: $F0 $02
    bit  7, a                                     ; $3152: $CB $7F
    jr   z, jr_000_315A                           ; $3154: $28 $04

    and  $7F                                      ; $3156: $E6 $7F
    ldh  [rSC], a                                 ; $3158: $E0 $02

jr_000_315A:
    or   $01                                      ; $315A: $F6 $01
    ldh  [rSC], a                                 ; $315C: $E0 $02
    ld   a, $40                                   ; $315E: $3E $40

jr_000_3160:
    nop                                           ; $3160: $00
    dec  a                                        ; $3161: $3D
    jr   nz, jr_000_3160                          ; $3162: $20 $FC

    ld   a, c                                     ; $3164: $79
    ldh  [rSB], a                                 ; $3165: $E0 $01
    ldh  a, [rSC]                                 ; $3167: $F0 $02
    or   $80                                      ; $3169: $F6 $80
    ldh  [rSC], a                                 ; $316B: $E0 $02

jr_000_316D:
    ldh  a, [$FFA8]                               ; $316D: $F0 $A8
    bit  0, a                                     ; $316F: $CB $47
    jr   z, jr_000_316D                           ; $3171: $28 $FA

    and  $FE                                      ; $3173: $E6 $FE
    ldh  [$FFA8], a                               ; $3175: $E0 $A8
    ret                                           ; $3177: $C9


Call_000_3178:
    ldh  a, [rSC]                                 ; $3178: $F0 $02
    bit  7, a                                     ; $317A: $CB $7F
    jr   z, jr_000_3182                           ; $317C: $28 $04

    and  $7F                                      ; $317E: $E6 $7F
    ldh  [rSC], a                                 ; $3180: $E0 $02

jr_000_3182:
    bit  0, a                                     ; $3182: $CB $47
    jr   z, jr_000_3190                           ; $3184: $28 $0A

    and  $FE                                      ; $3186: $E6 $FE
    ldh  [rSC], a                                 ; $3188: $E0 $02
    ld   a, $20                                   ; $318A: $3E $20

jr_000_318C:
    nop                                           ; $318C: $00
    dec  a                                        ; $318D: $3D
    jr   nz, jr_000_318C                          ; $318E: $20 $FC

jr_000_3190:
    ld   a, $00                                   ; $3190: $3E $00
    ldh  [rSB], a                                 ; $3192: $E0 $01
    ldh  a, [rSC]                                 ; $3194: $F0 $02
    or   $80                                      ; $3196: $F6 $80
    ldh  [rSC], a                                 ; $3198: $E0 $02
    jr   jr_000_316D                              ; $319A: $18 $D1

Call_000_319C:
    ld   hl, $FF99                                ; $319C: $21 $99 $FF
    inc  [hl]                                     ; $319F: $34
    call Call_000_3312                            ; $31A0: $CD $12 $33
    ld   a, $01                                   ; $31A3: $3E $01
    ldh  [$FFA0], a                               ; $31A5: $E0 $A0
    ld   a, [$C006]                               ; $31A7: $FA $06 $C0
    ld   [$C00A], a                               ; $31AA: $EA $0A $C0
    ld   hl, _RAM                                 ; $31AD: $21 $00 $C0
    ld   a, $80                                   ; $31B0: $3E $80
    ld   [hl+], a                                 ; $31B2: $22
    ld   a, $68                                   ; $31B3: $3E $68
    ld   [hl+], a                                 ; $31B5: $22
    ld   a, $9A                                   ; $31B6: $3E $9A
    ld   [hl+], a                                 ; $31B8: $22
    ld   a, $00                                   ; $31B9: $3E $00
    ld   [hl+], a                                 ; $31BB: $22
    ld   [hl+], a                                 ; $31BC: $22
    ld   [$C008], a                               ; $31BD: $EA $08 $C0
    ld   hl, $C00C                                ; $31C0: $21 $0C $C0
    ld   a, $80                                   ; $31C3: $3E $80
    ld   [hl+], a                                 ; $31C5: $22
    ld   a, $60                                   ; $31C6: $3E $60
    ld   [hl+], a                                 ; $31C8: $22
    ld   a, $99                                   ; $31C9: $3E $99
    ld   [hl+], a                                 ; $31CB: $22
    ld   a, $30                                   ; $31CC: $3E $30
    ldh  [hCounter], a                            ; $31CE: $E0 $B0
    ld   a, $00                                   ; $31D0: $3E $00
    ldh  [hCounter+1], a                          ; $31D2: $E0 $B1
    ld   hl, UnknownMusic5FC5                     ; $31D4: $21 $C5 $5F
    call Call_000_3309                            ; $31D7: $CD $09 $33
    jr   jr_000_320D                              ; $31DA: $18 $31

Call_000_31DC:
    ld   hl, $FF9A                                ; $31DC: $21 $9A $FF
    inc  [hl]                                     ; $31DF: $34
    ld   a, $02                                   ; $31E0: $3E $02
    ldh  [$FFA0], a                               ; $31E2: $E0 $A0
    ld   a, [$C006]                               ; $31E4: $FA $06 $C0
    ld   [$C00A], a                               ; $31E7: $EA $0A $C0
    ld   hl, _RAM                                 ; $31EA: $21 $00 $C0
    ld   a, $80                                   ; $31ED: $3E $80
    ld   [hl+], a                                 ; $31EF: $22
    ld   a, $68                                   ; $31F0: $3E $68
    ld   [hl+], a                                 ; $31F2: $22
    ld   a, $8C                                   ; $31F3: $3E $8C
    ld   [hl+], a                                 ; $31F5: $22
    ld   a, $00                                   ; $31F6: $3E $00
    ld   [hl+], a                                 ; $31F8: $22
    ld   [$C008], a                               ; $31F9: $EA $08 $C0
    ld   a, $80                                   ; $31FC: $3E $80
    ld   [hl+], a                                 ; $31FE: $22
    ld   a, $60                                   ; $31FF: $3E $60
    ld   [hl+], a                                 ; $3201: $22
    ld   a, $8B                                   ; $3202: $3E $8B
    ld   [hl+], a                                 ; $3204: $22
    ld   a, $50                                   ; $3205: $3E $50
    ldh  [hCounter], a                            ; $3207: $E0 $B0
    ld   a, $00                                   ; $3209: $3E $00
    ldh  [hCounter+1], a                          ; $320B: $E0 $B1

jr_000_320D:
    ld   a, $00                                   ; $320D: $3E $00
    ldh  [$FFB2], a                               ; $320F: $E0 $B2
    ld   a, $18                                   ; $3211: $3E $18
    ldh  [$FFB3], a                               ; $3213: $E0 $B3
    ld   a, $00                                   ; $3215: $3E $00
    ldh  [$FF9F], a                               ; $3217: $E0 $9F
    ld   a, $04                                   ; $3219: $3E $04
    ldh  [$FF9D], a                               ; $321B: $E0 $9D
    ret                                           ; $321D: $C9


Call_000_321E:
Jump_000_321E:
    ld   hl, hBlocksInitial+1                     ; $321E: $21 $C1 $FF
    ld   a, [hl-]                                 ; $3221: $3A
    cp   $02                                      ; $3222: $FE $02
    jr   nc, jr_000_323F                          ; $3224: $30 $19

    cp   $01                                      ; $3226: $FE $01
    jr   c, jr_000_322F                           ; $3228: $38 $05

    ld   a, [hl]                                  ; $322A: $7E
    cp   $05                                      ; $322B: $FE $05
    jr   nc, jr_000_323F                          ; $322D: $30 $10

jr_000_322F:
    ldh  a, [$FFA7]                               ; $322F: $F0 $A7
    bit  4, a                                     ; $3231: $CB $67
    ret  nz                                       ; $3233: $C0

    or   $30                                      ; $3234: $F6 $30
    ldh  [$FFA7], a                               ; $3236: $E0 $A7
    ld   a, $A0                                   ; $3238: $3E $A0
    ldh  [$FFBC], a                               ; $323A: $E0 $BC
    jp   Jump_000_32EB                            ; $323C: $C3 $EB $32


jr_000_323F:
    ldh  a, [$FFA7]                               ; $323F: $F0 $A7
    bit  4, a                                     ; $3241: $CB $67
    ret  z                                        ; $3243: $C8

    and  $CF                                      ; $3244: $E6 $CF
    ldh  [$FFA7], a                               ; $3246: $E0 $A7
    ld   a, $00                                   ; $3248: $3E $00
    ldh  [$FFBC], a                               ; $324A: $E0 $BC
    jr   jr_000_3270                              ; $324C: $18 $22

Call_000_324E:
    ld   hl, $FFA7                                ; $324E: $21 $A7 $FF
    ldh  a, [hSBlocksRemaining]                   ; $3251: $F0 $C5
    cp   $00                                      ; $3253: $FE $00
    jr   nz, jr_000_3265                          ; $3255: $20 $0E

    bit  3, [hl]                                  ; $3257: $CB $5E
    ret  nz                                       ; $3259: $C0

    set  3, [hl]                                  ; $325A: $CB $DE
    set  6, [hl]                                  ; $325C: $CB $F6
    ld   a, $A0                                   ; $325E: $3E $A0
    ldh  [$FFBD], a                               ; $3260: $E0 $BD
    jp   Jump_000_32EB                            ; $3262: $C3 $EB $32


jr_000_3265:
    bit  3, [hl]                                  ; $3265: $CB $5E
    ret  z                                        ; $3267: $C8

    res  3, [hl]                                  ; $3268: $CB $9E
    res  6, [hl]                                  ; $326A: $CB $B6
    ld   a, $00                                   ; $326C: $3E $00
    ldh  [$FFBD], a                               ; $326E: $E0 $BD

jr_000_3270:
    ldh  a, [$FFA9]                               ; $3270: $F0 $A9
    bit  0, a                                     ; $3272: $CB $47
    ret  z                                        ; $3274: $C8

    jr   jr_000_32C1                              ; $3275: $18 $4A

Call_000_3277:
    ld   hl, $C841                                ; $3277: $21 $41 $C8
    push hl                                       ; $327A: $E5
    ld   bc, $0020                                ; $327B: $01 $20 $00

jr_000_327E:
    ld   a, [hl]                                  ; $327E: $7E
    cp   $80                                      ; $327F: $FE $80
    jr   z, jr_000_32B2                           ; $3281: $28 $2F

    cp   $87                                      ; $3283: $FE $87
    jr   z, jr_000_32B2                           ; $3285: $28 $2B

    cp   $81                                      ; $3287: $FE $81
    jr   z, jr_000_32B5                           ; $3289: $28 $2A

    cp   $00                                      ; $328B: $FE $00
    jr   z, jr_000_3297                           ; $328D: $28 $08

jr_000_328F:
    pop  hl                                       ; $328F: $E1
    ld   hl, $FFA8                                ; $3290: $21 $A8 $FF
    set  5, [hl]                                  ; $3293: $CB $EE
    jr   jr_000_32EB                              ; $3295: $18 $54

jr_000_3297:
    add  hl, bc                                   ; $3297: $09
    ld   a, [hl]                                  ; $3298: $7E
    cp   $00                                      ; $3299: $FE $00
    jr   z, jr_000_3297                           ; $329B: $28 $FA

    cp   $81                                      ; $329D: $FE $81
    jr   z, jr_000_32B5                           ; $329F: $28 $14

jr_000_32A1:
    pop  hl                                       ; $32A1: $E1
    inc  hl                                       ; $32A2: $23
    ld   a, l                                     ; $32A3: $7D
    cp   $47                                      ; $32A4: $FE $47
    jr   nz, jr_000_32AF                          ; $32A6: $20 $07

    ld   hl, $FFA8                                ; $32A8: $21 $A8 $FF
    res  5, [hl]                                  ; $32AB: $CB $AE
    jr   jr_000_3270                              ; $32AD: $18 $C1

jr_000_32AF:
    push hl                                       ; $32AF: $E5
    jr   jr_000_327E                              ; $32B0: $18 $CC

jr_000_32B2:
    add  hl, bc                                   ; $32B2: $09
    jr   jr_000_327E                              ; $32B3: $18 $C9

jr_000_32B5:
    add  hl, bc                                   ; $32B5: $09
    ld   a, [hl]                                  ; $32B6: $7E
    cp   $81                                      ; $32B7: $FE $81
    jr   z, jr_000_32B5                           ; $32B9: $28 $FA

    cp   $00                                      ; $32BB: $FE $00
    jr   z, jr_000_32A1                           ; $32BD: $28 $E2

    jr   jr_000_328F                              ; $32BF: $18 $CE

Call_000_32C1:
jr_000_32C1:
    ldh  a, [$FFA8]                               ; $32C1: $F0 $A8
    bit  5, a                                     ; $32C3: $CB $6F
    ret  nz                                       ; $32C5: $C0

    ld   hl, $FFA7                                ; $32C6: $21 $A7 $FF
    bit  3, [hl]                                  ; $32C9: $CB $5E
    ret  nz                                       ; $32CB: $C0

    bit  4, [hl]                                  ; $32CC: $CB $66
    ret  nz                                       ; $32CE: $C0

    ld   hl, $FFA9                                ; $32CF: $21 $A9 $FF
    res  0, [hl]                                  ; $32D2: $CB $86
    ldh  a, [$FFDC]                               ; $32D4: $F0 $DC
    cp   $01                                      ; $32D6: $FE $01
    jr   c, jr_000_32E6                           ; $32D8: $38 $0C

    jr   z, jr_000_32E1                           ; $32DA: $28 $05

    ld   hl, UnknownMusic5D66                     ; $32DC: $21 $66 $5D
    jr   jr_000_3309                              ; $32DF: $18 $28

jr_000_32E1:
    ld   hl, UnknownMusic59DC                     ; $32E1: $21 $DC $59
    jr   jr_000_3309                              ; $32E4: $18 $23

jr_000_32E6:
    ld   hl, UnknownMusic55A4                     ; $32E6: $21 $A4 $55
    jr   jr_000_3309                              ; $32E9: $18 $1E

Call_000_32EB:
Jump_000_32EB:
jr_000_32EB:
    ldh  a, [$FFA9]                               ; $32EB: $F0 $A9
    bit  0, a                                     ; $32ED: $CB $47
    ret  nz                                       ; $32EF: $C0

    or   $01                                      ; $32F0: $F6 $01
    ldh  [$FFA9], a                               ; $32F2: $E0 $A9
    ldh  a, [$FFDC]                               ; $32F4: $F0 $DC
    cp   $01                                      ; $32F6: $FE $01
    jr   c, jr_000_3306                           ; $32F8: $38 $0C

    jr   z, jr_000_3301                           ; $32FA: $28 $05

    ld   hl, UnknownMusic5D5F                     ; $32FC: $21 $5F $5D
    jr   jr_000_3309                              ; $32FF: $18 $08

jr_000_3301:
    ld   hl, UnknownMusic59D5                     ; $3301: $21 $D5 $59
    jr   jr_000_3309                              ; $3304: $18 $03

jr_000_3306:
    ld   hl, UnknownMusic559D                     ; $3306: $21 $9D $55

Call_000_3309:
jr_000_3309:
    di                                            ; $3309: $F3
    ld   a, h                                     ; $330A: $7C
    ldh  [hMusic+1], a                            ; $330B: $E0 $DE
    ld   a, l                                     ; $330D: $7D
    ldh  [hMusic], a                              ; $330E: $E0 $DD
    ei                                            ; $3310: $FB
    ret                                           ; $3311: $C9


Call_000_3312:
    di                                            ; $3312: $F3
    ld   hl, UnknownMusic668C                     ; $3313: $21 $8C $66
    ld   a, h                                     ; $3316: $7C
    ldh  [hMusic+1], a                            ; $3317: $E0 $DE
    ld   a, l                                     ; $3319: $7D
    ldh  [hMusic], a                              ; $331A: $E0 $DD
    ld   a, $00                                   ; $331C: $3E $00
    ldh  [hMusic+2], a                            ; $331E: $E0 $DF
    ei                                            ; $3320: $FB

jr_000_3321:
    ldh  a, [hMusic+1]                            ; $3321: $F0 $DE
    cp   $00                                      ; $3323: $FE $00
    jr   nz, jr_000_3321                          ; $3325: $20 $FA

    ldh  a, [hMusic]                              ; $3327: $F0 $DD
    cp   $00                                      ; $3329: $FE $00
    jr   nz, jr_000_3321                          ; $332B: $20 $F4

    ret                                           ; $332D: $C9


Call_000_332E:
    di                                            ; $332E: $F3
    ld   a, h                                     ; $332F: $7C
    ldh  [$FFE2], a                               ; $3330: $E0 $E2
    ld   a, l                                     ; $3332: $7D
    ldh  [$FFE1], a                               ; $3333: $E0 $E1
    ld   a, $00                                   ; $3335: $3E $00
    ldh  [$FFE3], a                               ; $3337: $E0 $E3
    ldh  [$FFE4], a                               ; $3339: $E0 $E4
    ei                                            ; $333B: $FB
    ret                                           ; $333C: $C9

;;;;;;;;;;;;;;;
; Draw commands
;;;;;;;;;;;;;;;
;
; These are commands for drawing to the screen. Each command is structured like this:
; - Two bytes for the memory address to draw to (big-endian)
; - One byte for length, method and direction:
;   - bit 7:    1 for vertical drawing, 0 for horizontal
;   - bit 6:    1 to repeat one tile, 0 to draw a series of tiles
;   - bits 5-0: Length (number of tiles to draw)
;
; Multiple consecutive draw commands will be executed one after another, until
; terminated by $00.

; A draw command set that draws the title screen
TitleScreenDrawCommands::
    ; Blocks above logo
    DB   $98, $00, $54, $80

    DB   $98, $20, $54, $80

    ; Logo
    DB   $98, $40, $14, $80, $30, $31, $32, $33, $24, $24, $34, $24, $35, $36, $37, $38
    DB   $39, $3A, $64, $24, $65, $24, $80

    DB   $98, $60, $14, $80, $3B, $3C, $3D, $3E, $24, $24, $3F, $24, $40, $41, $42, $43
    DB   $44, $3E, $24, $45, $66, $24, $80
    
    DB   $98, $80, $14, $80, $46, $47, $24, $48, $49, $24, $4A, $24, $4B, $4C, $4D, $4E
    DB   $4F, $48, $49, $50, $51, $24, $80
    
    DB   $98, $A0, $14, $80, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D
    DB   $5E, $5F, $60, $61, $62, $63, $80
    
    ; Blocks under logo
    DB   $98, $C0, $54, $80
    
    DB   $98, $E0, $54, $80
    
    DB   $99, $00, $54, $80

    ; Text before high score
    DB   $99, $45, $04, "TOP-"

    ; Menu options
    DB   $99, $82, $11, "1PLAYER   2PLAYER"

    ; Copyright
IF "{REGION}" == "JP"
    DB   $99, $E0, $14, "c TAITO CORP. 1990  "
    DB   $9A, $20, $14, "LICENSED BY NINTENDO"
ELIF "{REGION}" == "US"
    DB   $99, $E4, $0C, "c TAITO 1990"
    DB   $9A, $20, $14, "LICENSED BY NINTENDO"
ENDC

    ; Command terminator
    DB   $00

; A draw command set that draws the play area
PlayAreaDrawCommand::
    DB   $98, $00, $54, $80
    
    DB   $98, $20, $06, $80, "SCORE"
    
    DB   $98, $2E, $46, $80
    
    DB   $98, $40, $54, $80
    
    DB   $98, $60, $CC, $80
    
    DB   $98, $6D, $CC, $80
    
    DB   $98, $73, $CC, $80

    DB   $98, $6E, $05, "CLEAR"
    
    DB   $98, $AE, $45, $80
    
    DB   $98, $CE, $05, "TIME "
    
    DB   $99, $0E, $45, $80
    
    DB   $99, $2E, $05, "BLOCK"

    DB   $99, $6E, $45, $80
    
    DB   $99, $8E, $05, "STAGE"
    
    DB   $99, $CF, $02, $82, "="
    
    DB   $99, $E0, $54, $80
    
    DB   $9A, $00, $54, $80
    
    DB   $9A, $20, $54, $80
    
    ; Command terminator
    DB   $00

StageNumberDrawCommand::
    DB   $98, $C5, $09, "STAGE    ", $00

GameOverDrawCommand::
    DB   $98, $C5, $09, "GAME OVER", $00

PlayArea2PlayerDrawCommand::
    DB   $98, $00, $54, $80
    
    DB   $98, $20, $54, $80
    
    DB   $98, $40, $54, $80
    
    DB   $98, $60, $CC, $80

    DB   $98, $6D, $CC, $80
    
    DB   $98, $73, $CC, $80
    
    DB   $98, $6E, $05, "CLEAR"

    DB   $98, $AE, $45, $80
    
    DB   $98, $CE, $05, "ENEMY"
    
    DB   $99, $0E, $45, $80

    DB   $99, $2E, $05, "BLOCK"
    
    DB   $99, $6E, $45, $80
    
    DB   $99, $8E, $05, "ROUND"
    
    DB   $99, $CF, $02, $82, "="
    
    DB   $99, $E0, $54, $80
    
    DB   $9A, $00, $54, $80

    DB   $9A, $20, $54, $80
    
    DB   $00

ContinueScreenDrawCommand::
    DB   $98, $C5, $09, "GAME OVER"
    
    DB   $99, $07, $08, "CONTINUE"
    
    DB   $99, $27, $03, "END"
    
    DB   $99, $6A, $06, "CREDIT"
    
    DB   $00

SetsDrawCommand::
    DB   $98, $C5, $0B, "3 SET MATCH"
    
    DB   $99, $05, $0B, "5 SET MATCH"
    
    DB   $99, $45, $0B, "7 SET MATCH"
    
    DB   $00

SetDrawCommand::
    DB   $98, $E7, $05, "SET  ", $00

BigBlockFrameDrawCommand::
    DB   $98, $00, $14, $9C, $9D, $9C, $9D, $9C, $9D, $9C, $9D, $9C, $9D, $9C, $9D, $9C
    DB   $9D, $9C, $9D, $9C, $9D, $9C, $9D, $98, $20, $14, $9E, $9F, $9E, $9F, $9E, $9F
    DB   $9E, $9F, $9E, $9F, $9E, $9F, $9E, $9F, $9E, $9F, $9E, $9F, $9E, $9F, $98, $40
    DB   $02, $9C, $9D, $98, $52, $02, $9C, $9D, $98, $60, $02, $9E, $9F, $98, $72, $02
    DB   $9E, $9F, $98, $80, $02, $9C, $9D, $98, $92, $02, $9C, $9D, $98, $A0, $02, $9E
    DB   $9F, $98, $B2, $02, $9E, $9F, $98, $C0, $02, $9C, $9D, $98, $D2, $02, $9C, $9D
    DB   $98, $E0, $02, $9E, $9F, $98, $F2, $02, $9E, $9F, $99, $00, $02, $9C, $9D, $99
    DB   $12, $02, $9C, $9D, $99, $20, $02, $9E, $9F, $99, $32, $02, $9E, $9F, $99, $40
    DB   $02, $9C, $9D, $99, $52, $02, $9C, $9D, $99, $60, $02, $9E, $9F, $99, $72, $02
    DB   $9E, $9F, $99, $80, $14, $9C, $9D, $9C, $9D, $9C, $9D, $9C, $9D, $9C, $9D, $9C
    DB   $9D, $9C, $9D, $9C, $9D, $9C, $9D, $9C, $9D, $99, $A0, $14, $9E, $9F, $9E, $9F
    DB   $9E, $9F, $9E, $9F, $9E, $9F, $9E, $9F, $9E, $9F, $9E, $9F, $9E, $9F, $9E, $9F
    DB   $99, $C0, $02, $9C, $9D, $99, $D2, $02, $9C, $9D, $99, $E0, $02, $9E, $9F, $99
    DB   $F2, $02, $9E, $9F, $9A, $00, $14, $9C, $9D, $9C, $9D, $9C, $9D, $9C, $9D, $9C
    DB   $9D, $9C, $9D, $9C, $9D, $9C, $9D, $9C, $9D, $9C, $9D, $9A, $20, $14, $9E, $9F
    DB   $9E, $9F, $9E, $9F, $9E, $9F, $9E, $9F, $9E, $9F, $9E, $9F, $9E, $9F, $9E, $9F
    DB   $9E, $9F, $00

YouWinBigTextDrawCommand::
    DB   $98, $65, $09, $A8, $AA, $AC, $24, $AE, $B0, $B2, $BA, $BA
    DB   $98, $85, $09, $A9, $AB, $AD, $24, $AF, $B1, $B3, $BB, $BB
    DB   $00

YouLoseBigTextDrawCommand::
    DB   $98, $65, $0A, $A8, $AA, $AC, $24, $B4, $AA, $B6, $B8, $BA, $BA
    DB   $98, $85, $0A, $A9, $AB, $AD, $24, $B5, $AB, $B7, $B9, $BB, $BB
    DB   $00

UnknownDrawCommand8::
    DB   $99, $80, $54, $80
    DB   $99, $A0, $54, $80
    DB   $99, $C0, $54, $80
    DB   $99, $E0, $54, $80
    DB   $9A, $00, $54, $80
    DB   $9A, $20, $54, $80
    DB   $00

; A look-up table with pointers to sets of draw commands that draw the
; physical layout of each stage (ie. blocks in the top left corner and pipes).
; There are only 32 unique stage layouts, and, perhaps more interestingly,
; there are only 48 pointers here, even though the game (according to the
; manual) should have 50 stages.
StageDrawCommandsTable::
    DW   Stage1DrawCommand
    DW   Stage2DrawCommand
    DW   Stage3DrawCommand
    DW   Stage4DrawCommand
    DW   Stage5DrawCommand
    DW   Stage6DrawCommand
    DW   Stage7DrawCommand
    DW   Stage8DrawCommand
    DW   Stage9DrawCommand
    DW   Stage10DrawCommand
    DW   Stage11DrawCommand
    DW   Stage12DrawCommand
    DW   Stage13DrawCommand
    DW   Stage14DrawCommand
    DW   Stage15DrawCommand
    DW   Stage16DrawCommand
    DW   Stage17DrawCommand
    DW   Stage18DrawCommand
    DW   Stage19DrawCommand
    DW   Stage20DrawCommand
    DW   Stage21DrawCommand
    DW   Stage22DrawCommand
    DW   Stage23DrawCommand
    DW   Stage24DrawCommand
    DW   Stage25DrawCommand
    DW   Stage26DrawCommand
    DW   Stage27DrawCommand
    DW   Stage28DrawCommand
    DW   Stage29DrawCommand
    DW   Stage30DrawCommand
    DW   Stage31DrawCommand
    DW   Stage32DrawCommand
.36A9
    DW   Stage1DrawCommand
    DW   Stage2DrawCommand
    DW   Stage3DrawCommand
    DW   Stage4DrawCommand
    DW   Stage5DrawCommand
    DW   Stage8DrawCommand
    DW   Stage9DrawCommand
    DW   Stage11DrawCommand
    DW   Stage13DrawCommand
    DW   Stage15DrawCommand
    DW   Stage17DrawCommand
    DW   Stage19DrawCommand
    DW   Stage20DrawCommand
    DW   Stage24DrawCommand
    DW   Stage27DrawCommand
    DW   Stage28DrawCommand

Stage1DrawCommand::
    DB   $98, $61, $44, $87, $98, $81, $43, $87, $98, $A1, $42, $87, $98, $C1, $01, $87
    DB   $00

Stage2DrawCommand::
    DB   $98, $61, $44, $87, $98, $81, $42, $87, $98, $A1, $C2, $87, $00

Stage3DrawCommand::
    DB   $98, $61, $44, $87, $98, $81, $43, $87, $98, $A1, $42, $87, $00

Stage4DrawCommand::
    DB   $98, $61, $01, $87, $98, $84, $01, $81, $98, $C2, $01, $81, $00

Stage5DrawCommand::
    DB   $98, $61, $44, $87, $98, $81, $43, $87, $98, $A1, $42, $87, $98, $C1, $01, $87
    DB   $99, $A6, $01, $81, $00

Stage6DrawCommand::
    DB   $98, $61, $86, $87, $87, $87, $87, $81, $81, $98, $62, $C3, $87, $98, $63, $C2
    DB   $87, $00

Stage7DrawCommand::
    DB   $98, $61, $44, $87, $98, $81, $43, $87, $98, $A1, $C2, $87, $99, $02, $01, $81
    DB   $99, $46, $01, $81, $99, $87, $01, $81, $00

Stage8DrawCommand::
    DB   $98, $61, $44, $87, $98, $81, $43, $87, $98, $A1, $42, $87, $98, $C1, $01, $87
    DB   $98, $E5, $01, $81, $00

Stage9DrawCommand::
    DB   $98, $61, $01, $81, $98, $82, $01, $81, $98, $A3, $01, $81, $98, $C4, $01, $81
    DB   $00

Stage10DrawCommand::
    DB   $98, $61, $C4, $87, $98, $62, $C4, $87, $98, $63, $C4, $87, $98, $64, $C3, $87
    DB   $99, $01, $01, $81, $00

Stage11DrawCommand::
    DB   $98, $61, $44, $87, $98, $81, $43, $87, $98, $A1, $42, $87, $00

Stage12DrawCommand::
    DB   $98, $61, $43, $87, $98, $66, $01, $81, $98, $81, $43, $87, $98, $A1, $43, $87
    DB   $98, $A6, $01, $81, $98, $C1, $42, $87, $99, $01, $01, $81, $99, $46, $01, $81
    DB   $99, $A6, $01, $81, $00

Stage13DrawCommand::
    DB   $98, $81, $81, $81, $98, $A2, $C2, $81, $98, $63, $81, $81, $98, $A4, $C2, $81
    DB   $00

Stage14DrawCommand::
    DB   $98, $61, $43, $87, $98, $81, $42, $87, $99, $05, $01, $81, $00

Stage15DrawCommand::
    DB   $98, $61, $44, $87, $98, $81, $43, $87, $98, $A1, $43, $87, $98, $C1, $43, $87
    DB   $98, $E5, $01, $81, $99, $A7, $01, $81, $00

Stage16DrawCommand::
    DB   $98, $C3, $01, $81, $98, $E2, $01, $81, $98, $E4, $01, $81, $99, $01, $01, $81
    DB   $99, $05, $01, $81, $00

Stage17DrawCommand::
    DB   $98, $61, $43, $87, $98, $81, $43, $87, $98, $A1, $43, $87, $00

Stage18DrawCommand::
    DB   $98, $61, $44, $87, $98, $81, $42, $87, $98, $A1, $01, $87, $98, $C1, $01, $87
    DB   $98, $C3, $01, $81, $99, $46, $01, $81, $99, $86, $01, $81, $99, $C6, $01, $81
    DB   $00

Stage19DrawCommand::
    DB   $98, $A1, $01, $81, $00

Stage20DrawCommand::
    DB   $98, $61, $44, $87, $98, $81, $44, $87, $98, $A1, $44, $87, $98, $C1, $43, $87
    DB   $99, $A6, $01, $81, $00

Stage21DrawCommand::
    DB   $98, $65, $01, $81, $98, $83, $01, $81, $98, $C4, $01, $81, $99, $02, $01, $81
    DB   $99, $56, $C2, $81, $00

Stage22DrawCommand::
    DB   $98, $61, $44, $87, $98, $81, $43, $87, $98, $A1, $42, $87, $98, $C1, $01, $87
    DB   $99, $66, $C3, $81, $00

Stage23DrawCommand::
    DB   $98, $C1, $C3, $81, $98, $E2, $C2, $81, $99, $46, $01, $81, $00

Stage24DrawCommand::
    DB   $98, $61, $44, $87, $98, $81, $44, $87, $98, $A1, $44, $87, $98, $C1, $05, $87
    DB   $87, $87, $87, $81, $98, $E1, $01, $81, $00

Stage25DrawCommand::
    DB   $98, $61, $44, $87, $98, $81, $44, $87, $98, $A1, $44, $87, $98, $C1, $05, $87
    DB   $87, $87, $87, $81, $99, $01, $01, $81, $00

Stage26DrawCommand::
    DB   $98, $61, $44, $87, $98, $81, $42, $87, $99, $05, $01, $81, $00

Stage27DrawCommand::
    DB   $98, $82, $01, $81, $98, $A3, $01, $81, $00

Stage28DrawCommand::
    DB   $98, $61, $43, $87, $98, $81, $43, $87, $98, $A1, $43, $87, $98, $C4, $42, $81
    DB   $98, $E4, $01, $81, $00

Stage29DrawCommand::
    DB   $98, $61, $44, $87, $98, $81, $43, $87, $98, $A1, $42, $87, $98, $C1, $01, $87
    DB   $98, $E6, $C2, $81, $99, $A7, $01, $81, $00

Stage30DrawCommand::
    DB   $98, $61, $44, $87, $98, $81, $43, $87, $98, $A1, $42, $87, $98, $C1, $01, $87
    DB   $99, $05, $01, $81, $99, $46, $C4, $81, $00

Stage31DrawCommand::
    DB   $98, $82, $01, $81, $98, $A1, $01, $81, $98, $C3, $01, $81, $98, $E4, $01, $81
    DB   $00

Stage32DrawCommand::
    DB   $98, $A4, $44, $81, $98, $C5, $01, $81, $98, $E6, $01, $81, $99, $04, $44, $81
    DB   $00

; Various text
PushText::
    DB   "    PUSH    "

StartText::
    DB   "   START    "

ToText::
    DB   "     TO     "

ContinueText::
    DB   "  CONTINUE  "

GameText::
    DB   "    GAME    "

BlankText::
    DB   "            "

PauseText::
    DB   "   PAUSE    "

ClearText::
    DB   "   CLEAR!   "

PerfectText::
    DB   " PERFECT!!  "

TimeBonusText::
    DB   " TIME BONUS "

X10Text::
    DB   "      X  10 "

ClearBonusText::
    DB   " CLEAR BONUS"

TimeUpText::
    DB   "  TIME UP!  "

SorryText::
    DB   "   SORRY    "

YouHaveText::
    DB   "  YOU HAVE  "

NoNextMoveText::
    DB   "NO NEXT MOVE"

; This is the seed for the wBlockRNG memory, from which blocks for stages are picked
BlockSeed::
    DB   $83, $86, $84, $85, $83, $86, $85, $84, $86, $83, $85, $84, $83, $85, $84, $86
    DB   $83, $85, $86, $83, $85, $84, $86, $83, $84, $86, $83, $85, $84, $86, $85, $84
    DB   $86, $83, $85, $84

; A look-up table with pointers to metadata for each stage. As in the StageDrawCommandsTable,
; there are only 32 unique stages, and only 48 stages, not 50 like the manual says. There's
; also no win condition in the game, so when it tries to load stage 49, the game becomes
; unwinnable because that stage has invalid metadata.
StageTable::
    DW   Stage1Data
    DW   Stage2Data
    DW   Stage3Data
    DW   Stage4Data
    DW   Stage5Data
    DW   Stage6Data
    DW   Stage7Data
    DW   Stage8Data
    DW   Stage9Data
    DW   Stage10Data
    DW   Stage11Data
    DW   Stage12Data
    DW   Stage13Data
    DW   Stage14Data
    DW   Stage15Data
    DW   Stage16Data
    DW   Stage17Data
    DW   Stage18Data
    DW   Stage19Data
    DW   Stage20Data
    DW   Stage21Data
    DW   Stage22Data
    DW   Stage23Data
    DW   Stage24Data
    DW   Stage25Data
    DW   Stage26Data
    DW   Stage27Data
    DW   Stage28Data
    DW   Stage29Data
    DW   Stage30Data
    DW   Stage31Data
    DW   Stage32Data
.3A4E
    DW   Stage1Data
    DW   Stage2Data
    DW   Stage3Data
    DW   Stage4Data
    DW   Stage5Data
    DW   Stage8Data
    DW   Stage9Data
    DW   Stage11Data
    DW   Stage13Data
    DW   Stage15Data
    DW   Stage17Data
    DW   Stage19Data
    DW   Stage20Data
    DW   Stage24Data
    DW   Stage27Data
    DW   Stage28Data

; Stage metadata:
; - byte 1: "Clear", ie. number of max blocks to clear the level
; - byte 2-3: "Blocks", ie. number of starting blocks (BCD, little-endian)
Stage1Data:
    DB   $09, $05, $02
Stage2Data:
    DB   $09, $05, $02
Stage3Data:
    DB   $08, $05, $02
Stage4Data:
    DB   $08, $00, $03
Stage5Data:
    DB   $08, $00, $03
Stage6Data:
    DB   $07, $00, $03
Stage7Data:
    DB   $07, $00, $03
Stage8Data:
    DB   $07, $06, $03
Stage9Data:
    DB   $08, $06, $03
Stage10Data:
    DB   $08, $06, $03
Stage11Data:
    DB   $08, $06, $03
Stage12Data:
    DB   $07, $00, $03
Stage13Data:
    DB   $07, $00, $03
Stage14Data:
    DB   $07, $06, $03
Stage15Data:
    DB   $07, $06, $03
Stage16Data:
    DB   $07, $00, $03
Stage17Data:
    DB   $07, $00, $03
Stage18Data:
    DB   $07, $00, $03
Stage19Data:
    DB   $07, $00, $03
Stage20Data:
    DB   $07, $00, $03
Stage21Data:
    DB   $07, $00, $03
Stage22Data:
    DB   $06, $00, $03
Stage23Data:
    DB   $06, $00, $03
Stage24Data:
    DB   $06, $06, $03
Stage25Data:
    DB   $06, $06, $03
Stage26Data:
    DB   $06, $06, $03
Stage27Data:
    DB   $06, $06, $03
Stage28Data:
    DB   $06, $06, $03
Stage29Data:
    DB   $06, $06, $03
Stage30Data:
    DB   $06, $05, $02
Stage31Data:
    DB   $06, $05, $02
Stage32Data:
    DB   $06, $05, $02

Tiles::
    INCBIN "gfx/Tiles.2bpp"

;;;;;;;;
; OAM
;;;;;;;;
;
; Blocks of OAM data

ArrowLeftSelectionOAM:
    DB   $70, $10, ">", $00

ArrowRightSelectionOAM:
    DB   $70, $60, ">", $00

OAMBlocks::
    DB   $70, $10, " ", $00
    DB   $70, $60, " ", $00

.52DE
    DB   $50, $38, ">", $00

.52E2
    DB   $58, $38, ">", $00

.52E6
    DB   $40, $20, ">", $00

.52EA
    DB   $50, $20, ">", $00

.52EE
    DB   $60, $20, ">", $00

MissTextOAM:
IF "{REGION}" == "JP"
    DB   $40, $30, "M", $00
    DB   $40, $38, "I", $00
    DB   $40, $40, "S", $00
    DB   $40, $48, "S", $00
    DB   $40, $50, "!", $00
ELSE
    DB   $40, $38, "M", $00
    DB   $40, $40, "I", $00
    DB   $40, $48, "S", $00
    DB   $40, $50, "S", $00
    DB   $40, $58, "!", $00
ENDC

TransitionStage10OAM::
    DB   $60, $78, $30, $00, $60, $80, $31, $00, $68, $78, $32, $00, $68, $80, $33, $00
    DB   $60, $68, $38, $00, $60, $70, $39, $00, $68, $68, $3A, $00, $68, $70, $3B, $00
    DB   $60, $28, $34, $00, $60, $30, $35, $00, $68, $28, $36, $00, $68, $30, $37, $00

UnknownOAM5336::
    DB   $68, $28, $58, $00, $68, $30, $59, $00, $68, $38, $24, $00

TransitionStage20OAM::
    DB   $60, $78, $30, $00, $60, $80, $31, $00, $68, $78, $32, $00, $68, $80, $33, $00
    DB   $60, $68, $34, $00, $60, $70, $35, $00, $68, $68, $36, $00, $68, $70, $37, $00

TransitionStage30OAM::
    DB   $60, $54, $24, $00, $60, $5C, $24, $00, $60, $64, $30, $00, $60, $6C, $31, $00
    DB   $68, $54, $24, $00, $68, $5C, $24, $00, $68, $64, $32, $00, $68, $6C, $33, $00
    DB   $40, $20, $3C, $00, $40, $28, $3D, $00, $48, $20, $3E, $00, $48, $28, $3F, $00

BigBlobTilemaps1::
    DB   $24, $24, $30, $31
    DB   $24, $24, $32, $33

BigBlobWalkingRightTilemap::
    DB   $24, $24, $44, $45
    DB   $24, $46, $47, $48

Tilemap53A2::
    DB   $24, $49, $4A, $24, $4B, $4C, $4D, $4E

Tilemap53AA::
    DB   $4F, $50, $24, $24, $51, $52, $53, $24

Tilemap53B2::
    DB   $24, $24, $5F, $60, $24, $24, $61, $62

BigSquareBlockOAM1::
    DB   $35, $20, $38, $00, $35, $28, $39, $00, $3D, $20, $3A, $00, $3D, $28, $3B, $00

TransitionStage40OAM::
    DB   $60, $78, $30, $00, $60, $80, $31, $00, $68, $78, $32, $00, $68, $80, $33, $00
    DB   $60, $68, $38, $00, $60, $70, $39, $00, $68, $68, $3A, $00, $68, $70, $3B, $00
    DB   $60, $28, $40, $00, $60, $30, $41, $00, $68, $28, $42, $00, $68, $30, $43, $00

BigBlobOAM1::
    DB   $60, $50, $30, $00, $60, $58, $31, $00, $68, $50, $32, $00, $68, $58, $33, $00

BigBlobOAM2::
    DB   $60, $58, $30, $00, $60, $60, $31, $00, $68, $58, $32, $00, $68, $60, $33, $00

BigBlobOAM3::
    DB   $60, $48, $30, $00, $60, $50, $31, $00, $68, $48, $32, $00, $68, $50, $33, $00

BigBlobWalkingLeftOAM1::
    DB   $60, $50, $4F, $00, $60, $58, $50, $00, $60, $60, $24, $00, $68, $50, $51, $00
    DB   $68, $58, $52, $00, $68, $60, $53, $00

BigFourBlocksOAM::
    DB   $A0, $20, $34, $00, $A0, $28, $35, $00, $A8, $20, $36, $00, $A8, $28, $37, $00
    DB   $F0, $38, $38, $00, $F0, $40, $39, $00, $F8, $38, $3A, $00, $F8, $40, $3B, $00
    DB   $C8, $68, $38, $00, $C8, $70, $77, $00, $D0, $68, $78, $00, $D0, $70, $79, $00
    DB   $B8, $80, $7A, $00, $B8, $88, $7B, $00, $C0, $80, $7C, $00, $C0, $88, $7D, $00

BigBlobWalkingRightOAM::
    DB   $60, $48, $24, $00, $60, $50, $24, $00, $60, $58, $44, $00, $60, $60, $45, $00
    DB   $68, $48, $24, $00, $68, $50, $46, $00, $68, $58, $47, $00, $68, $60, $48, $00

BigBlobWalkingLeftOAM2::
    DB   $60, $48, $4F, $00, $60, $50, $50, $00, $60, $58, $24, $00, $60, $60, $24, $00
    DB   $68, $48, $51, $00, $68, $50, $52, $00, $68, $58, $53, $00, $68, $60, $24, $00

BigBlobTilemaps2::
    DB   $24, $24, $44, $45, $24, $46, $47, $48

UnknownTilemap54CA::
    DB   $24, $49, $4A, $24, $4B, $4C, $4D, $4E

UnknownTilemap54D2::
    DB   $4F, $50, $24, $24, $51, $52, $53, $24

UnknownTilemap54DA::
    DB   $70, $71, $72, $73, $74, $75

UnknownTilemap54E0::
    DB   $4F, $50, $24, $51, $52, $53

HurryUpTextOAM::
    DB   $38, $A8, $BC, $00 ; H top
    DB   $38, $B0, $AC, $00 ; U top
    DB   $38, $B8, $BE, $00 ; R top
    DB   $38, $C0, $BE, $00 ; R top
    DB   $38, $C8, $A8, $00 ; Y top
    DB   $40, $A8, $BD, $00 ; H bottom
    DB   $40, $B0, $AD, $00 ; U bottom
    DB   $40, $B8, $BF, $00 ; R bottom
    DB   $40, $C0, $BF, $00 ; R bottom
    DB   $40, $C8, $A9, $00 ; Y bottom
    DB   $48, $B0, $AC, $00 ; U top
    DB   $48, $B8, $C0, $00 ; P top
    DB   $48, $C0, $BA, $00 ; ! top
    DB   $50, $B0, $AD, $00 ; U bottom
    DB   $50, $B8, $C1, $00 ; P bottom
    DB   $50, $C0, $BB, $00 ; ! bottom

;;;;;;;;;;;;;;;;
; Music and SFX?
;;;;;;;;;;;;;;;;
;
; Not well understood yet

Music::
    DB   $26, $80, $25, $DB, $24, $77, $10, $08, $11, $A6, $16, $A6, $1A, $80, $1B, $E9
    DB   $20, $3E, $22, $4C, $30, $00, $31, $00, $32, $12, $33, $34, $34, $56, $35, $78
    DB   $36, $99, $37, $99, $38, $99, $39, $99, $3A, $87, $3B, $65, $3C, $43, $3D, $21
    DB   $3E, $00, $3F, $00, $FD, $96, $FC

UnknownMusic555D::
    DB   $26, $80, $25, $DB, $24, $77, $10, $08, $11, $A6, $16, $A6, $1A, $80, $1B, $E9
    DB   $20, $3E, $22, $4C, $30, $00, $31, $00, $32, $12, $33, $34, $34, $56, $35, $78
    DB   $36, $99, $37, $99, $38, $99, $39, $99, $3A, $87, $3B, $65, $3C, $43, $3D, $21
    DB   $3E, $00, $3F, $00, $FD, $64, $FC

UnknownMusic5594::
    DB   $26, $80, $25, $DB, $24, $77, $FD, $C8, $FC

UnknownMusic559D::
    DB   $FB
    DW   UnknownMusic555D
    DB   $F0
    
    DB   $FE
    DW   UnknownMusic55A8

UnknownMusic55A4::
    DB   $FB
    DW   Music
    DB   $F0

UnknownMusic55A8::
    DB   $17, $B1, $18, $39, $19, $C7, $1B, $E9, $1C, $20, $1D, $0B, $1E, $C6, $21, $51,
    DB   $23, $C0, $F0, $1B, $E9, $1E, $C4, $21, $31, $23, $C0, $F0, $17, $B1, $18, $39,
    DB   $19, $C7, $1B, $E9, $1E, $C4, $21, $51, $23, $C0, $F0, $17, $B1, $18, $39, $19,
    DB   $C7, $1B, $E9, $1E, $C4, $21, $31, $23, $C0, $F0, $17, $B1, $18, $44, $19, $C7,
    DB   $1B, $E9, $1E, $C4, $21, $51, $23, $C0, $F0, $17, $B1, $18, $39, $19, $C7, $1B,
    DB   $E9, $1D, $63, $1E, $C5, $21, $31, $23, $C0, $F0, $17, $B1, $18, $44, $19, $C7,
    DB   $1B, $E9, $1D, $AC, $1E, $C5, $21, $51, $23, $C0, $F0, $17, $B1, $18, $39, $19,
    DB   $C7, $1B, $E9, $1D, $0B, $1E, $C6, $21, $31, $23, $C0, $F0, $17, $B1, $18, $21,
    DB   $19, $C7, $1B, $E9, $1D, $42, $1E, $C6, $21, $51, $23, $C0, $F0, $1B, $E9, $1D,
    DB   $AC, $1E, $C5, $21, $31, $23, $C0, $F0, $17, $B1, $18, $44, $19, $C7, $1B, $E9,
    DB   $1D, $42, $1E, $C6, $21, $51, $23, $C0, $F0, $1B, $E9, $1D, $72, $1E, $C6, $21,
    DB   $31, $23, $C0, $F0, $17, $B1, $18, $D6, $19, $C6, $1B, $E9, $1D, $89, $1E, $C6,
    DB   $21, $51, $23, $C0, $F0, $12, $B1, $13, $6B, $14, $C7, $1B, $E9, $1D, $B2, $1E,
    DB   $C6, $21, $31, $23, $C0, $F0, $12, $B1, $13, $44, $14, $C7, $1B, $E9, $1D, $89,
    DB   $1E, $C6, $21, $51, $23, $C0, $F0, $12, $B1, $13, $90, $14, $C7, $1B, $E9, $1D,
    DB   $42, $1E, $C6, $21, $51, $23, $C0, $F0, $17, $B1, $18, $21, $19, $C7, $12, $B1,
    DB   $13, $7B, $14, $C7, $1B, $E9, $1D, $63, $1E, $C5, $21, $51, $23, $C0, $F0, $1B,
    DB   $E9, $1E, $C2, $21, $31, $23, $C0, $F0, $17, $B1, $18, $21, $19, $C7, $1B, $E9,
    DB   $1E, $C2, $21, $51, $23, $C0, $F0, $17, $B1, $18, $21, $19, $C7, $1B, $E9, $1E,
    DB   $C2, $21, $31, $23, $C0, $F0, $17, $B1, $18, $39, $19, $C7, $1B, $E9, $1E, $C2,
    DB   $21, $51, $23, $C0, $F0, $17, $B1, $18, $21, $19, $C7, $1B, $E9, $1D, $42, $1E,
    DB   $C6, $21, $31, $23, $C0, $F0, $17, $B1, $18, $39, $19, $C7, $1B, $E9, $1D, $B2,
    DB   $1E, $C6, $21, $51, $23, $C0, $F0, $17, $B1, $18, $21, $19, $C7, $1B, $E9, $1D,
    DB   $63, $1E, $C5, $21, $31, $23, $C0, $F0, $17, $B1, $18, $06, $19, $C7, $12, $B1,
    DB   $13, $83, $14, $C7, $1B, $E9, $1D, $0B, $1E, $C6, $21, $51, $23, $C0, $F0, $1B,
    DB   $E9, $1D, $63, $1E, $C5, $21, $31, $23, $C0, $F0, $17, $B1, $18, $39, $19, $C7,
    DB   $12, $B1, $13, $59, $14, $C7, $1B, $E9, $1D, $0B, $1E, $C6, $21, $51, $23, $C0,
    DB   $F0, $1B, $E9, $1D, $42, $1E, $C6, $21, $31, $23, $C0, $F0, $17, $B1, $18, $B2,
    DB   $19, $C6, $12, $B1, $13, $44, $14, $C7, $1B, $E9, $1D, $72, $1E, $C6, $21, $51,
    DB   $23, $C0, $F0, $12, $B1, $13, $39, $14, $C7, $1B, $E9, $1D, $42, $1E, $C6, $21,
    DB   $31, $23, $C0, $F0, $12, $B1, $13, $06, $14, $C7, $1B, $E9, $1D, $0B, $1E, $C6,
    DB   $21, $51, $23, $C0, $F0, $12, $B1, $13, $B2, $14, $C6, $1B, $E9, $1D, $63, $1E,
    DB   $C5, $21, $31, $23, $C0, $F0, $17, $B1, $18, $39, $19, $C7, $1B, $E9, $1D, $0B,
    DB   $1E, $C6, $21, $51, $23, $C0, $F0, $1B, $E9, $1E, $C4, $21, $31, $23, $C0, $F0,
    DB   $17, $B1, $18, $39, $19, $C7, $1B, $E9, $1E, $C4, $21, $51, $23, $C0, $F0, $17,
    DB   $B1, $18, $39, $19, $C7, $1B, $E9, $1E, $C4, $21, $31, $23, $C0, $F0, $17, $B1,
    DB   $18, $44, $19, $C7, $1B, $E9, $1E, $C4, $21, $51, $23, $C0, $F0, $17, $B1, $18,
    DB   $39, $19, $C7, $1B, $E9, $1D, $63, $1E, $C5, $21, $31, $23, $C0, $F0, $17, $B1,
    DB   $18, $44, $19, $C7, $1B, $E9, $1D, $AC, $1E, $C5, $21, $51, $23, $C0, $F0, $17,
    DB   $B1, $18, $39, $19, $C7, $1B, $E9, $1D, $0B, $1E, $C6, $21, $31, $23, $C0, $F0,
    DB   $17, $B1, $18, $21, $19, $C7, $1B, $E9, $1D, $42, $1E, $C6, $21, $51, $23, $C0,
    DB   $F0, $1B, $E9, $1D, $AC, $1E, $C5, $21, $31, $23, $C0, $F0, $17, $B1, $18, $44,
    DB   $19, $C7, $1B, $E9, $1D, $89, $1E, $C6, $21, $51, $23, $C0, $F0, $1B, $E9, $1D,
    DB   $72, $1E, $C6, $21, $31, $23, $C0, $F0, $17, $B1, $18, $6B, $19, $C7, $12, $B1,
    DB   $13, $21, $14, $C7, $1B, $E9, $1D, $89, $1E, $C6, $21, $51, $23, $C0, $F0, $12,
    DB   $B1, $13, $39, $14, $C7, $1B, $E9, $1D, $B2, $1E, $C6, $21, $31, $23, $C0, $F0,
    DB   $12, $B1, $13, $44, $14, $C7, $1B, $E9, $1D, $D6, $1E, $C6, $21, $51, $23, $C0,
    DB   $F0, $12, $B1, $13, $21, $14, $C7, $1B, $E9, $1D, $42, $1E, $C6, $21, $31, $23,
    DB   $C0, $F0, $17, $B1, $18, $59, $19, $C7, $12, $B1, $13, $59, $14, $C7, $1B, $E9,
    DB   $1D, $B2, $1E, $C6, $21, $51, $23, $C0, $F0, $17, $B1, $18, $6B, $19, $C7, $1B,
    DB   $E9, $1D, $63, $1E, $C5, $21, $31, $23, $C0, $F0, $17, $B1, $18, $44, $19, $C7,
    DB   $1B, $E9, $1D, $0B, $1E, $C6, $21, $51, $23, $C0, $F0, $17, $B1, $18, $59, $19,
    DB   $C7, $1B, $E9, $1D, $B2, $1E, $C6, $21, $31, $23, $C0, $F0, $17, $B1, $18, $39,
    DB   $19, $C7, $12, $B1, $13, $B2, $14, $C6, $1B, $E9, $1D, $B2, $1E, $C6, $21, $51,
    DB   $23, $C0, $F0, $17, $B1, $18, $44, $19, $C7, $1B, $E9, $1D, $63, $1E, $C5, $21,
    DB   $31, $23, $C0, $F0, $17, $B1, $18, $21, $19, $C7, $1B, $E9, $1D, $42, $1E, $C6,
    DB   $21, $51, $23, $C0, $F0, $17, $B1, $18, $39, $19, $C7, $1B, $E9, $1D, $B2, $1E,
    DB   $C6, $21, $31, $23, $C0, $F0, $17, $B1, $18, $44, $19, $C7, $12, $B1, $13, $59,
    DB   $14, $C7, $1B, $E9, $1D, $42, $1E, $C6, $21, $51, $23, $C0, $F0, $17, $B1, $18,
    DB   $D6, $19, $C6, $1B, $E9, $1D, $AC, $1E, $C5, $21, $31, $23, $C0, $F0, $17, $B1,
    DB   $18, $F7, $19, $C6, $1B, $E9, $1D, $ED, $1E, $C5, $21, $51, $23, $C0, $F0, $17,
    DB   $B1, $18, $21, $19, $C7, $1B, $E9, $1D, $63, $1E, $C5, $21, $31, $23, $C0, $F0,
    DB   $17, $B1, $18, $06, $19, $C7, $12, $B1, $13, $06, $14, $C7, $1B, $E9, $1D, $0B,
    DB   $1E, $C6, $21, $51, $23, $C0, $F0, $12, $B1, $13, $44, $14, $C7, $1B, $E9, $1D,
    DB   $89, $1E, $C6, $21, $31, $23, $C0, $F0, $12, $B1, $13, $39, $14, $C7, $1B, $E9,
    DB   $1D, $72, $1E, $C6, $21, $51, $23, $C0, $F0, $12, $B1, $13, $21, $14, $C7, $1B,
    DB   $E9, $1D, $42, $1E, $C6, $21, $31, $23, $C0, $F0
 
    DB   $FE
    DW   UnknownMusic55A8

UnknownMusic59D5::
    DB   $FB
    DW   UnknownMusic555D
    DB   $F0
    
    DB   $FE
    DW   UnknownMusic59E0

UnknownMusic59DC::
    DB   $FB
    DW   Music
    DB   $F0
    
UnknownMusic59E0:: 
    DB   $16, $66, $17, $B1, $18, $59, $19, $C7, $1B, $E9, $1C, $20, $1D, $42, $1E, $C6,
    DB   $F0, $12, $B1, $13, $B2, $14, $C6, $1B, $E9, $1D, $42, $1E, $C6, $21, $31, $23,
    DB   $C0, $F0, $12, $B1, $13, $D6, $14, $C6, $1B, $E9, $1D, $42, $1E, $C6, $23, $C0,
    DB   $F0, $17, $B1, $18, $4F, $19, $C7, $1B, $E9, $1D, $42, $1E, $C6, $F0, $12, $B1,
    DB   $13, $6B, $14, $C7, $1B, $E9, $1D, $42, $1E, $C6, $23, $C0, $F0, $12, $B1, $13,
    DB   $6B, $14, $C7, $1B, $E9, $1D, $AC, $1E, $C5, $23, $C0, $F0, $17, $B1, $18, $21,
    DB   $19, $C7, $1B, $E9, $1D, $ED, $1E, $C5, $F0, $1B, $E9, $1D, $AC, $1E, $C5, $F0,
    DB   $16, $A6, $17, $B1, $18, $6B, $19, $C7, $1B, $E9, $1D, $42, $1E, $C6, $23, $C0,
    DB   $F0, $17, $B1, $18, $21, $19, $C7, $12, $B1, $13, $9E, $14, $C6, $F0, $17, $B1,
    DB   $18, $39, $19, $C7, $12, $B1, $13, $B2, $14, $C6, $F0, $17, $B1, $18, $D6, $19,
    DB   $C6, $1B, $E9, $1D, $42, $1E, $C6, $23, $C0, $F0, $17, $B1, $18, $21, $19, $C7,
    DB   $12, $B1, $13, $9E, $14, $C6, $F0, $17, $B1, $18, $39, $19, $C7, $12, $B1, $13,
    DB   $D6, $14, $C6, $F0, $17, $B1, $18, $4F, $19, $C7, $1B, $E9, $1D, $42, $1E, $C6,
    DB   $23, $C0, $F0, $17, $B1, $18, $21, $19, $C7, $1B, $E9, $1D, $42, $1E, $C6, $23,
    DB   $C0, $F0, $16, $66, $17, $B1, $18, $9E, $19, $C6, $1B, $E9, $1D, $ED, $1E, $C5,
    DB   $F0, $12, $B1, $13, $D6, $14, $C6, $1B, $E9, $1D, $ED, $1E, $C5, $23, $C0, $F0,
    DB   $12, $B1, $13, $F7, $14, $C6, $1B, $E9, $1D, $ED, $1E, $C5, $23, $C0, $F0, $17,
    DB   $B1, $18, $42, $19, $C6, $1B, $E9, $1D, $ED, $1E, $C5, $F0, $12, $B1, $13, $7B,
    DB   $14, $C7, $1B, $E9, $1D, $ED, $1E, $C5, $23, $C0, $F0, $12, $B1, $13, $7B, $14,
    DB   $C7, $1B, $E9, $1D, $3B, $1E, $C5, $23, $C0, $F0, $17, $B1, $18, $F7, $19, $C6,
    DB   $1B, $E9, $1D, $AC, $1E, $C5, $F0, $1B, $E9, $1D, $ED, $1E, $C5, $F0, $16, $A6,
    DB   $17, $B1, $18, $7B, $19, $C7, $1B, $E9, $1D, $ED, $1E, $C5, $23, $C0, $F0, $17,
    DB   $B1, $18, $6B, $19, $C7, $12, $B1, $13, $39, $14, $C7, $F0, $17, $B1, $18, $7B,
    DB   $19, $C7, $12, $B1, $13, $4F, $14, $C7, $F0, $17, $B1, $18, $4F, $19, $C7, $1B,
    DB   $E9, $1D, $ED, $1E, $C5, $23, $C0, $F0, $17, $B1, $18, $7B, $19, $C7, $12, $B1,
    DB   $13, $21, $14, $C7, $F0, $17, $B1, $18, $8A, $19, $C7, $12, $B1, $13, $4F, $14,
    DB   $C7, $F0, $17, $B1, $18, $90, $19, $C7, $1B, $E9, $1D, $ED, $1E, $C5, $23, $C0,
    DB   $F0, $17, $B1, $18, $7B, $19, $C7, $1B, $E9, $1D, $ED, $1E, $C5, $23, $C0, $F0,
    DB   $16, $66, $17, $B1, $18, $59, $19, $C7, $1B, $E9, $1D, $72, $1E, $C6, $F0, $12,
    DB   $B1, $13, $B2, $14, $C6, $1B, $E9, $1D, $72, $1E, $C6, $23, $C0, $F0, $12, $B1,
    DB   $13, $F7, $14, $C6, $1B, $E9, $1D, $72, $1E, $C6, $23, $C0, $F0, $17, $B1, $18,
    DB   $4F, $19, $C7, $1B, $E9, $1D, $72, $1E, $C6, $F0, $12, $B1, $13, $7B, $14, $C7,
    DB   $1B, $E9, $1D, $72, $1E, $C6, $23, $C0, $F0, $12, $B1, $13, $7B, $14, $C7, $1B,
    DB   $E9, $1D, $ED, $1E, $C5, $23, $C0, $F0, $17, $B1, $18, $21, $19, $C7, $1B, $E9,
    DB   $1D, $42, $1E, $C6, $F0, $1B, $E9, $1D, $72, $1E, $C6, $F0, $16, $A6, $17, $B1,
    DB   $18, $59, $19, $C7, $1B, $E9, $1D, $72, $1E, $C6, $23, $C0, $F0, $17, $B1, $18,
    DB   $6B, $19, $C7, $12, $B1, $13, $4F, $14, $C7, $F0, $17, $B1, $18, $7B, $19, $C7,
    DB   $12, $B1, $13, $59, $14, $C7, $F0, $17, $B1, $18, $59, $19, $C7, $1B, $E9, $1D,
    DB   $72, $1E, $C6, $23, $C0, $F0, $17, $B1, $18, $7B, $19, $C7, $12, $B1, $13, $39,
    DB   $14, $C7, $F0, $17, $B1, $18, $39, $19, $C7, $12, $B1, $13, $59, $14, $C7, $F0,
    DB   $17, $B1, $18, $59, $19, $C7, $1B, $E9, $1D, $72, $1E, $C6, $23, $C0, $F0, $17,
    DB   $B1, $18, $F7, $19, $C6, $1B, $E9, $1D, $72, $1E, $C6, $23, $C0, $F0, $16, $66,
    DB   $17, $B1, $18, $D6, $19, $C6, $1B, $E9, $1D, $AC, $1E, $C5, $F0, $12, $B1, $13,
    DB   $B2, $14, $C6, $1B, $E9, $1D, $AC, $1E, $C5, $23, $C0, $F0, $12, $B1, $13, $D6,
    DB   $14, $C6, $1B, $E9, $1D, $AC, $1E, $C5, $23, $C0, $F0, $17, $B1, $18, $72, $19,
    DB   $C6, $1B, $E9, $1D, $AC, $1E, $C5, $F0, $12, $B1, $13, $6B, $14, $C7, $1B, $E9,
    DB   $1D, $AC, $1E, $C5, $23, $C0, $F0, $12, $B1, $13, $6B, $14, $C7, $1B, $E9, $1D,
    DB   $42, $1E, $C6, $23, $C0, $F0, $17, $B1, $18, $6B, $19, $C7, $1B, $E9, $1D, $72,
    DB   $1E, $C6, $F0, $1B, $E9, $1D, $AC, $1E, $C5, $F0, $16, $A6, $17, $B1, $18, $6B,
    DB   $19, $C7, $1B, $E9, $1D, $AC, $1E, $C5, $23, $C0, $F0, $17, $B1, $18, $7B, $19,
    DB   $C7, $12, $B1, $13, $59, $14, $C7, $F0, $17, $B1, $18, $8A, $19, $C7, $12, $B1,
    DB   $13, $6B, $14, $C7, $F0, $17, $B1, $18, $90, $19, $C7, $1B, $E9, $1D, $AC, $1E,
    DB   $C5, $23, $C0, $F0, $17, $B1, $18, $9D, $19, $C7, $12, $B1, $13, $D6, $14, $C6,
    DB   $F0, $17, $B1, $18, $6B, $19, $C7, $12, $B1, $13, $39, $14, $C7, $F0, $17, $B1,
    DB   $18, $59, $19, $C7, $1B, $E9, $1D, $AC, $1E, $C5, $23, $C0, $F0, $17, $B1, $18,
    DB   $39, $19, $C7, $1B, $E9, $1D, $AC, $1E, $C5, $23, $C0, $F0
    
    DB   $FE
    DW   UnknownMusic59E0

UnknownMusic5D5F::
    DB   $FB
    DW   UnknownMusic555D
    DB   $F0
    
    DB   $FE
    DW   UnknownMusic5D6A

UnknownMusic5D66::
    DB   $FB
    DW   Music
    DB   $F0

UnknownMusic5D6A::
    DB   $17, $B1, $18, $D6, $19, $C6, $1B, $E9, $1C, $20, $1D, $83, $1E, $C4, $21, $31,
    DB   $23, $C0, $F0, $1B, $E9, $1E, $C4, $23, $C0, $F0, $1B, $E9, $1E, $C4, $F0, $1B,
    DB   $E9, $1E, $C4, $23, $C0, $F0, $17, $B1, $18, $21, $19, $C7, $1B, $E9, $1E, $C4,
    DB   $23, $C0, $F0, $F0, $1B, $E9, $1D, $58, $1E, $C3, $23, $C0, $F0, $17, $B1, $18,
    DB   $39, $19, $C7, $23, $C0, $F0, $17, $B1, $18, $4F, $19, $C7, $1B, $E9, $1D, $83,
    DB   $1E, $C4, $23, $C0, $F0, $F0, $17, $B1, $18, $4F, $19, $C7, $1B, $E9, $1D, $AC,
    DB   $1E, $C5, $23, $C0, $F0, $17, $B1, $18, $59, $19, $C7, $23, $C0, $F0, $17, $B1,
    DB   $18, $4F, $19, $C7, $1B, $E9, $1D, $42, $1E, $C6, $23, $C0, $F0, $F0, $17, $B1,
    DB   $18, $21, $19, $C7, $1B, $E9, $1D, $9E, $1E, $C6, $23, $C0, $F0, $1B, $E9, $1D,
    DB   $42, $1E, $C6, $23, $C0, $F0, $17, $B1, $18, $39, $19, $C7, $1B, $E9, $1D, $0B,
    DB   $1E, $C6, $23, $C0, $F0, $23, $C0, $F0, $17, $B1, $18, $06, $19, $C7, $1B, $E9,
    DB   $1D, $63, $1E, $C5, $F0, $23, $C0, $F0, $17, $B1, $18, $59, $19, $C7, $1B, $E9,
    DB   $1D, $72, $1E, $C6, $23, $C0, $F0, $F0, $17, $B1, $18, $39, $19, $C7, $1B, $E9,
    DB   $1D, $0B, $1E, $C6, $23, $C0, $F0, $23, $C0, $F0, $17, $B1, $18, $4F, $19, $C7,
    DB   $1B, $E9, $1D, $42, $1E, $C6, $23, $C0, $F0, $17, $B1, $18, $39, $19, $C7, $1B,
    DB   $E9, $1D, $AC, $1E, $C5, $F0, $17, $B1, $18, $4F, $19, $C7, $1B, $E9, $1D, $42,
    DB   $1E, $C6, $23, $C0, $F0, $17, $B1, $18, $59, $19, $C7, $1B, $E9, $1D, $72, $1E,
    DB   $C6, $23, $C0, $F0, $17, $B1, $18, $6B, $19, $C7, $1B, $E9, $1D, $9E, $1E, $C6,
    DB   $23, $C0, $F0, $F0, $12, $B3, $13, $90, $14, $C7, $23, $C0, $F0, $23, $C0, $F0,
    DB   $17, $B1, $18, $B2, $19, $C6, $12, $B1, $13, $83, $14, $C7, $1B, $E9, $1D, $16,
    DB   $1E, $C4, $23, $C0, $F0, $1B, $E9, $1E, $C4, $23, $C0, $F0, $1B, $E9, $1E, $C4,
    DB   $F0, $1B, $E9, $1E, $C4, $23, $C0, $F0, $17, $B1, $18, $06, $19, $C7, $1B, $E9,
    DB   $1D, $16, $1E, $C4, $23, $C0, $F0, $F0, $1B, $E9, $1D, $C7, $1E, $C2, $23, $C0,
    DB   $F0, $17, $B1, $18, $21, $19, $C7, $23, $C0, $F0, $17, $B1, $18, $39, $19, $C7,
    DB   $1B, $E9, $1D, $16, $1E, $C4, $23, $C0, $F0, $F0, $17, $B1, $18, $39, $19, $C7,
    DB   $1B, $E9, $1D, $63, $1E, $C5, $23, $C0, $F0, $17, $B1, $18, $44, $19, $C7, $23,
    DB   $C0, $F0, $17, $B1, $18, $39, $19, $C7, $1B, $E9, $1D, $0B, $1E, $C6, $23, $C0,
    DB   $F0, $F0, $17, $B1, $18, $06, $19, $C7, $1B, $E9, $1D, $72, $1E, $C6, $23, $C0,
    DB   $F0, $1B, $E9, $1D, $27, $1E, $C6, $23, $C0, $F0, $17, $B1, $18, $21, $19, $C7,
    DB   $1B, $E9, $1D, $CE, $1E, $C5, $23, $C0, $F0, $23, $C0, $F0, $17, $B1, $18, $E7,
    DB   $19, $C6, $1B, $E9, $1D, $89, $1E, $C6, $F0, $23, $C0, $F0, $17, $B1, $18, $44,
    DB   $19, $C7, $1B, $E9, $1D, $21, $1E, $C7, $23, $C0, $F0, $F0, $17, $B1, $18, $21,
    DB   $19, $C7, $1B, $E9, $1D, $CE, $1E, $C5, $23, $C0, $F0, $23, $C0, $F0, $17, $B1,
    DB   $18, $39, $19, $C7, $1B, $E9, $1D, $0B, $1E, $C6, $23, $C0, $F0, $F0, $17, $B1,
    DB   $18, $06, $19, $C7, $1B, $E9, $1D, $63, $1E, $C5, $23, $C0, $F0, $23, $C0, $F0,
    DB   $17, $B1, $18, $06, $19, $C7, $1B, $E9, $1D, $11, $1E, $C5, $23, $C0, $F0, $1B,
    DB   $E9, $1D, $E5, $1E, $C4, $F0, $1B, $E9, $1D, $83, $1E, $C4, $23, $C0, $F0, $1B,
    DB   $E9, $1D, $16, $1E, $C4, $23, $C0, $F0
 
    DB   $FE
    DW   UnknownMusic5D6A

UnknownMusic5FC5::
    DB   $FB
    DW   Music
    DB   $30, $BB, $31, $BB, $32, $BB, $33, $00, $34, $00, $35, $00, $36, $00, $37, $00,
    DB   $38, $00, $39, $00, $3A, $00, $3B, $00, $3C, $00, $3D, $00, $3E, $00, $3F, $00,
    DB   $16, $46, $FD, $82, $F0, $17, $B1, $18, $06, $19, $C7, $1B, $E9, $1C, $20, $1D,
    DB   $B2, $1E, $C6, $F0, $19, $C7, $1B, $E9, $1E, $C6, $F0, $18, $B2, $19, $C6, $1B,
    DB   $E9, $1D, $72, $1E, $C6, $F0, $F0, $18, $06, $19, $C7, $1B, $E9, $1D, $B2, $1E,
    DB   $C6, $F0, $F0, $18, $39, $19, $C7, $1B, $E9, $1D, $06, $1E, $C7, $F0, $F0, $18,
    DB   $44, $19, $C7, $1B, $E9, $1D, $D6, $1E, $C6, $F0, $F0, $18, $59, $19, $C7, $1B,
    DB   $E9, $1D, $06, $1E, $C7, $F0, $F0, $18, $6B, $19, $C7, $1B, $E9, $1D, $44, $1E,
    DB   $C7, $F0, $F0, $16, $40, $17, $B3, $18, $83, $19, $C7, $1B, $E0, $1D, $39, $1E,
    DB   $C7, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $17, $08, $19, $80, $1A, $00, $FF

UnknownMusic6068::
    DB   $FB
    DW   Music
    DB   $F0

UnknownMusic606C::
    DB   $12, $B2, $13, $06, $14, $C7, $1B, $E9, $1C, $20, $1D, $16, $1E, $C4, $21, $51,
    DB   $23, $C0, $F0, $12, $B1, $13, $B2, $14, $C6, $1B, $E9, $1D, $63, $1E, $C5, $21,
    DB   $31, $23, $C0, $F0, $12, $B1, $13, $06, $14, $C7, $1B, $E9, $1D, $C7, $1E, $C2,
    DB   $21, $51, $23, $C0, $F0, $12, $B1, $13, $21, $14, $C7, $1B, $E9, $1D, $63, $1E,
    DB   $C5, $21, $31, $23, $C0, $F0, $12, $B1, $13, $39, $14, $C7, $1B, $E9, $1D, $16,
    DB   $1E, $C4, $21, $51, $23, $C0, $F0, $12, $B1, $13, $21, $14, $C7, $1B, $E9, $1D,
    DB   $63, $1E, $C5, $21, $31, $23, $C0, $F0, $12, $B1, $13, $06, $14, $C7, $1B, $E9,
    DB   $1D, $C7, $1E, $C2, $21, $51, $23, $C0, $F0, $12, $B1, $13, $B2, $14, $C6, $1B,
    DB   $E9, $1D, $63, $1E, $C5, $21, $31, $23, $C0, $F0, $12, $B1, $13, $21, $14, $C7,
    DB   $1B, $E9, $1D, $83, $1E, $C4, $21, $51, $23, $C0, $F0, $12, $B1, $13, $B2, $14,
    DB   $C6, $1B, $E9, $1D, $63, $1E, $C5, $21, $31, $23, $C0, $F0, $12, $B1, $13, $21,
    DB   $14, $C7, $1B, $E9, $1D, $C7, $1E, $C2, $21, $51, $23, $C0, $F0, $12, $B1, $13,
    DB   $39, $14, $C7, $1B, $E9, $1D, $63, $1E, $C5, $21, $31, $23, $C0, $F0, $12, $B1,
    DB   $13, $44, $14, $C7, $1B, $E9, $1D, $83, $1E, $C4, $21, $51, $23, $C0, $F0, $12,
    DB   $B1, $13, $39, $14, $C7, $1B, $E9, $1D, $63, $1E, $C5, $21, $31, $23, $C0, $F0,
    DB   $12, $B1, $13, $21, $14, $C7, $1B, $E9, $1D, $C7, $1E, $C2, $21, $51, $23, $C0,
    DB   $F0, $12, $B1, $13, $B2, $14, $C6, $1B, $E9, $1D, $63, $1E, $C5, $21, $31, $23,
    DB   $C0, $F0, $12, $B1, $13, $39, $14, $C7, $1B, $E9, $1D, $16, $1E, $C4, $21, $51,
    DB   $23, $C0, $F0, $12, $B1, $13, $06, $14, $C7, $1B, $E9, $1D, $63, $1E, $C5, $21,
    DB   $31, $23, $C0, $F0, $12, $B1, $13, $39, $14, $C7, $1B, $E9, $1D, $C7, $1E, $C2,
    DB   $21, $51, $23, $C0, $F0, $12, $B1, $13, $44, $14, $C7, $1B, $E9, $1D, $63, $1E,
    DB   $C5, $21, $31, $23, $C0, $F0, $12, $B1, $13, $59, $14, $C7, $1B, $E9, $1D, $16,
    DB   $1E, $C4, $21, $51, $23, $C0, $F0, $12, $B1, $13, $44, $14, $C7, $1B, $E9, $1D,
    DB   $63, $1E, $C5, $21, $31, $23, $C0, $F0, $12, $B1, $13, $39, $14, $C7, $1B, $E9,
    DB   $1D, $C7, $1E, $C2, $21, $51, $23, $C0, $F0, $12, $B1, $13, $06, $14, $C7, $1B,
    DB   $E9, $1D, $63, $1E, $C5, $21, $31, $23, $C0, $F0, $12, $B1, $13, $44, $14, $C7,
    DB   $1B, $E9, $1D, $83, $1E, $C4, $21, $51, $23, $C0, $F0, $12, $B1, $13, $42, $14,
    DB   $C6, $1B, $E9, $1D, $AC, $1E, $C5, $21, $31, $23, $C0, $F0, $12, $B1, $13, $44,
    DB   $14, $C7, $1B, $E9, $1D, $58, $1E, $C3, $21, $51, $23, $C0, $F0, $12, $B1, $13,
    DB   $59, $14, $C7, $1B, $E9, $1D, $AC, $1E, $C5, $21, $31, $23, $C0, $F0, $12, $B1,
    DB   $13, $6B, $14, $C7, $1B, $E9, $1D, $83, $1E, $C4, $21, $51, $23, $C0, $F0, $12,
    DB   $B1, $13, $59, $14, $C7, $1B, $E9, $1D, $AC, $1E, $C5, $21, $31, $23, $C0, $F0,
    DB   $12, $B1, $13, $44, $14, $C7, $1B, $E9, $1D, $58, $1E, $C3, $21, $51, $23, $C0,
    DB   $F0, $12, $B1, $13, $21, $14, $C7, $1B, $E9, $1D, $AC, $1E, $C5, $21, $31, $23,
    DB   $C0, $F0, $12, $B1, $13, $59, $14, $C7, $1B, $E9, $1D, $C7, $1E, $C2, $21, $51,
    DB   $23, $C0, $F0, $12, $B1, $13, $59, $14, $C7, $21, $31, $23, $C0, $F0, $12, $B1,
    DB   $13, $59, $14, $C7, $1B, $E9, $1D, $C7, $1E, $C2, $21, $51, $23, $C0, $F0, $12,
    DB   $B1, $13, $6B, $14, $C7, $21, $31, $23, $C0, $F0, $12, $B1, $13, $59, $14, $C7,
    DB   $1B, $E9, $1D, $C7, $1E, $C2, $21, $51, $23, $C0, $F0, $12, $B1, $13, $21, $14,
    DB   $C7, $21, $31, $23, $C0, $F0, $12, $B1, $13, $39, $14, $C7, $1B, $E9, $1D, $C7,
    DB   $1E, $C2, $21, $51, $23, $C0, $F0, $12, $B1, $13, $06, $14, $C7, $1B, $E9, $1D,
    DB   $16, $1E, $C4, $21, $51, $23, $C0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    
    DB   $FE
    DW   UnknownMusic606C
    
    DB   $FB
    DW   Music
    DB   $F0, $17, $B2, $18, $06, $19, $C7, $1B, $E9, $1C, $20, $1D, $83, $1E, $C4, $F0,
    DB   $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $17,
    DB   $B2, $18, $D6, $19, $C6, $1B, $E9, $1E, $C4, $F0, $F0, $1B, $E9, $1E, $C4, $F0,
    DB   $F0, $17, $B2, $18, $F7, $19, $C6, $1B, $E9, $1D, $63, $1E, $C5, $F0, $1B, $E9,
    DB   $1E, $C5, $F0, $1B, $E9, $1E, $C5, $F0, $1B, $E9, $1E, $C5, $F0, $17, $B2, $18,
    DB   $21, $19, $C7, $1B, $E9, $1D, $11, $1E, $C5, $F0, $F0, $1B, $E9, $1E, $C5, $F0,
    DB   $F0, $17, $B2, $18, $06, $19, $C7, $1B, $E9, $1D, $E5, $1E, $C4, $F0, $1B, $E9,
    DB   $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $17, $B2, $18,
    DB   $39, $19, $C7, $1B, $E9, $1D, $63, $1E, $C5, $F0, $F0, $1B, $E9, $1E, $C5, $F0,
    DB   $F0, $17, $B2, $18, $B2, $19, $C6, $1B, $E9, $1D, $16, $1E, $C4, $F0, $1B, $E9,
    DB   $1E, $C4, $F0, $11, $80, $12, $B4, $13, $39, $14, $C7, $1B, $E9, $1E, $C4, $F0,
    DB   $1B, $E9, $1E, $C4, $F0, $12, $B4, $13, $06, $14, $C7, $1B, $E9, $1D, $E5, $1E,
    DB   $C4, $F0, $F0, $1B, $E9, $1D, $16, $1E, $C4, $F0, $F0, $17, $B2, $18, $89, $19,
    DB   $C6, $1B, $E9, $1D, $83, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E,
    DB   $C4, $F0, $1B, $E9, $1E, $C4, $F0, $17, $B2, $18, $89, $19, $C6, $1B, $E9, $1E,
    DB   $C4, $F0, $F0, $1B, $E9, $1E, $C4, $F0, $F0, $17, $B2, $18, $B2, $19, $C6, $1B,
    DB   $E9, $1D, $C7, $1E, $C2, $F0, $1B, $E9, $1E, $C2, $F0, $1B, $E9, $1E, $C2, $F0,
    DB   $1B, $E9, $1D, $83, $1E, $C4, $F0, $17, $B2, $18, $D6, $19, $C6, $1B, $E9, $1D,
    DB   $C7, $1E, $C2, $F0, $F0, $1B, $E9, $1E, $C2, $F0, $F0, $17, $B2, $18, $B2, $19,
    DB   $C6, $1B, $E9, $1D, $16, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E,
    DB   $C4, $F0, $1B, $E9, $1E, $C4, $F0, $17, $B2, $18, $06, $19, $C7, $1B, $E9, $1D,
    DB   $C7, $1E, $C2, $F0, $F0, $1B, $E9, $1E, $C2, $F0, $F0, $17, $B2, $18, $B2, $19,
    DB   $C6, $1B, $E9, $1D, $16, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $12, $B4, $13,
    DB   $B2, $14, $C6, $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $12, $B4, $13,
    DB   $06, $14, $C7, $1B, $E9, $1D, $E5, $1E, $C4, $F0, $F0, $1B, $E9, $1E, $C4, $F0,
    DB   $F0, $17, $B0, $18, $D6, $19, $86, $1B, $E9, $1D, $83, $1E, $C4, $F0, $1B, $E9,
    DB   $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E,
    DB   $C4, $F0, $F0, $1B, $E9, $1E, $C4, $F0, $F0, $17, $B0, $18, $F7, $19, $86, $1B,
    DB   $E9, $1D, $63, $1E, $C5, $F0, $1B, $E9, $1E, $C5, $F0, $1B, $E9, $1E, $C5, $F0,
    DB   $1B, $E9, $1E, $C5, $F0, $1B, $E9, $1D, $C7, $1E, $C2, $F0, $F0, $1B, $E9, $1E,
    DB   $C2, $F0, $F0, $17, $B0, $18, $06, $19, $87, $1B, $E9, $1D, $16, $1E, $C4, $F0,
    DB   $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $1B,
    DB   $E9, $1D, $C7, $1E, $C2, $F0, $F0, $1B, $E9, $1E, $C2, $F0, $F0, $1B, $E9, $1D,
    DB   $16, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $1B, $E9,
    DB   $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $11, $A6, $12, $B2, $13, $B2, $14, $C6,
    DB   $1B, $E9, $1D, $83, $1E, $C4, $F0, $12, $B2, $13, $06, $14, $C7, $1B, $E9, $1D,
    DB   $E5, $1E, $C4, $F0, $12, $B2, $13, $39, $14, $C7, $1B, $E9, $1D, $16, $1E, $C4,
    DB   $F0, $17, $08, $19, $80, $12, $B2, $13, $44, $14, $C7, $1B, $E9, $1D, $16, $1E,
    DB   $C4, $F0, $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $12, $B7, $13, $39,
    DB   $14, $C7, $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $F0, $1B, $E9, $1E,
    DB   $C4, $F0, $F0, $12, $08, $14, $80, $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4,
    DB   $F0, $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0,
    DB   $12, $B2, $13, $B2, $14, $C6, $F0, $12, $B2, $13, $06, $14, $C7, $1B, $E9, $1E,
    DB   $C4, $F0, $12, $B2, $13, $39, $14, $C7, $F0, $12, $B2, $13, $44, $14, $C7, $1B,
    DB   $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $12, $B0,
    DB   $13, $39, $14, $87, $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $F0, $1B,
    DB   $E9, $1E, $C4, $F0, $F0, $1B, $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $1B,
    DB   $E9, $1E, $C4, $F0, $1B, $E9, $1E, $C4, $F0, $1B, $80, $1E, $C4, $F0, $F0, $F0,
    DB   $F0, $12, $08, $14, $80, $1A, $00, $FF

UnknownMusic6619::
    DB   $FB
    DW   Music
    DB   $16, $46, $FD, $82, $F0

; 6621
GameOverMusic::
    DB   $12, $B1, $13, $2D, $14, $C7, $17, $B1, $18, $B2, $19, $C6, $F0, $F0, $F0, $F0
    DB   $13, $21, $14, $C7, $18, $9E, $19, $C6, $F0, $F0, $13, $14, $14, $C7, $18, $89
    DB   $19, $C6, $F0, $F0, $13, $06, $14, $C7, $18, $5B, $19, $C6, $F0, $F0, $13, $E7
    DB   $14, $C6, $18, $42, $19, $C6, $F0, $F0, $13, $C4, $14, $C6, $18, $0B, $19, $C6
    DB   $F0, $F0, $13, $89, $14, $C6, $18, $89, $19, $C5, $F0, $F0, $11, $40, $12, $B3
    DB   $13, $5B, $14, $C6, $17, $B3, $18, $63, $19, $C5, $F0, $F0, $F0, $F0, $F0, $F0
    DB   $F0, $F0, $17, $08, $19, $80, $12, $08, $14, $80, $FF

UnknownMusic668C::
    DB   $12, $08, $14, $80, $17, $08, $19, $80, $1A, $00, $21, $08, $23, $80, $FF
    
; 669B
UnknownMusic2:: 
    DB   $FB
    DW   UnknownMusic5594
    DB   $F0, $10, $34, $11, $A0, $12, $F0, $13, $0B, $14, $C6, $F0, $10, $08, $11, $A6
    DB   $12, $08, $14, $80, $FF

; 66B3
UnknownMusic3::
    DB   $FB
    DW   UnknownMusic5594
    DB   $FD, $32, $F0, $10, $08, $11, $A6, $12, $F0, $13, $D6, $14, $C6, $F0, $13, $06
    DB   $14, $C7, $F0, $10, $08, $11, $A6, $12, $08, $14, $80, $FF

UnknownMusic66D2::
    DB   $FB
    DW   UnknownMusic5594
    DB   $FD, $1E, $F0, $10, $08, $11, $A6, $12, $F0, $13, $C1, $14, $C7, $F0, $12, $F1
    DB   $13, $CE, $14, $C7, $F0, $10, $08, $11, $A6, $12, $08, $14, $80, $FF

    DB   $FB
    DW   UnknownMusic5594
    DB   $FD, $19, $F0, $10, $08, $11, $A6, $12, $F0, $13, $ED, $14, $C5, $F0, $12, $F1
    DB   $13, $AC, $14, $C5, $F0, $10, $08, $11, $A6, $12, $08, $14, $80, $FF

UnknownMusic6714::
    DB   $FB
    DW   UnknownMusic5594
    DB   $F0, $10, $3B, $11, $A0, $12, $F0, $13, $D6, $14, $C6, $F0, $10, $08, $11, $A6
    DB   $12, $08, $14, $80, $FF

UnknownMusic672C::
    DB   $FB
    DW   UnknownMusic5594
    DB   $F0, $10, $35, $11, $A0, $12, $F3, $13, $D6, $14, $C6, $F0, $10, $08, $11, $A6
    DB   $12, $08, $14, $80, $FF
    
; 6744
UnknownMusic::
    DB   $FB
    DW   UnknownMusic5594
    DB   $FD, $FF, $F0, $10, $08, $11, $A6, $12, $F0, $13, $44, $14, $C7, $F0, $13, $06,
    DB   $14, $C7, $F0, $13, $44, $14, $C7, $F0, $13, $06, $14, $C7, $F0, $13, $44, $14,
    DB   $C7, $F0, $13, $06, $14, $C7, $F0, $13, $44, $14, $C7, $F0, $13, $06, $14, $C7,
    DB   $F0, $13, $44, $14, $C7, $F0, $13, $06, $14, $C7, $F0, $13, $44, $14, $C7, $F0,
    DB   $13, $06, $14, $C7, $F0, $13, $44, $14, $C7, $F0, $13, $06, $14, $C7, $F0, $13,
    DB   $44, $14, $C7, $F0, $13, $06, $14, $C7, $F0, $10, $08, $11, $A6, $12, $08, $14,
    DB   $80, $FF

UnknownMusic67A9::
    DB   $FB
    DW   UnknownMusic5594
    DB   $FD, $C8, $F0, $10, $08, $11, $A0, $12, $51, $13, $4F, $14, $C7, $F0, $10, $08
    DB   $11, $A6, $12, $08, $14, $80, $FF

UnknownMusic67C3::
    DB   $FB
    DW   UnknownMusic5594
    DB   $F0, $10, $39, $11, $A0, $12, $F0, $13, $16, $14, $C4, $20, $00, $21, $D1, $22
    DB   $4C, $23, $80, $F0, $10, $08, $11, $A6, $12, $08, $14, $80, $FF

    DB   $FB
    DW   Music
    DB   $FD, $1E, $F0, $1B, $F9, $1C, $20, $1D, $16, $1E, $C4, $F0, $1B, $F9, $1C, $20
    DB   $1D, $E5, $1E, $C4, $F0, $1A, $00, $FF


    DB   $FB
    DW   UnknownMusic5594
    DB   $FD, $10, $F0, $20, $00, $21, $F0, $22, $81, $23, $80, $F0, $20, $00, $21, $F1
    DB   $22, $4C, $23, $00, $F0, $21, $08, $23, $80, $FF

UnknownMusic681B::
    DB   $FB
    DW   UnknownMusic5594
    DB   $FD, $64, $F0, $12, $F1, $13, $AC, $14, $C7, $F0, $12, $F1, $13, $AC, $14, $C7,
    DB   $F0, $12, $F1, $13, $B6, $14, $C7, $F0, $12, $F4, $13, $C1, $14, $C7, $F0, $F0,
    DB   $F0, $F0, $F0, $10, $08, $11, $A6, $12, $08, $14, $80, $FF

; 684A
UnknownMusic4::
    DB   $FB
    DW   UnknownMusic5594
    DB   $FD, $C8, $F0, $10, $37, $11, $A0, $12, $F0, $13, $06, $14, $C7, $F0, $10, $08
    DB   $11, $A6, $12, $08, $14, $80, $FF

UnknownMusic6864::
    DB   $FB
    DW   UnknownMusic5594
    DB   $F0, $10, $3A, $11, $A0, $12, $F0, $13, $06, $14, $C7, $F0, $10, $08, $11, $A6
    DB   $12, $08, $14, $80, $FF

UnknownMusic687C::
    DB   $FB
    DW   UnknownMusic5594
    DB   $FD, $6E, $F0, $10, $08, $11, $A6, $12, $F1, $13, $44, $14, $C7, $F0, $12, $F1
    DB   $13, $59, $14, $C7, $F0, $12, $F2, $13, $6B, $14, $C7, $F0, $F0, $10, $08, $11
    DB   $A6, $12, $08, $14, $80, $FF
