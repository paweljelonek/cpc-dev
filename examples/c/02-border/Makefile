ZCC   = zcc
CAP32 = cap32
IDSK  = iDSK

SRC  = main.c
BIN  = main.bin
DSK  = main.dsk
NAME = main

.PHONY: all run clean

all: $(DSK)

$(BIN): $(SRC)
	$(ZCC) +cpc -lndos -create-app -o $(NAME) $(SRC)
	@echo ">>> Built: $(BIN)"

$(DSK): $(BIN)
	$(IDSK) $(DSK) -n
	$(IDSK) $(DSK) -i $(BIN) -t 1
	@echo ">>> DSK: $(DSK)"

run: $(DSK)
	$(CAP32) $(DSK) &

clean:
	rm -f $(BIN) $(DSK) *.o *.lis $(NAME)
