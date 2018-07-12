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
	Capture and Hold

	Objective: Capture the flag and hold it for certain amount of time
	Map ends: When one team holds the flag for certain amount of time, or the time limit is reached
	Respawning: No wait / Near teammates

	Level requirements
	------------------
		Spawnpoints:
			classname	mp_ch_spawn_allies_start, mp_ch_spawn_axis_start
			All players spawn from these at the beginning of the round. These
			spawn points will be used until one team captures the flag.

			classname	mp_ch_spawn_allies, mp_ch_spawn_axis
			All players will spawn from these after a team has taken the flag.

		Spectator spawnpoints:
			classname	mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			At least one is required, any more and they are randomly chosen between.

		Flag:
			classname script_model targetname ch_flag
			classname trigger_radius targetname ch_trig
			Flag that needs to be captured and hold.

		Note:
			In the case the map doesn't support the above CH assets natively this
			implementation of CH will try to use the location of the bomb from
			Sabotage to determine the position of the flag. It will then use this
			position to create the needed assets for Capture and Hold.
*/


/*
=============
main

Load variables and initialize functions that will be called on events
=============
*/
main()
{
	if(getdvar("mapname") == "mp_background")
		return;

	if ( !isdefined( game["switchedsides"] ) )
		game["switchedsides"] = false;

	// Additional variables that we'll be using
	level.scr_ch_chmode = getdvarx( "scr_ch_chmode", "int", 0, 0, 1 );
	level.scr_ch_holdtime = getdvarx( "scr_ch_holdtime", "int", 100, 45, 300 );
	level.scr_ch_neutraltime = getdvarx( "scr_ch_neutraltime", "int", 15, 5, 59 );
	level.scr_ch_scoreboard_flag_carrier = getdvarx( "scr_ch_scoreboard_flag_carrier", "int", 1, 0, 1 );
	level.scr_ch_show_flag_carrier = getdvarx( "scr_ch_show_flag_carrier", "int", 0, 0, 2  );
	level.scr_ch_show_flag_carrier_time = getdvarx( "scr_ch_show_flag_carrier_time", "int", 5, 5, 600 );
	level.scr_ch_show_flag_carrier_distance = getdvarx( "scr_ch_show_flag_carrier_distance", "int", 0, 0, 1000 );	
	
	level.scr_ch_ownerspawndelay = getdvarx( "scr_ch_ownerspawndelay", "int", 0, 0, 60 );	

	level.scr_ch_suddendeath_show_enemies = getdvarx( "scr_ch_suddendeath_show_enemies", "int", 1, 0, 1 );
	level.scr_ch_suddendeath_timelimit = getdvarx( "scr_ch_suddendeath_timelimit", "int", 90, 0, 600 );
	
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	// Get the dvars we need for this gametype
	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 0, 0, 10 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 5, 1, 500 );
	maps\mp\gametypes\_globallogic::registerRoundSwitchDvar( level.gameType, 2, 0, 500 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 3, 0, 5000 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 20, 0, 1440 );


	level.teamBased = true;
	level.overrideTeamScore = true;
	level.endGameOnScoreLimit = true;
	level.onDeadEvent = ::onDeadEvent;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onRoundSwitch = ::onRoundSwitch;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onStartGameType = ::onStartGameType;
	
	if ( level.scr_ch_chmode == 0 ) {
		level.onTimeLimit = ::onTimeLimit;
	}	

	if ( level.scr_ch_ownerspawndelay > 0 ) {
		level.onRespawnDelay = ::getRespawnDelay;
	}

	game["dialog"]["gametype"] = gameTypeDialog( "capturehold" );
	game["dialog"]["offense_obj"] = "capture_obj";
	game["dialog"]["defense_obj"] = "capture_obj";
}


