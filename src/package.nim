import std/[os, strformat, strutils]
import std/uri

proc download(url: string, name: string) =
  createDir("ext")
  let n = name.split('/')
  let l = getCurrentDir() & "/ext/"
  let g: string = l & n[1]
  let p = &"git clone {url} {g}"

  for k in walkDir(l, true, true):
    if $k.path == $n[1]:
      echo "Already satisfied: " & $n[1]
      return

  discard execShellCmd(p)
  echo "download clear"

proc getPackage*(targetP: seq[string]) =
  let github: string = "https://github.com/"

  for target in targetP:
    let URL = parseUri(github & target)
    echo "searching..."
    if URL.isAbsolute():
      echo "available", URL.scheme
      download($URL, target)
    else:
      echo "not found", target
