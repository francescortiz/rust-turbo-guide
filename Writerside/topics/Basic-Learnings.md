# Basic Learnings

## Introduction

This is a collection of non-obvious key knowledge that I found necessary to get comfortable with rust. 


## Types

### Unit Type

* The unit type `()` is equivalent to TypeScript's `void` type and `undefined` value.

## Arrays

* Array bounds are checked at runtime.

```rust
let a = [1,2];
a[2] // -> runtime error.
```

## Statements / Expressions

* With a semicolon you get a statement, without you get an expression.
* Expressions are values that you need to use/assign/return.
* Expressions can can be put inside their own scopes `{...}`.
* The expression scopes can have statements inside and only if they end with an expression they return a value other than `()`
* If the last element in a function is a statement, it is automatically returned.

```rust
2 // -> expression that gives us a 2.
2; // -> statement (useless).

let a1 = {3}; // -> a is 3
let a2 = {3;}; // -> a is ()

let b = {
  let c = 3;
  c + 1
} // -> b is 4
let b2 = {
  let c = 3;
  c + 1;
} // -> b is ()

fn take_five() -> i32 {
  5
}
fn take_unit() -> () {
  5;
}
```