/*
=============
onPrecacheGameType

Precache the models, shaders, and strings to be used
=============
*/
onPrecacheGameType()
{
	// Initialize an array to keep all the assets we'll be using
	game[level.gameType] = [];

	// Precache team dependent assets for allies
	if ( game["allies"] == "marines" ) {
		game[level.gameType]["prop_flag_allies"] = "prop_flag_american";
		game[level.gameType]["prop_flag_allies_carry"] = "prop_flag_american_carry";
		game[level.gameType]["hud_flag_allies"] = "objpoint_flag_american";
		game[level.gameType]["flag_base_allies"] = loadFX( "misc/ui_flagbase_silver" );
	} else {
		game[level.gameType]["prop_flag_allies"] = "prop_flag_brit";
		game[level.gameType]["prop_flag_allies_carry"] = "prop_flag_brit_carry";
		game[level.gameType]["hud_flag_allies"] = "objpoint_flag_british";
		game[level.gameType]["flag_base_allies"] = loadFX( "misc/ui_flagbase_black" );
	}
	// Precache allies assets
	precacheModel( game[level.gameType]["prop_flag_allies"] );
	precacheModel( game[level.gameType]["prop_flag_allies_carry"] );
	precacheShader( game[level.gameType]["hud_flag_allies"] );

	// Precache team dependent assets for axis
	if ( game["axis"] == "russian" ) {
		game[level.gameType]["prop_flag_axis"] = "prop_flag_russian";
		game[level.gameType]["prop_flag_axis_carry"] = "prop_flag_russian_carry";
		game[level.gameType]["hud_flag_axis"] = "objpoint_flag_russian";
		game[level.gameType]["flag_base_axis"] = loadFX( "misc/ui_flagbase_red" );
	} else {
		game[level.gameType]["prop_flag_axis"] = "prop_flag_opfor";
		game[level.gameType]["prop_flag_axis_carry"] = "prop_flag_opfor_carry";
		game[level.gameType]["hud_flag_axis"] = "objpoint_flag_opfor";
		game[level.gameType]["flag_base_axis"] = loadFX( "misc/ui_flagbase_gold" );
	}

	// Precache axis assets
	precacheModel( game[level.gameType]["prop_flag_axis"] );
	precacheModel( game[level.gameType]["prop_flag_axis_carry"] );
	precacheShader( game[level.gameType]["hud_flag_axis"] );

	// Precache other assets that are not team dependent
	game[level.gameType]["prop_flag_neutral"] = "prop_flag_neutral";
	precacheModel( game[level.gameType]["prop_flag_neutral"] );	
	precacheStatusIcon( "hud_status_flag" );
	
	precacheShader( "compass_waypoint_captureneutral" );
	precacheShader( "compass_waypoint_capture" );
	precacheShader( "compass_waypoint_defend" );
	precacheShader( "compass_waypoint_target" );
	precacheShader( "waypoint_captureneutral" );
	precacheShader( "waypoint_capture" );
	precacheShader( "waypoint_defend" );
	precacheShader( "waypoint_kill" );
	
	// Voiceovers
	//game["dialog"]["defend"] = "defend";
	game["dialog"]["capture_obj"] = "capture_obj";
	game["dialog"]["lostobj"] = "lostobj";
	game["dialog"]["obj_defend"] = "obj_defend";
	
	// Precache strings
	precacheString( &"OW_CH_FLAG_TAKEN_ENEMY" );
	precacheString( &"OW_CH_FLAG_TAKEN" );
	precacheString( &"OW_CH_FLAG_LOST_ENEMY" );
	precacheString( &"OW_CH_FLAG_LOST" );
	precacheString( &"OW_CH_SCORE_IN" );
}


