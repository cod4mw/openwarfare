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
	level.scr_thirdperson_enable = getdvarx( "scr_thirdperson_enable", "int", 0, 0, 1 );

	// If third person is not enabled then there's nothing else to do here
	if ( level.scr_thirdperson_enable == 0 )
		return;

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onPlayerDeath", ::onPlayerDeath );	
}


onPlayerSpawned()
{
	self thread set3rdPersonView();

	// Switch to 1st. person view whenever the player is aiming down the sight		
	self thread monitorPlayerADS();
}


onPlayerDeath()
{
	self thread set3rdPersonView();
}


set3rdPersonView()
{
	// Set 3rd. person view
	self setClientDvars( 
		"cg_thirdPerson", "1",
		"cg_thirdPersonAngle", "360",
		"cg_thirdPersonRange", "72"
	);
}


set1stPersonView()
{
	// Set 1st. person view
	self setClientDvar( 
		"cg_thirdPerson", "0"
	);
}


monitorPlayerADS()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	// Initialize some control values
	oldAds = 0;
	firstPersonView = false;

	for (;;)
	{
		wait (0.05);
		
		// Check if the player enable/disable ADS
		if ( self playerADS() > oldAds ) {
			oldAds = self playerADS();
			// Player is enabling ADS
			if ( !firstPersonView ) {
				self thread set1stPersonView();	
				firstPersonView = true;				
			}
			
		} else if ( self playerADS() < oldAds ) {
			oldAds = self playerADS();
			// Player is disabling ADS
			if ( firstPersonView ) {
				self thread set3rdPersonView();	
				firstPersonView = false;
			}
		}
	}			
}