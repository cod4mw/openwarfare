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
	level.scr_wrm_enabled = getdvarx( "scr_wrm_enabled", "int", 0, 0, 1 );

	// If weapon range modifier is disabled then there's nothing else to do here
	if ( level.scr_wrm_enabled == 0 )
		return;

	thread loadWRM();

	return;
}


wrmDamage( eAttacker, iDamage, sWeapon, sHitLoc, sMeansOfDeath )
{
	// By default we won't change the iDamage value
	PlayerInRange = 1.0;

	// Make sure it was not a knife kill
	if ( sMeansOfDeath != "MOD_MELEE" ) {
		// Check if we support wrm for this weapon
		if ( isDefined( level.wrm[ sWeapon ] ) ) {
			rangeModifier = getdvarx( level.wrm[ sWeapon ], "float", 215.0, 5.0, 215.0 );
		
	 		//check if target is out of range
	 		if(isplayer(eAttacker)){
		 		targetDist = distance(eAttacker.origin, self.origin)* 0.0254;
		 		
		 		if( targetDist > rangeModifier){
		 	 		PlayerInRange = 0 ;}
			}
		} else {
			// Just for testing. Remove this line on release version!
			//self iprintln( "No range defined for " + sWeapon );
		}		
	}
		return int( iDamage * PlayerInRange );
}


