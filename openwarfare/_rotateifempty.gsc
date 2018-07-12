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
	// Get the main module's dvar
	level.scr_rotateifempty_enable = getdvarx( "scr_rotateifempty_enable", "int", 0, 0, 1 );

	// If rotation of the map when empty is not enabled then there's nothing else to do here
	if ( level.scr_rotateifempty_enable == 0 )
		return;

	// Get the module's dvars
	level.scr_rotateifempty_time = getdvarx( "scr_rotateifempty_time", "int", 600, 60, 3600 );
	level.scr_rotateifempty_grace_period = getdvarx( "scr_rotateifempty_grace_period", "int", 15, 0, 60 );
	
	level thread monitorMap();
	
}


monitorMap()
{
	level endon("game_ended");
	
	// We use a game[] variable because round based games reset level. variables
	if ( !isDefined( game["rotateifempty"] ) )
		game["rotateifempty"] = 0;
	
	for (;;) {
		wait(1);
		
		// Check if we have enough players for the type of game
		if ( !enoughPlayers() ) {
			game["rotateifempty"]++;
			
			// Check if we need to consider the rotation of the map
			if ( game["rotateifempty"] >= level.scr_rotateifempty_time && !level.intermission ) {
				
				// Check if we need to display a message if we still have players in the server
				if ( level.scr_rotateifempty_grace_period > 0 ) {
					players = getentarray( "player", "classname" );
					if ( players.size > 0 ) {
						iprintlnbold( &"OW_EMPTY_ROTATE", level.scr_rotateifempty_grace_period );
						wait( level.scr_rotateifempty_grace_period );
						
						// We check one more time that rotate if there are no players
						if ( !enoughPlayers() ) {
							game["rotateifempty"] = 0;
							game["amvs_skip_voting"] = true;
							exitLevel( false );								
						}						
					}
				}				
			}			
		} else {
			// If there are enough players then reset the internal counter
			game["rotateifempty"] = 0;
		}		
	}	
}


enoughPlayers()
{

	players[ "allies" ] = 0;
	players[ "axis" ] = 0;
	players[ "spectator" ] = 0;
	enoughPlayers = false;

	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];

		// Get the players team
		playerTeam = player.pers[ "team" ];
		players[ playerTeam ]++;

		// Check if we have players on both teams
		if ( level.teamBased ) {
			if ( players[ "allies" ] > 0 && players[ "axis" ] > 0 ) {
				enoughPlayers = true;
				break;
			}
		} else {
			// Or if we have more than 1 players for non-team based games
			if ( ( players[ "allies" ] + players[ "axis" ] ) >= 2 ) {
				enoughPlayers = true;
				break;
			}
		}
	}
	
	return (enoughPlayers);
}