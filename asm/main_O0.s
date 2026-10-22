	.file	"main.c"
	.intel_syntax noprefix
	.text
	.data
	.align 4
	.type	rng_state, @object
	.size	rng_state, 4
rng_state:
	.long	12345
	.text
	.type	lcg, @function
lcg:
	push	rbp
	mov	rbp, rsp
	mov	eax, DWORD PTR rng_state[rip]
	imul	eax, eax, 1664525
	add	eax, 1013904223
	mov	DWORD PTR rng_state[rip], eax
	mov	eax, DWORD PTR rng_state[rip]
	pop	rbp
	ret
	.size	lcg, .-lcg
	.globl	init_data
	.type	init_data, @function
init_data:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 80
	mov	QWORD PTR -40[rbp], rdi
	mov	QWORD PTR -48[rbp], rsi
	mov	QWORD PTR -56[rbp], rdx
	mov	QWORD PTR -64[rbp], rcx
	mov	QWORD PTR -72[rbp], r8
	mov	QWORD PTR -80[rbp], r9
	mov	QWORD PTR -24[rbp], 0
	jmp	.L4
.L9:
	call	lcg
	movzx	eax, ax
	mov	eax, eax
	test	rax, rax
	js	.L5
	pxor	xmm0, xmm0
	cvtsi2ss	xmm0, rax
	jmp	.L6
.L5:
	mov	rdx, rax
	shr	rdx
	and	eax, 1
	or	rdx, rax
	pxor	xmm0, xmm0
	cvtsi2ss	xmm0, rdx
	addss	xmm0, xmm0
.L6:
	mov	rax, QWORD PTR -24[rbp]
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -40[rbp]
	add	rax, rdx
	movss	xmm1, DWORD PTR .LC0[rip]
	divss	xmm0, xmm1
	movss	DWORD PTR [rax], xmm0
	call	lcg
	movzx	eax, ax
	mov	eax, eax
	test	rax, rax
	js	.L7
	pxor	xmm0, xmm0
	cvtsi2ss	xmm0, rax
	jmp	.L8
.L7:
	mov	rdx, rax
	shr	rdx
	and	eax, 1
	or	rdx, rax
	pxor	xmm0, xmm0
	cvtsi2ss	xmm0, rdx
	addss	xmm0, xmm0
.L8:
	mov	rax, QWORD PTR -24[rbp]
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -48[rbp]
	add	rax, rdx
	movss	xmm1, DWORD PTR .LC0[rip]
	divss	xmm0, xmm1
	movss	DWORD PTR [rax], xmm0
	add	QWORD PTR -24[rbp], 1
.L4:
	mov	rax, QWORD PTR -24[rbp]
	cmp	rax, QWORD PTR -56[rbp]
	jb	.L9
	mov	QWORD PTR -16[rbp], 0
	jmp	.L10
.L13:
	call	lcg
	movzx	eax, al
	mov	eax, eax
	test	rax, rax
	js	.L11
	pxor	xmm0, xmm0
	cvtsi2ss	xmm0, rax
	jmp	.L12
.L11:
	mov	rdx, rax
	shr	rdx
	and	eax, 1
	or	rdx, rax
	pxor	xmm0, xmm0
	cvtsi2ss	xmm0, rdx
	addss	xmm0, xmm0
.L12:
	mov	rax, QWORD PTR -16[rbp]
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -64[rbp]
	add	rax, rdx
	movss	xmm1, DWORD PTR .LC1[rip]
	divss	xmm0, xmm1
	movss	DWORD PTR [rax], xmm0
	mov	rax, QWORD PTR -16[rbp]
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -72[rbp]
	add	rax, rdx
	pxor	xmm0, xmm0
	movss	DWORD PTR [rax], xmm0
	add	QWORD PTR -16[rbp], 1
.L10:
	mov	rax, QWORD PTR -16[rbp]
	cmp	rax, QWORD PTR -80[rbp]
	jb	.L13
	mov	QWORD PTR -8[rbp], 0
	jmp	.L14
.L15:
	call	lcg
	shr	eax, 24
	mov	ecx, eax
	mov	rdx, QWORD PTR 16[rbp]
	mov	rax, QWORD PTR -8[rbp]
	add	rax, rdx
	mov	edx, ecx
	mov	BYTE PTR [rax], dl
	add	QWORD PTR -8[rbp], 1
