# Examples

| Path              | Language | What it shows                                      |
|-------------------|----------|----------------------------------------------------|
| `asm/01-hello/`   | Z80 ASM  | Hello World via firmware `TXT_OUTPUT` (&BB5A)      |
| `asm/02-border/`  | Z80 ASM  | Border color animation via Gate Array (port &7F)   |
| `c/01-hello/`     | C        | Hello World with `printf` (z88dk `+cpc` target)    |
| `c/02-border/`    | C        | Border animation using inline `#asm`/`#endasm`     |

```bash
cd examples/asm/01-hello
make run
```

MAME opens with the DSK inserted and types the load commands automatically. If autorun does not trigger, type manually:

```basic
|DISC
MEMORY &7FFF
LOAD "MAIN.BIN",&8000
CALL &8000
```

Install all required tools first with `./setup.sh` from the project root.
