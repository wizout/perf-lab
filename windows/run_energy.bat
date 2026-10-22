@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo Energy measurement ~2.5 min, close heavy apps and do not touch the PC
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0measure_energy.ps1"
echo.
pause
