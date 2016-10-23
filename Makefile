BIN?=bin
EXT?=exe

DFLAGS?="-Iapi/native"

all: $(BIN)/full.$(EXT) $(BIN)/test-full.$(EXT)

clean:
	rm -rf $(BIN)

$(BIN)/%.$(EXT): $(BIN)/%.cbe.c rt/runtime.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(LDFLAGS) -w $^ -o "$@" -lSDL -lSDL_gfx

$(BIN)/%.bc: %.d
	@mkdir -p $(dir $@)
	ldc2 $(DFLAGS) -release -boundscheck=off -Isrc -Irt $< -c -output-bc -of$@

$(BIN)/test-full.bc: \
	$(BIN)/rt/test.bc \
	$(BIN)/rt/standard.bc \
	$(BIN)/rt/object.bc
	@mkdir -p $(dir $@)
	llvm-link -o "$@" $^

$(BIN)/full.bc: \
	$(BIN)/src/main.bc \
	$(BIN)/src/game.bc \
	$(BIN)/src/vec.bc \
	$(BIN)/rt/standard.bc \
	$(BIN)/rt/object.bc
	@mkdir -p $(dir $@)
	llvm-link -o "$@" $^

$(BIN)/%.cbe.c: $(BIN)/%.bc
	@mkdir -p $(dir $@)
	llvm-dis "$<" -o="$(BIN)/$*.ll"
	llvm-cbe "$(BIN)/$*.ll" -o="$@"
	@sed -i 's/^#include <APInt-C\.h>//' "$@"

