@echo off

echo  * Copying full mod source code...

xcopy "%_BUILDPATH%\..\configs" "%_BUILDRAWPATH%\configs" /SYI > NUL
xcopy "%_BUILDPATH%\..\images" "%_BUILDRAWPATH%\images" /SYI > NUL
xcopy "%_BUILDPATH%\..\fx" "%_BUILDRAWPATH%\fx" /SYI > NUL
xcopy "%_BUILDPATH%\..\maps" "%_BUILDRAWPATH%\maps" /SYI > NUL
xcopy "%_BUILDPATH%\..\materials" "%_BUILDRAWPATH%\materials" /SYI > NUL
xcopy "%_BUILDPATH%\..\mp" "%_BUILDRAWPATH%\mp" /SYI > NUL
xcopy "%_BUILDPATH%\..\rulesets" "%_BUILDRAWPATH%\rulesets" /SYI > NUL
xcopy "%_BUILDPATH%\..\sound" "%_BUILDRAWPATH%\sound" /SYI > NUL
xcopy "%_BUILDPATH%\..\soundaliases" "%_BUILDRAWPATH%\soundaliases" /SYI > NUL
xcopy "%_BUILDPATH%\..\ui_mp" "%_BUILDRAWPATH%\ui_mp" /SYI > NUL
xcopy "%_BUILDPATH%\..\vision" "%_BUILDRAWPATH%\vision" /SYI > NUL
xcopy "%_BUILDPATH%\..\weapons\fixes" "%_BUILDRAWPATH%\weapons\mp" /SYI > NUL
xcopy "%_BUILDPATH%\..\xanim" "%_BUILDRAWPATH%\xanim" /SYI > NUL
xcopy "%_BUILDPATH%\..\xmodel" "%_BUILDRAWPATH%\xmodel" /SYI > NUL
xcopy "%_BUILDPATH%\..\xmodelparts" "%_BUILDRAWPATH%\xmodelparts" /SYI > NUL
xcopy "%_BUILDPATH%\..\xmodelsurfs" "%_BUILDRAWPATH%\xmodelsurfs" /SYI > NUL
xcopy "%_BUILDPATH%\..\openwarfare" "%_BUILDRAWPATH%\openwarfare" /SYI > NUL