@echo off
set variant=%1
set url=%2
set out=%3
set locale=%4
if "%variant%"=="" goto usage
if "%url%"=="" goto usage
if "%out%"=="" set out=%TEMP%\godrop-output.bat
if "%locale%"=="" set locale=en

if /I "%variant%"=="go" dist\godrop-go.exe --url "%url%" --out "%out%" --type bat --locale %locale%
if /I "%variant%"=="rust" dist\godrop-rust.exe --url "%url%" --out "%out%" --file-type bat --locale %locale%
if /I "%variant%"=="csharp" dist\godrop-csharp.exe --url "%url%" --out "%out%" --type bat --locale %locale%
if /I "%variant%"=="powershell" powershell -ExecutionPolicy Bypass -File ports\powershell\godrop.ps1 -Url "%url%" -Out "%out%" -Type bat -Locale %locale%
if /I "%variant%"=="cpp" dist\godrop-cpp.exe "%url%" "%out%" bat %locale%
goto :eof

:usage
echo Usage: run-variant.bat [go^|rust^|csharp^|powershell^|cpp] [url] [out] [locale]
