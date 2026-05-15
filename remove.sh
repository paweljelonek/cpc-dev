#!/usr/bin/env bash
# =============================================================================
# Amstrad CPC Development Environment - Uninstaller
# Removes everything installed by setup.sh
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

INSTALL_DIR="$HOME/.cpc-dev"
BIN_DIR="$HOME/.local/bin"

echo ""
echo -e "${RED}This will remove all CPC development tools installed by setup.sh.${NC}"
echo ""
echo "  Will remove:"
echo "    $INSTALL_DIR/"
echo "      rasm-src/      - Rasm assembler source"
echo "      pasmo-src/     - Pasmo assembler source (if built from source)"
echo "      z88dk/         - z88dk compiler and toolchain"
echo "      vasm/          - vasm assembler source"
echo "      idsk-src/      - iDSK disk image tool source"
echo "      ArkosTracker2/ - Arkos Tracker 2 directory"
echo "      cpctlera/      - CPCtelera framework"
echo "      rom/           - CPC ROM files"
echo ""
echo "    $BIN_DIR/{rasm,zcc,vasmz80,iDSK}"
echo ""
echo "    ~/.mame/mame.ini - MAME config"
echo ""
echo "    PATH entry from ~/.bashrc and/or ~/.zshrc"
echo ""
echo "  Will NOT remove apt packages:"
echo "    mame, pasmo, nasm, build-essential, libsdl2-dev, ..."
echo "    (use 'sudo apt-get remove <package>' manually if needed)"
echo ""
read -rp "Proceed? [y/N] " ans
[[ "$ans" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
echo ""

# -----------------------------------------------------------------------------
# Binaries from ~/.local/bin
# -----------------------------------------------------------------------------
info "Removing binaries from $BIN_DIR..."
for bin in rasm zcc vasmz80 iDSK; do
    if [ -f "$BIN_DIR/$bin" ]; then
        rm -f "$BIN_DIR/$bin"
        ok "Removed $bin"
    else
        warn "$bin not found in $BIN_DIR, skipping."
    fi
done

# -----------------------------------------------------------------------------
# Source trees and install directory
# -----------------------------------------------------------------------------
if [ -d "$INSTALL_DIR" ]; then
    info "Removing $INSTALL_DIR..."
    rm -rf "$INSTALL_DIR"
    ok "Removed $INSTALL_DIR"
else
    warn "$INSTALL_DIR not found, skipping."
fi

# -----------------------------------------------------------------------------
# MAME config
# -----------------------------------------------------------------------------
MAME_INI="$HOME/.mame/mame.ini"
if [ -f "$MAME_INI" ]; then
    info "Removing MAME config $MAME_INI..."
    rm -f "$MAME_INI"
    ok "Removed $MAME_INI"
fi

# -----------------------------------------------------------------------------
# PATH entry from shell rc files
# -----------------------------------------------------------------------------
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] && grep -q '# CPC Development tools' "$rc"; then
        info "Removing PATH entry from $rc..."
        sed -i '/^# CPC Development tools$/d' "$rc"
        sed -i '/^export PATH="\$HOME\/.local\/bin:\$PATH"$/d' "$rc"
        ok "Removed PATH entry from $rc"
    fi
done

# -----------------------------------------------------------------------------
echo ""
echo -e "${GREEN}Done.${NC} CPC dev tools removed."
echo ""
echo "  Apt packages were left intact."
echo "  Restart your terminal to apply PATH changes."
echo ""
