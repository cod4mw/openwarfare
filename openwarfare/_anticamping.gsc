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

#include openwarfare\_eventmanager;
#include openwarfare\_utils;

init()
{
	// Get the main module's dvar
	level.scr_anti_camping_enable = getdvarx( "scr_anti_camping_enable", "int", 0, 0, 2 );

	// If anti-camping is not enabled then there's nothing else to do here
	if ( level.scr_anti_camping_enable == 0 )
		return;

	// Get the module's dvars
	level.scr_anti_camping_show = getdvarx( "scr_anti_camping_show", "int", 0, 0, 2 );
	level.scr_anti_camping_message = getdvarx( "scr_anti_camping_message", "string", "" );
	level.scr_anti_camping_time = getdvarx( "scr_anti_camping_time", "float", 60, 30, 300 );
	level.scr_anti_camping_distance = getdvarx( "scr_anti_camping_distance", "int", 100, 50, 500 );

	// Precache shader
	precacheShader( "camping" );

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onPlayerKilled", ::onPlayerKilled );
}


onPlayerSpawned()
{
	// We do not monitor camping during the ready up period
	if ( !level.inReadyUpPeriod ) {
		self thread monitorPlayerCamping();
	}
}


onPlayerKilled()
{
	if ( isDefined( self.hud_camping_icon ) )
		self.hud_camping_icon destroy();
}


monitorPlayerCamping()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	// Monitor that the player is moving certain amount of distance in a given time
	oldPlayerPosition = self.origin;
	self.isCamping = false;

	if ( isDefined( self.hud_camping_icon ) )
		self.hud_camping_icon destroy();

	for (;;)
	{
		distanceMoved = 0;

		// Check distance moved. If distance moved goes beyong the limit then we'll start calculating again
		campingTime = openwarfare\_timer::getTimePassed() + level.scr_anti_camping_time * 1000;

		while ( distanceMoved < level.scr_anti_camping_distance && campingTime > openwarfare\_timer::getTimePassed() ) {
			distanceMoved = distance( oldPlayerPosition, self.origin );
			wait (0.25);
			if ( ( isDefined( self.interacting_with_objective ) && self.interacting_with_objective ) || ( isDefined( self.isVIP ) && self.isVIP ) || ( isDefined( self.isDefusing ) && self.isDefusing ) || ( isDefined( self.isPlanting ) && self.isPlanting ) || ( level.gametype == "ftag" && self.freezeTag["frozen"] ) )
				break;
		}

		// Make sure the player is not interacting with an objective
		if ( ( !isDefined( self.interacting_with_objective ) || !self.interacting_with_objective ) && ( !isDefined( self.isVIP ) || !self.isVIP ) && ( !isDefined( self.isDefusing ) || !self.isDefusing ) && ( !isDefined( self.isPlanting ) || !self.isPlanting ) && ( level.gametype != "ftag" || !self.freezeTag["frozen"] ) ) {
			// Check if the player has moved enough distance
			if ( distanceMoved < level.scr_anti_camping_distance ) {
				// Check if this player is using a sniper rifle
				if ( level.scr_anti_camping_enable == 1 ||
					 ( level.scr_anti_camping_enable == 2 && !maps\mp\gametypes\_weapons::isSniper( self getCurrentWeapon() ) ) ) {
					self.isCamping = true;
	
					// Disable the player weapons and show an icon to the player indicating anti-camping
					if ( level.scr_anti_camping_show != 1 ) {
						self thread showCampingIcon();
					}
					self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
					self playLocalSound( game["voice"][self.pers["team"]] + "new_positions" );
					if ( level.scr_anti_camping_show != 0 ) {
						if ( level.scr_anti_camping_message != "" ) {
							self iprintlnbold( level.scr_anti_camping_message );
						} else {
							self iprintlnbold( &"OW_MOVE_NEW_POSITION" );
						}
					}
	
					// Monitor the player's location more often now to re-enable the weapons
					while ( distanceMoved < level.scr_anti_camping_distance ) {
						wait (0.25);
						distanceMoved = distance( oldPlayerPosition, self.origin );
					}
	
					// Player is not camping anymore
					self.isCamping = false;
					self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
				}
			}
		}

		// Get the player's current position and start waiting again for the next check
		oldPlayerPosition = self.origin;
	}
}



showCampingIcon()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	// Create the hud element for the new spawned player
	self.hud_camping_icon = createIcon( "camping", 50, 50 );
	self.hud_camping_icon setPoint( "CENTER", "CENTER", 220, 90 );

	// Blink the icon to get the player's attention
	showIcon = 1;
	while ( self.isCamping )
	{
		self.hud_camping_icon fadeOverTime(1);
		if ( showIcon )
			self.hud_camping_icon.alpha = 0.9;
		else
			self.hud_camping_icon.alpha = 0.5;

		wait 1;

		showIcon = !showIcon;
	}

	// Destroy the HUD element
	self.hud_camping_icon destroy();
}