/*
=============
onStartGameType

Show objectives to the player, initialize spawn points, and register score information
=============
*/
onStartGameType()
{
	// Check if this map supports native CH
	nativeCH = isDefined( getEnt( "ch_trig", "targetname" ) );

	if ( level.scr_ch_chmode == 0 ) {
		maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OW_CH_MODE0" );
		maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OW_CH_MODE0" );
	} else {
		maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OW_CH_MODE1" );
		maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OW_CH_MODE1" );
	}

	if ( level.splitscreen )
	{
		if ( level.scr_ch_chmode == 0 ) {
			maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OW_CH_MODE0" );
			maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OW_CH_MODE0" );
		} else {
			maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OW_CH_MODE1" );
			maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OW_CH_MODE1" );
		}
	}
	else
	{
		if ( level.scr_ch_chmode == 0 ) {
			maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OW_CH_SCORE_MODE0" );
			maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OW_CH_SCORE_MODE0" );
		} else {
			maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OW_CH_SCORE_MODE1" );
			maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OW_CH_SCORE_MODE1" );
		}
	}
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"OW_CH_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"OW_CH_HINT" );

	setClientNameMode("auto_change");

	// Check if we need to switch sides
	if ( game["switchedsides"] ) {
		level.alliesAssets = "axis";
		level.axisAssets = "allies";
	} else {
		level.alliesAssets = "allies";
		level.axisAssets = "axis";
	}

	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );

	// If the map doesn't support CH natively we'll use the location of Sabotage's assets
	if ( nativeCH ) {
		spawnType = "ch";
	} else {
		spawnType = "sab";
		// Let's get the trigger origins of the bomb before we get rid of all the map assets
		level.flagOrigin = getOriginFromBomb();
	}

	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_" + spawnType + "_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_" + spawnType + "_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_" + spawnType + "_spawn_allies" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_" + spawnType + "_spawn_axis" );

	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );

	level.spawn_axis = getentarray( "mp_" + spawnType + "_spawn_" + level.axisAssets, "classname" );
	level.spawn_allies = getentarray( "mp_" + spawnType + "_spawn_" + level.alliesAssets, "classname" );
	level.spawn_axis_start = getentarray("mp_" + spawnType + "_spawn_" + level.axisAssets + "_start", "classname" );
	level.spawn_allies_start = getentarray("mp_" + spawnType + "_spawn_" + level.alliesAssets + "_start", "classname" );
	level.startPos["allies"] = level.spawn_allies_start[0].origin;
	level.startPos["axis"] = level.spawn_axis_start[0].origin;

	level.displayRoundEndText = true;

	allowed[0] = "ch";
	maps\mp\gametypes\_gameobjects::main(allowed);

	thread captureAndHold();
}


/*
=============
getOriginFromBomb

Get the origin of an entity to be used in case entities need to be manually created
=============
*/
getOriginFromBomb()
{
	bombLocation = getEnt( "sab_bomb_pickup_trig", "targetname" );
	if ( isDefined( bombLocation ) ) {
		trace = playerPhysicsTrace( bombLocation.origin + (0,0,20), bombLocation.origin - (0,0,2000), false, undefined );
		return trace;
	}
	return;	
}



onTimeLimit()
{
	if ( level.inOvertime )
		return;

	thread onOvertime();
}



onOvertime()
{
	level endon ( "game_ended" );

	level.timeLimitOverride = true;
	level.inOvertime = true;

	for ( index = 0; index < level.players.size; index++ )
	{
		level.players[index] notify("force_spawn");
		level.players[index] thread maps\mp\gametypes\_hud_message::oldNotifyMessage( &"MP_SUDDEN_DEATH", &"MP_NO_RESPAWN", undefined, (1, 0, 0), "mp_last_stand" );

		if ( level.scr_ch_suddendeath_show_enemies == 1 ) {
			level.players[index] setClientDvars("cg_deadChatWithDead", 1,
								"cg_deadChatWithTeam", 0,
								"cg_deadHearTeamLiving", 0,
								"cg_deadHearAllLiving", 0,
								"cg_everyoneHearsEveryone", 0,
								"g_compassShowEnemies", 1 );
		}
	}

	if ( level.scr_ch_suddendeath_timelimit > 0 ) {
		waitTime = 0;
		while ( waitTime < level.scr_ch_suddendeath_timelimit ) {
			waitTime += 1;
			setGameEndTime( getTime() + ( ( level.scr_ch_suddendeath_timelimit - waitTime ) * 1000 ) );
			wait ( 1.0 );
		}
		thread maps\mp\gametypes\_globallogic::endGame( "tie", game["strings"]["tie"] );
	} else {
		level.timelimit = 0;
	}
}