.L14:
	mov	rax, QWORD PTR -8[rbp]
	cmp	rax, QWORD PTR 24[rbp]
	jb	.L15
	nop
	nop
	leave
	ret
	.size	init_data, .-init_data
	.globl	matmul
	.type	matmul, @function
matmul:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 48
	mov	QWORD PTR -24[rbp], rdi
	mov	QWORD PTR -32[rbp], rsi
	mov	QWORD PTR -40[rbp], rdx
	mov	DWORD PTR -44[rbp], ecx
	mov	eax, DWORD PTR -44[rbp]
	movsx	rdx, eax
	mov	eax, DWORD PTR -44[rbp]
	cdqe
	imul	rax, rdx
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -40[rbp]
	mov	esi, 0
	mov	rdi, rax
	call	memset@PLT
	mov	DWORD PTR -16[rbp], 0
	jmp	.L17
.L22:
	mov	DWORD PTR -12[rbp], 0
	jmp	.L18
.L21:
	mov	eax, DWORD PTR -16[rbp]
	imul	eax, DWORD PTR -44[rbp]
	mov	edx, eax
	mov	eax, DWORD PTR -12[rbp]
	add	eax, edx
	cdqe
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -24[rbp]
	add	rax, rdx
	movss	xmm0, DWORD PTR [rax]
	movss	DWORD PTR -4[rbp], xmm0
	mov	DWORD PTR -8[rbp], 0
	jmp	.L19
.L20:
	mov	eax, DWORD PTR -16[rbp]
	imul	eax, DWORD PTR -44[rbp]
	mov	edx, eax
	mov	eax, DWORD PTR -8[rbp]
	add	eax, edx
	cdqe
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -40[rbp]
	add	rax, rdx
	movss	xmm1, DWORD PTR [rax]
	mov	eax, DWORD PTR -12[rbp]
	imul	eax, DWORD PTR -44[rbp]
	mov	edx, eax
	mov	eax, DWORD PTR -8[rbp]
	add	eax, edx
	cdqe
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -32[rbp]
	add	rax, rdx
	movss	xmm0, DWORD PTR [rax]
	mulss	xmm0, DWORD PTR -4[rbp]
	mov	eax, DWORD PTR -16[rbp]
	imul	eax, DWORD PTR -44[rbp]
	mov	edx, eax
	mov	eax, DWORD PTR -8[rbp]
	add	eax, edx
	cdqe
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -40[rbp]
	add	rax, rdx
	addss	xmm0, xmm1
	movss	DWORD PTR [rax], xmm0
	add	DWORD PTR -8[rbp], 1
.L19:
	mov	eax, DWORD PTR -8[rbp]
	cmp	eax, DWORD PTR -44[rbp]
	jl	.L20
	add	DWORD PTR -12[rbp], 1
.L18:
	mov	eax, DWORD PTR -12[rbp]
	cmp	eax, DWORD PTR -44[rbp]
	jl	.L21
	add	DWORD PTR -16[rbp], 1
.L17:
	mov	eax, DWORD PTR -16[rbp]
	cmp	eax, DWORD PTR -44[rbp]
	jl	.L22
	nop
	nop
	leave
	ret
	.size	matmul, .-matmul
	.globl	saxpy
	.type	saxpy, @function
saxpy:
	endbr64
	push	rbp
	mov	rbp, rsp
	movss	DWORD PTR -20[rbp], xmm0
	mov	QWORD PTR -32[rbp], rdi
	mov	QWORD PTR -40[rbp], rsi
	mov	QWORD PTR -48[rbp], rdx
	mov	QWORD PTR -8[rbp], 0
	jmp	.L24
.L25:
	mov	rax, QWORD PTR -8[rbp]
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -32[rbp]
	add	rax, rdx
	movss	xmm0, DWORD PTR [rax]
	movaps	xmm1, xmm0
	mulss	xmm1, DWORD PTR -20[rbp]
	mov	rax, QWORD PTR -8[rbp]
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -40[rbp]
	add	rax, rdx
	movss	xmm0, DWORD PTR [rax]
	mov	rax, QWORD PTR -8[rbp]
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -40[rbp]
	add	rax, rdx
	addss	xmm0, xmm1
	movss	DWORD PTR [rax], xmm0
	add	QWORD PTR -8[rbp], 1
