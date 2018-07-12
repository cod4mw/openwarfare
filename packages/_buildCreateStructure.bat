@echo off

echo  * Creating distribution packages folder structure...

mkdir "%_BUILDPATH%\OpenWarfare-Distribution" > NUL
mkdir "%_BUILDPATH%\OpenWarfare" > NUL
mkdir "%_BUILDPATH%\OpenWarfare\%_MODHOME%" > NUL

mkdir "%_BUILDPATH%\OpenWarfare\%_MODHOME%\configs" > NUL
mkdir "%_BUILDPATH%\OpenWarfare\%_MODHOME%\configs\gameplay" > NUL
mkdir "%_BUILDPATH%\OpenWarfare\%_MODHOME%\configs\gametypes" > NUL
mkdir "%_BUILDPATH%\OpenWarfare\%_MODHOME%\configs\mover" > NUL
mkdir "%_BUILDPATH%\OpenWarfare\%_MODHOME%\configs\server" > NUL

mkdir "%_BUILDPATH%\OpenWarfare\Extras" > NUL
mkdir "%_BUILDPATH%\OpenWarfare\Extras\StockWeapons" > NUL
mkdir "%_BUILDPATH%\OpenWarfare\Extras\SnipersIncreasedDistance" > NUL
mkdir "%_BUILDPATH%\OpenWarfare\Extras\TheCompanyHub" > NUL
mkdir "%_BUILDPATH%\OpenWarfare\Extras\LongerSmoke" > NUL