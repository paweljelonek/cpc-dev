# cpc-dev

> **⚠ Unstable - work in progress. Use at your own risk.**
>
> This project is in active, early-stage development. The directory structure,
> Makefile interface, and install scripts may change without notice between
> commits. The install script modifies your system (installs packages,
> compiles tools from source, writes to `~/.local/bin/` and `~/.cpc-dev/`) -
> read it before running. No guarantees are made about correctness,
> completeness, or fitness for any purpose.

Development environment for Amstrad CPC - Z80 assembler and C compiler toolchain,
Caprice32 emulator, DSK disk image tools, and ready-to-run examples.
Targets CPC464, CPC664, CPC6128, and CPC6128+.

> **🐧 Linux (Ubuntu / Linux Mint / Debian) only**
>
> `setup.sh` and `remove.sh` are written for Ubuntu, Linux Mint, and Debian-based
> distributions. They rely on `apt-get` and assume a standard Debian package layout.
>
> Other Linux distributions, macOS, and Windows are **not supported** at the moment.
> Whether that changes depends entirely on free time and motivation - no promises.
> If you get it running on another system, a note or patch is welcome.



---

## Contents

- [Structure](#structure)
- [Requirements](#requirements)
- [Quick start](#quick-start)
- [Makefile reference](#makefile-reference)
- [Examples](#examples)
- [Tools](#tools)
- [Known limitations](#known-limitations)
- [Troubleshooting](#troubleshooting)
- [Links](#links)

---

## Structure

```
cpc-dev/
├── .env               - local configuration (git-ignored, copy from .env.dist)
├── .env.dist          - configuration template
├── .gitignore
├── LICENSE
├── setup.sh           - install all tools (Linux Mint / Ubuntu / Debian)
├── remove.sh          - remove everything installed by setup.sh
├── Makefile           - build and run projects
└── examples/          - ready-to-run examples (ASM and C)
    ├── README.md
    ├── asm/
    │   ├── 01-hello/  - Hello World in Z80 assembler
    │   └── 02-border/ - border color animation via Gate Array
    └── c/
        ├── 01-hello/  - Hello World in C (z88dk)
        └── 02-border/ - border color animation in C
```

Your own projects live separately in `~/Projects/cpc-projects/` (configurable),
each as its own git repository. This repo only provides the toolchain and
environment - it does not host your code.

---

## Requirements

- **OS:** Ubuntu, Linux Mint, or Debian
- **Shell:** bash or zsh
- **Disk:** ~2 GB free for source builds (z88dk, CPCtelera)
- **Internet:** required during `setup.sh` (downloads sources and packages)
- `git`, `curl`, `wget`, `make`, `gcc` - needed before running the setup script

---

## Quick start

### 1. Install tools

```bash
./setup.sh
```

The script installs everything needed and may take several minutes. Tools end up
in three locations:

> **⏳ z88dk build takes time**
>
> Building z88dk from source is the longest step - it clones several submodules
> and compiles a full C compiler toolchain. Expect **5–15 minutes** of build
> time. The script will appear to hang while pulling submodules (`ext/regex`,
> `ext/uthash`, etc.) and then again during compilation - **this is normal,
> do not interrupt it.**

**`~/.cpc-dev/`** - source trees and build directories:

| Subdirectory      | Contents                                              | Created        |
|-------------------|-------------------------------------------------------|----------------|
| `rasm-src/`       | Rasm assembler source                                 | always         |
| `z88dk/`          | z88dk C compiler and Z80 toolchain                    | always         |
| `vasm/`           | vasm assembler source                                 | always         |
| `idsk-src/`       | iDSK disk image tool source                           | always         |
| `cpcfs-src/`      | cpcxfs DSK filesystem tool source                     | always         |
| `cpctlera/`       | CPCtelera C/ASM framework                             | always         |
| `ArkosTracker2/`  | placeholder - Arkos Tracker 2 requires manual download | always        |
| `caprice32-src/`  | Caprice32 emulator source                             | only if apt fails |
| `pasmo-src/`      | Pasmo assembler source                                | only if apt fails |

**`~/.local/bin/`** - compiled binaries and wrapper scripts:

| Binary     | Source                        | Installed        |
|------------|-------------------------------|------------------|
| `rasm`     | built from source             | always           |
| `zcc`      | wrapper script for z88dk      | always           |
| `vasmz80`  | built from source             | always           |
| `iDSK`     | built from source             | always           |
| `cpcxfs`   | built from source             | always           |
| `cap32`    | built from source             | only if apt fails |
| `pasmo`    | built from source             | only if apt fails |

**system (apt):** always installed via `apt-get`:

| Package            | Purpose                              |
|--------------------|--------------------------------------|
| `build-essential`  | gcc, make, and base build tools      |
| `git`              | version control                      |
| `curl`, `wget`     | downloading sources                  |
| `unzip`            | archive extraction                   |
| `cmake`            | build system (used by Pasmo)         |
| `python3`, `python3-pip` | scripting, used by some tools  |
| `default-jre`      | Java runtime (used by CPCtelera)     |
| `libsdl2-dev`, `libsdl2-image-dev` | graphics/emulator libs |
| `libpng-dev`, `zlib1g-dev` | image and compression libs   |
| `nasm`             | x86 assembler (build dependency)     |
| `caprice32`        | CPC emulator (falls back to source build if unavailable) |
| `pasmo`            | Z80 assembler (falls back to source build if unavailable) |

The setup script also adds `~/.local/bin` to `PATH` in `~/.bashrc` or `~/.zshrc`
if not already present.

To undo the installation run:

```bash
./remove.sh
```

This removes `~/.cpc-dev/`, the binaries from `~/.local/bin/`, and the `PATH`
entry from your shell rc. Apt packages are left intact.

### 2. Configure

```bash
cp .env.dist .env
```

Edit `.env` to point to your projects directory:

```env
CPC_PROJECTS=/home/you/Projects/cpc-projects
```

The `.env` file is git-ignored and loaded automatically by the Makefile.

### 3. Create a new project

```bash
mkdir ~/Projects/cpc-projects/my-project
cd ~/Projects/cpc-projects/my-project
git init
echo -e "*.bin\n*.dsk\n*.sym\n*.o" > .gitignore
# create main.asm (or main.c) and start coding
```

Every project must have a `main.asm` entry point (for assembly projects).
C projects use their own Makefile - see [examples/c/](examples/c/).

### 4. Build and run

```bash
make PROJECT=my-project           # assemble → create DSK image
make run PROJECT=my-project       # assemble → launch in Caprice32
make debug PROJECT=my-project     # assemble → launch with Caprice32 debugger
make clean PROJECT=my-project     # remove *.bin *.dsk *.sym *.o
make list                         # list all projects in CPC_PROJECTS
```

You can also target any local directory directly, without using `CPC_PROJECTS`:

```bash
make DIR=examples/asm/01-hello
make run DIR=examples/asm/01-hello
make clean DIR=examples/asm/01-hello
```

`DIR` accepts relative or absolute paths.

### 5. Try the examples

```bash
cd examples/asm/01-hello && make run   # Hello World - Z80 assembler
cd examples/asm/02-border && make run  # border animation - Z80 assembler
cd examples/c/01-hello && make run     # Hello World - C (z88dk)
cd examples/c/02-border && make run    # border animation - C (z88dk)
```

After Caprice32 opens, load the program from the DSK:

```basic
LOAD "MAIN.BIN",&8000
CALL &8000
```

See [examples/README.md](examples/README.md) for a full description of each example.

---

## Makefile reference

| Target  | Parameters         | Description                              |
|---------|--------------------|------------------------------------------|
| `all`   | `PROJECT` or `DIR` | Assemble source, produce `.bin` and `.dsk` |
| `run`   | `PROJECT` or `DIR` | Build, then launch in Caprice32          |
| `debug` | `PROJECT` or `DIR` | Build, then launch with Caprice32 debugger |
| `clean` | `PROJECT` or `DIR` | Delete `.bin`, `.dsk`, `.sym`, `.o`      |
| `list`  | -                  | List projects in `CPC_PROJECTS`          |

**`PROJECT=name`** - looks up `$(CPC_PROJECTS)/name/`  
**`DIR=path`** - uses the given path directly (relative or absolute)

The Makefile expects a `main.asm` source file in the project directory. For C
projects, use the per-example Makefile (`zcc`) instead.

---

## Examples

| Path                  | Language | Demonstrates                                  |
|-----------------------|----------|-----------------------------------------------|
| `asm/01-hello/`       | Z80 ASM  | Firmware call `TXT_OUTPUT` (&BB5A), string loop, `ret` to BASIC |
| `asm/02-border/`      | Z80 ASM  | Direct Gate Array I/O (port &7F), delay loops |
| `c/01-hello/`         | C        | `printf` via z88dk `+cpc` target              |
| `c/02-border/`        | C        | Gate Array I/O from C via `#asm`/`#endasm`    |

See [examples/README.md](examples/README.md) for build instructions and a
description of the CPC color palette.

---

## Tools

All tools below are installed automatically by `setup.sh` for Amstrad CPC development.

| Tool          | Role                                       | Notes                                           | Source |
|---------------|--------------------------------------------|-------------------------------------------------|--------|
| **rasm**      | Z80 assembler, CPC-centric                 | Default assembler, supports AMSDOS output, macros, struct | [github](https://github.com/EdouardBERGE/rasm) |
| **pasmo**     | Portable Z80 cross-assembler               | Alternative to rasm, simpler feature set        | [pasmo.speccy.org](https://pasmo.speccy.org/) |
| **vasmz80**   | vasm with Z80 backend                      | Alternative assembler, multiple syntax modes    | [hasenbraten.de](http://sun.hasenbraten.de/vasm/) |
| **zcc / z88dk** | C compiler and Z80 toolchain             | Used for C examples; `+cpc` target for CPC      | [github](https://github.com/z88dk/z88dk) |
| **cap32**     | Caprice32 emulator                         | Emulates CPC464/664/6128/6128+; `-d` opens debugger | [github](https://github.com/ColinPitrat/caprice32) |
| **iDSK**      | DSK disk image tool                        | Creates and populates `.dsk` images             | [github](https://github.com/cpcsdk/idsk) |
| **cpcxfs**    | CPC DSK filesystem tool                    | Alternative to iDSK for DSK manipulation        | [github](https://github.com/cpcsdk/cpcfs) |
| **CPCtelera** | C/ASM framework for CPC                    | Higher-level API for graphics, sound, input     | [github](https://github.com/lronaldo/cpctelera) |
| **Arkos Tracker** | AY/YM music tracker                    | Manual install - see project website            | [julien-nevo.com](https://www.julien-nevo.com/arkostracker/) |

---

## Known limitations

- The Makefile only handles **assembly projects** (`main.asm` + rasm). C
  projects must use their own Makefile (see `examples/c/`). A unified workflow
  for C is not yet implemented.
- `setup.sh` has been tested on **Linux Mint / Ubuntu / Debian** only.
  Other distributions will likely need manual adjustments.
- No support yet for multi-file projects or includes across directories.
- The Caprice32 autoboot sequence (loading from DSK automatically on start) is
  not set up - you must type `LOAD`/`CALL` manually or use a BASIC loader on
  the DSK. This is a known gap.
- CPCtelera requires its own project scaffold (`cpct_mkproject`) and is not
  integrated into the main Makefile. The examples use z88dk instead.
- `iDSK` commands in the Makefile do not set AMSDOS load/exec addresses.
  Always use `LOAD "MAIN.BIN",&8000` followed by `CALL &8000` from BASIC.

---

## Troubleshooting

### z88dk build fails with `bifrost2_engine_48.bin.zx0`

If `setup.sh` fails during the z88dk step with an error like:

```
make: *** No rule to make target 'target/zxn/obj/zxn/bifrost2_engine_48.bin.zx0'
```

This is a missing asset in z88dk's ZX Next target — unrelated to CPC development.
The current `setup.sh` builds z88dk with `-k` (keep going past errors), so the CPC
libraries finish building before ZXN fails and the error is ignored. If you hit this
with an older version of the script, remove the partial build and re-run:

```bash
rm -rf ~/.cpc-dev/z88dk
./setup.sh
```

---

## Contributing

Feel free to use this, copy it, hack it, break it, fix it - do whatever you
want with it. I hope it saves you some time getting started on CPC.

Bug reports, ideas, and notes about what you built with it are all welcome.

pawel.jelonek [at] gmail [dot] com

---

## Links

- [CPC Wiki - Programming](https://www.cpcwiki.eu/index.php/Programming)
- [Z80 Instruction Set](https://www.cpcwiki.eu/index.php/Z80)
- [CPC Memory Map](https://www.cpcwiki.eu/index.php/CPC_464_Memory_Map)
- [Gate Array / CRTC Reference](https://www.grimware.org/doku.php/documentations/devices/crtc)
- [Firmware Reference](https://www.cpcwiki.eu/index.php/Firmware)
- [CPCtelera Documentation](https://lronaldo.github.io/cpctelera/)
- [Arkos Tracker 2](https://www.julien-nevo.com/arkostracker/)
- [CPC Power - games & demos](https://www.cpc-power.com/)

---

## License

MIT - see [LICENSE](LICENSE)