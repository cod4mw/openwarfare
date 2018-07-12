@echo off

echo.
echo  * Building mod.ff file for language %_MODLANGX%...

if not exist "%_BUILDPATH%\..\..\..\zone\%_MODLTARGET%" mkdir "%_BUILDPATH%\..\..\..\zone\%_MODLTARGET%"
if not exist "%_BUILDPATH%\..\..\..\zone_source\%_MODLTARGET%" xcopy "%_BUILDPATH%\..\..\..\zone_source\english" "%_BUILDPATH%\..\..\..\zone_source\%_MODLTARGET%" /SYI > NUL

xcopy "%_BUILDPATH%\..\%_MODLANG%" "%_BUILDRAWPATH%\%_MODLTARGET%" /SYI > NUL
copy /Y "%_BUILDPATH%\..\mod.csv" "%_BUILDPATH%\..\..\..\zone_source" > NUL
copy /Y "%_BUILDPATH%\..\mod_ignore.csv" "%_BUILDPATH%\..\..\..\zone_source\%_MODLTARGET%\assetlist" > NUL

cd "%_BUILDPATH%\..\..\..\bin" > NUL

linker_pc.exe -language %_MODLTARGET% -compress -cleanup mod >NUL

cd "%_BUILDPATH%" > NUL
copy /Y "%_BUILDPATH%\..\..\..\zone\%_MODLTARGET%\mod.ff" "%_BUILDPATH%\OpenWarfare\%_MODHOME%" > NUL

echo  * Building mod.ff file with longer smoke for language %_MODLANGX%...

copy /Y "%_BUILDPATH%\..\mod.csv" "%_BUILDPATH%\..\..\..\zone_source" > NUL
"%_BUILDPATH%\..\ssr" 0 "#fx,props/american_smoke_grenade_mp" "fx,props/american_smoke_grenade_mp" "%_BUILDPATH%\..\..\..\zone_source\mod.csv"

cd "%_BUILDPATH%\..\..\..\bin" > NUL

linker_pc.exe -language %_MODLTARGET% -compress -cleanup mod >NUL

cd "%_BUILDPATH%" > NUL
copy /Y "%_BUILDPATH%\..\..\..\zone\%_MODLTARGET%\mod.ff" "%_BUILDPATH%\OpenWarfare\Extras\LongerSmoke" > NUL