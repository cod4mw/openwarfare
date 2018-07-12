@echo off

echo  * Building distribution package for language %_MODLANGX%...

"%_BUILDPATH%\..\7za" a -r -tzip "%_BUILDPATH%\OpenWarfare\OpenWarfare-%_MODVERSION%-%_MODBUILD%-%_MODLANGX%.zip" "%_BUILDPATH%\OpenWarfare\*" > NUL
move "%_BUILDPATH%\OpenWarfare\OpenWarfare-%_MODVERSION%-%_MODBUILD%-%_MODLANGX%.zip" "%_BUILDPATH%\OpenWarfare-Distribution" > NUL
