@echo off
chcp 65001 >nul
cd /d "%~dp0"
git add -A
git -c user.name="Hryhorii Kotilievskyi" -c user.email="gresor0209@gmail.com" commit -m "Energy measurements (HWiNFO SMU) + final report" >nul 2>&1
where gh >nul 2>&1
if %errorlevel%==0 (
  gh auth status >nul 2>&1 || gh auth login --web
  gh repo create perf-lab --public --source . --remote origin --push && goto done
)
echo.
echo 1) Open https://github.com/new , name: perf-lab , Public, NO readme, Create.
echo 2) Copy the repo URL (https://github.com/.../perf-lab.git) and paste it here.
set /p URL=Repo URL: 
git remote remove origin >nul 2>&1
git remote add origin %URL%
git branch -M main
git push -u origin main
:done
echo.
git remote get-url origin
pause
