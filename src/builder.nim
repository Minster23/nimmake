import configManager
import std/[os, strformat, strutils]
import package
import std/json
import std/strutils
import std/osproc

proc compile_commands(g: projectConfig) =
  var arr = newJArray()

  var includedR: seq[string]

  for l in g.included:
    let k = &"""-I"{l}""""
    includedR.add(k)

  let includeRed = includedR.join(" ")

  let gpp = execProcess("where g++").strip().splitLines()[0]

  for f in g.source:
    var cmd = &""""{gpp}" -std={g.version} """

    if g.macroM != "":
      cmd &= g.macroM & " "

    cmd &= includeRed & " "
    cmd &= "-c " & f

    arr.add(%*{"directory": getCurrentDir(), "command": cmd, "file": f})

  writeFile("compile_commands.json", pretty(arr))

proc mingwBuild(cfg: projectConfig) =
  let location = &"""out/{cfg.arc}"""
  var includedR: seq[string]
  var linkName: seq[string]
  var linkDir: seq[string]
  createDir(location)
  getPackage(cfg.packages)

  if cfg.compile_command:
    compile_commands(cfg)

  let files = cfg.source.join(" ")

  for l in cfg.included:
    echo "Detected: " & l
    let k = &""" -I"{l}" """
    includedR.add(k)
  let includeRed = includedR.join(" ")

  for k in cfg.linkdir:
    echo "Link: " & k
    let o = &""" -L"{k}" """
    linkDir.add(o)
  let linkDirRed = linkDir.join(" ")

  for k in cfg.linkname:
    echo "Link: " & k
    let o = &""" -l{k} """
    linkName.add(o)
  let linkNameRed = linkName.join(" ")

  let gppRaw = execProcess("where g++").strip().splitLines()[0]
  let gpp = gppRaw.replace("\\", "/")

  let p = &""""{gpp}" -std={cfg.version} {files} {cfg.macroM} {includeRed} {linkDirRed} {linkNameRed} -o {location}/{cfg.name}"""

  echo p
  let code = execCmd(p)
  if code != 0:
    echo "build failed"
    return
  echo "build complete in " & location

proc build*(configM: projectConfig) =
  if fileExists("config.toml") == false:
    echo "config not found"
    quit(1)

  echo "Build started"

  case configM.compiler
  of "mingw":
    echo "mingw running"
    mingwBuild(configM)
  else:
    echo "compiler didn't available"
    return

  return
