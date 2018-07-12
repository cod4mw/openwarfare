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

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

#include openwarfare\_eventmanager;
#include openwarfare\_utils;

init()
{
	// Get the main module's dvar
	level.scr_timeouts_perteam = getdvarx( "scr_timeouts_perteam", "int", 0, 0, 5 );

	// If team timeouts are disabled or is not a match game or is not team based then there's nothing else to do here
	if ( level.scr_timeouts_perteam == 0 || !level.teamBased ) {
		return;
	}

	// Get the rest of the module's dvars
	level.scr_timeouts_length = getdvarx( "scr_timeouts_length", "int", 30, 15, 300 );
	level.scr_timeouts_tags = getdvarx( "scr_timeouts_tags", "string", "" );
	level.scr_timeouts_guids = getdvarx( "scr_timeouts_guids", "string", "" );

	// Transform the protected tags into an array (format for the variable should be "[FLOT] [TGW] {1stAD}"
	level.scr_timeouts_tags = strtok( level.scr_timeouts_tags, " " );

	// Precache some resources we'll be using
	precacheString( &"OW_TIMEOUT_CALLED" );
	precacheString( &"OW_TIMEOUTS_NOMORE" );
	precacheString( &"OW_TIMEOUTS_LEFT" );
	precacheShader( "hudStopwatch" );

	// Check if we already stored the number of timeouts remaining for each team in this game
	if ( !isDefined( game["timeouts"] ) ) {
		game["timeouts"]["allies"] = level.scr_timeouts_perteam;
		game["timeouts"]["axis"] = level.scr_timeouts_perteam;
	}

	if ( !isDefined( level.bombPlanted ) )
		level.bombPlanted = false;

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}


onPlayerSpawned()
{
	// By default a player is not in timeout mode
	self.inTimeout = false;
	self thread monitorTimeout();
}


monitorTimeout()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	// We'll check if a timeout is called and freeze the player
	for (;;)
	{
		wait (0.05);
		// Check if we are in timeout mode
		if ( level.inTimeoutPeriod ) {
			// We are in timeout mode, let's check that the player has been frozen
			if ( !self.inTimeout ) {
				self playLocalSound( "mp_last_stand" );
				self setClientDvars( "ui_hud_hardcore", 1,
									 "ui_hud_hardcore_show_minimap", 0,
									 "ui_hud_hardcore_show_compass", 0,
									 "ui_hud_show_inventory", 0,
									 "cg_drawCrosshair", 0 );
				self freezeControls( true );
				self.inTimeout = true;
			}
		} else {
			// We are not in timeout mode, let's check that the player has been unfrozen
			if ( self.inTimeout ) {
				self playLocalSound( "mp_last_stand" );
				self setClientDvars( "ui_hud_hardcore", level.hardcoreMode,
							   		 "ui_hud_hardcore_show_minimap", level.scr_hud_hardcore_show_minimap,
							   		 "ui_hud_hardcore_show_compass", level.scr_hud_hardcore_show_compass,
							   		 "ui_hud_show_inventory", level.scr_hud_show_inventory,
							   		 "cg_drawCrosshair", !level.hardcoreMode );
				self freezeControls( false );
				self.inTimeout = false;
			}
		}
	}


}


timeoutCalled()
{
	// Make sure timeouts are allowed
	if ( level.scr_timeouts_perteam == 0 || !level.teamBased )
		return;

	// Make sure we are not in any state where we don't allowe timeouts to be called
	if ( level.inReadyUpPeriod || level.inStrategyPeriod || level.inPrematchPeriod || level.inHidingPeriod || level.inTimeoutPeriod || game["state"] == "postgame" )
		return;

	// Check also states where players are capturing objectives or in situations where timeouts can be called
	if ( level.bombPlanted )
		return;

	// Check if only certain people can call timeouts
	if ( level.scr_timeouts_guids != "" ) {
		if ( !issubstr( level.scr_timeouts_guids, self getGuid() ) ) {
			return;
		}
	} else if ( level.scr_timeouts_tags.size > 0 ) {
		playerAllowed = false;
		for ( tagx = 0; tagx < level.scr_timeouts_tags.size; tagx++ ) {
			if ( issubstr( self.name, level.scr_timeouts_tags[tagx] ) ) {
				playerAllowed = true;
				break;
			}
		}
		if ( !playerAllowed ) {
			return;
		}
	}

	// Check if this player's team has timeouts left
	playerTeam = self.pers["team"];
	if ( game["timeouts"][playerTeam] == 0 ) {
		// Inform all the players in the player's team that there are no more timeouts left
		for ( i = 0; i < level.players.size; i++ )
		{
			if ( level.players[i].pers["team"] == playerTeam ) {
				level.players[i] iprintln( &"OW_TIMEOUTS_NOMORE", self.name );
			}
		}
		return;
	} else {
		game["timeouts"][playerTeam] -= 1;

		// Show the information about who called the timeout and how many timeouts are left to the team calling the timeout
		for ( i = 0; i < level.players.size; i++ )
		{
			if ( level.players[i].pers["team"] == playerTeam ) {
				level.players[i] iprintln( &"OW_TIMEOUTS_LEFT", self.name, game["timeouts"][playerTeam] );
			}
		}
	}


	// We are officially in timeout mode
	level.timeoutTeam = playerTeam;
	maps\mp\gametypes\_globallogic::pauseTimer();
	visionSetNaked( "mpOutro", 0 );
	level.inTimeoutPeriod = true;

	// Create the HUD elements and wait for the timeout to be over to destroy them
	thread createHUDelements( game[playerTeam] );

	// Wait the timeout (timeouts are not supposed to be bypassed but respected)
	wait (level.scr_timeouts_length);

	// Timeout is officially over
	visionSetNaked( getDvar( "mapname" ), 0 );
	level.inTimeoutPeriod = false;
	maps\mp\gametypes\_globallogic::resumeTimer();

	return;
}


