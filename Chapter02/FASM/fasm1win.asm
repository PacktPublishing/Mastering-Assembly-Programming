
   include 'win32a.inc'

   format PE GUI
   entry _start

   section '.text' code readable executable
   _start:
	   push    0
	   push    0
	   push    title
	   push    message
	   push    0
	   call    [MessageBox]
	   call    [ExitProcess]

   section '.data' data readable writeable
	   message db	'Hello from FASM!', 0x00
	   title   db	'Hello!', 0x00

   section '.idata' import data readable writeable

   library kernel, 'kernel32.dll',\
	   user, 'user32.dll'

   import kernel,\
	  ExitProcess, 'ExitProcess'

   import user,\
	  MessageBox, 'MessageBoxA'
