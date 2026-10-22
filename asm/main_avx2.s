	.file	"main.c"
	.intel_syntax noprefix
	.text
	.p2align 4
	.globl	init_data
	.type	init_data, @function
init_data:
	endbr64
	push	rbx
	vxorps	xmm1, xmm1, xmm1
	mov	r10, QWORD PTR 24[rsp]
	test	rdx, rdx
	je	.L2
	mov	eax, DWORD PTR rng_state[rip]
	vmovss	xmm2, DWORD PTR .LC0[rip]
	xor	r11d, r11d
	.p2align 4,,10
	.p2align 3
.L3:
	imul	eax, eax, 1664525
	add	eax, 1013904223
	movzx	ebx, ax
	imul	eax, eax, 1664525
	vcvtsi2ss	xmm0, xmm1, ebx
	add	eax, 1013904223
	movzx	ebx, ax
	vmulss	xmm0, xmm0, xmm2
	vmovss	DWORD PTR [rdi+r11*4], xmm0
	vcvtsi2ss	xmm0, xmm1, ebx
	vmulss	xmm0, xmm0, xmm2
	vmovss	DWORD PTR [rsi+r11*4], xmm0
	add	r11, 1
	cmp	rdx, r11
	jne	.L3
	mov	DWORD PTR rng_state[rip], eax
.L2:
	test	r9, r9
	je	.L4
	mov	edx, DWORD PTR rng_state[rip]
	vmovss	xmm2, DWORD PTR .LC1[rip]
	xor	eax, eax
	.p2align 4,,10
	.p2align 3
.L5:
	imul	edx, edx, 1664525
	add	edx, 1013904223
	movzx	esi, dl
	vcvtsi2ss	xmm0, xmm1, esi
	mov	rsi, rax
	vmulss	xmm0, xmm0, xmm2
	vmovss	DWORD PTR [rcx+rax*4], xmm0
	mov	DWORD PTR [r8+rax*4], 0x00000000
	add	rax, 1
	cmp	r9, rax
	jne	.L5
	vmovss	DWORD PTR [rcx+rsi*4], xmm0
	mov	DWORD PTR rng_state[rip], edx
	mov	DWORD PTR [r8+rsi*4], 0x00000000
.L4:
	test	r10, r10
	je	.L20
	mov	rdx, QWORD PTR 16[rsp]
	mov	eax, DWORD PTR rng_state[rip]
	add	r10, rdx
	.p2align 4,,10
	.p2align 3
.L7:
	imul	eax, eax, 1664525
	add	rdx, 1
	add	eax, 1013904223
	mov	ecx, eax
	shr	ecx, 24
	mov	BYTE PTR -1[rdx], cl
	cmp	r10, rdx
	jne	.L7
	mov	DWORD PTR rng_state[rip], eax
.L20:
	pop	rbx
	ret
	.size	init_data, .-init_data
	.p2align 4
	.globl	matmul
	.type	matmul, @function
matmul:
	endbr64
	push	rbp
	mov	r11, rdx
	movsx	rdx, ecx
	mov	rbp, rsp
	push	r15
	push	r14
	mov	r14, rdi
	push	r13
	push	r12
	mov	r12, rsi
	xor	esi, esi
	push	rbx
	mov	rbx, rdx
	and	rsp, -32
	sub	rsp, 96
	mov	QWORD PTR 64[rsp], rdx
	imul	rdx, rdx
	mov	QWORD PTR 32[rsp], rdi
	mov	rdi, r11
	sal	rdx, 2
	call	memset@PLT
	test	ebx, ebx
	jle	.L59
	lea	edx, [rbx+rbx]
	lea	esi, -3[rbx]
	mov	r13d, ebx
	xor	r15d, r15d
	mov	DWORD PTR 16[rsp], edx
	movsx	rdx, edx
	and	esi, -2
	xor	ecx, ecx
	mov	QWORD PTR [rsp], rdx
	lea	edx, -1[rbx]
	lea	edi, 3[rsi]
	mov	r11, rax
	mov	DWORD PTR 76[rsp], edx
	mov	edx, ebx
	lea	r8, 0[0+rbx*4]
	mov	esi, ecx
	shr	edx, 3
	mov	QWORD PTR 80[rsp], r14
	and	r13d, -8
	mov	QWORD PTR 88[rsp], 0
	sal	rdx, 5
	mov	DWORD PTR 28[rsp], edi
	mov	r14, rdx
	mov	edi, r15d
	xor	edx, edx
