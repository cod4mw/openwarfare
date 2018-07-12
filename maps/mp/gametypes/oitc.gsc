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
	One In The Chamber
	Objective: 	Eliminate the other players
	Map ends:	When one player eliminates all the other players, reaches the score limit, or time limit is reached
	Respawning:	No respawning

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

	Optional level script settings
	------------------------------
		Soldier Type and Variation:
			game["american_soldiertype"] = "normandy";
			game["german_soldiertype"] = "normandy";
			This sets what character models are used for each nationality on a particular map.

			Valid settings:
				american_soldiertype	normandy
				british_soldiertype		normandy, africa
				russian_soldiertype		coats, padded
				german_soldiertype		normandy, africa, winterlight, winterdark
*/

/*QUAKED mp_dm_spawn (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Players spawn away from enemies at one of these positions.*/

main()
{
	// Force some server variables
	setDvar( "scr_player_forcerespawn_oitc", "1" );
	setDvar( "scr_show_lives_enable_oitc", "1" );
	
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	// Additional variables that we'll be using
	level.scr_oitc_handgun = toLower( getdvarx( "scr_oitc_handgun", "string", "beretta_mp;colt45_mp;usp_mp;deserteagle_mp" ) );
	level.scr_oitc_handgun = strtok( level.scr_oitc_handgun, ";" );
	
	level.scr_oitc_suddendeath_show_enemies = getdvarx( "scr_oitc_suddendeath_show_enemies", "int", 1, 0, 1 );
	level.scr_oitc_suddendeath_timelimit = getdvarx( "scr_oitc_suddendeath_timelimit", "int", 0, 0, 600 );	

	level.scr_oitc_specialty_slot1 = getdvarx( "scr_oitc_specialty_slot1", "string", "specialty_fastreload" );
	if ( !issubstr( "specialty_null;specialty_bulletdamage;specialty_fastreload;specialty_rof", level.scr_oitc_specialty_slot1 ) ) {
		level.scr_oitc_specialty_slot1 = "specialty_fastreload";
	}

	level.scr_oitc_specialty_slot2 = getdvarx( "scr_oitc_specialty_slot2", "string", "specialty_longersprint" );
	if ( !issubstr( "specialty_null;specialty_longersprint;specialty_bulletaccuracy;specialty_bulletpenetration;specialty_quieter", level.scr_oitc_specialty_slot2 ) ) {
		level.scr_oitc_specialty_slot2 = "specialty_longersprint";
	}
	
	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 3, 3, 3 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 0, 0, 500 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 3, 0, 5000 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 5, 0, 1440 );

	level.teamBased = false;

	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onLoadoutGiven = ::onLoadoutGiven;
	level.onRoundSwitch = ::onRoundSwitch;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onTimeLimit = ::onTimeLimit;

	game["dialog"]["gametype"] = gameTypeDialog( "oneinthechamber" );
}


onStartGameType()
{
	setClientNameMode("auto_change");

	maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OW_OBJECTIVES_ONEINTHECHAMBER" );
	maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OW_OBJECTIVES_ONEINTHECHAMBER" );

	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OW_OBJECTIVES_ONEINTHECHAMBER" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OW_OBJECTIVES_ONEINTHECHAMBER" );
	}
	else
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OW_OBJECTIVES_ONEINTHECHAMBER_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OW_OBJECTIVES_ONEINTHECHAMBER_SCORE" );
	}
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"OW_OBJECTIVES_ONEINTHECHAMBER_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"OW_OBJECTIVES_ONEINTHECHAMBER_HINT" );

	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_dm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_dm_spawn" );
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );
	
	allowed[0] = "dm";
	maps\mp\gametypes\_gameobjects::main(allowed);

	level.QuickMessageToAll = true;

	// elimination style
	level.displayRoundEndText = true;
	level.overridePlayerScore = true;
	level.onOneLeftEvent = ::onOneLeftEvent;
	
	thread oneInTheChamber();
}


