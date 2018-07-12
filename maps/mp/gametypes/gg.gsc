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
	Gun Game
	Objective: 	Move up weapon levels by eliminating other players
	Map ends:	When one player reaches the maximum weapon level and gets the final kills
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
	level.scr_gg_weapon_order = toLower( getdvarx( "scr_gg_weapon_order", "string", "beretta_mp;colt45_mp;usp_mp;deserteagle_mp;winchester1200_mp;m1014_mp;skorpion_mp;uzi_mp;ak74u_mp;mp5_mp;p90_mp;m14_mp;g3_mp;m16_mp;ak47_mp;g36c_mp;m4_mp;rpd_mp;m60e4_mp;frag_grenade_mp:1;knife_mp:1" ) );
	level.scr_gg_handicap_on = getdvarx( "scr_gg_handicap_on", "int", 2, 0, 2 );
	
	level.scr_gg_nade_knife_weapon = toLower( getdvarx( "scr_gg_nade_knife_weapon", "string", "c4_mp:0" ) );
	level.scr_gg_nade_knife_weapon = strtok( level.scr_gg_nade_knife_weapon, ":" );
	
	level.scr_gg_explosives_special = getdvarx( "scr_gg_explosives_special", "int", 0, 0, 3 );
	level.scr_gg_extra_explosives = getdvarx( "scr_gg_extra_explosives", "int", 1, 0, 1 );
	level.scr_gg_explosives_refresh = getdvarx( "scr_gg_explosives_refresh", "float", 10, 0, 30 );
	
	level.scr_gg_kills_per_lvl = getdvarx( "scr_gg_kills_per_lvl", "int", 2, 1, 10 );
	level.scr_gg_death_penalty = getdvarx( "scr_gg_death_penalty", "int", 5, 0, 10 );
	level.scr_gg_knifed_penalty = getdvarx( "scr_gg_knifed_penalty", "int", 0, 0, 1 );
	
	level.scr_gg_refill_on_kill = getdvarx( "scr_gg_refill_on_kill", "int", 1, 0, 1 );
	level.scr_gg_knife_pro = getdvarx( "scr_gg_knife_pro", "int", 0, 0, 3 );	
	
	level.scr_gg_auto_levelup = getdvarx( "scr_gg_auto_levelup", "int", 0, 0, 2 );	
	level.scr_gg_auto_levelup_time = getdvarx( "scr_gg_auto_levelup_time", "float", 60, 30, 300 );	
	
	level.scr_gg_specialty_slot1 = getdvarx( "scr_gg_specialty_slot1", "string", "specialty_fastreload" );
	if ( !issubstr( "specialty_null;specialty_bulletdamage;specialty_armorvest;specialty_fastreload;specialty_rof;specialty_gpsjammer;specialty_explosivedamage", level.scr_gg_specialty_slot1 ) ) {
		level.scr_gg_specialty_slot1 = "specialty_fastreload";
	}

	level.scr_gg_specialty_slot2 = getdvarx( "scr_gg_specialty_slot2", "string", "specialty_longersprint" );
	if ( !issubstr( "specialty_null;specialty_longersprint;specialty_bulletaccuracy;specialty_bulletpenetration;specialty_holdbreath;specialty_quieter", level.scr_gg_specialty_slot2 ) ) {
		level.scr_gg_specialty_slot2 = "specialty_longersprint";
	}

	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 0, 0, 0 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 1, 1, 1 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 0, 0, 0 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 0, 0, 1440 );

	level.teamBased = false;

	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onLoadoutGiven = ::onLoadoutGiven;
	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onTimeLimit = ::onTimeLimit;

	game["dialog"]["gametype"] = "gungame";
	
	level thread onPlayerConnected();
}


onPlayerConnected()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread handiCap();
	}
}


onPrecacheGameType()
{
	// Load all the allowed weapons with their respective shaders
	loadAllowedWeapons();

	// Load the weapons order and their custom kills if it has been defined
	game["gunGameLevels"] = [];
	weaponsOrder = strtok( level.scr_gg_weapon_order, ";" );
	for ( i=0; i < weaponsOrder.size; i++ ) {
		// Get the next element on the array
		newElement = game["gunGameLevels"].size;
		
		// Split the string into weapon name and custom kills
		customKills = strtok( weaponsOrder[i], ":" );
		
		// Make sure this weapon can be used
		if ( isDefined( game["gunGameWeapons"][ customKills[0] ] ) ) {
			game["gunGameLevels"][ newElement ]["weapon"] = customKills[0];
			if ( isDefined( customKills[1] ) ) {
				game["gunGameLevels"][ newElement ]["kills"] = int(customKills[1]);
			} else {
				game["gunGameLevels"][ newElement ]["kills"] = level.scr_gg_kills_per_lvl;
			}
		}
				
		// Make sure we don't load more than 36 elements
		if ( newElement == 35 ) {
			break;
		}
	}	
}


