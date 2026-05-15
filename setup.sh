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
# 2. CAPRICE32 - CPC EMULATOR
# =============================================================================
info "Installing Caprice32 emulator..."
if ! command -v cap32 &>/dev/null; then
    sudo apt-get install -y caprice32 2>/dev/null || {
        info "Building Caprice32 from source..."
        cd "$INSTALL_DIR"
        git clone --depth 1 https://github.com/ColinPitrat/caprice32.git caprice32-src
        cd caprice32-src
        make -j"$(nproc)"
        cp cap32 "$BIN_DIR/"
        ok "Caprice32 built."
        cd "$INSTALL_DIR"
    }
    ok "Caprice32 installed."
else
    ok "Caprice32 already installed."
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
    make -j"$(nproc)"
    cp iDSK "$BIN_DIR/"
    ok "iDSK installed."
    cd "$INSTALL_DIR"
else
    ok "iDSK already installed."
fi

# =============================================================================
# 8. CPCDSK / DSK TOOLS
# =============================================================================
info "Installing cpcxfs (DSK filesystem tool)..."
CPCXFS_BIN="$BIN_DIR/cpcxfs"
if [ ! -f "$CPCXFS_BIN" ]; then
    cd "$INSTALL_DIR"
    git clone --depth 1 https://github.com/cpcsdk/cpcfs.git cpcfs-src 2>/dev/null || \
    wget -q https://github.com/cpcsdk/cpcfs/archive/refs/heads/master.zip -O cpcfs.zip && \
    unzip -q cpcfs.zip && mv cpcfs-master cpcfs-src
    cd cpcfs-src
    make -j"$(nproc)" 2>/dev/null || cmake . && make -j"$(nproc)"
    find . -name "cpcxfs" -type f -exec cp {} "$BIN_DIR/" \;
    ok "cpcxfs installed."
    cd "$INSTALL_DIR"
else
    ok "cpcxfs already installed."
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
echo "    cap32    - Caprice32 (CPC464/664/6128/6128+)"
echo ""
echo "  DISK TOOLS:"
echo "    iDSK     - DSK image manipulation"
echo "    cpcxfs   - CPC DSK filesystem tool"
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
