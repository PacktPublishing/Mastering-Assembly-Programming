
type_dll	equ 0
type_obj	equ 1

platform_w32	equ 2
platform_w64	equ 4
platform_l32	equ 8
platform_l64	equ 16

TARGET_W32_DLL	equ platform_w32 or type_dll
TARGET_W32_OBJ	equ platform_w32 or type_obj
TARGET_W64_DLL	equ platform_w64 or type_dll
TARGET_W64_OBJ	equ platform_w64 or type_obj
TARGET_L32_O	equ platform_l32 or type_obj
TARGET_L64_O	equ platform_l64 or type_obj



seed = %t

macro fill_random count
{
	local a, b
	a = 0
	while a < count
		seed = ((seed shr 11) xor (seed * 12543)) and 0xffffffff
		b = seed and 0xff
		db   b
		a = a + 1
	end while
}



macro set_output_format
{
   if ACTIVE_TARGET = TARGET_W32_DLL
      include 'win32a.inc'
      format PE DLL
      entry DllMain

   else if ACTIVE_TARGET = TARGET_W32_OBJ
      format MS COFF

   else if ACTIVE_TARGET = TARGET_W64_DLL
      include 'win64a.inc'
      format PE64 DLL
      entry DllMain

   else if ACTIVE_TARGET = TARGET_W64_OBJ
      format MS64 COFF

   else if ACTIVE_TARGET = TARGET_L32_O
      format ELF

   else if ACTIVE_TARGET = TARGET_L64_O
      format ELF64

   end if
}

macro begin_code_section
{
   if ACTIVE_TARGET = TARGET_W32_DLL
      section '.text' code readable executable
	 DllMain:
	    xor eax, eax
	    inc eax
	    ret 4 * 3

   else if ACTIVE_TARGET = TARGET_W32_OBJ
      section '.text' code readable executable

   else if ACTIVE_TARGET = TARGET_W64_DLL
      section '.text' code readable executable
	 DllMain:
	    xor rax, rax
	    inc eax
	    ret

   else if ACTIVE_TARGET = TARGET_W64_OBJ
      section '.text' code readable executable

   else if ACTIVE_TARGET = TARGET_L32_O
      section '.text' executable

   else if ACTIVE_TARGET = TARGET_L64_O
      section '.text' executable

   end if
}


macro begin_data_section
{
   if ACTIVE_TARGET = TARGET_W32_DLL
      section '.data' data readable writeable

   else if ACTIVE_TARGET = TARGET_W32_OBJ
      section '.data' data readable writeable

   else if ACTIVE_TARGET = TARGET_W64_DLL
      section '.data' data readable writeable

   else if ACTIVE_TARGET = TARGET_W64_OBJ
      section '.data' data readable writeable align 16

   else if ACTIVE_TARGET = TARGET_L32_O
      section '.data' writeable

   else if ACTIVE_TARGET = TARGET_L64_O
      section '.data' writeable

   end if
}


macro finalize
{
   ;common
   if ACTIVE_TARGET = TARGET_W32_DLL
      section '.edata' export data readable
	 ;forward
	 export 'MA_CRYPTO.DLL',\
	    GetPointers, 'GetPointers'

      section '.reloc' fixups data readable discardable

   else if ACTIVE_TARGET = TARGET_W32_OBJ
      public GetPointers as '_GetPointers'

   else if ACTIVE_TARGET = TARGET_W64_DLL
      section '.edata' export data readable
	 ;forward
	 export 'MA_CRYPTO.DLL',\
	    GetPointers, 'GetPointers'

   else if ACTIVE_TARGET = TARGET_W64_OBJ
      public GetPointers as 'GetPointers'


   else if ACTIVE_TARGET = TARGET_L32_O
      public GetPointers as 'GetPointers'


   else if ACTIVE_TARGET = TARGET_L64_O
      public GetPointers as 'GetPointers'


   end if
}
