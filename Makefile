# Збірки для порівняння:
#   prog_O0   — без оптимізацій (базова версія "до")
#   prog_O3   — -O3, лише базовий SSE2 (128-біт xmm)
#   prog_avx2 — -O3 -mavx2 -mfma (256-біт ymm, FMA) — версія "після"
CC      ?= gcc
COMMON  := -g -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer -Wall
SRC     := src/main.c
B       := build

all: $(B)/prog_O0 $(B)/prog_O3 $(B)/prog_avx2 asm

$(B):
	mkdir -p $(B) asm

$(B)/prog_O0: $(SRC) | $(B)
	$(CC) $(COMMON) -O0 $< -o $@

$(B)/prog_O3: $(SRC) | $(B)
	$(CC) $(COMMON) -O3 $< -o $@

$(B)/prog_avx2: $(SRC) | $(B)
	$(CC) $(COMMON) -O3 -mavx2 -mfma $< -o $@

# Асемблер (Intel-синтаксис) + звіт векторизатора
asm: | $(B)
	$(CC) -O0 -S -masm=intel -fno-asynchronous-unwind-tables $(SRC) -o asm/main_O0.s
	$(CC) -O3 -S -masm=intel -fno-asynchronous-unwind-tables $(SRC) -o asm/main_O3.s
	$(CC) -O3 -mavx2 -mfma -S -masm=intel -fno-asynchronous-unwind-tables $(SRC) -o asm/main_avx2.s
	$(CC) -O3 -mavx2 -mfma -fopt-info-vec-optimized -c $(SRC) -o /dev/null 2> asm/vectorizer_report.txt

clean:
	rm -rf $(B) asm

.PHONY: all asm clean
