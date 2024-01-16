# Testing

## 101

Tests are identified by annotations:

```rust
pub fn add(left: usize, right: usize) -> usize {
    left + right
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }
}
```

Run them with:

```Shell
$ cargo test
```

## Tests from docs

Code from the documentation is also executed by tests.

## Making things testable

We need to timplement `PartialEq` and `Debug`. Usually is enough with annotation:

```rust
#[derive(PartialEq, Debug)]
```

## Macros

**IMPORTANT: The assert macros accept additional parameters that are going to be passed to printf.**
Example: `assert!(cond, "The user cond '{}' was supposed to be true", userId);`

`panic!(&str, &);`: runtime error equals test failure.

`assert!(boolean);`: fails if provided argument is false.

`assert_eq!<T>(T, T);` and `assert_ne!<T>(T, T);`: fail if provided values are different or equal. They show the 2
values, so there are more convenient and that `assert!` for this use case.

## Testing for `panic!`

Add `#[should_panic]` annotation to the test:

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[should_panic(expected = "optional error message fragment of the specific panic we want to trigger")]
    fn greater_than_100() {
        Guess::new(200);
    }
}
```

## Tests returning `Result<T, E>!`

Tests can result `Result<T, E>!`. This is useful for tests where we want to use the ? operator. It cannot be used with
`#[should_panic]`. If we want to check the Err, we need to use `assert!(res.is_error())`.

## Running tests

There are arguments before and after `--`

```Shell
cargo test --help
```

```Shell
cargo test -- --help
```

## Running specific tests

Run the `add_a_number` test:

```Shell
cargo test add_a_nunber
```

Tests names are search patterns; run any tests that contains `add` in the name:

```Shell
cargo test add
```

## `#[ignore]`: Ignoring tests unless explicitly requested

```Shell
#[test]
#[ignore]
fn expensive_test() {
    // code that takes an hour to run
}
```

## Test Organization

### Unit tests

The convention is to create a module named `tests` in each file to contain the test functions and to annotate the module
with `cfg(test)`.

_`#[cfg(xxxxx)]` is an annotation that tells the compiler to only compile under a certain configuration option._

### Integration tests

**ONLY `lib/` can be integration tested. This is why even binary crates have all the code in `lib` and as little code as
possible in `src/main.rs`.**

1. Create a tests directory next to `src`.
2. Create rust files. The convention is ending with `_test.rs`.
3. Add `#[test]` functions. No need for `#[cfg(test)]`.

Each test is considered as a separate crate, so we need to bring our library into each test crate’s scope:

```Shell
use adder; // Bring modules into scope on each test file

#[test]
fn it_adds_two() {
    assert_eq!(4, adder::add_two(2));
}
```

#### Shared code in tests

Only rust files that live in the `tests` directory are considered integration tests:

```
├── Cargo.lock
├── Cargo.toml
├── src
│   └── lib.rs
└── tests
    ├── common
    │   └── mod.rs           <-- old module structure is ignored by tests runner.
    ├── integration_test.rs  <-- contains test
    └── pipo
        └── piripo.rs        <-- files in subdirectories are ignored by tests runner.
```

Good for code shared by different tests.

```rust
use adder;

mod common;
mod pipo::piripo;

#[test]
fn it_adds_two() {
    common::setup();
    assert_eq!(4, adder::add_two(2));
    assert!(piripo());
}
```
