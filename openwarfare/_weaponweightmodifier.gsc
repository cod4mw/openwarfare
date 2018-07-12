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
	level.scr_wwm_enabled = getdvarx( "scr_wwm_enabled", "int", 0, 0, 1 );

	// If weapon weight modifier is disabled then there's nothing else to do here
	if ( level.scr_wwm_enabled == 0 )
		return;

	thread loadWWM();

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}


onPlayerSpawned()
{
	self thread weaponWeightMonitoring();
}

weaponWeightMonitoring()
{
	self endon("disconnect");	
	self endon( "death" );
	level endon( "game_ended" );

	for (;;)
	{
		wait (0.5);

		// Make sure the player is alive after the wait time is over
		if ( !isDefined( self) )
			return;

		// Initialize variable to keep the total weight
		totalWeight = 0;

		// Get all the things that the player is carrying
		weaponsList = self getWeaponsList();
		for( i = 0; i < weaponsList.size; i++ )
		{
			// Get the weapon's name and type
			weapon = weaponsList[ i ];
			weaponType = weaponInventoryType( weapon );

			// If it's a grenade or item like C4, claymore or RPG get the ammo available
			if ( weaponType == "offhand" || weaponType == "item" ) {
				itemCount = self getAmmoCount( weapon );
			} else {
				itemCount = 1;
			}

			// Get the weight assigned to the weapon
			if ( isDefined( level.wwm[ weapon ] ) ) {
				totalWeight += getdvarx( level.wwm[ weapon ], "float", 0.0, 0.0, 10.0 ) * itemCount;
			} else {
				// Just for testing. Remove this line on release version!
				//self iprintln( "No weight defined for " + weapon );
			}
		}

		// Set the player's speed based on the weight of the items being carried
		rangeToUse = 0;
		while ( totalWeight > level.wwmWeights[ rangeToUse ] && rangeToUse < level.wwmWeights.size ) {
			rangeToUse++;
		}
		// If we reached the higher value we'll go back one
		if ( rangeToUse >= level.wwmWeights.size ) {
			rangeToUse--;
		}
		
		// Get the new speed
		newSpeed = level.wwmSpeeds[ rangeToUse ];
		//self iprintln( "wwmSpeeds.size: " + level.wwmSpeeds.size + "  wwmWeights.size: " + level.wwmWeights.size );
		//self iprintln( "Range used: " + rangeToUse + "  Total weight: " + totalWeight + "  New speed: " + newSpeed );
		
		// Make sure we are allowed to change the player's speed
		self thread openwarfare\_speedcontrol::setBaseSpeed( newSpeed );
	}
}


