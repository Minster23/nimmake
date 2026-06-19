import parsetoml
import std/strformat
import os
import std/osproc

type projectConfig* = object
  name*, macroM*, version*, compiler*, buildType*: string
  arc*: int
  source*, packages*, included*, linkname*, linkdir*, skipDir*, skipFile*: seq[string]
  compile_command*, auto_regist*, onlyMain*: bool

proc read*(): projectConfig =
  if fileExists("config.toml") == false:
    echo "Config not detected"
    return
  var configFile = readFile("config.toml")

  var config = parsetoml.parseString(configFile)
  var sources: seq[string]
  var packages: seq[string]
  var included: seq[string]
  var linkname: seq[string]
  var linkdir: seq[string]
  var skipDir: seq[string]
  var skipFile: seq[string]

  if config["project"].hasKey("files"):
    for d in config["project"]["files"].arrayVal:
      sources.add(d.getStr())

  if config["library"].hasKey("packages"):
    for d in config["library"]["packages"].arrayVal:
      packages.add(d.getStr())

  if config["library"].hasKey("included"):
    for d in config["library"]["included"].arrayVal:
      included.add(d.getStr())

  if config["library"].hasKey("linkname"):
    for d in config["library"]["linkname"].arrayVal:
      linkname.add(d.getStr())

  if config["library"].hasKey("linkdir"):
    for d in config["library"]["linkdir"].arrayVal:
      linkdir.add(d.getStr())
  if config["library"].hasKey("skipDir"):
    for d in config["library"]["skipDir"].arrayVal:
      skipDir.add(d.getStr())
  if config["library"].hasKey("skipFile"):
    for d in config["library"]["skipFile"].arrayVal:
      skipFile.add(d.getStr())

  var configN: projectConfig = projectConfig(
    # PROJECT
    name:
      if config["project"].hasKey("name"):
        config["project"]["name"].getStr()
      else:
        "",
    version:
      if config["project"].hasKey("version"):
        config["project"]["version"].getStr()
      else:
        "c++20",
    source: sources,
    compiler:
      if config["project"].hasKey("compiler"):
        config["project"]["compiler"].getStr()
      else:
        "",

    # COSTUM
    macroM:
      if config["costum"].hasKey("macro"):
        config["costum"]["macro"].getStr()
      else:
        "",
    buildType:
      if config["costum"].hasKey("build"):
        config["costum"]["build"].getStr()
      else:
        "binary",
    arc:
      if config["costum"].hasKey("arc"):
        config["costum"]["arc"].getInt()
      else:
        64,
    compile_command:
      if config["costum"].hasKey("compile_command"):
        config["costum"]["compile_command"].getBool()
      else:
        false,

    # LIBRARY
    auto_regist:
      if config["library"].hasKey("auto_regist"):
        config["library"]["auto_regist"].getBool()
      else:
        false,
    onlyMain: if config["library"].hasKey("onlyMain"):
        config["library"]["onlyMain"].getBool()
      else: false,
    skipDir: skipDir,
    skipFile: skipFile,
    packages: packages,
    included: included,
    linkname: linkname,
    linkdir: linkdir,
  )

  return configN

proc init*() =
  if fileExists("config.toml"):
    echo "project already"
    return

  echo "Project Name: "
  let name = stdin.readLine()
  echo "description: "
  let desc = stdin.readLine()

  let config = &"""
[project]
name = "{name}"
desc = "{desc}"
version = "c++17"
files = ["src/main.cpp"]
compiler = "mingw"

[library]


[costum]
macro = ""
build = "binary"
arc = 64
compile_command = false
"""
  writeFile("config.toml", config)
  if dirExists("src"):
    #wont do anything
    return

  # creating /src
  createDir("src")
  writeFile("src/main.cpp", "")

proc run*() =
  var result: int
  var target: string
  if dirExists("out") == false:
    echo "build it first"
    return

  target = &"""out/{read().arc}/{read().name}"""
  result = execCmd(target)
  if result != 0:
    echo "failed to run"
    return