onTimeLimit()
{
	if ( !level.OITCExtraTime ) {
		level.timeLimitOverride = true;
		level.OITCExtraTime = true;
	
		if ( level.scr_oitc_suddendeath_show_enemies == 1 ) {
			for ( index = 0; index < level.players.size; index++ ) {
				level.players[index] thread maps\mp\gametypes\_hud_message::oldNotifyMessage( &"OW_ONEINTHECHAMBER", &"OW_UAV_ON", undefined, (1, 0, 0), "mp_last_stand" );
				level.players[index] setClientDvar( "g_compassShowEnemies", 1 );
			}
		}
	
		if ( level.scr_oitc_suddendeath_timelimit > 0 ) {
			setGameEndTime( getTime() + ( level.scr_oitc_suddendeath_timelimit * 1000 ) );
		} else {
			level.timelimit = 0;
		}
		
	} else {
		logString( "time limit, tie" );
		thread maps\mp\gametypes\_globallogic::endGame( undefined, game["strings"]["time_limit_reached"] );
	}
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


onOneLeftEvent( team )
{
	wait 0.05;
	
	winner = getLastAlivePlayer();

	if ( isDefined( winner ) )
		logString( "last one alive, win: " + winner.name );
	else
		logString( "last one alive, win: unknown" );

	if ( isDefined( winner ) ) {
		[[level._setPlayerScore]]( winner, [[level._getPlayerScore]]( winner ) + 1 );
	}
	
	thread maps\mp\gametypes\_globallogic::endGame( winner, &"MP_ENEMIES_ELIMINATED" );		
}


onLoadoutGiven()
{
	// Give player One In The Chamber loadouts
	self giveOneInTheChamberLoadout();	
}


onRoundSwitch()
{
	// Randomly select another handgun on round switch
	thread oneInTheChamber();
}

oneInTheChamber()
{
	level endon ( "game_ended" );
	
	level.OITCExtraTime = false;
	level.oneInTheChamberWeapon = level.scr_oitc_handgun[ randomIntRange( 0, level.scr_oitc_handgun.size ) ];
}


giveOneInTheChamberLoadout()
{
	// Remove all weapons and perks from the player
	self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
	self takeAllWeapons();

	// Make sure the player gets any hardpoint that he/she already had
	if ( isDefined( self.pers["hardPointItem"] ) ) {
		self maps\mp\gametypes\_hardpoints::giveHardpointItem( self.pers["hardPointItem"] );
	}
	
	// Give the player fixed specialties and reset the speed no matter what the class
	self clearPerks();
	self.specialty = [];
	self.specialty[0] = "specialty_null";
	if ( self.specialty[0] != "specialty_null" )
		self setPerk( self.specialty[0] );
		
	self.specialty[1] = level.scr_oitc_specialty_slot1;
	if ( self.specialty[1] != "specialty_null" )
		self setPerk( self.specialty[1] );
	
	self.specialty[2] = level.scr_oitc_specialty_slot2;
	if ( self.specialty[2] != "specialty_null" )
		self setPerk( self.specialty[2] );
	
	self thread openwarfare\_speedcontrol::setBaseSpeed( getdvarx( "class_specops_movespeed", "float", 1.0, 0.5, 1.5 ) );

	self giveWeapon( level.oneInTheChamberWeapon );
	self setWeaponAmmoClip( level.oneInTheChamberWeapon, 1 );
	self setWeaponAmmoStock( level.oneInTheChamberWeapon, 0 );
	self setSpawnWeapon( level.oneInTheChamberWeapon );
	self switchToWeapon( level.oneInTheChamberWeapon );	
	
	// Enable the new weapon
	self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
}


onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	// Give the attacker a bullet if he doesn't have any
	if ( isPlayer( attacker ) ) {
		attacker setWeaponAmmoClip( level.oneInTheChamberWeapon, 1 );
		attacker setWeaponAmmoStock( level.oneInTheChamberWeapon, 0 );
	}
}