.text

.include "A3/final.s"

.global main

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read                *
#   return: no return value                                  *
# ************************************************************
decode:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	subq $32, %rsp 			# stack storage
	movq %rdi, 24(%rsp) 	# copy starting address to memory

	.Lread_block:
		movq (%rdi), %rax 	# move contents to rax

		/*
			rax: character
			rcx: repetition count
			r8: next block number
			rdx: complete original block
		*/

		movq %rax, %rdx		# keep a original copy to rdx

		andq $255, %rax 	# get the last char

		movq %rdx, %rcx 	# keep a copy to rcx, continue in rcx
		shrq $8, %rcx 		# shift 8 bits right
		andq $255, %rcx 	# get the last 8 bits

		
		movq %rdx, %r8		# keep a copy to r8, continue in r8
		shrq $16, %r8 		# shift 16 bits right
		movl %r8d, %r8d 	# keep only the lower 32 bit and clear upper 32 bit, writing lower 32 bit automatically makes upper 32 bit zero

		movq %rax, (%rsp)	# save character to stack
		movq %rcx, 8(%rsp)	# save repetition count to stack
		movq %r8, 16(%rsp)	# save next block number to stack
	
		.Lprint_loop:		# print the char by the repetition times
			cmpq $0, 8(%rsp)
			je .Lblock_finished

			/*
				putchat prints one char
				it expects the char's ascii number
				in lower 32 bit part of rdi, which is edi
			*/
			movl (%rsp), %edi
			call putchar
			decq 8(%rsp)
		jmp .Lprint_loop

	.Lblock_finished:
		cmpq $0, 16(%rsp) 		# if next block number is 0, jump to done
		je .Ldone

		movq 24(%rsp), %rdi		# restore message starting adsress into rdi
		movq 16(%rsp), %r8 		# restore next block number into r8

		imulq $8, %r8 			# calculate the distance from beginning 
		addq %r8, %rdi 			# calculate next block's address

	jmp .Lread_block

	.Ldone:
		# epilogue
		movq	%rbp, %rsp		# clear local variables from stack
		popq	%rbp			# restore base pointer location 
		ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

