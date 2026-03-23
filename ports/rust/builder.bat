@echo off
setlocal

set /p URL=Enter direct artifact URL (http/https): 
if "%URL%"=="" (
  echo URL is required.
  exit /b 1
)

if not exist ..\..\dist mkdir ..\..\dist

echo Building Rust executable...
cargo build --release
if errorlevel 1 exit /b 1
copy target\release\godrop-rust.exe ..\..\dist\godrop-rust.exe >nul

(
  echo @echo off
  echo ..\..\dist\godrop-rust.exe --url "%URL%" --out "%%TEMP%%\godrop-output.bat" --file-type bat --locale en
) > run-downloader.bat

echo Built: ..\..\dist\godrop-rust.exe
echo Created launcher: ports\rust\run-downloader.bat
endlocal
