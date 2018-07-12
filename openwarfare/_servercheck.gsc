//******************************************************************************
//  _____                  _    _             __
// |  _  |                | |  | |           / _|
// | | | |_ __   ___ _ __ | |  | | __ _ _ __| |_ __ _ _ __ ___
// | | | | '_ \ / _ \ '_ \| |/\| |/ _` | '__|  _/ _` | '__/ _ \
// \ \_/ / |_) |  __/ | | \  /\  / (_| | |  | || (_| | | |  __/
//  \___/| .__/ \___|_| |_|\/  \/ \__,_|_|  |_| \__,_|_|  \___|
//       | |               We don't make the game you play.
//       |_|                 We make the game you play BETTER.
//
//            Website: http://openwarfaremod.com/
//******************************************************************************

#include openwarfare\_utils;

init()
{
	// Give some time to the server to populate variables with the referenced IWDs
	wait( 5.0 );
	
	// Check all the .IWDs active in the server
	checkResult = runCheck();

	// If the check was invalid then we'll let the players know about the problem and
	// exit the current map
	if ( checkResult != "passed" ) {
		logPrint( "OW;" + checkResult + "\n" );
		for ( times = 0; times < 30; times++ ) {
			iprintln( checkResult + " (^1" + (30-times) + "^7)." );
			wait( 2.0 );
		}
		exitLevel( false );
	}	
}


runCheck()
{	
	// Check if there's any .IWD file that doesn't belong to the mod
	iwdFiles = strtok( tolower( getdvar( "sv_referencedIwdNames" ) ), " " );
	modPath = tolower( getdvar("fs_game") ) + "/";
	
	for ( index = 0; index < iwdFiles.size; index++ ) {
		if ( isSubStr( iwdFiles[index], modPath ) ) {
			// Check if the .IWD file doesn't belong to the mod
			if ( iwdFiles[index] != modPath + "z_openwarfare" ) {
				return "Invalid file ^3" + iwdFiles[index] + ".iwd^7 has been found in the mod directory.";
			}
		}
	}
	
	return "passed";	
}