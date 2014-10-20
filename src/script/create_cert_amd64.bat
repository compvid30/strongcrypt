@echo off

C:\WinDDK\7600.16385.1\bin\amd64\MakeCert.exe -r -pe -ss PrivateCertStore -n "CN=strongcrypt.org" %~dp0\sccert_amd64.cer