onStartGameType()
{
	setClientNameMode("auto_change");

	maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OW_GUNGAME_OBJECTIVES" );
	maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OW_GUNGAME_OBJECTIVES" );

	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OW_GUNGAME_OBJECTIVES" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OW_GUNGAME_OBJECTIVES" );
	}
	else
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OW_GUNGAME_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OW_GUNGAME_SCORE" );
	}
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"OW_GUNGAME_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"OW_GUNGAME_HINT" );

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
}


onSpawnPlayer()
{
	spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( spawnPoints );

	self spawn( spawnPoint.origin, spawnPoint.angles );
	
	// Show the player the level weapon, the levels left and the kills left
	self thread showGunGameInfo();
	self thread onPlayerDeath();
	
	// Monitor use of grenades if we need to give player grenades every often when he runs out
	if ( level.scr_gg_explosives_refresh != 0 ) {
		self thread watchGrenadesUsage();
		self thread watchRocketLauncherUsage();
	}
}


onPlayerDeath()
{
	self waittill("death");
	// Remove all the weapons from this player so nothing gets dropped
	self takeAllWeapons();	
}


onLoadoutGiven()
{
	// Give player GunGame loadouts
	self giveGunGameLevelLoadout();	
}


onTimeLimit()
{
	// Search for the player with the highest level/kills
	winningPlayer = undefined;
	for ( i = 0; i < level.players.size; i++ ) {
		player = level.players[i];		
		if ( isDefined( player ) && isDefined( player.gunGame ) ) {
			if ( !isDefined( winningPlayer ) || ( winningPlayer.gunGame["level"] < player.gunGame["level"] || ( winningPlayer.gunGame["level"] == player.gunGame["level"] && winningPlayer.gunGame["kills"] < player.gunGame["kills"] ) ) ) {
				winningPlayer = player;
			}
		}				
	}	
	
	// Check if we have a winner
	if ( isDefined( winningPlayer ) ) {
		logString( "time limit, win: " + winningPlayer.name );
	} else {
		logString( "time limit, tie" );
	}
	maps\mp\gametypes\_globallogic::endGame( winningPlayer, game["strings"]["time_limit_reached"] );
}


handiCap()
{
	self.gunGame = [];
	
	// Handicap not enabled
	if ( level.scr_gg_handicap_on == 0 ) {
		self.gunGame["level"] = 0;
	
	// Average handicap
	} else if ( level.scr_gg_handicap_on == 1 ) {
		gunGameLevel = 0;
		gunGameQty = 0;
		for ( i = 0; i < level.players.size; i++ ) {
			player = level.players[i];		
			if ( isDefined( player ) && player != self && isDefined( player.gunGame ) ) {
				gunGameLevel += player.gunGame["level"];
				gunGameQty++;
			}				
		}
		// Make sure we had at least one player
		if ( gunGameQty > 0 ) {
			gunGameLevel = int( gunGameLevel / gunGameQty );
		}
		self.gunGame["level"] = gunGameLevel;		
	
	// Lowest handicap
	} else if ( level.scr_gg_handicap_on == 2 ) {
		lowestGunGameLevel = undefined;
		for ( i = 0; i < level.players.size; i++ ) {
			player = level.players[i];		
			if ( isDefined( player ) && player != self && isDefined( player.gunGame ) ) {
				if ( !isDefined( lowestGunGameLevel ) || player.gunGame["level"] < lowestGunGameLevel ) {
					lowestGunGameLevel = player.gunGame["level"];
				}
			}				
		}
		// Make sure we had at least one player
		if ( !isDefined( lowestGunGameLevel ) )
			lowestGunGameLevel = 0;
			
		self.gunGame["level"] = lowestGunGameLevel;				
	}
	
	// Save other values like the kills needed for this level and kills/deaths
	self setRank( self.gunGame["level"] );
	self.gunGame["lvl_kills"] = game["gunGameLevels"][ self.gunGame["level"] ]["kills"];
	self.gunGame["kills"] = 0;
	self.gunGame["deaths"] = 0;	

		
	// Check if auto levelup is enabled
	if ( level.scr_gg_auto_levelup > 0 ) {
		self thread autoLevelUp();
	}
}


