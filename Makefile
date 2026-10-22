CC ?= gcc
CFLAGS := -g -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer -Wall
SRC := src/main.c
B := build
ASMFLAGS := -S -masm=intel -fno-asynchronous-unwind-tables

all: $(B)/prog_O0 $(B)/prog_O3 $(B)/prog_avx2 asm

$(B):
	mkdir -p $(B) asm

$(B)/prog_O0: $(SRC) | $(B)
	$(CC) $(CFLAGS) -O0 $< -o $@

$(B)/prog_O3: $(SRC) | $(B)
	$(CC) $(CFLAGS) -O3 $< -o $@

$(B)/prog_avx2: $(SRC) | $(B)
	$(CC) $(CFLAGS) -O3 -mavx2 -mfma $< -o $@

# асемблер + звіт векторизатора
asm: | $(B)
	$(CC) -O0 $(ASMFLAGS) $(SRC) -o asm/main_O0.s
	$(CC) -O3 $(ASMFLAGS) $(SRC) -o asm/main_O3.s
	$(CC) -O3 -mavx2 -mfma $(ASMFLAGS) $(SRC) -o asm/main_avx2.s
	$(CC) -O3 -mavx2 -mfma -fopt-info-vec-optimized -c $(SRC) -o /dev/null 2> asm/vectorizer_report.txt

clean:
	rm -rf $(B) asm

.PHONY: all asm clean
