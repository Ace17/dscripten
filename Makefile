BIN?=bin
EXT?=exe

all: $(BIN)/full.$(EXT)

clean:
	rm -rf $(BIN)

$(BIN)/full.$(EXT): $(BIN)/full.cbe.c rt/runtime.c
	@mkdir -p $(dir $@)
	$(CC) -O3 -w $^ -o "$@" -lSDL -lSDL_gfx

$(BIN)/%.bc: %.d
	@mkdir -p $(dir $@)
	ldc2 -boundscheck=off -Isrc $< -c -output-bc -of$@

$(BIN)/full.bc: $(BIN)/src/main.bc $(BIN)/src/vec.bc $(BIN)/src/minirt.bc
	@mkdir -p $(dir $@)
	llvm-link -o "$@" $^

$(BIN)/%.cbe.c: $(BIN)/%.bc
	@mkdir -p $(dir $@)
	llvm-dis "$<" -o="$(BIN)/$*.ll"
	llvm-cbe "$(BIN)/$*.ll" -o="$@"
	@sed -i 's/^#include <APInt-C\.h>//' "$@"

