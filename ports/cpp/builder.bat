@echo off
setlocal

set /p URL=Enter direct artifact URL (http/https): 
if "%URL%"=="" (
  echo URL is required.
  exit /b 1
)

if not exist ..\..\dist mkdir ..\..\dist

echo Building C++ executable (MSVC cl expected)...
cl /EHsc /std:c++17 main.cpp /Fe:..\..\dist\godrop-cpp.exe
if errorlevel 1 exit /b 1

(
  echo @echo off
  echo ..\..\dist\godrop-cpp.exe "%URL%" "%%TEMP%%\godrop-output.bat" bat en
) > run-downloader.bat

echo Built: ..\..\dist\godrop-cpp.exe
echo Created launcher: ports\cpp\run-downloader.bat
endlocal
