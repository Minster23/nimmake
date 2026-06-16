import configManager
import std/[os, osproc, strutils, strformat, sequtils, json]
import package

type regitRet = object
  cpp, dir: seq[string]

proc compile_commands(g: projectConfig, reg: regitRet) =
  var arr = newJArray()
  var includedR: seq[string]

  for l in g.included:
    includedR.add(&"""-I"{l}"""")

  for d in reg.dir:
    includedR.add(&"""-I"{d}"""")

  let includeRed = includedR.join(" ")

  let gppRaw = execProcess("where g++").strip().splitLines()[0]
  let gpp = gppRaw.replace("\\", "/")

  for f in reg.cpp:
    var cmd = &""""{gpp}" -std={g.version} """

    if g.macroM != "":
      cmd &= g.macroM & " "

    cmd &= includeRed & " "
    cmd &= "-c " & &""""{f}""""

    arr.add(%*{"directory": getCurrentDir(), "command": cmd, "file": f})

  writeFile("compile_commands.json", pretty(arr))

proc isCppSource(ext: string): bool =
  ext in [".c", ".cc", ".cpp", ".cxx"]

proc ishppSource(ext: string): bool =
  ext in [".hpp", ".h", ".hxx"]

proc execptDir(ext: string, skipped: seq[string]): bool =
  return skipped.anyIt(ext.contains(it))

proc auto_regist(cfg: projectConfig): regitRet =
  var cpp, hpp, h, dir: seq[string]
  let data: seq[string] = cfg.packages
  for p in data:
    var l = p.split("/")
    let m = getCurrentDir() & "/ext/" & $l[1] & "/"
    for d in walkDirRec(m):
      if execptDir(splitFile(d).dir, cfg.skipDir) == true:
        echo "CPP: skipped dir"
      else:
        if isCppSource(splitFile(d).ext):
          echo "CPP: " & d
          cpp.add(d)

    for d in walkDirRec(m, yieldFilter = {pcDir}):
      if execptDir(splitFile(d).dir, cfg.skipDir) == true:
        echo "DIR: Skipped"
      else:
        echo "DIR: " & d
        dir.add(splitFile(d).dir)

  regitRet(cpp: cpp, dir: dir)

proc mingwBuild(cfg: projectConfig) =
  let location = &"out/{cfg.arc}"

  var includedR: seq[string]
  var linkName: seq[string]
  var linkDir: seq[string]

  createDir(location)
  getPackage(cfg.packages)

  var reg = regitRet(cpp: cfg.source, dir: @[])

  if cfg.auto_regist:
    let autoReg = auto_regist(cfg)

    for f in autoReg.cpp:
      if f notin reg.cpp:
        reg.cpp.add(f)

    for d in autoReg.dir:
      if d notin reg.dir:
        reg.dir.add(d)


  let files = reg.cpp.mapIt(&""""{it}"""").join(" ")

  for l in cfg.included:
    echo "Include: " & l
    includedR.add(&"""-I"{l}"""")

  for d in reg.dir:
    echo "Include: " & d
    includedR.add(&"""-I"{d}"""")

  let includeRed = includedR.join(" ")

  for k in cfg.linkdir:
    echo "Link dir: " & k
    linkDir.add(&"""-L"{k}"""")

  let linkDirRed = linkDir.join(" ")

  for k in cfg.linkname:
    echo "Link name: " & k
    linkName.add(&"-l{k}")

  let linkNameRed = linkName.join(" ")

  if cfg.compile_command:
    compile_commands(cfg, reg)

  let gppRaw = execProcess("where g++").strip().splitLines()[0]
  let gpp = gppRaw.replace("\\", "/")

  let output = &"""{location}/{cfg.name}"""

  var p = &""""{gpp}" -std={cfg.version} {files} """

  if cfg.macroM != "":
    p &= cfg.macroM & " "

  p &= &"""{includeRed} {linkDirRed} {linkNameRed} -o "{output}""""

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
  echo "auto_regist: ", configM.auto_regist
  case configM.compiler
  of "mingw":
    echo "mingw running"
    mingwBuild(configM)
  else:
    echo "compiler didn't available"
    return

  return
