@echo off
powershell -NoProfile -ExecutionPolicy ByPass -File .\setup.ps1 %1
IF ERRORLEVEL 0 GOTO Success
IF ERRORLEVEL 1 GOTO Error

:Error
echo %1 Failed
goto Done

:Success
echo %1 Success
goto Done

:Done
pause >nul