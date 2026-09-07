# How calls and the stack work

Your program prints a message and returns to the startup code that called it.
To understand how it returns, follow the values saved in memory.

The addresses below are made-up numbers chosen to make the steps easy to follow.
The examples describe Linux x86-64, where these stack entries are eight bytes wide.

## Three things to keep separate

- **Memory** stores values at numbered addresses.
- **`rsp`** is a register holding the address of the current top of the stack.
- **`rbp`** is another register. Your function uses it to remember a stack position.

A register holding an address is different from the value stored in memory at
that address. If `rsp` contains 992 and memory at 992 contains 405, then:

```text
992 = where the saved value is located
405 = the saved value itself
```

The stack is a region of memory where values are added and removed at the top.
On x86-64, adding one eight-byte value moves `rsp` down by eight.

## 1. The startup code calls main

Imagine the startup code has these instructions:

```text
Address 400: call main
Address 405: next instruction in startup
```

Before the call, suppose:

```text
rsp = 1000
rbp = 7000
```

When the CPU executes `call main`, it needs to remember **405**, because that
is where startup should resume when `main` finishes.

The CPU automatically:

1. Subtracts eight from `rsp`.
2. Writes 405 into memory at the new stack position.
3. Jumps to `main`.

```text
rsp = 992

Memory address    Stored value
992               405             ← rsp points here
```

The return address is now stored in memory. `rsp` holds its location, not
the return address itself.

## 2. Your function saves the old rbp

Your function begins with:

```asm
pushq %rbp
```

This means: save the value currently in `rbp` onto the stack.

It does two things:

1. Subtracts eight from `rsp` to make room.
2. Copies the current value of `rbp` into that room.

Using our numbers:

```text
rsp = 984
rbp = 7000                        ← unchanged by push

Memory address    Stored value
984               7000            ← rsp points here
992               405             ← return address is still here
```

Nothing overwrote 405. You used a different memory location.

The `q` means this operation uses an eight-byte value.

## 3. Your function remembers a stack position

The next instruction is:

```asm
movq %rsp, %rbp
```

AT&T syntax puts the source first and destination second. This copies the
value from `rsp` into `rbp`:

```text
rsp = 984
rbp = 984

Memory address    Stored value
984               7000            ← rsp and rbp point here
992               405
```

Think of `rbp` as a bookmark for this stack position. Copying a register does
not add anything to the stack or erase the source.

The old `rbp` value, 7000, is still saved in memory.

### Why save the old value?

The calling convention—the agreement between functions—requires your function
to restore the caller's `rbp` value before returning if you change it.

You save it because your next instruction overwrites it. A function that does
not change `rbp` does not need to save it for this reason.

Your earlier version left `rbp` alone and used `subq $8, %rsp` to reserve eight
bytes for stack alignment. The new `pushq %rbp` also moves `rsp` down eight
bytes, but uses that space to save a value.

## 4. Your function calls printf

Your register instructions prepare the message address and the other calling
information that `printf` expects. Then:

```asm
call printf
```

Just as with `call main`, the CPU saves the address of the instruction after
this call. Let's call that address **550** in this example.

```text
rsp = 976
rbp = 984

Memory address    Stored value
976               550             ← rsp; return to main after printf
984               7000            ← rbp; saved old rbp
992               405             ← return to startup
```

The CPU then jumps to `printf`.

`printf` can use more stack space internally. Before returning, it restores
its stack so that its own return address is on top again.

Its return takes 550 off the stack and jumps there. You resume in `main`
immediately after the call:

```text
rsp = 984
rbp = 984

Memory address    Stored value
984               7000            ← rsp and rbp point here
992               405
```

The most recently saved return address was used first. This is how calls
inside other calls can return in the correct order.

## 5. Your function prepares its result

```asm
movq $0, %rax
```

This puts zero in `rax`, where the caller expects your function's return value.
Returning zero from `main` means success.

This instruction does not end the function and does not change the stack.

There are two different ideas here:

- **Return value:** the result of your function, stored in `rax`.
- **Return address:** where execution should continue, saved on the stack.

## 6. Your function restores the stack position

```asm
movq %rbp, %rsp
```

This copies your bookmarked position back into `rsp`.

Using our numbers, it sets `rsp` to 984. In this small function, `rsp` already
contains 984 after `printf` returns, so this instruction changes nothing.
It becomes useful when a function has reserved additional space below its bookmark.

## 7. Your function restores the old rbp

```asm
popq %rbp
```

This does two things:

1. Reads the eight-byte value at the address in `rsp` into `rbp`.
2. Adds eight to `rsp`.

It reads 7000 from memory at 984, then moves `rsp` to 992:

```text
rsp = 992
rbp = 7000                        ← caller's original value restored

Memory address    Stored value
992               405             ← rsp points here again
```

The return address is now on top of the stack, exactly where `ret` expects it.

Removing a value from the stack does not mean erasing its bytes. Moving `rsp`
changes which location is considered the top of the active stack.

## 8. Your function returns

```asm
ret
```

The CPU:

1. Reads 405 from memory at the address in `rsp`, currently 992.
2. Adds eight to `rsp`, restoring it to 1000.
3. Jumps to instruction address 405.

You are back in the startup code, immediately after its call to `main`.
The startup code handles ending the program using the zero you returned.

```text
rsp = 1000                        ← original stack pointer restored
rbp = 7000                        ← original rbp restored
Execution resumes at 405.
```

## Why the cleanup matters

If you tried to execute `ret` while the saved old `rbp` was still on top:

```text
rsp → 7000                        ← saved old rbp
      405                         ← actual return address
```

`ret` would read 7000 and treat it as the next instruction address. It does
not know that this value was meant to be a saved register. Jumping to the
wrong place would usually cause a crash or other unintended execution.

That is why your function must remove its saved value before returning.

## Follow the numbers yourself

Cover the explanations above and work through these questions:

1. After `call main`, does `rsp` hold 992 or 405?
2. After `pushq %rbp`, did the return address move, or did `rsp` move?
3. After `movq %rsp, %rbp`, where is the old value 7000 saved?
4. Which value must be on top of the stack when `ret` executes?

Use [GDB basics](GDB_BASICS.md) to inspect real addresses in your program.
The real numbers will differ; the sequence of operations is the same.