/*
=============
onRoundSwitch

Switches the value of the variable to determine if sides needs to be switched
=============
*/
onRoundSwitch()
{
	// Just change the value for the variable controlling which map assets will be assigned to each team
	level.halftimeType = "halftime";
	game["switchedsides"] = !game["switchedsides"];
}


/*
=============
onDeadEvent

Declares the winner in the case a team has been eliminated or a tie in case both teams have been eliminated
=============
*/
onDeadEvent( team )
{
	// Make sure players on both teams were not eliminated
	if ( team != "all" ) {
		[[level._setTeamScore]]( getOtherTeam(team), [[level._getTeamScore]]( getOtherTeam(team) ) + 1 );
		thread maps\mp\gametypes\_globallogic::endGame( getOtherTeam(team), game["strings"][team + "_eliminated"] );
	} else {
		if ( level.scr_ch_chmode == 0 ) {
			thread onTimeLimit();
		} else {
			thread maps\mp\gametypes\_globallogic::default_onTimeLimit();
		}
	}
}


/*
=============
onSpawnPlayer

Determines what spawn points to use and spawns the player
=============
*/
onSpawnPlayer()
{
	self.isFlagCarrier = false;

	spawnteam = self.pers["team"];

	if ( level.useStartSpawns )
	{
		if (spawnteam == "axis")
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_axis_start);
		else
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_allies_start);
	}
	else
	{
		if (spawnteam == "axis")
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(level.spawn_axis);
		else
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(level.spawn_allies);
	}
	assert( isDefined(spawnpoint) );

	self spawn( spawnpoint.origin, spawnpoint.angles );
}


/*
=============
captureAndHold

Initializes all the map entities to be used or creates them (based on Sabotage) in the case
the native CH assets are not present. 
=============
*/
captureAndHold()
{
	// Initialize some variables to keep track of holding times
	level.lastStatus["allies"] = 0;
	level.lastStatus["axis"] = 0;
	level.gameStatus = [];
	level.gameStatus[ "allies_current_holdtime" ] = 0;
	level.gameStatus[ "allies_max_holdtime" ] = 0;
	level.gameStatus[ "axis_current_holdtime" ] = 0;
	level.gameStatus[ "axis_max_holdtime" ] = 0;

	// Make sure the map has all the assets we need
	gametypeAssets = [];
	gametypeAssets["flag_trigger"] = getEnt( "ch_trig", "targetname" );
	if ( !isDefined( gametypeAssets["flag_trigger"] ) ) {
		// Check if we can manually create the trigger
		if ( isDefined( level.flagOrigin ) ) {
			gametypeAssets["flag_trigger"] = spawn( "trigger_radius", level.flagOrigin, 0, 20, 100 );
		} else {
			error( "No ch_trig trigger found in map." );
			maps\mp\gametypes\_callbacksetup::AbortLevel();
			return;
		}
	}
	gametypeAssets["flag"] = [];
	gametypeAssets["flag"][0] = getEnt( "ch_flag", "targetname" );
	if ( !isDefined( gametypeAssets["flag"][0] ) ) {
		// Check if we can manually create the script model
		if ( isDefined( level.flagOrigin ) ) {
			gametypeAssets["flag"][0] = spawn( "script_model", level.flagOrigin );
		} else {
			error( "No ch_flag script model found in map." );
			maps\mp\gametypes\_callbacksetup::AbortLevel();
			return;
		}
	}

	// Create the flag carry object
	gametypeAssets["flag"][0] setModel( game[level.gameType]["prop_flag_neutral"] );
	level.flag = createFlagObject( gametypeAssets["flag_trigger"], gametypeAssets["flag"] );
	
	// Set the waypoint for the objective
	level.flag thread resetObjectiveWaypoint();
	
	// Create the timer that will show how much time is left for the holder to score
	if ( level.scr_ch_chmode == 0 ) {
		level.timerDisplay = [];
		level.timerDisplay["allies"] = createServerTimer( "objective", 1.4, "allies" );
		level.timerDisplay["allies"] setPoint( "TOPRIGHT", "TOPRIGHT", 0, 0 );
		level.timerDisplay["allies"].alpha = 0;
		level.timerDisplay["allies"].archived = false;
		level.timerDisplay["allies"].hideWhenInMenu = true;
	
		level.timerDisplay["axis"] = createServerTimer( "objective", 1.4, "axis" );
		level.timerDisplay["axis"] setPoint( "TOPRIGHT", "TOPRIGHT", 0, 0 );
		level.timerDisplay["axis"].alpha = 0;
		level.timerDisplay["axis"].archived = false;
		level.timerDisplay["axis"].hideWhenInMenu = true;
	}
}


