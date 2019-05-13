
format PE GUI

entry _start

include 'win32a.inc'

section '.text' code readable executable

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Entry point
;-----------------------------------------------------
_start:
	mov	     ecx, 20

	mov	     eax, [bmonth]
	dec	     eax
	mov	     eax, [mtab + eax * 4]
	mov	     [bmonth], eax

	mov	     eax, [cmonth]
	dec	     eax
	mov	     eax, [mtab + eax * 4]
	mov	     [cmonth], eax

	xor	     eax, eax

	movapd	     xmm0, xword[cday]
	movapd	     xmm1, xword[cmonth]
	cvtdq2ps     xmm0, xmm0
	cvtdq2ps     xmm1, xmm1

	movq	     xmm2, qword[dpy]
	movlhps      xmm2, xmm2
	addps	     xmm1, xmm0
	mulps	     xmm2, xmm1
	haddps	     xmm2, xmm2
	hsubps	     xmm2, xmm2

	movd	     xmm3, [dpy]
	movlhps      xmm3, xmm3
	movsldup     xmm3, xmm3

	movd	     xmm4, [pi_2]
	movlhps      xmm4, xmm4
	movsldup     xmm4, xmm4

	movaps	     xmm1, xword[T]
	pinsrd	     xmm1, eax, 3
	lea	     eax, [output]

   .calc_loop:
	addps	     xmm2, xmm3
	movaps	     xmm0, xmm4
	mulps	     xmm0, xmm2
	divps	     xmm0, xmm1
	call	     adjust

	call	     sin_taylor_series

	movaps	     [eax], xmm0

	add	     eax, 16
	;dec	      ecx
	;jnz	      .calc_loop
	loop	     .calc_loop

	push  0
	call [exitProcess]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Value adjustment before calculation of SIN()
; Parameter is in XMM0 register
; Return value is in XMM0 register
;-----------------------------------------------------
adjust:
	push	     ebp
	mov	     ebp, esp
	sub	     esp, 16 * 2

	movups	     [ebp - 16], xmm1
	movups	     [ebp - 16 * 2], xmm2

	movd	     xmm1, [pi_2]
	movlhps      xmm1, xmm1
	movsldup     xmm1, xmm1
	movaps	     xmm2, xmm0
	divps	     xmm2, xmm1
	roundps      xmm2, xmm2, 1b
	mulps	     xmm2, xmm1
	subps	     xmm0, xmm2

	movups	     xmm2, [ebp - 16 * 2]
	movups	     xmm1, [ebp - 16]

	mov	     esp, ebp
	pop	     ebp
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Calculation of SIN() using the Taylor Series
; approximation:
; sin(x) = x - x^3/3! + x^5/5! - x^7/7! + x^9/9! ...
; Values to calculate the SIN() of are in XMM0 register
; Return values are in XMM0 register
;-----------------------------------------------------
sin_taylor_series:
	push	     ebp
	mov	     ebp, esp
	sub	     esp, 5 * 16
	push	     eax ecx
	xor	     eax, eax
	xor	     ecx, ecx

	movups	     [ebp - 16], xmm1
	movups	     [ebp - 16 * 2], xmm2
	movups	     [ebp - 16 * 3], xmm3
	movups	     [ebp - 16 * 4], xmm4
	movups	     [ebp - 16 * 5], xmm5

	movaps	     xmm1, xmm0
	movaps	     xmm2, xmm0

	mov	     ecx,  3

   .l1:
	movaps	     xmm0, xmm2
	call	     pow
	movaps	     xmm3, xmm0

	call	     fact
	movaps	     xmm4, xmm0

	divps	     xmm3, xmm4
	test	     eax, 1
	jnz	     .plus
	subps	     xmm1, xmm3
	jmp	     @f
   .plus:
	addps	     xmm1, xmm3
   @@:
	add	     ecx, 2
	inc	     eax
	cmp	     eax, 8
	jb	     .l1

	movaps	     xmm0, xmm1

	movups	     xmm1, [ebp - 16]
	movups	     xmm2, [ebp - 16 * 2]
	movups	     xmm3, [ebp - 16 * 3]
	movups	     xmm4, [ebp - 16 * 4]
	movups	     xmm5, [ebp - 16 * 5]

	pop	     ecx eax
	mov	     esp, ebp
	pop	     ebp
	ret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Trivial exponentiation function
; Parameters are:
; Values to exponentiate in XMM0
; Exponent is in ECX
; Return values are in XMM0
;-----------------------------------------------------
pow:
	push	     ebp
	mov	     ebp, esp
	sub	     esp, 16

	push	     ecx
	dec	     ecx
	movups	     [ebp - 16], xmm1

	movaps	     xmm1, xmm0
   .l1:
	mulps	     xmm0, xmm1
	loop	     .l1

	movups	     xmm1, [ebp - 16]
	pop	     ecx
	mov	     esp, ebp
	pop	     ebp
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Simple calculation of factorial
; Parameter is in ECX (number to calculate the factorial of)
; Return value is in XMM0 register
;-----------------------------------------------------
fact:
	push	     ebp
	mov	     ebp, esp
	sub	     esp, 16 * 3

	push	     ecx
	movups	     [ebp - 16], xmm1
	movups	     [ebp - 16 * 2], xmm2
	mov	     dword[ebp - 16 * 3], 1.0
	movd	     xmm2, [ebp - 16 * 3]
	movlhps      xmm2, xmm2
	movsldup     xmm2, xmm2
	movaps	     xmm0, xmm2
	movaps	     xmm1, xmm2

   .l1:
	mulps	     xmm0, xmm1
	addps	     xmm1, xmm2
	loop	     .l1

	movups	     xmm2, [ebp - 16 * 2]
	movups	     xmm1, [ebp - 16]
	pop	     ecx
	mov	     esp, ebp
	pop	     ebp
	ret


section '.data' data readable writeable
	; Current date and birth date
	; The dates are arranged in a way most suitable
	; for use with XMM registers
	cday	dd	      9
	cyear	dd	      2017
	bday	dd	      16
	byear	dd	      1979

	cmonth	dd	      5
		dd	      0
	bmonth	dd	      1
		dd	      0


	; These values are used for calculation of days
	; in both current and birth dates
	dpy	dd	      1.0
		dd	      365.25

	; This table specifies number of days since the new year
	; till the first day of specified month.
	; Table's indices are zero based
	mtab:
		dd	      0 	; January
		dd	      31	; February
		dd	      59	; March
		dd	      90	; April
		dd	      120	; May
		dd	      151	; June
		dd	      181	; July
		dd	      212	; August
		dd	      243	; September
		dd	      273	; October
		dd	      304	; November
		dd	      334	; December

  align 16
	; Biorhythmic periods
	T	dd	      23.0	; Physical
		dd	      28.0	; Emotional
		dd	      33.0	; Intellectual

	pi_2	dd	      6.28318	; 2xPI - used in formula

  align 16
	; Result storage
	; Arranged as table:
	; Physical : Emotional : Intellectual
	output	rd	      20 * 4

; '.idata' section: contains import information, is readable, is writeable
section '.idata' import data readable writeable

; 'library' macro from 'win32a.inc' creates proper entry for importing
; functions from a dynamic link library. For now it is only 'kernel32.dll'.
library kernel, 'kernel32.dll'

; 'import' macro creates the actual entries for functions we want to import from a dynamic link library
import kernel,\
   exitProcess, 'ExitProcess'

