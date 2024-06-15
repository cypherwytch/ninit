# Package

version       = "1.0.0"
author        = "Via Stone"
description   = "Initialize a Nim package non-interactively (does not require nimble)"
license       = "BSD"
srcDir        = "src"
bin           = @["ninit"]


# Dependencies

requires "nim >= 2.0.0"
requires "shell"
requires "cligen"
requires "regex"