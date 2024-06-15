# Package

version       = "0.1.0"
author        = "Via Stone"
description   = "Initialize a Nim package non-interactively (using nimble)"
license       = "MIT"
srcDir        = "src"
bin           = @["ninit"]


# Dependencies

requires "nim >= 2.0.0"
requires "shell"
requires "cligen"
