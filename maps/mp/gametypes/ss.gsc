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
#include maps\mp\gametypes\_hud_util;
#include openwarfare\_utils;

/*
	Sharpshooter
	Objective: 	Reach the score limit or be the one with the highest score at the end of the match
	Map ends:	When one player reaches the score limit or time is up.
	Respawning:	No wait / Away from other players

	Level requirements
	------------------
		Spawnpoints:
			classname		mp_dm_spawn
			All players spawn from these. The spawnpoint chosen is dependent on the current locations of enemies at the time of spawn.
			Players generally spawn away from enemies.

		Spectator Spawnpoints:
			classname		mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.

	Level script requirements
	-------------------------
		Team Definitions:
			game["allies"] = "marines";
			game["axis"] = "opfor";
			Because Deathmatch doesn't have teams with regard to gameplay or scoring, this effectively sets the available weapons.

		If using minefields or exploders:
			maps\mp\_load::main();
*/


main()
{
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	// Additional variables that we'll be using
	level.scr_ss_available_weapons = toLower( getdvarx( "scr_ss_available_weapons", "string", "ak47_mp;ak74u_mp;g3_mp;g36c_mp;m4_mp;m14_mp;m16_mp;m60e4_mp;m1014_mp;mp5_mp;mp44_mp;p90_mp;rpd_mp;saw_mp;skorpion_mp;uzi_mp;winchester1200_mp" ) );
	level.scr_ss_available_weapons = strtok( level.scr_ss_available_weapons, ";" );
	
	level.scr_ss_weapon_switch_time = getdvarx( "scr_ss_weapon_switch_time", "int", 45, 30, 300 );
	level.scr_ss_explosives_special = getdvarx( "scr_ss_explosives_special", "int", 0, 0, 3 );
	
	level.scr_ss_specialty_slot1 = getdvarx( "scr_ss_specialty_slot1", "string", "specialty_fastreload" );
	if ( !issubstr( "specialty_null;specialty_bulletdamage;specialty_armorvest;specialty_fastreload;specialty_rof;specialty_gpsjammer;specialty_explosivedamage", level.scr_ss_specialty_slot1 ) ) {
		level.scr_ss_specialty_slot1 = "specialty_fastreload";
	}

	level.scr_ss_specialty_slot2 = getdvarx( "scr_ss_specialty_slot2", "string", "specialty_longersprint" );
	if ( !issubstr( "specialty_null;specialty_longersprint;specialty_bulletaccuracy;specialty_bulletpenetration;specialty_holdbreath;specialty_quieter", level.scr_ss_specialty_slot2 ) ) {
		level.scr_ss_specialty_slot2 = "specialty_longersprint";
	}

	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 0, 0, 0 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 1, 0, 500 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 0, 0, 5000 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 30, 0, 1440 );

	level.teamBased = false;

	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onLoadoutGiven = ::onLoadoutGiven;

	game["dialog"]["gametype"] = gameTypeDialog( "sharpshooter" );
	
}


onStartGameType()
{
	setClientNameMode("auto_change");

	maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OW_OBJECTIVES_SHARPSHOOTER" );
	maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OW_OBJECTIVES_SHARPSHOOTER" );

	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OW_OBJECTIVES_SHARPSHOOTER" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OW_OBJECTIVES_SHARPSHOOTER" );
	}
	else
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OW_OBJECTIVES_SHARPSHOOTER_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OW_OBJECTIVES_SHARPSHOOTER_SCORE" );
	}
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"OW_OBJECTIVES_SHARPSHOOTER_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"OW_OBJECTIVES_SHARPSHOOTER_HINT" );

	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_dm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_dm_spawn" );
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );
	
	allowed[0] = "dm";
	maps\mp\gametypes\_gameobjects::main(allowed);

	level.displayRoundEndText = true;
	level.QuickMessageToAll = true;
	
	thread startSharpshooter();
}


onSpawnPlayer()
{
	spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( spawnPoints );
	
	self spawn( spawnPoint.origin, spawnPoint.angles );
	self thread onPlayerDeath();
}


onPlayerDeath()
{
	self waittill("death");
	// Remove all the weapons from this player so nothing gets dropped
	self takeAllWeapons();	
}


onLoadoutGiven()
{
	// Give player Sharp shooter loadouts
	self giveSharpshooterLoadout( false );	
}


