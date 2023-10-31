# Basic Learnings

## Introduction

This is a collection of non-obvious key knowledge that I found necessary to get comfortable with rust.

## Types

### Unit Type

The unit type `()` is equivalent to TypeScript's `void` type and `undefined` value.

## Arrays

Array bounds are checked at runtime.

```rust
let a = [1,2];
a[2] // -> runtime error.
```

## Statements / Expressions

With a semicolon you get a statement, without you get an expression.

Expressions are values that you need to use/assign/return.

Expressions can can be put inside their own scopes `{...}`.

The expression scopes can have statements inside and only if they end with an expression they return a value other
  than `()`

If the last element in a function is a statement, it is automatically returned.

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

## Comments

There are only single line comments. 2 slashes for standard comments (`//`) and 3 for documentation comments (`///`).
See [Publishing a Crate to Crates.io](https://doc.rust-lang.org/book/ch14-02-publishing-to-crates-io.html#publishing-a-crate-to-cratesio).

## Vocabulary

Code branches are also referred to as "arms".

## If

Ifs are expressions, so they can be used on variable assignment; just don't put semicolon at the end of the arms/branches:

```rust

let is_positive: bool = if number >= 0 {
    println!("It is positive");
    true
} else {
    println!("It is negative");
    false
}

```

## Iterating

You have `loop`, `while`, and `for`. 

### `loop`

`loop` iterates forever unless you break it. `loop` is an expressions and returns the
argument you pass to `break``, if you want to:

```rust
let result = loop {
    counter += 1;

    if counter == 10 {
        break counter * 2;
    }
};
```

Loops can be labeled do disambiguate `break` and `continue` in nested loops. Loop labels always start with a single
quote `'`:

```rust
fn main() {
    let mut count = 0;
    'counting_up: loop {
        println!("count = {count}");
        let mut remaining = 10;

        loop {
            println!("remaining = {remaining}");
            if remaining == 9 {
                break;
            }
            if count == 2 {
                break 'counting_up;
            }
            remaining -= 1;
        }

        count += 1;
    }
    println!("End count = {count}");
}
```

### `for ... in ...`

The `for` loops are like the python ones or the `for ... of` of JavaScript. Example:

```rust
for number in (1..4).rev() {
    println!("{number}!");
}
```

### `while`

Use a `while` loop if you want to manage counters yourself.