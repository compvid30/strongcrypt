@echo off

bcdedit.exe /set TESTSIGNING OFF


SHUTDOWN /r /t 10 /c "Reboot in 10 seconds"