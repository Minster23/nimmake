# Package

version = "0.1.0"
author = "Neira"
description = "A new awesome nimble package"
license = "MIT"
srcDir = "src"
bin = @["nimmake"]

binDir = "bin"

# Dependencies

requires "nim >= 2.2.10"
requires "parsetoml"
requires "nimpretty_t"
