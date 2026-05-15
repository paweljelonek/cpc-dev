# =============================================================================
# Makefile for Amstrad CPC - Rasm Assembler / z88dk C Compiler
#
# Tryb PROJECT (projekty z katalogu CPC_PROJECTS):
#   make PROJECT=name          - asembluj projekt
#   make run PROJECT=name      - asembluj i uruchom w Caprice32
#   make debug PROJECT=name    - uruchom z debuggerem Caprice32
#   make clean PROJECT=name    - usuń artefakty
#   make list                  - wylistuj dostępne projekty
#
# Tryb DIR (dowolny katalog lokalny):
#   make DIR=examples/asm/01-hello
#   make run DIR=examples/asm/01-hello
#   make clean DIR=examples/asm/01-hello
# =============================================================================

RASM    = rasm
CAP32   = cap32

-include .env

# CPC model: accept MODEL= on command line, fall back to CPC_MODEL from .env, then 6128
_MODEL := $(or $(MODEL),$(CPC_MODEL),6128)
_MODEL_NUM := $(if $(filter 464,$(_MODEL)),0,$(if $(filter 664,$(_MODEL)),1,$(if $(filter 6128p,$(_MODEL)),3,2)))
_MODEL_FLAG = -O system.model=$(_MODEL_NUM)

# ---------------------------------------------------------------------------
# Rozwiązanie ścieżki projektu - PROJECT lub DIR
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

.PHONY: all run debug clean list help _require_dir

help:
	@_bold=$$(tput bold 2>/dev/null);   \
	 _cyan=$$(tput setaf 6 2>/dev/null); \
	 _yel=$$(tput setaf 3 2>/dev/null);  \
	 _dim=$$(tput dim   2>/dev/null);    \
	 _r=$$(tput sgr0    2>/dev/null);    \
	 echo "$${_bold}Amstrad CPC development environment$${_r}"; \
	 echo ""; \
	 echo "$${_cyan}Usage:$${_r}"; \
	 echo "  $${_yel}make [all]  PROJECT=name$${_r}   - assemble project from CPC_PROJECTS"; \
	 echo "  $${_yel}make run    PROJECT=name$${_r}   - assemble and launch in Caprice32"; \
	 echo "  $${_yel}make debug  PROJECT=name$${_r}   - assemble and launch with debugger"; \
	 echo "  $${_yel}make clean  PROJECT=name$${_r}   - remove build artifacts"; \
	 echo ""; \
	 echo "  $${_yel}make [all]  DIR=path$${_r}       - assemble from any local directory"; \
	 echo "  $${_yel}make run    DIR=path$${_r}       - assemble and launch from local directory"; \
	 echo "  $${_yel}make clean  DIR=path$${_r}       - remove build artifacts"; \
	 echo ""; \
	 echo "  $${_yel}make run    PROJECT=name MODEL=464$${_r}  - run on specific model"; \
	 echo ""; \
	 echo "  $${_yel}make list$${_r}                  - list projects in CPC_PROJECTS"; \
	 echo "  $${_yel}make help$${_r}                  - show this help"; \
	 echo ""; \
	 echo "$${_cyan}CPC_PROJECTS$${_r} = $${_dim}$(CPC_PROJECTS)$${_r}"; \
	 echo "$${_cyan}CPC_MODEL$${_r}    = $${_dim}$(_MODEL)$${_r}  (464 / 664 / 6128 / 6128p)"

_require_dir:
	@test -n "$(PROJ_DIR)" || \
	  (echo "ERROR: specify PROJECT=name or DIR=path" && exit 1)
ifdef PROJECT
	@test -n "$(CPC_PROJECTS)" || \
	  (echo "ERROR: CPC_PROJECTS is not set — copy .env.dist to .env and set CPC_PROJECTS" && exit 1)
endif
	@test -d "$(PROJ_DIR)" || \
	  (echo "ERROR: directory '$(PROJ_DIR)' does not exist" && exit 1)

all: $(if $(PROJ_DIR),_require_dir $(DSK),help)

$(BIN): $(SRC)
	@test -f $(SRC) || (echo "ERROR: $(SRC) nie znaleziono" && exit 1)
	$(RASM) $< -o $(BIN) -s $(SYM) -eq
	@echo ">>> Built: $(BIN) ($$(wc -c < $(BIN)) bytes)"

$(DSK): $(BIN)
	iDSK $(DSK) -n
	iDSK $(DSK) -i $(BIN) -t 1
	@echo ">>> DSK image: $(DSK)"

run: _require_dir $(DSK)
	$(CAP32) $(_MODEL_FLAG) $(DSK) &

debug: _require_dir $(DSK)
	$(CAP32) $(_MODEL_FLAG) $(DSK) -d &

clean: _require_dir
	rm -f $(PROJ_DIR)/*.bin $(PROJ_DIR)/*.dsk $(PROJ_DIR)/*.sym $(PROJ_DIR)/*.o

list:
	@echo "Available projects ($(CPC_PROJECTS)):"
	@ls -1d $(CPC_PROJECTS)/*/ 2>/dev/null | xargs -I{} basename {} || \
	  echo "  (katalog nie znaleziony)"
