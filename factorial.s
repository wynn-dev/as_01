.att_syntax prefix

.section .rodata
message: .asciz "Assignment 1: Powers\nName: Ege Cansu, Weishang Lu\nnetID: ecansu, weishanglu\n\n"
result_format: .asciz "Result: %ld\n"
input_format: .asciz "%ld"
number_input_prompt: .asciz "Number input: "

.bss
.align 8
number_input: .zero 8

.text
.globl main
main:
    pushq %rbp # We are about tp use rbp, so save its old value. pushq stores the value in the stack
    movq %rsp, %rbp # Copy current stack addr into rbp 
    
    movq $0, %rax # Callig rules require the low byte of rax to indicate how many vector registers carry arguments, mine uses none so zero is appropriate
    movq $message, %rdi # On Linux x86-64 rdi holds a functions's first pointer or integer argument
    call printf 
    
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
    movq $number_input_prompt, %rdi
    call printf

    movq $0, %rax
    movq $number_input, %rsi
    movq $input_format, %rdi
    call scanf

    /*
        Notes:
        Copies the address: movq $base_input, %rsi
        Copies the value: movq base_input(%rip), %rsi
    */

    movq number_input(%rip), %rdi # (%rip) is a way to locate that memory relative to the current instruction. the assembler and linker calculate the offset for you.
    call factorial
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

factorial:
    /*
        Number input (n): rdi
        Counter: rcx
        Result, eventually return value: rax
    */

    # Stack frame
    pushq %rbp
    movq %rsp, %rbp

    # Keep looping while counter (rcx) <= input (rdi)

    movq $2, %rcx # Move 2 into counter

    movq $1, %rax # Let result be 1

    .Lrepeat:
        cmpq %rdi, %rcx # Loop while counter (rcx) <= input (rdi)
        jg .Ldone

        imulq %rcx, %rax
        incq %rcx # Increase the counter by 1

    jmp .Lrepeat

    .Ldone:
        # Stack frame
        movq %rbp, %rsp
        popq %rbp
        ret