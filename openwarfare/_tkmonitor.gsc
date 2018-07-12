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
	level.scr_tk_limit = getdvarx( "scr_tk_limit", "int", 0, 0, 10 );

	// If tk monitor is not enabled or is not a teambased match then there's nothing else to do here
	if ( level.scr_tk_limit == 0 || !level.teamBased )
		return;

	// If TK monitor is enabled then disable the stock variables to prevent any conflict
	setDvar( "scr_team_teamkillspawndelay", "0" );
	setDvar( "scr_team_kickteamkillers", "0" );
	setDvar( "scr_teamKillPunishCount", "0" );

	// Get the rest of the module's dvars
	level.scr_tk_punishment_time = getdvarx( "scr_tk_punishment_time", "int", 0, 0, 60 );
	level.scr_tk_explosive_countasone  = getdvarx( "scr_tk_explosive_countasone", "int", 0, 0, 1 );

	// 0 = Warning, 1 = Remove player's weapons, 2 = Freeze player, 3 = Suicide player, 4 = Kick player
	level.scr_tk_punishment  = getdvarx( "scr_tk_punishment", "int", 0, 0, 4 );

	precacheString( &"OW_TK_WATCHFIRE" );
	precacheString( &"MP_FRIENDLY_FIRE_WILL_NOT" );
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}


onPlayerSpawned()
{
	self thread monitorTeamKills();
	self thread monitorForPunishment();
}


monitorTeamKills()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );
	
	// Check if it's the first time the player is monitored
	if ( !isDefined( self.teamKills ) ) {
			self.teamKills = 0;
	}

	lastExplosiveTK = 0;

	for (;;)
	{
		self waittill( "team_kill", eVictim, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime);

		// If the victim and the attacker are the same person don't do anything
		if ( self == eVictim )
			continue;

		// If the victim was killed by a friendly claymore we should not punish the player
		if ( sWeapon == "claymore_mp" )
			continue;

		// If the victim was killed by an explotion
		if ( sMeansOfDeath == "none" ) {
			// Check if we need to count them as one or individually
			if ( level.scr_tk_explosive_countasone == 1 ) {
				if ( gettime() - lastExplosiveTK > 500 ) {
					self.teamKills++;
					if ( self.teamKills < level.scr_tk_limit || level.scr_tk_punishment == 0 ) {
						self iprintlnbold( &"OW_TK_WATCHFIRE" );
					}
				}
			} else {
				// Make sure we display the message only once for multiple teamkills with explosives
				self.teamKills++;
				if ( gettime() - lastExplosiveTK > 500 ) {
					if ( self.teamKills < level.scr_tk_limit  || level.scr_tk_punishment == 0 ) {
						self iprintlnbold( &"OW_TK_WATCHFIRE" );
					}
				}

			}

			lastExplosiveTK = gettime();

		} else {
			// Just count another team kill and display a message to the player
			self.teamKills++;
			if ( self.teamKills < level.scr_tk_limit || level.scr_tk_punishment == 0 ) {
				self iprintlnbold( &"OW_TK_WATCHFIRE" );
			}
		}
	}
}



monitorForPunishment()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	for (;;)
	{
		wait (0.05);

		// Check if the player has reached the number of team kills allowed
		if ( self.teamKills >= level.scr_tk_limit ) {
			// Let's save the number of kills and reset it so it starts counting again
			playerTKs = self.teamKills;
			self.teamKills = 0;

			// Check if we need to display a new message to the player
			if ( level.scr_tk_punishment != 0 ) {
				self iprintlnbold( &"MP_FRIENDLY_FIRE_WILL_NOT" );
			}

			// Check what kind of punishments we should apply
			switch ( level.scr_tk_punishment )
			{
				case 1:
					// Remove player's weapons for some time
					self thread maps\mp\gametypes\_gameobjects::_disableWeapon();

					// Wait the proper time to give the weapons back to the player
					xWait( level.scr_tk_punishment_time );

					// Enable the player's weapons again
					self thread maps\mp\gametypes\_gameobjects::_enableWeapon();

					break;

				case 2:
					// Freeze player on the spot
					self thread openwarfare\_speedcontrol::setModifierSpeed( "_tkmonitor", 100 );

					// Wait the proper time to unfreeze the player
					xWait( level.scr_tk_punishment_time );

					// Unfreeze the player
					self thread openwarfare\_speedcontrol::setModifierSpeed( "_tkmonitor", 0 );

					break;

				case 3:
					// Kill the player
					self suicidePlayer();
					break;

				case 4:
					// Kick the player from the server (wait one second so the player has time to see the message)
					self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
					self thread openwarfare\_speedcontrol::setModifierSpeed( "_tkmonitor", 100 );
					wait (2.0);
					kick( self getEntityNumber() );
					break;
			}
		}
	}
}


