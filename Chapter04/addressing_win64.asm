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

; PE file consists of at least one section. In this template we only need 3:
;    1. '.text' - section that contains executable code
;    2. '.data' - section that contains data
;    3. '.idata' - section that contains import information
;
; '.text' section: contains code, is readable, is executable
section '.text' code readable executable

; Entry point
_start:
   mov	rbp, rsp
   sub	rsp, 0x50
   lea	rdi, [rsp + 0x10]
   lea	rsi, [ro_string]
   mov	rsp, rbp
   pop	rbp


   mov	rsp, rbp
   ; We have to terminate the process properly
   ; Put return code on stack
   push  0
   ; Call ExitProcess Windows API function
   call [exitProcess]

   ; Read only string
   ro_string		db	 'This is a readonly string',0
   ro_string_len = $ - ro_string

   align 8
my_proc0:
   push rbp
   mov	rbp, rsp
   xor	eax, eax
   mov	rsp, rbp
   pop	rbp
   ret


   align 8
my_proc1:
   push rbp
   mov	rbp, rsp
   xor	eax, eax
   inc	eax
   mov	rsp, rbp
   pop	rbp
   ret

; '.data' section: contains data, is readable, may be writeable
section '.data' data readable writeable
   ;
   ; Put your data here
   ;
   dq	0
   my_proc_address	dq my_proc0, my_proc1

; '.idata' section: contains import information, is readable, is writeable
section '.idata' import data readable writeable

; 'library' macro from 'win32a.inc' creates proper entry for importing
; functions from a dynamic link library. For now it is only 'kernel32.dll'.
library kernel, 'kernel32.dll'

; 'import' macro creates the actual entries for functions we want to import from a dynamic link library
import kernel,\
   exitProcess, 'ExitProcess'

