@echo off
setlocal
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v PCFreeDefaultApps /t REG_SZ /d "powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File C:\OEM\install.ps1" /f
if errorlevel 1 exit /b 1
exit /b 0
