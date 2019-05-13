; File: src\template_win.asm

; First of all, we tell the compiler which type of executable
; we want it to be. In our case it is a 32-bit PE executable.
format PE GUI

; Tell the compiler where we want our program to start - define
; the entry point. We want it to be at the place labeled with '_start'.
entry _start

; The following line includes a set of macros, shipped with FASM,
; which are essential for Windows program. We can, of course, implement
; all we need ourselves, and we will do that in chapter 9.
include 'win32a.inc'


; PE file consists of at least one section. In this template we only need 3:
;    1. '.text' - section that contains executable code
;    2. '.data' - section that contains data
;    3. '.idata' - section that contains import information
;
; '.text' section: contains code, is readable, is executable
section '.text' code readable executable

struc tnode dataPtr, leftChild, rightChild
{
	.left		dd	leftChild
	.right		dd	rightChild
	.data		dd	dataPtr
}

struc instruction opcode, target
{
	.opcode dd	opcode
	.target dd	target
}


; unsigned int tree_lookup(void* treePtr, unsigned int code)
tree_lookup:
	push	ebp
	mov	ebp, esp
	push	ebx ecx

	virtual at ebp + 8
		.treePtr dd	?
		.code	 dd	?
	end virtual
	virtual at ecx
		.node	tnode ?,?,?
	end virtual
	virtual at eax
		.instr	instruction ?, ?
	end virtual

	mov	ecx, [.treePtr]
	mov	ecx, [ecx]
	mov	ebx, [.code]
	movzx	ebx, bl

    @@:
	or	ecx, 0
	jz	.no_such_thing

	mov	eax, [.node.data]
	cmp	ebx, [.instr.opcode]
	jz	@f
	ja	.go_right
	mov	ecx, [.node.left]
	jmp	@b
    .go_right:
	mov	ecx, [.node.right]
	jmp	@b

    @@:
	;add	 eax, [.instr.target]
	mov	eax, [.instr.target]
    @@:
	pop	ecx ebx
	leave
	ret	8

    .no_such_thing:
	xor	eax, eax
	jmp	@b




