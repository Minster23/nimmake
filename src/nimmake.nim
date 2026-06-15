import configManager
import builder

import std/os

proc screen() =
  echo """
  nimmake: C++/C project manager
       =made by neirra=

  help = for more
  """

proc help() =
  echo """ this is help """

proc main() =
  let arg = commandLineParams()

  if arg.len == 0:
    screen()
    echo "Currents: ", getCurrentDir()
    quit(0)

  case arg[0]
  of "help":
    help()
    quit(1)
  of "init":
    configManager.init()
    echo configManager.read()
    quit(1)
  of "build":
    builder.build(configManager.read())
    quit(1)
  of "check":
    echo configManager.read()
    quit(1)
  else:
    echo("Goodbye")
    quit(1)

main()
