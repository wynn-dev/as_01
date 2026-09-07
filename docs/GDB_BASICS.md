# GDB basics for assembly beginners

A debugger lets you pause a program, execute individual instructions, and
inspect registers and memory. Use it to test a prediction: decide what an
instruction should change, step once, and compare the result.

For this project's Docker setup, first follow [the QEMU setup guide](DEBUGGING_SETUP.md).
The examples below assume you have connected to QEMU and stopped at `main`.
Enter these commands at the `(gdb)` prompt.

## Find your place

```gdb
set disassembly-flavor att
disassemble main
x/i $rip
```

AT&T syntax matches your source's `%rax` register names and source-before-destination
operand order. `disassemble main` displays the function's machine instructions.
`$rip` is the instruction pointer; `x/i $rip` displays the next instruction to execute.

GDB prefixes register names with `$`, even though AT&T assembly uses `%`.

## Move one instruction at a time

| Command | Meaning |
| --- | --- |
| `si` or `stepi` | Execute one machine instruction; enter a called function. |
| `ni` or `nexti` | Execute one instruction; run a called function until it returns. |
| `continue` or `c` | Resume until a breakpoint, signal, or program exit. |
| `break *main` | Set a breakpoint at the exact entry address of `main`. |
| `info breakpoints` | List breakpoints and their numbers. |
| `delete 1` | Remove breakpoint number 1, if that is the breakpoint you intend to remove. |

Use `ni` at `call printf` when you want to study your own function. Use `si`
there when you deliberately want to explore library or linker instructions.

`step` and `next` operate at the source-line level. For learning assembly,
`si` and `ni` make the amount of execution clearer.

## Inspect registers

```gdb
info registers
info registers rip rsp rax rdi
p/x $rsp
p/d $rax
```

`p` means print an expression. `/x` chooses hexadecimal; `/d` chooses decimal.

| Register | Role in this exercise |
| --- | --- |
| `rip` | Address of the next instruction. |
| `rsp` | Address of the current top of the stack. |
| `rdi` | First integer or pointer argument, such as the format-string address. |
| `rax` | Function return value; its low byte also has a role before variadic calls such as `printf`. |

Registers are working storage, so their meanings can change as execution proceeds.
For example, after `printf` returns, `rax` contains its return value rather
than the value you supplied before the call.

## Inspect stack memory

```gdb
x/8gx $rsp
```

Read this as: examine eight values, each eight bytes wide, in hexadecimal,
starting at the address held in `rsp`.

- The left column is a memory address.
- The values to its right are the contents stored at that address and following addresses.
- `g` selects an eight-byte unit; it does not mean a GDB variable.

The stack is memory. `rsp` is a register holding an address into that memory.
Changing `rsp` changes which memory location is considered the top; it does
not automatically erase or initialize the memory.

After you have loaded the string address into `rdi`, inspect it with:

```gdb
x/s $rdi
```

Here `/s` interprets memory as a null-terminated string.

## Keep useful information visible

GDB can print selected values whenever execution stops:

```gdb
display/i $rip
display/x $rsp
```

List those automatic displays with `info display`. Disable a particular one
with `undisplay` followed by its displayed number.

For a terminal interface showing assembly and registers:

```gdb
layout asm
layout regs
```

If the terminal display becomes scrambled, press Ctrl+L to redraw. Use
`tui disable` to return to the ordinary prompt layout. Examine stack memory
with `x/8gx $rsp` as needed.

## Practice: predict the stack adjustment

At the first instruction of `main`:

1. Print `rsp` and examine the stack.
2. Find the instruction that reserves stack space.
3. Predict the new value of `rsp` before stepping.
4. Execute one instruction with `si`, then inspect `rsp` again.
5. Check whether the reserved memory changed, or only the pointer moved.

Before the `call`, check alignment using:

```gdb
p/d ((unsigned long)$rsp & 15)
```

This checks the low four address bits, equivalent to the remainder after
division by 16. A result of zero means 16-byte alignment. The Linux x86-64
calling convention requires this alignment immediately before a call.

Next, step over `printf` with `ni`. Inspect `rax` before your own return-value
instruction overwrites it. What might that value tell you about the output?

Finally, watch the instruction that releases your stack reservation. Does
`rsp` return to its value at entry to `main` before `ret` executes?

## Ask GDB for help and finish

```gdb
help x
help stepi
apropos register
quit
```

`help` explains a command. `apropos` searches help text for a word.
GDB may ask what to do with an active debugging session when you quit.

With this QEMU remote workflow, restart the program from the QEMU terminal
and reconnect GDB for another run. The ordinary GDB `run` command is not
the restart mechanism for this connection.