loadWRM()
{
	// Load all the weapons with their corresponding dvar controlling it
	level.wrm = [];

	// Assault class weapons
	level.wrm[ "m16_acog_mp" ] = "scr_wrm_m16";
	level.wrm[ "m16_gl_mp" ] = "scr_wrm_m16";
	level.wrm[ "m16_mp" ] = "scr_wrm_m16";
	level.wrm[ "m16_reflex_mp" ] = "scr_wrm_m16";
	level.wrm[ "m16_silencer_mp" ] = "scr_wrm_m16_silenced";

	level.wrm[ "ak47_acog_mp" ] = "scr_wrm_ak47";
	level.wrm[ "ak47_gl_mp" ] = "scr_wrm_ak47";
	level.wrm[ "ak47_mp" ] = "scr_wrm_ak47";
	level.wrm[ "ak47_reflex_mp" ] = "scr_wrm_ak47";
	level.wrm[ "ak47_silencer_mp" ] = "scr_wrm_ak47_silenced";

	level.wrm[ "m4_acog_mp" ] = "scr_wrm_m4";
	level.wrm[ "m4_gl_mp" ] = "scr_wrm_m4";
	level.wrm[ "m4_mp" ] = "scr_wrm_m4";
	level.wrm[ "m4_reflex_mp" ] = "scr_wrm_m4";
	level.wrm[ "m4_silencer_mp" ] = "scr_wrm_m4_silenced";

	level.wrm[ "g3_acog_mp" ] = "scr_wrm_g3";
	level.wrm[ "g3_gl_mp" ] = "scr_wrm_g3";
	level.wrm[ "g3_mp" ] = "scr_wrm_g3";
	level.wrm[ "g3_reflex_mp" ] = "scr_wrm_g3";
	level.wrm[ "g3_silencer_mp" ] = "scr_wrm_g3_silenced";

	level.wrm[ "g36c_acog_mp" ] = "scr_wrm_g36c";
	level.wrm[ "g36c_gl_mp" ] = "scr_wrm_g36c";
	level.wrm[ "g36c_mp" ] = "scr_wrm_g36c";
	level.wrm[ "g36c_reflex_mp" ] = "scr_wrm_g36c";
	level.wrm[ "g36c_silencer_mp" ] = "scr_wrm_g36c_silenced";

	level.wrm[ "m14_acog_mp" ] = "scr_wrm_m14";
	level.wrm[ "m14_gl_mp" ] = "scr_wrm_m14";
	level.wrm[ "m14_mp" ] = "scr_wrm_m14";
	level.wrm[ "m14_reflex_mp" ] = "scr_wrm_m14";
	level.wrm[ "m14_silencer_mp" ] = "scr_wrm_m14_silenced";

	level.wrm[ "mp44_mp" ] = "scr_wrm_mp44";


	// Special Ops class weapons
	level.wrm[ "mp5_acog_mp" ] = "scr_wrm_mp5";
	level.wrm[ "mp5_mp" ] = "scr_wrm_mp5";
	level.wrm[ "mp5_reflex_mp" ] = "scr_wrm_mp5";
	level.wrm[ "mp5_silencer_mp" ] = "scr_wrm_mp5_silenced";

	level.wrm[ "skorpion_acog_mp" ] = "scr_wrm_skorpion";
	level.wrm[ "skorpion_mp" ] = "scr_wrm_skorpion";
	level.wrm[ "skorpion_reflex_mp" ] = "scr_wrm_skorpion";
	level.wrm[ "skorpion_silencer_mp" ] = "scr_wrm_skorpion_silenced";

	level.wrm[ "uzi_acog_mp" ] = "scr_wrm_uzi";
	level.wrm[ "uzi_mp" ] = "scr_wrm_uzi";
	level.wrm[ "uzi_reflex_mp" ] = "scr_wrm_uzi";
	level.wrm[ "uzi_silencer_mp" ] = "scr_wrm_uzi_silenced";

	level.wrm[ "ak74u_acog_mp" ] = "scr_wrm_ak74u";
	level.wrm[ "ak74u_mp" ] = "scr_wrm_ak74u";
	level.wrm[ "ak74u_reflex_mp" ] = "scr_wrm_ak74u";
	level.wrm[ "ak74u_silencer_mp" ] = "scr_wrm_ak74u_silenced";

	level.wrm[ "p90_acog_mp" ] = "scr_wrm_p90";
	level.wrm[ "p90_mp" ] = "scr_wrm_p90";
	level.wrm[ "p90_reflex_mp" ] = "scr_wrm_p90";
	level.wrm[ "p90_silencer_mp" ] = "scr_wrm_p90_silenced";


	// Demolition class weapons
	level.wrm[ "m1014_grip_mp" ] = "scr_wrm_m1014";
	level.wrm[ "m1014_mp" ] = "scr_wrm_m1014";
	level.wrm[ "m1014_reflex_mp" ] = "scr_wrm_m1014";

	level.wrm[ "winchester1200_grip_mp" ] = "scr_wrm_winchester1200";
	level.wrm[ "winchester1200_mp" ] = "scr_wrm_winchester1200";
	level.wrm[ "winchester1200_reflex_mp" ] = "scr_wrm_winchester1200";


	// Heavy gunner class weapons
	level.wrm[ "saw_acog_mp" ] = "scr_wrm_saw";
	level.wrm[ "saw_grip_mp" ] = "scr_wrm_saw";
	level.wrm[ "saw_mp" ] = "scr_wrm_saw";
	level.wrm[ "saw_reflex_mp" ] = "scr_wrm_saw";

	level.wrm[ "rpd_acog_mp" ] = "scr_wrm_rpd";
	level.wrm[ "rpd_grip_mp" ] = "scr_wrm_rpd";
	level.wrm[ "rpd_mp" ] = "scr_wrm_rpd";
	level.wrm[ "rpd_reflex_mp" ] = "scr_wrm_rpd";

	level.wrm[ "m60e4_acog_mp" ] = "scr_wrm_m60e4";
	level.wrm[ "m60e4_grip_mp" ] = "scr_wrm_m60e4";
	level.wrm[ "m60e4_mp" ] = "scr_wrm_m60e4";
	level.wrm[ "m60e4_reflex_mp" ] = "scr_wrm_m60e4";


	// Sniper class weapons
	level.wrm[ "dragunov_acog_mp" ] = "scr_wrm_dragunov";
	level.wrm[ "dragunov_mp" ] = "scr_wrm_dragunov";

	level.wrm[ "m40a3_acog_mp" ] = "scr_wrm_m40a3";
	level.wrm[ "m40a3_mp" ] = "scr_wrm_m40a3";

	level.wrm[ "barrett_acog_mp" ] = "scr_wrm_barrett";
	level.wrm[ "barrett_mp" ] = "scr_wrm_barrett";

	level.wrm[ "remington700_acog_mp" ] = "scr_wrm_remington700";
	level.wrm[ "remington700_mp" ] = "scr_wrm_remington700";

	level.wrm[ "m21_acog_mp" ] = "scr_wrm_m21";
	level.wrm[ "m21_mp" ] = "scr_wrm_m21";


	// Handguns
	level.wrm[ "beretta_mp" ] = "scr_wrm_beretta";
	level.wrm[ "beretta_silencer_mp" ] = "scr_wrm_beretta_silenced";

	level.wrm[ "colt45_mp" ] = "scr_wrm_colt45";
	level.wrm[ "colt45_silencer_mp" ] = "scr_wrm_colt45_silenced";

	level.wrm[ "usp_mp" ] = "scr_wrm_usp";
	level.wrm[ "usp_silencer_mp" ] = "scr_wrm_usp_silenced";

	level.wrm[ "deserteagle_mp" ] = "scr_wrm_deserteagle";
	level.wrm[ "deserteaglegold_mp" ] = "scr_wrm_deserteagle";


	return;
}