; void run_vm(char* cmd_buffer, char* data_buffer, int len, char key)
run_vm:
	push	ebp
	mov	ebp, esp
	sub	esp, 4 * 3
	push	eax ebx ecx edx esi

	virtual at ebp + 8
		.p_cmd_buffer_ptr	dd	?
		.p_data_buffer_ptr	dd	?
		.p_data_length		dd	?
		.p_key			dd	?
	end virtual
	virtual at ebp - 0x0c
		.register_a		db	?
		.register_b		db	?
		.register_key		db	?
		.register_cnt		db	?
		.data_base		dd	?
		.data_length		dd	?
	end virtual

	mov	eax, [.p_data_buffer_ptr]
	mov	[.data_base], eax
	xor	ebx, ebx		; Would be instruction pointer
	mov	esi, [.p_cmd_buffer_ptr]

    .virtual_loop:
	mov	al, [esi + ebx]
	movzx	eax, al
	push	eax
	push	tree_root
	call	tree_lookup
	or	eax, 0
	jz	.exit
	jmp	eax

    .load_key:		     ;00
	inc	ebx
	mov	eax, [.p_key]
	mov	[.register_key], al
	jmp	.virtual_loop

    .nop:		     ;01
	inc	ebx
	jmp	.virtual_loop

    .load_data_length:	     ;02
	inc	ebx
	mov	eax, [.p_data_length]
	mov	[.data_length], eax
	mov	[.register_cnt], 0
	jmp	.virtual_loop

    .loop:		     ;10
	mov	eax, [esi + ebx + 1]
	add	ebx, 5
	inc	byte[.register_cnt]
	mov	ecx, [.data_length]
	cmp	cl, [.register_cnt]
	jz	@f
	add	ebx, eax
    @@:
	jmp	.virtual_loop

    .jmp:		    ;11
	mov	eax, [esi + ebx + 1]
	lea	ebx, [ebx + eax + 2]
	add	ebx, eax
	jmp	.virtual_loop

    .encrypt:		     ;20
	mov	al, [.register_key]
	mov	ah, [esi + ebx + 1]
	add	ebx, 2
	cmp	ah, register_a
	jnz	@f
	mov	ah, [.register_a]
	xor	ah, al
	mov	[.register_a], ah
	jmp	.virtual_loop
    @@:
	cmp	ah, register_b
	jnz	.virtual_loop
	mov	ah, [.register_b]
	xor	ah, al
	mov	[.register_b], ah
	jmp	.virtual_loop

    .decrement: 	     ;21
	mov	al, [esi + ebx + 1]
	add	ebx, 2
	cmp	al, register_a
	jnz	@f
	dec	byte [.register_a]
	jmp	.virtual_loop
    @@:
	cmp	al, register_b
	jnz	@f
	dec	byte [.register_b]
	jmp	.virtual_loop
    @@:
	cmp	al, register_cnt
	jnz	.virtual_loop
	dec	byte [.register_cnt]
	jmp	.virtual_loop


    .increment: 	     ;22
	mov	al, [esi + ebx + 1]
	add	ebx, 2
	cmp	al, register_a
	jnz	@f
	inc	byte [.register_a]
	jmp	.virtual_loop
    @@:
	cmp	al, register_b
	jnz	@f
	inc	byte [.register_b]
	jmp	.virtual_loop
    @@:
	cmp	al, register_cnt
	jnz	.virtual_loop
	inc	byte [.register_cnt]
	jmp	.virtual_loop

    .load_data_byte:	     ;30
	mov	al, [esi + ebx + 1]
	add	ebx, 2
	mov	dl, [.register_cnt]
	movzx	edx, dl
	add	edx, [.data_base]
	cmp	al, register_a
	jnz	@f
	mov	al, [edx]
	mov	[.register_a], al
	jmp	.virtual_loop
    @@:
	cmp	al, register_b
	jnz	@f
	mov	al, [edx]
	mov	[.register_b], al
	jmp	.virtual_loop
    @@:
	cmp	al, register_cnt
	jnz	.virtual_loop
	mov	al, [edx]
	mov	[.register_cnt], al
	jmp	.virtual_loop


    .store_data_byte:	     ;31
	mov	al, [esi + ebx + 1]
	add	ebx, 2
	mov	dl, [.register_cnt]
	movzx	edx, dl
	add	edx, [.data_base]
	cmp	al, register_a
	jnz	@f
	mov	al, [.register_a]
	mov	[edx], al
	jmp	.virtual_loop
    @@:
	cmp	al, register_b
	jnz	@f
	mov	al, [.register_b]
	mov	[edx], al
	jmp	.virtual_loop
    @@:
	cmp	al, register_cnt
	jnz	.virtual_loop
	mov	al, [.register_cnt]
	mov	[edx], al
	jmp	.virtual_loop

    .exit:		     ;12
	pop	esi edx ecx ebx eax
	add	esp, 4 * 3
	leave
	ret	4 * 4

; int tree_to_vine(root_ptr)
tree_to_vine:
	push	ebp
	mov	ebp, esp

	push	ebx ecx edx esi

	xor	esi, esi

	virtual at eax
		.root tnode ?, ?, ?
	end virtual
	virtual at ebx
		.tail tnode ?, ?, ?
	end virtual
	virtual at ecx
		.temp tnode ?, ?, ?
	end virtual
	virtual at edx
		.rest tnode ?, ?, ?
	end virtual

	mov	eax, [ebp + 8]
	mov	ebx, eax
	mov	edx, [.tail.right]
     @@:
	or	edx, 0
	jz	.out

	or	dword[.rest.left], 0
	jnz	.has_left
	mov	ebx, edx
	mov	edx, [.rest.right]
	inc	esi
	jmp	@b

     .has_left:
	mov	ecx, [.rest.left]
	push	dword [.temp.right]
	pop	dword [.rest.left]
	mov	[.temp.right], edx
	mov	edx, ecx
	mov	[.tail.right], ecx
	jmp	@b

     .out:
	mov	eax, esi
	pop	esi edx ecx ebx

	leave
	ret	4

log2_size:
	push	ebp
	mov	ebp, esp
	lea	eax, [ebp + 8]
	fld1
	fild	dword[eax]
	fyl2x
	fwait
	fistp	 dword[eax]
	mov	eax, [eax]
	leave
	ret	4


