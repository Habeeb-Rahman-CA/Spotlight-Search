@echo off
setlocal

set "QT_BIN=C:\Qt\6.10.2\mingw_64\bin"
set "CMAKE_BIN=C:\Qt\Tools\CMake_64\bin"
set "NINJA_BIN=C:\Qt\Tools\Ninja"
set "MINGW_BIN=C:\Qt\Tools\mingw1310_64\bin"

set "PATH=%QT_BIN%;%CMAKE_BIN%;%NINJA_BIN%;%MINGW_BIN%;%PATH%"

echo [1/4] Cleaning previous build...
if exist build rd /s /q build
mkdir build
cd build

echo [2/4] Configuring Release build...
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release ..

echo [3/4] Building Trinode...
cmake --build . --config Release

echo [4/4] Gathering dependencies (windeployqt)...
if exist appTrinode.exe (
    if exist ..\release_out rd /s /q ..\release_out
    mkdir ..\release_out
    xcopy /Y appTrinode.exe ..\release_out\
    windeployqt --qmldir ..\ ..\release_out\appTrinode.exe
    echo.
    echo Done! Your production-ready app is in the 'release_out' folder.
) else (
    echo Error: appTrinode.exe not found. Build might have failed.
)
