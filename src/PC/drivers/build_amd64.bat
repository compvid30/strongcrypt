@echo off

rem The path and directory of this batch file
set BABAT_FILE_DIR=%~dp0
rem The CWD (we return to this dir after building)
set CWD=%cd%


echo Building PC amd64 drivers...

set FREEOTFE_CPU_OVERRIDE=amd64

rem Note that x86 and amd64 batch files build in a slightly different order.
rem This is to reduce the risk of the same drivers being built simultaneously
rem for x86 and amd64, and the build script copying copying files over at a
rem time that that are being used by the other build.

cd %BABAT_FILE_DIR%\CYPHER_DRIVERS\CYPHER_AES_Gladman
call my_build_sys.bat
cd %BABAT_FILE_DIR%\CYPHER_DRIVERS\CYPHER_AES_ltc
call my_build_sys.bat
cd %BABAT_FILE_DIR%\CYPHER_DRIVERS\CYPHER_BLOWFISH
call my_build_sys.bat
cd %BABAT_FILE_DIR%\CYPHER_DRIVERS\CYPHER_CAST5
call my_build_sys.bat
cd %BABAT_FILE_DIR%\CYPHER_DRIVERS\CYPHER_CAST6_Gladman
call my_build_sys.bat
cd %BABAT_FILE_DIR%\CYPHER_DRIVERS\CYPHER_DES
call my_build_sys.bat
cd %BABAT_FILE_DIR%\CYPHER_DRIVERS\CYPHER_MARS_Gladman
call my_build_sys.bat
cd %BABAT_FILE_DIR%\CYPHER_DRIVERS\CYPHER_NULL
call my_build_sys.bat
cd %BABAT_FILE_DIR%\CYPHER_DRIVERS\CYPHER_RC6_Gladman
call my_build_sys.bat
cd %BABAT_FILE_DIR%\CYPHER_DRIVERS\CYPHER_RC6_ltc
call my_build_sys.bat
cd %BABAT_FILE_DIR%\CYPHER_DRIVERS\CYPHER_SERPENT_Gladman
call my_build_sys.bat
cd %BABAT_FILE_DIR%\CYPHER_DRIVERS\CYPHER_TWOFISH_Gladman
call my_build_sys.bat
cd %BABAT_FILE_DIR%\CYPHER_DRIVERS\CYPHER_TWOFISH_HifnCS
call my_build_sys.bat
cd %BABAT_FILE_DIR%\CYPHER_DRIVERS\CYPHER_TWOFISH_ltc
call my_build_sys.bat
cd %BABAT_FILE_DIR%\CYPHER_DRIVERS\CYPHER_XOR
call my_build_sys.bat
cd %BABAT_FILE_DIR%\DRIVER
call my_build_sys.bat
cd %BABAT_FILE_DIR%\HASH_DRIVERS\HASH_MD
call my_build_sys.bat
cd %BABAT_FILE_DIR%\HASH_DRIVERS\HASH_NULL
call my_build_sys.bat
cd %BABAT_FILE_DIR%\HASH_DRIVERS\HASH_RIPEMD
call my_build_sys.bat
cd %BABAT_FILE_DIR%\HASH_DRIVERS\HASH_SHA
call my_build_sys.bat
cd %BABAT_FILE_DIR%\HASH_DRIVERS\HASH_TIGER
call my_build_sys.bat
cd %BABAT_FILE_DIR%\HASH_DRIVERS\HASH_WHIRLPOOL
call my_build_sys.bat


rem Return to original CWD
cd %CWD%

echo.
echo.
echo amd64 build completed.
echo.
echo.

