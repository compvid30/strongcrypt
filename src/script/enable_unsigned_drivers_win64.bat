@echo off

bcdedit.exe /set TESTSIGNING ON


SHUTDOWN /r /t 10 /c "Reboot in 10 seconds"