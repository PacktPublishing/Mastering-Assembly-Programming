format ELF64
extrn printk

section '.init.text' executable

module_init:
	push	rdi
	
	mov		rdi, str1
	xor		eax ,eax
	call	printk
	
	xor		eax, eax
	pop		rdi
	ret
	

section '.exit.text' executable

module_cleanup:
	xor		eax, eax
	ret
	

section '.rodata.str1.1'
	str1	db	'<0> Here I am, gentlemen!', 0x0a, 0
	
section '.modinfo' align 10h
	db	'license=GPL',0
	db	'depends=',0
	db	'vermagic=3.16.0-4-amd64 SMP mod_unload modversions ',0
	
	
section '.gnu.linkonce.this_module' writeable
this_module:
	rb	0x18
	db	'simple_module',0
	rb	0x150 - ($ - this_module)
	dq	module_init
	rb	0x248 - ($ - this_module)
	dq	module_cleanup
	dq	0
	
	
macro __version ver, name
{
	local .version, .name
	.version	dq	ver
	.name		db	name, 0
	.name_len = $ - .name
	rb			56 - .name_len
}
	
section '__versions'
;	dq	0x2ab9dba5 ;0x568fba06
;@@:
;	db	'module_layout', 0
;	rb	56 - ($ - @b)
;	
;	dq	0x27e1a049
;@@:	
;	db	'printk', 0
;	rb	56 - ($ - @b)

	__version 0x2ab9dba5, 'module_layout'
	__version 0x27e1a049, 'printk'
