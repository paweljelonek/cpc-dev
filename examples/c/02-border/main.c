/* Border color animation - Amstrad CPC - z88dk (zcc +cpc) */

int main(void) {
#asm
    ei
    ld d, 0

border_color_loop:
    ld b, 0x7F
    ld a, 0x10
    out (c), a
    ld a, 0x40
    or d
    out (c), a

    ld e, 20
border_wait:
    halt
    dec e
    jr nz, border_wait

    inc d
    ld a, d
    and 0x1F
    ld d, a
    jr border_color_loop
#endasm
    return 0;
}