/*
=============
createFlagObject

Creates the flag object that players need to capture
=============
*/
createFlagObject( trigger, visuals )
{
	// Create the flag object
	flagObject = maps\mp\gametypes\_gameobjects::createCarryObject( "neutral", trigger, visuals, (0,0,100) );
	flagObject.objIDPingEnemy = true;
	flagObject.onPickup = ::onPickup;
	flagObject.onDrop = ::onDrop;
	flagObject.onReset = ::onReset;
	flagObject.allowWeapons = true;
	flagObject.objPoints["allies"].archived = true;
	flagObject.objPoints["axis"].archived = true;
	flagObject.autoResetTime = 60.0;
	flagObject maps\mp\gametypes\_gameobjects::allowCarry( "any" );

	return flagObject;
}


/*
=============
resetObjectiveWaypoint

Reset the waypoint depending whether the flag is neutral or not
=============
*/
resetObjectiveWaypoint()
{
	// Update the waypoints
	if ( isDefined( self.carrier ) ) {
		// Show the defend icons to teammates
		self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_defend" );
		self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defend" );

		// Check if we should show the KILL icon to the enemies
		if ( level.scr_ch_show_flag_carrier == 0 || level.scr_ch_show_flag_carrier == 2 ) {
			self maps\mp\gametypes\_gameobjects::setVisibleTeam( "friendly" );
		} else {
			self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_target" );
			self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_kill" );			
			self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
		}

		// Check if we need to monitor the player carrying the flag
		if ( level.scr_ch_show_flag_carrier ==  2 ) {
			self thread monitorFlagCarrier( self.carrier );
		}
			
	} else {
		// Check which kind of waypoints we need to show
		if ( self.ownerTeam == "neutral" ) {
			showWaypoint = "waypoint_captureneutral";
			showCompass = "compass_waypoint_captureneutral";
		} else {
			showWaypoint = "waypoint_capture";
			showCompass = "compass_waypoint_capture";
		}	
		
		self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", showCompass );
		self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", showWaypoint );
		self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", showCompass );
		self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", showWaypoint );
		self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	}
}


/*
=============
onPlayerKilled

Checks if the victim was killed within 15 meters of the flag and give the score for defending the flag
to the attacker
=============
*/
onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	// Make sure the attacker is not in the same team
	if ( isPlayer( attacker ) && self.pers["team"] != attacker.pers["team"] ) {

		// Check if the victim was the flag carrier
		if ( self.isFlagCarrier ) {
			attacker thread [[level.onXPEvent]]( "killcarrier" );
			maps\mp\gametypes\_globallogic::givePlayerScore( "killcarrier", attacker );			
		} else {
			// Make sure the flag is owned by the attacker's team to give defending points
			if ( level.flag.ownerTeam == attacker.pers["team"] ) {
				// Get the distance between the victim and the flag
				distanceToFlag = distance( self.origin, level.flag.curOrigin );
		
				// 591 units = 15 meters
				if ( distanceToFlag <= 591 ) {
					attacker thread [[level.onXPEvent]]( "defend" );
					maps\mp\gametypes\_globallogic::givePlayerScore( "defend", attacker );
				}
			}
		}
	}
}


