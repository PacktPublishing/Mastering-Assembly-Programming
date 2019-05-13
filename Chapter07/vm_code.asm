
macro	vm_load_key
{
	db	0x00
}

macro	vm_nop
{
	db	0x01
}

macro	vm_load_data_length
{
	db	0x02
}

macro	vm_loop loopTarget
{
	db	0x10
	dd	loopTarget - ($ + 4)
}

macro	vm_jump jumpTarget
{
	db	0x11
	dd	jumpTarget - ($ + 4)
}

macro	vm_exit
{
	db	0x12
}

macro	vm_encrypt regId
{
	db	0x20
	db	regId
}

macro	vm_decrement regId
{
	db	0x21
	db	regId
}

macro	vm_increment regId
{
	db	0x22
	db	regId
}

macro	vm_load_data_byte regId
{
	db	0x30
	db	regId
}

macro	vm_store_data_byte regId
{
	db	0x31
	db	regId
}

register_a = 0
register_b = 1
register_cnt = 2

vm_code_start:
	vm_load_key
	vm_load_data_length
	vm_nop

    .encryption_loop:
	vm_load_data_byte register_b
	vm_encrypt register_b
	vm_store_data_byte register_b
	;vm_increment register_data_ptr
	;vm_decrement register_cnt
	vm_loop .encryption_loop

	vm_exit
    .size = $ - vm_code_start

