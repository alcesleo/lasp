# laspec

A simple RSpec clone written in Läsp.

```lisp
(require "laspec.lasp")

(describe "parser"
  (it "one equals one"
    (expect-eq 1 1))

  (it "one equals two"
    (expect-eq 1 2)))
```