createHUDelements( playerTeam )
{
	// "Timeout called!" legend
	timeoutCalled = createServerFontString( "objective", 2.4 );
	timeoutCalled.archived = false;
	timeoutCalled.hideWhenInMenu = true;
	timeoutCalled.alignX = "center";
	timeoutCalled.alignY = "top";
	timeoutCalled.horzAlign = "center";
	timeoutCalled.vertAlign = "top";
	timeoutCalled.sort = -1;
	timeoutCalled.x = 0;
	timeoutCalled.y = 60;
	timeoutCalled.color = ( 0.694, 0.220, 0.114 );
	timeoutCalled setText( &"OW_TIMEOUT_CALLED" );

	// Team name
	timeoutTeamName = createServerFontString( "default", 2.2 );
	timeoutTeamName.archived = false;
	timeoutTeamName.hideWhenInMenu = true;
	timeoutTeamName.alignX = "center";
	timeoutTeamName.alignY = "top";
	timeoutTeamName.horzAlign = "center";
	timeoutTeamName.vertAlign = "top";
	timeoutTeamName.sort = -1;
	timeoutTeamName.color = ( 1, 0.5, 0 );
	timeoutTeamName.x = 0;
	timeoutTeamName.y = 86;
	switch ( playerTeam )
	{
		case "sas":
		case "marines":
			timeoutTeamName setText( level.scr_team_allies_name );
			break;
		case "russian":
		case "opfor":
		case "arab":
			timeoutTeamName setText( level.scr_team_axis_name );
			break;
	}


	// Check if the timeout is longer than 60 seconds
	if ( level.scr_timeouts_length > 60 ) {
		stopWatch = createServerTimer( "objective", 4 );
		stopWatch.archived = false;
		stopWatch setTenthsTimer( level.scr_timeouts_length );
		stopWatch.alignX = "center";
		stopWatch.alignY = "bottom";
		stopWatch.horzAlign = "center";
		stopWatch.vertAlign = "middle";
		stopWatch.x = 0;
		stopWatch.y = -50;
		stopWatch.color = ( 1, 1, 0 );
		stopWatch.sort = 0;
		stopWatch.foreground = false;
		stopWatch.hideWhenInMenu = true;		
	} else {
		// Create the nice stop watch!
		stopWatch = NewHudElem();
		stopWatch.archived = false;
		stopWatch.hideWhenInMenu = true;
		stopWatch.alignX = "center";
		stopWatch.alignY = "bottom";
		stopWatch.horzAlign = "center";
		stopWatch.vertAlign = "middle";
		stopWatch.sort = 0;
		stopWatch.alpha = 1.0;
		stopWatch.x = 0;
		stopWatch.y = -30;
		stopWatch SetClock( level.scr_timeouts_length, 60, "hudStopwatch", 96, 96 );
	}

	oldTime = gettime();
	// Wait until the timeout is over
	while ( level.inTimeoutPeriod ) {
		wait (0.05);
		if ( gettime() - oldTime >= 500 ) {
			oldTime = gettime();
			timeoutCalled.alpha = !timeoutCalled.alpha;
		}
	}

	// Destroy the HUD elements
	stopWatch destroy();
	timeoutCalled destroy();
	timeoutTeamName destroy();

	return;
}
