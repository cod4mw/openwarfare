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
#include openwarfare\_utils;

start()
{
	// Get the main module's dvars
	level.scr_match_strategy_time = getdvarx( "scr_match_strategy_time", "float", 0, 0, 60 );

	// There's no need to have strategy time when the game is not team based unless players are crazy and like to talk to themselves... ;)
	if ( !level.teamBased || level.scr_match_strategy_time == 0 ) {
		level.inStrategyPeriod = false;
		return;
	}

	// Make sure there's at least 5 seconds
	if ( level.scr_match_strategy_time < 2.5 ) {
		level.scr_match_strategy_time = 2.5;
	}
	
	// Get the rest of the dvars
	level.scr_match_strategy_allow_bypass = getdvarx( "scr_match_strategy_allow_bypass", "int", 1, 0, 1 );
	level.scr_match_strategy_show_bypassed = getdvarx( "scr_match_strategy_show_bypassed", "int", 1, 0, 1 );
	level.scr_match_strategy_getready_time = getdvarx( "scr_match_strategy_getready_time", "float", 1.5, 0.5, 5 );
	level.scr_match_strategy_allow_movement = getdvarx( "scr_match_strategy_allow_movement", "int", 0, 0, 1 );

	// We are in strategy mode
	level.inStrategyPeriod = true;
	visionSetNaked( "mpIntro", 0 );

	precacheString( &"OW_STRATEGY_PERIOD_STARTED" );
	precacheString( &"OW_STRATEGY_PERIOD_FINISHED" );
	precacheString( &"OW_STRATEGY_GET_READY" );
	precacheString( &"OW_STRATEGY_BYPASSED" );
	precacheString( &"OW_PRESS_TO_BYPASS" );

	precacheStatusIcon( "hud_status_ready" );

	level thread onPlayerConnect();

	level.strategyPeriodEnds = gettime() + level.scr_match_strategy_time * 1000;

	// Show HUD elements
	level.strategyPeriodText = createServerFontString( "objective", 1.5 );
	level.strategyPeriodText setPoint( "CENTER", "CENTER", 0, -20 );
	level.strategyPeriodText.sort = 1001;
	level.strategyPeriodText setText( &"OW_STRATEGY_PERIOD_STARTED" );
	level.strategyPeriodText.foreground = false;
	level.strategyPeriodText.hidewheninmenu = true;

	level.strategyPeriodTimer = createServerTimer( "objective", 1.5 );
	level.strategyPeriodTimer setTimer( ( level.strategyPeriodEnds - gettime() ) / 1000 );
	level.strategyPeriodTimer setPoint( "CENTER", "CENTER", 0, 0 );
	level.strategyPeriodTimer.color = ( 1, 0.5, 0 );
	level.strategyPeriodTimer.sort = 1001;
	level.strategyPeriodTimer.foreground = false;
	level.strategyPeriodTimer.hideWhenInMenu = true;

	// Loop until the strategy period is over
	while ( level.inStrategyPeriod )
	{
		wait (0.05);

		// Check that we are still within the time frame
		if ( gettime() >= level.strategyPeriodEnds ) {
			level.inStrategyPeriod = false;
		} else {
			// Check if players all the players have bypassed
			if ( level.scr_match_strategy_allow_bypass == 1 ) {
				playersWaiting = 0;
				playersReady = 0;
				for ( index = 0; index < level.players.size; index++ )
				{
					player = level.players[index];
					// Spectator don't count
					if ( player.pers["team"] != "spectator" ) {
						if ( !isDefined( player.bypassedStratPeriod ) || !player.bypassedStratPeriod ) {
							playersWaiting++;
						} else {
							playersReady++;
						}
					}
				}
				// If there are no players waiting then strategy time is over
				if ( playersWaiting == 0 && playersReady > 0 ) {
					level.inStrategyPeriod = false;
				}
			}
		}
	}

	// Show a message letting players know the round is about to start
	level.strategyPeriodText setText( &"OW_STRATEGY_PERIOD_FINISHED" );
	level.strategyPeriodTimer setTenthsTimer( level.scr_match_strategy_getready_time );

	// Clean the status icons
	if ( level.scr_match_strategy_show_bypassed == 1 ) {
		for ( index = 0; index < level.players.size; index++ )
		{
			level.players[index].statusicon = "";
		}
	}

	visionSetNaked( getDvar( "mapname" ), level.scr_match_strategy_getready_time );
	wait ( level.scr_match_strategy_getready_time );
	level.strategyPeriodText destroy();
	level.strategyPeriodTimer destroy();

	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		// Spectator don't count
		if ( player.pers["team"] != "spectator" ) {
			if ( level.scr_match_strategy_allow_movement == 1 ) {
				player thread maps\mp\gametypes\_gameobjects::_enableWeapon();
				player thread maps\mp\gametypes\_gameobjects::_enableJump();
				// Unfreeze the player
				player thread openwarfare\_speedcontrol::setModifierSpeed( "_strategyperiod", 0 );			
			} else {
				player freezeControls( false );
			}
		}
	}
	
	level notify("strategyperiod_ended");
}

onPlayerConnect()
{
	self endon("strategyperiod_ended");

	while ( level.inStrategyPeriod )
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	self endon("strategyperiod_ended");

	while ( level.inStrategyPeriod )
	{
		self waittill("spawned_player");
		self thread strategyPeriod();
	}
}

strategyPeriod()
{
	self endon("disconnect");

	if ( !level.inStrategyPeriod )
		return;

	// Check if we should allow player movement
	if ( level.scr_match_strategy_allow_movement == 1 ) {
		self freezeControls( false );
		self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
		self thread maps\mp\gametypes\_gameobjects::_disableJump();
		// Freeze player on the spot
		self thread openwarfare\_speedcontrol::setModifierSpeed( "_strategyperiod", 100 );		
	}
	
	self.bypassedStratPeriod =  false;
	
	self.bypassedPeriodText = createFontString( "objective", 1.5 );
	self.bypassedPeriodText setPoint( "CENTER", "CENTER", 0, 18 );
	self.bypassedPeriodText.sort = 1001;
	self.bypassedPeriodText.color = ( .42, 1, 0.42 );
	self.bypassedPeriodText.foreground = false;
	self.bypassedPeriodText.hidewheninmenu = true;	

	// Make sure players are allowed to bypass
	if ( level.scr_match_strategy_allow_bypass == 1 ) {
		self setLowerMessage( &"OW_PRESS_TO_BYPASS" );

		// Wait for players to bypass or for the strategy time to be over
		while ( level.inStrategyPeriod && !self.bypassedStratPeriod )
		{
			wait (0.05);
			if ( self useButtonPressed() ) {
				self.bypassedStratPeriod = true;
				if ( level.scr_match_strategy_show_bypassed == 1 ) {
					self.statusicon = "hud_status_ready";
				}
			}
		}

		// If the player bypassed show a new HUD element
		if ( self.bypassedStratPeriod && level.inStrategyPeriod ) {
			self.bypassedPeriodText setText( &"OW_STRATEGY_BYPASSED" );
		}

		self clearLowerMessage();
	}

	// Wait until strategy period is over
	while ( level.inStrategyPeriod )
		wait (0.05);

	self.bypassedPeriodText setText( &"OW_STRATEGY_GET_READY" );

	wait ( level.scr_match_strategy_getready_time );

	// Remove the HUD elements
	if ( isDefined( self.bypassedPeriodText ) )
		self.bypassedPeriodText destroy();

	// Enable player movement
	self notify("strategyperiod_ended");
}