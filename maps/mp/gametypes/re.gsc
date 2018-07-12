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
	Retrieval
	Attackers objective: Retrieve the objects back to their spawn
	Defenders objective: Defend these 2 positions to prevent the attackers from retrieving the objects
	Round ends:	When one team is eliminated, objects are retrieved, or roundlength time is reached
	Map ends:	When one team reaches the score limit, or time limit or round limit is reached
	Respawning:	Players remain dead for the round and will respawn at the beginning of the next round

	Level requirements
	------------------
		Allied Spawnpoints:
			classname		mp_retrieval_spawn_attacker
			Allied players spawn from these. Place at least 16 of these relatively close together.

		Axis Spawnpoints:
			classname		mp_retrieval_spawn_defender
			Axis players spawn from these. Place at least 16 of these relatively close together.

		Spectator Spawnpoints:
			classname		mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.

		Goal Zone:
			classname trigger_radius targetname mp_retrieval_goal_zone
			Goal zone where the retrieved object needs to be taken.
			
		Objectives:
			classname script_model targetname retrieval_objective_a
			classname trigger_use targetname retrieval_trigger_use_a
			classname mp_retrieval_objective_a

			classname script_model targetname retrieval_objective_b
			classname trigger_use targetname retrieval_trigger_use_b
			classname mp_retrieval_objective_b


	Level script requirements
	-------------------------
		Team Definitions:
			game["allies"] = "marines";
			game["axis"] = "opfor";
			This sets the nationalities of the teams. Allies can be american, british, or russian. Axis can be german.

			game["attackers"] = "allies";
			game["defenders"] = "axis";
			This sets which team is attacking and which team is defending. Attackers retrieve the objects. Defenders protect the objects.
*/


main()
{
	if(getdvar("mapname") == "mp_background")
		return;

	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	level.scr_re_scoreboard_objective_carrier = getdvarx( "scr_re_scoreboard_objective_carrier", "int", 0, 0, 1  );
	level.scr_re_one_retrieve = getdvarx( "scr_re_one_retrieve", "int", 0, 0, 1  );
	level.scr_re_objectives_enabled = getdvarx( "scr_re_objectives_enabled", "int", 0, 0, 4 );
	level.scr_re_defenders_show_both = getdvarx( "scr_re_defenders_show_both", "int", 0, 0, 1 );
	
	level.scr_re_defenders_spawndelay = getdvarx( "scr_re_defenders_spawndelay", "int", 0, 0, 60 );
	level.scr_re_objective_autoresettime = getdvarx( "scr_re_objective_autoresettime", "float", 0, 0, 120 );

	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 1, 0, 10 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 5, 0, 500 );
	maps\mp\gametypes\_globallogic::registerRoundSwitchDvar( level.gameType, 2, 0, 500 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 3, 0, 5000 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 7, 0, 1440 );


	level.teamBased = true;
	level.overrideTeamScore = true;
	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onDeadEvent = ::onDeadEvent;
	level.onOneLeftEvent = ::onOneLeftEvent;
	level.onTimeLimit = ::onTimeLimit;
	level.onRoundSwitch = ::onRoundSwitch;

	if ( level.scr_re_defenders_spawndelay > 0 ) {
		level.onRespawnDelay = ::getRespawnDelay;
	}

	level.endGameOnScoreLimit = false;

	game["dialog"]["gametype"] = gameTypeDialog( "retrieval" );
	game["dialog"]["offense_obj"] = "capture_objs";
	game["dialog"]["defense_obj"] = "obj_defend";
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

	if ( game["attackers"] == "allies" ) {
		// Precache team dependent assets for allies
		if ( game["allies"] == "marines" ) {
			game[level.gameType]["extraction_base"] = loadFX( "misc/ui_flagbase_silver" );
		} else {
			game[level.gameType]["extraction_base"] = loadFX( "misc/ui_flagbase_black" );
		}
	} else {
		// Precache team dependent assets for axis
		if ( game["axis"] == "russian" ) {
			game[level.gameType]["extraction_base"] = loadFX( "misc/ui_flagbase_red" );
		} else {
			game[level.gameType]["extraction_base"] = loadFX( "misc/ui_flagbase_gold" );
		}		
	}

	// Precache other assets that are not team dependent
	game[level.gameType]["objectiveModel"] = "com_office_book_red_flat";
	game[level.gameType]["objectiveIcon"] = "icon_redbinder";
	precacheModel( game[level.gameType]["objectiveModel"] );
	precacheShader( game[level.gameType]["objectiveIcon"] );
	precacheStatusIcon( game[level.gameType]["objectiveIcon"] );

	precacheShader( "compass_waypoint_captureneutral_a" );
	precacheShader( "compass_waypoint_defend_a" );
	precacheShader( "waypoint_captureneutral_a" );
	precacheShader( "waypoint_defend_a" );
	
	precacheShader( "compass_waypoint_captureneutral_b" );
	precacheShader( "compass_waypoint_defend_b" );
	precacheShader( "waypoint_captureneutral_b" );
	precacheShader( "waypoint_defend_b" );
	
	precacheShader( "compass_waypoint_extraction_zone" );	
	precacheShader( "waypoint_extraction_zone" );
}