autoLevelUp()
{
	self endon("disconnect");
	
	for (;;)
	{
		wait (0.05);

		oldLevel = self.gunGame["level"];
		nextLevelUp = openwarfare\_timer::getTimePassed() + level.scr_gg_auto_levelup_time * 1000;
		
		while ( openwarfare\_timer::getTimePassed() < nextLevelUp && oldLevel == self.gunGame["level"] && self.pers["team"] != "spectator" )
			wait (0.5);
			
		// Make sure the player didn't change the level and he/she is not in the last level already
		if ( oldLevel == self.gunGame["level"] && oldLevel < game["gunGameLevels"].size - 1 && self.pers["team"] != "spectator" ) {
			if ( level.scr_gg_auto_levelup == 1 ) {
				// Increase player's level by one
				self thread setGunGameLevel( self.gunGame["level"] + 1 );
			
			} else {
				// Search the lowest player with a higher level than the this player
				lowestHigherLevel = undefined;
				for ( i = 0; i < level.players.size; i++ ) {
					player = level.players[i];		
					if ( isDefined( player ) && player != self && isDefined( player.gunGame ) ) {
						if ( player.gunGame["level"] > self.gunGame["level"] && ( !isDefined( lowestHigherLevel ) || player.gunGame["level"] < lowestHigherLevel ) ) {
							lowestHigherLevel = player.gunGame["level"];
						}
					}				
				}
				if ( isDefined( lowestHigherLevel ) ) {
					self thread setGunGameLevel( lowestHigherLevel );
				}				
			}
		}
	}	
}


