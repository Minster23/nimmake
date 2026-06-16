# nimmake

*A lightweight C++ project manager written in Nim.*

`nimmake` is a lightweight build tool designed to simplify modern C++ project management. It focuses on keeping projects easy to configure while providing automatic source discovery, dependency registration, and integration with development tools such as `clangd`.

Created and maintained by **Neirra**.

---

## Features

- Simple project initialization
- Automatic source file discovery
- Automatic include directory registration
- GitHub package support
- `compile_commands.json` generation
- Minimal TOML configuration
- MinGW support

---

## Installation

Clone the repository and build it using Nim.

```bash
git clone https://github.com/Minster23/nimmake.git
cd nimmake
nimble build
```

After building, place the executable in your system `PATH`.

---

## Quick Start

Create a new project.

```bash
nimmake init
```

Build the project.

```bash
nimmake build
```

Run the executable.

```bash
nimmake run
```

Print the current configuration.

```bash
nimmake check
```

Show available commands.

```bash
nimmake help
```

---

## Commands

| Command | Description |
|----------|-------------|
| `init` | Generate a new `config.toml` |
| `build` | Build the current project |
| `run` | Run the generated executable |
| `check` | Display the parsed configuration |
| `help` | Show command usage |

---

## Configuration

Projects are configured using a single `config.toml`.

### Project

```toml
[project]

name     = "MyProject"
desc     = ""
version  = "c++17"

files = [
    "src/main.cpp"
]

compiler = "mingw"
```

| Field | Description |
|------|-------------|
| `name` | Project name |
| `desc` | Project description |
| `version` | C++ language standard |
| `files` | Entry source files |
| `compiler` | Compiler to use |

---

### Library

```toml
[library]

auto_regist = true
onlyMain    = true

skipDir = [
    "tests",
    "examples"
]

packages = [
    "nlohmann/json"
]

included = []
linkdir  = []
linkname = []
```

| Field | Description |
|------|-------------|
| `auto_regist` | Automatically discover source files and include directories |
| `onlyMain` | Restrict executable entry points to files listed in `project.files` |
| `skipDir` | Directories ignored during scanning |
| `packages` | External GitHub packages |
| `included` | Additional include directories |
| `linkdir` | Additional linker search directories |
| `linkname` | Libraries to link against |

---

### Custom

```toml
[costum]

macro           = ""
build           = "binary"
arc             = 64
compile_command = true
```

| Field | Description |
|------|-------------|
| `macro` | Additional compiler flags |
| `build` | Build type |
| `arc` | Target architecture |
| `compile_command` | Generate `compile_commands.json` |

---

## Example Project

```
MyProject/
├── src/
│   └── main.cpp
├── ext/
├── config.toml
└── nimmake.exe
```

Build the project.

```bash
nimmake build
```

Run the executable.

```bash
nimmake run
```

---

## Roadmap

- Incremental builds
- Parallel compilation
- Additional compiler support
- Package manager
- Better dependency resolution
- Plugin system

---

## Philosophy

`nimmake` is built around one idea:

> C++ project management should be straightforward.

Instead of writing complex build scripts, developers should be able to describe their project with a small configuration file and let the build system handle the rest.

---

## License

MIT License.

## Credit
docs by ChatGPT
code by neirra
