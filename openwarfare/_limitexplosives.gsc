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
	level.scr_limit_planted_c4s = getdvarx( "scr_limit_planted_c4s", "int", 0, 0, 50 );
	level.scr_limit_planted_claymores = getdvarx( "scr_limit_planted_claymores", "int", 0, 0, 50 );

	// Check if we need to stay here or not
	if ( ( level.scr_limit_planted_c4s == 0 && level.scr_limit_planted_claymores == 0 ) || !level.teamBased )
		return;

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}


onPlayerSpawned()
{
	// Check what explosives we need to control and start the controlling functions
	if ( level.scr_limit_planted_c4s > 0 )
		self thread monitorPlantedExplosives( level.scr_limit_planted_c4s, "c4_mp" );
	if ( level.scr_limit_planted_claymores > 0 )
		self thread monitorPlantedExplosives( level.scr_limit_planted_claymores, "claymore_mp" );
}


monitorPlantedExplosives( explosiveLimit, explosiveName )
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	// Initialize some variables
	ammoCount = 0;
	ammoTaken = 0;
	
	for (;;)
	{
		wait (0.5);
		
		// Check if the player has these kind of explosives or we have taken away explosives from the player
		ammoCount = self getAmmoCount( explosiveName );
		
		if ( ammoCount > 0 || ammoTaken > 0 ) {
			// Count the number of explosives in the map
			explosiveCount = countActiveExplosives( explosiveName, self.pers["team"] );
			
			// If ammo was already taken then we just need to check if we can give it back
			if ( ammoTaken > 0 && explosiveCount < explosiveLimit ) {
				// Give the explosives back
				self giveWeapon( explosiveName );
				self setWeaponAmmoStock( explosiveName, ammoTaken );				
				ammoTaken = 0;
				
			} else if ( ammoCount > 0 && explosiveCount >= explosiveLimit ) {
				// Remove the ammo from the player
				if ( self getCurrentWeapon() == explosiveName ) {
					// Switch to the player's primary weapon as we are about to remove his/her explosives
					primaryWeapon = self getPlayerPrimaryWeapon();
					if ( primaryWeapon != "none" ) {
						self switchToWeapon( primaryWeapon );
					}
				}
				ammoTaken += ammoCount;
				self setWeaponAmmoStock( explosiveName, 0 );				
			}			
		}		
	}	
}


countActiveExplosives( explosiveName, explosiveTeam )
{
	// Count placed explosives
	explosiveEntities = getEntArray( explosiveName + "_" + explosiveTeam, "targetname");
	
	return explosiveEntities.size;	
}