/*
=============
onStartGameType

Show objectives to the player, initialize spawn points, and register score information
=============
*/
onStartGameType()
{
	// Check if this map supports native RE
	nativeRE = isDefined( getEnt( "mp_retrieval_goal_zone", "targetname" ) );

	if ( !isDefined( game["switchedsides"] ) )
		game["switchedsides"] = false;

	if ( game["switchedsides"] )
	{
		oldAttackers = game["attackers"];
		oldDefenders = game["defenders"];
		game["attackers"] = oldDefenders;
		game["defenders"] = oldAttackers;
	}

	setClientNameMode( "manual_change" );

	maps\mp\gametypes\_globallogic::setObjectiveText( game["attackers"], &"OW_OBJECTIVES_RE_ATTACKER" );
	maps\mp\gametypes\_globallogic::setObjectiveText( game["defenders"], &"OW_OBJECTIVES_RE_DEFENDER" );

	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["attackers"], &"OW_OBJECTIVES_RE_ATTACKER" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["defenders"], &"OW_OBJECTIVES_RE_DEFENDER" );
	}
	else
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["attackers"], &"OW_OBJECTIVES_RE_ATTACKER_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["defenders"], &"OW_OBJECTIVES_RE_DEFENDER_SCORE" );
	}
	maps\mp\gametypes\_globallogic::setObjectiveHintText( game["attackers"], &"OW_OBJECTIVES_RE_ATTACKER_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( game["defenders"], &"OW_OBJECTIVES_RE_DEFENDER_HINT" );

	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	
	// If the map doesn't support RE natively we'll use the location of Search and Destroy's assets
	if ( nativeRE ) {
		level.attackersSpawnPoints = "mp_retrieval_spawn_attacker";
		level.defendersSpawnPoints = "mp_retrieval_spawn_defender";
	} else {
		level.attackersSpawnPoints = "mp_sd_spawn_attacker";
		level.defendersSpawnPoints = "mp_sd_spawn_defender";
		// Let's get the locations of the bomb zones and the bomb from S&D to locate the assets
		level.retrieval_objective_a = getOriginFromBombZone("_a");
		level.retrieval_objective_b = getOriginFromBombZone("_b");
		level.mp_retrieval_goal_zone = getOriginFromBomb();
	}	
	
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( level.attackersSpawnPoints );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( level.defendersSpawnPoints );

	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );

	level.displayRoundEndText = true;

	allowed[0] = "retrieval";
	maps\mp\gametypes\_gameobjects::main(allowed);

	thread retrieval();
}



/*
=============
getOriginFromBomb

Get the origin of an entity to be used in case entities need to be manually created
=============
*/
getOriginFromBomb()
{
	bombLocation = getEnt( "sd_bomb_pickup_trig", "targetname" );
	if ( isDefined( bombLocation ) ) {
		trace = playerPhysicsTrace( bombLocation.origin + (0,0,20), bombLocation.origin - (0,0,2000), false, undefined );
		return trace;
	}
	return;	
}



