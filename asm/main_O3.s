	.file	"main.c"
	.intel_syntax noprefix
	.text
	.p2align 4
	.globl	init_data
	.type	init_data, @function
init_data:
	endbr64
	push	rbx
	mov	r10, rsi
	mov	rsi, QWORD PTR 24[rsp]
	test	rdx, rdx
	je	.L2
	mov	eax, DWORD PTR rng_state[rip]
	movss	xmm1, DWORD PTR .LC0[rip]
	mov	r11, rdx
	xor	edx, edx
	.p2align 4,,10
	.p2align 3
.L3:
	imul	eax, eax, 1664525
	pxor	xmm0, xmm0
	add	eax, 1013904223
	movzx	ebx, ax
	imul	eax, eax, 1664525
	cvtsi2ss	xmm0, ebx
	add	eax, 1013904223
	movzx	ebx, ax
	mulss	xmm0, xmm1
	movss	DWORD PTR [rdi+rdx*4], xmm0
	pxor	xmm0, xmm0
	cvtsi2ss	xmm0, ebx
	mulss	xmm0, xmm1
	movss	DWORD PTR [r10+rdx*4], xmm0
	add	rdx, 1
	cmp	r11, rdx
	jne	.L3
	mov	DWORD PTR rng_state[rip], eax
.L2:
	test	r9, r9
	je	.L4
	mov	edx, DWORD PTR rng_state[rip]
	movss	xmm1, DWORD PTR .LC1[rip]
	xor	eax, eax
	.p2align 4,,10
	.p2align 3
.L5:
	imul	edx, edx, 1664525
	pxor	xmm0, xmm0
	add	edx, 1013904223
	movzx	edi, dl
	cvtsi2ss	xmm0, edi
	mov	rdi, rax
	mulss	xmm0, xmm1
	movss	DWORD PTR [rcx+rax*4], xmm0
	mov	DWORD PTR [r8+rax*4], 0x00000000
	add	rax, 1
	cmp	r9, rax
	jne	.L5
	movss	DWORD PTR [rcx+rdi*4], xmm0
	mov	DWORD PTR rng_state[rip], edx
	mov	DWORD PTR [r8+rdi*4], 0x00000000
.L4:
	test	rsi, rsi
	je	.L1
	mov	rdx, QWORD PTR 16[rsp]
	mov	eax, DWORD PTR rng_state[rip]
	add	rsi, rdx
	.p2align 4,,10
	.p2align 3
.L7:
	imul	eax, eax, 1664525
	add	rdx, 1
	add	eax, 1013904223
	mov	ecx, eax
	shr	ecx, 24
	mov	BYTE PTR -1[rdx], cl
	cmp	rsi, rdx
	jne	.L7
	mov	DWORD PTR rng_state[rip], eax
.L1:
	pop	rbx
	ret
	.size	init_data, .-init_data
	.p2align 4
	.globl	matmul
	.type	matmul, @function
matmul:
	endbr64
	push	r15
	mov	r8, rdx
	movsx	rdx, ecx
	push	r14
	mov	r14, rdx
	push	r13
	push	r12
	push	rbp
	mov	rbp, rdi
	push	rbx
	mov	rbx, rsi
	xor	esi, esi
	sub	rsp, 120
	mov	QWORD PTR 16[rsp], rdx
	imul	rdx, rdx
	mov	QWORD PTR 64[rsp], rdi
	mov	rdi, r8
	sal	rdx, 2
	call	memset@PLT
	test	r14d, r14d
	jle	.L22
	lea	esi, [r14+r14]
	mov	edx, r14d
	mov	QWORD PTR [rsp], rbp
	xor	r11d, r11d
	mov	DWORD PTR 104[rsp], esi
	movsx	rsi, esi
	shr	edx, 2
	mov	ebp, r14d
	mov	QWORD PTR 96[rsp], rsi
	lea	esi, -1[r14]
	sal	rdx, 4
	mov	r8, rax
	mov	DWORD PTR 12[rsp], esi
	mov	esi, r14d
	mov	r13, rdx
	lea	edx, -3[r14]
	and	esi, 3
	and	edx, -2
	lea	rdi, 0[0+r14*4]
	xor	ecx, ecx
	mov	DWORD PTR 108[rsp], esi
	add	edx, 3
	and	ebp, -4
	xor	r15d, r15d
	mov	DWORD PTR 76[rsp], edx
	xor	r12d, r12d
	mov	edx, r11d
