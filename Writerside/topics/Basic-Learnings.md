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

## Return statements

Return statements can short-circuit functions anywhere:

```rust
use std::fs::File;
use std::io::{self, Read};

fn read_username_from_file() -> Result<String, io::Error> {
    let username_file_result = File::open("hello.txt");

    let mut username_file = match username_file_result {
        Ok(file) => file,
        Err(e) => return Err(e),  // <-- non-functional early return!!!!
    };

    let mut username = String::new();

    match username_file.read_to_string(&mut username) { // <-- mutation of username
        Ok(_) => Ok(username),
        Err(e) => Err(e),
    }
}
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
- <img src="warning.png" alt="WARNING!" width="24" height="24" title="WARNING!"/> **It moves ownership to the new struct!** <img src="warning.png" alt="WARNING!" width="24" height="24" title="WARNING!"/>

### Borrows need lifetimes

```

struct Human<'parent> {
    name: String,
    parent: &'parent Human<'parent>,
}

```

### println! for structs

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

## dgb!

`dbg!` allows you to log to STDERR expressions. It either moves or accepts borrowing, and returns the provided
move/borrow. Examples:

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let scale = 2;
    let rect1 = Rectangle {
        width: dbg!(30 * scale),
        height: 50,
    };

    dbg!(&rect1);
}
```

outputs:

```rust
[src/main.rs:10] 30 * scale = 60
[src/main.rs:14] &rect1 = Rectangle {
    width: 60,
    height: 50,
}
```

## Methods

You can create methods for structs, enums or trait objects. Create additional `impl` blocks. There can be more than one
for a given type. Example `impl`:

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }
    
    fn transpose(self) -> Self {
        Self {
            width: self.height,
            height: self.width,
        }
    }
}

impl Rectangle {
    fn perimeter(&self) -> u32 {
        2 * self.width + 2 * self.height
    }
}

// Now we can do rect.area()
```

First paramater must be called `self` and have type `Self`. Self is a reference to the type. We can avoid the Self type
though. You can use `&self`, `&mut self` or `self`. The latter is a move and it is a rare use case; this technique is
usually used when the method transforms self into something else and you want to prevent the caller from using the
original instance after the transformation.

Methods and fields can have the same name; invocation parenthesis disclose which one you look for.

### Associated functions

`impl` blocks can contain functions with no reference to `Self`. These are just function, not methods. Methods and
functions inside impl are called _associated functions_. They are invoked as `<Type>::<function>`. Example:

```rust
impl Rectangle {
    fn square(size: u32) -> Self {
        Self {
            width: size,
            height: size,
        }
    }
}

let s = Rectangle::square(2)
```

## Enums

```rust
enum Message<T> { // <- Generics!
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
    Apply(T),
}

impl Message<bool> { // <- Generics need to be implemented for each type!
    fn call(&self) {
        match self {
            Message::Quit => {
                println!("The Quit variant has no data to destructure.");
            }
            Message::Move { x, y } => {
                println!("Move in the x direction {x} and in the y direction {y}");
            }
            Message::Write(text) => {
                println!("Text message: {text}");
            }
            Message::ChangeColor(r, g, b) => {
                println!("Change the color to red {r}, green {g}, and blue {b}",)
            }
            Message::Apply(apply) => {
                println!("Apply {apply}");
            }
        }
    }
}

```

## Pattern matching

```rust
enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter,
}

fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter => 25,
    }
}
```

```rust
let x = 1;

match x {
    0 => println!("zero"),
    1 | 2 => println!("one or two"),
    3..=5 => println!("three through five"),
    _ => println!("anything"),
}
```

```rust
let x = 'c';

match x {
    'a'..='j' => println!("early ASCII letter"),
    'k'..='z' => println!("late ASCII letter"),
    _ => println!("something else"),
}
```

```rust
match (setting_value, new_setting_value) {
    (Some(1), Some(2)) => {
        println!("1 and 2 are ok.");
    }
    (Some(2), Some(y)) => {
        println!("2 is happy with {y}.");
    }
    (Some(_), Some(_)) => {
        println!("We don't care about other values as long they are there.");
    }
    _ => {
        println!("One of the two was None! Unacceptable!");
    }
}
```

### EVIL SHADOWING!!!! 🤬

```rust
let x = Some(5);
let y = 10;

match x {
    Some(50) => println!("Got 50"),
    Some(y) => println!("Matched, y = {y}"), // <-- y gets shadowed 🤬🤬🤬🤬🤬
    _ => println!("Default case, x = {:?}", x),
}

println!("at the end: x = {:?}, y = {y}", x);
```

#### ifs to the rescue!

```rust
match x {
    Some(50) => println!("Got 50"),
    Some(n) if n == y => println!("Matched, n = {n}"),
    _ => println!("Default case, x = {:?}", x),
}
```

```
let x = 4;
let y = false;

match x {
    4 | 5 | 6 if y => println!("yes"),
    _ => println!("no"),
}
```

### @ Bindings

The at operator @ lets us create a variable that holds a value at the same time as we’re testing that value for a
pattern match:

```rust
enum Message {
    Hello { id: i32 },
}

