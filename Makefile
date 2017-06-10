BIN?=bin
EXT?=exe

DFLAGS?="-Iapi/native"
LINK?=clang

all: \
	$(BIN)/game.$(EXT) \
	$(BIN)/tests.$(EXT) \

$(BIN)/tests.$(EXT): \
	$(BIN)/rt/test.bc \
	$(BIN)/rt/runtime.bc \
	$(BIN)/rt/standard.bc \
	$(BIN)/rt/object.bc

$(BIN)/game.$(EXT): \
	$(BIN)/src/main.bc \
	$(BIN)/src/game.bc \
	$(BIN)/src/vec.bc \
	$(BIN)/rt/runtime.bc \
	$(BIN)/rt/mainloop.bc \
	$(BIN)/rt/standard.bc \
	$(BIN)/rt/object.bc

#------------------------------------------------------------------------------
# Generic rules
#------------------------------------------------------------------------------

clean:
	rm -rf $(BIN)

$(BIN)/%.bc: %.d
	@mkdir -p $(dir $@)
	ldc2 $(DFLAGS) -release -boundscheck=off -Isrc -Irt $< -c -output-bc -of$@

$(BIN)/%.bc: %.c
	@mkdir -p $(dir $@)
	clang $(CFLAGS) $< -c -S -emit-llvm -o "$@.llvm"
	llvm-as "$@.llvm" -o="$@"

$(BIN)/%.$(EXT):
	@mkdir -p $(dir $@)
	llvm-link $^ -o="$@.bc"
	$(LINK) $(CFLAGS) $(LDFLAGS) -w "$@.bc" -o "$@" -lSDL -lSDL_gfx

