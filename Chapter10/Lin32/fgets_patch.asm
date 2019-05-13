
format ELF 

public gets as 'gets'
extrn fgets
extrn stdin

section '.text' executable

gets:
	push	ebp
	mov		ebp, esp
	
	mov		eax, [_stdin]
	push	dword [eax]
	push	127
	push	dword[ebp + 8]
	call	[_fgets]
	add		esp, 12
	
	mov		esp, ebp
	pop		ebp
	ret

section '.idata' writeable

	_msg	db	"This is fgets analog", 10
	_msglen = $ - _msg
	_fgets	dd	fgets
	_stdin	dd	stdin
