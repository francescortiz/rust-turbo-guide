# Cargo and crates.io

## Setting optimization level

There are the defaults:

```toml
[profile.dev]
opt-level = 0

[profile.release]
opt-level = 3
```

`opt-level` ranges from 0 to 3.

## Publishing a crate to crates.io

### Documentation

Three slashes means documentation. It has to go before the documented element and supports markdown:

```Rust
/// Adds one to the number given.
///
/// # Examples
///
/// ```
/// let arg = 5;
/// let answer = my_crate::add_one(arg);
///
/// assert_eq!(6, answer);
/// ```
pub fn add_one(x: i32) -> i32 {
    x + 1
}
```

#### Generating documentation

Render

```Shell
cargo doc
```

Render and serve

```Shell
cargo doc --preview
```

#### Common sections

- **Examples**: self descriptive.
- **Panics**: The scenarios in which the function being documented could panic. Callers of the function who don’t want
  their
  programs to panic should make sure they don’t call the function in these situations.
- **Errors**: If the function returns a Result, describing the kinds of errors that might occur and what conditions
  might cause those errors to be returned can be helpful to callers so they can write code to handle the different kinds
  of errors in different ways.
- **Safety**: If the function is unsafe to call (we discuss unsafety in Chapter 19), there should be a section
  explaining why the function is unsafe and covering the invariants that the function expects callers to uphold.

#### Documentation Comments as Tests

`cargo test` executes all the code that appears in the comments.

#### Container comments

Comments that start with `//!` talk about the container of the items in this section of code.

Use for crate or module documentation.

### `pub use`

It re-exports an item. Good to make your crates more usable by 3rd parties. It doesn't hide the real location of items
in the docs. In the following example, 3rd parties can just do `use crate::PrimaryColor` instead
of `use crate::kinds::PrimaryColor`:

```Rust
//! # Art
//!
//! A library for modeling artistic concepts.

pub use self::kinds::PrimaryColor;
pub use self::kinds::SecondaryColor;
pub use self::utils::mix;

pub mod kinds {
    // --snip--
}

pub mod utils {
    // --snip--
}
```

You can also use `pub use` to re-export 3rd party items from your crates.

### `cargo publish`

`cargo publish` publishes the packages and makes sure that you filled the mandatory fields before publishing.

Licenses need to be taken from https://spdx.org/licenses/ or else a license file needs to be provided.

You can double-license with `OR`. This is common: `MIT OR Apache-2.0`

#### Publishing is permanent

**WARNING! Publishing is permanent and cannot be deleted or overwritten!**

### Semantic Versioning

Self-explanatory

### `cargo yank --vers X.Y.Z [--undo]`

Marks a version as not eligible by future projects.

## Workspaces

A workspace is a set of packages that share the same `Cargo.lock` and output directory. They are managed by the `cargo`
command itself. It is pretty straight forward to work with them, just check The Book's chapter about
it: [Cargo Workspaces](https://doc.rust-lang.org/book/ch14-03-cargo-workspaces.html)

## Installing Binaries with cargo install

The cargo install command allows you to install and use binary crates locally.

## Extending Cargo with Custom Commands

If a binary in your $PATH is named cargo-something, you can run it as if it was a Cargo subcommand by running cargo
something