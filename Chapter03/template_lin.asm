; File: src/template_lin.asm

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
	;
	; Put your code here
	;

	; Set return value to 0
	xor	ebx, ebx
	mov	eax, ebx
	
	; Set eax to 1 - 32-bit Linux SYS_exit system call number
	inc eax
	
	; Call kernel
	int 0x80


; Data segment
segment readable writeable
	db	0


; As you see, there is no import/export segment here. The structure of an ELF executable/object file
; will be covered in more detail in chapter 9