; Border color animation - Amstrad CPC
;
; Cycles through all 32 CPC colors on the screen border.
; Uses HALT to sync with CPC timer interrupt (~300Hz).
;
; Load from BASIC:
;   LOAD "MAIN.BIN",&8000
;   CALL &8000
; Exit: CTRL+BREAK

    org &8000

GA_PORT     equ &7F     ; B=&7F for OUT (C),A: A15=0, A14=1
GA_BORDER   equ &10     ; select border pen: &00 | &10 (bits 7-6=00, bit4=1)
GA_COLOR    equ &40     ; set color: &40 | color 0-31 (bits 7-6=01)

HALTS       equ 20      ; interrupts per color (~66ms at 300Hz)

start:
    ld d, 0             ; current color (0-31)

.loop:
    ld b, GA_PORT

    ld a, GA_BORDER
    out (c), a          ; select border pen

    ld a, GA_COLOR
    or d
    out (c), a          ; set color

    ld e, HALTS
.wait:
    halt                ; wait for next CPC interrupt (~3.3ms)
    dec e
    jr nz, .wait

    inc d
    ld a, d
    and &1F
    ld d, a
    jr .loop
