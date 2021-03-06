# Läsp changelog

## v0.12.0 - 2016-03-18

### Added

- Allow access to Ruby constants, namespaces separated by `/`.


## v0.11.0 - 2016-03-05

### Added

- Allow `require` to accept a second argument, when it is truthy it uses a path
  relative to the file that called `require`.
- Allow `_` to be used several times in parameter lists to ignore parameters
- Additions to standard library
  - `and`
  - `or`

### Changed

- `require` now uses a static paths by default.
- The `.` function has been renamed to `send`, the `.` can now instead be used
  as a prefix to call Ruby methods, what previously looked like this: `(. obj method)`
  now looks like this `(.method obj)`. This is equivalent to `(send :method obj)`.

### Fixed

- Relative paths in `require` was completely broken before this.
- `empty?` no longer returns `true` for lists with a `nil` value at the first position.


## v0.10.1 - 2016-02-22

### Fixed

- Backwards compatibility with Ruby 2.0.0


## v0.10.0 - 2016-02-22

### Added

- Allow escape characters in strings
    - `\n` - newline
    - `\t` - tab
    - `\"` - double quote
    - `\\` - backslash
- Allow `print` and `println` to take any number of arguments
- Add text function to stdlib for easier concatenation (works the same as
  `print` and `println` now do but returns a string)

## v0.9.0 - 2016-02-20

### Added

- Add support for let-bindings
- Make list and dict be functions of their contents
- Additions to core library
    - `print`
    - `readln`
- Additions to standard library
    - `prompt`
    - `every`
    - `->integer`
    - `->decimal`

### Changed

- Make `require` use relative paths
- Rename float type to "decimal"
- Rename type string to "text"
- Allow any non-whitespace in symbol-style strings
- Raise `Lasp::NameError` instead of `KeyError` when unable to resolve symbol
- Show error class in REPL output

### Fixed

- Consistently do not capitalise error messages
- Properly enforce that def only be used with a symbol
- Properly enforce that parameters are declared as a list

## v0.8.0 - 2016-02-04

### Added

- Macro system
    - `quote` special form to defer evaluation
    - `macro` special form that works like a function but receives its arguments before evaluation
    - `'` syntax sugar for quoting, `'f` becomes `(quote f)`
- Variadic functions
    - Both functions and macros can now accept rest-arguments with an `&`
- Additions to core library
    - `require`
    - `apply`
- Additions to standard library
    - `nil?`
    - `not=`
    - `second`
    - macros
        - `defn`
        - `defm`
        - `macroexpand`
- Lispy looking datastructures
    - The REPL now displays `[:f, 12, 34]` as `(f 12 34)`

### Changed

- Rename `hash-map` to `dict`
- `pipe` now uses rest-arguments instead of taking a list of functions

### Fixed

- Parentheses inside strings are now handled correctly
- Negative numbers parsed correctly instead of appearing as symbols

## v0.7.0 - 2016-01-18

- Arity is now enforced in function calls and will throw errors when mismatched
- Add methods to stdlib:
    - `zero?`
    - `list->str`
    - `str->list`
    - `->str`
    - `reverse-str`
    - `ruby-method`
    - `pipe`
- REPL improvements:
    - Automatically close trailing parentheses
    - Change error prompt from `*>` to `!>`
    - Return nil when pressing Ctrl+D (this used to cause an error)
- Many refactorings

## v0.6.0 - 2016-01-17

- `<` and `>` now return false when given a list of equal items, they all **have to** increase or decrease.
- Add `<=` and `>=` to the core library.
- Fix stack overflowing when using `range` with an upper bound less than the lower bound, this now returns an empty list.

## v0.5.0 - 2015-09-24

- Merge `lasp-repl` command into `lasp`, it starts when not provided with a filename.
- Don't send env to functions implemented as Ruby procs, it was never used.
- Specs as default rake task.

## v0.4.0 - 2015-08-09

Implicit do-blocks around files. You can now do this...:

```lisp
(def x 5)

(def y 10)
```

...in a Läsp file without having to wrap the entire contents of the file in
`(do ...)`. Previously it just stopped reading after the first form and
anything after would seemingly inexplicably not be run.

**This is only enabled in files, not every form of evaluation.**

## v0.3.2 - 2015-08-09

Fix bug in `do` - it accidentally returned part of the AST, now it correctly
returns the result of the last expression.

## v0.3.1 - 2015-08-09

Make readline support actually work once released to rubygems by implementing it directly in Ruby.

It does not seem to remember history between runs like rlwrap did, but trying
to deploy an interactive bash script to rubygems is just too much of a headache
and this is almost as nice with just a single line of Ruby.

## v0.3.0 - 2015-08-09

Add readline support in the REPL using rlwrap, this makes the REPL a **lot** nicer to use.

## v0.2.0 - 2015-08-08

Add support for hash-maps with the following added functions to the core library:

- `hash-map`
- `get`
- `assoc`
- `dissoc`

Also adds exit instructions to the REPL welcome message.

## v0.1.1 - 2015-08-02

Fix broken `lasp` executable.

## v0.1.0 - 2015-08-01

First release.
