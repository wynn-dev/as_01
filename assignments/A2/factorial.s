.text
message: .asciz "Assignment 2: Factorial\nName: Ege Cansu, Weishang Lu\nnetID: ecansu, weishanglu\n\n"
result_format: .asciz "Result: %ld\n"
input_format: .asciz "%ld"
number_input_prompt: .asciz "Number input: "

.bss
number_input: .skip 8               # the number read from the user

.text
.global main

# ************************************************************
# Subroutine: main                                           *
# Description: prints the assignment details, reads a number *
#   from the user, computes its factorial and prints it      *
# Parameters: none                                           *
# Return value: none, the program exits with code 0          *
# ************************************************************
main:
    # prologue
    pushq %rbp                      # save the caller's base pointer
    movq %rsp, %rbp                 # the base of our stack frame is the current stack pointer

    # print the names, netIDs and assignment name
    movq $0, %rax                   # no vector registers in use for printf
    movq $message, %rdi             # first argument: address of the message
    call printf

    # ask for the number and store it in number_input
    movq $0, %rax                   # no vector registers in use for printf
    movq $number_input_prompt, %rdi # first argument: address of the prompt
    call printf

    movq $0, %rax                   # no vector registers in use for scanf
    movq $input_format, %rdi        # first argument: the format string
    movq $number_input, %rsi        # second argument: address where scanf stores the number
    call scanf

    # compute the factorial of the number
    movq number_input, %rdi         # first argument: the value of the number
    call factorial                  # the result is returned in rax

    # print the result
    movq %rax, %rsi                 # second argument: the result, substituted for %ld
    movq $0, %rax                   # no vector registers in use for printf
    movq $result_format, %rdi       # first argument: the format string
    call printf

    # epilogue
    movq %rbp, %rsp                 # clear local variables from the stack
    popq %rbp                       # restore the caller's base pointer

    movq $0, %rdi                   # load the program exit code
    call exit                       # exit the program

# ************************************************************
# Subroutine: factorial                                      *
# Description: recursively calculates n!; the factorial of   *
#   0 and 1 is 1, any larger n is n times the factorial of   *
#   n - 1                                                    *
# Parameters:                                                *
#   first: n (non-negative integer)                          *
# Return value: the factorial of n                           *
# ************************************************************
factorial:
    # prologue
    pushq %rbp                      # save the caller's base pointer
    movq %rsp, %rbp                 # the base of our stack frame is the current stack pointer

    cmpq $1, %rdi                   # only n greater than 1 needs a recursive call
    jg factorial_recurse

    # base case: the factorial of 0 and 1 is 1
    movq $1, %rax
    jmp factorial_end

factorial_recurse:
    subq $16, %rsp                  # reserve space for n, keeping the stack 16-byte aligned
    movq %rdi, -8(%rbp)             # save n, since the recursive call may overwrite rdi

    decq %rdi                       # first argument: n - 1
    call factorial                  # rax now holds the factorial of n - 1

    imulq -8(%rbp)                  # multiply it by n (rdx:rax = rax * n)

factorial_end:
    # epilogue
    movq %rbp, %rsp                 # clear local variables from the stack
    popq %rbp                       # restore the caller's base pointer
    ret                             # return the factorial in rax
