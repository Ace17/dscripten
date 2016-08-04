BIN?=bin
EXT?=exe

CFLAGS?="-Iapi/native"

all: $(BIN)/full.$(EXT)

clean:
	rm -rf $(BIN)

$(BIN)/full.$(EXT): $(BIN)/full.bc
	@mkdir -p $(dir $@)
	$(CC) -O3 -w $^ -o "$@" -lSDL -lSDL_gfx

$(BIN)/%.bc: %.d
	@mkdir -p $(dir $@)
	ldc2 $(CFLAGS) -boundscheck=off -Isrc $< -c -output-bc -of$@

$(BIN)/full.bc: \
	$(BIN)/src/main.bc \
	$(BIN)/src/game.bc \
	$(BIN)/src/vec.bc \
	$(BIN)/src/minirt.bc
	@mkdir -p $(dir $@)
	llvm-link -o "$@" $^

