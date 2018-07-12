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

#include openwarfare\_utils;


init()
{
	// Get the main module's dvar
	level.scr_rng_enabled = getdvarx( "scr_rng_enabled", "int", 0, 0, 2 );

	// If R&G is disabled then there's nothing else to do here
	if ( level.scr_rng_enabled == 0 )
		return;

	// Load the rest of the module's dvars
	level.scr_rng_distance = getdvarx( "scr_rng_distance", "int", 200, 0, 10000 );
	level.scr_rng_damage_closer = getdvarx( "scr_rng_damage_closer", "float", 50, 0, 100 );
	level.scr_rng_damage_longer = getdvarx( "scr_rng_damage_longer", "float", 5, 0, 100 );

	return;
}


rngDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	// Make sure we are dealing with a player that was not using the weapon sights
	if ( isDefined( eAttacker ) && isPlayer( eAttacker ) && self != eAttacker && sHitLoc != "none" && !eAttacker playerAds() ) {
		// Make sure we are dealing with a weapon that supports sights
		if ( ( maps\mp\gametypes\_weapons::isPrimaryWeapon( sWeapon ) || maps\mp\gametypes\_weapons::isPistol( sWeapon ) ) && ( level.scr_rng_enabled == 1 || weaponClass( sWeapon ) != "spread" ) && sMeansOfDeath != "MOD_MELEE" ) {
			// Get the distance between the player and the attacker
			rngDistance = distance( self.origin, eAttacker.origin );

				// Check which damage percentage we need to apply
			if ( rngDistance <= level.scr_rng_distance ) {
				iDamage = int( iDamage * level.scr_rng_damage_closer / 100 );
			} else {
				iDamage = int( iDamage * level.scr_rng_damage_longer / 100 );
			}
		}
	}

	return iDamage;
}