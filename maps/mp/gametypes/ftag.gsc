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
	Freeze Tag
	Objective: 	Score points for your team by eliminating players on the opposing team
	Map ends:	When one team reaches the score limit, time limit is reached or an entire team is frozen.
	Respawning:	No wait / Near teammates

	Level requirements
	------------------
		Spawnpoints:
			classname		mp_tdm_spawn
			All players spawn from these. The spawnpoint chosen is dependent on the current locations of teammates and enemies
			at the time of spawn. Players generally spawn behind their teammates relative to the direction of enemies.

		Spectator Spawnpoints:
			classname		mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.

	Level script requirements
	-------------------------
		Team Definitions:
			game["allies"] = "marines";
			game["axis"] = "opfor";
			This sets the nationalities of the teams. Allies can be american, british, or russian. Axis can be german.

		If using minefields or exploders:
			maps\mp\_load::main();

*/


main()
{
	if(getdvar("mapname") == "mp_background")
		return;
		
	if ( !isdefined( game["switchedsides"] ) )
		game["switchedsides"] = false;		

	// Get the amount of health we'll be using for players
	level.hardcoreMode = getDvarInt( "scr_hardcore" );
	level.oldschool = ( getDvarInt( "scr_oldschool" ) == 1 );
	if ( level.hardcoreMode )
		level.maxhealth = getdvarx( "scr_player_maxhealth", "int", 30, 1, 500 );
	else if ( level.oldschool )
		level.maxhealth = getdvarx( "scr_player_maxhealth", "int", 200, 1, 500 );
	else
		level.maxhealth = getdvarx( "scr_player_maxhealth", "int", 100, 1, 500 );

	// Additional variables that we'll be using
	level.scr_ftag_forcestartspawns = getdvarx( "scr_ftag_forcestartspawns", "int", 0, 0, 1 );
	level.scr_ftag_unfreeze_time = getdvarx( "scr_ftag_unfreeze_time", "int", 250, 1, 60000 );
	level.scr_ftag_auto_unfreeze_time = getdvarx( "scr_ftag_auto_unfreeze_time", "int", int( 60000 / level.maxhealth ), 0, 60000 );
	level.scr_ftag_unfreeze_maxdistance = getdvarx( "scr_ftag_unfreeze_maxdistance", "int", 1000, 0, 100000 );
	level.scr_ftag_unfreeze_beam = getdvarx( "scr_ftag_unfreeze_beam", "int", 1, 0, 1 );
	level.scr_ftag_unfreeze_respawn = getdvarx( "scr_ftag_unfreeze_respawn", "int", 0, 0, 1 );
	level.scr_ftag_frozen_freelook = getdvarx( "scr_ftag_frozen_freelook", "int", 1, 0, 1 );
	level.scr_ftag_show_stats = getdvarx( "scr_ftag_show_stats", "int", 1, 0, 1 );
	level.scr_ftag_unfreeze_score = getdvarx( "scr_ftag_unfreeze_score", "int", 1, 1, 50 );
	level.scr_ftag_unfreeze_melt_iceberg = getdvarx( "scr_ftag_unfreeze_melt_iceberg", "int", 1, 0, 1 );

	// Force some server variables
	setDvar( "scr_ftag_playerrespawndelay", "-1" );
	setDvar( "scr_ftag_waverespawndelay", "0" );
	setDvar( "scr_blackscreen_enable_ftag", "0" );
	setDvar( "scr_healthsystem_show_healthbar_ftag", "1" );
	setDvar( "scr_player_forcerespawn_ftag", "1" );
	setDvar( "scr_allow_stationary_turrets_ftag", "0" );
		
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 0, 0, 10 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 5, 0, 500 );
	maps\mp\gametypes\_globallogic::registerRoundSwitchDvar( level.gameType, 2, 0, 500 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 3, 0, 5000 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 20, 0, 1440 );

	level.teamBased = true;
	level.overrideTeamScore = true;
	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onRoundSwitch = ::onRoundSwitch;
	level.onTimeLimit = ::onTimeLimit;	
		
	game["dialog"]["gametype"] = gameTypeDialog( "freezetag" );
	
	level thread onPlayerConnect();
}


