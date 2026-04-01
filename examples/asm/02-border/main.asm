; Animacja koloru obramowania — Amstrad CPC
;
; Cyklicznie zmienia kolor bordera uzywajac bezposredniego
; dostepu do Gate Array (port &7F).
;
; Uruchomienie z BASICa:
;   LOAD "MAIN.BIN",&8000
;   CALL &8000
; Wyjscie: CTRL+BREAK

    org &8000

; Gate Array: adres portu (A15=0, A14=1 → typowo &7F)
GA          equ &7F
; Komenda wyboru pena: bity 7-6 = 01 → &40 | numer_pena
; Pen 16 (&10) = border
GA_BORDER   equ &50         ; &40 | &10
; Komenda ustawienia koloru: bity 7-6 = 10 → &80 | kolor (0-31)
GA_COLOR    equ &80

DELAY       equ 4000        ; tiki opoznienia miedzy kolorami

start:
    ld b, 0                 ; biezacy kolor (0-31)

.loop:
    ; wybierz pen bordera
    ld a, GA_BORDER
    out (GA), a
    ; ustaw kolor
    ld a, GA_COLOR
    or b
    out (GA), a

    ; opoznienie
    ld de, DELAY
.wait:
    dec de
    ld a, d
    or e
    jr nz, .wait

    ; nastepny kolor, zawijaj po 32
    inc b
    ld a, b
    and &1F
    ld b, a
    jr .loop
