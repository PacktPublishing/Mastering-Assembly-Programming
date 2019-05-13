; File: src\template_win.asm

; First of all, we tell the compiler which type of executable
; we want it to be. In our case it is a 32-bit PE executable.
format PE64 GUI

; Tell the compiler where we want our program to start - define
; the entry point. We want it to be at the place labeled with '_start'.
entry _start

; The following line includes a set of macros, shipped with FASM,
; which are essential for Windows program. We can, of course, implement
; all we need ourselves, and we will do that in chapter 9.
include 'win64a.inc'

macro ms64_call procName, [args]
{
	a = 0
	if ~args eq
	   forward
	   if a = 0
	      push    rcx
	      mov     rcx, args
	   else if a = 1
	      push    rdx
	      mov     rdx, args
	   else if a = 2
	      push    r8
	      mov     r8, args
	   else if a = 3
	      push    r9
	      mov     r9, args
	   end if
	   a = a + 1
	end if
	common
	sub	rsp, 32
	call	procName
	add	rsp, 32
	forward
	if ~args eq
	   if a = 4
	      pop     r9
	   else if a = 3
	      pop     r8
	   else if a = 2
	      pop     rdx
	   else if a = 1
	      pop     rcx
	   end if
	   a = a - 1
	end if
}

macro amd64_call procName, [args]
{
	a = 0
	if ~args eq
	   forward
	   if a = 0
	      push    rdi
	      mov     rdi, args
	   else if a = 1
	      push    rsi
	      mov     rsi, args
	   else if a = 2
	      push    rdx
	      mov     rdx, args
	   else if a = 3
	      push    rcx
	      mov     rcx, args
	   else if a = 4
	      push     r8
	      mov      r8, args
	   else if a = 5
	      push     r9
	      mov      r9, args
	   end if
	   a = a + 1
	end if
	common
	call	procName
	forward
	if ~args eq
	   if a = 6
	      pop     r9
	   else if a = 5
	      pop     r8
	   else if a = 4
	      pop     rcx
	   else if a = 3
	      pop     rdx
	   else if a = 2
	      pop     rsi
	   else if a = 1
	      pop     rdi
	   end if
	   a = a - 1
	end if
}

; PE file consists of at least one section. In this template we only need 3:
;    1. '.text' - section that contains executable code
;    2. '.data' - section that contains data
;    3. '.idata' - section that contains import information
;
; '.text' section: contains code, is readable, is executable
section '.text' code readable executable

ms64_proc:
	push	rbp
	mov	rbp, rsp
	nop
	mov	rsp, rbp
	pop	rbp
	ret


amd64_proc:
	push	rbp
	mov	rbp, rsp
	nop
	mov	rsp, rbp
	pop	rbp
	ret

; Entry point
_start:

   ms64_call ms64_proc, dummy, 128
   amd64_call amd64_proc, dummy, 128

   ; We have to terminate the process properly
   ; Put return code on stack
   push  0
   ; Call ExitProcess Windows API function
   call [exitProcess]

   ; Read only string
   ro_string		db	 'This is a readonly string',0
   align 8
   ro_string_len = $ - ro_string

	repeat ro_string_len
	      load b byte from ro_string + % - 1
	      store byte b xor 0x5a at ro_string + % -1
	end repeat
; '.data' section: contains data, is readable, may be writeable
section '.data' data readable writeable
   ;
   ; Put your data here
   ;
   dummy	dq 0
   stri 	rb ro_string_len
   my_far_ptr	dq 0xc0
		dw 0x53

		dq 0x1234567890987654

; '.idata' section: contains import information, is readable, is writeable
section '.idata' import data readable writeable

; 'library' macro from 'win32a.inc' creates proper entry for importing
; functions from a dynamic link library. For now it is only 'kernel32.dll'.
library kernel, 'kernel32.dll'

; 'import' macro creates the actual entries for functions we want to import from a dynamic link library
import kernel,\
   exitProcess, 'ExitProcess'

