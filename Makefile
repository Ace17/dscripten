BIN?=bin

all: $(BIN)/full.exe $(BIN)/full.html

clean:
	rm -rf $(BIN)

$(BIN)/full.exe: $(BIN)/full.cbe.c runtime.c
	@mkdir -p $(dir $@)
	gcc -O3 -I. -w $^ -o "$@" -lSDL -lSDL_gfx

$(BIN)/full.html: $(BIN)/full.cbe.c runtime.c
	@mkdir -p $(dir $@)
	emcc -O3 -I. -w $^ -o "$@" -lSDL -lSDL_gfx

$(BIN)/%.bc: %.d
	@mkdir -p $(dir $@)
	ldc2 $< -c -output-bc -of$@

$(BIN)/full.bc: $(BIN)/hello.bc $(BIN)/lib.bc
	@mkdir -p $(dir $@)
	llvm-link -o "$@" $^

$(BIN)/%.cbe.c: $(BIN)/%.bc
	@mkdir -p $(dir $@)
	llvm-dis "$<" -o="$(BIN)/$*.ll"
	llvm-cbe "$(BIN)/$*.ll" -o="$@"

