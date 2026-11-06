@echo off
setlocal
title Death Stranding Director's Cut - Traducere in limba romana
cd /d "%~dp0"
set "CLI=%~dp0tools\decima\decima-cli.exe"
set "JAVA=%~dp0tools\decima\runtime\bin\java.exe"
set "JSON=%~dp0traducere\ds_ro.json"
set "IMG=%~dp0traducere\imagini_ro.dat"
set "BN=59b95a781c9170b0d13773766e27ad90.bin"
set "SIZE=5480926370"
set "TMPD=%TEMP%\DS_RO_compiled"
set "FOUND=%TEMP%\DS_RO_cale.txt"

echo ============================================================
echo  Death Stranding Director's Cut - Traducere in limba romana
echo ============================================================
echo.
if not exist "%CLI%" goto nocli
if not exist "%JSON%" goto nocli
if not exist "%IMG%" goto nocli

tasklist /fi "imagename eq ds.exe" 2>nul | find /i "ds.exe" >nul
if not errorlevel 1 goto running

if exist "%FOUND%" del /f "%FOUND%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\gaseste_joc.ps1" -Out "%FOUND%" -Start "%~dp0."
if exist "%FOUND%" goto readpath
echo Nu am gasit jocul automat.
echo Scrie calea folderului jocului, de exemplu:
echo D:\SteamLibrary\steamapps\common\DEATH STRANDING DIRECTORS CUT
echo.
set /p "GAME=Cale: "
goto checkpath
:readpath
set /p GAME=<"%FOUND%"
del /f "%FOUND%"
:checkpath
set "BIN=%GAME%\data\%BN%"
set "BAK=%BIN%.bak"
set "LOG=%GAME%\DS_RO_instalare.log"
if not exist "%BIN%" goto nogame
echo Jocul a fost gasit in:
echo %GAME%
echo.

if exist "%BAK%" goto restore

for %%A in ("%BIN%") do set "CUR=%%~zA"
if "%CUR%"=="%SIZE%" goto sizeok
echo ATENTIE: arhiva jocului are alta dimensiune decat versiunea pentru care
echo a fost facuta traducerea (1.004). Poate fi o actualizare noua a jocului.
echo Daca jocul a fost actualizat, unele texte pot ramane in engleza.
echo.
choice /c DN /m "Continui oricum (D = da, N = nu)"
if errorlevel 2 goto cancel
:sizeok
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\spatiu.ps1" -Path "%GAME%" -NeedGB 13
if errorlevel 1 goto nospace
echo.
echo [1/3] Fac backup la arhiva originala (5,5 GB). Poate dura cateva minute...
copy /y "%BIN%" "%BAK%.tmp" >nul
if errorlevel 1 goto failbak
move /y "%BAK%.tmp" "%BAK%" >nul
if errorlevel 1 goto failbak
goto import

:restore
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\spatiu.ps1" -Path "%GAME%" -NeedGB 6
if errorlevel 1 goto nospace
echo.
echo [1/3] Exista deja un backup. Refac originalul inainte de reinstalare...
copy /y "%BAK%" "%BIN%" >nul
if errorlevel 1 goto failbak

:import
if exist "%TMPD%" rmdir /s /q "%TMPD%"
echo Instalare traducere > "%LOG%"
echo.
echo [2/3] Pregatesc textele si imaginile in romana. Poate dura cateva minute...
"%CLI%" localization import "--project=%GAME%" "--input=%JSON%" "--output=%TMPD%" >> "%LOG%" 2>&1
if errorlevel 1 goto fail
if not exist "%TMPD%" goto fail
"%JAVA%" --add-modules decima.ui --add-exports decima.ui/com.shade.decima.cli.converters=ALL-UNNAMED --add-opens decima.ui/com.shade.decima.ui=ALL-UNNAMED --enable-native-access=decima.model -cp "%~dp0tools\dspatch.jar" DsPatch "%GAME%" "%IMG%" "%TMPD%" >> "%LOG%" 2>&1
if errorlevel 1 goto fail
echo.
echo [3/3] Pun traducerea in joc. Poate dura cateva minute...
"%CLI%" repack --level=NONE "--project=%GAME%" "%BIN%" "%TMPD%" >> "%LOG%" 2>&1
if errorlevel 1 goto fail
if exist "%TMPD%" rmdir /s /q "%TMPD%"
echo.
echo ============================================================
echo  GATA! Traducerea a fost instalata.
echo.
echo  In joc, la Optiuni - Setari de limba, lasa limba textului
echo  pe English. Romana inlocuieste textul englezesc.
echo  Vocile pot ramane pe orice limba vrei.
echo ============================================================
goto end

:nocli
echo Lipsesc fisiere din pachet. Dezarhiveaza toata arhiva, apoi ruleaza din nou.
goto end
:running
echo Jocul este pornit. Inchide-l si ruleaza din nou.
goto end
:nogame
echo Nu gasesc arhiva jocului in: %GAME%
echo Traducerea functioneaza doar cu versiunea de Steam.
goto end
:nospace
echo Nu ai destul spatiu liber pe discul jocului.
goto end
:cancel
echo Instalare anulata.
goto end
:failbak
echo Backup-ul sau restaurarea a esuat. Verifica spatiul liber sau
echo ruleaza Instaleaza.bat cu click dreapta - Run as administrator.
goto end
:fail
echo.
echo A aparut o eroare. Jocul poate fi readus la original cu Dezinstaleaza.bat.
echo Detalii in: %LOG%
:end
echo.
pause