/*
=============
getOriginFromBombZone

Get the origin of an entity to be used in case entities need to be manually created
=============
*/
getOriginFromBombZone( label )
{
	bombZones = getEntArray( "bombzone", "targetname" );
	for ( index = 0; index < bombZones.size; index++ ) {
		trigger = bombZones[index];
		
		if ( !isDefined( trigger.script_label ) || trigger.script_label != label )
			continue;
		
		trace = playerPhysicsTrace( trigger.origin + (0,0,20), trigger.origin - (0,0,2000), false, undefined );
		return trace;
	}
	
	return;	
}


/*
=============
getRespawnDelay

Add extra spawn time to defenders when they die
=============
*/
getRespawnDelay()
{
	if ( self.pers["team"] == game["defenders"] )
	{
		return level.scr_re_defenders_spawndelay;
	}
	
	return undefined;
}


/*
=============
onSpawnPlayer

Determines what spawn points to use and spawns the player
=============
*/
onSpawnPlayer()
{
	self.isObjectiveCarrier = false;

	if( self.pers["team"] == game["attackers"] )
		spawnPointName = level.attackersSpawnPoints;
	else
		spawnPointName = level.defendersSpawnPoints;

	spawnPoints = getEntArray( spawnPointName, "classname" );
	assert( spawnPoints.size );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );

	self spawn( spawnpoint.origin, spawnpoint.angles );
	level notify ( "spawned_player" );
}



/*
=============
onPlayerKilled

Checks if the victim was killed within 15 meters of the object and give the score for defending the object
to the attacker
=============
*/
onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	// Make sure the attacker is not in the same team
	if ( isPlayer( attacker ) && self.pers["team"] != attacker.pers["team"] && attacker.pers["team"] == game["defenders"] ) {

		// Check if the victim was the object carrier
		if ( self.isObjectiveCarrier ) {
			attacker thread [[level.onXPEvent]]( "killcarrier" );
			maps\mp\gametypes\_globallogic::givePlayerScore( "killcarrier", attacker );
			
		} else {
			// Get the distance between the victim and the objects - 591 units = 15 meters
			if ( ( !level.objectiveA.isRetrieved && distance( self.origin, level.objectiveA.curOrigin ) <= 591 ) || ( !level.objectiveB.isRetrieved && distance( self.origin, level.objectiveB.curOrigin ) <= 591 ) ) {
				attacker thread [[level.onXPEvent]]( "defend" );
				maps\mp\gametypes\_globallogic::givePlayerScore( "defend", attacker );
			}
		}
	}
}



/*
=============
onDeadEvent

Declares the winner in the case a team has been eliminated or a tie in case both teams have been eliminated
=============
*/
onDeadEvent( team )
{
	if ( team == "all" || team == game["attackers"] ) {
		[[level._setTeamScore]]( game["defenders"], [[level._getTeamScore]]( game["defenders"] ) + 1 );
		thread maps\mp\gametypes\_globallogic::endGame( game["defenders"], game["strings"][game["attackers"]+"_eliminated"] );
		
	}	else if ( team == game["defenders"] )	{
		[[level._setTeamScore]]( game["attackers"], [[level._getTeamScore]]( game["attackers"] ) + 1 );
		thread maps\mp\gametypes\_globallogic::endGame( game["attackers"], game["strings"][game["defenders"]+"_eliminated"] );

	}
}



/*
=============
onTimeLimit

Declares the defenders as the winners in the case a time limit has been reached
=============
*/
onTimeLimit()
{
	[[level._setTeamScore]]( game["defenders"], [[level._getTeamScore]]( game["defenders"] ) + 1 );
	thread maps\mp\gametypes\_globallogic::endGame( game["defenders"], game["strings"]["time_limit_reached"] );	
}



