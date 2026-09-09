# CSE11C Assignment 1

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
