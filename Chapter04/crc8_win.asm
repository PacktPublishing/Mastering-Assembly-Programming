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

; Entry point
_start:

   ;
   ; Put your code here
   ;
   ;lea  ebx, [my_far_ptr]
   mov	 ax, fs
   mov	 gs, ax
   mov	 edx, 0
   mov	 eax, [gs:edx]

   mov	word[my_far_ptr + 4], fs
   lgs	edx, [my_far_ptr]
   mov	eax, [gs:edx]
   mov	eax, [eax + 0x30]
   mov	ebx, [fs:0x30]

   mov	al, 0x16
   call crc8

   ; We have to terminate the process properly
   ; Put return code on stack
   push  0
   ; Call ExitProcess Windows API function
   call [exitProcess]

crc8:
	push	ebx ecx edx
	xor	dl, dl
	mov	ecx, 8
  .crc_loop:
	shl	al, 1
	setc	bl
	shl	dl, 1
	setc	bh
	xor	bl, bh
	jz	.noxor
	xor	dl, 0x31
  .noxor:
	loop	.crc_loop
	mov	al, dl
	pop	edx ecx ebx
	ret



; '.data' section: contains data, is readable, may be writeable
section '.data' data readable writeable
   ;
   ; Put your data here
   ;
   dd	0
   some_string db 'some string',0


   my_far_ptr	dp 0x0
		dw 0x0

; '.idata' section: contains import information, is readable, is writeable
section '.idata' import data readable writeable

; 'library' macro from 'win32a.inc' creates proper entry for importing
; functions from a dynamic link library. For now it is only 'kernel32.dll'.
library kernel, 'kernel32.dll'

; 'import' macro creates the actual entries for functions we want to import from a dynamic link library
import kernel,\
   exitProcess, 'ExitProcess'

