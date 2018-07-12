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
	// Load the the module's dvars
	level.scr_de_dropweapon_on_arm_hit = getdvarx( "scr_de_dropweapon_on_arm_hit", "int", 0, 0, 3 );
	level.scr_de_dropweapon_chance = getdvarx( "scr_de_dropweapon_chance", "int", 50, 0, 100 );
	
	level.scr_de_falldown_on_leg_hit = getdvarx( "scr_de_falldown_on_leg_hit", "int", 0, 0, 2 );
	level.scr_de_falldown_chance = getdvarx( "scr_damage_effect_falldown_chance", "int", 50, 0, 100 );
	
	level.scr_de_shiftview_on_damage = getdvarx( "scr_de_shiftview_on_damage", "int", 0, 0, 50 );
	
	level.scr_de_break_ankle_on_fall = getdvarx( "scr_de_break_ankle_on_fall", "int", 0, 0, 75 );
	level.scr_de_slowdown_on_leg_hit = getdvarx( "scr_de_slowdown_on_leg_hit", "int", 0, 0, 75 );

	// Make sure we need to still stay here
	if ( level.scr_de_dropweapon_on_arm_hit == 0 && level.scr_de_falldown_on_leg_hit == 0 && level.scr_de_shiftview_on_damage == 0 && level.scr_de_break_ankle_on_fall == 0 && level.scr_de_slowdown_on_leg_hit == 0 )
		return;

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}

onPlayerSpawned()
{
	self thread onDamageTaken();
}

onDamageTaken()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	for(;;)
	{
		self waittill("damage_taken", eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

		// Make sure there was damage done
		if ( iDamage == 0 )
			continue;

		// Get the player's current weapon
		currentWeapon = self getCurrentWeapon();

		// Check if this a damage from a fall
		if ( sMeansOfDeath == "MOD_FALLING" ) {
			// Check if we need to slow down the player
			if ( level.scr_de_break_ankle_on_fall > 0 && iDamage > level.scr_de_break_ankle_on_fall ) {
				self thread openwarfare\_speedcontrol::setModifierSpeed( "_damageeffect_fall", 75 );
				self ExecClientCommand("gocrouch");
				self thread maps\mp\gametypes\_gameobjects::_disableSprint();
				self thread maps\mp\gametypes\_gameobjects::_disableJump();
				self iprintlnbold( &"OW_DE_BROKEN_ANKLE" );
			}			
			
		} else{
			// Check the location of the hit
			switch( sHitLoc )
			{
				case "gun":
				case "left_hand":
				case "right_hand":
					// Player was hit in the hands or the weapon. Check if we need to drop the player's weapon.
					if ( level.scr_de_dropweapon_on_arm_hit >= 1 ) {
						randomChance = randomIntRange( 0, 101 );
						if ( randomChance <= level.scr_de_dropweapon_chance ) {
							self playlocalsound("MP_hit_alert");
							self dropItem( currentWeapon );
						}
					}
					break;
	
				case "left_arm_lower":
				case "right_arm_lower":
					// Player was hit in the arm. Check if we need to drop the player's weapon.
					if ( level.scr_de_dropweapon_on_arm_hit >= 2 ) {
						randomChance = randomIntRange( 0, 101 );
						if ( randomChance <= level.scr_de_dropweapon_chance ) {
							self playlocalsound("MP_hit_alert");
							self dropItem( currentWeapon );
						}
					}
					break;
	
				case "left_arm_upper":
				case "right_arm_upper":
					// Player was hit in the arm. Check if we need to drop the player's weapon.
					if ( level.scr_de_dropweapon_on_arm_hit >= 3 ) {
						randomChance = randomIntRange( 0, 101 );
						if ( randomChance <= level.scr_de_dropweapon_chance ) {
							self playlocalsound("MP_hit_alert");
							self dropItem( currentWeapon );
						}
					}
					break;
	
				case "left_leg_upper":
				case "right_leg_upper":
					// Player was hit in the upper legs. Check if we need to slow him down.
					if ( level.scr_de_slowdown_on_leg_hit > 0 && iDamage >= level.scr_de_slowdown_on_leg_hit ) {
						self thread openwarfare\_speedcontrol::setModifierSpeed( "_damageeffect_leg", 50 );
					}
					break;
									
				case "left_leg_lower":
				case "left_foot":
				case "right_leg_lower":
				case "right_foot":
					// Player was hit in the lower legs. Check if we need to make the player fall to the ground.
					if ( level.scr_de_falldown_on_leg_hit > 0 ) {
						randomChance = randomIntRange( 0, 101 );
						if ( randomChance <= level.scr_de_falldown_chance ) {					
							self ExecClientCommand("gocrouch");
							self ExecClientCommand("goprone");
							if ( level.scr_de_falldown_on_leg_hit == 2 ) {
								self thread openwarfare\_speedcontrol::setModifierSpeed( "_damageeffect_leg", 50 );
								self thread maps\mp\gametypes\_gameobjects::_disableSprint();
								self thread maps\mp\gametypes\_gameobjects::_disableJump();
							}
						}
					}
					break;
			}

			// Check if we need to shift the player's view
			if ( level.scr_de_shiftview_on_damage > 0 &&  iDamage > level.scr_de_shiftview_on_damage ) {
				self shiftPlayerView( iDamage );
			}
		}
	}
}