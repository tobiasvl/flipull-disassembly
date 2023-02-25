SECTION "OAM", WRAM0[$C000]
wBlob::
    ds 4

wCurrentBlock::
    ds 4

wArrow::
    ds 4

SECTION "Score", WRAM0[$C120]
; C120
wScore::
    ds 7

SECTION "High Score", WRAM0[$C130]
; C130
wHiScore::
    ds 7

SECTION "Blocks 1", WRAM0[$C840]
; C840
wBlocks1::
    ds $10

SECTION "Blocks 2", WRAM0[$C9E0]
; C9E0
wBlocks2::
    ds $10

SECTION "Block RNG", WRAM0[$CA00]
; CA00
wBlockRNG::
    ds $24

SECTION "Block RNG counter", WRAM0[$CA30]
; CA30
wBlockRNGCounter::
    ds 1

SECTION "Stack", WRAM0[$CFFF]
; CFFF
wStack::
    ds 1