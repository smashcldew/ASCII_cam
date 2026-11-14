@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"
title ASCII Cam

if not exist ".venv\Scripts\python.exe" (
    echo [X] 還沒安裝，請先點兩下 install.bat
    pause
    exit /b 1
)

rem 有帶參數就直接傳給程式，例如：run.bat --vcam --color
if not "%~1"=="" (
    ".venv\Scripts\python.exe" ascii_cam.py %*
    goto end
)

echo ==========================================
echo   ASCII Cam
echo ==========================================
echo   1. 只開預覽視窗
echo   2. 預覽 + 虛擬攝影機
echo   3. 預覽 + 虛擬攝影機 + 彩色
echo   4. 離開
echo.
choice /c 1234 /n /m "請選擇 [1-4]： "

if errorlevel 4 goto end
if errorlevel 3 (
    ".venv\Scripts\python.exe" ascii_cam.py --vcam --color
    goto end
)
if errorlevel 2 (
    ".venv\Scripts\python.exe" ascii_cam.py --vcam
    goto end
)
".venv\Scripts\python.exe" ascii_cam.py

:end
echo.
echo 程式已結束。
pause
endlocal
