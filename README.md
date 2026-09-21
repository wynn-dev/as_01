# CSE11C Assignment 1: Power

Implemenation plan for pow subroutine. Here's a typescript syntax-ish spec because I love typescript.

```ts
// y is a integer and > 0
function power(x: int, y: int) {
  let result = 1;

  for (let i = 0; i < y; i++) {
    result = result * x;
  }

  return result;
}
```

Spec for factorial subroutine.

```ts
// n is a integer and n > 0
function factorial(n: int) {
  let result = 1;

  for (let i = 2; i <= n; i++) {
    result *= i;
  }

  return result;
}

console.log(factorial(5)); // 120
```

# CSE11C Assignment 3: Memory

Spec for the decoder subroutine. Each 8-byte block contains a character, how many times to print it, and the number of the next block to visit. The highest 2 bytes are ignored.

This is TypeScript-like pseudocode. Numbers here can hold a complete unsigned 64-bit block, and `>>` shifts bits right while filling the left side with zeros. `readBlock` reads 8 bytes from memory; `printCharacter` prints the character represented by an ASCII number.

```ts
// messageAddress points to the first block of a valid encoded message.
// Prints the decoded message; returns no value.
function decode(messageAddress: address): void {
  let currentAddress = messageAddress;

  while (true) {
    let block = readBlock(currentAddress);

    // Keep the lowest 8 bits to get the character's ASCII number.
    let character = block & 0xff;

    // Move past the character, then keep the 8-bit repetition count.
    let printsRemaining = (block >> 8) & 0xff;

    // Move past the character and count, then keep the 32-bit block number.
    let nextBlock = (block >> 16) & 0xffffffff;

    // Finish printing this block before checking whether the message ends.
    while (printsRemaining > 0) {
      printCharacter(character);
      printsRemaining = printsRemaining - 1;
    }

    // Zero marks the end of the message, not a jump back to block zero.
    if (nextBlock == 0) {
      return;
    }

    // Each block takes 8 bytes. Always measure from the message's beginning.
    currentAddress = messageAddress + nextBlock * 8;
  }
}
```
