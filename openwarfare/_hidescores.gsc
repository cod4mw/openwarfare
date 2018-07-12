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

#include openwarfare\_eventmanager;
#include openwarfare\_utils;


init()
{
	// Get the main module's dvar
	level.scr_hide_scores = getdvarx( "scr_hide_scores", "int", 0, 0, 1 );

	if ( !level.overrideTeamScore ) {
		setDvar( "ui_hide_scores", level.scr_hide_scores );
	} else {
		setDvar( "ui_hide_scores", 0 );
	}
	makeDvarServerInfo( "ui_hide_scores" );

	// If hide scores is disabled then there's nothing else to do here
	if ( level.scr_hide_scores == 0 )
		return;

	level thread cleanScoreBoard();
	level thread onGameEnded();
}


cleanScoreBoard()
{
	level endon( "game_ended" );

	for (;;)
	{
		wait (0.1);

		// Loop the players and remove the player's stats
		for ( index = 0; index < level.players.size; index++ )
		{
			player = level.players[index];

			// Remove the player stats
			needScoreboardRefresh = player.score + player.kills + player.deaths + player.assists;
			player.score = 0;
			player.kills = 0;
			player.deaths = 0;
			player.assists = 0;

			// Check if we need to refresh the scoreboard because we removed something
			if ( needScoreboardRefresh )
				player notify ( "update_playerscore_hud" );
		}
	}
}


onGameEnded()
{
	level waittill( "game_ended" );

	// Game has ended so we need to restore the scoreboard numbers
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];

		// Move the player's stats to the scoreboard again
		setDvar( "ui_hide_scores", 0 );
		player.score = player.pers["score"];
		player.kills = player.pers["kills"];
		player.deaths = player.pers["deaths"];
		player.assists = player.pers["assists"];
		player notify ( "update_playerscore_hud" );
	}

	return;
}