.L24:
	xor	esi, esi
	cmp	r14d, 2
	jle	.L40
	lea	esi, 1[r12]
	mov	DWORD PTR 88[rsp], ecx
	mov	r10d, r14d
	xor	r11d, r11d
	mov	DWORD PTR 32[rsp], esi
	mov	esi, DWORD PTR 76[rsp]
	mov	QWORD PTR 24[rsp], 0
	add	esi, r12d
	mov	QWORD PTR 40[rsp], rax
	mov	DWORD PTR 60[rsp], esi
	mov	rsi, QWORD PTR [rsp]
	mov	DWORD PTR 92[rsp], edx
	mov	QWORD PTR 48[rsp], rsi
	mov	QWORD PTR 80[rsp], rdi
	mov	rdi, QWORD PTR 64[rsp]
	mov	DWORD PTR 56[rsp], r14d
	mov	r14, r15
	mov	r15d, ebp
.L28:
	mov	r9, QWORD PTR 48[rsp]
	cmp	DWORD PTR 12[rsp], 2
	movss	xmm4, DWORD PTR [r9]
	je	.L44
	mov	rax, QWORD PTR 24[rsp]
	movss	xmm2, DWORD PTR 4[r9]
	movsx	rbp, r10d
	xor	edx, edx
	movaps	xmm3, xmm4
	lea	rcx, [rbx+rbp*4]
	lea	rsi, [rbx+rax*4]
	mov	rax, QWORD PTR 40[rsp]
	shufps	xmm3, xmm3, 0
	shufps	xmm2, xmm2, 0
	.p2align 4,,10
	.p2align 3
.L37:
	movups	xmm0, XMMWORD PTR [rsi+rdx]
	movups	xmm1, XMMWORD PTR [rcx+rdx]
	movups	xmm6, XMMWORD PTR [rax+rdx]
	mulps	xmm0, xmm3
	mulps	xmm1, xmm2
	addps	xmm0, xmm6
	addps	xmm0, xmm1
	movups	XMMWORD PTR [rax+rdx], xmm0
	add	rdx, 16
	cmp	r13, rdx
	jne	.L37
	mov	QWORD PTR 40[rsp], rax
	cmp	DWORD PTR 56[rsp], r15d
	je	.L25
	mov	eax, DWORD PTR 108[rsp]
	mov	edx, eax
	cmp	eax, 1
	je	.L41
	mov	DWORD PTR 72[rsp], r15d
	mov	ecx, r15d
.L36:
	mov	rax, QWORD PTR 24[rsp]
	lea	rsi, [r14+rcx]
	movaps	xmm2, xmm4
	lea	r9, [r8+rsi*4]
	movsx	rsi, DWORD PTR 32[rsp]
	shufps	xmm2, xmm2, 0xe0
	add	rax, rcx
	add	rcx, rbp
	movq	xmm0, QWORD PTR [rbx+rax*4]
	movss	xmm3, DWORD PTR [rdi+rsi*4]
	movq	xmm1, QWORD PTR [rbx+rcx*4]
	mulps	xmm0, xmm2
	shufps	xmm3, xmm3, 0xe0
	movq	xmm2, QWORD PTR [r9]
	mulps	xmm1, xmm3
	addps	xmm0, xmm2
	addps	xmm0, xmm1
	movlps	QWORD PTR [r9], xmm0
	test	dl, 1
	je	.L25
	mov	eax, DWORD PTR 72[rsp]
	and	edx, -2
	add	edx, eax
