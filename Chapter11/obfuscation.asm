

; random - sets r to a pseudo random value
random_seed = %t
macro	  random r
{
	random_seed = ((random_seed*214013+2531011) shr 16) and 0xffffffff
	r = random_seed
}


; Use this only with procedures returning result in EAX
; or take care of preserving the EAX register otherwise
macro	f_call	callee
{
	local .reference_addr, .out, .ret_addr, .z, .call

	; Calculate the reference address
	call	.call
   .call:
	add	dword[esp], .reference_addr - .call
	ret
	random	.z
	dd	.z

   .reference_addr:
	; Calculate the callee address
	load .z dword from .reference_addr - 4
	mov	eax, [esp-4]
	mov	eax, [eax-4]
	xor	eax, callee xor .z
	; Setup return address
	; The return address is within this macro
	sub	esp, 4
	add	dword[esp], .ret_addr - .reference_addr
	; Jump to callee
	jmp	eax

	random	.z
	dd	.z
	random	.z
	dd	.z

	; This code is executed upon return
	; from the callee
   .ret_addr:
	sub	dword[esp - 4], -(.out - .ret_addr)
	sub	esp, 4
	ret

	random	.z
	dd	.z

   .out:
}
