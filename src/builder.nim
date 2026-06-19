import configManager
import std/[os, osproc, strutils, strformat, sequtils, json, times]
import package

type regitRet = object
  cpp, dir: seq[string]

proc normPath(p: string): string =
  p.replace("\\", "/")

proc addInclude(includes: var seq[string], path: string) =
  let p = normPath(path)
  if p.len > 0 and dirExists(p):
    let flag = &"""-I"{p}""""
    if flag notin includes:
      includes.add(flag)

proc compile_commands(
  cfg: projectConfig,
  reg: regitRet,
  objFile: seq[string],
  gpp: string
) =
  var arr = newJArray()
  var includedR: seq[string]

  let cwd = normPath(getCurrentDir())
  let compiler = normPath(gpp)

  var mingwInclude = compiler
  if mingwInclude.contains("/bin/"):
    mingwInclude = mingwInclude.replace("/bin/g++.exe", "/include")
    mingwInclude = mingwInclude.replace("/bin/g++", "/include")

  addInclude(includedR, mingwInclude)

  let cppRoot = mingwInclude / "c++"
  if dirExists(cppRoot):
    for kind, path in walkDir(cppRoot):
      if kind == pcDir:
        let cppVer = normPath(path)
        addInclude(includedR, cppVer)
        addInclude(includedR, cppVer / "x86_64-w64-mingw32")
        break

  for l in cfg.included:
    addInclude(includedR, l)

  for d in reg.dir:
    addInclude(includedR, d)

  let includeRed = includedR.join(" ")

  for i, f in reg.cpp:
    let src = normPath(f)
    let absSrc =
      if src.isAbsolute:
        src
      else:
        cwd / src

    var cmd = &""""{compiler}" -std={cfg.version} """

    if cfg.macroM.len > 0:
      cmd &= cfg.macroM & " "

    cmd &= includeRed & " "
    cmd &= &"""-c "{normPath(absSrc)}" """

    if objFile.len > i:
      let obj = normPath(objFile[i])
      let absObj =
        if obj.isAbsolute:
          obj
        else:
          cwd / obj

      cmd &= &"""-o "{normPath(absObj)}""""

    arr.add(%*{
      "directory": cwd,
      "command": cmd,
      "file": normPath(absSrc)
    })

  writeFile("compile_commands.json", pretty(arr))

proc isCppSource(ext: string): bool =
  ext in [".c", ".cc", ".cpp", ".cxx"]

proc execptDir(ext: string, skipped: seq[string]): bool =
  return skipped.anyIt(ext.contains(it))

proc auto_regist(cfg: projectConfig): regitRet =
  var cpp, hpp, h, dir: seq[string]
  let data: seq[string] = cfg.packages
  for p in data:
    var l = p.split("/")
    let m = getCurrentDir() & "/ext/" & $l[1] & "/"
    for d in walkDirRec(m):
      if execptDir(splitFile(d).dir, cfg.skipDir) == false:
        if isCppSource(splitFile(d).ext):
          echo "CPP: " & d
          cpp.add(d)

    for d in walkDirRec(m, yieldFilter = {pcDir}):
      if execptDir(splitFile(d).dir, cfg.skipDir) == false:
        echo "DIR: " & d
        dir.add(splitFile(d).dir)

  regitRet(cpp: cpp, dir: dir)

proc makeObject(file, gcc, incl: string): string =
  if dirExists("out/object") == false:
    createDir("out/object")

  var o = file.split("/")
  var ter: string
  if o.maxIndex() == 0:
    ter = o[o.maxIndex()+1]
  else:
    ter = o.max()
  var g = ter.replace(".cpp", ".o")

  var p = &"""{gcc} -c {file} -o out/object/{g} {incl}"""

  let k = execCmd(p)
  if k != 0:
    echo (&"""FAILED MAKING OBJECT AT {file}""")
    return
  else:
    return &"""out/object/{g}"""

proc fileValidator(file: string): bool =
  var o = file.split("/")
  var ter: string
  if o.maxIndex() == 0:
    ter = o[o.maxIndex()+1]
  else:
    ter = o.max()
  var g = ter.replace(".cpp", ".o")

  let target = &"""out/object/{g}"""
  let targetFile = target.getFileInfo()
  let f = file.getFileInfo()

  if targetFile.lastWriteTime < f.lastWriteTime:
    return false
  else:
    return true


proc mingwBuild(cfg: projectConfig) =
  let location = &"out/{cfg.arc}"

  var obejctVar: seq[string]
  var includedR: seq[string]
  var linkName: seq[string]
  var linkDir: seq[string]
  var fileCount: int

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

  let files = reg.cpp.join(" ")

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

  let gppRaw = execProcess("where g++").strip().splitLines()[0]
  let gpp = gppRaw.replace("\\", "/")

  let output = &"""{location}/{cfg.name}"""

  for j in reg.cpp:
    var p = j.replace("\\", "/")
    #if fileValidator(p) == true:
    #  continue
    var t: string = makeObject(p, gpp, includeRed)
    echo t
    obejctVar.add(&"""{t}""")
    fileCount = fileCount + 1

  if cfg.compile_command:
    if obejctVar.len > 0:
      compile_commands(cfg, reg, obejctVar, gpp)


  let objectVarRed = obejctVar.join(" ")

  var p = &""""{gpp}" -std={cfg.version} {objectVarRed} """

  if fileExists("out/object/main.o") == false:
    p = &""""{gpp}" -std={cfg.version} {files} """


  if cfg.macroM != "":
    p &= cfg.macroM & " "

  p &= &"""{includeRed} {linkDirRed} {linkNameRed} -o "{output}""""

  if fileCount != 0:
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