.L26:
	lea	ecx, [r12+rdx]
	movsx	rcx, ecx
	lea	r9, [r8+rcx*4]
	lea	ecx, [r10+rdx]
	add	edx, r11d
	movsx	rdx, edx
	movsx	rcx, ecx
	movss	xmm1, DWORD PTR [r9]
	mulss	xmm4, DWORD PTR [rbx+rdx*4]
	movss	xmm0, DWORD PTR [rbx+rcx*4]
	mulss	xmm0, DWORD PTR [rdi+rsi*4]
	addss	xmm1, xmm4
	addss	xmm0, xmm1
	movss	DWORD PTR [r9], xmm0
.L25:
	mov	eax, DWORD PTR 104[rsp]
	mov	rsi, QWORD PTR 96[rsp]
	add	QWORD PTR 48[rsp], 8
	add	r10d, eax
	add	r11d, eax
	mov	eax, DWORD PTR 32[rsp]
	add	QWORD PTR 24[rsp], rsi
	lea	edx, 2[rax]
	cmp	DWORD PTR 60[rsp], edx
	je	.L62
	mov	DWORD PTR 32[rsp], edx
	jmp	.L28
.L62:
	mov	edx, DWORD PTR 92[rsp]
	mov	esi, eax
	mov	ebp, r15d
	mov	ecx, DWORD PTR 88[rsp]
	mov	r15, r14
	mov	rax, QWORD PTR 40[rsp]
	mov	rdi, QWORD PTR 80[rsp]
	mov	r14d, DWORD PTR 56[rsp]
	lea	esi, 1[rsi+rdx]
.L40:
	movsx	r11, esi
	imul	esi, r14d
	mov	DWORD PTR 24[rsp], ecx
	mov	QWORD PTR 32[rsp], rdi
	mov	DWORD PTR 40[rsp], edx
	movsx	r10, esi
	.p2align 4,,10
	.p2align 3
.L34:
	mov	rdi, QWORD PTR [rsp]
	cmp	DWORD PTR 12[rsp], 2
	movss	xmm3, DWORD PTR [rdi+r11*4]
	jbe	.L43
	movaps	xmm1, xmm3
	lea	rcx, [rbx+r10*4]
	xor	edx, edx
	shufps	xmm1, xmm1, 0
	.p2align 4,,10
	.p2align 3
.L30:
	movups	xmm0, XMMWORD PTR [rcx+rdx]
	movups	xmm5, XMMWORD PTR [rax+rdx]
	mulps	xmm0, xmm1
	addps	xmm0, xmm5
	movups	XMMWORD PTR [rax+rdx], xmm0
	add	rdx, 16
	cmp	r13, rdx
	jne	.L30
	cmp	r14d, ebp
	je	.L31
	mov	ecx, ebp
	mov	edx, ebp
.L29:
	mov	edi, r14d
	sub	edi, ecx
	cmp	edi, 1
	je	.L32
	lea	r9, [rcx+r15]
	add	rcx, r10
	movaps	xmm2, xmm3
	movq	xmm0, QWORD PTR [rbx+rcx*4]
	shufps	xmm2, xmm2, 0xe0
	lea	r9, [r8+r9*4]
	mulps	xmm0, xmm2
	movq	xmm2, QWORD PTR [r9]
	addps	xmm0, xmm2
	movlps	QWORD PTR [r9], xmm0
	test	dil, 1
	je	.L31
	and	edi, -2
	add	edx, edi
.L32:
	lea	ecx, [r12+rdx]
	add	edx, esi
	movsx	rdx, edx
	movsx	rcx, ecx
	mulss	xmm3, DWORD PTR [rbx+rdx*4]
	lea	rcx, [r8+rcx*4]
	movss	xmm0, DWORD PTR [rcx]
	addss	xmm0, xmm3
	movss	DWORD PTR [rcx], xmm0
.L31:
	mov	rdi, QWORD PTR 16[rsp]
	add	r11, 1
	add	esi, r14d
	add	r10, rdi
	cmp	r14d, r11d
	jg	.L34
	mov	ecx, DWORD PTR 24[rsp]
	mov	rsi, rdi
	mov	edx, DWORD PTR 40[rsp]
	add	r12d, r14d
	mov	rdi, QWORD PTR 32[rsp]
	add	r15, rsi
	add	QWORD PTR [rsp], rdi
	add	ecx, 1
	sub	edx, r14d
	add	rax, rdi
	cmp	r14d, ecx
	jne	.L24
