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

Code from the documentation is also executed by tests.

## Making things testable

We need to timplement `PartialEq` and `Debug`. Usually is enough with annotation:

```rust
#[derive(PartialEq, Debug)]
```

## Macros

**IMPORTANT: The assert macros accept additional parameters that are going to be passed to printf.** Example: `assert!(cond, "The user cond '{}' was supposed to be true", userId);`

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