
include 'platform.inc'
;include 'protection.inc'

ACTIVE_TARGET = TARGET_W32_DLL

set_output_format

begin_code_section


GetPointers:

   if (ACTIVE_TARGET = TARGET_W32_OBJ) |\
      (ACTIVE_TARGET = TARGET_W32_DLL) |\
      (ACTIVE_TARGET = TARGET_L32_O)

      push  dword pointers
      pop   eax
      mov   [eax], dword f_set_data_pointer
      mov   [eax + 4], dword f_set_data_length
      mov   [eax + 8], dword f_encrypt
      mov   [eax + 12], dword f_decrypt
      ret

   else if (ACTIVE_TARGET = TARGET_W64_OBJ) |\
	   (ACTIVE_TARGET = TARGET_W64_DLL) |\
	   (ACTIVE_TARGET = TARGET_L64_O)

      push  rbx
      mov   rbx, pointers
      mov   rax, rbx
      mov   rbx, f_set_data_pointer
      mov   [rax], rbx
      mov   rbx, f_set_data_length
      mov   [rax + 8], rbx
      mov   rbx, f_encrypt
      mov   [rax + 16], rbx
      mov   rbx, f_decrypt
      mov   [rax + 24], rbx
      pop   rbx
      ret

   end if




f_set_data_pointer:
   if (ACTIVE_TARGET = TARGET_W32_OBJ) |\
      (ACTIVE_TARGET = TARGET_W32_DLL) |\
      (ACTIVE_TARGET = TARGET_L32_O)
      push  eax
      lea   eax, [esp + 8]
      push  dword [eax]
      pop   dword [data_pointer]
      pop   eax
      ret

   else if (ACTIVE_TARGET = TARGET_W64_OBJ) |\
	   (ACTIVE_TARGET = TARGET_W64_DLL)
      push  rax
      lea   rax, [data_pointer]
      mov   [rax], rcx
      pop   rax
      ret

   else if (ACTIVE_TARGET = TARGET_L64_O)
      push  rax
      lea   rax, [data_pointer]
      mov   [rax], rdi
      pop   rax
      ret

   end if

f_set_data_length:
   if (ACTIVE_TARGET = TARGET_W32_OBJ) |\
      (ACTIVE_TARGET = TARGET_W32_DLL) |\
      (ACTIVE_TARGET = TARGET_L32_O)
      push  eax
      lea   eax, [esp + 8]
      push  dword [eax]
      pop   dword [data_length]
      pop   eax
      ret

   else if (ACTIVE_TARGET = TARGET_W64_OBJ) |\
	   (ACTIVE_TARGET = TARGET_W64_DLL)
      push  rax
      lea   rax, [data_length]
      mov   [rax], rcx
      pop   rax
      ret

   else if (ACTIVE_TARGET = TARGET_L64_O)
      push  rax
      lea   rax, [data_length]
      mov   [rax], rdi
      pop   rax
      ret

   end if

f_encrypt:
   if (ACTIVE_TARGET = TARGET_W32_OBJ) |\
      (ACTIVE_TARGET = TARGET_W32_DLL) |\
      (ACTIVE_TARGET = TARGET_L32_O)
      push  eax ebx esi edi ecx
      lea   esi, [data_pointer]
      mov   esi, [esi]
      mov   edi, esi
      lea   ebx, [data_length]
      mov   ebx, [ebx]
      lea   ecx, [key]
      mov   cx, [ecx]
      and   cl, 0x07

   @@:
      lodsb
      rol   al, cl
      xor   al, ch
      stosb
      dec   ebx
      or    ebx, 0
      jnz   @b

      pop   ecx edi esi ebx eax
      ret

   else if (ACTIVE_TARGET = TARGET_W64_OBJ) |\
	   (ACTIVE_TARGET = TARGET_W64_DLL) |\
	   (ACTIVE_TARGET = TARGET_L64_O)
      push  rax rbx rsi rdi rcx
      lea   rsi, [data_pointer]
      mov   rsi, [rsi]
      mov   rdi, rsi
      lea   rbx, [data_length]
      mov   ebx, [rbx]
      lea   rcx, [key]
      mov   cx, [rcx]
      and   cl, 0x07

   @@:
      lodsb
      rol   al, cl
      xor   al, ch
      stosb
      dec   rbx
      or    rbx, 0
      jnz   @b

      pop   rcx rdi rsi rbx rax
      ret

   end if

f_decrypt:
   if (ACTIVE_TARGET = TARGET_W32_OBJ) | (ACTIVE_TARGET = TARGET_W32_DLL) | (ACTIVE_TARGET = TARGET_L32_O)
      push  eax ebx esi edi ecx
      lea   esi, [data_pointer]
      mov   esi, [esi]
      mov   edi, esi
      lea   ebx, [data_length]
      mov   ebx, [ebx]
      lea   ecx, [key]
      mov   cx, [ecx]
      and   cl, 0x07

   @@:
      lodsb
      xor   al, ch
      ror   al, cl
      stosb
      dec   ebx
      or    ebx, 0
      jnz   @b

      pop   ecx edi esi ebx eax
      ret

   else if (ACTIVE_TARGET = TARGET_W64_OBJ) | (ACTIVE_TARGET = TARGET_W64_DLL) | (ACTIVE_TARGET = TARGET_L64_O)
      push  rax rbx rsi rdi rcx
      lea   rsi, [data_pointer]
      mov   rsi, [rsi]
      mov   rdi, rsi
      lea   rbx, [data_length]
      mov   ebx, [rbx]
      lea   rcx, [key]
      mov   cx, [rcx]
      and   cl, 0x07

   @@:
      lodsb
      xor   al, ch
      ror   al, cl
      stosb
      dec   ebx
      or    ebx, 0
      jnz   @b

      pop   rcx rdi rsi rbx rax
      ret

   end if

begin_data_section

 if (ACTIVE_TARGET = TARGET_W32_OBJ) | (ACTIVE_TARGET = TARGET_W32_DLL) | (ACTIVE_TARGET = TARGET_L32_O)
      use32
   else if (ACTIVE_TARGET = TARGET_W64_OBJ) | (ACTIVE_TARGET = TARGET_W64_DLL) | (ACTIVE_TARGET = TARGET_L64_O)
      use64
   end if

   pointers:
   fill_random 4 * 8

   data_pointer:
   fill_random 8

   data_length:
   fill_random 8

   key:
   fill_random 2


finalize