onPrecacheGameType()
{
	// Initialize an array to keep all the assets we'll be using
	game[level.gameType] = [];
	
	// Allies resources
	game[level.gameType]["prop_iceberg_allies"] = "iceberg";
	game[level.gameType]["hud_frozen_allies"] = "hud_frozen";
	game[level.gameType]["hud_counter_allies"] = ( 0.3, 1, 1 );
	game[level.gameType]["defrost_beam_allies"] = loadFx( "freezetag/defrostbeam" );
	precacheModel( game[level.gameType]["prop_iceberg_allies"] );
	precacheShader( game[level.gameType]["hud_frozen_allies"] );
		
	// Axis resources
	game[level.gameType]["prop_iceberg_axis"] = "icebergred";
	game[level.gameType]["hud_frozen_axis"] = "hud_fznred";
	game[level.gameType]["hud_counter_axis"] = ( 1, 0.22, 0.22 );
	game[level.gameType]["defrost_beam_axis"] = loadFx( "freezetag/defrostbeamred" );
	precacheModel( game[level.gameType]["prop_iceberg_axis"] );
	precacheShader( game[level.gameType]["hud_frozen_axis"] );
	
	// Precache independent resources
	precacheStatusIcon( "hud_status_snowflake" );
	precacheShader( "hud_status_snowflake" );
	precacheShader( "icon_snowflake" );
	precacheShader( "icon_unfreeze_heat" );
	precacheShader( "icon_unfreeze_beam" );
	
	game["strings"]["allies_frozen"] = &"OW_FTAG_ALLIES_FROZEN";
	game["strings"]["axis_frozen"] = &"OW_FTAG_AXIS_FROZEN";
}


onStartGameType()
{
	setClientNameMode("auto_change");

	maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OW_OBJECTIVES_FTAG" );
	maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OW_OBJECTIVES_FTAG" );
	
	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OW_OBJECTIVES_FTAG" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OW_OBJECTIVES_FTAG" );
	}
	else
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OW_OBJECTIVES_FTAG_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OW_OBJECTIVES_FTAG_SCORE" );
	}
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"OW_OBJECTIVES_FTAG_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"OW_OBJECTIVES_FTAG_HINT" );
			
	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );	
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );

	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );
	
	allowed[0] = "war";
	
	if ( getDvarInt( "scr_oldHardpoints" ) > 0 )
		allowed[1] = "hardpoint";
	
	level.displayRoundEndText = true;
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	// elimination style
	if ( level.roundLimit != 1 && level.numLives )
	{
		level.onDeadEvent = ::onDeadEvent;
	}

	// Initialize some variables we need
	level.unfreezeMinDistance = 60;
	level.unfreezeSafeDistance = 75;
	level.unfreezeUnitsPerPoint = int( ( level.maxhealth - 1 ) / 5 );
		
	// Start the thread to monitor the game status
	level thread monitorGameStatus();
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		
		// Set some internal variables
		player.freezeTag = [];
		player.freezeTag["frozen"] = false;
		player.freezeTag["transfer"] = false;
		player.freezeTag["healthgiven"] = 0;
				
		player thread onSpawnFrozen();
		player thread monitorPlayerScore();
	}
}


onSpawnPlayer()
{
	if ( !isDefined( self.freezeTag ) ) {
		self.freezeTag["frozen"] = false;
		self.freezeTag["transfer"] = false;
	}
	
	if ( isDefined( self.body ) )
		self.body delete();
	
	// Check if this player should spawn frozen
	if ( self.freezeTag["frozen"] ) {
		self spawn( self.freezeTag["origin"], self.freezeTag["angles"] );

	} else {
		// Check which spawn points should be used
		if ( game["switchedsides"] ) {
			spawnTeam = level.otherTeam[ self.pers["team"] ];
		} else {
			spawnTeam =  self.pers["team"];
		}
		
		self.usingObj = undefined;
	
		if ( level.inGracePeriod || level.scr_ftag_forcestartspawns )
		{
			spawnPoints = getentarray("mp_tdm_spawn_" + spawnTeam + "_start", "classname");
			
			if ( !spawnPoints.size )
				spawnPoints = getentarray("mp_sab_spawn_" + spawnTeam + "_start", "classname");
				
			if ( !spawnPoints.size )
			{
				spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnTeam );
				spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
			}
			else
			{
				spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
			}		
		}
		else
		{
			spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnTeam );
			spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
		}

		self spawn( spawnPoint.origin, spawnPoint.angles );
	}
	
	// Show team freezes status
	self thread showTeamStatus();
	
	// Function to monitor for attempts to unfreeze
	if ( level.scr_ftag_unfreeze_maxdistance > 0 ) {
		self thread monitorUnfreezeAttempt();
	}
}



onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	// Make sure the player didn't die by falling or we will freeze him in a hole!
	if ( sMeansOfDeath != "MOD_FALLING" && sMeansOfDeath != "MOD_TRIGGER_HURT" && ( sMeansOfDeath != "MOD_SUICIDE" || ( sHitLoc == "none" && self.throwingGrenade ) ) ) {
		self.freezeTag["frozen"] = true;
		self.freezeTag["angles"] = self getPlayerAngles();
		
		// Wait for the ragdoll body to stop moving to get the final frozen place
		self.body maps\mp\gametypes\_weapons::waitTillNotMoving();
		self.freezeTag["origin"] = self.body getOrigin();		
	}	
}


