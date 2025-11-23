
@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ===== Settings =====
set "root=%~dp0"
set "assembler=%root%assembler.exe"
set "log=%root%compile.log"

rem Switches
set "DEBUG=0"      rem set to 1 for per-file diagnostics
set "FORCE=0"      rem set by /force
set "REBUILD=0"    rem set by /rebuild
set "CLEAN=0"      rem set by /clean

rem Parse arguments
if "%~1"=="" goto :Run
if /I "%~1"=="/force"   set "FORCE=1" & goto :Run
if /I "%~1"=="/rebuild" set "REBUILD=1" & goto :Run
if /I "%~1"=="/clean"   set "CLEAN=1" & goto :Run
if /I "%~1"=="/help"    goto :ShowHelp

:ShowHelp
echo Usage: %~nx0 [option]
echo.
echo Options:
echo   /force     Compile all files (ignore timestamps)
echo   /rebuild   Compile all files (same as /force)
echo   /clean     Delete all .iram and .bin files, then compile all
echo   /help      Show this help message
echo.
echo If no option is given, performs incremental build (only newer sources).
echo.
echo Examples:
echo   %~nx0            Perform incremental build
echo   %~nx0 /force     Compile all files
echo   %~nx0 /clean     Clean and compile all files
goto :EOF

:Run
rem Counters
set /a compiled=0, skipped=0, failed=0

> "%log%" echo Compilation started at %date% %time%
echo Searching for .txt files under "%root%" ...

rem --- CLEAN step ---
if !CLEAN! EQU 1 (
  echo Cleaning old .iram and .bin files...
  for /r "%root%" %%x in (*.iram *.bin) do del /q "%%x"
  set "REBUILD=1"
)

rem --- Recursively walk all .txt files (unique list) ---
for /f "usebackq delims=" %%f in (`dir /b /s "%root%\*.txt" ^| sort /unique`) do (
  if /I not "%%~nxf"=="assemble_all.txt" (
    set "src=%%~f"
    set "iram=%%~dpf%%~nf.iram"
    set "bin=%%~dpf%%~nf.bin"
    set "rel=!src:%root%=!"

    if !FORCE! EQU 1 (
      call :CompileFile "!src!" "!bin!" "!rel!"
    ) else if !REBUILD! EQU 1 (
      call :CompileFile "!src!" "!bin!" "!rel!"
    ) else (
      set "artifact=!iram!"
      if not exist "!artifact!" (
        call :CompileFile "!src!" "!bin!" "!rel!"
      ) else (
        call :GetStamp "!src!" srcNorm
        call :GetStamp "!artifact!" artNorm
        if "!srcNorm!"=="0" (
          call :CompileFile "!src!" "!bin!" "!rel!"
        ) else if "!artNorm!"=="0" (
          call :CompileFile "!src!" "!bin!" "!rel!"
        ) else (
          if !srcNorm! GTR !artNorm! (
            call :CompileFile "!src!" "!bin!" "!rel!"
          ) else (
            echo Skipping !rel! (up-to-date) >> "%log%"
            echo Skipping !rel! (up-to-date)
            set /a skipped+=1
          )
        )
      )
    )
  )
)

echo(
echo Compilation finished! Log saved to "%log%"
echo Compiled: %compiled%, Skipped: %skipped%, Failed: %failed%
goto :EOF

rem =====================================================================
rem GetStamp: returns YYYYMMDDHHMMSS using PowerShell (locale-invariant)
rem Returns "0" on failure to allow safe numeric comparisons
rem =====================================================================
:GetStamp
setlocal EnableExtensions
set "_path=%~1"
set "_outvar=%~2"
set "_stamp="
if not exist "%_path%" ( endlocal & set "%_outvar%=0" & exit /b )
for /f "usebackq delims=" %%S in (`powershell -NoProfile -Command ^
  "$p='%_path%'; if (Test-Path $p) { (Get-Item $p).LastWriteTime.ToString('yyyyMMddHHmmss') }"`) do (
  set "_stamp=%%S"
)
if not defined _stamp set "_stamp=0"
endlocal & set "%_outvar%=%_stamp%"
exit /b

rem =====================================================================
rem Compile subroutine
rem =====================================================================
:CompileFile
echo Compiling %~3 ...
call "%assembler%" "%~1" "%~2"
if errorlevel 1 (
  echo FAILED: %~3 >> "%log%"
  echo Failed to compile %~3
  set /a failed+=1
) else (
  echo SUCCESS: %~3 >> "%log%"
  echo Successfully compiled %~3
  set /a compiled+=1
)
exit /b
