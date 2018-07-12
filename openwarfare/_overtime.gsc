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
	level.scr_overtime_enable = getdvarx( "scr_overtime_enable", "int", 0, 0, 1 );
	
	// If overtime is disabled then there's nothing else to do here
	if ( level.scr_overtime_enable == 0 )
		return;

	// Load the rest of the module's variables
	level.scr_overtime_playerrespawndelay = getdvarx( "scr_overtime_playerrespawndelay", "float", -1, 0, 600 );
	level.scr_overtime_incrementalspawndelay = getdvarx( "scr_overtime_incrementalspawndelay", "float", 0, 0, 10 );
	level.scr_overtime_suddendeath = getdvarx( "scr_overtime_suddendeath", "int", 1, 0, 1 );
	
	// Check if we need to monitor the game score
	if ( isDefined( game["_overtime"] ) && level.scr_overtime_suddendeath == 1 ) {
		level thread monitorTeamScores();
	}
}


registerTimeLimitDvar()
{
	level.timelimit = getdvarx( "scr_overtime_timelimit", "int", 0, 0, 1440 );
	setDvar( "ui_timelimit", level.timelimit );
	level notify ( "update_timelimit" );
}


registerNumLivesDvar()
{
	level.numLives = getdvarx( "scr_overtime_numlives", "int", 0, 0, 10 );	
}


monitorTeamScores()
{
	level endon("game_ended");
	
	for (;;)
	{
		wait (0.05);
		// If the scores are different it means someone has scored
		if ( game["teamScores"]["allies"] != game["teamScores"]["axis"] ) {
			level thread suddenDeathScore();
		}		
	}
}


checkGameState()
{
	// We only support overtime for team based games
	if ( !level.teamBased || level.gametype == "bel" )
		return;
		
	// Check if the teams are tied
	if ( game["teamScores"]["allies"] != game["teamScores"]["axis"] )
		return;	
	
	// Check if we have rounds but this was not the last one
	if ( level.roundLimit && !maps\mp\gametypes\_globallogic::hitRoundLimit() )
		return;
		
	// Make sure we have players on both teams
	players[ "allies" ] = 0;
	players[ "axis" ] = 0;
	players[ "spectator" ] = 0;

	for ( index = 0; index < level.players.size; index++ ) {
		players[ level.players[index].pers["team"] ]++;
		if ( players[ "allies" ] > 0 && players[ "axis" ] > 0 )
			break;
	}
	if ( players[ "allies" ] == 0 || players[ "axis" ] == 0 )
		return;
	
	// Add one more round
	game["_overtime"] = true;	
	level.roundLimit++;
	level notify ( "update_roundlimit" );
}


respawnDelay()
{
	// Check if this is the first time the player spawns
	if ( !isDefined( self.overtimeDeaths ) )
		self.overtimeDeaths = 0;
	else
		self.overtimeDeaths++;
		
	// Calculate the respawn time for this player
	respawnDelay = level.scr_overtime_playerrespawndelay;
	
	// Add the increased due to number of deaths
	respawnDelay += ( level.scr_overtime_incrementalspawndelay * self.overtimeDeaths );
	
	return respawnDelay;	
}


suddenDeathScore()
{
	winner = undefined;

	if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
		winner = "axis";
	else
		winner = "allies";

	logString( "overtime, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );

	makeDvarServerInfo( "ui_text_endreason", game["strings"]["round_limit_reached"] );
	setDvar( "ui_text_endreason", game["strings"]["round_limit_reached"] );

	thread maps\mp\gametypes\_globallogic::endGame( winner, game["strings"]["round_limit_reached"] );
}