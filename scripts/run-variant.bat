@echo off
set variant=%1
set out=%2
set locale=%3

if "%variant%"=="" goto usage
if "%out%"=="" set out=%TEMP%\godrop-output.bat
if "%locale%"=="" set locale=en

if /I "%variant%"=="go" dist\godrop-go.exe --out "%out%" --type bat --locale %locale%
if /I "%variant%"=="rust" dist\godrop-rust.exe --out "%out%" --file-type bat --locale %locale%
if /I "%variant%"=="csharp" dist\godrop-csharp.exe --out "%out%" --type bat --locale %locale%
if /I "%variant%"=="powershell" powershell -ExecutionPolicy Bypass -File dist\godrop.ps1 -Out "%out%" -Type bat -Locale %locale%
if /I "%variant%"=="cpp" dist\godrop-cpp.exe "%out%" bat %locale%
if /I "%variant%"=="javascript" node dist\godrop-js.js --out "%out%" --type bat --locale %locale%

goto :eof

:usage
echo Usage: run-variant.bat [go^|rust^|csharp^|powershell^|cpp^|javascript] [out] [locale]
