.text
message: .asciz "Assignment 1: Powers\nName: Ege Cansu, Weishang Lu\nnetID: ecansu, weishanglu\n\n"
result_format: .asciz "Result: %ld\n"
input_format: .asciz "%ld"
base_input_prompt: .asciz "Base input: "
exponent_input_prompt: .asciz "Exponent input: "

.bss
base_input: .skip 8                 # the base read from the user
exponent_input: .skip 8             # the exponent read from the user

.text
.global main

main:
    # prologue
    pushq %rbp                      # save the caller's base pointer
    movq %rsp, %rbp                 # the base of our stack frame is the current stack pointer

    movq $0, %rax                   # no vector registers in use for printf
    movq $message, %rdi             # first argument: address of the message
    call printf

    movq $0, %rax                   # no vector registers in use for printf
    movq $base_input_prompt, %rdi   # first argument: address of the prompt
    call printf

    movq $0, %rax                   # no vector registers in use for scanf
    movq $input_format, %rdi        # first argument: the format string
    movq $base_input, %rsi          # second argument: address where scanf stores the base
    call scanf

    movq $0, %rax                   # no vector registers in use for printf
    movq $exponent_input_prompt, %rdi   # first argument: address of the prompt
    call printf

    movq $0, %rax                   # no vector registers in use for scanf
    movq $input_format, %rdi        # first argument: the format string
    movq $exponent_input, %rsi      # second argument: address where scanf stores the exponent
    call scanf

    # compute base to the power of exponent
    movq base_input, %rdi           # first argument: the value of the base
    movq exponent_input, %rsi       # second argument: the value of the exponent
    call pow                        # the result is returned in rax

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

pow:
    # prologue
    pushq %rbp                      # save the caller's base pointer
    movq %rsp, %rbp                 # the base of our stack frame is the current stack pointer

    movq %rsi, %rcx                 # the counter holds the number of multiplications left
    movq $1, %rax                   # the total starts at 1

pow_loop:
    cmpq $0, %rcx                   # stop once no multiplications are left
    jle pow_end

    imulq %rdi                      # multiply the total by the base (rdx:rax = rax * base)
    decq %rcx                       # one multiplication fewer to go
    jmp pow_loop                    # repeat the loop

pow_end:
    # epilogue
    movq %rbp, %rsp                 # clear local variables from the stack
    popq %rbp                       # restore the caller's base pointer
    ret                             # return the total in rax
