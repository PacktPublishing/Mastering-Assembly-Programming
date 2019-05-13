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

; Our macroinstructions
macro prolog frameSize, [regs]
{
	common
	push	ebp
	mov	ebp, esp
	sub	esp, frameSize
	forward
	push	regs
}

macro return [regs]
{
	reverse
	pop	regs
	common
	mov	esp, ebp
	pop	ebp
	ret
}

macro ccall procName, [args]
{
	a = 0
	if  ~args eq
		forward
		a = a + 4
		reverse
		push	args
	end if
	common
	call procName
	if a > 0
		add  esp, a
	end if
}

macro exordd p1, p2
{
	if ~p1 in <eax, ebx, ecx, edx, esi, edi, ebp, esp> &\
	   ~p2 in <eax, ebx, ecx, edx, esi, edi, ebp, esp>
	   push   eax
	   mov	  eax, [p2]
	   xor	  [p1], eax
	   pop	  eax
	else
	   if ~p1 in <eax, ebx, ecx, edx, esi, edi, ebp, esp>
	      xor [p1], p2
	   else if ~p2 in <eax, ebx, ecx, edx, esi, edi, ebp, esp>
	      xor p1, [p2]
	   else
	      xor p1, p2
	   end if
	end if
}


; PE file consists of at least one section. In this template we only need 3:
;    1. '.text' - section that contains executable code
;    2. '.data' - section that contains data
;    3. '.idata' - section that contains import information
;
; '.text' section: contains code, is readable, is executable
section '.text' code readable executable

proc_1:
	prolog 12, ecx
	nop
	nop
	return	ecx

; Procedure
my_proc:
	prolog	8, ebx, ecx, edx
	nop
	ccall proc_1
	return ebx, ecx, edx


; Entry point
_start:
   ccall my_proc, 1, 2, 3, 4

   exordd my_var1, my_var2
   nop
   mov	  ebx, [my_var2]
   exordd ebx, my_var1
   mov	  [my_var2], ebx
   exordd my_var1, ebx
   exordd ebx, ebx
   nop
   ;exordd value_3, 5

   irp v, eax, ebx, ecx
   {
	xor v, v
   }

   irps v, eax ebx ecx
   {
	xor v, v
   }



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
   my_var1	dd   0xcafecafe
   my_var2	dd   0x02010201


   hex_chars:
   rept 10 c
   {
	db	'0' + c - 1
   }
   rept 6 cnt
   {
	    db	     'A' + cnt - 1
   }




; '.idata' section: contains import information, is readable, is writeable
section '.idata' import data readable writeable

; 'library' macro from 'win32a.inc' creates proper entry for importing
; functions from a dynamic link library. For now it is only 'kernel32.dll'.
library kernel, 'kernel32.dll'

; 'import' macro creates the actual entries for functions we want to import from a dynamic link library
import kernel,\
   exitProcess, 'ExitProcess'

