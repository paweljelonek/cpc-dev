; Border color animation - Amstrad CPC
;
; Cycles through all 32 CPC colors on the screen border using
; direct Gate Array access (port &7F).
;
; Load from BASIC:
;   LOAD "MAIN.BIN",&8000
;   CALL &8000
; Exit: CTRL+BREAK

    org &8000

; Gate Array port (A15=0, A14=1 - typically &7F)
GA          equ &7F
; Select pen command: bits 7-6 = 01 - &40 | pen_number
; Pen 16 (&10) = border
GA_BORDER   equ &50         ; &40 | &10
; Set color command: bits 7-6 = 10 - &80 | color (0-31)
GA_COLOR    equ &80

DELAY       equ 4000        ; delay ticks between colors

start:
    ld b, 0                 ; current color (0-31)

.loop:
    ; select border pen
    ld a, GA_BORDER
    out (GA), a
    ; set color
    ld a, GA_COLOR
    or b
    out (GA), a

    ; delay
    ld de, DELAY
.wait:
    dec de
    ld a, d
    or e
    jr nz, .wait

    ; next color, wrap at 32
    inc b
    ld a, b
    and &1F
    ld b, a
    jr .loop
