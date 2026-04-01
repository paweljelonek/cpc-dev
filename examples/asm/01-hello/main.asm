; Hello World — Amstrad CPC
;
; Wyswietla tekst uzywajac firmware CPC (TXT_OUTPUT).
; Uruchomienie z BASICa:
;   LOAD "MAIN.BIN",&8000
;   CALL &8000

    org &8000

TXT_OUTPUT  equ &BB5A       ; firmware: wyslij znak z A na ekran

start:
    ld hl, msg
.next:
    ld a, (hl)
    or a
    ret z                   ; koniec stringa — powrot do BASICa
    call TXT_OUTPUT
    inc hl
    jr .next

msg:
    defb "Hello, Amstrad CPC!", 13, 0
