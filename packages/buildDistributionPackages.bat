@echo off

cls
echo.
echo.  _____                  _    _             __
echo. ^|  _  ^|                ^| ^|  ^| ^|           / _^|
echo. ^| ^| ^| ^|_ __   ___ _ __ ^| ^|  ^| ^| __ _ _ __^| ^|_ __ _ _ __ ___
echo. ^| ^| ^| ^| '_ \ / _ \ '_ \^| ^|/\^| ^|/ _` ^| '__^|  _/ _` ^| '__/ _ \
echo. \ \_/ / ^|_) ^|  __/ ^| ^| \  /\  / (_^| ^| ^|  ^| ^|^| (_^| ^| ^| ^|  __/
echo.  \___/^| .__/ \___^|_^| ^|_^|\/  \/ \__,_^|_^|  ^|_^| \__,_^|_^|  \___^|
echo.       ^| ^|               We don't make the game you play.
echo.       ^|_^|                 We make the game you play BETTER.
echo.
echo.            Website: http://openwarfaremod.com/

:BUILDVERSION
echo _________________________________________________________________
echo.
echo  REMEMBER TO UPDATE THE VERSION NUMBER IN _GLOBALLOGIC.GSC AND
echo  INSIDE THE CHANGELOG.TXT (ONLY FINAL RELEASES) WITH THE 
echo  CORRESPONDING SVN REVISION LEVEL !!!
echo.
echo  Please enter the version number:
echo   - Format for final releases: 1.6.2.1972
echo   - Format for release candidates: 1.6.2.RC1-1972
echo   - Format for beta releases: 1.6.2.B1-1972
echo   - Format for alpha releases: 1.6.2.A-1972
echo.
echo    0. Exit
echo.
set /p _MODBUILD=: 
if "%_MODBUILD%"=="0" goto FINAL
echo.

set _BUILDPATH=%CD%
set _BUILDRAWPATH=%_BUILDPATH%\..\..\..\raw
set _MODVERSION=CoD4MW

if not exist "%_BUILDPATH%\OpenWarfare" mkdir "%_BUILDPATH%\OpenWarfare" >NUL
rd /s /q "%_BUILDPATH%\OpenWarfare" >NUL
if not exist "%_BUILDPATH%\OpenWarfare-Distribution" mkdir "%_BUILDPATH%\OpenWarfare-Distribution" >NUL
rd /s /q "%_BUILDPATH%\OpenWarfare-Distribution" >NUL

call _buildCopySourceCode

set _MODHOME=openwarfare
call _buildCreateStructure
call _buildCopyFiles

set _MODWEAPONS=weapons\fixes+nogunsway
call _buildIWD.bat
move /Y "%_BUILDPATH%\..\z_openwarfare.iwd" "%_BUILDPATH%\OpenWarfare\%_MODHOME%" > NUL

set _MODWEAPONS=weapons\fixes
call _buildIWD.bat
move /Y "%_BUILDPATH%\..\z_openwarfare.iwd" "%_BUILDPATH%\OpenWarfare\Extras\StockWeapons" > NUL

set _MODWEAPONS=weapons\fixes+nogunsway+sniper
call _buildIWD.bat
move /Y "%_BUILDPATH%\..\z_openwarfare.iwd" "%_BUILDPATH%\OpenWarfare\Extras\SnipersIncreasedDistance" > NUL

set _MODWEAPONS=weapons\thecompany
call _buildIWD.bat
move /Y "%_BUILDPATH%\..\z_openwarfare.iwd" "%_BUILDPATH%\OpenWarfare\Extras\TheCompanyHub" > NUL

xcopy "%_BUILDPATH%\docs" "%_BUILDPATH%\OpenWarfare\%_MODHOME%\docs" /SYI > NUL

set _MODLANG=english
set _MODLTARGET=english
set _MODLANGX=English
call _buildFF
call _buildPackage

set _MODLANG=french
set _MODLTARGET=french
set _MODLANGX=French
call _buildFF
call _buildPackage

set _MODLANG=german
set _MODLTARGET=german
set _MODLANGX=German
call _buildFF
call _buildPackage

set _MODLANG=italian
set _MODLTARGET=italian
set _MODLANGX=Italian
call _buildFF
call _buildPackage

set _MODLANG=portuguese
set _MODLTARGET=leet
set _MODLANGX=Portuguese
call _buildFF
call _buildPackage

set _MODLANG=russian
set _MODLTARGET=russian
set _MODLANGX=Russian
call _buildFF
call _buildPackage

set _MODLANG=spanish
set _MODLTARGET=spanish
set _MODLANGX=Spanish
call _buildFF
call _buildPackage

:END
echo.
echo  * Cleaning temporary files...
echo  * Distribution packages successfully built!
rd /s /q "%_BUILDPATH%\OpenWarfare" >NUL
echo.
pause
goto FINAL

:FINAL