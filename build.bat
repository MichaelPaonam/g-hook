@echo off
setlocal

rem Check for Java.
where java >nul 2>nul
if errorlevel 1 goto :no_java

rem Use BOB_JAR env var if provided, otherwise default to bob.jar.
if "%BOB_JAR%"=="" set "BOB_JAR=bob.jar"

if not exist "%BOB_JAR%" goto :no_bob

rem Remove the previous bundle output.
rmdir /s /q bundle 2>nul

rem Run bob to produce the archive bundle.
java -jar "%BOB_JAR%" --platform js-web --architectures wasm-web --archive --bundle-output bundle resolve build bundle
if errorlevel 1 exit /b %errorlevel%

rem Defold writes to bundle\<subdir> - flatten that into build\.
rmdir /s /q build 2>nul
mkdir build 2>nul

set "BUNDLE_SUBDIR="
for /d %%D in ("bundle\*") do (
    set "BUNDLE_SUBDIR=%%~fD"
    goto :found_subdir
)

:found_subdir
if defined BUNDLE_SUBDIR (
    xcopy "%BUNDLE_SUBDIR%\*" "build\" /E /I /Y >nul
) else (
    xcopy "bundle\*" "build\" /E /I /Y >nul
)
if errorlevel 4 exit /b %errorlevel%

echo HTML5 build written to build\
endlocal
exit /b 0

:no_java
echo Java is required to run bob.jar (JDK 17+).
echo Install it from https://adoptium.net or your system package manager.
exit /b 1

:no_bob
echo %BOB_JAR% not found. Download it from:
echo   https://github.com/defold/defold/releases
echo.
echo Place it in this directory or set the BOB_JAR environment variable.
exit /b 1
