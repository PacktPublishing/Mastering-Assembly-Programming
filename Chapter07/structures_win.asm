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

struc strtabentry [s]
{
	.length   dw	  .pad - .string
	.string   db	  s, 0
	.pad	  rb	  30 - (.pad - .string)
	.previous dd	  ?
	.next	  dd	  ?
	.size = $ - .length
}

macro make_links baseAddr
{
	local b
	b = baseAddr

	store dword b + 80 at b + 36
	store dword b + 120 at b + 80 + 36
	store dword b + 40 at b + 120 + 36

	store dword b + 120 at b + 40 + 32
	store dword b + 80 at b + 120 + 32
	store dword b at b + 80 + 32
}

macro make_strtab strtabName, [strings]
{
	common
	label strtabName#_ptr dword
	local c
	c = 0

	forward
	c = c + 1

	common
	dd  c

	forward
	local a
	dd    a

	common
	label strtabName dword

	forward
	a strtabentry strings
}

get_string_length:
	push	ebp
	mov	ebp, esp
	push	ebx ecx

	virtual at ebp + 8
		.structPtr	 dd ?
		.structIdx	 dd ?
	end virtual

	virtual at ebx + ecx
		.s strtabentry ?
	end virtual

	mov	ebx, [.structPtr]
	mov	ecx, [.structIdx]
	shl	ecx, 5
	mov	ax, [.s.length]
	movzx	eax, ax
	dec	eax
	pop	ecx ebx
	leave
	ret	8

add_node:
	push	ebp
	mov	ebp, esp
	push	eax ebx ecx

	virtual at ebp + 8
		.topPtr  dd	?
		.nodePtr dd	?
	end virtual

	virtual at ebx
		.s0 strtabentry ?
	end virtual
	virtual at ecx
		.s1 strtabentry ?
	end virtual

	mov	eax, [.topPtr]
	mov	ebx, [.nodePtr]
	or	dword[eax],0
	jz	@f

	mov	.s1, [eax]
	mov	[.s0.next], ecx
	mov	[.s1.previous], ebx

     @@:
	mov	[eax], ebx
	pop	ecx ebx eax
	leave
	ret	8

; Entry point
_start:
   push strtab + 40
   push list_top
   call add_node

   push strtab + 120
   push list_top
   call add_node

   push strtab + 80
   push list_top
   call add_node

   push strtab
   push list_top
   call add_node
   nop


   ; We have to terminate the process properly
   ; Put return code on stack
   push  0
   ; Call ExitProcess Windows API function
   call [exitProcess]

; '.data' section: contains data, is readable, may be writeable
section '.data' data readable writeable
   ;
   ; Put your data here
   ;
		dd   0
	make_strtab strtab,\
		    "string 0",\
		    "string 1 ",\
		    "string 2  ",\
		    "string 3   "
	list_top    dd	    0

	;make_links strtab

; '.idata' section: contains import information, is readable, is writeable
section '.idata' import data readable writeable



; 'library' macro from 'win32a.inc' creates proper entry for importing
; functions from a dynamic link library. For now it is only 'kernel32.dll'.
library kernel, 'kernel32.dll'

; 'import' macro creates the actual entries for functions we want to import from a dynamic link library
import kernel,\
   exitProcess, 'ExitProcess'

