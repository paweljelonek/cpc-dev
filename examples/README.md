# Examples - Amstrad CPC

Ready-to-run programs for learning CPC development in Z80 assembler and C.

## Structure

```
examples/
├── asm/
│   ├── 01-hello/   - Hello World (firmware TXT_OUTPUT)
│   └── 02-border/  - border color animation (Gate Array, port &7F)
└── c/
    ├── 01-hello/   - Hello World (printf, z88dk)
    └── 02-border/  - border color animation (Gate Array via inline asm)
```

## Requirements

| Tool   | Purpose                    |
|--------|----------------------------|
| `rasm` | Z80 assembler (ASM examples) |
| `zcc`  | C compiler - z88dk (C examples) |
| `iDSK` | DSK disk image creation    |
| `cap32`| Caprice32 emulator         |

Install everything with `./setup-cpc-dev.sh` from the project root.

## Building and running

Each example has its own `Makefile`:

```bash
cd examples/asm/01-hello
make          # build (produces main.bin and main.dsk)
make run      # build and launch in Caprice32
make clean    # remove build artifacts
```

## Loading from BASIC

Once Caprice32 opens with the DSK image:

```basic
LOAD "MAIN.BIN",&8000
CALL &8000
```

## Example descriptions

### `asm/01-hello` - Hello World (ASM)

Prints a string using the CPC firmware routine `TXT_OUTPUT` (&BB5A).
Demonstrates: `org`, `defb`, iterating over a null-terminated string, `ret` to BASIC.

### `asm/02-border` - Border animation (ASM)

Cycles through all 32 CPC colors on the screen border by writing directly to
the Gate Array (port &7F). Demonstrates: `OUT`, delay loops, wrapping with `AND`.

Gate Array byte format:

- `&40 | pen` - select pen (pen 16 = border)
- `&80 | color` - set color (0–31 from the CPC palette)

### `c/01-hello` - Hello World (C)

`printf` output on the CPC screen, compiled with z88dk (`zcc +cpc`).
Demonstrates: minimal C compilation setup for CPC.

### `c/02-border` - Border animation (C)

Same effect as `asm/02-border`, written in C with Gate Array access via a
z88dk inline assembly block (`#asm`/`#endasm`).
Demonstrates: mixing C and assembly, direct hardware access from C.

## CPC color palette (0–31)

```
 0 Black         8 Dark Blue     16 Bright Blue    24 Bright Green
 1 Blue          9 Blue          17 Sea Green      25 Cyan
 2 Bright Blue  10 Bright Blue   18 Lime Green     26 Bright Cyan
 3 Red          11 Magenta       19 Green          27 Pastel Blue
 4 Magenta      12 Bright Magenta 20 Sky Blue      28 Sea Green
 5 Bright Magenta 13 Orange      21 White          29 Bright Sea Green
 6 Dark Red     14 Pink          22 Pastel Blue    30 Bright Yellow
 7 Purple       15 Bright Pink   23 Bright White   31 Bright White
```
