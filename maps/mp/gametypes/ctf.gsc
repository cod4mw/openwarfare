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

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include openwarfare\_utils;

/*
	Capture the Flag

	Objective: Capture the enemy's flag and return it to the base
	Map ends: When one team reaches the score limit, or the time limit is reached
	Respawning: No wait / Near teammates

	Level requirements
	------------------
		Spawnpoints:
			classname	mp_ctf_spawn_allies_start, mp_ctf_spawn_axis_start
			All players spawn from these at the beginning of the round. These
			spawn points will be used until one team captures the other team's
			flag.

			classname	mp_ctf_spawn_allies, mp_ctf_spawn_axis
			All players will spawn from these after a team has taken the other's
			team's flag.

		Spectator spawnpoints:
			classname	mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			At least one is required, any more and they are randomly chosen between.

		Flags:
			classname script_model targetname ctf_flag_allies, ctf_flag_axis
			classname trigger_radius targetname ctf_trig_allies, ctf_trig_axis
			Flags that need to be captured and returned to the base.

		Capture Zones:
			classname trigger_radius targetname ctf_zone_allies, ctf_zone_axis
			Zones were players have to return the enemy flag to score a team point.

		Note:
			In the case the map doesn't support the above CTF assets natively this
			implementation of CTF will try to use the location of the bomb zones from
			Sabotage to determine the position of the flags. It will then use these
			positions to create the needed assets for Capture the Flag.
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
	level.scr_ctf_ctfmode = getdvarx( "scr_ctf_ctfmode", "int", 0, 0, 2  );
	level.scr_ctf_endround_on_capture = getdvarx( "scr_ctf_endround_on_capture", "int", 0, 0, 1  );
	level.scr_ctf_flag_carrier_can_return = getdvarx( "scr_ctf_flag_carrier_can_return", "int", 1, 0, 1  );
	level.scr_ctf_show_flag_carrier = getdvarx( "scr_ctf_show_flag_carrier", "int", 0, 0, 2  );
	level.scr_ctf_scoreboard_flag_carrier = getdvarx( "scr_ctf_scoreboard_flag_carrier", "int", 1, 0, 1 );
	level.scr_ctf_show_flag_carrier_time = getdvarx( "scr_ctf_show_flag_carrier_time", "int", 5, 5, 600 );
	level.scr_ctf_show_flag_carrier_distance = getdvarx( "scr_ctf_show_flag_carrier_distance", "int", 0, 0, 1000 );

	level.scr_ctf_suddendeath_show_enemies = getdvarx( "scr_ctf_suddendeath_show_enemies", "int", 1, 0, 1 );
	level.scr_ctf_suddendeath_timelimit = getdvarx( "scr_ctf_suddendeath_timelimit", "int", 90, 0, 600 );
	
	level.scr_ctf_idleflagreturntime = getdvarx( "scr_ctf_idleflagreturntime", "float", 60, 0, 120 );
	if ( level.scr_ctf_idleflagreturntime == 0 && level.scr_ctf_ctfmode == 1 ) {
		level.scr_ctf_ctfmode = 0;
	}

	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	// Get the dvars we need for this gametype
	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 0, 0, 10 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 2, 1, 500 );
	maps\mp\gametypes\_globallogic::registerRoundSwitchDvar( level.gameType, 1, 0, 500 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 0, 0, 5000 );
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
		
	if ( level.scr_ctf_endround_on_capture == 1 ) {
		level.onTimeLimit = ::onTimeLimit;
	}
	
	game["dialog"]["offense_obj"] = "boost";
	game["dialog"]["defense_obj"] = "boost";	
	game["dialog"]["gametype"] = gameTypeDialog( "captureflag" );

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
		game[level.gameType]["compass_waypoint_flag_allies"] = "objpoint_flag_american";
		game[level.gameType]["waypoint_flag_allies"] = "objpoint_flag_american";
		game[level.gameType]["waypoint_flag_allies_x"] = "objpoint_flag_x_american";
		game[level.gameType]["hud_flag_allies"] = "objpoint_flag_american";
		game[level.gameType]["flag_base_allies"] = loadFX( "misc/ui_flagbase_silver" );
	} else {
		game[level.gameType]["prop_flag_allies"] = "prop_flag_brit";
		game[level.gameType]["prop_flag_allies_carry"] = "prop_flag_brit_carry";
		game[level.gameType]["compass_waypoint_flag_allies"] = "objpoint_flag_british";
		game[level.gameType]["waypoint_flag_allies"] = "objpoint_flag_british";
		game[level.gameType]["waypoint_flag_allies_x"] = "objpoint_flag_x_british";
		game[level.gameType]["hud_flag_allies"] = "objpoint_flag_british";
		game[level.gameType]["flag_base_allies"] = loadFX( "misc/ui_flagbase_black" );
	}
	// Precache everything (no matter that we precache the same thing more than once, we have it anyway
	// in case someone decides to use different images)
	precacheModel( game[level.gameType]["prop_flag_allies"] );
	precacheModel( game[level.gameType]["prop_flag_allies_carry"] );
	precacheShader( game[level.gameType]["compass_waypoint_flag_allies"] );
	precacheShader( game[level.gameType]["waypoint_flag_allies"] );
	precacheShader( game[level.gameType]["waypoint_flag_allies_x"] );
	precacheShader( game[level.gameType]["hud_flag_allies"] );

	// Precache team dependent assets for axis
	if ( game["axis"] == "russian" ) {
		game[level.gameType]["prop_flag_axis"] = "prop_flag_russian";
		game[level.gameType]["prop_flag_axis_carry"] = "prop_flag_russian_carry";
		game[level.gameType]["compass_waypoint_flag_axis"] = "objpoint_flag_russian";
		game[level.gameType]["waypoint_flag_axis"] = "objpoint_flag_russian";
		game[level.gameType]["waypoint_flag_axis_x"] = "objpoint_flag_x_russian";
		game[level.gameType]["hud_flag_axis"] = "objpoint_flag_russian";
		game[level.gameType]["flag_base_axis"] = loadFX( "misc/ui_flagbase_red" );
	} else {
		game[level.gameType]["prop_flag_axis"] = "prop_flag_opfor";
		game[level.gameType]["prop_flag_axis_carry"] = "prop_flag_opfor_carry";
		game[level.gameType]["compass_waypoint_flag_axis"] = "objpoint_flag_opfor";
		game[level.gameType]["waypoint_flag_axis"] = "objpoint_flag_opfor";
		game[level.gameType]["waypoint_flag_axis_x"] = "objpoint_flag_x_opfor";
		game[level.gameType]["hud_flag_axis"] = "objpoint_flag_opfor";
		game[level.gameType]["flag_base_axis"] = loadFX( "misc/ui_flagbase_gold" );
	}

	// Precache everything (no matter that we precache the same thing more than once, we have it anyway
	// in case someone decides to use different images)
	precacheModel( game[level.gameType]["prop_flag_axis"] );
	precacheModel( game[level.gameType]["prop_flag_axis_carry"] );
	precacheShader( game[level.gameType]["compass_waypoint_flag_axis"] );
	precacheShader( game[level.gameType]["waypoint_flag_axis"] );
	precacheShader( game[level.gameType]["waypoint_flag_axis_x"] );
	precacheShader( game[level.gameType]["hud_flag_axis"] );

	// Precache other assets that are not team dependent
	precacheStatusIcon( "hud_status_flag" );
	precacheShader( "compass_waypoint_target" );
	precacheShader( "waypoint_kill" );
	precacheShader( "compass_waypoint_defend" );
	precacheShader( "waypoint_defend" );

	// Voiceovers
	game["dialog"]["ourflag"] = "ourflag";
	game["dialog"]["ourflag_capt"] = "ourflag_capt";
	game["dialog"]["ourflag_drop"] = "ourflag_drop";
	game["dialog"]["ourflag_return"] = "ourflag_return";
	game["dialog"]["enemyflag"] = "enemyflag";
	game["dialog"]["enemyflag_capt"] = "enemyflag_capt";
	game["dialog"]["enemyflag_drop"] = "enemyflag_drop";
	game["dialog"]["enemyflag_return"] = "enemyflag_return";

	// Precache strings - What happened to the 4 missing strings IW? You are making me work here... ;)
	precacheString( &"MP_ENEMY_FLAG_CAPTURED_BY" );
	precacheString( &"MP_ENEMY_FLAG_DROPPED_BY" );
	precacheString( &"MP_ENEMY_FLAG_RETURNED" );
	precacheString( &"MP_ENEMY_FLAG_TAKEN" );
	precacheString( &"MP_ENEMY_FLAG_TAKEN_BY" );
	precacheString( &"OW_ENEMY_FLAG_DROPPED" );
	precacheString( &"OW_ENEMY_FLAG_RETURNED_BY" );
	precacheString( &"MP_FLAG_CAPTURED_BY" );
	precacheString( &"MP_FLAG_RETURNED" );
	precacheString( &"MP_FLAG_RETURNED_BY" );
	precacheString( &"MP_FLAG_TAKEN_BY" );
	precacheString( &"OW_FLAG_DROPPED" );
	precacheString( &"OW_FLAG_DROPPED_BY" );
}



/*
=============
onStartGameType

Show objectives to the player, initialize spawn points, and register score information
=============
*/
onStartGameType()
{
	// Check if this map supports native CTF
	nativeCTF = isDefined( getEnt( "ctf_trig_allies", "targetname" ) );

	maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OBJECTIVES_CTF" );
	maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OBJECTIVES_CTF" );

	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OBJECTIVES_CTF" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OBJECTIVES_CTF" );
	}
	else
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OBJECTIVES_CTF_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OBJECTIVES_CTF_SCORE" );
	}
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"OBJECTIVES_CTF_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"OBJECTIVES_CTF_HINT" );
	
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

	// If the map doesn't support CTF natively we'll use the locations of Sabotage assets
	if ( nativeCTF ) {
		spawnType = "ctf";
	} else {
		spawnType = "sab";
		// Let's get the trigger origins of the bomb zones before we get rid of all the map assets
		level.origins["allies"] = getOriginFromBombZone( "sab_bomb_allies" );
		level.origins["axis"] = getOriginFromBombZone( "sab_bomb_axis" );
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

	allowed[0] = "ctf";
	maps\mp\gametypes\_gameobjects::main(allowed);

	thread captureTheFlag();
}



