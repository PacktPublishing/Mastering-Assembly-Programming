/*
	This is a multiline comment.
*/
//	This is a single line comment.
#	Another single line comment.

# The following line is not a necessity.
	.file "test.S"
	
# Tell GAS that we are using an external function.
	.extern	printf
	
# Make some data - store message in data section 0
	.data
msg:
	.ascii	"Hello from Assembly language!\xa\xd\x0"
	
	
# Begin the actual code
	.text
# Make main() publicly visible
	.globl	main
	
/*
	This is our main() function. 
	It is important to mention, 
	that we can't begin the program with 
	'main()' when using GAS alone. We have then
	to begin the program with 'start' or '_start' 
	function.
*/
main:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	$msg				# Pass parameter (pointer
								# to message) to output_message function.
	call	output_message		# Print the message
	movl	$0, %eax
	leave
	ret
	
#	This function simply prints out a message to the terminal
output_message:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	printf				# Here we call printf
	addl	$4, %esp
	movl	$0, %eax
	leave
	ret		$4

	
