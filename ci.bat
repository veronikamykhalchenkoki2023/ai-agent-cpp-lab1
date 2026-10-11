@echo off
setlocal enabledelayedexpansion

cmake -S . -B build
if errorlevel 1 exit /b 1

cmake --build build --config Debug
if errorlevel 1 exit /b 1

ctest --test-dir build -C Debug --output-on-failure
if errorlevel 1 exit /b 1

if exist "build\Debug\hello.exe" (
    echo Hello binary exists: build\Debug\hello.exe
) else (
    echo Missing build\Debug\hello.exe
    exit /b 1
)
