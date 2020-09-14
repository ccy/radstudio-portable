@echo off
powershell -NoProfile -ExecutionPolicy ByPass -File .\setup.ps1
IF ERRORLEVEL 0 GOTO Success
IF ERRORLEVEL 1 GOTO Error

:Error
echo Setup Failed
goto Done

:Success
echo Setup Success
goto Done

:Done
pause >nul