onDeadEvent( team )
{
	// Make sure players on both teams were not eliminated
	if ( team != "all" ) {
		[[level._setTeamScore]]( getOtherTeam(team), [[level._getTeamScore]]( getOtherTeam(team) ) + 1 );
		thread maps\mp\gametypes\_globallogic::endGame( getOtherTeam(team), game["strings"][team + "_eliminated"] );
	} else {
		// We can't determine a winner if everyone died like in S&D so we declare a tie
		thread maps\mp\gametypes\_globallogic::endGame( "tie", game["strings"]["round_draw"] );
	}
}


onGameEnded( team, reason )
{
	// Make sure players on both teams were not eliminated
	if ( team != "all" ) {
		[[level._setTeamScore]]( getOtherTeam(team), [[level._getTeamScore]]( getOtherTeam(team) ) + 1 );
		thread maps\mp\gametypes\_globallogic::endGame( getOtherTeam(team), reason );
	} else {
		// We can't determine a winner if everyone died like in S&D so we declare a tie
		thread maps\mp\gametypes\_globallogic::endGame( "tie", reason );
	}
}


onRoundSwitch()
{
	// Just change the value for the variable controlling which map assets will be assigned to each team
	level.halftimeType = "halftime";
	game["switchedsides"] = !game["switchedsides"];
}


showTeamStatus()
{
	self endon("disconnect");
	
	// Create the icon and the number of players frozen
	frozenIcon = self createIcon( "icon_snowflake", 50, 50 );
	frozenIcon setPoint( "CENTER", "CENTER", 220, 140 );
	frozenIcon.archived = true;
	frozenIcon.hideWhenInMenu = true;
	frozenIcon.sort = -3;
	frozenIcon.alpha = 0.75;

	// Create the teammates frozen
	playersFrozen = self createFontString( "objective", 1.8 );
	playersFrozen.archived = true;
	playersFrozen.hideWhenInMenu = true;
	playersFrozen setPoint( "CENTER", "CENTER", 245, 155 );
	playersFrozen.alignX = "right";
	playersFrozen.sort = -1;
	playersFrozen.alpha = 0.75;
	playersFrozen.color = game[level.gameType]["hud_counter_" + self.pers["team"] ];
	playersFrozen setValue( 0 );

	oldFrozen = 0;
		
	while ( isDefined( self ) && isAlive(self) )	{
		wait (0.05);
		
		newFrozen = 0;
		// Count the teammates frozen
		for ( i = 0; i < level.players.size; i++ ) {
			player = level.players[i];		
			if ( isDefined( player ) && player.pers["team"] == self.pers["team"] && player.freezeTag["frozen"] ) {
				newFrozen++;	
			}				
		}		
		
		// Check if we need to update the HUD element
		if ( oldFrozen != newFrozen ) {
			playersFrozen setValue( newFrozen );
			oldFrozen = newFrozen;
		}	
	}	
	
	if ( isDefined( frozenIcon ) )
		frozenIcon destroy();
		
	if ( isDefined( playersFrozen ) )
		playersFrozen destroy();
}