let msg = Message::Hello { id: 5 };

match msg {
    Message::Hello {
        id: id_variable @ 3..=7,
    } => println!("Found an id in range: {}", id_variable),
    Message::Hello { id: 10..=12 } => {
        println!("Found an id in another range")
    }
    Message::Hello { id } => println!("Found some other id: {}", id),
}
```

## Destructuring

```rust
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p = Point { x: 0, y: 7 };

    let Point { x, y } = p;
    assert_eq!(0, x);
    assert_eq!(7, x);

    let Point { x: a, y: b } = p;
    assert_eq!(0, a);
    assert_eq!(7, b);
    
    match p {
        Point { x, y: 0 } => println!("On the x axis at {x}"),
        Point { x: 0, y } => println!("On the y axis at {y}"),
        Point { x, y } => {
            println!("On neither axis: ({x}, {y})");
        }
    }
}
```

## `if ... let`

```rust
let mut count = 0;
if let Coin::Quarter(state) = coin {
    println!("State quarter from {:?}!", state);
} else {
    count += 1;
}
```

## Crates, modules and packages

### Crate

- It is the minimum compilation unit.
- There can be many application crates, but only one library crate.
- The root application crate is `src/main.rs`.
- The library crate is `src/lib.rs`.
- Additional application crates are in `src/bin/<appliation crate>.rs`.

### Module

Modules are declared inside root files (`src/main.rs` or `src/lib.rs`) with `mod whatever_module;`.

The code of the modules can live:

1. In a block of code placed instead of a semicolon right after `mod whatever_module`.
2. In a file named `src/whatever_module.rs`.
3. In a file named `src/whatever_module/mod.rs`. **Old stile; avoid.**

Submodules can be declared inside other modules, recurring the same 3 pattern above. Examples:

Inside code:

```rust
mod another_module {
   ...
}
```

In files:

```
src/whatever_module/another_module.rs
src/whatever_module/another_module/mod.rs // OLD STYLE; AVOID
```

Example with nesting in one file:

```rust
// If the submodules and their items are not public we won't be able to invoke them from our file!
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}

        pub fn seat_at_table() {}
    }

    pub mod serving {
        pub fn take_order() {}

        pub fn serve_order() {}

        pub fn take_payment() {
            clean_table() // Here we can invoke private function
        }
        
        fn clean_table() {}
    }
}
```

#### Referencing modules inside the crate

Absolute path (crate == _root_)

```rust
fn main() {
    let x = crate::whatever_module::another_module::Item(true)
}
```

Relative path

```rust
fn main() {
    let x = whatever_module::another_module::Item(true)
}
```

`use` example:

```rust
use crate::whatever_module::another_module::Item;

fn main() {
    let x = Item(true)
}
```

##### Relative paths

`super::`: Parent module.

#### Visibility

RULE 1: **Everything is private by default**

If a module is declared with `pub` (`pub mod whatever_module`) then it is visible by the parent of the modulewhere it
was defined. Same applies to modules' items.

RULE 2: **struct attributes are also private by default:**

```rust
pub struct Breakfast {
    pub toast: String,
    seasonal_fruit: String, // -> Private!
}
```

RULE 3: **Submodules see everything from their super modules**

All submodules are defined within the context of the parent module and they have full access to it.

#### Modules good practice

A package can contain both a `src/main.rs` and `src/lib.rs`. This means that it is an executable that also exposes its
logic as a library. In this case all the module tree is defined under `src/lib.rs` and we import it from `src/main.rs`
by using paths starting with the module name. Example: `whaterver_page::module::submosule::Item`.

### `use`

Use `use` to bring a module or item into a scope. Also, aliases:

```rust
use module::submodule::Item as SubItem;
```

#### `pub use` use an export... re-export

Not much to say. Expose in an upper level something that is nested.

#### Importing package

```rust
use package;
use package::Item;
use package::submodule::SubItem;

// equivalent to
use package::{self, Item;, submodule::SubItem};
```

Also:

```rust
use package::*; // Import all public items... BE CAREFUL!!! use in tests or prelude pattern.
```

## Collections

### Vector

Vectors store elements in memory next to each other. New memory is allocated and elements might be copied to a new
location as needed in order to make them be next to each other.

#### Creation

`vec!` is a macro to created populated vector. It allows to create readonly vec right away.

```rust
let v = vec![1, 2, 3];
```

Otherwise:

```rust
let mut v = Vec::new();
v.push(1);
v.push(2);
v.push(3);
```

#### Reading vector

```rust
let v = vec![1, 2, 3, 4, 5];

let exists = &v[1]; // Returns &2
let exists = v.get(1); // Returns Some(&2)

let does_not_exist = &v[100]; // Panic; out of bounds. Unsafe.
let does_not_exist = v.get(100); // Returns a None. Safe.
```

```rust
let mut v = vec![1, 2, 3, 4, 5];

let first = &v[0];

