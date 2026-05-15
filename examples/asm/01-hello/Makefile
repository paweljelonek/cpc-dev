RASM  = rasm
MAME  = mame
IDSK  = iDSK

SRC = main.asm
BIN = main.bin
DSK = main.dsk
SYM = main.sym

.PHONY: all run clean

all: $(DSK)

$(BIN): $(SRC)
	$(RASM) $(SRC) -ob $(BIN) -amper -sw $(SYM:.sym=)
	@echo ">>> Built: $(BIN) ($$(wc -c < $(BIN)) bytes)"

$(DSK): $(BIN)
	$(IDSK) $(DSK) -n
	$(IDSK) $(DSK) -i $(BIN) -t 1 -c 8000 -e 8000
	@echo ">>> DSK: $(DSK)"

run: $(DSK)
	$(MAME) cpc6128 -window -skip_gameinfo -flop1 $(abspath $(DSK)) -autoboot_delay 3 -autoboot_command '|disc\nMEMORY &7FFF\nLOAD "MAIN.BIN",&8000\nCALL &8000\n' &

clean:
	rm -f $(BIN) $(DSK) $(SYM)