/*
=============
monitorFlagCarrier

Monitors the flag carrier to displays the KILL icon in case the flag carrier is camping
=============
*/
monitorFlagCarrier( flagCarrier )
{
	level endon( "flag_dropped" );
	level endon( "flag_hold" );
	flagCarrier endon("disconnect");
	flagCarrier endon("death");		

	// Check if we just have to show the KILL icon after certain time
	if ( level.scr_ch_show_flag_carrier_time > 0 && level.scr_ch_show_flag_carrier_distance == 0 ) {
		// Wait the time
		xWait( level.scr_ch_show_flag_carrier_time );

		// Show the KILL icon
		flagCarrier playLocalSound( game["voice"][flagCarrier.pers["team"]] + "new_positions" );
		self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
		self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_target" );
		self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_kill" );

		return;
	}

	// Monitor that the player is moving certain amount of distance in a given time or show him on the radar
	oldPlayerPosition = flagCarrier.origin;
	for (;;)
	{
		// Wait for the given time
		xWait( level.scr_ch_show_flag_carrier_time );

		// Get the distance and update the current's player position
		distanceMoved = distance( oldPlayerPosition, flagCarrier.origin );

		// Check if the player has moved enough distance
		if ( distanceMoved < level.scr_ch_show_flag_carrier_distance ) {

			// Show the player in the enemies radar for 2 seconds
			flagCarrier playLocalSound( game["voice"][flagCarrier.pers["team"]] + "new_positions" );
			self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
			self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_target" );
			self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_kill" );

			xWait( 5 );

			// Disable the KILL icon
			self maps\mp\gametypes\_gameobjects::setVisibleTeam( "friendly" );
			self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", undefined );
			self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", undefined );
		}

		// Get the player's current position and start waiting again for the next check
		oldPlayerPosition = flagCarrier.origin;
	}
}


/*
=============
onPickup

Pickups the flag 
=============
*/
onPickup( player )
{
	level notify( "flag_picked_up", self, player );

	playerTeam = player.pers["team"];

	// Reset the model of the flag so when it's dropped it will have the correct team
	if ( self.ownerTeam != playerTeam ) {
		self.visuals[0] setModel( game[level.gameType]["prop_flag_" + playerTeam ] );
		self maps\mp\gametypes\_gameobjects::setCarryIcon( game[level.gameType]["hud_flag_" + self.ownerTeam ] );
	}
	
	// Reset the time of the other team
	if ( self.ownerTeam != "neutral" ) {
		level.gameStatus[ getOtherTeam( self.ownerTeam ) + "_current_holdtime" ] = 0;
		thread forceSpawnTeam( self.ownerTeam );
		
	} else {
		// Give the player the take score because the flag was neutral
		player thread [[level.onXPEvent]]( "take" );
		maps\mp\gametypes\_globallogic::givePlayerScore( "take", player );
	}
	
	// Set team ownership
	self thread maps\mp\gametypes\_gameobjects::setOwnerTeam( playerTeam );

	// Stop using start spawns
	level.useStartSpawns = false;

	// Set this player as the flag carrier, set up the scoreboard status
	player.isFlagCarrier = true;
	if ( level.scr_ch_scoreboard_flag_carrier == 1 ) {
		player.statusicon = "hud_status_flag";
	}

	// Play the corresponding sounds for players
	thread printAndSoundOnEveryone( playerTeam, getOtherTeam( playerTeam ), &"OW_CH_FLAG_TAKEN", &"OW_CH_FLAG_TAKEN_ENEMY", "mp_enemy_obj_taken", "mp_obj_taken", player, "" );
	statusDialog( "obj_defend", playerTeam );
	
	// Attach the flag model to the player and log the event
	player thread maps\mp\gametypes\_gameobjects::attachUseModel( game[level.gameType]["prop_flag_" + self.ownerTeam + "_carry" ], "J_SpineLower", true );
	player logString( "flag taken" );

	lpselfnum = player getEntityNumber();
	lpGuid = player getGuid();
	logPrint("FT;" + lpGuid + ";" + lpselfnum + ";" + player.name + "\n");
	
	// Update waypoints
	self thread resetObjectiveWaypoint();
	
	// Monitor hold time
	self thread monitorFlagHoldTime( player );
}


