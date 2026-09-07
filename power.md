# Pseudocode

Implemenation plan for pow subroutine. Here's a typescript syntax-ish spec because I love typescript.

```
// y is a integer and > 0
function power(x: int, y: int) {
    let result = 1

    for (let i = 0; i < y; i++) {
        result = result * x
    }

    return result
}
```

Start with 1 then multiply by `x` exactly `y` times

```
power(2, 3)
// 8
power(2, 12)
// 4096
power(3, 5)
// 243
power(3, 9)
// 19683
```
