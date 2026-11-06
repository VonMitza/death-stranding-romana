@echo off
setlocal
title Death Stranding Director's Cut - Dezinstalare traducere
cd /d "%~dp0"
set "BN=59b95a781c9170b0d13773766e27ad90.bin"
set "FOUND=%TEMP%\DS_RO_cale.txt"
tasklist /fi "imagename eq ds.exe" 2>nul | find /i "ds.exe" >nul
if not errorlevel 1 goto running
if exist "%FOUND%" del /f "%FOUND%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\gaseste_joc.ps1" -Out "%FOUND%" -Start "%~dp0."
if exist "%FOUND%" goto readpath
set /p "GAME=Scrie calea folderului jocului: "
goto go
:readpath
set /p GAME=<"%FOUND%"
del /f "%FOUND%"
:go
set "BIN=%GAME%\data\%BN%"
set "BAK=%BIN%.bak"
if not exist "%BAK%" goto nobak
echo Restaurez arhiva originala...
del /f "%BIN%"
move /y "%BAK%" "%BIN%" >nul
if errorlevel 1 goto failed
if exist "%GAME%\DS_RO_instalare.log" del /f "%GAME%\DS_RO_instalare.log"
echo Gata. Jocul este din nou original.
goto end
:running
echo Jocul este pornit. Inchide-l si ruleaza din nou.
goto end
:nobak
echo Nu exista backup. Repara jocul din Steam:
echo click dreapta pe joc - Properties - Installed Files - Verify integrity.
goto end
:failed
echo Restaurarea a esuat. Foloseste Verify integrity din Steam.
:end
echo.
pause
