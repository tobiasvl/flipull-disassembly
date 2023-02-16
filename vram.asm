SECTION "Clear count", VRAM[$9890]
; 9890
vClearCount::
    ds 2

SECTION "Enemy blocks count", VRAM[$98F0]
; 98F0
vEnemyBlocksCount::
    ds 2

SECTION "Title screen High Score", VRAM[$9949]
; 9949
vTitleScreenHiScore::
    ds 7

SECTION "Blocks count", VRAM[$9950]
; 9950
vBlocksCount::

SECTION "S-Blocks count", VRAM[$99D1]
; 99D1
vSBlockCount::
    ds 1

SECTION "Stage number", VRAM[$99AF]
; 99AF
vStageNumber::
    ds 3