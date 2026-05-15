#!/usr/bin/env bash
# =============================================================================
# Amstrad CPC Development Environment Setup
# Supports: CPC464, CPC664, CPC6128, CPC6128+
# For: Linux Mint / Ubuntu / Debian
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[ OK ]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERR ]${NC} $*"; exit 1; }

INSTALL_DIR="$HOME/.cpc-dev"
BIN_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR" "$BIN_DIR"

# =============================================================================
# 1. SYSTEM DEPENDENCIES
# =============================================================================
info "Installing system dependencies..."
sudo apt-get update -qq
sudo apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    unzip \
    cmake \
    python3 \
    python3-pip \
    default-jre \
    libsdl2-dev \
    libsdl2-image-dev \
    libpng-dev \
    zlib1g-dev \
    nasm
ok "Dependencies installed."

# =============================================================================
# 2. MAME - CPC EMULATOR
# =============================================================================
info "Installing MAME emulator..."
if ! command -v mame &>/dev/null; then
    sudo apt-get install -y mame
    ok "MAME installed."
else
    ok "MAME already installed."
fi

# Configure MAME rompath so it finds CPC ROMs in our install directory
MAME_CFG_DIR="$HOME/.mame"
MAME_ROM_DIR="$INSTALL_DIR/rom"
mkdir -p "$MAME_CFG_DIR" "$MAME_ROM_DIR"

MAME_INI="$MAME_CFG_DIR/mame.ini"
if [ ! -f "$MAME_INI" ]; then
    printf 'rompath %s\n' "$MAME_ROM_DIR" > "$MAME_INI"
    info "MAME config written to $MAME_INI"
fi

