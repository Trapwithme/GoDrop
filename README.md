# GoDrop Multi-Port Edition

GoDrop now keeps every language in an organized folder under `ports/`, including Go.

## Folder layout

- Go: `ports/go`
- Rust: `ports/rust`
- C#: `ports/csharp`
- PowerShell: `ports/powershell`
- C++: `ports/cpp`

Each folder includes a `builder.bat` that:
1. Prompts the user for a direct URL at runtime.
2. Builds (or prepares) that language variant.
3. Generates a `run-downloader.bat` launcher in the same folder with the entered URL wired in.

## Behavior

All variants download/save `.bat` or `.exe` artifacts and print status output in locale options (`en`, `es`, `fr`).

## Per-language usage

### Go
```bat
cd ports\go
builder.bat
run-downloader.bat
```

### Rust
```bat
cd ports\rust
builder.bat
run-downloader.bat
```

### C#
```bat
cd ports\csharp
builder.bat
run-downloader.bat
```

### PowerShell
```bat
cd ports\powershell
builder.bat
run-downloader.bat
```

### C++
```bat
cd ports\cpp
builder.bat
run-downloader.bat
```

## Build everything

From `scripts/`:

```bat
build-all.bat
```

Artifacts are placed in `dist\`.
