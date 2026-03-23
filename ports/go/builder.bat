@echo off
setlocal

set /p URL=Enter direct artifact URL (http/https): 
if "%URL%"=="" (
  echo URL is required.
  exit /b 1
)

if not exist ..\..\dist mkdir ..\..\dist

echo Building Go executable...
go build -o ..\..\dist\godrop-go.exe main.go
if errorlevel 1 exit /b 1

(
  echo @echo off
  echo ..\..\dist\godrop-go.exe --url "%URL%" --out "%%TEMP%%\godrop-output.bat" --type bat --locale en
) > run-downloader.bat

echo Built: ..\..\dist\godrop-go.exe
echo Created launcher: ports\go\run-downloader.bat
endlocal