/*
=============
onOneLeftEvent

Warn a player about being the last man alive in the team
=============
*/
onOneLeftEvent( team )
{
	if ( !isdefined( level.warnedLastPlayer ) )
		level.warnedLastPlayer = [];

	if ( isDefined( level.warnedLastPlayer[team] ) )
		return;

	level.warnedLastPlayer[team] = true;

	players = level.players;
	for ( i = 0; i < players.size; i++ ){
		player = players[i];

		if ( isDefined( player.pers["team"] ) && player.pers["team"] == team && isdefined( player.pers["class"] ) )	{
			if ( player.sessionstate == "playing" && !player.afk )
				break;
		}
	}

	if ( i == players.size )
		return;

	players[i] maps\mp\gametypes\_globallogic::leaderDialogOnPlayer( "last_alive" );
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
retrieval

Initializes all the map entities to be used or creates them (based on Search and Destroy) in the case
the native RE assets are not present. 
=============
*/
retrieval()
{
	// Create the goal zone
	mp_retrieval_goal_zone = getEnt( "mp_retrieval_goal_zone", "targetname" );
	if ( !isDefined( mp_retrieval_goal_zone ) ) {
		// Check if we can manually create the trigger
		if ( isDefined( level.mp_retrieval_goal_zone ) ) {
			mp_retrieval_goal_zone = spawn( "trigger_radius", level.mp_retrieval_goal_zone, 0, 40, 10 );
		} else {
			error( "No mp_retrieval_goal_zone trigger found in map." );
			maps\mp\gametypes\_callbacksetup::AbortLevel();
			return;
		}
	}
	level.goalZone = createGoalZone( game["attackers"], mp_retrieval_goal_zone );
	
	// Create the objective A
	retrieval_trigger_use_a = getEnt( "retrieval_trigger_use_a", "targetname" );
	if ( !isDefined( retrieval_trigger_use_a ) ) {
		// Check if we can manually create the trigger
		if ( isDefined( level.retrieval_objective_a ) ) {
			retrieval_trigger_use_a = spawn( "trigger_radius", level.retrieval_objective_a, 0, 16, 16);
		} else {
			error( "No retrieval_trigger_use_a trigger found in map." );
			maps\mp\gametypes\_callbacksetup::AbortLevel();
			return;
		}
	}
	retrieval_objective_a = [];
	retrieval_objective_a[0] = getEnt( "retrieval_objective_a", "targetname" );
	if ( !isDefined( retrieval_objective_a[0] ) ) {
		// Check if we can manually create the script model
		if ( isDefined( level.retrieval_objective_a ) ) {
			retrieval_objective_a[0] = spawn( "script_model", level.retrieval_objective_a );
		} else {
			error( "No retrieval_objective_a script model found in map." );
			maps\mp\gametypes\_callbacksetup::AbortLevel();
			return;
		}
	}
	retrieval_objective_a[0] setModel( game[level.gameType]["objectiveModel"] );
	level.objectiveA = createObjective( game["defenders"], retrieval_trigger_use_a, retrieval_objective_a, "a"  );

	// Create the objective B
	retrieval_trigger_use_b = getEnt( "retrieval_trigger_use_b", "targetname" );
	if ( !isDefined( retrieval_trigger_use_b ) ) {
		// Check if we can manually create the trigger
		if ( isDefined( level.retrieval_objective_b ) ) {
			retrieval_trigger_use_b = spawn( "trigger_radius", level.retrieval_objective_b, 0, 16, 16);
		} else {
			error( "No retrieval_trigger_use_b trigger found in map." );
			maps\mp\gametypes\_callbacksetup::AbortLevel();
			return;
		}
	}
	retrieval_objective_b = [];
	retrieval_objective_b[0] = getEnt( "retrieval_objective_b", "targetname" );
	if ( !isDefined( retrieval_objective_b[0] ) ) {
		// Check if we can manually create the script model
		if ( isDefined( level.retrieval_objective_b ) ) {
			retrieval_objective_b[0] = spawn( "script_model", level.retrieval_objective_b );
		} else {
			error( "No retrieval_objective_b script model found in map." );
			maps\mp\gametypes\_callbacksetup::AbortLevel();
			return;
		}
	}
	retrieval_objective_b[0] setModel( game[level.gameType]["objectiveModel"] );
	level.objectiveB = createObjective( game["defenders"], retrieval_trigger_use_b, retrieval_objective_b, "b" );

	// Check if we should randomly disable one of the objectives
	if ( level.scr_re_objectives_enabled == 1 )	{
		if ( percentChance(50) ) {
			if ( percentChance(50) ) {
				level.objectiveA disableObject();
			}	else {
				level.objectiveB disableObject();
			}
		}
	}	else if ( level.scr_re_objectives_enabled == 3 ) {
		level.objectiveB disableObject();
		
	}	else if (level.scr_re_objectives_enabled == 4 ) {
		level.objectiveA disableObject();
	
	}	else if ( level.scr_re_objectives_enabled == 2 ) {
		if ( percentChance(50) ) {
			level.objectiveA disableObject();
		} else {
			level.objectiveB disableObject();
		}
	}
}



/*
=============
createGoalZone

Creates the goal zone where the objects need to be taken
=============
*/
createGoalZone( attackerTeam, zoneTrigger )
{
	// Create the use object with 0 useTime so it's immediate
	goalZone = maps\mp\gametypes\_gameobjects::createUseObject( attackerTeam, zoneTrigger, undefined, (0,0,100) );
	goalZone maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	goalZone maps\mp\gametypes\_gameobjects::setUseTime(0);
	goalZone maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_extraction_zone" );
	goalZone maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_extraction_zone" );
	goalZone maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_extraction_zone" );
	goalZone maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_extraction_zone" );
	goalZone maps\mp\gametypes\_gameobjects::allowUse( "friendly" );
	goalZone.onUse = ::onGoalZoneUse;

	// Spawn an special effect at the base of the goal zone to indicate where it is located
	traceStart = zoneTrigger.origin + (0,0,32);
	traceEnd = zoneTrigger.origin + (0,0,-32);
	trace = bulletTrace( traceStart, traceEnd, false, undefined );
	upangles = vectorToAngles( trace["normal"] );
	goalZone.baseEffect = spawnFx( game[level.gameType]["extraction_base"], trace["position"], anglesToForward( upangles ), anglesToRight( upangles ) );
	triggerFx( goalZone.baseEffect );
	
	return goalZone;
}



/*
=============
onGoalZoneUse

Checks if the player that has entered the goal zone is the carrying an object
=============
*/
onGoalZoneUse( player )
{
	// Check if this player is carrying an object
	if ( isPlayer( player ) && player.isObjectiveCarrier ) {
		player.isObjectiveCarrier = false;
		
		// Give the player the retrieved score
		player thread [[level.onXPEvent]]( "capture" );
		maps\mp\gametypes\_globallogic::givePlayerScore( "capture", player );

		lpselfnum = player getEntityNumber();
		lpGuid = player getGuid();
		logPrint("RO;" + lpGuid + ";" + lpselfnum + ";" + player.name + "\n");		
		
		// Mark this object as retrieved
		player.carryObject.isRetrieved = true;

		thread printAndSoundOnEveryone( player.pers["team"], getOtherTeam( player.pers["team"] ), &"OW_RE_RETRIEVED", &"OW_RE_RETRIEVED", "mp_enemy_obj_captured", "mp_obj_captured", player, player, player.carryObject.longname );
		player.carryObject maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );		
		player.carryObject maps\mp\gametypes\_gameobjects::clearCarrier();
		
		// Check if both objectives have been retrieved or if only one objective will end the round 
		if ( level.scr_re_one_retrieve == 1 || ( level.objectiveA.isRetrieved && level.objectiveB.isRetrieved ) ) {
			[[level._setTeamScore]]( game["attackers"], [[level._getTeamScore]]( game["attackers"] ) + 1 );
			
			if ( level.scr_re_one_retrieve == 1 ) {
				thread maps\mp\gametypes\_globallogic::endGame( game["attackers"], &"OW_RE_ONE_RETRIEVED" );
			} else {
				thread maps\mp\gametypes\_globallogic::endGame( game["attackers"], &"OW_RE_ALL_RETRIEVED" );
			}
		}
	}
}



