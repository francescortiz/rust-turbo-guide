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

Ifs are expressions, so they can be used on variable assignment; just don't put semicolon at the end of the
arms/branches:

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

### `for ... in ...`

The `for` loops are like the python ones or the `for ... of` of JavaScript. Example:

```rust
for number in (1..4).rev() {
    println!("{number}!");
}
```

### `while`

Use a `while` loop if you want to manage counters yourself.

### Loop labels

Loops (`loop`, `for`, `while`, ) can be labeled do disambiguate `break` and `continue` statements in nested loops. Loop
labels
always start with a single
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

## String VS string literal

A string literal has fixed size defined at compile time. A String has unknown size and belongs to the heap. To create a
String from a string literal use:

```rust
String::from("string literal")
```

Strings are treated as pointers, not values.

## Stack and Heap

### The tack

The stack is for fixed size elements. The stack memory access is _last in, first out_. Pointers to the heap can be
stored in the stack. Writing to the stack is faster because there is no scanning in th heap for a gap of sufficient
size, the location is always the top of the stack.

When you pass arguments to a function, those are pushed to the stack, and they are popped off when the function
finished.

### The Heap

The Heap allows elements for which size is not known at compile time or size changes. The heap always stores pointers.
This is called _allocating on the heap_ or _allocating_. Accessing the heap is slower because it has to follow a
pointer.

## Ownership

The goal of ownership is to help you manage the stack and the heap. Ownership rules:

- Each value in Rust has an owner.
- There can only be one owner at a time.
- When the owner goes out of scope, the value will be dropped.

## Allocating and deallocating

Allocating ends at the end of the scope. Rust calls `drop` automatically at the end of the scope to free the memory.

## Ownership: moving vs copying

### Moving (or transferring ownership)

When we assign a pointer to another variable, the initial variable becomes invalid and cannot be accessed unless
the value implements the [`Copy`](#copy-trait) trait, in which case a copy of
the contents will be created. For Strings or other objects you can `.clone()` them. This process of assigning a pointer
to another variable and this losing access to the initial variable is called moving:

```rust
let s = String::from("Pabla");
let t = s; // the String has moved to t, so s cannot be accessed anymore.
```

Rust by design will always make you use `.clonse()` when you want to make copies of information stored in the heap in
order to make aware of expensive operations.

### `Copy` trait

It is reserved for stack types for performance reasons. It gives a compilation error if it is added to a type that
implements the `Drop` trait.

It is implemented mostly for scalar types and tuples of types that implement the `Copy` trait.

### Calling functions

Calling functions either moves or copies the variables to the function. Moving a variable into a function is called
_transferring ownership_.

```rust
fn main() {
    let s = String::from("hello");  // s comes into scope

    takes_ownership(s);             // s's value moves into the function...
                                    // ... and so is no longer valid here

    let x = 5;                      // x comes into scope

    makes_copy(x);                  // x would move into the function,
                                    // but i32 is Copy, so it's okay to still
                                    // use x afterward

} // Here, x goes out of scope, then s. But because s's value was moved, nothing
  // special happens.

fn takes_ownership(some_string: String) { // some_string comes into scope
    println!("{}", some_string);
} // Here, some_string goes out of scope and `drop` is called. The backing
  // memory is freed.

fn makes_copy(some_integer: i32) { // some_integer comes into scope
    println!("{}", some_integer);
} // Here, some_integer goes out of scope. Nothing special happens.
```

Function return values are also moved out of the scope of the function and up to the caller.

```rust
fn main() {
    let s1 = gives_ownership();         // gives_ownership moves its return
                                        // value into s1

    let s2 = String::from("hello");     // s2 comes into scope

    let s3 = takes_and_gives_back(s2);  // s2 is moved into
                                        // takes_and_gives_back, which also
                                        // moves its return value into s3
} // Here, s3 goes out of scope and is dropped. s2 was moved, so nothing
  // happens. s1 goes out of scope and is dropped.

fn gives_ownership() -> String {             // gives_ownership will move its
                                             // return value into the function
                                             // that calls it

    let some_string = String::from("yours"); // some_string comes into scope

    some_string                              // some_string is returned and
                                             // moves out to the calling
                                             // function
}

// This function takes a String and returns one
fn takes_and_gives_back(a_string: String) -> String { // a_string comes into
                                                      // scope

    a_string  // a_string is returned and moves out to the calling function
}
```

## Borrowing

We can borrow variables many times in read-only manner, but in write mode (`mut`) the borrowing is exclusive. This
prevents data races.

Create scopes to create multiple non-simultaneous `mut` references

```rust
let mut s = String::from("hello");

{
    let r1 = &mut s;
} // r1 goes out of scope here, so we can make a new reference with no problems.

let r2 = &mut s;
```

This is ok because there are no uses of the read-only references before the mutable reference:

```rust
 let mut s = String::from("hello");

let r1 = &s; // no problem
let r2 = &s; // no problem
println!("{} and {}", r1, r2);
// variables r1 and r2 will not be used after this point

let r3 = &mut s; // no problem
println!("{}", r3);
```

### Slices

Slices are references to parts of other elements (slice of a string or an array):

```rust

let s = String::from("Ghost")
let piece = &s[0..2] // piece contains a reference NOT A COPY to 2 first 2 letters of s, "Gh"

```

With slices, we have guaranteed that the source cannot be modified until we are done working with one of its slices.

#### Functions that return slices

A function can return a slice of a reference that has been borrowed to them:

```
fn slicer(s: &str) -> &str {
    &s[0..2]
}

let s = String::from("Ghost")
let piece = slicer(s)
```

If you borrow many arguments, you need to use lifetimes. A lifetime is a label prefixed with a single quote that is
placed between the `&` and the variable name. It needs to be declared after the function name between `<` and `>`.
Lifetimes are a way of saying:

> _The returned reference's lifetime is linked to the one of the parameter that has the same lifetime label._

```rust
fn slicer<'a>(a: &str, s: &'a str) -> &'a str {
    println!("a = {a}");
    &s[0..2]
}

let s = String::from("Ghost")
let piece = slicer(s)
```

## Structs

### Types of structs

#### Tuple structs

```rust 
struct Color(u32, u32, u32);
let red = Color(255, 0, 0);
```

#### _Unit-like_ structs

```rust
struct NoColor;
```

Useless alone, but traits and enums will add more juice to the recipe.

#### _Traditional_ structs

Like C structs or TypeScript types.

### Struct update syntax

You can take the **remaining** values from another struct **of the same type**:

```rust

struct Pixel {
    x: i32;
    y: i32;
    color: i32;
}

let p1 = Pixel {
    x: 13,
    y 13,
    color: 65535 // -> Yellow
}

p2 = {
    x: 14,
    ..p1
}

```

#### Relevant points:

- It has to appear last
- **It moves ownership to the new struct!** :smile:

### Borrows need lifetimes

```

struct Human<'parent> {
    name: String,
    parent: &'parent Human<'parent>,
}

```

### println! and dbg! for structs

structs don't implement the `std::fmt::Display` so we cannot send them right away to `println!`. `println!` can
debug structs using the specifiers `{:?}` and `{:#?}` for pretty print. Unfortunately, structs also don't implement
the `Debug` trait, so that won't work either. But there is a quick trick: we can annotate the structs with
`#[derive(Debug)]` and _voilà!_

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!("rect1 is {:?}", rect1);
    println!("rect1 is {:#?}", rect1);
}
```

Output:

```
rect1 is Rectangle { width: 30, height: 50 }
rect1 is Rectangle {
    width: 30,
    height: 50,
}
```