.L25:
	xor	r10d, r10d
	cmp	ebx, 2
	jle	.L41
	lea	ecx, 1[rdx]
	mov	r15, QWORD PTR 80[rsp]
	mov	DWORD PTR 24[rsp], esi
	mov	r10d, ebx
	mov	DWORD PTR 72[rsp], ecx
	mov	ecx, DWORD PTR 28[rsp]
	mov	DWORD PTR 48[rsp], 0
	vmovss	xmm3, DWORD PTR [r15]
	add	ecx, edx
	mov	DWORD PTR 40[rsp], edx
	mov	DWORD PTR 44[rsp], ecx
	xor	ecx, ecx
	cmp	DWORD PTR 76[rsp], 6
	mov	DWORD PTR 20[rsp], edi
	mov	QWORD PTR 56[rsp], rax
	mov	QWORD PTR 8[rsp], r8
	jbe	.L44
.L62:
	movsx	rdx, r10d
	vbroadcastss	ymm1, DWORD PTR 4[r15]
	mov	rax, QWORD PTR 56[rsp]
	lea	rdi, [r12+rcx*4]
	lea	rsi, [r12+rdx*4]
	vbroadcastss	ymm2, xmm3
	xor	edx, edx
	.p2align 4,,10
	.p2align 3
.L38:
	vmovups	ymm0, YMMWORD PTR [rdi+rdx]
	vfmadd213ps	ymm0, ymm2, YMMWORD PTR [rax+rdx]
	vfmadd231ps	ymm0, ymm1, YMMWORD PTR [rsi+rdx]
	vmovups	YMMWORD PTR [rax+rdx], ymm0
	add	rdx, 32
	cmp	rdx, r14
	jne	.L38
	mov	QWORD PTR 56[rsp], rax
	cmp	r13d, ebx
	je	.L26
	mov	edx, r13d
	mov	esi, r13d
.L37:
	mov	r8d, ebx
	sub	r8d, edx
	lea	edi, -1[r8]
	cmp	edi, 2
	jbe	.L27
	mov	rdi, QWORD PTR 88[rsp]
	mov	rax, QWORD PTR 32[rsp]
	vshufps	xmm1, xmm3, xmm3, 0
	add	rdi, rdx
	lea	r9, [r11+rdi*4]
	movsx	rdi, r10d
	add	rdi, rdx
	add	rdx, rcx
	vmovups	xmm6, XMMWORD PTR [r9]
	vfmadd132ps	xmm1, xmm6, XMMWORD PTR [r12+rdx*4]
	movsx	rdx, DWORD PTR 72[rsp]
	vbroadcastss	xmm0, DWORD PTR [rax+rdx*4]
	vfmadd132ps	xmm0, xmm1, XMMWORD PTR [r12+rdi*4]
	mov	edx, r8d
	and	edx, -4
	add	esi, edx
	and	r8d, 3
	vmovups	XMMWORD PTR [r9], xmm0
	je	.L26
.L27:
	mov	eax, DWORD PTR 40[rsp]
	mov	r9d, DWORD PTR 48[rsp]
	vmovss	xmm0, DWORD PTR 4[r15]
	lea	edx, [rax+rsi]
	movsx	rdx, edx
	lea	rdi, [r11+rdx*4]
	lea	edx, [r9+rsi]
	movsx	rdx, edx
	vmovss	xmm1, DWORD PTR [r12+rdx*4]
	lea	edx, [r10+rsi]
	vfmadd213ss	xmm1, xmm3, DWORD PTR [rdi]
	movsx	rdx, edx
	vfmadd231ss	xmm1, xmm0, DWORD PTR [r12+rdx*4]
	lea	edx, 1[rsi]
	vmovss	DWORD PTR [rdi], xmm1
	cmp	ebx, edx
	jle	.L26
	lea	edi, [rax+rdx]
	add	esi, 2
	movsx	rdi, edi
	lea	r8, [r11+rdi*4]
	lea	edi, [r9+rdx]
	add	edx, r10d
	movsx	rdi, edi
	movsx	rdx, edx
	vmovss	xmm1, DWORD PTR [r12+rdi*4]
	vfmadd213ss	xmm1, xmm3, DWORD PTR [r8]
	vfmadd231ss	xmm1, xmm0, DWORD PTR [r12+rdx*4]
	vmovss	DWORD PTR [r8], xmm1
	cmp	ebx, esi
	jle	.L26
	lea	edx, [rax+rsi]
	movsx	rdx, edx
	lea	rdi, [r11+rdx*4]
	lea	edx, [r9+rsi]
	add	esi, r10d
	movsx	rdx, edx
	vmovss	xmm7, DWORD PTR [rdi]
	vfmadd132ss	xmm3, xmm7, DWORD PTR [r12+rdx*4]
	movsx	rdx, esi
	vfmadd132ss	xmm0, xmm3, DWORD PTR [r12+rdx*4]
	vmovss	DWORD PTR [rdi], xmm0
