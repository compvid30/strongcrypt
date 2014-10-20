@echo off

set PROJECT_DIR_MAIN=%~dp0\main

echo Note: This batch file does only work with Delphi 2007 or higher.
echo.
echo.
echo To make this work under Win64, you need to copy:
echo Borland.Common.Targets
echo Borland.Cpp.Targets
echo Borland.Delphi.Targets
echo Borland.Group.Targets
echo from C:\Windows\Microsoft.NET\Framework\v2.0.50727
echo to C:\Windows\Microsoft.NET\Framework64\v2.0.50727
echo.
echo.

call "C:\Delphi\Ide\2007\bin\rsvars.bat"

msbuild %PROJECT_DIR_MAIN%\StrongCrypt.dproj

