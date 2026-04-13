@echo off
setlocal enabledelayedexpansion

rem ==========================================
rem Fetch or update the latest llama.cpp from GitHub
rem ==========================================

rem Set target directory (override with LLAMA_SRC_DIR env var or first argument)
set "DEFAULT_DIR=%USERPROFILE%\source\llama.cpp"

if not "%~1"=="" (
    set "TARGET_DIR=%~1"
) else if defined LLAMA_SRC_DIR (
    set "TARGET_DIR=%LLAMA_SRC_DIR%"
) else (
    set "TARGET_DIR=%DEFAULT_DIR%"
)

rem Optional: pin to a specific commit hash for reproducible builds
rem Set LLAMA_COMMIT env var or pass as second argument
if not "%~2"=="" (
    set "PIN_COMMIT=%~2"
) else if defined LLAMA_COMMIT (
    set "PIN_COMMIT=%LLAMA_COMMIT%"
) else (
    set "PIN_COMMIT="
)

rem Ensure target directory exists
if not exist "%TARGET_DIR%" (
    echo [INFO] Directory "%TARGET_DIR%" does not exist. Creating...
    mkdir "%TARGET_DIR%"
)

rem Navigate to target directory
pushd "%TARGET_DIR%" >nul 2>&1 || (
    echo [ERROR] Failed to enter "%TARGET_DIR%".
    exit /b 1
)

rem Update existing repository or clone if missing
if exist ".git" (
    echo [INFO] Git repository detected. Pulling latest changes...
    echo [WARNING] This will discard any local changes in "%TARGET_DIR%".
    git reset --hard >nul 2>&1
    git clean -fd >nul 2>&1
    git pull origin main
    if errorlevel 1 (
        echo [ERROR] Failed to update repository.
        popd
        exit /b 1
    )
) else (
    echo [INFO] No Git repository found. Cloning llama.cpp...
    rem Go up to parent directory to safely clone
    pushd .. >nul
    git clone https://github.com/ggerganov/llama.cpp.git "%TARGET_DIR%"
    if errorlevel 1 (
        echo [ERROR] Failed to clone repository.
        popd
        exit /b 1
    )
    popd
)

rem Pin to a specific commit if requested (for reproducible / verified builds)
if defined PIN_COMMIT (
    echo [INFO] Checking out pinned commit: %PIN_COMMIT%
    git checkout %PIN_COMMIT%
    if errorlevel 1 (
        echo [ERROR] Failed to checkout commit %PIN_COMMIT%.
        popd
        exit /b 1
    )
)

echo [SUCCESS] Latest llama.cpp fetched/updated successfully.
popd
pause