/*
=============
getOriginFromBombZone

Get the origin of an entity to be used in case entities need to be manually created
=============
*/
getOriginFromBombZone( entityName )
{
	bombZone = getEnt( entityName, "targetname" );
	if ( isDefined( bombZone ) ) {
		trace = playerPhysicsTrace( bombZone.origin + (0,0,20), bombZone.origin - (0,0,2000), false, undefined );
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

		if ( level.scr_ctf_suddendeath_show_enemies == 1 ) {
			level.players[index] setClientDvars("cg_deadChatWithDead", 1,
								"cg_deadChatWithTeam", 0,
								"cg_deadHearTeamLiving", 0,
								"cg_deadHearAllLiving", 0,
								"cg_everyoneHearsEveryone", 0,
								"g_compassShowEnemies", 1 );
		}
	}

	if ( level.scr_ctf_suddendeath_timelimit > 0 ) {
		waitTime = 0;
		while ( waitTime < level.scr_ctf_suddendeath_timelimit ) {
			waitTime += 1;
			setGameEndTime( getTime() + ( ( level.scr_ctf_suddendeath_timelimit - waitTime ) * 1000 ) );
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
		// We can't determine a winner if everyone died like in S&D so we declare a tie
		thread maps\mp\gametypes\_globallogic::endGame( "tie", game["strings"]["round_draw"] );
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
captureTheFlag

Initializes all the map entities to be used or creates them (based on Sabotage) in the case
the native CTF assets are not present. 
=============
*/
captureTheFlag()
{
	level.lastStatus["allies"] = 0;
	level.lastStatus["axis"] = 0;
	level.flags = [];
	level.zones = [];
	gametypeAssets = [];

	// Make sure the map has all the assets we need
	gametypeAssets["allies"] = [];
	gametypeAssets["allies"]["flag_trigger"] = getEnt( "ctf_trig_" + level.alliesAssets, "targetname" );
	if ( !isDefined( gametypeAssets["allies"]["flag_trigger"] ) ) {
		// Check if we can manually create the trigger
		if ( isDefined( level.origins[level.alliesAssets] ) ) {
			gametypeAssets["allies"]["flag_trigger"] = spawn( "trigger_radius", level.origins[level.alliesAssets], 0, 20, 100 );
		} else {
			error( "No ctf_trig_" + level.alliesAssets + " trigger found in map." );
			maps\mp\gametypes\_callbacksetup::AbortLevel();
			return;
		}
	}
	gametypeAssets["allies"]["flag"] = [];
	gametypeAssets["allies"]["flag"][0] = getEnt( "ctf_flag_" + level.alliesAssets, "targetname" );
	if ( !isDefined( gametypeAssets["allies"]["flag"][0] ) ) {
		// Check if we can manually create the script model
		if ( isDefined( level.origins[level.alliesAssets] ) ) {
			gametypeAssets["allies"]["flag"][0] = spawn( "script_model", level.origins[level.alliesAssets] );
		} else {
			error( "No ctf_flag_" + level.alliesAssets + " script model found in map." );
			maps\mp\gametypes\_callbacksetup::AbortLevel();
			return;
		}
	}
	gametypeAssets["allies"]["zone_trigger"] = getEnt( "ctf_zone_" + level.alliesAssets, "targetname" );
	if ( !isDefined( gametypeAssets["allies"]["zone_trigger"] ) ) {
		// Check if we can manually create the trigger
		if ( isDefined( level.origins[level.alliesAssets] ) ) {
			gametypeAssets["allies"]["zone_trigger"] = spawn( "trigger_radius", level.origins[level.alliesAssets], 0, 50, 100 );
		} else {
			error( "No ctf_zone_" + level.alliesAssets + " trigger found in map." );
			maps\mp\gametypes\_callbacksetup::AbortLevel();
			return;
		}
	}

	gametypeAssets["axis"] = [];
	gametypeAssets["axis"]["flag_trigger"] = getEnt( "ctf_trig_" + level.axisAssets, "targetname" );
	if ( !isDefined( gametypeAssets["axis"]["flag_trigger"] ) ) {
		// Check if we can manually create the trigger
		if ( isDefined( level.origins[level.axisAssets] ) ) {
			gametypeAssets["axis"]["flag_trigger"] = spawn( "trigger_radius", level.origins[level.axisAssets], 0, 20, 100 );
		} else {
			error( "No ctf_trig_" + level.axisAssets + " trigger found in map." );
			maps\mp\gametypes\_callbacksetup::AbortLevel();
			return;
		}
	}
	gametypeAssets["axis"]["flag"] = [];
	gametypeAssets["axis"]["flag"][0]  = getEnt( "ctf_flag_" + level.axisAssets, "targetname" );
	if ( !isDefined( gametypeAssets["axis"]["flag"][0] ) ) {
		// Check if we can manually create the script model
		if ( isDefined( level.origins[level.axisAssets] ) ) {
			gametypeAssets["axis"]["flag"][0] = spawn( "script_model", level.origins[level.axisAssets] );
		} else {
			error( "No ctf_flag_" + level.axisAssets + " script model found in map." );
			maps\mp\gametypes\_callbacksetup::AbortLevel();
			return;
		}
	}
	gametypeAssets["axis"]["zone_trigger"] = getEnt( "ctf_zone_" + level.axisAssets, "targetname" );
	if ( !isDefined( gametypeAssets["axis"]["zone_trigger"] ) ) {
		// Check if we can manually create the trigger
		if ( isDefined( level.origins[level.axisAssets] ) ) {
			gametypeAssets["axis"]["zone_trigger"] = spawn( "trigger_radius", level.origins[level.axisAssets], 0, 50, 100 );
		} else {
			error( "No ctf_zone_" + level.axisAssets + " trigger found in map." );
			maps\mp\gametypes\_callbacksetup::AbortLevel();
			return;
		}
	}

	// Create the flag carry objects
	gametypeAssets["allies"]["flag"][0] setModel( game[level.gameType]["prop_flag_allies"] );
	gametypeAssets["axis"]["flag"][0] setModel( game[level.gameType]["prop_flag_axis"] );
	level.flags["allies"] = createFlagObject( "allies", gametypeAssets["allies"]["flag_trigger"], gametypeAssets["allies"]["flag"] );
	level.flags["axis"] = createFlagObject( "axis", gametypeAssets["axis"]["flag_trigger"], gametypeAssets["axis"]["flag"] );

	// Create the capture zones
	level.zones["allies"] = createCaptureZone( "allies", gametypeAssets["allies"]["zone_trigger"] );
	level.zones["axis"] = createCaptureZone( "axis", gametypeAssets["axis"]["zone_trigger"] );

	// Set the waypoints for the objectives
	level.flags["allies"] resetObjectiveWaypoints( true );
	level.flags["axis"] resetObjectiveWaypoints( true );
	
	if ( level.scr_ctf_ctfmode == 1 ) {
		createReturnMessageElems();
	}
}


createReturnMessageElems()
{
	level.ReturnMessageElems = [];

	level.ReturnMessageElems["allies"]["axis"] = createServerTimer( "objective", 1.4, "allies" );
	level.ReturnMessageElems["allies"]["axis"] setPoint( "TOPRIGHT", "TOPRIGHT", 0, 15 );
	level.ReturnMessageElems["allies"]["axis"].label = &"OW_ENEMY_FLAG_RETURNING_IN";
	level.ReturnMessageElems["allies"]["axis"].alpha = 0;
	level.ReturnMessageElems["allies"]["axis"].archived = false;
	level.ReturnMessageElems["allies"]["allies"] = createServerTimer( "objective", 1.4, "allies" );
	level.ReturnMessageElems["allies"]["allies"] setPoint( "TOPRIGHT", "TOPRIGHT", 0, 0 );
	level.ReturnMessageElems["allies"]["allies"].label = &"OW_YOUR_FLAG_RETURNING_IN";
	level.ReturnMessageElems["allies"]["allies"].alpha = 0;
	level.ReturnMessageElems["allies"]["allies"].archived = false;

	level.ReturnMessageElems["axis"]["allies"] = createServerTimer( "objective", 1.4, "axis" );
	level.ReturnMessageElems["axis"]["allies"] setPoint( "TOPRIGHT", "TOPRIGHT", 0, 15 );
	level.ReturnMessageElems["axis"]["allies"].label = &"OW_ENEMY_FLAG_RETURNING_IN";
	level.ReturnMessageElems["axis"]["allies"].alpha = 0;
	level.ReturnMessageElems["axis"]["allies"].archived = false;
	level.ReturnMessageElems["axis"]["axis"] = createServerTimer( "objective", 1.4, "axis" );
	level.ReturnMessageElems["axis"]["axis"] setPoint( "TOPRIGHT", "TOPRIGHT", 0, 0 );
	level.ReturnMessageElems["axis"]["axis"].label = &"OW_YOUR_FLAG_RETURNING_IN";
	level.ReturnMessageElems["axis"]["axis"].alpha = 0;
	level.ReturnMessageElems["axis"]["axis"].archived = false;
}


returnFlagHudElems()
{
	level endon("game_ended");
	
	ownerTeam = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
	
	assert( !level.ReturnMessageElems["axis"][ownerTeam].alpha );
	level.ReturnMessageElems["axis"][ownerTeam].alpha = 1;
	level.ReturnMessageElems["axis"][ownerTeam] setTimer( level.scr_ctf_idleflagreturntime );
	
	assert( !level.ReturnMessageElems["allies"][ownerTeam].alpha );
	level.ReturnMessageElems["allies"][ownerTeam].alpha = 1;
	level.ReturnMessageElems["allies"][ownerTeam] setTimer( level.scr_ctf_idleflagreturntime );
	
	self waittill_any( "picked_up", "returned" );
	
	level.ReturnMessageElems["allies"][ownerTeam].alpha = 0;
	level.ReturnMessageElems["axis"][ownerTeam].alpha = 0;
}


/*
=============
createFlagObject

Creates the flag object that players need to steal from the enemy
=============
*/
createFlagObject( team, trigger, visuals )
{
	// Create the flag object
	flagObject = maps\mp\gametypes\_gameobjects::createCarryObject( team, trigger, visuals, (0,0,100) );
	flagObject maps\mp\gametypes\_gameobjects::setCarryIcon( game[level.gameType]["hud_flag_" + team] );
	flagObject maps\mp\gametypes\_gameobjects::allowCarry( "enemy" );
	flagObject.objIDPingFriendly = true;
	flagObject.onPickup = ::onPickup;
	flagObject.onPickupFailed = ::onPickupFailed;
	flagObject.onDrop = ::onDrop;
	flagObject.onReset = ::onReset;
	flagObject.allowWeapons = true;
	flagObject.objPoints["allies"].archived = true;
	flagObject.objPoints["axis"].archived = true;
	
	if ( level.scr_ctf_ctfmode == 1 ) {
		flagObject.autoResetTime = level.scr_ctf_idleflagreturntime;
	}

	return flagObject;
}



/*
=============
createCaptureZone

Creates a capture zone where players will need to return the enemy's flag to score a point
=============
*/
createCaptureZone( team, trigger )
{
	// Create the use object with 0 useTime so it's immediate
	captureZone = maps\mp\gametypes\_gameobjects::createUseObject( team, trigger, undefined, (0,0,100) );
	captureZone	maps\mp\gametypes\_gameobjects::allowUse( "friendly" );
	captureZone maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	captureZone maps\mp\gametypes\_gameobjects::setUseTime( 0 );
	captureZone.onUse = ::onUse;

	// Spawn an special effect at the base of the flag to indicate where it is located
	traceStart = trigger.origin + (0,0,32);
	traceEnd = trigger.origin + (0,0,-32);
	trace = bulletTrace( traceStart, traceEnd, false, undefined );
	upangles = vectorToAngles( trace["normal"] );
	level.flags[team].baseEffect = spawnFx( game[level.gameType]["flag_base_" + team], trace["position"], anglesToForward( upangles ), anglesToRight( upangles ) );
	triggerFx( level.flags[team].baseEffect );

	return captureZone;
}



/*
=============
onPickup

Returns the flag to the base in case the player is in the same team as the flag or
handles the carry of the flag when picked up by the enemy.
=============
*/
onPickup( player )
{
	level notify( self.ownerTeam + "_flag_picked_up", self, player );
	self notify( "picked_up", player );

	playerTeam = player.pers["team"];

	// If the player is in the same team as the flag then we need to return the flag
	if ( playerTeam == self.ownerTeam && level.scr_ctf_ctfmode == 0 ) {
		self flagReturned( player );
		return;
	}

	level.useStartSpawns = false;

	// Set this player as the flag carrier, set up the scoreboard status and give the proper score
	player.isFlagCarrier = true;
	if ( level.scr_ctf_scoreboard_flag_carrier == 1 ) {
		player.statusicon = "hud_status_flag";
	}

	// We only give "take" points when it's taken from the enemy's base
	if ( playerTeam != self.ownerTeam && self.curOrigin == self.trigger.baseOrigin ) {
		player thread [[level.onXPEvent]]( "take" );
		maps\mp\gametypes\_globallogic::givePlayerScore( "take", player );
	}

	// Play the corresponding sounds for players
	if ( playerTeam != self.ownerTeam ) {
		thread printAndSoundOnEveryone( playerTeam, getOtherTeam( playerTeam ), &"MP_ENEMY_FLAG_TAKEN_BY", &"MP_FLAG_TAKEN_BY", "mp_enemy_obj_taken", "mp_obj_taken", player );
		statusDialog( "enemyflag", playerTeam );
		statusDialog( "ourflag", getOtherTeam( playerTeam ) );
	} else {
		thread printAndSoundOnEveryone( playerTeam, getOtherTeam( playerTeam ), &"OW_FLAG_RECOVERED_BY", &"OW_ENEMY_FLAG_RECOVERED_BY", "mp_obj_taken", "mp_enemy_obj_taken", player );
	}

	// Attach the flag model to the player and log the event
	player thread maps\mp\gametypes\_gameobjects::attachUseModel( game[level.gameType]["prop_flag_" + self.ownerTeam + "_carry" ], "J_SpineLower", true );
	
	if ( playerTeam != self.ownerTeam ) {
		player logString( self.ownerTeam + " flag taken" );
	
		lpselfnum = player getEntityNumber();
		lpGuid = player getGuid();
		logPrint("FT;" + lpGuid + ";" + lpselfnum + ";" + player.name + "\n");
		
	} else {
		player logString( self.ownerTeam + " flag recovered" );
	
		lpselfnum = player getEntityNumber();
		lpGuid = player getGuid();
		logPrint("FV;" + lpGuid + ";" + lpselfnum + ";" + player.name + "\n");		
	}

	// Set the new icons to be displayed
	if ( level.scr_ctf_show_flag_carrier == 0 || level.scr_ctf_show_flag_carrier == 2 ) {
		// Only friendlies see the flag carrier in the minimap
		if ( playerTeam != self.ownerTeam ) {
			self maps\mp\gametypes\_gameobjects::setVisibleTeam( "enemy" );
		} else {
			self maps\mp\gametypes\_gameobjects::setVisibleTeam( "friendly" );
		}
	} else {
		// Kill waypoint is always enabled
		self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
		if ( playerTeam != self.ownerTeam ) {
			self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_target" );
			self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_kill" );
		} else {
			self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_target" );
			self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_kill" );
		}
	}

	// Check if we need to monitor the player carrying the flag
	if ( level.scr_ctf_show_flag_carrier ==  2 ) {
		self thread monitorFlagCarrier( player );
	}

	if ( playerTeam != self.ownerTeam ) {
		self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_defend" );
		self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_defend" );
	} else {
		self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_defend" );
		self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defend" );
	}

	// Set a 3D icon to show that the flag is not there anymore
	self resetObjectiveWaypoints( false );
}



/*
=============
onPickupFailed

Checkes if a player carrying the enemy flag can return his/her flag
=============
*/
onPickupFailed( player )
{
	// Check if flag carriers can return their own flag
	if ( level.scr_ctf_flag_carrier_can_return == 1 && level.scr_ctf_ctfmode == 0 ) {
		self flagReturned( player );
	}
}



/*
=============
flagReturned

Give player score points for returning the flag and returns the flag home
=============
*/
flagReturned( player )
{
	level notify( self.ownerTeam + "_flag_returned", self, player );
	
	// Give player the score for returning the flag
	player thread [[level.onXPEvent]]( "return" );
	maps\mp\gametypes\_globallogic::givePlayerScore( "return", player );
	// Stop the automatic reset time and return the flag home
	self notify( "stop_pickup_timeout" );
	self thread maps\mp\gametypes\_gameobjects::returnHome( player );
}



/*
=============
monitorFlagCarrier

Monitors the flag carrier to displays the KILL icon in case the flag carrier is camping
=============
*/
monitorFlagCarrier( flagCarrier )
{
	level endon( self.ownerTeam + "_flag_dropped" );
	level endon( self.ownerTeam + "_flag_captured" );	
	level endon( self.ownerTeam + "_flag_returned" );	
	flagCarrier endon("disconnect");
	flagCarrier endon("death");	

	playerTeam = flagCarrier.pers["team"];

	// Check if we just have to show the KILL icon after certain time
	if ( level.scr_ctf_show_flag_carrier_time > 0 && level.scr_ctf_show_flag_carrier_distance == 0 ) {
		// Wait the time
		xWait( level.scr_ctf_show_flag_carrier_time );

		// Show the KILL icon
		flagCarrier playLocalSound( game["voice"][flagCarrier.pers["team"]] + "new_positions" );
		self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
		if ( playerTeam != self.ownerTeam ) {
			self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_target" );
			self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_kill" );
		} else {
			self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_target" );
			self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_kill" );			
		}

		return;
	}

	// Monitor that the player is moving certain amount of distance in a given time or show him on the radar
	oldPlayerPosition = flagCarrier.origin;
	for (;;)
	{
		// Wait for the given time
		xWait( level.scr_ctf_show_flag_carrier_time );

		// Get the distance and update the current's player position
		distanceMoved = distance( oldPlayerPosition, flagCarrier.origin );

		// Check if the player has moved enough distance
		if ( distanceMoved < level.scr_ctf_show_flag_carrier_distance ) {

			// Show the player in the enemies radar for 2 seconds
			flagCarrier playLocalSound( game["voice"][flagCarrier.pers["team"]] + "new_positions" );
			self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
			if ( playerTeam != self.ownerTeam ) {
				self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_target" );
				self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_kill" );
			} else {
				self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_target" );
				self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_kill" );				
			}

			xWait( 5 );

			// Disable the KILL icon
			self maps\mp\gametypes\_gameobjects::setVisibleTeam( "friendly" );
			if ( playerTeam != self.ownerTeam ) {			
				self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", undefined );
				self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", undefined );
			} else {
				self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", undefined );
				self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", undefined );				
			}
		}

		// Get the player's current position and start waiting again for the next check
		oldPlayerPosition = flagCarrier.origin;
	}
}



/*
=============
onDrop

Determines if the owners of the flag can return it by touching it or not and re-initilizes the waypoints
=============
*/
onDrop( player )
{
	level notify( self.ownerTeam + "_flag_dropped", self, player );

	if ( isDefined( player ) ) {
		// Player is not the flag carrier anymore.
		if ( isAlive( player ) ) {
			player thread maps\mp\gametypes\_gameobjects::detachUseModels();
			player.isFlagCarrier = false;
		}

		// Play sound and show the proper message
		thread printAndSoundOnEveryone( self.ownerTeam, getOtherTeam( self.ownerTeam ), &"OW_FLAG_DROPPED_BY", &"MP_ENEMY_FLAG_DROPPED_BY", "mp_war_objective_taken", "mp_war_objective_lost", player );

		// If scoreboard flag carrier is active and the player is alive remove the icon
		if ( level.scr_ctf_scoreboard_flag_carrier == 1 && isAlive( player ) ) {
			player.statusicon = "";
		}
		player logString( self.ownerTeam + " flag dropped" );
	} else {
		thread printAndSoundOnEveryone( self.ownerTeam, getOtherTeam( self.ownerTeam ), &"OW_FLAG_DROPPED", &"OW_ENEMY_FLAG_DROPPED", "mp_war_objective_taken", "mp_war_objective_lost", "" );
		logString( self.ownerTeam + "flag dropped" );
	}
	statusDialog( "ourflag_drop", self.ownerTeam );
	statusDialog( "enemyflag_drop", getOtherTeam( self.ownerTeam ) );

	// Make the flag visible to everyone
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", game[level.gameType]["compass_waypoint_flag_" + self.ownerTeam ] );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", game[level.gameType]["waypoint_flag_" + self.ownerTeam ] );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", game[level.gameType]["compass_waypoint_flag_" + self.ownerTeam ] );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", game[level.gameType]["waypoint_flag_" + self.ownerTeam ] );
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );

	// Check if the team can return the flag by touching it
	if ( level.scr_ctf_ctfmode == 0 || level.scr_ctf_ctfmode == 2 ) {
		self maps\mp\gametypes\_gameobjects::allowCarry( "any" );
	} else {
		self thread returnFlagHudElems();
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
	level notify( self.ownerTeam + "_flag_returned", self, player );
	self notify( "returned", player );

	self resetObjectiveWaypoints( true );

	// Play the corresponding sounds for players
	if ( isDefined( player ) ) {
		thread printAndSoundOnEveryone( self.ownerTeam, getOtherTeam( self.ownerTeam ), &"MP_FLAG_RETURNED_BY", &"OW_ENEMY_FLAG_RETURNED_BY", "mp_obj_returned", "mp_enemy_obj_returned", player );
		player logString( self.ownerTeam + " flag returned" );

		lpselfnum = player getEntityNumber();
		lpGuid = player getGuid();
		logPrint("FR;" + lpGuid + ";" + lpselfnum + ";" + player.name + "\n");

	} else {
		thread printAndSoundOnEveryone( self.ownerTeam, getOtherTeam( self.ownerTeam ), &"MP_FLAG_RETURNED", &"MP_ENEMY_FLAG_RETURNED", "mp_obj_returned", "mp_enemy_obj_returned", "" );
		logString( self.ownerTeam + " flag returned" );
	}
	statusDialog( "ourflag_return", self.ownerTeam );
	statusDialog( "enemyflag_return", getOtherTeam( self.ownerTeam ) );
}



/*
=============
onUse

Checks if the player that has entered the capture zone is the flag carrier and gives
the corresponding score
=============
*/
onUse( player )
{
	// Check if this player is the flag carrier
	if ( player.isFlagCarrier ) {
		playerTeam = player.pers["team"];		
		
		// Player is returning their flag or capturing the enemy's when theirs is at home
		if ( playerTeam == player.carryObject.ownerTeam || level.flags[playerTeam].curOrigin == level.flags[playerTeam].trigger.baseOrigin ) {
			player.isFlagCarrier = false;
			player thread maps\mp\gametypes\_gameobjects::detachUseModels();
			if ( level.scr_ctf_scoreboard_flag_carrier == 1 ) {
				player.statusicon = "";
			}
	
			// Give the player the capture score and the team 1 point
			if ( playerTeam != player.carryObject.ownerTeam ) {
				level notify( getOtherTeam( player.pers["team"] ) + "_flag_captured", player.carryObject, player );
				
				player thread [[level.onXPEvent]]( "capture" );
				maps\mp\gametypes\_globallogic::givePlayerScore( "capture", player );
				[[level._setTeamScore]]( player.pers["team"], [[level._getTeamScore]]( player.pers["team"] ) + 1 );
				
				// Play the corresponding sounds and show the messages
				thread printAndSoundOnEveryone( player.pers["team"], getOtherTeam( player.pers["team"] ), &"MP_ENEMY_FLAG_CAPTURED_BY", &"MP_FLAG_CAPTURED_BY", "mp_enemy_obj_captured", "mp_obj_captured", player );
				player logString( self.ownerTeam + " flag captured" );
				
				lpselfnum = player getEntityNumber();
				lpGuid = player getGuid();
				logPrint("FC;" + lpGuid + ";" + lpselfnum + ";" + player.name + "\n");
					
				statusDialog( "enemyflag_capt", player.pers["team"] );
				statusDialog( "ourflag_capt", getOtherTeam( player.pers["team"] ) );
		
				// Return the flag to its home
				player.carryObject thread teamScored();
				
				// Check if we need to end the round or not
				if ( level.scr_ctf_endround_on_capture == 1 ) {
					thread maps\mp\gametypes\_globallogic::endGame( player.pers["team"], game["strings"][player.pers["team"] + "_win_round"] );
				}
				
			} else {
				// Player just returned their flag to their base
				player.carryObject flagReturned( player );			
			}
		}
	}
}



/*
=============
teamScored

Returns the flag to the enemy's base after the team has scored
=============
*/
teamScored()
{
	// Do the same stuff that _gameobjects:returnHome() does but without calling ::onReset
	self.isResetting = true;

	self notify ( "reset" );
	for ( index = 0; index < self.visuals.size; index++ )
	{
		self.visuals[index].origin = self.visuals[index].baseOrigin;
		self.visuals[index].angles = self.visuals[index].baseAngles;
		self.visuals[index] show();
	}
	self.trigger.origin = self.trigger.baseOrigin;

	self.curOrigin = self.trigger.origin;

	self maps\mp\gametypes\_gameobjects::clearCarrier();

	self resetObjectiveWaypoints( true );

	maps\mp\gametypes\_gameobjects::updateWorldIcons();
	maps\mp\gametypes\_gameobjects::updateCompassIcons();

	self.isResetting = false;
}



/*
=============
onPlayerKilled

Checks if the victim was killed within 5 meters of the enemy flag and gives the score for defending the flag
to the attacker
=============
*/
onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	// Make sure the attacker is not in the same team
	if ( isPlayer( attacker ) && self.pers["team"] != attacker.pers["team"] ) {

		// Get the distance between the victim and the attacker's flag
		distanceToEnemyFlag = distance( self.origin, level.flags[attacker.pers["team"]].curOrigin );

		// 197 units = 5 meters
		if ( distanceToEnemyFlag <= 197 ) {
			attacker thread [[level.onXPEvent]]( "defend" );
			maps\mp\gametypes\_globallogic::givePlayerScore( "defend", attacker );
		}
	}
}