/*
=============
createObjective

Creates the objective that players need to retrieve/defend
=============
*/
createObjective( team, trigger, visuals, name )
{
	// Create the objective
	objective = maps\mp\gametypes\_gameobjects::createCarryObject( team, trigger, visuals, (0,0,20) );
	objective maps\mp\gametypes\_gameobjects::setCarryIcon( game[level.gameType]["objectiveIcon"] );
	objective.objIDPingFriendly = true;
	objective.onPickup = ::onPickup;
	objective.onDrop = ::onDrop;
	objective.onReset = ::onReset;
	objective.allowWeapons = true;
	objective.objPoints["allies"].archived = true;
	objective.objPoints["axis"].archived = true;
	objective.autoResetTime = level.scr_re_objective_autoresettime;

	// Make the objective visible to everyone
	objective maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_defend_" + name );
	objective maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defend_" + name );

	objective maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_captureneutral_" + name );
	objective maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_captureneutral_" + name );

	objective maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );

	// Make sure only the attackers can pick up the objective
	objective maps\mp\gametypes\_gameobjects::allowCarry( "enemy" );
		
	// Set the name of this objective
	objective.name = name;
	if ( name == "a" ) {
		objective.longname = &"OW_RE_OBJECTIVE_A";
	} else {
		objective.longname = &"OW_RE_OBJECTIVE_B";
	}
	
	objective.isRetrieved = false;

	return objective;
}