v.push(6); // ILEGAL: this might trigger reallocation, `first` would point to dealocated memory and we are using it below.

println!("The first element is: {first}");
```

#### Iterating vectors

Use `for ... in` because it guarantees immutability of the vector during the iteration.

```rust
    let v = vec![100, 32, 57];
    for i in &v {
        println!("{i}");
    }
```

```rust
    let mut v = vec![100, 32, 57];
    for i in &mut v {
        *i += 50; // asterisk is the dereference operator; to access the value.
    }
```

### String

```rust
    let s1 = String::from("Hello, ");
    let s2 = String::from("world!");
    let s3 = s1 + &s2; // note s1 gets moved here and can no longer be used
```

```rust
fn add(self, s: &str) -> String { // <- this is the signature of + with String... self is moved.
```

```rust
let s = format!("{s1}-{s2}"); // <- nicer than + and doesn't take ownership of first string. 
```

#### String indexing `&s[1]`

Not possible. Internally strings are `Vec<u8>`... bytes... big trouble with UTF-8... so not possible. Period.

Also, the only way to go to position N in a UTF-8 string is to scan the string, slow performance and unpredicted time,
better use functions that remind you that.

#### String slicing `&s[a..b]`

This is allowed, but if you slice in the middle of an UTF-8 char, panic and game over... **watch out!**

#### Iterating strings

```rust
for c in "Зд".chars() {
    println!("{c}");
}
```

```rust
for b in "Зд".bytes() {
    println!("{b}");
}
```

**WARNING:** On UTF-8 grapheme might be composed of more than one UTF-8 char. Those are called clusters of UTF-8 chars.

### HashMap

Not included in the prelude, no macro to simplify its usage and can be iterated with a `for in` loop:

```rust
    use std::collections::HashMap;

    let mut scores = HashMap::new();

    scores.insert(String::from("Blue"), 10);
    scores.insert(String::from("Yellow"), 50);

    for (key, value) in &scores {
        println!("{key}: {value}");
    }
```

HashMaps move

```rust
    use std::collections::HashMap;

    let field_name = String::from("Favorite color");
    let field_value = String::from("Blue");

    let mut map = HashMap::new();
    map.insert(field_name, field_value);
    // field_name and field_value are invalid at this point, try using them and
    // see what compiler error you get!
```

Insert if not present and read:

```rust
    use std::collections::HashMap;

    let mut scores = HashMap::new();
    scores.insert(String::from("Blue"), 10);

    scores.entry(String::from("Yellow")).or_insert(50);
    scores.entry(String::from("Blue")).or_insert(50);
```

We don't need to re-apply, we can update a reference to the value because `.or_insert` returns a mutable
reference `&mut V`

```rust
    use std::collections::HashMap;

    let text = "hello world wonderful world";

    let mut map = HashMap::new();

    for word in text.split_whitespace() {
        let count = map.entry(word).or_insert(0);
        *count += 1;
    }
```

#### HashMap's has function can be customized

The default one, SipHash, is slow but safe against DoS attacks.

## Error handling

### `panic!` macro

Unrecoverable error. Behavior:

1. Show error message or show backtrace (AKA stacktrace) with the environment variable `RUST_BACKTRACE=1` and compiled
   with debug symbols.
2. Unwind the stack or quit right away (use the latter when small binary is top priority).

`Cargo.toml`:

```toml
[profile.release]
panic = 'abort'
```

### `Result<T, E>`

`match` is considered too verbose, to rustacians prefer `unwrap_or_else`.

If you feel like using `unwrap`, use `expect` instead, because it gives a meaningful error message.

#### `?` operator in `Result`

The `?` operator is almost equivalent to "unwrap `Ok` or return `Err`". The difference is that `?` calls the `from`
function from the `From` trait on the error type of the function, which transforms values, so the error received by `?`
is transformed into the error type of the function. These 2 pieces of code are equivalent:

```rust
    let username_file_result = File::open("hello.txt");

    let mut username_file = match username_file_result {
        Ok(file) => file,
        Err(e) => return Err(e),
    };
```

```rust
   let mut username_file = File::open("hello.txt")?;
```

This is how the `from` is created to transform `io::Error` into `OurError`:

```rust
impl From<io::Error> for OurError
```

And, obviously, it is chainable (but, for peace of mind, try to avoid one-liners):

```rust
use std::fs::File;
use std::io::{self, Read};

fn read_username_from_file() -> Result<String, io::Error> {
    let mut username = String::new();

    File::open("hello.txt")?.read_to_string(&mut username)?;

    Ok(username)
}
```

But, in the future, just use a function that does it all if available, like `fs::read_to_string("hello.txt")` for this
case.

#### `?` operator in `Option`

Same but, instead of `Err` you get `None`.

### `main` can return a `Result`

```rust
use std::error::Error;
use std::fs::File;

fn main() -> Result<(), Box<dyn Error>> {
    let greeting_file = File::open("hello.txt")?;

    Ok(())
}
```

The main function may return any types that implement the `std::process::Termination` trait, which contains a function
report that returns an ExitCode.