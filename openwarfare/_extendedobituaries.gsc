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
	level.scr_show_ext_obituaries = getdvarx( "scr_show_ext_obituaries", "int", 0, 0, 3 );

	// If extended obituaries are disabled then there's nothing else to do here
	if ( level.scr_show_ext_obituaries == 0 )
		return;

	// Get the rest of  module's dvars
	level.scr_ext_obituaries_unit = getdvarx( "scr_ext_obituaries_unit", "string", "meters", undefined, undefined );
	if ( level.scr_ext_obituaries_unit != "meters" && level.scr_ext_obituaries_unit != "yards" && level.scr_ext_obituaries_unit != "both" ) {
		level.scr_ext_obituaries_unit = "meters";
	}

	precacheString( &"OW_EXTENDED_OBITUARY" );
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}


onPlayerSpawned()
{
	self thread waitForKill();
}


waitForKill()
{
	self endon("disconnect");	
	
	// Wait for the player to die
	self waittill( "player_killed", eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, fDistance );

	// Make sure the attacker is a player
	if ( !isPlayer( eAttacker ) )
		return;

	showObituary = true;

	// Check if we should show detail about certain kills
	if ( self == eAttacker && level.scr_show_obituaries != 0 ) {
		showObituary = false;
	}

	// Check if we still need to show the extended obituary
	if ( !showObituary )
		return;

	if ( !isDefined( fDistance ) || sMeansOfDeath == "MOD_EXPLOSIVE" )
		fDistance = 0;
		
	distInches = fDistance;
	distYards = int( distInches * 0.0278 * 10 ) / 10;
	distMeters = int( distInches * 0.0254 * 10 ) / 10;

	// Check what kind of unit of measure we need to display
	if ( level.scr_ext_obituaries_unit == "meters" ) {
		distToShow = distMeters + "m";
	} else if ( level.scr_ext_obituaries_unit == "yards" ) {
		distToShow = distYards + "yd";
	} else {
		distToShow = distYards + "yd / " + distMeters + "m";
	}

	// Adjustment to the weapon name
	if ( sMeansOfDeath == "MOD_MELEE" ) {
		sWeapon = "knife_mp";
	} else if ( sMeansOfDeath == "MOD_SUICIDE" ) {
		// Don't show extended obituary information
		return;	
	}

	// If the player bleed out then just show that instead of the hit location
	if ( level.scr_healthsystem_bleeding_enable == 1 && self.bleedOut ) {
		sHitLoc = "bloodloss";
	}

	// Convert the weapon name and hit location to the long description
	sWeapon = convertWeaponName( sWeapon );
	sHitLoc = convertHitLocation( sHitLoc );

	// Display the extended information to the victim
	self iprintlnbold( &"OW_EXTENDED_OBITUARY_KILLEDBY_WEAPON", eAttacker.name, sWeapon );
	self iprintlnbold( &"OW_EXTENDED_OBITUARY_LOCATION_DISTANCE", sHitLoc, distToShow );

	// Check if we should show the extended obituary to all the players or just the attacker
	if ( level.scr_show_ext_obituaries == 2 ) {
		eAttacker iprintln( &"OW_EXTENDED_OBITUARY", eAttacker.name, self.name, sHitLoc, sWeapon, distToShow );
		
	} else if ( level.scr_show_ext_obituaries == 3 ) {
		iprintln( &"OW_EXTENDED_OBITUARY", eAttacker.name, self.name, sHitLoc, sWeapon, distToShow );		
	}

	return;
}