.L24:
	mov	rax, QWORD PTR -8[rbp]
	cmp	rax, QWORD PTR -48[rbp]
	jb	.L25
	nop
	nop
	pop	rbp
	ret
	.size	saxpy, .-saxpy
	.globl	saxpy_loop
	.type	saxpy_loop, @function
saxpy_loop:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 48
	mov	QWORD PTR -24[rbp], rdi
	mov	QWORD PTR -32[rbp], rsi
	mov	QWORD PTR -40[rbp], rdx
	mov	DWORD PTR -44[rbp], ecx
	mov	DWORD PTR -4[rbp], 0
	jmp	.L27
.L28:
	pxor	xmm1, xmm1
	cvtsi2ss	xmm1, DWORD PTR -4[rbp]
	movss	xmm0, DWORD PTR .LC3[rip]
	mulss	xmm1, xmm0
	movss	xmm0, DWORD PTR .LC4[rip]
	addss	xmm1, xmm0
	movd	eax, xmm1
	mov	rdx, QWORD PTR -40[rbp]
	mov	rsi, QWORD PTR -32[rbp]
	mov	rcx, QWORD PTR -24[rbp]
	mov	rdi, rcx
	movd	xmm0, eax
	call	saxpy
	add	DWORD PTR -4[rbp], 1
.L27:
	mov	eax, DWORD PTR -4[rbp]
	cmp	eax, DWORD PTR -44[rbp]
	jl	.L28
	nop
	nop
	leave
	ret
	.size	saxpy_loop, .-saxpy_loop
	.globl	histogram
	.type	histogram, @function
histogram:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 48
	mov	QWORD PTR -24[rbp], rdi
	mov	QWORD PTR -32[rbp], rsi
	mov	QWORD PTR -40[rbp], rdx
	mov	rax, QWORD PTR -40[rbp]
	mov	edx, 2048
	mov	esi, 0
	mov	rdi, rax
	call	memset@PLT
	mov	QWORD PTR -8[rbp], 0
	jmp	.L30
.L31:
	mov	rdx, QWORD PTR -24[rbp]
	mov	rax, QWORD PTR -8[rbp]
	add	rax, rdx
	movzx	eax, BYTE PTR [rax]
	movzx	eax, al
	lea	rdx, 0[0+rax*8]
	mov	rax, QWORD PTR -40[rbp]
	add	rax, rdx
	mov	rdx, QWORD PTR [rax]
	add	rdx, 1
	mov	QWORD PTR [rax], rdx
	add	QWORD PTR -8[rbp], 1
.L30:
	mov	rax, QWORD PTR -8[rbp]
	cmp	rax, QWORD PTR -32[rbp]
	jb	.L31
	nop
	nop
	leave
	ret
	.size	histogram, .-histogram
	.type	now_sec, @function
now_sec:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 32
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR -8[rbp], rax
	xor	eax, eax
	lea	rax, -32[rbp]
	mov	rsi, rax
	mov	edi, 1
	call	clock_gettime@PLT
	mov	rax, QWORD PTR -32[rbp]
	pxor	xmm1, xmm1
	cvtsi2sd	xmm1, rax
	mov	rax, QWORD PTR -24[rbp]
	pxor	xmm2, xmm2
	cvtsi2sd	xmm2, rax
	movsd	xmm0, QWORD PTR .LC5[rip]
	mulsd	xmm0, xmm2
	addsd	xmm0, xmm1
	mov	rax, QWORD PTR -8[rbp]
	sub	rax, QWORD PTR fs:40
	je	.L34
	call	__stack_chk_fail@PLT
.L34:
	leave
	ret
	.size	now_sec, .-now_sec
	.section	.rodata
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
	.align 8
.LC13:
	.string	"checksum  c=%.4f y=%.4f h=%llu\n"
	.text
	.globl	main
	.type	main, @function
main:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 2208
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR -8[rbp], rax
	xor	eax, eax
	mov	QWORD PTR -2160[rbp], 4194304
	mov	rax, QWORD PTR -2160[rbp]
	sal	rax, 2
	mov	rdi, rax
	call	malloc@PLT
	mov	QWORD PTR -2152[rbp], rax
	mov	rax, QWORD PTR -2160[rbp]
	sal	rax, 2
	mov	rdi, rax
	call	malloc@PLT
	mov	QWORD PTR -2144[rbp], rax
	mov	rax, QWORD PTR -2160[rbp]
	sal	rax, 2
	mov	rdi, rax
	call	malloc@PLT
	mov	QWORD PTR -2136[rbp], rax
	mov	edi, 16777216
	call	malloc@PLT
	mov	QWORD PTR -2128[rbp], rax
	mov	edi, 16777216
	call	malloc@PLT
	mov	QWORD PTR -2120[rbp], rax
	mov	edi, 67108864
	call	malloc@PLT
	mov	QWORD PTR -2112[rbp], rax
	cmp	QWORD PTR -2152[rbp], 0
	je	.L36
	cmp	QWORD PTR -2144[rbp], 0
	je	.L36
	cmp	QWORD PTR -2136[rbp], 0
	je	.L36
	cmp	QWORD PTR -2128[rbp], 0
	je	.L36
	cmp	QWORD PTR -2120[rbp], 0
	je	.L36
	cmp	QWORD PTR -2112[rbp], 0
	jne	.L37
.L36:
	mov	rax, QWORD PTR stderr[rip]
	mov	rcx, rax
	mov	edx, 14
	mov	esi, 1
	lea	rax, .LC6[rip]
	mov	rdi, rax
	call	fwrite@PLT
	mov	eax, 1
	jmp	.L45
.L37:
	call	now_sec
	movq	rax, xmm0
	mov	QWORD PTR -2104[rbp], rax
	mov	rdi, QWORD PTR -2120[rbp]
	mov	rcx, QWORD PTR -2128[rbp]
	mov	rdx, QWORD PTR -2160[rbp]
	mov	rsi, QWORD PTR -2144[rbp]
	mov	rax, QWORD PTR -2152[rbp]
	push	67108864
	push	QWORD PTR -2112[rbp]
	mov	r9d, 4194304
	mov	r8, rdi
	mov	rdi, rax
	call	init_data
	add	rsp, 16
	call	now_sec
	movq	rax, xmm0
	mov	QWORD PTR -2096[rbp], rax
	mov	rdx, QWORD PTR -2136[rbp]
	mov	rsi, QWORD PTR -2144[rbp]
	mov	rax, QWORD PTR -2152[rbp]
	mov	ecx, 2048
	mov	rdi, rax
	call	matmul
	call	now_sec
	movq	rax, xmm0
	mov	QWORD PTR -2088[rbp], rax
	mov	rsi, QWORD PTR -2120[rbp]
	mov	rax, QWORD PTR -2128[rbp]
	mov	ecx, 400
	mov	edx, 4194304
	mov	rdi, rax
	call	saxpy_loop
	call	now_sec
	movq	rax, xmm0
	mov	QWORD PTR -2080[rbp], rax
	lea	rdx, -2064[rbp]
	mov	rax, QWORD PTR -2112[rbp]
	mov	esi, 67108864
	mov	rdi, rax
	call	histogram
	call	now_sec
	movq	rax, xmm0
	mov	QWORD PTR -2072[rbp], rax
	pxor	xmm0, xmm0
	movsd	QWORD PTR -2200[rbp], xmm0
	pxor	xmm0, xmm0
	movsd	QWORD PTR -2192[rbp], xmm0
	mov	QWORD PTR -2184[rbp], 0
	jmp	.L39
.L40:
	mov	rax, QWORD PTR -2184[rbp]
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -2136[rbp]
	add	rax, rdx
	movss	xmm0, DWORD PTR [rax]
	cvtss2sd	xmm0, xmm0
	movsd	xmm1, QWORD PTR -2200[rbp]
	addsd	xmm0, xmm1
	movsd	QWORD PTR -2200[rbp], xmm0
	add	QWORD PTR -2184[rbp], 97
.L39:
	mov	rax, QWORD PTR -2184[rbp]
	cmp	rax, QWORD PTR -2160[rbp]
	jb	.L40
	mov	QWORD PTR -2176[rbp], 0
	jmp	.L41
