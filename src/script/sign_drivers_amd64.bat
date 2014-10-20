@echo off

echo Signig Main Driver...
echo
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCMain.sys
echo
echo Signing Cypher Drivers...
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCCypherAES_ltc.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCCypherAES_gm.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCCypherBLOWFISH.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCCypherCAST5.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCCypherCAST6_gm.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCCypherDES.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCCypherMARS_gm.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCCypherNull.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCCypherRC6_gm.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCCypherRC6_ltc.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCCypherSerpent_gm.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCCypherTWOFISH_gm.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCCypherTwofish_HifnCS.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCCypherTwofish_ltc.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCCypherXOR.sys
echo
echo Signing Hash Drivers...
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCHashMD.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCHashNull.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCHashRIPEMD.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCHashSHA.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCHashTiger.sys
C:\WinDDK\7600.16385.1\bin\amd64\SignTool.exe sign /v /s PrivateCertStore /n strongcrypt.org /t http://timestamp.verisign.com/scripts/timstamp.dll ..\..\bin\PC\amd64\SCHashWhirlpool.sys

echo.
echo.
echo All drivers signed.
echo.
echo.