; void compress(root, count)
compress:
	push	ebp
	mov	ebp, esp
	push	eax ebx ecx edx

	virtual at eax
		.root	tnode ?, ?, ?
	end virtual
	virtual at ebx
		.scan	tnode ?, ?, ?
	end virtual
	virtual at edx
		.child	tnode ?, ?, ?
	end virtual

	mov	eax, [ebp + 8]
	mov	ecx, [ebp + 12]
	mov	ebx, eax

    @@:
	mov	edx, [.scan.right]
	push	dword [.child.right]
	pop	dword [.scan.right]
	mov	ebx, [.scan.right]
	push	dword [.scan.left]
	pop	dword [.child.right]
	mov	[.scan.left], edx
	loop	@b


	pop	edx ecx ebx eax
	leave
	ret	8

; void vine_to_tree(root, size)
vine_to_tree:
	push	ebp
	mov	ebp, esp

	virtual at edx
		.root	tnode ?, ?, ?
	end virtual


	mov	ebx, [ebp + 12]
	mov	edx, [ebp + 8]


	push	ebx
	call	log2_size
	movzx	ecx, al
	mov	eax, 1
	shl	eax, cl
	mov	ecx, ebx
	inc	ecx
	sub	ecx, eax
	push	ecx
	push	edx
	call	compress
	sub	ebx, ecx

     @@:
	cmp	ebx, 1
	jbe	@f
	shr	ebx, 1
	push	ebx
	push	edx
	call	compress
	jmp	@b

     @@:
	leave
	ret	8

; Entry point
_start:
   push 0xa5			; key byte
   push data_to_encrypt_len	; length of data to be encrypted
   push data_to_encrypt 	; pointer to date to be encrypted
   push vm_code_start		; pointer to virtual code buffer
   call run_vm

   ; We have to terminate the process properly
   ; Put return code on stack
   push  0
   ; Call ExitProcess Windows API function
   call [exitProcess]

; '.data' section: contains data, is readable, may be writeable
section '.data' data readable writeable

   include 'vm_code.asm'

   t_load_key		tnode i_load_key,\
			      0,\
			      0
   t_nop		tnode i_nop,\
			      t_load_key,\
			      t_load_data_length
   t_load_data_length	tnode i_load_data_length,\
			      0,\
			      0
   t_loop		tnode i_loop,\
			      t_nop,\
			      t_jmp
   t_jmp	       tnode i_jump,\
			      0,\
			      0
   t_exit		tnode i_exit,\
			      t_loop,\
			      t_decrement
   t_encrypt		tnode i_encrypt,\
			      0,\
			      0
   t_decrement		tnode i_decrement,\
			      t_encrypt,\
			      t_load_data_byte
   t_increment		tnode i_increment,\
			      0,\
			      0
   t_load_data_byte	tnode i_load_data_byte,\
			      t_increment,\
			      t_store_data_byte
   t_store_data_byte	tnode i_store_data_byte,\
			      0,\
			      0

   i_load_key		instruction 0x00,\
				    run_vm.load_key; - i_load_key
   i_nop		instruction 0x01,\
				    run_vm.nop; - i_nop
   i_load_data_length	instruction 0x02,\
				    run_vm.load_data_length; - i_load_data_length
   i_loop		instruction 0x10,\
				    run_vm.loop; - i_loop
   i_jump		instruction 0x11,\
				    run_vm.jmp; - i_jump
   i_exit		instruction 0x12,\
				    run_vm.exit; - i_exit
   i_encrypt		instruction 0x20,\
				    run_vm.encrypt; - i_encrypt
   i_decrement		instruction 0x21,\
				    run_vm.decrement; - i_decrement
   i_increment		instruction 0x22,\
				    run_vm.increment; - i_increment
   i_load_data_byte	instruction 0x30,\
				    run_vm.load_data_byte; - i_load_data_byte
   i_store_data_byte	instruction 0x31,\
				    run_vm.store_data_byte; - i_store_data_byte

   tree_root	  dd	t_exit

   data_to_encrypt	db	"This is the data to encrypt",0
   data_to_encrypt_len = $ - data_to_encrypt

   pseudo_root		tnode ?, ?, t_exit



; '.idata' section: contains import information, is readable, is writeable
section '.idata' import data readable writeable



; 'library' macro from 'win32a.inc' creates proper entry for importing
; functions from a dynamic link library. For now it is only 'kernel32.dll'.
library kernel, 'kernel32.dll'

; 'import' macro creates the actual entries for functions we want to import from a dynamic link library
import kernel,\
   exitProcess, 'ExitProcess'