giveGunGameLevelLoadout()
{
	// Remove all weapons and perks from the player
	self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
	self takeAllWeapons();
	self clearPerks();

	// Make sure the player gets any hardpoint that he/she already had
	if ( isDefined( self.pers["hardPointItem"] ) ) {
		self maps\mp\gametypes\_hardpoints::giveHardpointItem( self.pers["hardPointItem"] );
	}
	
	// Give the player fixed specialties and reset the speed no matter what the class
	self.specialty = [];
	self.specialty[0] = "specialty_null";
	if ( self.specialty[0] != "specialty_null" )
		self setPerk( self.specialty[0] );
		
	self.specialty[1] = level.scr_gg_specialty_slot1;
	if ( self.specialty[1] != "specialty_null" )
		self setPerk( self.specialty[1] );
	
	self.specialty[2] = level.scr_gg_specialty_slot2;
	if ( self.specialty[2] != "specialty_null" )
		self setPerk( self.specialty[2] );
	
	self thread openwarfare\_speedcontrol::setBaseSpeed( getdvarx( "class_specops_movespeed", "float", 1.0, 0.5, 1.5 ) );
	
	// Get the weapon that corresponds to this level
	levelWeapon = game["gunGameLevels"][ self.gunGame["level"] ]["weapon"];
	
	// Check if the weapon is the knife or a some kind of grenade
	if ( levelWeapon == "knife_mp" || weaponClass( levelWeapon ) == "grenade" || weaponClass( levelWeapon ) == "rocketlauncher" ) {
		// Check if we should give grenades to this player
		if ( levelWeapon != "knife_mp" ) {
			// Give the grenade
			self giveWeapon( levelWeapon );
			self giveMaxAmmo( levelWeapon );
			
			if ( weaponClass( levelWeapon ) != "rocketlauncher" && levelWeapon != "c4_mp" ) {
				self switchToOffhand( levelWeapon );
			}
			
			// Check if we should also give a special grenade
			nadeType = "none";
			switch ( level.scr_gg_explosives_special ) {
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
		}
				
		// Give the grenade/knife corresponding weapon to the player
		if ( levelWeapon != "c4_mp" && weaponClass( levelWeapon ) != "rocketlauncher" ) {
			self giveWeapon( level.scr_gg_nade_knife_weapon[0] );
			if ( !isDefined( level.scr_gg_nade_knife_weapon[1] ) ) {
				self giveMaxAmmo( level.scr_gg_nade_knife_weapon[0] );
			} else {
				self setWeaponAmmoClip( level.scr_gg_nade_knife_weapon[0], int( level.scr_gg_nade_knife_weapon[1] ) );
				self setWeaponAmmoStock( level.scr_gg_nade_knife_weapon[0], 0 );
			}
			self setSpawnWeapon( level.scr_gg_nade_knife_weapon[0] );
			self switchToWeapon( level.scr_gg_nade_knife_weapon[0] );
		} else {
			self setSpawnWeapon( levelWeapon );
			self switchToWeapon( levelWeapon );			
		}

	// If it's not the knife or some kind of grenade just give the weapon and max ammo
	} else {
		self giveWeapon( levelWeapon );
		self giveMaxAmmo( levelWeapon );
		self setSpawnWeapon( levelWeapon );
		self switchToWeapon( levelWeapon );	
	}
	
	// Enable the new weapon
	self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
}


showGunGameInfo()
{
	self endon("disconnect");
	
	// Check if this player has a gun game level set
	if ( !isDefined( self.gunGame ) ) {
		self.gunGame["level"] = 0;
		self.gunGame["lvl_kills"] = game["gunGameLevels"][0]["kills"];
		self.gunGame["kills"] = 0;
		self.gunGame["deaths"] = 0;			
	}
	
	// Create the weapon icon
	if ( game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] == "knife_mp" ) {
		weaponIcon = self createIcon( game["gunGameWeapons"][ game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] ], 100, 100 );
		
	} else if ( weaponClass( game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] ) == "pistol" ) {
		weaponIcon = self createIcon( game["gunGameWeapons"][ game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] ], 75, 75 );
		
	} else if ( weaponClass( game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] ) == "grenade" ) {
		weaponIcon = self createIcon( game["gunGameWeapons"][ game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] ], 100, 100 );
		
	} else {
		weaponIcon = self createIcon( game["gunGameWeapons"][ game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] ], 100, 50 );
	}	
	
	weaponIcon setPoint( "CENTER", "CENTER", 220, 140 );
	weaponIcon.archived = true;
	weaponIcon.hideWhenInMenu = true;
	weaponIcon.sort = -3;
	weaponIcon.alpha = 0.75;
	
	// Create the levels left
	levelsLeft = self createFontString( "objective", 1.8 );
	levelsLeft.archived = true;
	levelsLeft.hideWhenInMenu = true;
	levelsLeft setPoint( "CENTER", "CENTER", 250, 140 );
	levelsLeft.alignX = "left";
	levelsLeft.sort = -1;
	levelsLeft.alpha = 0.75;
	levelsLeft.color = ( 1, 1, 0 );
	levelsLeft setValue( game["gunGameLevels"].size - 1 - self.gunGame["level"] );

	// Create the deaths left 
	if ( level.scr_gg_death_penalty > 0 ) {
		deathsLeft = self createFontString( "objective", 1.4 );
		deathsLeft.archived = true;
		deathsLeft.hideWhenInMenu = true;
		deathsLeft setPoint( "CENTER", "CENTER", 250, 120 );
		deathsLeft.alignX = "left";
		deathsLeft.sort = -1;
		deathsLeft.alpha = 0.75;
		deathsLeft.color = ( 1, 0, 0 );
		deathsLeft setValue( level.scr_gg_death_penalty - self.gunGame["deaths"] );
	} else {
		deathsLeft = undefined;
	}
		
	// Create the kills left 
	killsLeft = self createFontString( "objective", 1.4 );
	killsLeft.archived = true;
	killsLeft.hideWhenInMenu = true;
	killsLeft setPoint( "CENTER", "CENTER", 250, 160 );
	killsLeft.alignX = "left";
	killsLeft.sort = -1;
	killsLeft.alpha = 0.75;
	killsLeft.color = ( 0, 0.5, 0 );
	killsLeft setValue( self.gunGame["lvl_kills"] - self.gunGame["kills"] );

	oldLevel = self.gunGame["level"];
	oldKills = self.gunGame["kills"];
	oldDeaths = self.gunGame["deaths"];
	
	// Update the level and kills info until the player dies
	while ( isDefined( self ) && isAlive( self ) ) {
		wait (0.05);
		
		// Check if the level has changed
		if ( self.gunGame["level"] != oldLevel ) {
			if ( game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] == "knife_mp" ) {
				weaponIcon setShader( game["gunGameWeapons"][ game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] ], 100, 100 );
				
			} else if ( weaponClass( game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] ) == "pistol" ) {
				weaponIcon setShader( game["gunGameWeapons"][ game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] ], 75, 75 );
				
			} else if ( weaponClass( game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] ) == "grenade" ) {
				weaponIcon setShader( game["gunGameWeapons"][ game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] ], 100, 100 );
				
			} else {
				weaponIcon setShader( game["gunGameWeapons"][ game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] ], 100, 50 );
			}
			levelsLeft setValue( game["gunGameLevels"].size - 1 - self.gunGame["level"] );
			oldLevel = self.gunGame["level"];
		}
		
		// Check if the number of kills has changed
		if ( self.gunGame["kills"] != oldKills ) {
			killsLeft setValue( self.gunGame["lvl_kills"] - self.gunGame["kills"] );
			oldKills = self.gunGame["kills"];
		}
		
		// Check if the number of deaths has changed
		if ( level.scr_gg_death_penalty > 0 && self.gunGame["deaths"] != oldDeaths ) {
			deathsLeft setValue( level.scr_gg_death_penalty - self.gunGame["deaths"] );
			oldDeaths = self.gunGame["deaths"];
		}		
	}
	
	// Destroy the HUD elements
	weaponIcon destroy();
	levelsLeft destroy();
	killsLeft destroy();
	
	if ( level.scr_gg_death_penalty > 0 ) {
		deathsLeft destroy();
	}
}


