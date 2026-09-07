# Debugging x86-64 assembly in Docker on Apple Silicon

Your setup has an ARM64 Mac host and an x86-64 Debian container named
`asm-projects`. Your project is at `/workspace/as_01` inside the container.

Commands marked **Mac terminal**, **container terminal**, or **GDB prompt**
must run in that environment. GDB commands go after `(gdb)`; shell commands do not.

## Why ordinary GDB execution failed

GDB successfully loaded `power`, but `run` produced errors such as:

```text
Cannot PTRACE_GETREGS: Input/output error
Couldn't get CS register: Input/output error.
```

GDB normally asks the Linux kernel to inspect a process through `ptrace`.
Running an x86-64 container on an ARM64 host adds a translation layer, where
this debugging interface can fail. This is consistent with the
[reported Docker issue](https://github.com/docker/for-mac/issues/6921).

The workaround below uses QEMU's built-in GDB connection. QEMU executes the
program and provides its register and memory state to GDB directly.
See the [QEMU user-mode documentation](https://www.qemu.org/docs/master/user/main.html).

GDB 16.3 was verified in this container. The QEMU workflow below has not yet
been verified in this project.

## 1. Install the tools

In a **Mac terminal**:

```sh
docker ps
docker exec -u root asm-projects apt-get update
docker exec -u root asm-projects apt-get install -y gdb qemu-user
```

`docker exec` runs a command inside an existing, running container. `-u root`
provides the privileges needed to install packages. Installation changes this
container; recreating it from its original image may lose those changes.

## 2. Build with debugging information

Enter the container from a **Mac terminal**:

```sh
docker exec -it asm-projects bash
```

In that **container terminal**:

```sh
cd /workspace/as_01
gcc -g -no-pie power.s -o power
```

- `-g` includes debugging information so GDB can associate instructions with source.
- `-no-pie` supports the fixed-address string reference used in this exercise.
- `-o power` names the executable.

Resolve any build errors before starting the debugger. This guide assumes your
assembly exposes a `main` function for GCC's startup code to call.

## 3. Start the program under QEMU

In the same **container terminal**:

```sh
qemu-x86_64 -g 1234 ./power
```

QEMU waits for GDB to connect on port 1234. The apparent pause is expected.
Leave this terminal open; your program's output will appear here.

## 4. Connect GDB from a second terminal

Open a second **Mac terminal** and enter the same container:

```sh
docker exec -it asm-projects bash
```

In the second **container terminal**:

```sh
cd /workspace/as_01
gdb ./power
```

At the **GDB prompt**:

```gdb
set disassembly-flavor att
target remote localhost:1234
break *main
continue
```

Both sessions are inside the same container, so `localhost` reaches QEMU;
you do not need to publish a Docker port for this workflow.

Use `continue`, rather than `run`, after connecting. QEMU already created the
process; GDB is controlling that existing process remotely.

You should stop at the first instruction of `main`. Try `info registers` and
`x/8gx $rsp`. If either fails, retain the exact error for troubleshooting.

## 5. Repeat an experiment

After the program exits, start QEMU again in the first terminal. In GDB,
reconnect with `target remote localhost:1234`, check your breakpoints using
`info breakpoints`, and use `continue`.

If you change and rebuild the source, finish the old session first. Start
QEMU with the new executable and reopen GDB so both use the same build.

## Common messages

| Message | Meaning and next step |
| --- | --- |
| `apt` or `apt-get`: command not found | Check whether you are in the Mac shell. Enter the Debian container first. |
| `/etc/os-release`: no such file | This is expected on macOS; it suggests you are outside the Linux container. |
| `./power`: no such file | Move to `/workspace/as_01` and build the executable successfully. |
| No symbol table / no executable specified | GDB has not loaded an executable. Start it with `gdb ./power` in the correct directory. |
| No debugging symbols found | Rebuild with `-g`. Named symbols such as `main` may still exist without source debugging information. |
| Register errors after `run` | Use the QEMU remote workflow above. Adding `-g` does not repair the emulation interface. |
| Connection refused | Check that QEMU is waiting and both terminals are in the same container using port 1234. |

Continue with [GDB basics](GDB_BASICS.md) once the breakpoint works.