/*
=============
onPickup

Handles the carry of the objective when picked up by the enemy.
=============
*/
onPickup( player )
{
	level notify( "objective_picked_up", self, player );

	// Set this player as the objective carrier, set up the scoreboard status and give the proper score
	player.isObjectiveCarrier = true;
	if ( level.scr_re_scoreboard_objective_carrier == 1 ) {
		player.statusicon = game[level.gameType]["objectiveIcon"];
	}

	// We only give "take" points when it's taken from the enemy's base
	if ( self.curOrigin == self.trigger.baseOrigin ) {
		player thread [[level.onXPEvent]]( "take" );
		maps\mp\gametypes\_globallogic::givePlayerScore( "take", player );
	}

	// Play the corresponding sounds for players
	thread printAndSoundOnEveryone( player.pers["team"], getOtherTeam( player.pers["team"] ), &"OW_RE_TAKEN", &"OW_RE_TAKEN", "mp_enemy_obj_taken", "mp_obj_taken", player, player, self.longname );

	// Log the event
	player logString( "objective " + self.name + " taken" );

	lpselfnum = player getEntityNumber();
	lpGuid = player getGuid();
	logPrint("OT;" + lpGuid + ";" + lpselfnum + ";" + player.name + "\n");

	// Set the new icons to be displayed
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "enemy" );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_defend_" + self.name );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_defend_" + self.name );
}



/*
=============
onDrop

Updates the compass and waypoints
=============
*/
onDrop( player )
{
	level notify( "objective_dropped", self, player );

	if ( isDefined( player ) ) {
		// Player is not the objective carrier anymore.
		if ( isAlive( player ) ) {
			player.isObjectiveCarrier = false;
		}
		// If scoreboard objective carrier is active and the player is alive remove the icon
		if ( level.scr_re_scoreboard_objective_carrier == 1 && isAlive( player ) ) {
			player.statusicon = "";
		}
		player logString( "objective " + self.name + " dropped" );

		// Play sound and show the proper message
		thread printAndSoundOnEveryone( game["defenders"], game["attackers"], &"OW_RE_DROPPED_BY", &"OW_RE_DROPPED_BY", "mp_war_objective_taken", "mp_war_objective_lost", player, player, self.longname );
	
	} else {
		// Play sound and show the proper message
		thread printAndSoundOnEveryone( game["defenders"], game["attackers"], &"OW_RE_DROPPED", &"OW_RE_DROPPED", "mp_war_objective_taken", "mp_war_objective_lost", self.longname );
		
		logString( "objective " + self.name + " dropped" );
	}



	// Make the objective visible to everyone
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_captureneutral_" + self.name );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_captureneutral_" + self.name );

	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
}



/*
=============
onReset

Objective has been returned automatically by the game after 60 seconds
=============
*/
onReset( player )
{
	thread printAndSoundOnEveryone( game["defenders"], game["attackers"], &"OW_RE_RETURNED", &"OW_RE_RETURNED", "mp_obj_returned", "mp_enemy_obj_returned", self.longname );
	logString( "objective " + self.name + " returned" );
}



disableObject()
{
	// Consider this objective retrieved if disabled
	self.isRetrieved = true;
		
	// Check if the objective should still show to the defenders
	if ( level.scr_re_defenders_show_both == 1 ) {
		self maps\mp\gametypes\_gameobjects::setVisibleTeam( "friendly" );
	} else {
		self maps\mp\gametypes\_gameobjects::disableObject();
	}	
}