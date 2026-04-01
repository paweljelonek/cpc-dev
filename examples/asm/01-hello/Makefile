RASM  = rasm
CAP32 = cap32
IDSK  = iDSK

SRC = main.asm
BIN = main.bin
DSK = main.dsk
SYM = main.sym

.PHONY: all run clean

all: $(DSK)

$(BIN): $(SRC)
	$(RASM) $(SRC) -o $(BIN) -s $(SYM) -eq
	@echo ">>> Built: $(BIN) ($$(wc -c < $(BIN)) bytes)"

$(DSK): $(BIN)
	$(IDSK) $(DSK) -n
	$(IDSK) $(DSK) -i $(BIN) -t 1
	@echo ">>> DSK: $(DSK)"

run: $(DSK)
	$(CAP32) $(DSK) &

clean:
	rm -f $(BIN) $(DSK) $(SYM)
