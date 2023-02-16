SECTION "HRAM", HRAM[$FF80]

; FF80
hDMARoutine::
    ds 1

; FF81-FF8A
; Unknown
    ds 10

; FF8B
hPressedButtonsMask::
    ds 1

; FF8C
hJoypadState::
    ds 1

; FF8D-FF90
; Unknown
    ds 4

; FF91
; Set to 1 when the VBlank interrupt handler has finished.
hVBlankDone::
    ds 1

; FF92
; Unknown
    ds 1

; FF93
; Copy of rIE. Seems unused.
hIE::
    ds 1

; FF94-FFAF
; Unknown
    ds 28

; FFB0
hCounter::
    ds 2

; FFB2-FFBF
    ds 14

; FFC0
hBlocksInitial::
    ds 2

; FFC2-FFC3
; Unknown
    ds 2

; FFC4
hCredits::
    ds 1

; FFC5
hSBlocksRemaining::
    ds 1

; FFC6
hStage::
    ds 3

; FFC9
hBlocks::
    ds 2

; FFCB
hSeconds::
    ds 2

; FFCD
hUnknown::
    ds 1

; FFCE
hMinutes::
    ds 1

; FFCF
; Unknown
    ds 1

; FFD0
hClearCount::
    ds 1

; FFD1-FFDC
; Unknown
    ds 12

; FFDD
hMusic::
    ds 3

; FFE0
hMusicSpeed::
    ds 1