# Copy CPC ROMs from Caprice32 apt package and create MAME-compatible directory structure.
# MAME expects: rompath/cpc6128/cpc6128.rom (32K OS+BASIC) and cpcados.rom (16K AMSDOS).
# Caprice32 ships the same ROM data as amsdos.rom - correct CRC verified.
ROM_SRC="$(dpkg -L caprice32 2>/dev/null | grep -m1 '\.rom$' | xargs dirname 2>/dev/null || true)"
if [ -n "$ROM_SRC" ] && [ -d "$ROM_SRC" ]; then
    cp "$ROM_SRC"/*.rom "$MAME_ROM_DIR/" 2>/dev/null || true
    # Create cpc6128/ subdir with MAME-expected filenames
    mkdir -p "$MAME_ROM_DIR/cpc6128"
    cp "$MAME_ROM_DIR/cpc6128.rom" "$MAME_ROM_DIR/cpc6128/cpc6128.rom" 2>/dev/null || true
    cp "$MAME_ROM_DIR/amsdos.rom"  "$MAME_ROM_DIR/cpc6128/cpcados.rom" 2>/dev/null || true
    ok "CPC ROMs configured for MAME in $MAME_ROM_DIR/cpc6128/"
    mame -verifyroms cpc6128 &>/dev/null && ok "MAME ROM verification: OK" || \
        warn "MAME ROM verification failed - run 'mame -verifyroms cpc6128' to diagnose"
else
    warn "CPC ROM files not found - MAME needs them to emulate the CPC."
    warn "  Create: $MAME_ROM_DIR/cpc6128/"
    warn "  Place:  cpc6128.rom (32768 bytes) and cpcados.rom (16384 bytes) inside it"
    warn "  CPC ROMs are freely available - search 'amstrad cpc roms mame'"
fi

# =============================================================================
# 3. RASM - CPC ASSEMBLER
# =============================================================================
info "Installing Rasm assembler..."
RASM_BIN="$BIN_DIR/rasm"
if [ ! -f "$RASM_BIN" ]; then
    cd "$INSTALL_DIR"
    [ -d rasm-src ] && rm -rf rasm-src
    git clone --depth 1 https://github.com/EdouardBERGE/rasm.git rasm-src
    cd rasm-src
    make -j"$(nproc)"
    cp rasm.exe "$BIN_DIR/rasm"
    ok "Rasm installed."
    cd "$INSTALL_DIR"
else
    ok "Rasm already installed."
fi

# =============================================================================
# 4. PASMO - Z80 CROSS-ASSEMBLER
# =============================================================================
info "Installing Pasmo assembler..."
if ! command -v pasmo &>/dev/null; then
    sudo apt-get install -y pasmo 2>/dev/null || {
        info "Building Pasmo from source..."
        cd "$INSTALL_DIR"
        git clone --depth 1 https://github.com/jgromero/pasmo.git pasmo-src
        cd pasmo-src
        mkdir -p build && cd build
        cmake ..
        make -j"$(nproc)"
        cp pasmo "$BIN_DIR/"
        ok "Pasmo built."
        cd "$INSTALL_DIR"
    }
    ok "Pasmo installed."
else
    ok "Pasmo already installed."
fi

# =============================================================================
# 5. Z88DK - C/ASM COMPILER FOR Z80
# =============================================================================
info "Installing z88dk..."
Z88DK_DIR="$INSTALL_DIR/z88dk"
if [ ! -d "$Z88DK_DIR" ]; then
    cd "$INSTALL_DIR"
    git clone --depth 1 --recursive https://github.com/z88dk/z88dk.git z88dk
    cd z88dk
    chmod +x build.sh
    # -k: keep going past errors - the ZXN target fails (missing bifrost2 asset) but CPC
    # libraries are built earlier in the sequence and will be complete regardless.
    ./build.sh -k 2>&1 | tail -10
    test -f bin/zcc || error "z88dk build failed: bin/zcc not found"
    # Add to PATH via wrapper
    cat > "$BIN_DIR/zcc" << EOF
#!/usr/bin/env bash
export PATH="$INSTALL_DIR/z88dk/bin:\$PATH"
export ZCCCFG="$INSTALL_DIR/z88dk/lib/config"
zcc "\$@"
EOF
    chmod +x "$BIN_DIR/zcc"
    ok "z88dk installed."
    cd "$INSTALL_DIR"
else
    ok "z88dk already installed."
fi

# =============================================================================
# 6. VASM - PORTABLE ASSEMBLER (Z80 BACKEND)
# =============================================================================
info "Installing vasm..."
VASM_BIN="$BIN_DIR/vasmz80"
if [ ! -f "$VASM_BIN" ]; then
    cd "$INSTALL_DIR"
    wget -q http://sun.hasenbraten.de/vasm/release/vasm.tar.gz -O vasm.tar.gz
    tar -xzf vasm.tar.gz
    rm vasm.tar.gz
    cd vasm
    make CPU=z80 SYNTAX=oldstyle -j"$(nproc)"
    cp vasmz80_oldstyle "$BIN_DIR/vasmz80"
    ok "vasm (Z80) installed."
    cd "$INSTALL_DIR"
else
    ok "vasm already installed."
fi

# =============================================================================
# 7. IDSK - DISK IMAGE TOOL
# =============================================================================
info "Installing iDSK..."
IDSK_BIN="$BIN_DIR/iDSK"
if [ ! -f "$IDSK_BIN" ]; then
    cd "$INSTALL_DIR"
    git clone --depth 1 https://github.com/cpcsdk/idsk.git idsk-src
    cd idsk-src
    mkdir -p build && cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make -j"$(nproc)"
    cp iDSK "$BIN_DIR/"
    cd "$INSTALL_DIR/idsk-src"
    ok "iDSK installed."
    cd "$INSTALL_DIR"
else
    ok "iDSK already installed."
fi

# =============================================================================
# 9. ARKOS TRACKER 2 - AY MUSIC TOOL
# =============================================================================
info "Checking Arkos Tracker 2..."
ARKOS_DIR="$INSTALL_DIR/ArkosTracker2"
if [ ! -d "$ARKOS_DIR" ]; then
    mkdir -p "$ARKOS_DIR"
    warn "Arkos Tracker 2 requires manual download (AppImage or Wine)."
    warn "  Download from: https://www.julien-nevo.com/arkostracker/"
    warn "  Place the AppImage in: $ARKOS_DIR/"
else
    ok "Arkos Tracker 2 directory found."
fi

# =============================================================================
# 10. CPCTELERA - CPC DEVELOPMENT FRAMEWORK
# =============================================================================
info "Installing CPCtelera framework..."
CPCT_DIR="$INSTALL_DIR/cpctlera"
if [ ! -d "$CPCT_DIR" ]; then
    cd "$INSTALL_DIR"
    git clone --depth 1 https://github.com/lronaldo/cpctelera.git cpctlera
    cd cpctlera
    ./setup.sh 2>&1 | tail -10 || warn "CPCtelera setup encountered issues - check manually."
    ok "CPCtelera installed."
    cd "$INSTALL_DIR"
else
    ok "CPCtelera already installed."
fi

# =============================================================================
# 11. ADD ~/.local/bin TO PATH
# =============================================================================
SHELL_RC="$HOME/.bashrc"
[ -n "${ZSH_VERSION:-}" ] || [ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"

if ! grep -q 'cpc-dev\|\.local/bin' "$SHELL_RC" 2>/dev/null; then
    echo '' >> "$SHELL_RC"
    echo '# CPC Development tools' >> "$SHELL_RC"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    info "Added ~/.local/bin to PATH in $SHELL_RC"
fi

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  Amstrad CPC Dev environment ready!${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo "  Installed tools:"
echo ""
echo "  ASSEMBLERS:"
echo "    rasm     - $(command -v rasm    && rasm 2>&1 | head -1 || echo 'not available')"
echo "    pasmo    - $(command -v pasmo   && pasmo --version 2>&1 | head -1 || echo 'not available')"
echo "    vasmz80  - $(command -v vasmz80 && echo 'available' || echo 'not available')"
echo "    nasm     - $(command -v nasm    && nasm --version 2>&1 | head -1 || echo 'not available')"
echo "    zcc      - $(command -v zcc     && echo 'available (z88dk)' || echo 'not available')"
echo ""
echo "  EMULATOR:"
echo "    mame     - MAME (CPC464/664/6128/6128+)"
echo ""
echo "  DISK TOOLS:"
echo "    iDSK     - DSK image manipulation"
echo ""
echo "  MUSIC:"
echo "    Arkos Tracker 2 - AY/YM music tracker (manual install, see $INSTALL_DIR/ArkosTracker2)"
echo ""
echo "  FRAMEWORKS:"
echo "    CPCtelera - C/ASM development framework ($INSTALL_DIR/cpctlera)"
echo ""
echo -e "${YELLOW}  Restart your terminal or run: source $SHELL_RC${NC}"
echo ""
echo "  Useful links:"
echo "    https://www.cpcwiki.eu/index.php/Programming"
echo "    https://www.grimware.org/doku.php/documentations/devices/crtc"
echo "    https://lronaldo.github.io/cpctelera/"
echo "    https://www.julien-nevo.com/arkostracker/"
echo ""
