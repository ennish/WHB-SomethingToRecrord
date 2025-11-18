@echo off
setlocal enabledelayedexpansion

title Java Environment Check and Setup

echo.
echo ========================================
echo        Java Environment Check and Setup Tool
echo ========================================
echo.

:: Check if Java is on PATH
where java >nul 2>nul
if %errorlevel% equ 0 (
    echo [INFO] Java environment is configured
    for /f "tokens=*" %%i in ('where java') do (
        echo [INFO] Java path: %%i
    )
    java -version 2>&1 | findstr /i "version" >nul && (
        echo [INFO] Java version:
        java -version 2>&1 | findstr /i "version"
    )
    goto :end
)

echo [WARN] Java not found in PATH, starting configuration...
echo.

:: User selection
echo.
set /p "choice=Please choose JDK directory [1-!jdk_count!], or enter m to specify manually: "

if "!choice!"=="m" goto :manual_select

set /a choice=!choice! 2>nul
if !choice! geq 1 if !choice! leq !jdk_count! (
    call set "selected_jdk=%%jdk_!choice!%%"
    goto :validate_jdk
) else (
    echo [ERROR] Invalid selection
    goto :manual_select
)

:manual_select
echo.
set /p "jdk_dir=Please enter the full path of the JDK installation directory: "

:: Remove surrounding quotes if any
set "jdk_dir=%jdk_dir:"=%"
set "jdk_dir=%jdk_dir:'=%"

if not exist "%jdk_dir%" (
    echo [ERROR] Directory does not exist: %jdk_dir%
    pause
    exit /b 1
)

set "selected_jdk=%jdk_dir%"

:validate_jdk
if not exist "%selected_jdk%\bin\java.exe" (
    echo [ERROR] Not a valid JDK directory: %selected_jdk%
    echo Please ensure the directory contains bin\java.exe
    pause
    exit /b 1
)

echo [INFO] Selected JDK directory: %selected_jdk%

set "java_bin=%selected_jdk%\bin"

echo %PATH% | find /i "%java_bin%" >nul
if %errorlevel% equ 0 (
    echo [INFO] The JDK directory is already in PATH
    goto :show_result
)

set "PATH=%java_bin%;%PATH%"

echo [SUCCESS] Java has been temporarily added to the current session PATH

echo.
set /p "add_permanent=Do you want to permanently add to system environment variables? [Y/N]: "

if /i "!add_permanent!"=="Y" (
    setx PATH "%java_bin%;%PATH%" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [SUCCESS] Permanently added to user environment variables
        echo [NOTE] You need to restart the command prompt for changes to take effect
    ) else (
        echo [WARN] Failed to set permanent environment variable, please add manually
    )
) else (
    echo [INFO] Not added permanently. Please add to system environment variables manually
)

:show_result
echo.
echo ========================================
echo           Java environment configuration complete
echo ========================================
echo Java path: %java_bin%\java.exe
echo.
echo Java version info:
"%java_bin%\java.exe" -version 2>&1
echo.

:end
echo.
echo Press any key to exit...
pause >nul