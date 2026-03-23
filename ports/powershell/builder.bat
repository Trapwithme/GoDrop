@echo off
setlocal

set /p URL=Enter direct artifact URL (http/https): 
if "%URL%"=="" (
  echo URL is required.
  exit /b 1
)

if not exist ..\..\dist mkdir ..\..\dist
copy godrop.ps1 ..\..\dist\godrop.ps1 >nul

(
  echo @echo off
  echo powershell -ExecutionPolicy Bypass -File ..\..\dist\godrop.ps1 -Url "%URL%" -Out "%%TEMP%%\godrop-output.bat" -Type bat -Locale en
) > run-downloader.bat

echo Copied script: ..\..\dist\godrop.ps1
echo Created launcher: ports\powershell\run-downloader.bat
endlocal