.L26:
	mov	eax, DWORD PTR 16[rsp]
	add	DWORD PTR 48[rsp], eax
	add	r15, 8
	add	r10d, eax
	mov	rax, QWORD PTR [rsp]
	add	rcx, rax
	mov	eax, DWORD PTR 72[rsp]
	lea	edx, 2[rax]
	cmp	DWORD PTR 44[rsp], edx
	je	.L61
	cmp	DWORD PTR 76[rsp], 6
	vmovss	xmm3, DWORD PTR [r15]
	mov	DWORD PTR 72[rsp], edx
	ja	.L62
.L44:
	xor	edx, edx
	xor	esi, esi
	jmp	.L37
.L61:
	mov	edi, DWORD PTR 20[rsp]
	mov	ecx, eax
	mov	esi, DWORD PTR 24[rsp]
	mov	edx, DWORD PTR 40[rsp]
	mov	rax, QWORD PTR 56[rsp]
	mov	r8, QWORD PTR 8[rsp]
	lea	r10d, 1[rdi+rcx]
.L41:
	movsx	r15, r10d
	imul	r10d, ebx
	mov	DWORD PTR 72[rsp], esi
	mov	DWORD PTR 56[rsp], edi
	mov	QWORD PTR 48[rsp], r8
	movsx	r9, r10d
	.p2align 4,,10
	.p2align 3
.L35:
	mov	rdi, QWORD PTR 80[rsp]
	cmp	DWORD PTR 76[rsp], 6
	vmovss	xmm1, DWORD PTR [rdi+r15*4]
	jbe	.L43
	lea	rsi, [r12+r9*4]
	vbroadcastss	ymm2, xmm1
	xor	ecx, ecx
	.p2align 4,,10
	.p2align 3
.L31:
	vmovups	ymm0, YMMWORD PTR [rsi+rcx]
	vfmadd213ps	ymm0, ymm2, YMMWORD PTR [rax+rcx]
	vmovups	YMMWORD PTR [rax+rcx], ymm0
	add	rcx, 32
	cmp	r14, rcx
	jne	.L31
	cmp	r13d, ebx
	je	.L32
	mov	ecx, r13d
	mov	esi, r13d
.L30:
	mov	edi, ebx
	sub	edi, ecx
	lea	r8d, -1[rdi]
	cmp	r8d, 2
	jbe	.L33
	mov	r8, QWORD PTR 88[rsp]
	vshufps	xmm0, xmm1, xmm1, 0
	add	r8, rcx
	add	rcx, r9
	lea	r8, [r11+r8*4]
	vmovups	xmm4, XMMWORD PTR [r8]
	vfmadd132ps	xmm0, xmm4, XMMWORD PTR [r12+rcx*4]
	mov	ecx, edi
	and	ecx, -4
	add	esi, ecx
	and	edi, 3
	vmovups	XMMWORD PTR [r8], xmm0
	je	.L32
.L33:
	lea	ecx, [rdx+rsi]
	movsx	rcx, ecx
	lea	rdi, [r11+rcx*4]
	lea	ecx, [r10+rsi]
	movsx	rcx, ecx
	vmovss	xmm0, DWORD PTR [r12+rcx*4]
	vfmadd213ss	xmm0, xmm1, DWORD PTR [rdi]
	lea	ecx, 1[rsi]
	vmovss	DWORD PTR [rdi], xmm0
	cmp	ebx, ecx
	jle	.L32
	lea	edi, [rdx+rcx]
	add	ecx, r10d
	add	esi, 2
	movsx	rdi, edi
	movsx	rcx, ecx
	lea	rdi, [r11+rdi*4]
	vmovss	xmm0, DWORD PTR [r12+rcx*4]
	vfmadd213ss	xmm0, xmm1, DWORD PTR [rdi]
	vmovss	DWORD PTR [rdi], xmm0
	cmp	ebx, esi
	jle	.L32
	lea	ecx, [rdx+rsi]
	add	esi, r10d
	movsx	rcx, ecx
	movsx	rsi, esi
	lea	rcx, [r11+rcx*4]
	vmovss	xmm5, DWORD PTR [rcx]
	vfmadd132ss	xmm1, xmm5, DWORD PTR [r12+rsi*4]
	vmovss	DWORD PTR [rcx], xmm1