startSharpshooter()
{
	level endon ( "game_ended" );

	weaponsCyclingAvailable = level.scr_ss_available_weapons;
	level thread showCyclingCountDown();
		
	for (;;) {
		// Make a random weapon selection and assign it to everyone in the server
		newWeaponElement = randomIntRange( 0, weaponsCyclingAvailable.size );
		level.sharpshooterWeapon = weaponsCyclingAvailable[ newWeaponElement ];

		// Assign the new weapon to all the players
		for ( p = 0; p < level.players.size; p++ ) {
			player = level.players[p];
			
			if ( isDefined( player ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" ) {
				player thread giveSharpshooterLoadout( true );
			}
		}

		level notify( "cycling_complete" );
						
		// Check if this was the last weapon in the pool
		if ( weaponsCyclingAvailable.size == 1 ) {
			weaponsCyclingAvailable = level.scr_ss_available_weapons;
		} else {
			// Remove this element from the array (this ensures that we cycle through all the weapons)
			tempArray = [];
			for ( i = 0; i < weaponsCyclingAvailable.size; i++ ) {
				if ( i != newWeaponElement ) {
					tempArray[tempArray.size] = weaponsCyclingAvailable[i];
				}
			}
			weaponsCyclingAvailable = tempArray;
		}
		
		level waittill( "start_cycling" );
	}		
}


showCyclingCountDown()
{
	level endon ( "game_ended" );
	
	tickSounds = 5;
	
	while ( level.inPrematchPeriod ) wait (0.05);

	// Create the timer to show how much is left
	weaponCyclingCountDown = createServerTimer( "objective", 1.4 );
	weaponCyclingCountDown setPoint( "TOPRIGHT", "TOPRIGHT", 0, 0 );
	weaponCyclingCountDown.label = &"OW_SHARPSHOOTER_CLYCLING_IN";
	weaponCyclingCountDown.alpha = 1;
	weaponCyclingCountDown.archived = false;
	weaponCyclingCountDown.hideWhenInMenu = true;

	for (;;) {
		timeLeft = level.scr_ss_weapon_switch_time;
		weaponCyclingCountDown.color = (1,1,1);
		weaponCyclingCountDown setTimer( timeLeft );
		
		while ( timeLeft > 0 ) {
			
			// Do we need to play a tick sound?
			if ( timeLeft <= tickSounds ) {
				weaponCyclingCountDown.color = (1,0.5,0);
				for ( p = 0; p < level.players.size; p++ ) {
					player = level.players[p];
					if ( isDefined( player ) ) {
						player playLocalSound( "ui_mp_suitcasebomb_timer" );
					}				
				}
			}
			
			wait (1);
			
			// If there was a timeout called during the wait time we'll disregard the last second
			if ( level.inTimeoutPeriod ) {
				weaponCyclingCountDown.alpha = 0;
				// Wait for the timeout to be over and reset the clock
				while ( level.inTimeoutPeriod ) wait (0.05);
				weaponCyclingCountDown setTimer( timeLeft );
				weaponCyclingCountDown.alpha = 1;
			} else {
				timeLeft--;
			}
		}
			
		level notify( "start_cycling" );
		level waittill( "cycling_complete" );
	}	
}


giveSharpshooterLoadout( weaponCycling )
{
	// Play sound to the player is the weapon is cycling
	if ( weaponCycling ) {
		self playLocalSound( "mp_last_stand" );
	}
	
	// Remove all weapons and perks from the player
	self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
	self takeAllWeapons();

	// Make sure the player gets any hardpoint that he/she already had
	if ( isDefined( self.pers["hardPointItem"] ) ) {
		self maps\mp\gametypes\_hardpoints::giveHardpointItem( self.pers["hardPointItem"] );
	}
	
	// Only change the perks and set the speed when the player spawns but not when the weapon is cycling
	if ( !weaponCycling ) {
		// Give the player fixed specialties and reset the speed no matter what the class
		self clearPerks();
		self.specialty = [];
		self.specialty[0] = "specialty_null";
		if ( self.specialty[0] != "specialty_null" )
			self setPerk( self.specialty[0] );
			
		self.specialty[1] = level.scr_ss_specialty_slot1;
		if ( self.specialty[1] != "specialty_null" )
			self setPerk( self.specialty[1] );
		
		self.specialty[2] = level.scr_ss_specialty_slot2;
		if ( self.specialty[2] != "specialty_null" )
			self setPerk( self.specialty[2] );
		
		self thread openwarfare\_speedcontrol::setBaseSpeed( getdvarx( "class_specops_movespeed", "float", 1.0, 0.5, 1.5 ) );
	}

	// Check if we should also give a special grenade
	nadeType = "none";
	switch ( level.scr_ss_explosives_special ) {
		case 1:
			nadeType = "smoke_grenade_mp";
			self setOffhandSecondaryClass("smoke");
			break;
		case 2:
			nadeType = "flash_grenade_mp";
			self setOffhandSecondaryClass("flash");
			break;
		case 3:
			nadeType = "concussion_grenade_mp";
			self setOffhandSecondaryClass("smoke");
			break;
	}
	if ( nadeType != "none" ) {
		self giveWeapon( nadeType );
		self setWeaponAmmoClip( nadeType, 1 );
	}	

	self giveWeapon( level.sharpshooterWeapon );
	self giveMaxAmmo( level.sharpshooterWeapon );
	
	if ( !weaponCycling ) {
		self setSpawnWeapon( level.sharpshooterWeapon );
	}
	
	self switchToWeapon( level.sharpshooterWeapon );	
	
	// Enable the new weapon
	self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
}