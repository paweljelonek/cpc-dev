/* Animacja koloru bordera — Amstrad CPC — z88dk (zcc +cpc)
 *
 * Build: make
 * Load:  LOAD "MAIN.BIN",&8000  (z BASICa)
 * Run:   CALL &8000
 * Exit:  CTRL+BREAK
 *
 * Dostep do portu Gate Array realizowany przez inline Z80 asm
 * (z88dk: blok #asm / #endasm).
 */

/* Gate Array port i komendy */
#define GA_PORT     0x7F
#define GA_BORDER   0x50    /* 0x40 | 0x10: wybierz pen 16 = border  */
#define GA_COLOR    0x80    /* 0x80 | kolor: ustaw kolor (0-31)       */

/* Zmienne globalne uzyte do przekazania wartosci do bloku asm
 * (omijamy kwestie konwencji wywolan z88dk)                         */
static unsigned char _ga_val;

static void ga_out(unsigned char val) {
    _ga_val = val;
#asm
    ld   a, (_ga_val)
    ld   c, 0x7F
    out  (c), a
#endasm
}

static void set_border(unsigned char color) {
    ga_out(GA_BORDER);
    ga_out((unsigned char)(GA_COLOR | (color & 0x1F)));
}

static void delay(unsigned int n) {
    unsigned int i;
    for (i = 0; i < n; i++);
}

int main(void) {
    unsigned char color;
    for (;;) {
        for (color = 0; color < 32; color++) {
            set_border(color);
            delay(8000);
        }
    }
    return 0;
}
