@echo off
setlocal

if "%~1"=="" exit /b 1

set "WEZTERM=%ProgramFiles%\WezTerm\wezterm-gui.exe"

if not exist "%WEZTERM%" (
    echo WezTerm not found at:
    echo   %WEZTERM%
    pause
    exit /b 1
)

set "MSYSTEM=UCRT64"

start "" "%WEZTERM%" start -- ^
    "C:\msys64\usr\bin\bash.exe" ^
    -l -c "exec nvim \"$1\"" bash "%~1"

exit /b 0
