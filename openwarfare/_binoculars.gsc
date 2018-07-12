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
	level.weap_allow_binoculars = getdvarx( "weap_allow_binoculars", "int", 0, 0, 1 );
	
	// If binoculars is not enabled then there's nothing else to do here
	if ( level.weap_allow_binoculars == 0 )
		return;
		
	precacheItem( "binoculars_mp" );	
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}


onPlayerSpawned()
{
	// Give the binos to the player
	self giveWeapon( "binoculars_mp" );
	self setActionSlot( 2, "weapon", "binoculars_mp" );
	
	// Monitor the use of binos to prevent them from be used as sniper scopes
	self thread monitorBinosUtilization();
}


monitorBinosUtilization()
{
	self endon("death");
	self endon("disconnect");
	level endon( "game_ended" );
	
	oldWeapon = self getCurrentWeapon();
	wasBinos = ( oldWeapon == "binoculars_mp" );
	
	for (;;) 
	{
		wait (0.05);
		if ( isDefined( self ) ) {
			currentWeapon = self getCurrentWeapon();
			if ( currentWeapon != oldWeapon ) {
				if ( wasBinos ) {
					self shiftPlayerView( 3 );
					wasBinos = false;
				} else if ( currentWeapon == "binoculars_mp" ) {
					wasBinos = true;
				}					
					
				oldWeapon = currentWeapon;
			}			
		}	
	}
}