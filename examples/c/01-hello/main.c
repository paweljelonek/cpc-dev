/* Hello World dla Amstrad CPC — z88dk (zcc +cpc)
 *
 * Build: make
 * Load:  LOAD "MAIN.BIN",&8000  (z BASICa)
 * Run:   CALL &8000
 */

#include <stdio.h>

int main(void) {
    printf("Hello, Amstrad CPC!\n");
    return 0;
}
