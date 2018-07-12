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
	level.scr_wlm_enabled = getdvarx( "scr_wlm_enabled", "int", 0, 0, 1 );

	// If weapon damage modifier is disabled then there's nothing else to do here
	if ( level.scr_wlm_enabled == 0 )
		return;

	thread loadWLM();

	return;
}


wlmDamage( iDamage, sHitLoc, sMeansOfDeath )
{
	// By default we won't change the iDamage value
	damageModifier = 1.0;

	// Make sure it was not a knife kill 
	if ( sMeansOfDeath != "MOD_MELEE" ) {
		// Check if we support wdm for this weapon
		if ( isDefined( level.wlm[ sHitLoc ] ) ) {
			damageModifier = getdvarx( level.wlm[ sHitLoc ], "float", 100.0, 5.0, 200.0 ) / 100;
		} else {
			// Just for testing. Remove this line on release version!
			//iprintln( "No damage defined for " + sHitLoc );
		}
	}
	
	return int( iDamage * damageModifier );
}


loadWLM()
{
	// Load all the weapons with their corresponding dvar controlling it
	level.wlm = [];

	// Different hit locations
	level.wlm[ "left_arm_upper" ] = "scr_wlm_upper_arm";
	level.wlm[ "right_arm_upper" ] = "scr_wlm_upper_arm";
	
	level.wlm[ "left_arm_lower" ] = "scr_wlm_lower_arm";
	level.wlm[ "right_arm_lower" ] = "scr_wlm_lower_arm";
	
	level.wlm[ "left_hand" ] = "scr_wlm_hand";
	level.wlm[ "right_hand" ] = "scr_wlm_hand";
	
	level.wlm[ "left_leg_upper" ] = "scr_wlm_upper_leg";
	level.wlm[ "right_leg_upper" ] = "scr_wlm_upper_leg";
	
	level.wlm[ "left_leg_lower" ] = "scr_wlm_lower_leg";
	level.wlm[ "right_leg_lower" ] = "scr_wlm_lower_leg";
	
	level.wlm[ "left_foot" ] = "scr_wlm_foot";
	level.wlm[ "right_foot" ] = "scr_wlm_foot";
	
	level.wlm[ "head" ] = "scr_wlm_head";
	level.wlm[ "neck" ] = "scr_wlm_neck";
	level.wlm[ "torso_upper" ] = "scr_wlm_upper_torso";
	level.wlm[ "torso_lower" ] = "scr_wlm_lower_torso";				
	
	return;
}

