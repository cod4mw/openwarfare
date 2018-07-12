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
	level.scr_wdm_enabled = getdvarx( "scr_wdm_enabled", "int", 0, 0, 1 );

	// If weapon damage modifier is disabled then there's nothing else to do here
	if ( level.scr_wdm_enabled == 0 )
		return;

	thread loadWDM();

	return;
}


wdmDamage( iDamage, sWeapon, sHitLoc, sMeansOfDeath )
{
	// By default we won't change the iDamage value
	damageModifier = 1.0;

	// Make sure it was not a knife kill or a headshot
	if ( sMeansOfDeath != "MOD_MELEE" && !maps\mp\gametypes\_globallogic::isHeadShot( sWeapon, sHitLoc, sMeansOfDeath ) ) {
		// Check if we support wdm for this weapon
		if ( isDefined( level.wdm[ sWeapon ] ) ) {
			damageModifier = getdvarx( level.wdm[ sWeapon ], "float", 100.0, 0.0, 200.0 ) / 100;
		} else {
			// Just for testing. Remove this line on release version!
			//self iprintln( "No damage defined for " + sWeapon );
		}
	}

	return int( iDamage * damageModifier );
}


loadWDM()
{
	// Load all the weapons with their corresponding dvar controlling it
	level.wdm = [];

	// Assault class weapons
	level.wdm[ "m16_acog_mp" ] = "scr_wdm_m16";
	level.wdm[ "m16_gl_mp" ] = "scr_wdm_m16";
	level.wdm[ "m16_mp" ] = "scr_wdm_m16";
	level.wdm[ "m16_reflex_mp" ] = "scr_wdm_m16";
	level.wdm[ "m16_silencer_mp" ] = "scr_wdm_m16_silenced";

	level.wdm[ "ak47_acog_mp" ] = "scr_wdm_ak47";
	level.wdm[ "ak47_gl_mp" ] = "scr_wdm_ak47";
	level.wdm[ "ak47_mp" ] = "scr_wdm_ak47";
	level.wdm[ "ak47_reflex_mp" ] = "scr_wdm_ak47";
	level.wdm[ "ak47_silencer_mp" ] = "scr_wdm_ak47_silenced";

	level.wdm[ "m4_acog_mp" ] = "scr_wdm_m4";
	level.wdm[ "m4_gl_mp" ] = "scr_wdm_m4";
	level.wdm[ "m4_mp" ] = "scr_wdm_m4";
	level.wdm[ "m4_reflex_mp" ] = "scr_wdm_m4";
	level.wdm[ "m4_silencer_mp" ] = "scr_wdm_m4_silenced";

	level.wdm[ "g3_acog_mp" ] = "scr_wdm_g3";
	level.wdm[ "g3_gl_mp" ] = "scr_wdm_g3";
	level.wdm[ "g3_mp" ] = "scr_wdm_g3";
	level.wdm[ "g3_reflex_mp" ] = "scr_wdm_g3";
	level.wdm[ "g3_silencer_mp" ] = "scr_wdm_g3_silenced";

	level.wdm[ "g36c_acog_mp" ] = "scr_wdm_g36c";
	level.wdm[ "g36c_gl_mp" ] = "scr_wdm_g36c";
	level.wdm[ "g36c_mp" ] = "scr_wdm_g36c";
	level.wdm[ "g36c_reflex_mp" ] = "scr_wdm_g36c";
	level.wdm[ "g36c_silencer_mp" ] = "scr_wdm_g36c_silenced";

	level.wdm[ "m14_acog_mp" ] = "scr_wdm_m14";
	level.wdm[ "m14_gl_mp" ] = "scr_wdm_m14";
	level.wdm[ "m14_mp" ] = "scr_wdm_m14";
	level.wdm[ "m14_reflex_mp" ] = "scr_wdm_m14";
	level.wdm[ "m14_silencer_mp" ] = "scr_wdm_m14_silenced";

	level.wdm[ "mp44_mp" ] = "scr_wdm_mp44";


	// Special Ops class weapons
	level.wdm[ "mp5_acog_mp" ] = "scr_wdm_mp5";
	level.wdm[ "mp5_mp" ] = "scr_wdm_mp5";
	level.wdm[ "mp5_reflex_mp" ] = "scr_wdm_mp5";
	level.wdm[ "mp5_silencer_mp" ] = "scr_wdm_mp5_silenced";

	level.wdm[ "skorpion_acog_mp" ] = "scr_wdm_skorpion";
	level.wdm[ "skorpion_mp" ] = "scr_wdm_skorpion";
	level.wdm[ "skorpion_reflex_mp" ] = "scr_wdm_skorpion";
	level.wdm[ "skorpion_silencer_mp" ] = "scr_wdm_skorpion_silenced";

	level.wdm[ "uzi_acog_mp" ] = "scr_wdm_uzi";
	level.wdm[ "uzi_mp" ] = "scr_wdm_uzi";
	level.wdm[ "uzi_reflex_mp" ] = "scr_wdm_uzi";
	level.wdm[ "uzi_silencer_mp" ] = "scr_wdm_uzi_silenced";

	level.wdm[ "ak74u_acog_mp" ] = "scr_wdm_ak74u";
	level.wdm[ "ak74u_mp" ] = "scr_wdm_ak74u";
	level.wdm[ "ak74u_reflex_mp" ] = "scr_wdm_ak74u";
	level.wdm[ "ak74u_silencer_mp" ] = "scr_wdm_ak74u_silenced";

	level.wdm[ "p90_acog_mp" ] = "scr_wdm_p90";
	level.wdm[ "p90_mp" ] = "scr_wdm_p90";
	level.wdm[ "p90_reflex_mp" ] = "scr_wdm_p90";
	level.wdm[ "p90_silencer_mp" ] = "scr_wdm_p90_silenced";


	// Demolition class weapons
	level.wdm[ "m1014_grip_mp" ] = "scr_wdm_m1014";
	level.wdm[ "m1014_mp" ] = "scr_wdm_m1014";
	level.wdm[ "m1014_reflex_mp" ] = "scr_wdm_m1014";

	level.wdm[ "winchester1200_grip_mp" ] = "scr_wdm_winchester1200";
	level.wdm[ "winchester1200_mp" ] = "scr_wdm_winchester1200";
	level.wdm[ "winchester1200_reflex_mp" ] = "scr_wdm_winchester1200";


	// Heavy gunner class weapons
	level.wdm[ "saw_acog_mp" ] = "scr_wdm_saw";
	level.wdm[ "saw_grip_mp" ] = "scr_wdm_saw";
	level.wdm[ "saw_mp" ] = "scr_wdm_saw";
	level.wdm[ "saw_reflex_mp" ] = "scr_wdm_saw";

	level.wdm[ "rpd_acog_mp" ] = "scr_wdm_rpd";
	level.wdm[ "rpd_grip_mp" ] = "scr_wdm_rpd";
	level.wdm[ "rpd_mp" ] = "scr_wdm_rpd";
	level.wdm[ "rpd_reflex_mp" ] = "scr_wdm_rpd";

	level.wdm[ "m60e4_acog_mp" ] = "scr_wdm_m60e4";
	level.wdm[ "m60e4_grip_mp" ] = "scr_wdm_m60e4";
	level.wdm[ "m60e4_mp" ] = "scr_wdm_m60e4";
	level.wdm[ "m60e4_reflex_mp" ] = "scr_wdm_m60e4";


	// Sniper class weapons
	level.wdm[ "dragunov_acog_mp" ] = "scr_wdm_dragunov";
	level.wdm[ "dragunov_mp" ] = "scr_wdm_dragunov";

	level.wdm[ "m40a3_acog_mp" ] = "scr_wdm_m40a3";
	level.wdm[ "m40a3_mp" ] = "scr_wdm_m40a3";

	level.wdm[ "barrett_acog_mp" ] = "scr_wdm_barrett";
	level.wdm[ "barrett_mp" ] = "scr_wdm_barrett";

	level.wdm[ "remington700_acog_mp" ] = "scr_wdm_remington700";
	level.wdm[ "remington700_mp" ] = "scr_wdm_remington700";

	level.wdm[ "m21_acog_mp" ] = "scr_wdm_m21";
	level.wdm[ "m21_mp" ] = "scr_wdm_m21";


	// Handguns
	level.wdm[ "beretta_mp" ] = "scr_wdm_beretta";
	level.wdm[ "beretta_silencer_mp" ] = "scr_wdm_beretta_silenced";

	level.wdm[ "colt45_mp" ] = "scr_wdm_colt45";
	level.wdm[ "colt45_silencer_mp" ] = "scr_wdm_colt45_silenced";

	level.wdm[ "usp_mp" ] = "scr_wdm_usp";
	level.wdm[ "usp_silencer_mp" ] = "scr_wdm_usp_silenced";

	level.wdm[ "deserteagle_mp" ] = "scr_wdm_deserteagle";

	level.wdm[ "deserteaglegold_mp" ] = "scr_wdm_deserteaglegold";


	// Miscellaneous

	// Grenade launcher
	level.wdm[ "gl_m16_mp" ] = "scr_wdm_gl";
	level.wdm[ "gl_ak47_mp" ] = "scr_wdm_gl";
	level.wdm[ "gl_m4_mp" ] = "scr_wdm_gl";
	level.wdm[ "gl_g3_mp" ] = "scr_wdm_gl";
	level.wdm[ "gl_g36c_mp" ] = "scr_wdm_gl";
	level.wdm[ "gl_m14_mp" ] = "scr_wdm_gl";
	level.wdm[ "gl_mp" ] = "scr_wdm_gl";

	// Frag grenades
	level.wdm[ "frag_grenade_mp" ] = "scr_wdm_frag_grenades";
	level.wdm[ "frag_grenade_short_mp" ] = "scr_wdm_frag_grenades";  // This one is the one used in Martyrdom

	// Explosives
	level.wdm[ "c4_mp" ] = "scr_wdm_c4";
	level.wdm[ "claymore_mp" ] = "scr_wdm_claymore";
	level.wdm[ "rpg_mp" ] = "scr_wdm_rpg";

	// Misc
	level.wdm[ "destructible_car" ] = "scr_wdm_vehicles";
	level.wdm[ "explodable_barrel" ] = "scr_wdm_barrels";
	
	return;
}