.L22:
	add	rsp, 120
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	ret
	.p2align 4,,10
	.p2align 3
.L43:
	xor	ecx, ecx
	xor	edx, edx
	jmp	.L29
.L44:
	mov	DWORD PTR 72[rsp], 0
	mov	edx, 3
	xor	ecx, ecx
	movsx	rbp, r10d
	jmp	.L36
.L41:
	movsx	rsi, DWORD PTR 32[rsp]
	mov	edx, r15d
	jmp	.L26
	.size	matmul, .-matmul
	.p2align 4
	.globl	saxpy
	.type	saxpy, @function
saxpy:
	endbr64
	mov	rcx, rsi
	test	rdx, rdx
	je	.L63
	lea	rax, -1[rdx]
	cmp	rax, 2
	jbe	.L70
	mov	rsi, rdx
	movaps	xmm2, xmm0
	xor	eax, eax
	shr	rsi, 2
	shufps	xmm2, xmm2, 0
	sal	rsi, 4
	.p2align 4,,10
	.p2align 3
.L66:
	movups	xmm1, XMMWORD PTR [rdi+rax]
	movups	xmm3, XMMWORD PTR [rcx+rax]
	mulps	xmm1, xmm2
	addps	xmm1, xmm3
	movups	XMMWORD PTR [rcx+rax], xmm1
	add	rax, 16
	cmp	rax, rsi
	jne	.L66
	test	dl, 3
	je	.L63
	mov	rax, rdx
	and	rax, -4
.L65:
	sub	rdx, rax
	cmp	rdx, 1
	je	.L68
	movq	xmm1, QWORD PTR [rdi+rax*4]
	movaps	xmm2, xmm0
	lea	rsi, [rcx+rax*4]
	shufps	xmm2, xmm2, 0xe0
	mulps	xmm1, xmm2
	movq	xmm2, QWORD PTR [rsi]
	addps	xmm1, xmm2
	movlps	QWORD PTR [rsi], xmm1
	test	dl, 1
	je	.L63
	and	rdx, -2
	add	rax, rdx
.L68:
	lea	rdx, [rcx+rax*4]
	mulss	xmm0, DWORD PTR [rdi+rax*4]
	addss	xmm0, DWORD PTR [rdx]
	movss	DWORD PTR [rdx], xmm0
.L63:
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
	jle	.L89
	sub	rsp, 8
	mov	r10, rsi
	mov	r11, rdx
	mov	r9d, ecx
	movss	xmm5, DWORD PTR .LC3[rip]
	movss	xmm4, DWORD PTR .LC4[rip]
	xor	r8d, r8d
	.p2align 4,,10
	.p2align 3
.L86:
	pxor	xmm0, xmm0
	mov	rdx, r11
	mov	rsi, r10
	cvtsi2ss	xmm0, r8d
	add	r8d, 1
	mulss	xmm0, xmm5
	addss	xmm0, xmm4
	call	saxpy
	cmp	r9d, r8d
	jne	.L86
	add	rsp, 8
	ret
	.p2align 4,,10
	.p2align 3
.L89:
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
	je	.L92
	mov	rax, r8
	add	rsi, r8
	.p2align 4,,10
	.p2align 3
.L94:
	movzx	ecx, BYTE PTR [rax]
	add	rax, 1
	add	QWORD PTR [rdx+rcx*8], 1
	cmp	rax, rsi
	jne	.L94
.L92:
	ret
	.size	histogram, .-histogram
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC6:
	.string	"out of memory\n"
.LC8:
	.string	"init      %8.3f s\n"
.LC9:
	.string	"matmul    %8.3f s\n"
.LC10:
	.string	"saxpy     %8.3f s\n"
.LC11:
	.string	"histogram %8.3f s\n"
