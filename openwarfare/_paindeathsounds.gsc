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
	level.scr_health_hurt_sound = getdvarx( "scr_health_hurt_sound", "int", 1, 0, 1 );
	level.scr_health_pain_sound = getdvarx( "scr_health_pain_sound", "int", 0, 0, 10 );
	level.scr_health_death_sound = getdvarx( "scr_health_death_sound", "int", 0, 0, 1 );

	if ( level.scr_health_hurt_sound == 0 && level.scr_health_pain_sound == 0 && level.scr_health_death_sound == 0 )
		return;

	level.healthOverlayCutoff = 0.55;

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onPlayerKilled", ::onPlayerKilled );
}

onPlayerSpawned()
{
	// Set which kind of voice this player is going to do when dying
	switch ( self.pers["team"] ) {
		case "allies":
			switch ( game["allies"] ) {
				case "sas":
					self.myDeathSound = "generic_death_british_";
					self.myPainSound = "generic_pain_british_";
					break;
				case "marines":
				default:
					self.myDeathSound = "generic_death_american_";
					self.myPainSound = "generic_pain_american_";
					break;
			}
			break;
		case "axis":
			switch ( game["axis"] ) {
				case "russian":
					self.myDeathSound = "generic_death_russian_";
					self.myPainSound = "generic_pain_russian_";
					break;
				case "arab":
				case "opfor":
				default:
					self.myDeathSound = "generic_death_arab_";
					self.myPainSound = "generic_pain_arab_";
					break;
			}
			break;
		default:
			self.myDeathSound = "generic_death_american_";
			self.myPainSound = "generic_pain_american_";
			break;
	}
	// Assign a random number between 1 and 8 (sound aliases for go from 1 to 8).
	self.myDeathSound = self.myDeathSound + randomIntRange(1, 9);
	self.myPainSound = self.myPainSound + randomIntRange(1, 9);

	// Initialize the threads that will handle the sound for us
	self thread playerBreathingSound( self.maxhealth );
	self thread playerPainSound();
}


onPlayerKilled()
{
	// Make the death sound for this player
	if ( level.scr_health_death_sound == 1 && ( !isDefined( self.sMeansOfDeath ) || self.sMeansOfDeath != "MOD_HEAD_SHOT" ) ) {
		self playSound( self.myDeathSound );
	}
}


playerBreathingSound( maxHealth )
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	// Are pain sounds enabled? If bleeding is enabled then let that routine handle the sounds instead
	if ( level.scr_health_hurt_sound == 0 || ( level.scr_healthsystem_bleeding_enable && level.scr_healthregen_method == 0 ) )
		return;

	player = self;

	// We'll use this variable to control which kind of sound we should make
	healthCap = maxHealth * level.healthOverlayCutoff;

	veryHurt = false;

	for (;;)
	{
		wait (0.05);

		// Player is dead.
		if ( !isDefined( player ) || player.health <= 0 ) {
			return;
		}

		// Player has more than 99% of the health restored... We shouldn't make any more sounds.
		if ( player.health >= ( maxHealth * 0.99 ) ) {
			if ( !veryHurt ) {
				continue;
			} else {
				veryHurt = false;
			}
		}

		// Check which sound we should play
		if ( player.health < healthCap ) {
			playSound = "breathing_hurt";
			veryHurt = true;
		} else {
			playSound = "breathing_better";
		}

		// Play the sound and wait some standard amount of time between each one
		if ( level.gametype != "ftag" || !self.freezeTag["frozen"] )
			player playLocalSound( playSound );
			
		wait 0.784;
		wait ( 0.5 + randomfloat( 0.8 ) );
	}
}


playerPainSound()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	if ( level.scr_health_pain_sound == 0 )
		return;

	for (;;)
	{
		self waittill("damage_taken", eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

		// Make sure the player was damaged
		if ( iDamage > 0 ) {
			playPainSound = randomIntRange(1, level.scr_health_pain_sound + 1 );

			// We only play the sound when the random value is 1
			if ( playPainSound == 1 ) {
				self playSound( self.myPainSound );
			}
		}
	}
}