watchGrenadesUsage()
{
	self endon ( "death" );
	self endon ( "disconnect" );	

	for ( ;; )
	{
		self waittill ( "grenade_fire", grenade, weapName );
		// Check if we ran out of grenades and give a player an extra one if this is the level grenade
		if ( self getAmmoCount( weapName ) == 0 && game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] == weapName ) {
			self thread giveOneAmmo( weapName );
		}
	}	
}


watchRocketLauncherUsage()
{
	self endon ( "death" );
	self endon ( "disconnect" );	

	for ( ;; )
	{
		self waittill ( "end_firing" );
		// Check if we are using the rocket launcher and if we have no more ammo
		weapName = self getCurrentWeapon();
		if ( weaponClass( weapName ) == "rocketlauncher" && self getAmmoCount( weapName ) == 0 && game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] == weapName ) {
			self thread giveOneAmmo( weapName );
		}
	}	
}


giveOneAmmo( weapName )
{
	self endon ( "death" );
	self endon ( "disconnect" );	
	
	// Calculate when the grenade should be given
	timeToGive = openwarfare\_timer::getTimePassed() + level.scr_gg_explosives_refresh * 1000;
	while ( timeToGive > openwarfare\_timer::getTimePassed() && game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] == weapName && self getAmmoCount( weapName ) == 0 )
		wait (0.05);
		
	// Make sure the player doesn't have already a grenade and that the grenade is still the level weapon
	if ( self getAmmoCount( weapName ) == 0 && game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] == weapName ) {
		self setWeaponAmmoClip( weapName, 1 );
		self playLocalSound( "weap_ammo_pickup" );
	}	
}


onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	if ( sMeansOfDeath == "MOD_MELEE" )
		sWeapon = "knife_mp";
	
	// Handle attacker stuff first
	if ( isDefined( attacker ) && isPlayer( attacker ) && self != attacker ) {
		// Check if the kill was made with the knife and if the attacker should steal the level from the victim
		if ( sWeapon == "knife_mp" && level.scr_gg_knife_pro == 1 && self.gunGame["level"] > attacker.gunGame["level"] && game["gunGameLevels"][ attacker.gunGame["level"] ]["weapon"] != "knife_mp" ) {
			attacker thread setGunGameLevel( self.gunGame["level"] );
			
		} else if ( sWeapon == "knife_mp" && level.scr_gg_knife_pro == 2 && self.gunGame["level"] >= attacker.gunGame["level"] && game["gunGameLevels"][ attacker.gunGame["level"] ]["weapon"] != "knife_mp" ) {
			// Make sure the player is not in the last level already
			if ( attacker.gunGame["level"] < game["gunGameLevels"].size - 1 ) {
					// Increase player's level by one
					attacker thread setGunGameLevel( attacker.gunGame["level"] + 1 );
			}	

		} else if ( sWeapon == "knife_mp" && level.scr_gg_knife_pro == 3 && game["gunGameLevels"][ attacker.gunGame["level"] ]["weapon"] != "knife_mp" ) {
			// Make sure the player is not in the last level already
			if ( attacker.gunGame["level"] < game["gunGameLevels"].size - 1 ) {
					// Increase player's level by one
					attacker thread setGunGameLevel( attacker.gunGame["level"] + 1 );
			}			
			
		// Just add the kill to the attacker
		} else {
			// Check if the player has changed levels with this kill
			if ( !attacker addGunGameKill( sWeapon ) ) {
				// Check what kind of weapon is the player using
				if ( game["gunGameLevels"][ attacker.gunGame["level"] ]["weapon"] != "knife_mp" ) {
					if ( weaponClass( game["gunGameLevels"][ attacker.gunGame["level"] ]["weapon"] ) == "grenade" ) {
						// Check if we should give an extra grenade
						if ( level.scr_gg_extra_explosives == 1 ) {
							attacker setWeaponAmmoStock( game["gunGameLevels"][ attacker.gunGame["level"] ]["weapon"], attacker getAmmoCount( game["gunGameLevels"][ attacker.gunGame["level"] ]["weapon"] ) + 1 );
						}
												
					} else {
						// Check if we should refill stock ammo
						if ( level.scr_gg_refill_on_kill == 1 ) {
							attacker giveMaxAmmo( game["gunGameLevels"][ attacker.gunGame["level"] ]["weapon"] );
						}						
					}					
				}				
			}
		}
	}

	// Check if we should reduce a level for the victim in case the knife was used
	if ( level.scr_gg_knifed_penalty == 1 && sWeapon == "knife_mp" ) {
		self thread setGunGameLevel( self.gunGame["level"] - 1 );
	} else {	
		// Give an extra death to the victim
		self thread addGunGameDeath();
	}
}


addGunGameKill( sWeapon )
{
	// If the weapon used was not the level weapon then we don't give the kill to the attacker
	if ( game["gunGameLevels"][ self.gunGame["level"] ]["weapon"] != sWeapon )
		return false;
		
	// Add the extra kill
	self.gunGame["kills"]++;
	
	// Check if the player can go up to the next level
	if ( self.gunGame["kills"] == self.gunGame["lvl_kills"] ) {
		self thread setGunGameLevel( self.gunGame["level"] + 1 );
		return true;
		
	} else {
		return false;
	}	
}


addGunGameDeath()
{
	// Add the extra death
	self.gunGame["deaths"]++;
	
	// Check if the player has to go down a level
	if ( level.scr_gg_death_penalty > 0 && self.gunGame["deaths"] == level.scr_gg_death_penalty ) {
		self thread setGunGameLevel( self.gunGame["level"] - 1 );
	}	
}


setGunGameLevel( newLevel )
{
	// Make sure the player's level doesn't go below zero
	if ( newLevel < 0 ) {	
		self.gunGame["deaths"] = 0;
		
	// Do we have a winner?
	} else if ( newLevel == game["gunGameLevels"].size ) {
		self setRank( newLevel );
		maps\mp\gametypes\_globallogic::endGame( self, &"OW_GUNGAME_WINNER" );
		
	// Just change the player to the new level
	} else {
		// Check which kind of sound we should play
		if ( self.gunGame["level"] < newLevel ) {
			self playLocalSound( "powerup" );
		} else {
			self playLocalSound( "powerdown" );
		}

		// Assign the new level and reset the auxiliary variables		
		self setRank( newLevel );
		self.gunGame["level"] = newLevel;
		self.gunGame["lvl_kills"] = game["gunGameLevels"][ self.gunGame["level"] ]["kills"];
		self.gunGame["kills"] = 0;
		self.gunGame["deaths"] = 0;
		self thread giveGunGameLevelLoadout();
	}	
}