.L42:
	mov	rax, QWORD PTR -2176[rbp]
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -2120[rbp]
	add	rax, rdx
	movss	xmm0, DWORD PTR [rax]
	cvtss2sd	xmm0, xmm0
	movsd	xmm1, QWORD PTR -2192[rbp]
	addsd	xmm0, xmm1
	movsd	QWORD PTR -2192[rbp], xmm0
	add	QWORD PTR -2176[rbp], 997
.L41:
	cmp	QWORD PTR -2176[rbp], 4194303
	jbe	.L42
	mov	QWORD PTR -2168[rbp], 0
	mov	DWORD PTR -2204[rbp], 0
	jmp	.L43
.L44:
	mov	eax, DWORD PTR -2204[rbp]
	cdqe
	mov	rdx, QWORD PTR -2064[rbp+rax*8]
	mov	eax, DWORD PTR -2204[rbp]
	add	eax, 1
	cdqe
	imul	rax, rdx
	add	QWORD PTR -2168[rbp], rax
	add	DWORD PTR -2204[rbp], 1
.L43:
	cmp	DWORD PTR -2204[rbp], 255
	jle	.L44
	movsd	xmm0, QWORD PTR -2096[rbp]
	subsd	xmm0, QWORD PTR -2104[rbp]
	movq	rax, xmm0
	movq	xmm0, rax
	lea	rax, .LC8[rip]
	mov	rdi, rax
	mov	eax, 1
	call	printf@PLT
	movsd	xmm0, QWORD PTR -2088[rbp]
	subsd	xmm0, QWORD PTR -2096[rbp]
	movq	rax, xmm0
	movq	xmm0, rax
	lea	rax, .LC9[rip]
	mov	rdi, rax
	mov	eax, 1
	call	printf@PLT
	movsd	xmm0, QWORD PTR -2080[rbp]
	subsd	xmm0, QWORD PTR -2088[rbp]
	movq	rax, xmm0
	movq	xmm0, rax
	lea	rax, .LC10[rip]
	mov	rdi, rax
	mov	eax, 1
	call	printf@PLT
	movsd	xmm0, QWORD PTR -2072[rbp]
	subsd	xmm0, QWORD PTR -2080[rbp]
	movq	rax, xmm0
	movq	xmm0, rax
	lea	rax, .LC11[rip]
	mov	rdi, rax
	mov	eax, 1
	call	printf@PLT
	movsd	xmm0, QWORD PTR -2072[rbp]
	subsd	xmm0, QWORD PTR -2104[rbp]
	movq	rax, xmm0
	movq	xmm0, rax
	lea	rax, .LC12[rip]
	mov	rdi, rax
	mov	eax, 1
	call	printf@PLT
	mov	rdx, QWORD PTR -2168[rbp]
	movsd	xmm0, QWORD PTR -2192[rbp]
	mov	rax, QWORD PTR -2200[rbp]
	mov	rsi, rdx
	movapd	xmm1, xmm0
	movq	xmm0, rax
	lea	rax, .LC13[rip]
	mov	rdi, rax
	mov	eax, 2
	call	printf@PLT
	mov	rax, QWORD PTR -2152[rbp]
	mov	rdi, rax
	call	free@PLT
	mov	rax, QWORD PTR -2144[rbp]
	mov	rdi, rax
	call	free@PLT
	mov	rax, QWORD PTR -2136[rbp]
	mov	rdi, rax
	call	free@PLT
	mov	rax, QWORD PTR -2128[rbp]
	mov	rdi, rax
	call	free@PLT
	mov	rax, QWORD PTR -2120[rbp]
	mov	rdi, rax
	call	free@PLT
	mov	rax, QWORD PTR -2112[rbp]
	mov	rdi, rax
	call	free@PLT
	mov	eax, 0
.L45:
	mov	rdx, QWORD PTR -8[rbp]
	sub	rdx, QWORD PTR fs:40
	je	.L46
	call	__stack_chk_fail@PLT
.L46:
	leave
	ret
	.size	main, .-main
	.section	.rodata
	.align 4
.LC0:
	.long	1199570944
	.align 4
.LC1:
	.long	1132462080
	.align 4
.LC3:
	.long	981668463
	.align 4
.LC4:
	.long	1056964608
	.align 8
.LC5:
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
