; File: src/aes128_lin.asm

; Just as in the Windows template - we tell the assembler which type of output we expext. 
; In this case it is 32-bit executable ELF
format ELF executable

; Tell the assembler where the entry point is
entry _start

; On *nix based systems, when in memory, the space is arranged into segments, rather than in sections,
; therefore, we define two segments:
; Code segment (executable segment)
segment readable executable

; Here is our entry point
_start:
	       ; First of all we have to expand the key
	; into AES key schedule.
	lea	   esi, [k]
	movups	   xmm1, [esi]
	lea	   edi, [s]

	; Copy initial key to schedule
	mov	   ecx, 4
	rep	   movsd
	call	   aes_set_encrypt_key

	; Actually encrypt data
	lea	   esi, [s]	; ESI points to key schedule
	lea	   edi, [r]	; EDI points to result buffer
	lea	   eax, [d]	; EAX points to data we want
				; to encrypt
	movups	   xmm0, [eax]	; Load this data to XMM0

	; Call the AES128 encryption function
	call	   aes_encrypt

	jmp	   terminate_process


; AES128 encryption function
aes_encrypt:   ; esi points to key schedule
	       ; edi points to output buffer
	       ; xmm0 contains data to be encrypted
	mov		ecx, 9

	movups		xmm1, [esi]
	add		esi, 0x10
	pxor		xmm0, xmm1

    .encryption_loop:
	movups		xmm1, [esi]
	add		esi, 0x10
	aesenc		xmm0, xmm1
	loop		.encryption_loop

	movups		xmm1, [esi]
	aesenclast	xmm0, xmm1

	lea		edi, [r]
	movups		[edi], xmm0
	ret

; AES128 key setup functions
aes_set_encrypt_key:	 ; xmm1 contains the key
			 ; edi points to key schedule
	aeskeygenassist xmm2, xmm1, 1
	call		key_expand
	aeskeygenassist xmm2, xmm1, 2
	call		key_expand
	aeskeygenassist xmm2, xmm1, 4
	call		key_expand
	aeskeygenassist xmm2, xmm1, 8
	call		key_expand
	aeskeygenassist xmm2, xmm1, 0x10
	call		key_expand
	aeskeygenassist xmm2, xmm1, 0x20
	call		key_expand
	aeskeygenassist xmm2, xmm1, 0x40
	call		key_expand
	aeskeygenassist xmm2, xmm1, 0x80
	call		key_expand
	aeskeygenassist xmm2, xmm1, 0x1b
	call		key_expand
	aeskeygenassist xmm2, xmm1, 0x36
	call		key_expand
	ret

key_expand:		; xmm2 contains key portion
			; edi points to place in schedule
			; where this portion should
			; be stored at
	pshufd	  xmm2, xmm2, 0xff
	vpslldq   xmm3, xmm1, 0x04
	pxor	  xmm1, xmm3
	vpslldq   xmm3, xmm1, 0x04
	pxor	  xmm1, xmm3
	vpslldq   xmm3, xmm1, 0x04
	pxor	  xmm1, xmm3
	pxor	  xmm1, xmm2
	movups	  [edi], xmm1
	add	  edi, 0x10
	ret

terminate_process:
	; Set return value to 0
	xor	ebx, ebx
	mov	eax, ebx
	
	; Set eax to 1 - 32-bit Linux SYS_exit system call number
	inc eax
	
	; Call kernel
	int 0x80


; Data segment
segment readable writeable
	d	db   0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0xa,0xb, 0xc, 0xd, 0xe, 0xf
	k	db   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	s	rb   16 * 11
	r	rb   16


; As you see, there is no import/export segment here. The structure of an ELF executable/object file
; will be covered in more detail in chapter 9