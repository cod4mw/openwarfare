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
	// Wait until the match starts
	level waittill("prematch_over");
	
	// If the variable has not been initialized then we are probably not running a ruleset or the ruleset hasn't set any variable to monitor
	if ( !isDefined( level.dvarMonitor ) )
		return;

	level thread dvarMonitor();
}


dvarMonitor()
{
	level endon( "game_ended" );
	
	for (;;)
	{
		wait (1);
		
		// Check if any variable has been changed since the last loop
		for ( iDvar = 0; iDvar < level.dvarMonitor.size; iDvar++ ) {
			// Check if the value has changed
			currentValue = getDvar( level.dvarMonitor[iDvar]["name"] );
			if ( currentValue != level.dvarMonitor[iDvar]["value"] ) {
				// Variable has changed so let the players know
				iprintlnbold( &"OW_DVAR_MONITOR_NAME", level.dvarMonitor[iDvar]["name"] );
				iprintlnbold( &"OW_DVAR_MONITOR_OLD_NEW", level.dvarMonitor[iDvar]["value"], currentValue );
				level thread playSoundOnEveryone( "mp_last_stand" );
				
				level.dvarMonitor[iDvar]["value"] = currentValue;
				wait (1);
			}			
		}		
	}	
}


playSoundOnEveryone( soundName )
{
	level endon( "game_ended" );
	
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		player playLocalSound( soundName );
	}	
}