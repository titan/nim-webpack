import std/[os, sequtils, strutils]
import bytesequtils
import docopt
import zippy

proc normalize(s: string): string =
  return "router_" &
          s.replace("/", "_slash_")
          .replace(".", "_dot_")
          .replace("-", "_link_")
          .replace(" ", "_space_")

proc mime(f: string): string =
  let (dir, name, ext) = f.splitFile
  case ext.toLower():
    of ".html":
      result = "text/html"
    of ".txt":
      result = "text/plain"
    of ".css":
      result = "text/css"
    of ".js":
      result = "text/javascript"
    of ".gif":
      result = "image/gif"
    of ".png":
      result = "image/png"
    of ".jpg":
      result = "image/jpeg"
    of ".jpeg":
      result = "image/jpeg"
    of ".svg":
      result = "image/svg+xml"
    else:
      result = "application/octet-stream"

proc compressable(f: string): bool =
  let (dir, name, ext) = f.splitFile
  case ext.toLower():
    of ".html":
      result = true
    of ".js":
      result = true
    of ".css":
      result = true
    of ".svg":
      result = true
    else:
      result = false

proc main(srcdir: string, target: string) =
  var mapping: seq[(string, seq[byte], bool)] = @[]
  for f in os.walkDirRec(srcdir, relative = true):
    let c = readFile(srcdir & "/" & f)
    if compressable(f):
      compress(c, BestCompression, dfGzip).asByteSeq:
        mapping.add((f, data, true))
    else:
      c.asByteSeq:
        mapping.add((f, data, false))
  var code = "import std/tables\n\n"
  for (f, c, zipped) in mapping:
    let buf = "const " & normalize(f) & ": seq[byte] = @[" & c.mapIt("0x" & toHex(it) & "'u8").join(",") & "]"
    code = code & "\n" & buf
  code = code & "\n\n"
  code = code & "let mapping*: TableRef[string, (seq[byte], string, bool)] = ["
  for (f, c, zipped) in mapping:
    code = code & "(\"/" & f & "\", (" & normalize(f) & ", \"" & mime(f) & "\", true)), "
  code = code & "].newTable"
  writeFile(target, code)

when isMainModule:
  let doc = """
webpack

Usage:
  webpack [options] <srcdir> <target>

Options:
  -h --help                                   Show this screen.
  --version                                   Show version.
"""
  let
    args = docopt(doc, version = "webpack 0.1.0")
    srcdir = $args["<srcdir>"]
    target = $args["<target>"]
  main(srcdir, target)
