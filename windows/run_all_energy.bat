@echo off
chcp 65001 >nul
rem ---- one-click energy measurement: HWiNFO shared memory + timed phases ----
net session >nul 2>&1
if %errorlevel% neq 0 (
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)
cd /d "%~dp0"
set "HW=%USERPROFILE%\Downloads\HWiNFO64.exe"
if not exist "%HW%" (echo HWiNFO64.exe not found in Downloads & pause & exit /b)

taskkill /im HWiNFO64.exe /f >nul 2>&1
taskkill /im HWiNFO32.exe /f >nul 2>&1
timeout /t 2 >nul

(
echo [Settings]
echo SensorsOnly=1
echo ShowWelcomeAndProgress=0
echo SensorInterval=1000
echo MinimalizeSensors=1
echo SensorsSM=1
) > "%USERPROFILE%\Downloads\HWiNFO64.INI"

del /q power.csv power_error.txt stop.flag >nul 2>&1
echo Starting HWiNFO (sensors + shared memory)...
start "" "%HW%"
echo Waiting 20 s for sensors to settle...
timeout /t 20 >nul

start "" /b powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0sample_power.ps1"
timeout /t 12 >nul
if exist power_error.txt (type power_error.txt & echo In HWiNFO: Settings - check "Shared Memory Support", OK, then run this again. & pause & exit /b)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0measure_phases.ps1"

timeout /t 5 >nul
echo.> stop.flag
timeout /t 12 >nul
taskkill /im HWiNFO64.exe >nul 2>&1
timeout /t 2 >nul
taskkill /im HWiNFO64.exe /f >nul 2>&1
del /q stop.flag >nul 2>&1

if exist power.csv (echo OK: power.csv written) else (echo !! power.csv NOT found)
echo Done. Tell Claude "готово".
pause