onSpawnFrozen()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");	
	
		// Check if the player is not frozen
		if ( !self.freezeTag["frozen"] )
			continue;
	

		// Spawn the iceberg model
		self.freezeTag["iceberg"] = spawn( "script_model", self.origin + ( 0, 0, 35 ) );
		self.freezeTag["iceberg"] setModel( game[level.gameType]["prop_iceberg_" + self.pers["team"] ] );
		self.freezeTag["iceberg"].angles = self.angles + ( 0, 0, 180 );
		self.freezeTag["iceberg"] playSound( "frozen" );
		self.freezeTag["iceberg"] playLoopSound( "icecrack" );	
	
		// Freeze the controls for this player
		self setClientDvar( "ui_healthoverlay", 0 );
		self resetUnfreezingBudies();
		self.health = 1;
		self.freezeTag["frozentime"] = openwarfare\_timer::getTimePassed();
		
		// Check if we should allow free look
		if ( level.scr_ftag_frozen_freelook == 1 ) {
			self freezeControls( false );
			self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
			self thread maps\mp\gametypes\_gameobjects::_disableJump();
			self thread openwarfare\_speedcontrol::setModifierSpeed( "ftag", 100 );				
		} else {
			self freezeControls( true );
		}
		
		// Check if we need to update the status icon on the scoreboard
		if ( level.scr_show_player_status == 1 ) {
			self.statusicon = "hud_status_snowflake";
		}
		
		// Create the HUD element with the frozen effect
		self.freezeTag["fzneffect"] = newClientHudElem( self );
		self.freezeTag["fzneffect"].horzAlign = "fullscreen";
		self.freezeTag["fzneffect"].vertAlign = "fullscreen";
		self.freezeTag["fzneffect"].x = 0;
		self.freezeTag["fzneffect"].y = 0;
		self.freezeTag["fzneffect"].sort = 5;
		self.freezeTag["fzneffect"].alpha = 0;
		self.freezeTag["fzneffect"] setShader( game[level.gameType]["hud_frozen_" + self.pers["team"] ], 640, 480 );
		self.freezeTag["fzneffect"] fadeovertime( 2 );
		self.freezeTag["fzneffect"].alpha = 0.6;	
	
		// Create icon in compass
		if ( level.scr_hud_show_2dicons == 1 ) {
			self.freezeTag["objCompass"] = maps\mp\gametypes\_gameobjects::getNextObjID();
			if ( self.freezeTag["objCompass"] != -1 ) {
				objective_add( self.freezeTag["objCompass"], "active", self.origin );
				objective_icon( self.freezeTag["objCompass"], "hud_status_snowflake" );
				objective_team( self.freezeTag["objCompass"], self.pers["team"] );
			} else {
				self.freezeTag["objCompass"] = undefined;
			}
		} else {
			self.freezeTag["objCompass"] = undefined;
		}
	
		// Create 3D world icon
		if ( level.scr_hud_show_3dicons == 1 ) {
			self.freezeTag["objWorld"] = newTeamHudElem( self.pers["team"] );		
			origin = self.origin + (0,0,75);
			self.freezeTag["objWorld"].name = "frozen_" + self getEntityNumber();
			self.freezeTag["objWorld"].x = origin[0];
			self.freezeTag["objWorld"].y = origin[1];
			self.freezeTag["objWorld"].z = origin[2];
			self.freezeTag["objWorld"].baseAlpha = 1.0;
			self.freezeTag["objWorld"].isFlashing = false;
			self.freezeTag["objWorld"].isShown = true;
			self.freezeTag["objWorld"] setShader( "icon_snowflake", level.objPointSize, level.objPointSize );
			self.freezeTag["objWorld"] setWayPoint( true, "icon_snowflake" );
		} else {
			self.freezeTag["objWorld"] = undefined;
		}
				
		// Start threads for unfreeze
		if ( level.scr_ftag_auto_unfreeze_time ) {
			self thread autoUnfreezePlayer();
		}
		
		// Create the trigger that will monitor teammate heat transfer
		self thread unfreezeTriggerZone();
		
		// Start the thread that will monitor for the player temperature
		self thread monitorTemperature();
	}
}


