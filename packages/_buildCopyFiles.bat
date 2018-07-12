@echo off

echo  * Copying mod language-independent files...

copy /Y "%_BUILDPATH%\..\*.cfg" "%_BUILDPATH%\OpenWarfare\%_MODHOME%" > NUL

copy /Y "%_BUILDPATH%\..\configs\*.cfg" "%_BUILDPATH%\OpenWarfare\%_MODHOME%\configs" > NUL
copy /Y "%_BUILDPATH%\..\configs\gameplay\*.cfg" "%_BUILDPATH%\OpenWarfare\%_MODHOME%\configs\gameplay" > NUL
copy /Y "%_BUILDPATH%\..\configs\gametypes\*.cfg" "%_BUILDPATH%\OpenWarfare\%_MODHOME%\configs\gametypes" > NUL
copy /Y "%_BUILDPATH%\..\configs\mover\*.cfg" "%_BUILDPATH%\OpenWarfare\%_MODHOME%\configs\mover" > NUL
copy /Y "%_BUILDPATH%\..\configs\server\*.cfg" "%_BUILDPATH%\OpenWarfare\%_MODHOME%\configs\server" > NUL

copy /Y "%_BUILDPATH%\_extras_readme.txt" "%_BUILDPATH%\OpenWarfare\Extras\readme.txt" > NUL

echo.