.LC12:
	.string	"total     %8.3f s\n"
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC13:
	.string	"checksum  c=%.4f y=%.4f h=%llu\n"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
	endbr64
	push	r15
	mov	edi, 16777216
	push	r14
	push	r13
	push	r12
	push	rbp
	push	rbx
	sub	rsp, 2152
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR 2136[rsp], rax
	xor	eax, eax
	call	malloc@PLT
	mov	edi, 16777216
	mov	r14, rax
	call	malloc@PLT
	mov	edi, 16777216
	mov	r13, rax
	call	malloc@PLT
	mov	edi, 16777216
	mov	rbp, rax
	call	malloc@PLT
	mov	edi, 16777216
	mov	QWORD PTR [rsp], rax
	mov	r15, rax
	call	malloc@PLT
	mov	edi, 67108864
	mov	rbx, rax
	call	malloc@PLT
	test	r14, r14
	je	.L100
	test	r13, r13
	je	.L100
	test	rbp, rbp
	je	.L100
	test	r15, r15
	je	.L100
	test	rbx, rbx
	je	.L100
	mov	r12, rax
	test	rax, rax
	je	.L100
	lea	r15, 64[rsp]
	mov	edi, 1
	mov	rsi, r15
	call	clock_gettime@PLT
	pxor	xmm0, xmm0
	pxor	xmm1, xmm1
	mov	r8, rbx
	cvtsi2sd	xmm0, QWORD PTR 72[rsp]
	mov	edx, 4194304
	mov	rsi, r13
	mov	rdi, r14
	mulsd	xmm0, QWORD PTR .LC7[rip]
	cvtsi2sd	xmm1, QWORD PTR 64[rsp]
	mov	r9d, 4194304
	addsd	xmm0, xmm1
	movsd	QWORD PTR 40[rsp], xmm0
	push	67108864
	push	r12
	mov	rcx, QWORD PTR 16[rsp]
	call	init_data
	mov	rsi, r15
	mov	edi, 1
	call	clock_gettime@PLT
	pxor	xmm0, xmm0
	pxor	xmm1, xmm1
	mov	rdx, rbp
	cvtsi2sd	xmm0, QWORD PTR 88[rsp]
	mov	ecx, 2048
	mov	rsi, r13
	mov	rdi, r14
	mulsd	xmm0, QWORD PTR .LC7[rip]
	cvtsi2sd	xmm1, QWORD PTR 80[rsp]
	addsd	xmm0, xmm1
	movsd	QWORD PTR 48[rsp], xmm0
	call	matmul
	mov	rsi, r15
	mov	edi, 1
	call	clock_gettime@PLT
	pxor	xmm0, xmm0
	pxor	xmm1, xmm1
	mov	rsi, rbx
	mov	rdi, QWORD PTR 16[rsp]
	mov	ecx, 400
	mov	edx, 4194304
	cvtsi2sd	xmm0, QWORD PTR 88[rsp]
	mulsd	xmm0, QWORD PTR .LC7[rip]
	cvtsi2sd	xmm1, QWORD PTR 80[rsp]
	addsd	xmm0, xmm1
	movsd	QWORD PTR 40[rsp], xmm0
	call	saxpy_loop
	mov	rsi, r15
	mov	edi, 1
	call	clock_gettime@PLT
	pxor	xmm0, xmm0
	pxor	xmm1, xmm1
	mov	rdi, r12
	cvtsi2sd	xmm0, QWORD PTR 88[rsp]
	lea	r8, 96[rsp]
	mov	esi, 67108864
	mulsd	xmm0, QWORD PTR .LC7[rip]
	cvtsi2sd	xmm1, QWORD PTR 80[rsp]
	mov	rdx, r8
	mov	QWORD PTR 64[rsp], r8
	addsd	xmm0, xmm1
	movsd	QWORD PTR 32[rsp], xmm0
	call	histogram
	mov	rsi, r15
	mov	edi, 1
	call	clock_gettime@PLT
	pxor	xmm0, xmm0
	pxor	xmm1, xmm1
	mov	rax, rbp
	cvtsi2sd	xmm0, QWORD PTR 88[rsp]
	mulsd	xmm0, QWORD PTR .LC7[rip]
	lea	rdx, 16777508[rbp]
	cvtsi2sd	xmm1, QWORD PTR 80[rsp]
	pxor	xmm2, xmm2
	addsd	xmm0, xmm1
	movsd	QWORD PTR 24[rsp], xmm0
	pop	rcx
	pop	rsi
	mov	r8, QWORD PTR 48[rsp]
	.p2align 4,,10
	.p2align 3
