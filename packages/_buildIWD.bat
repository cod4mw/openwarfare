@echo off

echo  * Building z_openwarfare.iwd file with %_MODWEAPONS%...

cd ..

xcopy "%_BUILDPATH%\..\%_MODWEAPONS%" "%_BUILDPATH%\..\weapons\mp" /SYI > NUL
if exist "%_BUILDPATH%\..\z_openwarfare.iwd" del "%_BUILDPATH%\..\z_openwarfare.iwd" >NUL
7za a -r -tzip z_openwarfare.iwd images\*.iwi > NUL
7za a -r -tzip z_openwarfare.iwd sound\*.mp3 > NUL
7za a -r -tzip z_openwarfare.iwd weapons\mp\*_mp > NUL
7za a -r -tzip z_openwarfare.iwd rulesets\leagues.gsc > NUL
7za a -r -tzip z_openwarfare.iwd rulesets\openwarfare\*.gsc > NUL
del /f /q "%_BUILDPATH%\..\weapons\mp\*" >NUL
rmdir "%_BUILDPATH%\..\weapons\mp" >NUL

cd "%_BUILDPATH%"