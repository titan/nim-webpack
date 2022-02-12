# Package

version       = "0.1.0"
author        = "Anonymous"
description   = "A tool to pack web file into nim code"
license       = "MIT"
srcDir        = "src"
bin           = @["webpack"]

# Dependencies

requires "nim >= 1.6.2"
requires "bytesequtils >= 1.1.3"
requires "docopt >= 0.6.8"
requires "zippy >= 0.7.4"
