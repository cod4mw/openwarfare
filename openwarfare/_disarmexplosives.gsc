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

#include maps\mp\_utility;
#include common_scripts\utility;

#include openwarfare\_eventmanager;
#include openwarfare\_utils;

init()
{
	// Get the main module's dvar
	level.scr_explosives_allow_disarm = getdvarx( "scr_explosives_allow_disarm", "int", 0, 0, 1 );

	// If disarm explosives is not enabled then there's nothing else to do here
	if ( level.scr_explosives_allow_disarm == 0 )
		return;

	// Get the module's dvars
	level.scr_explosives_disarm_time = getdvarx( "scr_explosives_disarm_time", "float", 5, 0.5, 30.0 );

	precacheString( &"OW_EXPLOSIVE_DISARMING" );
	precacheString( &"OW_EXPLOSIVE_RETRIEVING" );

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onPlayerKilled", ::onPlayerKilled );
}

onPlayerSpawned()
{
	// Check if this player spawned with explosives
	if ( self hasWeapon( "c4_mp" ) || self hasWeapon( "claymore_mp" ) ) {
		// Save that this player had explosives
		if ( self hasWeapon( "c4_mp" ) ) {
			self.hadExplosive["c4_mp"] = true;
			self.hadExplosive["claymore_mp"] = false;
		} else {
			self.hadExplosive["c4_mp"] = false;
			self.hadExplosive["claymore_mp"] = true;
		}
		self thread checkExplosivesUtilization();
	} else {
		self.hadExplosive["c4_mp"] = false;
		self.hadExplosive["claymore_mp"] = false;
	}
}

onPlayerKilled()
{
	if ( isDefined( self.checkDisarming ) )
		self.checkDisarming = false;

	if ( isDefined( self.isDisarming ) ) {
		self.isDisarming = false;
		self updateSecondaryProgressBar( undefined, undefined, true, undefined );
	}
}

checkExplosivesUtilization()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("unfrozen_player");
	level endon( "game_ended" );

	for (;;)
	{
		// Wait for the player to plant an explosive
		self waittill("grenade_fire", explosiveEnt, weaponName);
		// Make sure it wasn't a grenade or something else
		if ( weaponName == "c4_mp" || weaponName == "claymore_mp" ) {
			// Monitor this explosive device
			explosiveEnt.weaponName = weaponName;
			explosiveEnt thread explosiveMonitor();
		}
	}
}


explosiveMonitor()
{
	self endon( "death" );
	level endon( "game_ended" );

	// Wait until the explosive is stationary (planted)
	self maps\mp\gametypes\_weapons::waitTillNotMoving();

	if ( isDefined( self ) ) {
		// Create a trigger_radius around the explosive
		self.triggerRadius = spawn( "trigger_radius", self.origin + ( 0, 0, -40 ), 0, 35, 80 );
		self thread deleteTriggerOnDeath();

		for (;;)
		{
			wait (0.05);

			// Wait until a player has entered my radius
			self.triggerRadius waittill("trigger", player);

			// A player is within my radius, let's see what's done
			if ( !isDefined( player.checkDisarming ) || !player.checkDisarming ) {
				player thread checkForDisarming( self );
			}
		}
	}
}

// self is explosive's trigger
deleteTriggerOnDeath()
{
	triggerRadius = self.triggerRadius;
	
	// Wait for destruction of the explosive
	self waittill("death");

	// Delete the radius entity
	triggerRadius delete();
}