.L32:
	mov	rsi, QWORD PTR 64[rsp]
	add	r15, 1
	add	r10d, ebx
	add	r9, rsi
	cmp	ebx, r15d
	jg	.L35
	mov	r15, rsi
	mov	esi, DWORD PTR 72[rsp]
	mov	r8, QWORD PTR 48[rsp]
	add	edx, ebx
	mov	edi, DWORD PTR 56[rsp]
	add	QWORD PTR 80[rsp], r8
	add	esi, 1
	add	QWORD PTR 88[rsp], r15
	add	rax, r8
	sub	edi, ebx
	cmp	ebx, esi
	jne	.L25
	vzeroupper
.L59:
	lea	rsp, -40[rbp]
	pop	rbx
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	pop	rbp
	ret
	.p2align 4,,10
	.p2align 3
.L43:
	xor	ecx, ecx
	xor	esi, esi
	jmp	.L30
	.size	matmul, .-matmul
	.p2align 4
	.globl	saxpy
	.type	saxpy, @function
saxpy:
	endbr64
	mov	rcx, rsi
	test	rdx, rdx
	je	.L82
	lea	rax, -1[rdx]
	cmp	rax, 6
	jbe	.L70
	mov	rsi, rdx
	vbroadcastss	ymm2, xmm0
	xor	eax, eax
	shr	rsi, 3
	sal	rsi, 5
	.p2align 4,,10
	.p2align 3
.L66:
	vmovups	ymm1, YMMWORD PTR [rdi+rax]
	vfmadd213ps	ymm1, ymm2, YMMWORD PTR [rcx+rax]
	vmovups	YMMWORD PTR [rcx+rax], ymm1
	add	rax, 32
	cmp	rax, rsi
	jne	.L66
	mov	rax, rdx
	and	rax, -8
	test	dl, 7
	je	.L83
	vzeroupper
.L65:
	mov	rsi, rdx
	sub	rsi, rax
	lea	r8, -1[rsi]
	cmp	r8, 2
	jbe	.L68
	lea	r8, [rcx+rax*4]
	vshufps	xmm1, xmm0, xmm0, 0
	vmovups	xmm3, XMMWORD PTR [r8]
	vfmadd132ps	xmm1, xmm3, XMMWORD PTR [rdi+rax*4]
	vmovups	XMMWORD PTR [r8], xmm1
	mov	r8, rsi
	and	r8, -4
	add	rax, r8
	and	esi, 3
	je	.L82
.L68:
	lea	rsi, 0[0+rax*4]
	vmovss	xmm1, DWORD PTR [rdi+rax*4]
	lea	r8, [rcx+rsi]
	vfmadd213ss	xmm1, xmm0, DWORD PTR [r8]
	vmovss	DWORD PTR [r8], xmm1
	lea	r8, 1[rax]
	cmp	r8, rdx
	jnb	.L82
	lea	r8, 4[rcx+rsi]
	vmovss	xmm1, DWORD PTR 4[rdi+rsi]
	add	rax, 2
	vfmadd213ss	xmm1, xmm0, DWORD PTR [r8]
	vmovss	DWORD PTR [r8], xmm1
	cmp	rax, rdx
	jnb	.L82
	lea	rax, 8[rcx+rsi]
	vmovss	xmm4, DWORD PTR [rax]
	vfmadd132ss	xmm0, xmm4, DWORD PTR 8[rdi+rsi]
	vmovss	DWORD PTR [rax], xmm0
.L82:
	ret
	.p2align 4,,10
	.p2align 3
.L83:
	vzeroupper
	ret
.L70:
	xor	eax, eax
	jmp	.L65
	.size	saxpy, .-saxpy
	.p2align 4
	.globl	saxpy_loop
	.type	saxpy_loop, @function
saxpy_loop:
	endbr64
	test	ecx, ecx
	jle	.L90
	sub	rsp, 8
	mov	r11, rsi
	mov	r10d, ecx
	xor	r9d, r9d
	.p2align 4,,10
	.p2align 3
