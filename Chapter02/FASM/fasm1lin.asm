
   format ELF executable 3
   entry _start

   segment readable executable
   _start:
	 mov	eax, 4
	 mov	ebx, 1
	 mov	ecx, message
	 mov	edx, len
	 int	0x80

	 xor	ebx, ebx
	 mov	eax, ebx
	 inc	eax
	 int	0x80


   segment readable writeable
	 message db  'Hello from FASM on Linux!', 0x0a
	 len = $ - message