loadAllowedWeapons()
{
	// Load all the weapon shaders
	game["gunGameWeapons"] = [];

	// Handguns
	game["gunGameWeapons"][ "beretta_mp" ] = "weapon_m9beretta";
	precacheShader( "weapon_m9beretta" );	
	
	game["gunGameWeapons"][ "colt45_mp" ] = "weapon_colt_45";
	precacheShader( "weapon_colt_45" );	
	
	game["gunGameWeapons"][ "usp_mp" ] = "weapon_usp_45";
	precacheShader( "weapon_usp_45" );	
	
	game["gunGameWeapons"][ "deserteagle_mp" ] = "weapon_desert_eagle";
	precacheShader( "weapon_desert_eagle" );	
	
	game["gunGameWeapons"][ "deserteaglegold_mp" ] = "weapon_desert_eagle_gold";
	precacheShader( "weapon_desert_eagle_gold" );					

	// Assault class weapons
	game["gunGameWeapons"][ "m16_mp" ] = "weapon_m16a4";
	precacheShader( "weapon_m16a4" );

	game["gunGameWeapons"][ "ak47_mp" ] = "weapon_ak47";
	precacheShader( "weapon_ak47" );

	game["gunGameWeapons"][ "m4_mp" ] = "weapon_m4carbine";
	precacheShader( "weapon_m4carbine" );

	game["gunGameWeapons"][ "g3_mp" ] = "weapon_g3";
	precacheShader( "weapon_g3" );

	game["gunGameWeapons"][ "g36c_mp" ] = "weapon_g36c";
	precacheShader( "weapon_g36c" );

	game["gunGameWeapons"][ "m14_mp" ] = "weapon_m14";
	precacheShader( "weapon_m14" );

	game["gunGameWeapons"][ "mp44_mp" ] = "weapon_mp44";
	precacheShader( "weapon_mp44" );

	// Special Ops class weapons
	game["gunGameWeapons"][ "mp5_mp" ] = "weapon_mp5";
	precacheShader( "weapon_mp5" );

	game["gunGameWeapons"][ "skorpion_mp" ] = "weapon_skorpion";
	precacheShader( "weapon_skorpion" );

	game["gunGameWeapons"][ "uzi_mp" ] = "weapon_mini_uzi";
	precacheShader( "weapon_mini_uzi" );

	game["gunGameWeapons"][ "ak74u_mp" ] = "weapon_aks74u";
	precacheShader( "weapon_aks74u" );

	game["gunGameWeapons"][ "p90_mp" ] = "weapon_p90";
	precacheShader( "weapon_p90" );


	// Demolition class weapons 
	game["gunGameWeapons"][ "m1014_mp" ] = "weapon_benelli_m4";
	precacheShader( "weapon_benelli_m4" );

	game["gunGameWeapons"][ "winchester1200_mp" ] = "weapon_winchester1200";
	precacheShader( "weapon_winchester1200" );
	

	// Heavy gunner class weapons
	game["gunGameWeapons"][ "saw_mp" ] = "weapon_m249saw";
	precacheShader( "weapon_m249saw" );

	game["gunGameWeapons"][ "rpd_mp" ] = "weapon_rpd";
	precacheShader( "weapon_rpd" );

	game["gunGameWeapons"][ "m60e4_mp" ] = "weapon_m60e4";
	precacheShader( "weapon_m60e4" );


	// Sniper class weapons
	game["gunGameWeapons"][ "dragunov_mp" ] = "weapon_dragunovsvd";
	precacheShader( "weapon_dragunovsvd" );

	game["gunGameWeapons"][ "m40a3_mp" ] = "weapon_m40a3";
	precacheShader( "weapon_m40a3" );

	game["gunGameWeapons"][ "barrett_mp" ] = "weapon_barrett50cal";
	precacheShader( "weapon_barrett50cal" );

	game["gunGameWeapons"][ "remington700_mp" ] = "weapon_remington700";
	precacheShader( "weapon_remington700" );

	game["gunGameWeapons"][ "m21_mp" ] = "weapon_m14_scoped";
	precacheShader( "weapon_m14_scoped" );


	// Other
	game["gunGameWeapons"][ "frag_grenade_mp" ] = "weapon_fraggrenade";
	precacheShader( "weapon_fraggrenade" );
	
	game["gunGameWeapons"][ "c4_mp" ] = "weapon_c4";
	precacheShader( "weapon_c4" );
	
	game["gunGameWeapons"][ "rpg_mp" ] = "weapon_rpg7";
	precacheShader( "weapon_rpg7" );	
	
	game["gunGameWeapons"][ "knife_mp" ] = "weapon_knife";
	precacheShader( "weapon_knife" );	
	
	return;
}