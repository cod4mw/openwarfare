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

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

#include openwarfare\_eventmanager;
#include openwarfare\_utils;

init()
{
	// Get the main module's dvars
	level.scr_idle_switch_spectator = getdvarx( "scr_idle_switch_spectator", "int", 0, 0, 600 );
	level.scr_idle_spectator_timeout = getdvarx( "scr_idle_spectator_timeout", "int", 0, 0, 600 );

	// Check if we really need to monitor idle players
	if ( level.scr_idle_switch_spectator == 0 && level.scr_idle_spectator_timeout  == 0 )
		return;

	// Get the rest of the module's dvars
	level.scr_idle_protected_tags = getdvarx( "scr_idle_protected_tags", "string", "" );
	level.scr_idle_protected_guids = getdvarx( "scr_idle_protected_guids", "string", level.scr_server_overall_admin_guids );
	level.scr_idle_show_warning = getdvarx( "scr_idle_show_warning", "int", 0, 0, 1 );

	// Transform the protected tags into an array (format for the variable should be "[FLOT] [TGW] {1stAD}"
	level.scr_idle_protected_tags = strtok( level.scr_idle_protected_tags, " " );

	precacheString( &"OW_SWITCH_TO_SPECTATE" );
	precacheString( &"OW_KICK_IDLE" );

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnected()
{
	self thread idleMonitor();
	self thread addNewEvent( "onJoinedTeam", ::onJoinedTeam );
	self thread addNewEvent( "onJoinedSpectators", ::onJoinedSpectators );
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onPlayerKilled", ::onPlayerKilled );
}

onPlayerKilled()
{
	self destroyIdleTimer();
}


onPlayerSpawned()
{
	self.lastActivity = gettime();
	self.idleWarned = false;
	self.idleSwitched = false;
}


onJoinedTeam()
{
	self.lastActivity = gettime();
	self.idleWarned = false;
	self.idleSwitched = false;
	self destroyIdleTimer();
}


onJoinedSpectators()
{
	// If the player was moved to spectator we don't change the time since the player was idle
	if ( !self.idleSwitched ) {
		self.lastActivity = gettime();
	}
	self.idleWarned = false;
	self.idleSwitched = false;
}


idleMonitor()
{
	self endon("disconnect");
	level endon( "game_ended" );

	// Check if this player is protected by GUID or clan tag
	if ( issubstr( level.scr_idle_protected_guids, self getGuid() ) ) {
		return;
	}
	for ( tagx = 0; tagx < level.scr_idle_protected_tags.size; tagx++ ) {
		if ( issubstr( self.name, level.scr_idle_protected_tags[tagx] ) ) {
			return;
		}
	}

	self.lastActivity = gettime();
	self.idleWarned = false;
	self.idleSwitched = false;

	for (;;)
	{
		wait (0.05);

		// Check that the player is not spectating
		if ( isDefined( self.pers["team"] ) && self.pers["team"] != "spectator" ) {
			// Check if we need to move idle players to spectating
			if ( level.scr_idle_switch_spectator > 0 ) {
				// Check if the player is dead but waiting to respawn
				if ( !isAlive( self ) && ( self.waitingToSpawn || !self maps\mp\gametypes\_globallogic::maySpawn() ) ) {
					self.lastActivity = gettime();
					self destroyIdleTimer();
					self.idleWarned = false;
				}

				// Check if the player is alive and doing stuff
				playerAngles = self getPlayerAngles();
				if ( isAlive( self ) && ( self getVelocity() != 0 || self attackButtonPressed() || self fragButtonPressed() || self meleeButtonPressed() || self secondaryOffhandButtonPressed() || self useButtonPressed() || ( !isDefined( self.idlePlayerAngles ) || self.idlePlayerAngles != playerAngles ) || ( level.gametype == "ftag" && self.freezeTag["frozen"] ) ) ) {
					self.lastActivity = gettime();
					self.idleWarned = false;
					self destroyIdleTimer();
					self.idlePlayerAngles = playerAngles;
				}

				// See how long this player has been idle
				idleTime = ( gettime() - self.lastActivity ) / 1000;

				// Check if it's time to warn the player
				if ( idleTime >= ( level.scr_idle_switch_spectator * 0.8 ) && !self.idleWarned ) {
					self.idleWarned = true;
					if ( level.scr_idle_show_warning == 1 && level.scr_idle_switch_spectator - idleTime > 0 ) {
						self showIdleTimer( &"OW_SWITCH_TO_SPECTATE", level.scr_idle_switch_spectator - idleTime );
					}
				}

				// Check if it's time to kick the player
				if ( idleTime >= level.scr_idle_switch_spectator ) {
					self.idleSwitched = true;
					self destroyIdleTimer();
					self maps\mp\gametypes\_globallogic::menuSpectator();
				}
			}
		} else {
			// Check if we need to kick spectators but make sure we don't a person that is connecting to the server
			if ( level.scr_idle_spectator_timeout > 0 && self.statusicon != "hud_status_connecting" ) {
				// See how long this player has been spectating
				idleTime = ( gettime() - self.lastActivity ) / 1000;

				// Check if it's time to warn the player
				if ( idleTime >= ( level.scr_idle_spectator_timeout * 0.8 ) && !self.idleWarned ) {
					self.idleWarned = true;
					if ( level.scr_idle_show_warning == 1 && level.scr_idle_switch_spectator - idleTime > 0 ) {
						self showIdleTimer( &"OW_KICK_IDLE", level.scr_idle_spectator_timeout - idleTime );
					}
				}

				// Check if it's time to kick the player
				if ( idleTime >= level.scr_idle_spectator_timeout ) {
					self destroyIdleTimer();
					kick( self getEntityNumber() );
				}
			} else {
					self.lastActivity = gettime();
					self destroyIdleTimer();
					self.idleWarned = false;
			}
		}
	}
}


showIdleTimer( idleText, timeRemaining )
{
	// Create the message text
	self.idleText = createFontString( "objective", 1.5 );
	self.idleText.color = ( 1, 1, 1 );
	self.idleText setPoint( "CENTER", "CENTER", 0, -20 );
	self.idleText.sort = 1001;
	self.idleText setText( idleText );
	self.idleText.foreground = false;
	self.idleText.hidewheninmenu = true;

	// Create the timer showing when action is going to be taken
	self.idleTimer = createTimer( "objective", 1.4 );
	self.idleTimer.color = ( 1, 0.5, 0 );
	self.idleTimer setPoint( "CENTER", "CENTER", 0, 0 );
	self.idleTimer setTimer( timeRemaining );
	self.idleTimer.sort = 1001;
	self.idleTimer.foreground = false;
	self.idleTimer.hideWhenInMenu = true;
}


destroyIdleTimer()
{
	// Destroy the idle monitor HUD elements
	if ( isDefined( self.idleText ) )
		self.idleText destroy();
	if ( isDefined( self.idleTimer ) )
		self.idleTimer destroy();
}