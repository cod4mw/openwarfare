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
	level.scr_enable_scorebot = getdvarx( "scr_enable_scorebot", "int", 0, 0, 1 );

	if ( level.scr_enable_scorebot == 0 )
		return;

	level thread runScoreBot();
}

runScoreBot()
{
	// Make all the variables public
	setDvar( "__Game_Allies_Scores", "N/A", true );
	setDvar( "__Game_Axis_Scores", "N/A", true );
	setDvar( "__Game_Mod", "N/A", true );
	setDvar( "__Game_Mod_Version", "N/A", true );
	setDvar( "__Game_Round", "N/A", true );
	setDvar( "__Game_Scores", "N/A", true );
	setDvar( "__Game_Status", "N/A", true );
	setDvar( "__Match_League", "N/A", true );
	setDvar( "__Match_League_Long", "N/A", true );

	// Get the delimiter to use
	scoreBotDelimiter = getdvarx( "scr_scorebot_delimiter", "string", ",", undefined, undefined );

	// Set the variables that will not change unless the map is restarted
	setDvar( "__Match_League", getdvard( "scr_match_league", "string", "", undefined, undefined ) );
	setDvar( "__Match_League_Long", getdvard( "scr_league_ruleset", "string", "", undefined, undefined ) );
	setDvar( "__Game_Mod", getdvard( "_Mod", "string", "", undefined, undefined ) );
	setDvar( "__Game_Mod_Version", getdvard( "_ModVer", "string", "", undefined, undefined ) );

	// Clean any variables from a previous game
	if ( level.teamBased ) {
		setDvar( "__Game_Scores", "" );
	} else {
		setDvar( "__Game_Allies_Scores", "" );
		setDvar( "__Game_Axis_Scores", "" );
	}

	// Initialize some variables to control the updates as every update produces an entry in the server log
	__game_allies_scores_current = "";
	__game_axis_scores_current = "";
	__game_scores_current = "";
	__game_status_current = "";
	__game_round_current = "";

	// We'll loop as long as the game hasn't ended
	while ( game["state"] != "postgame" ) {
		// Updating all the dvars every 30 seconds
		wait 30;

		// Game status
		if ( level.inReadyUpPeriod ) {
			__game_status = "ReadyupPeriod";
		} else if ( level.inStrategyPeriod ) {
			__game_status = "StrategyPeriod";
		} else if ( level.inPrematchPeriod ) {
			__game_status = "PrematchPeriod";
		} else if ( level.inTimeoutPeriod ) {
			__game_status = "TimeoutPeriod";
		} else {
			__game_status = "Playing";
		}
		// Check if we need to update the game status
		if ( __game_status != __game_status_current ) {
			__game_status_current = __game_status;
			setDvar( "__Game_Status", __game_status );
		}

		// Game round
		currentRound = game["roundsplayed"] + 1;
		__game_round = currentRound + scoreBotDelimiter + level.roundLimit + scoreBotDelimiter + level.scoreLimit + scoreBotDelimiter + level.timeLimit;
		if ( __game_round != __game_round_current ) {
			__game_round_current = __game_round;
			setDvar( "__Game_Round", __game_round );
		}

		// Game scores
		if ( level.teamBased ) {
			__game_allies_scores = "" + game["teamScores"]["allies"];
			__game_axis_scores = "" + game["teamScores"]["axis"];

			// Add the players' scores in the format <player><delimiter><score><delimiter><player><delimiter><score>
			for ( i = 0; i < level.players.size; i++ )
			{
				player = level.players[i];
				switch ( player.pers["team"] )
				{
					case "allies":
						__game_allies_scores += scoreBotDelimiter + player.name + scoreBotDelimiter + player.pers["score"];
						break;
					case "axis":
						__game_axis_scores += scoreBotDelimiter + player.name + scoreBotDelimiter + player.pers["score"];
						break;
				}

			}
			// Check if we need to update the allies score
			if ( __game_allies_scores != __game_allies_scores_current ) {
				__game_allies_scores_current = __game_allies_scores;
				setDvar( "__Game_Allies_Scores", __game_allies_scores );
			}
			// Check if we need to update the axis score
			if ( __game_axis_scores != __game_axis_scores_current ) {
				__game_axis_scores_current = __game_axis_scores;
				setDvar( "__Game_Axis_Scores", __game_axis_scores );
			}

		} else {
			__game_scores = "";

			// Store the players' scores in the format <player><delimiter><score><delimiter><player><delimiter><score>
			for ( i = 0; i < level.players.size; i++ )
			{
				player = level.players[i];
				if ( player.pers["team"] != "spectator" ) {
					if ( __game_scores != "" )
						__game_scores += scoreBotDelimiter;

					__game_scores += player.name + scoreBotDelimiter + player.pers["score"];
				}
			}
			// Check if we need to update the scores
			if ( __game_scores != __game_scores_current ) {
				__game_scores_current = __game_scores;
				setDvar( "__Game_Scores", __game_scores );
			}
		}


	}

	// Game has finished so changed the game status
	setDvar( "__Game_Status", "Ended" );

	return;
}