/*
=============
monitorFlagHoldTime

Monitors the time the flag has been hold 
=============
*/
monitorFlagHoldTime( player )
{
	level endon( "flag_dropped" );
	player endon( "disconnect" );
	player endon( "death" );
	
	// Show the time left
	if ( level.scr_ch_chmode == 0 ) {
		level.timerDisplay["allies"] setTimer( level.scr_ch_holdtime - level.gameStatus[ self.ownerTeam + "_current_holdtime" ] );
		level.timerDisplay["axis"] setTimer( level.scr_ch_holdtime - level.gameStatus[ self.ownerTeam + "_current_holdtime" ] );
		level.timerDisplay[ self.ownerTeam ].label = &"OW_CH_HAVE_FLAG";
		level.timerDisplay[ getOtherTeam(self.ownerTeam) ].label = &"OW_CH_DONTHAVE_FLAG";
		level.timerDisplay["allies"].alpha = 1;
		level.timerDisplay["axis"].alpha = 1;
	}
	
	giveScore = 0;
	
	while ( isDefined( self.carrier ) && ( level.scr_ch_chmode == 1 || level.gameStatus[ self.ownerTeam + "_current_holdtime" ] < level.scr_ch_holdtime ) ) {
		xWait(1);
		giveScore++;
		
		// Give score to player
		if ( giveScore == 5 ) {
			giveScore = 0;
			player thread [[level.onXPEvent]]( "holding" );
			maps\mp\gametypes\_globallogic::givePlayerScore( "holding", player );
				
			// Give team score
			if ( level.scr_ch_chmode == 1 ) {
				[[level._setTeamScore]]( player.pers["team"], [[level._getTeamScore]]( player.pers["team"] ) + maps\mp\gametypes\_rank::getScoreInfoValue( "holding" ) );				
			}
		}
						
		// Update internal variables
		level.gameStatus[ self.ownerTeam + "_current_holdtime" ]++;
		level.gameStatus[ self.ownerTeam + "_max_holdtime" ]++;
	}
	
	// Check if the player hold the flag for the proper amount of time
	if ( level.scr_ch_chmode == 0 && level.gameStatus[ self.ownerTeam + "_current_holdtime" ] >= level.scr_ch_holdtime ) {
		self thread teamScored( player );
	}
}


/*
=============
teamScored

Team has scored, give team the point and end the round
=============
*/
teamScored( player )
{
	level notify( "flag_hold", self, player );

	// Give the team a point
	[[level._setTeamScore]]( player.pers["team"], [[level._getTeamScore]]( player.pers["team"] ) + 1 );
	player logString( "flag hold" );

	lpselfnum = player getEntityNumber();
	lpGuid = player getGuid();
	logPrint("FH;" + lpGuid + ";" + lpselfnum + ";" + player.name + "\n");
	
	// End the round
	thread maps\mp\gametypes\_globallogic::endGame( player.pers["team"], game["strings"][player.pers["team"] + "_win_round"] );
}


/*
=============
onDrop

Update waypoint and start counting to reset it
=============
*/
onDrop( player )
{
	level notify( "flag_dropped", self, player );

	flagTeam = self maps\mp\gametypes\_gameobjects::getOwnerTeam();

	// Hide the hold time left
	if ( level.scr_ch_chmode == 0 ) {
		level.timerDisplay["allies"].alpha = 0;
		level.timerDisplay["axis"].alpha = 0;
	}
	
	// Check for maximum hold time
	if ( level.gameStatus[ flagTeam + "_current_holdtime" ] > level.gameStatus[ flagTeam + "_max_holdtime" ] ) {
		level.gameStatus[ flagTeam + "_max_holdtime" ] = level.gameStatus[ flagTeam + "_current_holdtime" ];
	}

	if ( isDefined( player ) ) {
		// Player is not the flag carrier anymore.
		if ( isAlive( player ) ) {
			player thread maps\mp\gametypes\_gameobjects::detachUseModels();
			player.isFlagCarrier = false;
		}

		// If scoreboard flag carrier is active and the player is alive remove the icon
		if ( level.scr_ch_scoreboard_flag_carrier == 1 && isAlive( player ) ) {
			player.statusicon = "";
		}
		player logString( "flag dropped" );
		thread printAndSoundOnEveryone( flagTeam, getOtherTeam( flagTeam ), &"OW_CH_FLAG_LOST", &"OW_CH_FLAG_LOST_ENEMY", "mp_war_objective_taken", "mp_war_objective_lost", player, "" );
	} else {
		logString( "flag dropped" );
	}
	
	// Play sound and show the proper message
	statusDialog( "lostobj", flagTeam );
	
	// Update the waypoint
	self maps\mp\gametypes\_gameobjects::clearCarrier();
	self thread resetObjectiveWaypoint();

	// Monitor flag's ownership time
	self thread monitorFlagNeutralTime();
}


