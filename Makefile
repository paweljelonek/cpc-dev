# =============================================================================
# Makefile for Amstrad CPC — Rasm Assembler / z88dk C Compiler
#
# Tryb PROJECT (projekty z katalogu CPC_PROJECTS):
#   make PROJECT=name          — asembluj projekt
#   make run PROJECT=name      — asembluj i uruchom w Caprice32
#   make debug PROJECT=name    — uruchom z debuggerem Caprice32
#   make clean PROJECT=name    — usuń artefakty
#   make list                  — wylistuj dostępne projekty
#
# Tryb DIR (dowolny katalog lokalny):
#   make DIR=examples/asm/01-hello
#   make run DIR=examples/asm/01-hello
#   make clean DIR=examples/asm/01-hello
# =============================================================================

RASM    = rasm
CAP32   = cap32

-include .env

# ---------------------------------------------------------------------------
# Rozwiązanie ścieżki projektu — PROJECT lub DIR
# ---------------------------------------------------------------------------
ifdef DIR
  PROJ_DIR := $(DIR)
else ifdef PROJECT
  PROJ_DIR := $(CPC_PROJECTS)/$(PROJECT)
else
  PROJ_DIR :=
endif

SRC      = $(PROJ_DIR)/main.asm
DSK      = $(PROJ_DIR)/main.dsk
BIN      = $(PROJ_DIR)/main.bin
SYM      = $(PROJ_DIR)/main.sym

.PHONY: all run debug clean list _require_dir

_require_dir:
	@test -n "$(PROJ_DIR)" || \
	  (echo "ERROR: podaj PROJECT=name lub DIR=sciezka" && exit 1)
	@test -d "$(PROJ_DIR)" || \
	  (echo "ERROR: katalog '$(PROJ_DIR)' nie istnieje" && exit 1)

all: _require_dir $(DSK)

$(BIN): $(SRC)
	@test -f $(SRC) || (echo "ERROR: $(SRC) nie znaleziono" && exit 1)
	$(RASM) $< -o $(BIN) -s $(SYM) -eq
	@echo ">>> Built: $(BIN) ($$(wc -c < $(BIN)) bytes)"

$(DSK): $(BIN)
	iDSK $(DSK) -n
	iDSK $(DSK) -i $(BIN) -t 1
	@echo ">>> DSK image: $(DSK)"

run: _require_dir $(DSK)
	$(CAP32) $(DSK) &

debug: _require_dir $(DSK)
	$(CAP32) $(DSK) -d &

clean: _require_dir
	rm -f $(PROJ_DIR)/*.bin $(PROJ_DIR)/*.dsk $(PROJ_DIR)/*.sym $(PROJ_DIR)/*.o

list:
	@echo "Available projects ($(CPC_PROJECTS)):"
	@ls -1d $(CPC_PROJECTS)/*/ 2>/dev/null | xargs -I{} basename {} || \
	  echo "  (katalog nie znaleziony)"