monitorTemperature()
{
	// Save resources to clean
	playerIceberg = self.freezeTag["iceberg"];
	playerFznEffect = self.freezeTag["fzneffect"];
	objCompass = self.freezeTag["objCompass"];
	objWorld = self.freezeTag["objWorld"];
	currentTeam = self.pers["team"];
	
	// Wait until the player has recovered all the health or has disconnected
	oldHealth = self.health;
	moveUnits = -92 / ( self.maxhealth - 1 );
	
	while ( isDefined( self ) && isAlive( self ) && self.health < self.maxhealth && currentTeam == self.pers["team"] ) {
		wait (0.05);
		
		// Check if we need to move the iceberg and that the health has changed since last time
		if ( isDefined( self ) && level.scr_ftag_unfreeze_melt_iceberg == 1 && oldHealth != self.health ) {
			unitsToMove = int( ( self.health - oldHealth ) * moveUnits );
			if ( unitsToMove != 0 ) {
				oldHealth = self.health;
				playerIceberg movez( unitsToMove, 0.01, 0, 0 );	
			}
		}
	}
	
	// Check if the player is still in the server
	if ( isDefined( self ) && currentTeam == self.pers["team"] ) {
		self setClientDvar( "ui_healthoverlay", 1 );
		
		// Player is not frozen anymore
		self.freezeTag["frozen"] = false;
		self notify("unfrozen_player");
		
		// Call the onPlayerSpawned from some modules to re-initiliaze some variables
		// in case the player has changed loadouts while frozen
		if ( level.scr_explosives_allow_disarm == 1 )
			self thread openwarfare\_disarmexplosives::onPlayerSpawned();
		if ( level.specialty_grenadepulldeath_check_frags == 1 )
			self thread openwarfare\_martyrdom::onPlayerSpawned();
		if ( level.scr_enable_spawn_protection == 1 )
			self thread openwarfare\_spawnprotection::onPlayerSpawned();
		
		// Check if we should respawn the player in another place
		if ( level.scr_ftag_unfreeze_respawn == 1 ) {
			// Check which spawn points should be used
			if ( game["switchedsides"] ) {
				spawnTeam = level.otherTeam[ self.pers["team"] ];
			} else {
				spawnTeam =  self.pers["team"];
			}
			if ( level.inGracePeriod || level.scr_ftag_forcestartspawns ) {
				spawnPoints = getentarray("mp_tdm_spawn_" + spawnTeam + "_start", "classname");
				
				if ( !spawnPoints.size )
					spawnPoints = getentarray("mp_sab_spawn_" + spawnTeam + "_start", "classname");
					
				if ( !spawnPoints.size ) {
					spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnTeam );
					spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
				} else {
					spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
				}		
			} else {
				spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnTeam );
				spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
			}
	
			self setPlayerAngles( spawnPoint.angles );
			self setOrigin( spawnPoint.origin );
		}

		// Unfreeze the player
		if ( level.scr_ftag_frozen_freelook == 1 ) { 
			self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
			self thread maps\mp\gametypes\_gameobjects::_enableJump();				
			// Unfreeze the player
			self thread openwarfare\_speedcontrol::setModifierSpeed( "ftag", 0 );
		} else {
			self freezeControls( false );
		}
							
		// Check if we need to update the status icon on the scoreboard
		if ( level.scr_show_player_status == 1 ) {
			self.statusicon = "";
		}	
		
		// Check if we should show the stats of how the player became unfrozen
		if ( level.scr_ftag_show_stats == 1 ) {
			playerNames = self getUnfreezingBudies();
			if ( playerNames != "" ) {
				frozenTime = int( ( openwarfare\_timer::getTimePassed() - self.freezeTag["frozentime"] ) / 100 ) / 10;
				self iprintln( &"OW_FTAG_UNFROZEN_STATS", playerNames, frozenTime );				
			}
		}
	}

	// Remove any HUD elements and model
	if ( isDefined( playerFznEffect ) )
		playerFznEffect destroy();	

	if ( isDefined( objCompass ) ) {
		objective_delete( objCompass );	
		maps\mp\gametypes\_gameobjects::resetObjID( objCompass );
	}
		
	if ( isDefined( objWorld ) )
		objWorld destroy();
			
	playerIceberg stopLoopSound();
	playerIceberg movez( -90, 0.75, 0.25, 0.25 );
	playerIceberg playSound( "frozen" );
	wait (1.0);
	playerIceberg delete();		
}


autoUnfreezePlayer()
{
	self endon("death");
	self endon("disconnect");
	
	self addUnfreezingBudy( self );
	
	// Wait two seconds to start unfreezing
	xWait( 2.0 );
	
	for (;;) {
		// Calculate next temperature raise
		xWait( level.scr_ftag_auto_unfreeze_time / 1000 );
		
		// Make sure the player is still frozen
		if ( self.freezeTag["frozen"] && self.health < level.maxhealth ) {
			self.health++;
			self addHealthPoint( self );
		} else {
			break;
		}
	}
}


unfreezeTriggerZone()
{
	self endon("disconnect");
	self endon("death");
	
	// Create the trigger and monitor it
	triggerRadius = spawn( "trigger_radius", self.origin, 0, level.unfreezeMinDistance, level.unfreezeMinDistance );
	self thread deleteTriggerZone( triggerRadius );
	self thread monitorTriggerZone( triggerRadius );
}


monitorTriggerZone( triggerRadius )
{
	self endon("disconnect");
	self endon("death");
	
	triggerRadius endon("death");
	
	for (;;)
	{
		// Wait until a player has entered my radius
		triggerRadius waittill( "trigger", player );

		// Check if the player has disconnected
		if ( !isDefined( player ) || !isDefined( player.pers ) )
			continue;

		// Make sure it's a player
		if ( !isPlayer( player ) )
			continue;
			
		// Make sure it's not us
		if ( player == self )
			continue;
			
		// Make sure it's not an enemy
		if ( player.pers["team"] != self.pers["team"] )
			continue;
			
		// Make sure this player is not also frozen
		if ( player.freezeTag["frozen"] )
			continue;

		// Make sure this player is not giving heat already
		if ( player.freezeTag["transfer"] )
			continue;
			
		// We have a canditate for heat transfer
		player thread startHeatTransfer( self, triggerRadius );
	}
}


deleteTriggerZone( triggerRadius )
{
	// Wait for the player to disconnect, change teams or be unfrozen
	while ( isDefined( self ) && isAlive( self ) && self.freezeTag["frozen"] )
		wait (0.05);
	
	// Remove the trigger
	triggerRadius delete();	
}


