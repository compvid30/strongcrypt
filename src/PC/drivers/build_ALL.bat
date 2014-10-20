@echo off

rem The path and directory of this batch file
set BABAT_FILE_DIR=%~dp0
rem The CWD (we return to this dir after building)
set CWD=%cd%

echo Building PC x86 drivers...
start build_x86.bat

echo Building PC amd64 drivers...
start build_amd64.bat


rem Return to original CWD
cd %CWD%

