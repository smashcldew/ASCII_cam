@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"
title ASCII Cam 安裝程式

echo ==========================================
echo   ASCII Cam 一鍵安裝
echo ==========================================
echo.

rem ---------- 1. 找 Python ----------
set "PY="
where py >nul 2>nul
if not errorlevel 1 (
    py -3 -c "import sys" >nul 2>nul
    if not errorlevel 1 set "PY=py -3"
)
if not defined PY (
    where python >nul 2>nul
    if not errorlevel 1 (
        python -c "import sys" >nul 2>nul
        if not errorlevel 1 set "PY=python"
    )
)

if defined PY goto have_python

echo [!] 找不到 Python。
where winget >nul 2>nul
if errorlevel 1 (
    echo.
    echo 請先到 https://www.python.org/downloads/ 下載並安裝 Python 3.12
    echo 安裝時務必勾選 "Add python.exe to PATH"，裝完再重新執行本檔案。
    pause
    exit /b 1
)
echo 正在用 winget 自動安裝 Python 3.12 ...
winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements
if errorlevel 1 (
    echo.
    echo [X] Python 自動安裝失敗，請手動到 https://www.python.org/downloads/ 安裝。
    pause
    exit /b 1
)
echo.
echo Python 安裝完成！請「關掉這個視窗」，再重新點兩下 install.bat 繼續。
pause
exit /b 0

:have_python
echo [OK] 使用 Python：%PY%
%PY% --version
echo.

rem ---------- 2. 建立專用環境 (.venv) ----------
rem 用虛擬環境就不需要 pip 在全域、也不會弄亂電腦上其他的 Python
if not exist ".venv\Scripts\python.exe" (
    echo 正在建立專用環境 .venv ...
    %PY% -m venv .venv
    if errorlevel 1 (
        echo [X] 建立環境失敗。
        pause
        exit /b 1
    )
)

rem ---------- 3. 安裝套件 ----------
echo 正在安裝套件，第一次會花一點時間 ...
".venv\Scripts\python.exe" -m pip install --upgrade pip
".venv\Scripts\python.exe" -m pip install -r requirements.txt
if errorlevel 1 (
    echo.
    echo [X] 套件安裝失敗，請檢查網路後重試。
    echo     如果訊息提到找不到符合的版本，可能是 Python 版本太新，建議改裝 Python 3.12。
    pause
    exit /b 1
)
echo [OK] 套件安裝完成
echo.

rem ---------- 4. 檢查 OBS (虛擬攝影機需要) ----------
set "OBS_OK="
if exist "%ProgramFiles%\obs-studio\bin\64bit\obs64.exe" set "OBS_OK=1"
if exist "%ProgramFiles(x86)%\obs-studio\bin\64bit\obs64.exe" set "OBS_OK=1"
if exist "%LocalAppData%\Programs\obs-studio\bin\64bit\obs64.exe" set "OBS_OK=1"

if defined OBS_OK (
    echo [OK] 已偵測到 OBS Studio
    goto done
)

echo [!] 沒偵測到 OBS Studio。
echo     想把 ASCII 畫面丟到 Discord / Meet 等視訊軟體，就需要裝 OBS
echo     ^(只要裝好就行，不用開啟 OBS^)。只用預覽視窗的話可以跳過。
echo.
choice /c YN /n /m "要現在自動安裝 OBS Studio 嗎？[Y/N] "
if errorlevel 2 goto done

where winget >nul 2>nul
if errorlevel 1 (
    echo 沒有 winget，請手動到 https://obsproject.com/ 下載安裝。
    goto done
)
winget install -e --id OBSProject.OBSStudio --accept-package-agreements --accept-source-agreements

:done
echo.
echo ==========================================
echo   安裝完成！之後請點兩下 run.bat 來啟動
echo ==========================================
pause
endlocal
