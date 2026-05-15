; Hello World - Amstrad CPC
;
; Prints text using the CPC firmware routine TXT_OUTPUT.
; Load from BASIC:
;   LOAD "MAIN.BIN",&8000
;   CALL &8000

    org &8000

TXT_OUTPUT  equ &BB5A       ; firmware: send character in A to screen

start:
    ld hl, msg
.next:
    ld a, (hl)
    or a
    ret z                   ; null terminator - return to BASIC
    call TXT_OUTPUT
    inc hl
    jr .next

msg:
    defb "Hello, Amstrad CPC!", 13, 0
