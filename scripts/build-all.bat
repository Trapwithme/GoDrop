@echo off
setlocal

if not exist ..\dist mkdir ..\dist

echo Building Go...
cd ..\ports\go
call builder.bat
cd ..\..\scripts

echo Building Rust...
cd ..\ports\rust
call builder.bat
cd ..\..\scripts

echo Building C#...
cd ..\ports\csharp
call builder.bat
cd ..\..\scripts

echo Preparing PowerShell...
cd ..\ports\powershell
call builder.bat
cd ..\..\scripts

echo Building C++...
cd ..\ports\cpp
call builder.bat
cd ..\..\scripts

echo Preparing JavaScript...
cd ..\ports\javascript
call builder.bat
cd ..\..\scripts

echo Done. Outputs in ..\dist\
endlocal
