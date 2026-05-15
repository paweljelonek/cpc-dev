/* Hello World - Amstrad CPC - z88dk (zcc +cpc)
 *
 * Build: make
 * Load:  LOAD "MAIN.BIN",&8000  (from BASIC)
 * Run:   CALL &8000
 */

#include <stdio.h>
#include <conio.h>

int main(void) {
    printf("Hello, Amstrad CPC!\n");
    printf("Press any key...\n");
    getchar();
    return 0;
}
