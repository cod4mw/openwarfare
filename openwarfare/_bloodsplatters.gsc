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
	// Get the main module's dvars
	level.scr_show_headshot_blood_splatters = getdvarx( "scr_show_headshot_blood_splatters", "int", 0, 0, 1 );
	level.scr_show_knifed_blood_splatters = getdvarx( "scr_show_knifed_blood_splatters", "int", 0, 0, 1 );
	level.scr_show_general_blood_splatters = getdvarx( "scr_show_general_blood_splatters", "int", 0, 0, 1 );

	// If none of the blood splatters are active then there's nothing to do here
	if ( level.scr_show_headshot_blood_splatters == 0 && level.scr_show_knifed_blood_splatters == 0 && level.scr_show_general_blood_splatters == 0 )
		return;

	// Precache the headshot shader if blood splatter for headshots is active
	if ( level.scr_show_headshot_blood_splatters == 1 ) {
		precacheShader( "hud_headshot_kill" );
	}

	// Precache the knife shader if blood splatter for getting knifed is active
	if ( level.scr_show_knifed_blood_splatters == 1 ) {
		precacheShader( "hud_knife_kill" );
	}

	// Precache the blood stain shaders if blood splatters for taking general damage is active
	if ( level.scr_show_general_blood_splatters == 1 ) {
		precacheShader( "hud_blood_stain_1" );
		precacheShader( "hud_blood_stain_2" );
		precacheShader( "hud_blood_stain_3" );
		precacheShader( "hud_blood_stain_4" );
	}

	// Number of blood splatters and time they will show
	level.bloodSplattersQuantity = 8;
	level.bloodTime = 1.5;

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnected()
{
	self.ownBloodSplatters = [];
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onPlayerKilled", ::onPlayerKilled );
}

onPlayerSpawned()
{
	self.lastStandBlood = false;

	// Destroy and initialize hud element for headshot or knife kill
	if ( level.scr_show_headshot_blood_splatters == 1 || level.scr_show_knifed_blood_splatters == 1 ) {
		// Clean all the blood from players view on spawn
		if ( isDefined( self.hud_special_blood_effect ) )
			self.hud_special_blood_effect destroy();
	}

	// Check if blood splatters are active
	if ( level.scr_show_general_blood_splatters == 1 ) {
		if ( isDefined( self.ownBloodSplatters ) ) {
			// Destroy and initialize hud elements for blood stains
			for ( idx = 0; idx < level.bloodSplattersQuantity; idx++ ) {
				// Destroy the hud element
				if ( isDefined( self.ownBloodSplatters[ idx ] ) ) {
					self.ownBloodSplatters[ idx ] destroy();
				}
			}
		}
		self.ownBloodSplatters = [];
	}

	if ( level.scr_show_general_blood_splatters == 1 ) {
		self thread onPlayerDamaged();
	}		
}


onPlayerKilled()
{
	// Show blood stains no matter what when they die if they are active and the player was not in LastStand
	if ( level.scr_show_general_blood_splatters == 1 && !self.lastStandBlood ) {
		for ( idx = 0; idx < level.bloodSplattersQuantity; idx++ ) {
			whichStain = ( idx % 4 ); whichStain++;
			self thread bloodSplatter( idx, "hud_blood_stain_" + whichStain, ( whichStain % 2 ), 150 );
		}
	}


	if ( isDefined( self.sMeansOfDeath ) ) {
		// Check if we need to create the HUD element
		if ( ( self.sMeansOfDeath == "MOD_HEAD_SHOT" && level.scr_show_headshot_blood_splatters == 1 ) || ( self.sMeansOfDeath == "MOD_MELEE" && level.scr_show_knifed_blood_splatters == 1 ) ) {
					self.hud_special_blood_effect = newClientHudElem( self );
					self.hud_special_blood_effect.horzAlign = "center";
					self.hud_special_blood_effect.vertAlign = "middle";
					self.hud_special_blood_effect.alignx = "center";
					self.hud_special_blood_effect.aligny = "bottom";
					self.hud_special_blood_effect.sort = -1;
					self.hud_special_blood_effect.archived = true;
		}
		
		// Check if the player died with a headshot or under the knife
		switch ( self.sMeansOfDeath )
		{
			case "MOD_HEAD_SHOT":
				if ( level.scr_show_headshot_blood_splatters == 1 ) {
					self.hud_special_blood_effect setShader( "hud_headshot_kill", 450, 450 );
					self.hud_special_blood_effect.x = 0;
					self.hud_special_blood_effect.y = 210;
					self.hud_special_blood_effect.alpha = 1;
					self.hud_special_blood_effect fadeOverTime( level.bloodTime );
					self.hud_special_blood_effect.alpha = 0;
				}
				break;
			case "MOD_MELEE":
				if ( level.scr_show_knifed_blood_splatters == 1 ) {
					self.hud_special_blood_effect setShader( "hud_knife_kill", 512, 128);
					self.hud_special_blood_effect.x = 0;
					self.hud_special_blood_effect.y = 0;
					self.hud_special_blood_effect.alpha = 1;
					self.hud_special_blood_effect fadeOverTime( level.bloodTime );
					self.hud_special_blood_effect.alpha = 0;
				}
				break;
		}
	}

	// Make sure we clean this OpenWarfare create var
	self.sMeansOfDeath = undefined;
}


onPlayerDamaged()
{
	self endon("disconnect");
	self endon("death");

	for (;;)
	{
		self waittill("damage_taken", eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

		healthRatio = self.health / self.maxhealth;

		// The more damage the more blood stains and the more blood stains the bigger those blood stains
		checkHealth = 1.0;
		healthInterval = 1.0 / level.bloodSplattersQuantity;
		splatterSize = 176;
		for ( idx = 0; idx < level.bloodSplattersQuantity; idx++ ) {
			whichStain = ( idx % 4 ); whichStain++;
			if ( healthRatio < checkHealth ) {
				self thread bloodSplatter( idx, "hud_blood_stain_" + whichStain, self.lastStandBlood, splatterSize );
			}
			checkHealth -= healthInterval;
			splatterSize += 10;
		}
	}
}


bloodSplatter( hud_id, bloodShader, lastStand, shaderSize )
{
	// Check if this element is already defined
	if ( !isDefined( self.ownBloodSplatters[ hud_id ] ) ) {
		// Create a new hud element with the certain default values
		newBlood = newClientHudElem( self );
		self.ownBloodSplatters[ hud_id ] = newBlood;
		newBlood.alignx = "left";
		newBlood.aligny = "top";
		newBlood.sort = -3;
		newBlood.archived = true;
		newBlood.fadedTime = 0;

		// Make sure the splatters in last stand or when dead are bigger
		if ( lastStand ) {
			shaderWidthHeight = 246 + randomint( 10 );
		} else {
			shaderWidthHeight = shaderSize + randomint( 10 );
		}
		// Calculate the position of the splatter ramdonly once we have its size
		shaderX = randomint( 640 - shaderWidthHeight );
		shaderY = randomint( 480 - shaderWidthHeight );
	
		// Set the coordinates for the hud element
		newBlood.x = shaderX;
		newBlood.y = shaderY;
		newBlood.alpha = 1;
		newBlood setShader( bloodShader, shaderWidthHeight, shaderWidthHeight );
	
		// Extend the fade over time for LastStand
		if ( lastStand ) {
			newBlood fadeOverTime( level.bloodTime * 3 );
		} else {
			newBlood fadeOverTime( level.bloodTime );
		}
		newBlood.alpha = 0;
		wait ( level.bloodTime );
		if ( isDefined( newBlood ) )
			newBlood destroy();
	}	

	return;
}