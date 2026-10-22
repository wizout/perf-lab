/*
 * perf-lab: навчальна програма для профілювання.
 *
 * Три обчислювальні етапи з різним характером навантаження:
 *   1) matmul      — множення матриць float (N x N), порядок i-k-j:
 *                    внутрішній цикл послідовно йде по пам'яті й добре векторизується;
 *   2) saxpy_loop  — y = a*x + y над великим масивом (обмежене пропускною здатністю пам'яті);
 *   3) histogram   — гістограма байтів (розгалуження/залежності, погано векторизується).
 * Плюс init_data — генерація даних (LCG), щоб етап ініціалізації теж був видно на графіку.
 *
 * Функції позначені noinline, щоб кожен етап лишався окремим кадром на FlameGraph
 * навіть при -O3 (інакше компілятор вбудує їх у main).
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>

#define NOINLINE __attribute__((noinline))

#ifndef N
#define N 2048           /* розмір матриць */
#endif
#ifndef VEC_LEN
#define VEC_LEN (1u << 22) /* 4M float = 16 MB на масив */
#endif
#ifndef SAXPY_REPS
#define SAXPY_REPS 400
#endif
#ifndef HIST_BYTES
#define HIST_BYTES (1u << 26) /* 64 MB */
#endif

static uint32_t rng_state = 12345u;

static inline uint32_t lcg(void) {
    rng_state = rng_state * 1664525u + 1013904223u;
    return rng_state;
}

NOINLINE void init_data(float *a, float *b, size_t n2, float *x, float *y, size_t len,
                        uint8_t *bytes, size_t nbytes) {
    for (size_t i = 0; i < n2; i++) {
        a[i] = (float)(lcg() & 0xFFFF) / 65536.0f;
        b[i] = (float)(lcg() & 0xFFFF) / 65536.0f;
    }
    for (size_t i = 0; i < len; i++) {
        x[i] = (float)(lcg() & 0xFF) / 256.0f;
        y[i] = 0.0f;
    }
    for (size_t i = 0; i < nbytes; i++)
        bytes[i] = (uint8_t)(lcg() >> 24);
}

/* C = A * B, порядок i-k-j: c[i][j] += a[i][k] * b[k][j] */
NOINLINE void matmul(const float *restrict a, const float *restrict b, float *restrict c, int n) {
    memset(c, 0, sizeof(float) * (size_t)n * n);
    for (int i = 0; i < n; i++)
        for (int k = 0; k < n; k++) {
            float aik = a[i * n + k];
            for (int j = 0; j < n; j++)
                c[i * n + j] += aik * b[k * n + j];
        }
}

/* y = alpha * x + y */
NOINLINE void saxpy(float alpha, const float *restrict x, float *restrict y, size_t len) {
    for (size_t i = 0; i < len; i++)
        y[i] = alpha * x[i] + y[i];
}

NOINLINE void saxpy_loop(const float *x, float *y, size_t len, int reps) {
    for (int r = 0; r < reps; r++)
        saxpy(0.5f + (float)r * 1e-3f, x, y, len);
}

NOINLINE void histogram(const uint8_t *bytes, size_t nbytes, uint64_t hist[256]) {
    memset(hist, 0, 256 * sizeof(uint64_t));
    for (size_t i = 0; i < nbytes; i++)
        hist[bytes[i]]++;
}

static double now_sec(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec * 1e-9;
}

int main(void) {
    size_t n2 = (size_t)N * N;
    float *a = malloc(n2 * sizeof(float));
    float *b = malloc(n2 * sizeof(float));
    float *c = malloc(n2 * sizeof(float));
    float *x = malloc(VEC_LEN * sizeof(float));
    float *y = malloc(VEC_LEN * sizeof(float));
    uint8_t *bytes = malloc(HIST_BYTES);
    uint64_t hist[256];
    if (!a || !b || !c || !x || !y || !bytes) {
        fprintf(stderr, "out of memory\n");
        return 1;
    }

    double t0 = now_sec();
    init_data(a, b, n2, x, y, VEC_LEN, bytes, HIST_BYTES);
    double t1 = now_sec();
    matmul(a, b, c, N);
    double t2 = now_sec();
    saxpy_loop(x, y, VEC_LEN, SAXPY_REPS);
    double t3 = now_sec();
    histogram(bytes, HIST_BYTES, hist);
    double t4 = now_sec();

    /* контрольні суми, щоб компілятор не викинув обчислення */
    double cs_c = 0, cs_y = 0;
    for (size_t i = 0; i < n2; i += 97) cs_c += c[i];
    for (size_t i = 0; i < VEC_LEN; i += 997) cs_y += y[i];
    uint64_t cs_h = 0;
    for (int i = 0; i < 256; i++) cs_h += hist[i] * (uint64_t)(i + 1);

    printf("init      %8.3f s\n", t1 - t0);
    printf("matmul    %8.3f s\n", t2 - t1);
    printf("saxpy     %8.3f s\n", t3 - t2);
    printf("histogram %8.3f s\n", t4 - t3);
    printf("total     %8.3f s\n", t4 - t0);
    printf("checksum  c=%.4f y=%.4f h=%llu\n", cs_c, cs_y, (unsigned long long)cs_h);

    free(a); free(b); free(c); free(x); free(y); free(bytes);
    return 0;
}
