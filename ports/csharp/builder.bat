@echo off
setlocal

set /p URL=Enter direct artifact URL (http/https): 
if "%URL%"=="" (
  echo URL is required.
  exit /b 1
)

if not exist ..\..\dist mkdir ..\..\dist

echo Building C# executable...
dotnet publish GoDrop.csproj -c Release -r win-x64 --self-contained true -o ..\..\dist\godrop-csharp
if errorlevel 1 exit /b 1
copy ..\..\dist\godrop-csharp\GoDrop.exe ..\..\dist\godrop-csharp.exe >nul

(
  echo @echo off
  echo ..\..\dist\godrop-csharp.exe --url "%URL%" --out "%%TEMP%%\godrop-output.bat" --type bat --locale en
) > run-downloader.bat

echo Built: ..\..\dist\godrop-csharp.exe
echo Created launcher: ports\csharp\run-downloader.bat
endlocal
