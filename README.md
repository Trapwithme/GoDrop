# GoDrop Multi-Port Edition

GoDrop now keeps every language in an organized folder under `ports/`, including Go.

## Folder layout

- Go: `ports/go`
- Rust: `ports/rust`
- C#: `ports/csharp`
- PowerShell: `ports/powershell`
- C++: `ports/cpp`
- JavaScript (Node.js): `ports/javascript`

Each folder includes a `builder.bat` that:
1. Prompts for the download URL.
2. Encrypts and embeds that URL into code/script for the selected language.
3. Builds (or prepares) that language variant.

## Behavior

All variants decrypt the embedded URL at runtime, download/save `.bat` or `.exe` artifacts, and print status output in locale options (`en`, `es`, `fr`).

## Per-language usage

### Go
```bat
cd ports\go
builder.bat
..\..\dist\godrop-go.exe --out "%TEMP%\godrop-output.bat" --type bat --locale en
```

### Rust
```bat
cd ports\rust
builder.bat
..\..\dist\godrop-rust.exe --out "%TEMP%\godrop-output.bat" --file-type bat --locale en
```

### C#
```bat
cd ports\csharp
builder.bat
..\..\dist\godrop-csharp.exe --out "%TEMP%\godrop-output.bat" --type bat --locale en
```

### PowerShell
```bat
cd ports\powershell
builder.bat
powershell -ExecutionPolicy Bypass -File ..\..\dist\godrop.ps1 -Out "%TEMP%\godrop-output.bat" -Type bat -Locale en
```

### C++
```bat
cd ports\cpp
builder.bat
..\..\dist\godrop-cpp.exe "%TEMP%\godrop-output.bat" bat en
```

### JavaScript (Node.js)
```bat
cd ports\javascript
builder.bat
node ..\..\dist\godrop-js.js --out "%TEMP%\godrop-output.bat" --type bat --locale en
```

## Build everything

From `scripts/`:

```bat
build-all.bat
```

Artifacts are placed in `dist\`.