startHeatTransfer( frozenPlayer, triggerRadius )
{
	self.freezeTag["transfer"] = true;
	
	frozenPlayer addUnfreezingBudy( self );
	
	// Create the HUD element we'll be using to show a player "unfreezing" a teammate
	unfreezeIcon = newClientHudElem( self );
	unfreezeIcon.x = 37;
	unfreezeIcon.y = 142;
	unfreezeIcon.alignX = "center";
	unfreezeIcon.alignY = "middle";
	unfreezeIcon.horzAlign = "center_safearea";
	unfreezeIcon.vertAlign = "center_safearea";
	unfreezeIcon.alpha = 0.75;
	unfreezeIcon.archived = true;
	unfreezeIcon.hideWhenInMenu = true;
	unfreezeIcon setShader( "icon_unfreeze_heat", 34, 34);

	while ( isDefined( self ) && isAlive( self ) && isDefined( frozenPlayer ) && isAlive( frozenPlayer ) && frozenPlayer.freezeTag["frozen"] && isDefined( triggerRadius ) && self isTouching( triggerRadius ) ) {
		if ( frozenPlayer.health < level.maxhealth ) {
			frozenPlayer.health++;
			frozenPlayer addHealthPoint( self );
			self.freezeTag["healthgiven"]++;
			xWait( level.scr_ftag_unfreeze_time / 1000 );
		} else {
			break;
		}
	}
					
	if ( isDefined( self ) )
		self.freezeTag["transfer"] = false;
	
	// Destroy the HUD element
	if ( isDefined( unfreezeIcon ) )
		unfreezeIcon destroy();
}


monitorGameStatus()
{
	self endon("game_ended");
	
	alliesOneLeft = false;
	axisOneLeft = false;
	
	for (;;)
	{
		wait (0.5);
		
		// Initialize variables
		teamStatus["allies"]["qty"] = 0;
		teamStatus["axis"]["qty"] = 0;
		teamStatus["allies"]["alive"] = 0;
		teamStatus["axis"]["alive"] = 0;
		teamStatus["allies"]["player"] = undefined;
		teamStatus["axis"]["player"] = undefined;
		
		// Cycle through all the players
		for ( index = 0; index < level.players.size; index++ )
		{
			player = level.players[index];

			// Update counters depending on player's team and status
			if ( player.pers["team"] != "spectator" ) {
				if ( !player.freezeTag["frozen"] ) {
					teamStatus[ player.pers["team"] ]["alive"]++;
					teamStatus[ player.pers["team"] ]["player"] = player;
				}
				teamStatus[ player.pers["team"] ]["qty"]++;				
			}
		}
		
		// Check if we have the last players standing
		if ( teamStatus["allies"]["alive"] == 1 && teamStatus["allies"]["qty"] > 1 && teamStatus["axis"]["qty"] > 1 ) {
			// Make sure we didn't play the sound already
			if ( !alliesOneLeft ) {
				alliesOneLeft = true;
				teamStatus["allies"]["player"] maps\mp\gametypes\_globallogic::leaderDialogOnPlayer( "last_alive" );				
			}
		} else {
			alliesOneLeft = false;
		}
		if ( teamStatus["axis"]["alive"] == 1 && teamStatus["allies"]["qty"] > 1 && teamStatus["axis"]["qty"] > 1 ) {
			// Make sure we didn't play the sound already
			if ( !axisOneLeft ) {
				axisOneLeft = true;
				teamStatus["axis"]["player"] maps\mp\gametypes\_globallogic::leaderDialogOnPlayer( "last_alive" );				
			}
		} else {
			axisOneLeft = false;
		}
		
		// Check if we have players on both teams
		if ( teamStatus["allies"]["qty"] > 0 && teamStatus["axis"]["qty"] > 0 ) {
			// Check for game draw
			if ( teamStatus["allies"]["alive"] == 0 && teamStatus["axis"]["alive"] == 0 ) {
				level thread onGameEnded( "all", game["strings"]["round_draw"] );
			
			// Check for allies frozen
			} else if ( teamStatus["allies"]["alive"] == 0 ) {
				level thread onGameEnded( "allies", game["strings"]["allies_frozen"] );
				
			// Check for axis frozen
			} else if ( teamStatus["axis"]["alive"] == 0 ) {
				level thread onGameEnded( "axis", game["strings"]["axis_frozen"] );
			}			
		}
	}	
}


