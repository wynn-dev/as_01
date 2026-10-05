.text

.include "final.s"

.global main

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes a message as defined in Assignment 3. *
#   Every 8-byte block holds, from highest to lowest byte:   *
#   - 2 bytes unknown                                        *
#   - 4 bytes index of the next block                        *
#   - 1 byte amount of times to print the character          *
#   - 1 byte ASCII character                                 *
#   Decoding starts at block 0 and stops after printing a    *
#   block whose next index is 0.                             *
# Parameters:                                                *
#   first: the address of the message to read                *
# Return value: none                                         *
# ************************************************************

decode:
	# prologue
	pushq	%rbp			# push the base pointer and align the stack
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	# helpful 
	#   -8(%rbp): character of the current block
	#   -16(%rbp): times the character still has to be printed
	#   -24(%rbp): index of the next block
	#   -32(%rbp): address of the start of the message

	subq	$32, %rsp		# reserve space for the local variables
	movq	%rdi, -32(%rbp)		# remember where the message starts

decode_read_block:
	movq	(%rdi), %rdx		# load the current block into rdx

	movq	%rdx, %rax		# the character is the lowest byte
	andq	$255, %rax

	movq	%rdx, %rcx		# the repetition count is the second lowest byte
	shrq	$8, %rcx
	andq	$255, %rcx

	movq	%rdx, %r8		# the next index is held in the four bytes above that
	shrq	$16, %r8
	movl	%r8d, %r8d		# writing the lower 32 bits clears the upper 32 bits

	movq	%rax, -8(%rbp)		# save the character
	movq	%rcx, -16(%rbp)		# save the repetition count
	movq	%r8, -24(%rbp)		# save the next index

decode_print_loop:			# print the character as many times as the count says
	cmpq	$0, -16(%rbp)		# stop once the count reaches zero
	je	decode_block_finished

	movl	-8(%rbp), %edi		# first argument: the character to print
	call	putchar
	decq	-16(%rbp)		# reduce the count by 1
	jmp	decode_print_loop

decode_block_finished:
	cmpq	$0, -24(%rbp)		# a next index of 0 is the end of the message
	je	decode_end

	movq	-24(%rbp), %r8		# each block is 8 bytes, so the offset is index * 8
	shlq	$3, %r8 			# imulq $8, %r8
	movq	-32(%rbp), %rdi		# start from the beginning of the message
	addq	%r8, %rdi		# and add the offset to find the next block
	jmp	decode_read_block

decode_end:
	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location
	ret

main:
	# prologue
	pushq	%rbp			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi		# first parameter: address of the message
	call	decode			# call decode

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location

	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program