.L86:
	vxorps	xmm1, xmm1, xmm1
	vmovss	xmm2, DWORD PTR .LC4[rip]
	mov	rsi, r11
	vcvtsi2ss	xmm0, xmm1, r9d
	add	r9d, 1
	vfmadd132ss	xmm0, xmm2, DWORD PTR .LC3[rip]
	call	saxpy
	cmp	r10d, r9d
	jne	.L86
	add	rsp, 8
	ret
	.p2align 4,,10
	.p2align 3
.L90:
	ret
	.size	saxpy_loop, .-saxpy_loop
	.p2align 4
	.globl	histogram
	.type	histogram, @function
histogram:
	endbr64
	mov	r8, rdi
	lea	rdi, 8[rdx]
	mov	rcx, rdx
	xor	eax, eax
	and	rdi, -8
	mov	QWORD PTR [rdx], 0
	mov	QWORD PTR 2040[rdx], 0
	sub	rcx, rdi
	add	ecx, 2048
	shr	ecx, 3
	rep stosq
	test	rsi, rsi
	je	.L100
	mov	rax, r8
	add	rsi, r8
	.p2align 4,,10
	.p2align 3
.L95:
	movzx	ecx, BYTE PTR [rax]
	add	rax, 1
	add	QWORD PTR [rdx+rcx*8], 1
	cmp	rsi, rax
	jne	.L95
.L100:
	ret
	.size	histogram, .-histogram
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC7:
	.string	"out of memory\n"
.LC11:
	.string	"init      %8.3f s\n"
.LC12:
	.string	"matmul    %8.3f s\n"
.LC13:
	.string	"saxpy     %8.3f s\n"
.LC14:
	.string	"histogram %8.3f s\n"
.LC15:
	.string	"total     %8.3f s\n"
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC16:
	.string	"checksum  c=%.4f y=%.4f h=%llu\n"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
	endbr64
	lea	r10, 8[rsp]
	and	rsp, -32
	mov	edi, 16777216
	push	QWORD PTR -8[r10]
	push	rbp
	mov	rbp, rsp
	push	r15
	push	r14
	push	r13
	push	r12
	push	r10
	push	rbx
	sub	rsp, 2176
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR -56[rbp], rax
	xor	eax, eax
	call	malloc@PLT
	mov	edi, 16777216
	mov	r14, rax
	call	malloc@PLT
	mov	edi, 16777216
	mov	QWORD PTR -2160[rbp], rax
	mov	r15, rax
	call	malloc@PLT
	mov	edi, 16777216
	mov	r12, rax
	call	malloc@PLT
	mov	edi, 16777216
	mov	QWORD PTR -2152[rbp], rax
	call	malloc@PLT
	mov	edi, 67108864
	mov	rbx, rax
	call	malloc@PLT
	test	r14, r14
	je	.L102
	test	r15, r15
	je	.L102
	test	r12, r12
	je	.L102
	cmp	QWORD PTR -2152[rbp], 0
	je	.L102
	test	rbx, rbx
	je	.L102
	mov	r13, rax
	test	rax, rax
	je	.L102
	lea	r15, -2144[rbp]
	mov	edi, 1
	mov	rsi, r15
	call	clock_gettime@PLT
	vxorps	xmm2, xmm2, xmm2
	mov	r8, rbx
	mov	rdi, r14
	vcvtsi2sd	xmm0, xmm2, QWORD PTR -2144[rbp]
	mov	rcx, QWORD PTR -2152[rbp]
	mov	rsi, QWORD PTR -2160[rbp]
	mov	r9d, 4194304
	vcvtsi2sd	xmm1, xmm2, QWORD PTR -2136[rbp]
	mov	edx, 4194304
	vfmadd132sd	xmm1, xmm0, QWORD PTR .LC8[rip]
	vmovsd	QWORD PTR -2192[rbp], xmm1
	push	67108864
	push	r13
	call	init_data
	mov	rsi, r15
	mov	edi, 1
	vzeroupper
	call	clock_gettime@PLT
	vxorps	xmm2, xmm2, xmm2
	mov	ecx, 2048
	vcvtsi2sd	xmm0, xmm2, QWORD PTR -2144[rbp]
	mov	rsi, QWORD PTR -2160[rbp]
	mov	rdx, r12
	mov	rdi, r14
	vcvtsi2sd	xmm1, xmm2, QWORD PTR -2136[rbp]
	vfmadd132sd	xmm1, xmm0, QWORD PTR .LC8[rip]
	vmovsd	QWORD PTR -2184[rbp], xmm1
	call	matmul
	mov	rsi, r15
	mov	edi, 1
	call	clock_gettime@PLT
	vxorps	xmm2, xmm2, xmm2
	mov	ecx, 400
	mov	rsi, rbx
	vcvtsi2sd	xmm0, xmm2, QWORD PTR -2144[rbp]
	mov	rdi, QWORD PTR -2152[rbp]
	mov	edx, 4194304
	vcvtsi2sd	xmm1, xmm2, QWORD PTR -2136[rbp]
	vfmadd132sd	xmm1, xmm0, QWORD PTR .LC8[rip]
	vmovsd	QWORD PTR -2176[rbp], xmm1
	call	saxpy_loop
	mov	rsi, r15
	mov	edi, 1
	call	clock_gettime@PLT
	vxorps	xmm2, xmm2, xmm2
	mov	esi, 67108864
	mov	rdi, r13
	vcvtsi2sd	xmm0, xmm2, QWORD PTR -2144[rbp]
	lea	rcx, -2128[rbp]
	vcvtsi2sd	xmm1, xmm2, QWORD PTR -2136[rbp]
	mov	rdx, rcx
	mov	QWORD PTR -2208[rbp], rcx
	vfmadd132sd	xmm1, xmm0, QWORD PTR .LC8[rip]
	vmovsd	QWORD PTR -2168[rbp], xmm1
	call	histogram
	mov	rsi, r15
	mov	edi, 1
	vzeroupper
	call	clock_gettime@PLT
	vxorps	xmm2, xmm2, xmm2
	pop	rcx
	mov	rcx, QWORD PTR -2208[rbp]
	mov	rax, r12
	pop	rsi
	vxorpd	xmm3, xmm3, xmm3
	vcvtsi2sd	xmm1, xmm2, QWORD PTR -2136[rbp]
	lea	rdx, 16777508[r12]
	vcvtsi2sd	xmm0, xmm2, QWORD PTR -2144[rbp]
	vfmadd132sd	xmm1, xmm0, QWORD PTR .LC8[rip]
	vmovq	r15, xmm1
	.p2align 4,,10
	.p2align 3