.L104:
	pxor	xmm0, xmm0
	add	rax, 388
	cvtss2sd	xmm0, DWORD PTR -388[rax]
	addsd	xmm2, xmm0
	cmp	rdx, rax
	jne	.L104
	mov	rax, rbx
	lea	rdx, 16777516[rbx]
	pxor	xmm1, xmm1
	.p2align 4,,10
	.p2align 3
.L105:
	pxor	xmm0, xmm0
	add	rax, 3988
	cvtss2sd	xmm0, DWORD PTR -3988[rax]
	addsd	xmm1, xmm0
	cmp	rdx, rax
	jne	.L105
	mov	eax, 1
	xor	r15d, r15d
	.p2align 4,,10
	.p2align 3
.L106:
	mov	rcx, QWORD PTR -8[r8+rax*8]
	imul	rcx, rax
	add	rax, 1
	add	r15, rcx
	cmp	rax, 257
	jne	.L106
	movsd	xmm0, QWORD PTR 32[rsp]
	subsd	xmm0, QWORD PTR 40[rsp]
	mov	edi, 2
	lea	rsi, .LC8[rip]
	mov	eax, 1
	movsd	QWORD PTR 56[rsp], xmm2
	movsd	QWORD PTR 48[rsp], xmm1
	call	__printf_chk@PLT
	movsd	xmm4, QWORD PTR 24[rsp]
	subsd	xmm4, QWORD PTR 32[rsp]
	lea	rsi, .LC9[rip]
	mov	edi, 2
	mov	eax, 1
	movapd	xmm0, xmm4
	call	__printf_chk@PLT
	movsd	xmm0, QWORD PTR 16[rsp]
	subsd	xmm0, QWORD PTR 24[rsp]
	lea	rsi, .LC10[rip]
	mov	edi, 2
	mov	eax, 1
	call	__printf_chk@PLT
	movsd	xmm0, QWORD PTR 8[rsp]
	subsd	xmm0, QWORD PTR 16[rsp]
	lea	rsi, .LC11[rip]
	mov	edi, 2
	mov	eax, 1
	call	__printf_chk@PLT
	movsd	xmm0, QWORD PTR 8[rsp]
	subsd	xmm0, QWORD PTR 40[rsp]
	lea	rsi, .LC12[rip]
	mov	edi, 2
	mov	eax, 1
	call	__printf_chk@PLT
	movsd	xmm2, QWORD PTR 56[rsp]
	mov	rdx, r15
	movsd	xmm1, QWORD PTR 48[rsp]
	lea	rsi, .LC13[rip]
	mov	edi, 2
	mov	eax, 2
	movapd	xmm0, xmm2
	call	__printf_chk@PLT
	mov	rdi, r14
	call	free@PLT
	mov	rdi, r13
	call	free@PLT
	mov	rdi, rbp
	call	free@PLT
	mov	rdi, QWORD PTR [rsp]
	call	free@PLT
	mov	rdi, rbx
	call	free@PLT
	mov	rdi, r12
	call	free@PLT
	xor	eax, eax
.L99:
	mov	rdx, QWORD PTR 2136[rsp]
	sub	rdx, QWORD PTR fs:40
	jne	.L112
	add	rsp, 2152
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	ret
.L100:
	mov	rcx, QWORD PTR stderr[rip]
	mov	edx, 14
	mov	esi, 1
	lea	rdi, .LC6[rip]
	call	fwrite@PLT
	mov	eax, 1
	jmp	.L99
.L112:
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
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.LC7:
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