checkForDisarming( explosiveEnt )
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	self.checkDisarming = true;

	// Calculate the time it will take this player to disarm the explosive
	disarmAdjust = 1.0;
	// First check if the player is the owner of the explosive (reduce time by 50%)
	if ( explosiveEnt.owner == self ) {
		disarmAdjust -= 0.50;
	} else {
		// It's not the owner. Let's check if the player is in a different team (increase time by 50%)
		if ( !level.teamBased || !isDefined( explosiveEnt.owner ) || explosiveEnt.owner.pers["team"] != self.pers["team"] ) {
			disarmAdjust += 0.50;
		}
		// Let's see if the player is an expert on this explosive (reduce time by 25% )
		if ( self.hadExplosive[explosiveEnt.weaponName] ) {
			disarmAdjust -= 0.25;
		}
	}
	// Let's see if the player has the specialty_detectexplosive perk (reduce time by 10%)
	if (self hasPerk( "specialty_detectexplosive" ) ) {
		disarmAdjust -= 0.10;
	}

	// Check if it's going to be a disarming or retrieving
	if ( self.hadExplosive[explosiveEnt.weaponName] ) {
		ammoCount = self getWeaponAmmoStock( explosiveEnt.weaponName );
		maxAmmo = weaponMaxAmmo( explosiveEnt.weaponName );
		if ( ammoCount < maxAmmo ) {
			typeOfAction = "retrieving";
		} else {
			typeOfAction = "disarming";
		}
	} else {
		typeOfAction = "disarming";
	}


	disarmTime = level.scr_explosives_disarm_time * disarmAdjust * 1000;
	startedTime = 0;
	explosiveDisarmed = false;

	// Loop as long as the player is within the explosive's radius
	while ( !explosiveDisarmed && isDefined( explosiveEnt.triggerRadius ) && self isTouching( explosiveEnt.triggerRadius ) ) {
		// Just a wait so the thread doesn't kill the game
		wait (0.05);

		while ( !explosiveDisarmed && isDefined( explosiveEnt.triggerRadius ) && self isTouching( explosiveEnt.triggerRadius ) && ( self useButtonPressed() || level.inTimeoutPeriod ) && isDefined( explosiveEnt ) && self IsLookingAt( explosiveEnt )  && ( !isDefined( self.isPlanting ) || !self.isPlanting ) && ( !isDefined( self.isDefusing ) || !self.isDefusing ) ) {
			// Disable the player's weapons when the player starts disarming
			if ( startedTime == 0 ) {
				startedTime = openwarfare\_timer::getTimePassed();
				self.isDisarming = true;
				self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
				explosiveEnt.disarmedBy = self;
			}

			wait (0.01);
			timeDifference = openwarfare\_timer::getTimePassed() - startedTime;

			// Update the progress bar
			if ( typeOfAction == "disarming" )
				self updateSecondaryProgressBar( timeDifference, disarmTime, false, &"OW_EXPLOSIVE_DISARMING" );
			else
				self updateSecondaryProgressBar( timeDifference, disarmTime, false, &"OW_EXPLOSIVE_RETRIEVING" );

			// Check if we have a complete disarm of the explosive
			if ( timeDifference >= disarmTime ) {
				if ( level.hardcoreMode == 0 ) {
					if ( typeOfAction == "disarming" )
						self iprintln( &"OW_EXPLOSIVE_DISARMED" );
					else
						self iprintln( &"OW_EXPLOSIVE_RETRIEVED" );
				}

				// Add the explosive to the player's inventory as long as the player has the expertise to handle it and
				// doesn't have the maximum amount of ammo already
				if ( self.hadExplosive[explosiveEnt.weaponName] ) {
					ammoCount = self getWeaponAmmoStock( explosiveEnt.weaponName );
					// If ammo count is 0 then we need to give the weapon to the player again
					if ( ammoCount == 0 ) {
						self giveWeapon( explosiveEnt.weaponName );
						self setActionSlot( 3, "weapon", explosiveEnt.weaponName );
					}

					maxAmmo = weaponMaxAmmo( explosiveEnt.weaponName );
					if ( ammoCount < maxAmmo ) {
						self setWeaponAmmoStock( explosiveEnt.weaponName, ammoCount + 1 );
						self playLocalSound( "oldschool_pickup" );
					}
				}
				// The last thing we need to do is delete the explosive
				if ( isDefined( explosiveEnt ) ) {
					explosiveEnt delete();
					explosiveDisarmed = true;
				}
			}
		}
		// The player stopped pressing the use key, stop looking at the explosive, moved out of the trigger zone,
		// the explosive was detonated, or it successfully disarmed the explosive.
		if ( startedTime > 0 ) {
			startedTime = 0;
			self.isDisarming = false;
			self updateSecondaryProgressBar( undefined, undefined, true, undefined );
			// Enable weapons again
			self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
		}
	}

	self.checkDisarming = false;
}