loadWWM()
{
	// Load the speed ranges
	level.wwmSpeeds = getDvarListx( "scr_wwm_range_speed_", "float", 0.0, 0.0, 1.5 );
	level.wwmWeights = getDvarListx( "scr_wwm_range_weight_", "float", 0.0, 0.0, 20.0 );
	// Make sure we have at least one element
	if ( level.wwmSpeeds.size == 0 || level.wwmWeights.size == 0 || level.wwmSpeeds.size != level.wwmWeights.size ) {
		level.wwmSpeeds[0] = 1.0;
		level.wwmWeights[0] = 20.0;
	}	
	
	// Load all the weapons with their corresponding dvar controlling it
	level.wwm = [];

	// Assault class weapons
	level.wwm[ "m16_acog_mp" ] = "scr_wwm_m16";
	level.wwm[ "m16_gl_mp" ] = "scr_wwm_m16_gl";
	level.wwm[ "m16_mp" ] = "scr_wwm_m16";
	level.wwm[ "m16_reflex_mp" ] = "scr_wwm_m16";
	level.wwm[ "m16_silencer_mp" ] = "scr_wwm_m16";

	level.wwm[ "ak47_acog_mp" ] = "scr_wwm_ak47";
	level.wwm[ "ak47_gl_mp" ] = "scr_wwm_ak47_gl";
	level.wwm[ "ak47_mp" ] = "scr_wwm_ak47";
	level.wwm[ "ak47_reflex_mp" ] = "scr_wwm_ak47";
	level.wwm[ "ak47_silencer_mp" ] = "scr_wwm_ak47";

	level.wwm[ "m4_acog_mp" ] = "scr_wwm_m4";
	level.wwm[ "m4_gl_mp" ] = "scr_wwm_m4_gl";
	level.wwm[ "m4_mp" ] = "scr_wwm_m4";
	level.wwm[ "m4_reflex_mp" ] = "scr_wwm_m4";
	level.wwm[ "m4_silencer_mp" ] = "scr_wwm_m4";
	
	level.wwm[ "g3_acog_mp" ] = "scr_wwm_g3";
	level.wwm[ "g3_gl_mp" ] = "scr_wwm_g3_gl";
	level.wwm[ "g3_mp" ] = "scr_wwm_g3";
	level.wwm[ "g3_reflex_mp" ] = "scr_wwm_g3";
	level.wwm[ "g3_silencer_mp" ] = "scr_wwm_g3";
	
	level.wwm[ "g36c_acog_mp" ] = "scr_wwm_g36c";
	level.wwm[ "g36c_gl_mp" ] = "scr_wwm_g36c_gl";
	level.wwm[ "g36c_mp" ] = "scr_wwm_g36c";
	level.wwm[ "g36c_reflex_mp" ] = "scr_wwm_g36c";
	level.wwm[ "g36c_silencer_mp" ] = "scr_wwm_g36c";
	
	level.wwm[ "m14_acog_mp" ] = "scr_wwm_m14";
	level.wwm[ "m14_gl_mp" ] = "scr_wwm_m14_gl";
	level.wwm[ "m14_mp" ] = "scr_wwm_m14";
	level.wwm[ "m14_reflex_mp" ] = "scr_wwm_m14";
	level.wwm[ "m14_silencer_mp" ] = "scr_wwm_m14";
	
	level.wwm[ "mp44_mp" ] = "scr_wwm_mp44";

	// Special Ops class weapons
	level.wwm[ "mp5_acog_mp" ] = "scr_wwm_mp5";
	level.wwm[ "mp5_mp" ] = "scr_wwm_mp5";
	level.wwm[ "mp5_reflex_mp" ] = "scr_wwm_mp5";
	level.wwm[ "mp5_silencer_mp" ] = "scr_wwm_mp5";

	level.wwm[ "skorpion_acog_mp" ] = "scr_wwm_skorpion";
	level.wwm[ "skorpion_mp" ] = "scr_wwm_skorpion";
	level.wwm[ "skorpion_reflex_mp" ] = "scr_wwm_skorpion";
	level.wwm[ "skorpion_silencer_mp" ] = "scr_wwm_skorpion";

	level.wwm[ "uzi_acog_mp" ] = "scr_wwm_uzi";
	level.wwm[ "uzi_mp" ] = "scr_wwm_uzi";
	level.wwm[ "uzi_reflex_mp" ] = "scr_wwm_uzi";
	level.wwm[ "uzi_silencer_mp" ] = "scr_wwm_uzi";

	level.wwm[ "ak74u_acog_mp" ] = "scr_wwm_ak74u";
	level.wwm[ "ak74u_mp" ] = "scr_wwm_ak74u";
	level.wwm[ "ak74u_reflex_mp" ] = "scr_wwm_ak74u";
	level.wwm[ "ak74u_silencer_mp" ] = "scr_wwm_ak74u";

	level.wwm[ "p90_acog_mp" ] = "scr_wwm_p90";
	level.wwm[ "p90_mp" ] = "scr_wwm_p90";
	level.wwm[ "p90_reflex_mp" ] = "scr_wwm_p90";
	level.wwm[ "p90_silencer_mp" ] = "scr_wwm_p90";


	// Demolition class weapons
	level.wwm[ "m1014_grip_mp" ] = "scr_wwm_m1014";
	level.wwm[ "m1014_mp" ] = "scr_wwm_m1014";
	level.wwm[ "m1014_reflex_mp" ] = "scr_wwm_m1014";

	level.wwm[ "winchester1200_grip_mp" ] = "scr_wwm_winchester1200";
	level.wwm[ "winchester1200_mp" ] = "scr_wwm_winchester1200";
	level.wwm[ "winchester1200_reflex_mp" ] = "scr_wwm_winchester1200";


	// Heavy gunner class weapons
	level.wwm[ "saw_acog_mp" ] = "scr_wwm_saw";
	level.wwm[ "saw_grip_mp" ] = "scr_wwm_saw";
	level.wwm[ "saw_mp" ] = "scr_wwm_saw";
	level.wwm[ "saw_reflex_mp" ] = "scr_wwm_saw";

	level.wwm[ "rpd_acog_mp" ] = "scr_wwm_rpd";
	level.wwm[ "rpd_grip_mp" ] = "scr_wwm_rpd";
	level.wwm[ "rpd_mp" ] = "scr_wwm_rpd";
	level.wwm[ "rpd_reflex_mp" ] = "scr_wwm_rpd";

	level.wwm[ "m60e4_acog_mp" ] = "scr_wwm_m60e4";
	level.wwm[ "m60e4_grip_mp" ] = "scr_wwm_m60e4";
	level.wwm[ "m60e4_mp" ] = "scr_wwm_m60e4";
	level.wwm[ "m60e4_reflex_mp" ] = "scr_wwm_m60e4";


	// Sniper class weapons
	level.wwm[ "dragunov_acog_mp" ] = "scr_wwm_dragunov";
	level.wwm[ "dragunov_mp" ] = "scr_wwm_dragunov";

	level.wwm[ "m40a3_acog_mp" ] = "scr_wwm_m40a3";
	level.wwm[ "m40a3_mp" ] = "scr_wwm_m40a3";

	level.wwm[ "barrett_acog_mp" ] = "scr_wwm_barrett";
	level.wwm[ "barrett_mp" ] = "scr_wwm_barrett";

	level.wwm[ "remington700_acog_mp" ] = "scr_wwm_remington700";
	level.wwm[ "remington700_mp" ] = "scr_wwm_remington700";

	level.wwm[ "m21_acog_mp" ] = "scr_wwm_m21";
	level.wwm[ "m21_mp" ] = "scr_wwm_m21";


	// Handguns
	level.wwm[ "beretta_mp" ] = "scr_wwm_beretta";
	level.wwm[ "beretta_silencer_mp" ] = "scr_wwm_beretta";

	level.wwm[ "colt45_mp" ] = "scr_wwm_colt45";
	level.wwm[ "colt45_silencer_mp" ] = "scr_wwm_colt45";

	level.wwm[ "usp_mp" ] = "scr_wwm_usp";
	level.wwm[ "usp_silencer_mp" ] = "scr_wwm_usp";

	level.wwm[ "deserteagle_mp" ] = "scr_wwm_deserteagle";

	level.wwm[ "deserteaglegold_mp" ] = "scr_wwm_deserteaglegold";


	// Miscellaneous
	level.wwm[ "briefcase_bomb_mp" ] = "scr_wwm_bomb";

	// Grenades
	level.wwm[ "frag_grenade_mp" ] = "scr_wwm_frag_grenade";
	level.wwm[ "flash_grenade_mp" ] = "scr_wwm_flash_grenade";
	level.wwm[ "smoke_grenade_mp" ] = "scr_wwm_smoke_grenade";
	level.wwm[ "concussion_grenade_mp" ] = "scr_wwm_concussion_grenade";

	// Explosives
	level.wwm[ "c4_mp" ] = "scr_wwm_c4";
	level.wwm[ "claymore_mp" ] = "scr_wwm_claymore";
	level.wwm[ "rpg_mp" ] = "scr_wwm_rpg";

	return;
}
