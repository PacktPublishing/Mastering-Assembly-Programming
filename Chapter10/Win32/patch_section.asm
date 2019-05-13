use32
org	0x41e000

label fgets at 0x414bd8
label __acrt_iob_func at 0x41b180

fgets_patch:
    ; Standard cdecl prolog
	push	ebp
	mov		ebp, esp

	; Get stdin stream
	push	0
	call	dword[__acrt_iob_func]
	add		esp, 4

	; Forward the call to fgets
	push	eax					; stdin
	push	128					; max length of input
	push	dword [ebp + 8]     ; input buffer
	call	fgets
	add		esp, 4 * 3	    ; restore the stack
	
	; Standard cdecl epilog
	mov		esp, ebp
	pop		ebp
	ret
