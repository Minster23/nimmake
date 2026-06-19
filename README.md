# nimmake

*A lightweight C++ project manager written in Nim.*

`nimmake` is a lightweight build system focused on making C++ projects simple to configure and build. It automatically discovers source files, registers include directories, downloads GitHub dependencies, and generates `compile_commands.json` for editor integration.

Created and maintained by **Neirra**.

---

## Features

* Simple project initialization
* Automatic source file discovery
* Wildcard source support (`src/*.cpp`)
* Automatic include directory registration
* Automatic object caching (incremental compilation)
* Automatic `compile_commands.json` generation
* GitHub package support
* Configurable directory and file skipping
* Minimal TOML configuration
* MinGW support

---

## Requirements

Currently supported:

* Windows
* x64 (64-bit)
* MinGW (MSYS2 recommended)

Additional compilers and platforms are planned.

---

## Installation

Clone the repository.

```bash
git clone https://github.com/Minster23/nimmake.git
cd nimmake
nimble build
```

Add the directory containing `nimmake.exe` to your system **PATH**.

Verify the installation:

```bash
nimmake help
```

---

## Quick Start

Create a project.

```bash
nimmake init
```

Build.

```bash
nimmake build
```

Run.

```bash
nimmake run
```

Check parsed configuration.

```bash
nimmake check
```

Show help.

```bash
nimmake help
```

---

## Commands

| Command | Description                          |
| ------- | ------------------------------------ |
| `init`  | Generate `config.toml`               |
| `build` | Build the project                    |
| `run`   | Execute the generated application    |
| `check` | Display parsed project configuration |
| `help`  | Show command usage                   |

---

# Configuration

Projects are configured using a single `config.toml`.

## Project

```toml
[project]
name = "MyProject"
desc = "Example project"
version = "c++20"

files = [
    "src/*.cpp"
]

compiler = "mingw"
```

### Project Fields

| Field      | Description                        |
| ---------- | ---------------------------------- |
| `name`     | Project name                       |
| `desc`     | Project description                |
| `version`  | C++ standard (`c++11` ... `c++23`) |
| `files`    | Source files or wildcard patterns  |
| `compiler` | Compiler backend                   |

Examples:

```toml
files = [
    "src/main.cpp"
]
```

```toml
files = [
    "src/*.cpp"
]
```

---

## Library

```toml
[library]

auto_regist = true
onlyMain = true

packages = [
    "ocornut/imgui",
    "fmtlib/fmt"
]

included = [
    "thirdparty/include"
]

linkdir = [
    "thirdparty/lib"
]

linkname = [
    "glfw3",
    "opengl32"
]

skipDir = [
    ".git",
    ".github",
    "docs",
    "examples",
    "misc",
    "tests"
]

skipFile = [
    "imgui_impl_dx9.cpp",
    "imgui_impl_dx10.cpp",
    "imgui_impl_dx11.cpp",
    "imgui_impl_dx12.cpp"
]
```

### Library Fields

| Field         | Description                                                               |
| ------------- | ------------------------------------------------------------------------- |
| `auto_regist` | Automatically discover source files and include directories from packages |
| `onlyMain`    | Only compile executable entry files listed in `project.files`             |
| `packages`    | GitHub repositories downloaded into `ext/`                                |
| `included`    | Additional include directories                                            |
| `linkdir`     | Additional library search directories                                     |
| `linkname`    | Libraries passed to the linker                                            |
| `skipDir`     | Directories ignored during automatic scanning                             |
| `skipFile`    | Files ignored during automatic scanning                                   |

---

## Custom

```toml
[costum]

macro = ""
build = "binary"
arc = 64
compile_command = true
```

### Custom Fields

| Field             | Description                      |
| ----------------- | -------------------------------- |
| `macro`           | Additional compiler flags        |
| `build`           | Build type                       |
| `arc`             | Target architecture              |
| `compile_command` | Generate `compile_commands.json` |

---

# Example

```
MyProject/
├── src/
│   ├── main.cpp
│   ├── app.cpp
│   └── app.h
├── ext/
├── out/
├── config.toml
└── nimmake.exe
```

Build:

```bash
nimmake build
```

Run:

```bash
nimmake run
```

---

## Incremental Compilation

`nimmake` automatically checks timestamps of object files.

Only modified source files are recompiled.

Example:

```
src/main.cpp  ---> out/object/main.o
src/app.cpp   ---> out/object/app.o
```

If only `app.cpp` changes:

```
Compile:
✓ app.cpp

Skip:
✓ main.cpp
```

The final executable is then linked using all object files.

---

## GitHub Packages

Packages are downloaded automatically into the `ext/` directory.

```toml
packages = [
    "ocornut/imgui",
    "glfw/glfw"
]
```

---

## Roadmap

* Parallel compilation
* MSVC support
* Clang support
* Linux support
* macOS support
* Static library target
* Shared library target
* Package manager
* Plugin system
* Better dependency resolution

---

## Philosophy

`nimmake` is designed around one idea:

> C++ projects should be easy to build.

Instead of maintaining large build scripts, developers describe their project using a small TOML file while `nimmake` handles source discovery, dependency registration, incremental compilation, and editor integration automatically.

---

## Credits

* **Code** — Neirra
* **Documentation** — ChatGPT