onTimeLimit()
{
	// See which team has less frozen players
	teamStatus["allies"]["frozen"] = 0;
	teamStatus["axis"]["frozen"] = 0;
	
	// Cycle through all the players
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];

		// Update counters depending on player's team and status
		if ( player.pers["team"] != "spectator" ) {
			if ( player.freezeTag["frozen"] ) {
				teamStatus[ player.pers["team"] ]["frozen"]++;
			}
		}
	}	
	
	// Check for game draw
	if ( teamStatus["allies"]["frozen"] == teamStatus["axis"]["frozen"] ) {
		level thread onGameEnded( "all", game["strings"]["time_limit_reached"] );
	
	// Check for allies frozen
	} else if ( teamStatus["allies"]["frozen"] > teamStatus["axis"]["frozen"] ) {
		level thread onGameEnded( "allies", game["strings"]["time_limit_reached"] );
		
	// Check for axis frozen
	} else {
		level thread onGameEnded( "axis", game["strings"]["time_limit_reached"] );
	}			
	
}


monitorUnfreezeAttempt()
{
	self endon("disconnect");
	
	// Create the HUD element we'll be using to show a player "unfreezing" a teammate
	if ( level.scr_ftag_unfreeze_beam == 0 ) {
		unfreezeIcon = newClientHudElem( self );
		unfreezeIcon.x = -37;
		unfreezeIcon.y = 142;
		unfreezeIcon.alignX = "center";
		unfreezeIcon.alignY = "middle";
		unfreezeIcon.horzAlign = "center_safearea";
		unfreezeIcon.vertAlign = "center_safearea";
		unfreezeIcon.alpha = 0;
		unfreezeIcon.archived = true;
		unfreezeIcon.hideWhenInMenu = true;
		unfreezeIcon setShader( "icon_unfreeze_beam", 34, 34);
	} else {
		unfreezeIcon = undefined;
	}
	
	while ( isDefined( self ) && isAlive( self ) ) {
		wait (0.05);
		
		// Check if the player is pressing the USE key
		if ( isDefined( self ) && self useButtonPressed() && !self.freezeTag["frozen"] ) {
			// Check if he's looking at a frozen player
			lookingPlayer = self getLookingAtEntity();
			if ( isDefined( lookingPlayer ) && isPlayer( lookingPlayer ) ) {
	
				// Check if we are at a good distance and if the player is frozen and on the same team
				if ( distance( self.origin, lookingPlayer.origin ) > level.unfreezeSafeDistance && distance( self.origin, lookingPlayer.origin ) <= level.scr_ftag_unfreeze_maxdistance && lookingPlayer.freezeTag["frozen"] && self.pers["team"] == lookingPlayer.pers["team"] ) {

					lookingPlayer addUnfreezingBudy( self );
					
					if ( isDefined( unfreezeIcon ) )
						unfreezeIcon.alpha = 0.75;
						
					while ( isDefined( self ) && isAlive( self ) && isDefined( lookingPlayer ) && lookingPlayer.freezeTag["frozen"] && self useButtonPressed() && self isLookingAtPlayer( lookingPlayer ) && distance( self.origin, lookingPlayer.origin ) > level.unfreezeSafeDistance && distance( self.origin, lookingPlayer.origin ) <= level.scr_ftag_unfreeze_maxdistance ) {
						// Check if we should show a defrost beam
						if ( level.scr_ftag_unfreeze_beam == 1 ) {
							self thread showDefrostBeam( lookingPlayer );
						}				
						if ( lookingPlayer.health < level.maxhealth ) {
							lookingPlayer.health++;
							lookingPlayer addHealthPoint( self );
							self.freezeTag["healthgiven"]++;
							xWait( level.scr_ftag_unfreeze_time / 1000 );
						} else {
							break;
						}
					}
					
					if ( isDefined( unfreezeIcon ) )
						unfreezeIcon.alpha = 0;
				}
			}		
		}		
	}
	
	// Destroy the HUD element
	if ( isDefined( unfreezeIcon ) )
		unfreezeIcon destroy();	
}


showDefrostBeam( frozenPlayer )
{
	// Make sure there's no other beam already present
	if ( isDefined( self.showingBeam ) && self.showingBeam )
		return;
		
	self.showingBeam = true;
	
	defrostBeam = spawn( "script_origin", self.origin + ( 0, 0, 40 ) );
	self thread loopBeamEffect( defrostBeam );
	defrostBeam moveTo( frozenPlayer.origin + ( 0, 0, 40 ), distance( self.origin, frozenPlayer.origin ) / 750 );
	defrostBeam waittill("movedone");
	defrostBeam delete();	
	
	self.showingBeam = false;
}


loopBeamEffect( defrostBeam )
{
	self endon("disconnect");
	self endon("death");
	
	while ( isDefined( self ) && isAlive( self ) && self.showingBeam && isDefined( defrostBeam ) ) {
		playFx( game[level.gameType]["defrost_beam_" + self.pers["team"] ], defrostBeam.origin );
		wait(0.05);
	}	
}