.L106:
	vcvtss2sd	xmm0, xmm2, DWORD PTR [rax]
	add	rax, 388
	vaddsd	xmm3, xmm3, xmm0
	cmp	rax, rdx
	jne	.L106
	mov	rax, rbx
	lea	rdx, 16777516[rbx]
	vxorpd	xmm1, xmm1, xmm1
	.p2align 4,,10
	.p2align 3
.L107:
	vcvtss2sd	xmm0, xmm2, DWORD PTR [rax]
	add	rax, 3988
	vaddsd	xmm1, xmm1, xmm0
	cmp	rax, rdx
	jne	.L107
	mov	rax, rcx
	mov	ecx, 8
	vmovdqa	ymm5, YMMWORD PTR .LC6[rip]
	lea	rdx, -80[rbp]
	vmovd	xmm8, ecx
	mov	ecx, 1
	vpxor	xmm6, xmm6, xmm6
	vmovd	xmm7, ecx
	vpbroadcastd	ymm8, xmm8
	vpbroadcastd	ymm7, xmm7
	.p2align 4,,10
	.p2align 3
.L108:
	vmovdqa	ymm0, ymm5
	vmovdqa	ymm10, YMMWORD PTR 32[rax]
	add	rax, 64
	vpaddd	ymm5, ymm5, ymm8
	vpaddd	ymm0, ymm0, ymm7
	vextracti128	xmm4, ymm0, 0x1
	vpsrlq	ymm9, ymm10, 32
	vpmovsxdq	ymm0, xmm0
	vpmovsxdq	ymm4, xmm4
	vpsrlq	ymm2, ymm4, 32
	vpmuludq	ymm9, ymm9, ymm4
	vpmuludq	ymm2, ymm2, ymm10
	vpmuludq	ymm11, ymm4, ymm10
	vpaddq	ymm2, ymm2, ymm9
	vpsllq	ymm2, ymm2, 32
	vpaddq	ymm4, ymm11, ymm2
	vmovdqa	ymm11, YMMWORD PTR -64[rax]
	vpsrlq	ymm2, ymm0, 32
	vpsrlq	ymm10, ymm11, 32
	vpmuludq	ymm9, ymm0, ymm11
	vpmuludq	ymm2, ymm2, ymm11
	vpmuludq	ymm0, ymm10, ymm0
	vpaddq	ymm2, ymm2, ymm0
	vpsllq	ymm2, ymm2, 32
	vpaddq	ymm0, ymm9, ymm2
	vpaddq	ymm0, ymm4, ymm0
	vpaddq	ymm6, ymm6, ymm0
	cmp	rdx, rax
	jne	.L108
	vextracti128	xmm2, ymm6, 0x1
	vmovsd	xmm7, QWORD PTR -2184[rbp]
	vsubsd	xmm0, xmm7, QWORD PTR -2192[rbp]
	vmovsd	QWORD PTR -2224[rbp], xmm3
	vpaddq	xmm2, xmm2, xmm6
	mov	edi, 2
	mov	eax, 1
	vmovsd	QWORD PTR -2216[rbp], xmm1
	vmovdqa	XMMWORD PTR -2208[rbp], xmm2
	lea	rsi, .LC11[rip]
	vzeroupper
	call	__printf_chk@PLT
	vmovsd	xmm5, QWORD PTR -2176[rbp]
	vsubsd	xmm0, xmm5, QWORD PTR -2184[rbp]
	lea	rsi, .LC12[rip]
	mov	edi, 2
	mov	eax, 1
	call	__printf_chk@PLT
	mov	edi, 2
	mov	eax, 1
	vmovsd	xmm7, QWORD PTR -2168[rbp]
	vsubsd	xmm0, xmm7, QWORD PTR -2176[rbp]
	lea	rsi, .LC13[rip]
	call	__printf_chk@PLT
	vmovq	xmm5, r15
	mov	edi, 2
	vsubsd	xmm0, xmm5, QWORD PTR -2168[rbp]
	lea	rsi, .LC14[rip]
	mov	eax, 1
	call	__printf_chk@PLT
	vmovq	xmm7, r15
	mov	edi, 2
	vsubsd	xmm0, xmm7, QWORD PTR -2192[rbp]
	lea	rsi, .LC15[rip]
	mov	eax, 1
	call	__printf_chk@PLT
	vmovdqa	xmm2, XMMWORD PTR -2208[rbp]
	vmovsd	xmm3, QWORD PTR -2224[rbp]
	lea	rsi, .LC16[rip]
	vmovsd	xmm1, QWORD PTR -2216[rbp]
	mov	edi, 2
	mov	eax, 2
	vpsrldq	xmm0, xmm2, 8
	vpaddq	xmm2, xmm2, xmm0
	vmovsd	xmm0, xmm3, xmm3
	vmovq	rdx, xmm2
	call	__printf_chk@PLT
	mov	rdi, r14
	call	free@PLT
	mov	rdi, QWORD PTR -2160[rbp]
	call	free@PLT
	mov	rdi, r12
	call	free@PLT
	mov	rdi, QWORD PTR -2152[rbp]
	call	free@PLT
	mov	rdi, rbx
	call	free@PLT
	mov	rdi, r13
	call	free@PLT
	xor	eax, eax
.L101:
	mov	rdx, QWORD PTR -56[rbp]
	sub	rdx, QWORD PTR fs:40
	jne	.L114
	lea	rsp, -48[rbp]
	pop	rbx
	pop	r10
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	pop	rbp
	lea	rsp, -8[r10]
	ret
.L102:
	mov	rcx, QWORD PTR stderr[rip]
	mov	edx, 14
	mov	esi, 1
	lea	rdi, .LC7[rip]
	call	fwrite@PLT
	mov	eax, 1
	jmp	.L101
.L114:
	call	__stack_chk_fail@PLT
	.size	main, .-main
	.data
	.align 4
	.type	rng_state, @object
	.size	rng_state, 4
rng_state:
	.long	12345
	.section	.rodata.cst4,"aM",@progbits,4
	.align 4
.LC0:
	.long	931135488
	.align 4
.LC1:
	.long	998244352
	.align 4
.LC3:
	.long	981668463
	.align 4
.LC4:
	.long	1056964608
	.section	.rodata.cst32,"aM",@progbits,32
	.align 32
.LC6:
	.long	0
	.long	1
	.long	2
	.long	3
	.long	4
	.long	5
	.long	6
	.long	7
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.LC8:
	.long	-400107883
	.long	1041313291
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