/*
=============
monitorFlagNeutralTime

Monitors how long the flag has been sitting with no owner after being dropped
=============
*/
monitorFlagNeutralTime()
{
	level endon( "flag_picked_up" );
	ownerTeam = level.flag.ownerTeam;
	
	// Calculate when the flag should turn to neutral and wait
	ownershipEnds = openwarfare\_timer::getTimePassed() + level.scr_ch_neutraltime * 1000;
	while ( ownershipEnds > openwarfare\_timer::getTimePassed() && !isDefined( self.carrier ) ) {
		wait (0.5);		
	}
	
	// Check if ownership has been lost and reset the time for the teams
	if ( ownershipEnds <= openwarfare\_timer::getTimePassed() ) {
		level.gameStatus[ self.ownerTeam + "_current_holdtime" ] = 0;
		self.visuals[0] setModel( game[level.gameType]["prop_flag_neutral"] );
		self maps\mp\gametypes\_gameobjects::setOwnerTeam( "neutral" );
			
		thread forceSpawnTeam( ownerTeam );
		
		// Play some sound so players know that the ownership has been returned to neutral
		thread printAndSoundOnEveryone( "axis", "allies", &"", &"", "mp_obj_returned", "mp_obj_returned", "", "" );
		
		// Update the waypoins
		self thread resetObjectiveWaypoint();
	}	
}


/*
=============
onReset

Flag has been returned automatically by the game after 60 seconds
=============
*/
onReset( player )
{
	level notify( "flag_returned", self );

	// Play the corresponding sounds for players
	thread printAndSoundOnEveryone( "axis", "allies", &"", &"", "mp_enemy_obj_returned", "mp_enemy_obj_returned", "", "" );
	statusDialog( "capture_obj", "axis" );
	statusDialog( "capture_obj", "allies" );
	logString( "flag returned" );
}


statusDialog( dialog, team )
{
	time = getTime();
	if ( getTime() < level.lastStatus[team] + 5000 )
		return;

	thread delayedLeaderDialog( dialog, team );
	level.lastStatus[team] = getTime();
}


delayedLeaderDialog( sound, team )
{
	wait .1;
	maps\mp\gametypes\_globallogic::WaitTillSlowProcessAllowed();
	maps\mp\gametypes\_globallogic::leaderDialog( sound, team );
}


getRespawnDelay()
{
	self.lowerMessageOverride = undefined;

	if ( level.flag.ownerTeam == "neutral" )
		return undefined;

	flagOwningTeam = level.flag.ownerTeam;
	if ( self.pers["team"] == flagOwningTeam )
	{
		self.lowerMessageOverride = &"OW_CH_WAITING_FOR_FLAG";
		return level.scr_ch_ownerspawndelay;
	}
	
	return undefined;
}


forceSpawnTeam( team )
{
	if ( level.scr_ch_ownerspawndelay == 0 )
		return;
		
	players = level.players;
	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];
		if ( !isdefined( player ) )
			continue;

		if ( player.pers["team"] == team )
		{
			player.lowerMessageOverride = undefined;
			player notify( "force_spawn" );
			wait .1;
		}
	}
}