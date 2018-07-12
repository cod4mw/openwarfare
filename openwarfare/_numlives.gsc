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

#include maps\mp\gametypes\_hud_util;
#include openwarfare\_eventmanager;
#include openwarfare\_utils;

init()
{
	// Get the main module's dvar
	level.scr_show_lives_enable = getdvarx( "scr_show_lives_enable", "int", 0, 0, 1 );

	// If showing number of lives remaining is disabled there's nothing else to do here
	if ( level.scr_show_lives_enable == 0 || !level.numLives )
		return;

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}	


onPlayerSpawned()
{
	self endon("disconnect");
	self endon("joined_team");
	self endon("joined_spectators");
		
	// We won't show any messaGe if we are in overtime or ready-up periods
	if ( level.inOverTime || level.inReadyUpPeriod )
		return;
		
	// We'll wait for prematch period to be over
	if ( level.inPrematchPeriod )
		level waittill("prematch_over");	

	// Create the HUD element to show the remaining lives for this player
	numLives = createFontString( "objective", 2.3 );
	numLives setPoint( "CENTER", "CENTER", 0, 50 );
	numLives.sort = 1001;
	numLives.foreground = false;
	numLives.hidewheninmenu = true;
	numLives.archived = true;
	numLives maps\mp\gametypes\_hud::fontPulseInit();
	
	// Check which string we should show
	if ( level.numLives == 1 ) {
		numLives.glowAlpha = 0.9;
		numLives.glowColor = (1,0,0);
		numLives.color = (1,0.5,0);
		numLives setText( &"MP_NO_RESPAWN" );		
		
	} else if ( self.pers["lives"] ) {
		numLives.label = &"OW_LIVES_LEFT";
		numLives setValue( self.pers["lives"] + 1 );
		
	} else {
		numLives.glowAlpha = 0.9;
		numLives.glowColor = (1,0,0);
		numLives.color = (1,0.5,0);
		numLives setText( &"OW_LAST_LIFE" );
	}

	// Do the pulse effect and destroy the element	
	numLives thread maps\mp\gametypes\_hud::fontPulse( level );
	wait (2.5);
	numLives destroyElem();
}