/*
=============
resetObjectiveWaypoints

Reset the waypoints depending whether the flag is at home or not
=============
*/
resetObjectiveWaypoints( flagAtHome )
{
	// Check which kind of waypoints we need to show
	if ( flagAtHome ) {
		// Hide the waypoing showing that the flag is not at home
		level.zones[self.ownerTeam] maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", undefined );
		level.zones[self.ownerTeam] maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", undefined );

		// Make the flag visible to everyone
		self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", game[level.gameType]["compass_waypoint_flag_" + self.ownerTeam ] );
		self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", game[level.gameType]["waypoint_flag_" + self.ownerTeam ] );
		self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", game[level.gameType]["compass_waypoint_flag_" + self.ownerTeam ] );
		self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", game[level.gameType]["waypoint_flag_" + self.ownerTeam ] );
		self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );

		// Make sure only the enemy can pick up the flag
		self maps\mp\gametypes\_gameobjects::allowCarry( "enemy" );
	} else {
		// Change the waypoints on the capture zone to indicate the flag is missing
		level.zones[self.ownerTeam] maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", game[level.gameType]["waypoint_flag_" + self.ownerTeam + "_x"] );
		level.zones[self.ownerTeam] maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", game[level.gameType]["waypoint_flag_" + self.ownerTeam + "_x"] );
	}
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
