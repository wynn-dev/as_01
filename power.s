.att_syntax prefix

.section .rodata
message: .asciz "Assignment 1: Powers\nName: Weishang Lu\nnetID: weishanglu\n\n"
result_format: .asciz "Result: %ld\n"
input_format: .asciz "%ld"
base_input_prompt: .asciz "Base input: "
exponent_input_prompt: .asciz "Exponent input: "

.bss
.align 8
base_input: .zero 8
exponent_input: .zero 8

.text
.globl main
main:
    pushq %rbp # We are about tp use rbp, so save its old value. pushq stores the value in the stack
    movq %rsp, %rbp # Copy current stack addr into rbp 
    
    movq $0, %rax # Callig rules require the low byte of rax to indicate how many vector registers carry arguments, mine uses none so zero is appropriate
    movq $message, %rdi # On Linux x86-64 rdi holds a functions's first pointer or integer argument
    call printf 
    
    # Practice
    #     movq $6, %rdi # Input for the subroutine
    #     movq $4, %rsi
    #     call practice
    #     movq %rax, %rsi

    #     movq $0, %rax
    #     movq $result_format, %rdi
    #     call printf

    /*
        print arguments
        Address of input: rdi
        Zero, for the variadic calling convention: rax
    */

    /*
        scanf arguments
        Address of input_format: rdi
        Address of base_input: rsi
        Zero, for the variadic calling convention: rax
    */

    movq $0, %rax
    movq $base_input_prompt, %rdi
    call printf

    movq $0, %rax
    movq $base_input, %rsi
    movq $input_format, %rdi
    call scanf

    movq $0, %rax
    movq $exponent_input_prompt, %rdi
    call printf

    movq $0, %rax
    movq $exponent_input, %rsi
    movq $input_format, %rdi
    call scanf

    /*
        Notes:
        Copies the address: movq $base_input, %rsi
        Copies the value: movq base_input(%rip), %rsi
    */

    movq base_input(%rip), %rdi # (%rip) is a way to locate that memory relative to the current instruction. the assembler and linker calculate the offset for you.
    movq exponent_input(%rip), %rsi
    call pow
    movq %rax, %rsi # Copies result into there printf expects second argument, for replacing %ld

    movq $0, %rax
    movq $result_format, %rdi
    call printf

    movq $0, %rax # Put return value in rax
    movq %rbp, %rsp # Move the stack pointer back to bookmarked position
    popq %rbp # Restore old rbp from the stack, then move rsp up 8 bytes
    ret # Now caller's register is restored and the return addr is on top
 
/* 
    Subroutines
    First integer argument: rdi
    Second integer argument: rsi
    Integer result: rax
*/

/*
    Practice subroutine
    Adds numbers from 1 through a given number
    Input: rdi
    Counter: rcx
    Running total, eventually return value: rax
*/
# practice:
#     /*
#         The loop:
#         If zero -> go to the finish
#             Otherwise:
#                 Add the counter to the total
#                 Decrease the couter
#                 Jump back to the check
#         Finish:
#             Return
#     */
#     movq %rdi, %rcx # Move the wanted number into the counter
#     movq $0, %rax # Setup rax
#
#     .Lrepeat:
#         cmpq $0, %rcx
#         je .Ldone
#
#         addq %rcx, %rax
#         decq %rcx # Decrease the counter by 1
#
#     jnz .Lrepeat
#
#     .Ldone:
#         ret

pow:
    /*
        Let result = 1
        First input (x): rdi
        Second input (y): rsi
        Counter: rcx
        Running total, eventually return value: rax
    */

    # Stack frame
    pushq %rbp
    movq %rsp, %rbp

    movq %rsi, %rcx # Move the wanted multiplication count into the counter
    movq $1, %rax # Let result be 1

    .Lrepeat:
        cmpq $0, %rcx # When counter reaches 0, its done
        je .Ldone

        imulq %rdi, %rax
        decq %rcx # Decrease the counter by 1

    jnz .Lrepeat

    .Ldone:
        # Stack frame
        movq %rbp, %rsp
        popq %rbp
        ret