getLookingAtEntity()
{
	// Get position of player's eyes and angles
	playerEyes = self getPlayerEyes();
	playerAngles = self getPlayerAngles();
	
	// Calculate the origin
	origin = playerEyes + maps\mp\_utility::vector_Scale( anglesToForward( playerAngles ), 9999999 );

	// Run the trace
	trace = bulletTrace( playerEyes, origin, true, self );
	return trace["entity"];
}


isLookingAtPlayer( gameEntity )
{
	// Get position of player's eyes and angles
	playerEyes = self getPlayerEyes();
	playerAngles = self getPlayerAngles();
	
	// Calculate the origin
	origin = playerEyes + maps\mp\_utility::vector_Scale( anglesToForward( playerAngles ), 9999999 );

	// Run the trace
	trace = bulletTrace( playerEyes, origin, true, self );
	if( trace["fraction"] != 1 ) {
		if ( isDefined( trace["entity"] ) && trace["entity"] == gameEntity ) {
			return true;
		} else {
			return false;
		}		
	} else {
		return false;
	}
}


resetUnfreezingBudies()
{
	self.freezeTag["unfreezebudies"] = [];
}


addUnfreezingBudy( budy )
{
	self endon("disconnect");
	self endon("death");

	// Get the budy's entity number
	budyEntity = budy getEntityNumber();
	
	// Search for this entity
	i = 0;
	while ( isDefined( self ) && i < self.freezeTag["unfreezebudies"].size && self.freezeTag["unfreezebudies"][i].playerEntity != budyEntity )
		i++;
	
	// If we couldn't find the entity we'll just add a new element
	if ( isDefined( self ) && i == self.freezeTag["unfreezebudies"].size ) {
		newElement = self.freezeTag["unfreezebudies"].size;
		self.freezeTag["unfreezebudies"][newElement] = spawnstruct();
		self.freezeTag["unfreezebudies"][newElement].playerEntity = budyEntity;
		self.freezeTag["unfreezebudies"][newElement].playerName = budy.name;
		self.freezeTag["unfreezebudies"][newElement].healthGiven = 0;
	}	
}


addHealthPoint( budy )
{
	self endon("disconnect");
	self endon("death");

	// Get the budy's entity number
	budyEntity = budy getEntityNumber();
	
	// Search for this entity
	i = 0;
	while ( isDefined( self ) && i < self.freezeTag["unfreezebudies"].size && self.freezeTag["unfreezebudies"][i].playerEntity != budyEntity )
		i++;
	
	// Make sure we found the budy
	if ( isDefined( self ) && i < self.freezeTag["unfreezebudies"].size ) {	
		self.freezeTag["unfreezebudies"][i].healthGiven++;
	}			
}


getUnfreezingBudies()
{
	healthReceived = "";
	for ( i=0; i < self.freezeTag["unfreezebudies"].size; i++ ) {
		// Make sure this player gave us at least a unit
		if ( self.freezeTag["unfreezebudies"][i].healthGiven > 0 ) {
			// Check if we need to add a comma
			if ( healthReceived != "" ) {
				healthReceived += ", ";
			}
			// Add this player
			healthReceived += "^3" + self.freezeTag["unfreezebudies"][i].playerName + "^7 (" + self.freezeTag["unfreezebudies"][i].healthGiven + ")";			
		}		
	}	
	
	return healthReceived;
}


monitorPlayerScore()
{
	level endon("game_ended");
	self endon("disconnect");
	
	unfreezeScoresGiven = 0;
	
	for (;;) {
		wait (0.05);
		
		// Check if we have enough units to give the player a score point
		if ( self.freezeTag["healthgiven"] >= level.unfreezeUnitsPerPoint ) {
			// Give the score to the player
			self.freezeTag["healthgiven"] -= level.unfreezeUnitsPerPoint;
			self maps\mp\gametypes\_rank::giveRankXP( "unfreeze", level.scr_ftag_unfreeze_score );
			self.pers["score"] += level.scr_ftag_unfreeze_score;
			self maps\mp\gametypes\_persistence::statAdd( "score", ( self.pers["score"] - level.scr_ftag_unfreeze_score ) );
			self.score = self.pers["score"];

			// Increment the amount scores given to this player
			unfreezeScoresGiven++;
			
			// If we gave 5 scores this means the player has completely unfrozen one entire teammate giving him an assist point
			if ( unfreezeScoresGiven == 5 ) {
				// Give the assist point to the player (number of assists indicates teammates that have been unfrozen)
				unfreezeScoresGiven = 0;
				self maps\mp\gametypes\_globallogic::incPersStat( "assists", 1 );
				self.assists = self maps\mp\gametypes\_globallogic::getPersStat( "assists" );
			}
			
			self notify ("update_playerscore_hud");				
		}
	}
}