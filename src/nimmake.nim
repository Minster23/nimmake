import std/os

import configManager
import builder

const AppName = "nimmake"
const AppDesc = "C/C++ project manager"
const Author = "neirra"

proc showBanner() =
  echo """
nimmake - C/C++ project manager
made by neirra

Usage:
  nimmake <command>

Try:
  nimmake help
"""

proc showHelp() =
  echo """
nimmake - C/C++ project manager

Usage:
  nimmake <command>

Commands:
  init       Create nimmake config
  build      Build project
  run        Run project output
  check      Print current config
  help       Show this help message

Examples:
  nimmake init
  nimmake build
  nimmake run
  nimmake check
"""

proc cmdInit() =
  configManager.init()
  echo "Config created:"
  echo configManager.read()

proc cmdBuild() =
  let cfg = configManager.read()
  builder.build(cfg)

proc cmdCheck() =
  echo configManager.read()

proc cmdRun() =
  configManager.run()

proc main() =
  let args = commandLineParams()

  if args.len == 0:
    showBanner()
    echo "Current directory: ", getCurrentDir()
    quit(0)

  case args[0]
  of "help", "-h", "--help":
    showHelp()
    quit(0)

  of "init":
    cmdInit()
    quit(0)

  of "build":
    cmdBuild()
    quit(0)

  of "check":
    cmdCheck()
    quit(0)

  of "run":
    cmdRun()
    quit(0)

  else:
    echo "Unknown command: ", args[0]
    echo "Run `nimmake help` for available commands."
    quit(1)

when isMainModule:
  main()
