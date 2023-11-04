# Cross Compilation

## To Windows

## From Linux to Windows

If you use Arch Linux or Manjaro, it is piece of cake. Just install the required `mingw...` dependencies at will. A lot
of them are already packaged: 

* [Community repository (toolchain)](https://archlinux.org/packages/?q=mingw-w64)
* [AUR repository (additional packages)](https://aur.archlinux.org/packages?SeB=n&K=mingw-w64&SB=c&PP=250)

## From macOS to Windows

It relies on then [mingw-w64](https://www.mingw-w64.org) project. It feels quite abandoned. On the official page they
don't even mention Homebrew (`brew install mingw-w64`), only MacPorts. What you get there doesn't even include sqlite
and you have to compile it yourself. I guess that what you get is what Arch Linux calls "toolchain". For any other
thing you need, it is on you to download the source and compile it. Please, correct me if you have updates on this.

### Initial setup

1. Create config file:

```shell
$ cat ~/.cargo/config 
[target.x86_64-pc-windows-gnu]
linker = "x86_64-w64-mingw32-gcc"
```

_Note: everybody mentions `.cargo/config`, I assumed it is `~/.cargo/config`._

2. Build with 

```shell
$ cargo build --target=x86_64-pc-windows-gnu
```

### SQLite

Luckily, for sqlite you can ask the `libsqlite3-sys` crate to use a bundled `sqlite`. Add the following to your
`Cargo.toml`:

```toml
[dependencies.rusqlite]
version = "0.26.0"
features = ["bundled"]
```
