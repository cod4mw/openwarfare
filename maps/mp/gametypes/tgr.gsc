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
	Team Greed
	Objective: 	Score points for your team by collecting and delivering dog tags
	to the drop zone.
	Map ends:	When one team reaches the score limit, or time limit is reached
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

	// Force most of the scores to be 0 so players are forced into completing objectives
	setDvar( "scr_enable_scoresystem_tgr", "1" );
	setDvar( "scr_score_airstrike_kill_tgr", "0" );
	setDvar( "scr_score_assist_25_kill_tgr", "0" );
	setDvar( "scr_score_assist_50_kill_tgr", "0" );
	setDvar( "scr_score_assist_75_kill_tgr", "0" );
	setDvar( "scr_score_assist_kill_tgr", "0" );
	setDvar( "scr_score_barrel_explosion_kill_tgr", "0" );
	setDvar( "scr_score_c4_kill_tgr", "0" );
	setDvar( "scr_score_claymore_kill_tgr", "0" );
	setDvar( "scr_score_defend_objective_tgr", "5" );
	setDvar( "scr_score_grenade_kill_tgr", "0" );
	setDvar( "scr_score_grenade_launcher_kill_tgr", "0" );
	setDvar( "scr_score_hardpoint_used_tgr", "0" );
	setDvar( "scr_score_headshot_kill_tgr", "0" );
	setDvar( "scr_score_helicopter_kill_tgr", "0" );
	setDvar( "scr_score_melee_kill_tgr", "0" );
	setDvar( "scr_score_rpg_kill_tgr", "0" );
	setDvar( "scr_score_shot_down_helicopter_tgr", "0" );
	setDvar( "scr_score_standard_kill_tgr", "0" );
	setDvar( "scr_score_vehicle_explosion_kill_tgr", "0" );

	// Disable the following modules	
	setDvar( "scr_dogtags_enable_tgr", "0" );
	setDvar( "scr_bodyremoval_enable_tgr", "0" );
		
	if ( !isdefined( game["switchedsides"] ) )
		game["switchedsides"] = false;		
	
	level.scr_tgr_dogtag_autoremoval_time = getdvarx( "scr_tgr_dogtag_autoremoval_time", "int", 60, 0, 300 );
	level.scr_tgr_minimap_mark_red_drops = getdvarx( "scr_tgr_minimap_mark_red_drops", "int", 1, 0, 1 );
	level.scr_tgr_forcestartspawns = getdvarx( "scr_tgr_forcestartspawns", "int", 0, 0, 1 );
	level.scr_tgr_base_dogtag_score = getdvarx( "scr_tgr_base_dogtag_score", "int", 10, 5, 50 );
	
	level.scr_tgr_color_levels = getdvarx( "scr_tgr_color_levels", "string", "2;5;10" );
	level.scr_tgr_color_levels = strtok( level.scr_tgr_color_levels, ";" );
	for ( i=0; i < level.scr_tgr_color_levels.size; i++ ) {
		level.scr_tgr_color_levels[i] = int( level.scr_tgr_color_levels[i] );
	}
	
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 0, 0, 0 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 2, 0, 500 );
	maps\mp\gametypes\_globallogic::registerRoundSwitchDvar( level.gameType, 1, 0, 500 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 0, 0, 5000 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 20, 0, 1440 );


	level.teamBased = true;
	level.overrideTeamScore = true;
	
	level.onPrecacheGameType = ::onPrecacheGameType;	
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onRoundSwitch = ::onRoundSwitch;

	game["dialog"]["gametype"] = gameTypeDialog( "team_greed" );
	game["dialog"]["offense_obj"] = "boost";
	game["dialog"]["defense_obj"] = "boost";
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
		game[level.gameType]["drop_zone_allies"] = loadFX( "misc/ui_flagbase_silver" );
	} else {
		game[level.gameType]["drop_zone_allies"] = loadFX( "misc/ui_flagbase_black" );
	}

	// Precache team dependent assets for axis
	if ( game["axis"] == "russian" ) {
		game[level.gameType]["drop_zone_axis"] = loadFX( "misc/ui_flagbase_red" );
	} else {
		game[level.gameType]["drop_zone_axis"] = loadFX( "misc/ui_flagbase_gold" );
	}		

	precacheShader( "compass_waypoint_extraction_zone" );	
	precacheShader( "waypoint_extraction_zone" );
	precacheShader( "dogtag" );
	
	game[level.gameType]["1"] = loadFX( "greed/ui_pickup_green" );
	game[level.gameType]["2"] = loadFX( "greed/ui_pickup_yellow" );
	game[level.gameType]["3"] = loadFX( "greed/ui_pickup_purple" );
	game[level.gameType]["4"] = loadFX( "greed/ui_pickup_red" );	
	
	game[level.gameType]["pickup"] = loadfx( "props/crateExp_dust" );
}



/*
=============
onStartGameType

Show objectives to the player, initialize spawn points, and register score information
=============
*/
onStartGameType()
{
	setClientNameMode("auto_change");

	maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OW_OBJECTIVES_TGR" );
	maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OW_OBJECTIVES_TGR" );
	
	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OW_OBJECTIVES_TGR" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OW_OBJECTIVES_TGR" );
	}
	else
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OW_OBJECTIVES_TGR_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OW_OBJECTIVES_TGR_SCORE" );
	}
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"OW_OBJECTIVES_TGR_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"OW_OBJECTIVES_TGR_HINT" );
			
	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sab_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sab_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );

	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );

	level.spawn_axis = getentarray("mp_tdm_spawn", "classname");
	level.spawn_allies = getentarray("mp_tdm_spawn", "classname");
	level.spawn_axis_start = getentarray("mp_sab_spawn_axis_start", "classname");
	level.spawn_allies_start = getentarray("mp_sab_spawn_allies_start", "classname");

	level.bombZoneAllies = getOriginFromBombZone( "sab_bomb_allies" );
	level.bombZoneAxis = getOriginFromBombZone( "sab_bomb_axis" );
	
	allowed[0] = "war";
	
	if ( getDvarInt( "scr_oldHardpoints" ) > 0 )
		allowed[1] = "hardpoint";
	
	level.displayRoundEndText = true;
	maps\mp\gametypes\_gameobjects::main(allowed);

	thread greed();
}



/*
=============
onSpawnPlayer

Determines what spawn points to use and spawns the player
=============
*/
onSpawnPlayer()
{
	self.isDropping = false;
	self.dogtagsCollected = 0;

	spawnteam = self.pers["team"];
	if ( game["switchedsides"] )
		spawnteam = getOtherTeam( spawnteam );

	if ( level.useStartSpawns || level.scr_tgr_forcestartspawns )
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

	if ( !isDefined( self.carryIcon ) ) {
		self.carryIcon = self createIcon( "dogtag", 50, 50 );
		self.carryIcon setPoint( "CENTER", "CENTER", 220, 140 );
		self.carryIcon.archived = true;
		self.carryIcon.hideWhenInMenu = true;
		self.carryIcon.sort = -3;
		self.carryIcon.alpha = 0.75;
	}

	if ( !isDefined( self.carryAmount ) ) {
		self.carryAmount = self createFontString( "objective", 1.8 );
		self.carryAmount.archived = true;
		self.carryAmount.hideWhenInMenu = true;
		self.carryAmount setPoint( "CENTER", "CENTER", 245, 155 );
		self.carryAmount.alignX = "right";
		self.carryAmount.sort = -1;
		self.carryAmount.alpha = 0.75;
		self.carryAmount.color = ( 1, 1, 0 );
	}

	self.carryAmount setValue( 0 );
	self.carryIcon.alpha = 0.75;
	self.carryAmount.alpha = 0.75;

	self spawn( spawnpoint.origin, spawnpoint.angles );
	self thread onPlayerBody();
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
greed

Initializes all the map entities to be used (based on Sabotage) 
=============
*/
greed()
{
	// Setup drop zones
	if ( game["switchedsides"] ) {
		level.dropZones["allies"] = createDropZone( "allies", level.bombZoneAllies  );
		level.dropZones["axis"] = createDropZone( "axis", level.bombZoneAxis );
	}	else {
		level.dropZones["allies"] = createDropZone( "allies", level.bombZoneAxis );
		level.dropZones["axis"] = createDropZone( "axis", level.bombZoneAllies );
	}		
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



/*
=============
createDropZone

Create the drop zone for the players to drop the dog tags
=============
*/
createDropZone( team, dropZoneCoord )
{
	// Create the trigger
	dropZoneTrigger = spawn( "trigger_radius", dropZoneCoord, 0, 40, 10 );

	// Create the use object with 0 useTime so it's immediate
	dropZone = maps\mp\gametypes\_gameobjects::createUseObject( team, dropZoneTrigger, undefined, (0,0,100) );
	dropZone maps\mp\gametypes\_gameobjects::setVisibleTeam( "friendly" );
	dropZone maps\mp\gametypes\_gameobjects::setUseTime(0);
	dropZone maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_extraction_zone" );
	dropZone maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_extraction_zone" );
	dropZone maps\mp\gametypes\_gameobjects::allowUse( "friendly" );
	dropZone.origin = dropZoneTrigger.origin;
	dropZone.onUse = ::onDropZoneUse;

	// Spawn an special effect at the base of the goal zone to indicate where it is located
	traceStart = dropZoneTrigger.origin + (0,0,32);
	traceEnd = dropZoneTrigger.origin + (0,0,-32);
	trace = bulletTrace( traceStart, traceEnd, false, undefined );
	upangles = vectorToAngles( trace["normal"] );
	dropZone.baseEffect = spawnFx( game[level.gameType]["drop_zone_" + team], trace["position"], anglesToForward( upangles ), anglesToRight( upangles ) );
	triggerFx( dropZone.baseEffect );
	
	return dropZone;
}



/*
=============
onDropZoneUse

Checks if the player that has entered the drop zone carrying dog tags
=============
*/
onDropZoneUse( player )
{
	// Check if this player is carrying an object
	if ( isPlayer( player ) && player.dogtagsCollected > 0 && !player.isDropping ) {
		player.isDropping = true;
		
		// Calculate the score to be given to the team based on the amount of dog tags being dropped
		// The more dog tags the higher the score per dog tag received
		dogtagsCollected = player.dogtagsCollected;
		totalScore = int( player.dogtagsCollected * 1.5 ) * level.scr_tgr_base_dogtag_score;

		// Remove the dog tags from the player and update its HUD 
		player.dogtagsCollected = 0;
		player.carryAmount setValue( 0 );
		
		// Give the player and the team the score
		player givePlayerScore( "capture", totalScore );
		[[level._setTeamScore]]( player.pers["team"], [[level._getTeamScore]]( player.pers["team"] ) + totalScore );
		
		// Play the corresponding sounds and show the messages
		thread printAndSoundOnEveryone( player.pers["team"], getOtherTeam( player.pers["team"] ), &"OW_TEAM_DOGTAGS_CAPTURED_BY", &"OW_ENEMY_DOGTAGS_CAPTURED_BY", "mp_enemy_obj_captured", "mp_obj_captured", player, player, dogtagsCollected );
		player logString( player.pers["team"] + " " + dogtagsCollected  + "dog tags captured" );
		
		lpselfnum = player getEntityNumber();
		lpGuid = player getGuid();
		logPrint("DTC;" + lpGuid + ";" + lpselfnum + ";" + player.name + ";" + dogtagsCollected + "\n");		
		
		player.isDropping = false;
	}
}



/*
=============
givePlayerScore

Gives the player the proper score for dropping the dog tags
=============
*/
givePlayerScore( event, score )
{
	self maps\mp\gametypes\_rank::giveRankXP( event, score );
		
	self.pers["score"] += score;
	self maps\mp\gametypes\_persistence::statAdd( "score", (self.pers["score"] - score) );
	self.score = self.pers["score"];
	self notify ( "update_playerscore_hud" );
}	



/*
=============
onPlayerKilled

Checks if the victim was killed within 15 meters of the drop zone while carrying dog tags and give the score for defending
=============
*/
onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	// Remove carry icon and amount from the victim
	self.carryIcon.alpha = 0;
	self.carryAmount.alpha = 0;
	
	// Make sure the attacker is not in the same team
	if ( isPlayer( attacker ) && self.pers["team"] != attacker.pers["team"] ) {

		// Check if the victim was carrying dog tags
		if ( self.dogtagsCollected > 0 ) {
			// Get the distance between the victim and the drop zone - 591 units = 15 meters
			if ( distance( self.origin, level.dropZones[self.pers["team"]].origin ) <= 591 ) {
				attacker givePlayerScore( "defend", self.dogtagsCollected );
			}
		}
	}
}



/*
=============
onPlayerBody

Waits for a player's body to spawn in the level and drops the dog tags being carried, spawning special
effects, and marking in the minimap in case they are red
=============
*/
onPlayerBody()
{
	self endon("disconnect");
	level endon("game_ended");

	self waittill("player_body");

	// Save the body in case the player disconnects
	thisBody = self.body;
	
	// Wait until the body is not moving anymore
	wait (.5);
	thisBody maps\mp\gametypes\_weapons::waitTillNotMoving();
	
	// Drop any dof tags the player was carrying
	dogtagsAmount = self.dogtagsCollected + 1;
	
	// Determine which color will be using for the special effect
	effectToUse = game[level.gameType]["1"];
	if ( dogtagsAmount >= level.scr_tgr_color_levels[2] ) {
		effectToUse = game[level.gameType]["4"];
	} else if ( dogtagsAmount >= level.scr_tgr_color_levels[1] ) {
		effectToUse = game[level.gameType]["3"];
	} else if ( dogtagsAmount >= level.scr_tgr_color_levels[0] ) {
		effectToUse = game[level.gameType]["2"];
	}
	
	// Create the special effect 	
	colorEffect = spawnPickupFX( thisBody.origin + (0,0,15), effectToUse );
	
	// Create pickup trigger
	dogtagTrigger = spawn( "trigger_radius", thisBody.origin, 0, 30, 10 );
	
	// If this is a red drop mark it on the radar if the option is active
	if ( dogtagsAmount >= level.scr_tgr_color_levels[2] && level.scr_tgr_minimap_mark_red_drops ) {
		thisBody thread showOnMinimap();	
	}
	
	// Remove the trigger if the dog tag expire
	if ( level.scr_tgr_dogtag_autoremoval_time > 0 ) {
		thisBody thread removeTriggerOnTimeout( dogtagTrigger, colorEffect );
	}
	
	// Wait for another player to pickup the dogtags
	thisBody thread removeTriggerOnPickup( dogtagsAmount, dogtagTrigger, colorEffect );
}	



/*
=============
showOnMinimap

Show this body in the minimap as it contains a lot of dog tags (red)
=============
*/
showOnMinimap()
{
	// Get the next objective ID to use
	objCompass = maps\mp\gametypes\_gameobjects::getNextObjID();
	if ( objCompass != -1 ) {
		objective_add( objCompass, "active", self.origin + (0,0,25) );
		objective_icon( objCompass, "dogtag" );
		//objective_onentity( objCompass, self );
	}
		
	// Set stuff for world icon
	objWorld = newHudElem();			
	origin = self.origin + (0,0,25);
	objWorld.name = "dogtag_" + self getEntityNumber();
	objWorld.x = origin[0];
	objWorld.y = origin[1];
	objWorld.z = origin[2];
	objWorld.baseAlpha = 1.0;
	objWorld.isFlashing = false;
	objWorld.isShown = true;
	objWorld setShader( "dogtag", level.objPointSize, level.objPointSize );
	objWorld setWayPoint( true, "dogtag" );
	//objWorld setTargetEnt( self );
	objWorld thread maps\mp\gametypes\_objpoints::startFlashing();
	
	self waittill("death");
	
	// Stop flashing
	objWorld notify("stop_flashing_thread");
	objWorld thread maps\mp\gametypes\_objpoints::stopFlashing();

	// Wait some time to make sure the main loop ends	
	wait (0.25);
	
	// Delete the objective
	if ( objCompass != -1 ) {
		objective_delete( objCompass );
		maps\mp\gametypes\_gameobjects::resetObjID( objCompass );
	}
	objWorld destroy();
}



/*
=============
removeTriggerOnTimeout

Removes the dog tags from the map in case nobody has collected them in certain amount of time
=============
*/
removeTriggerOnTimeout( dogtagTrigger, colorEffect )
{
	dogtagTrigger endon("picked_up");
	
	// Wait for this body to timeout
	xwait( level.scr_tgr_dogtag_autoremoval_time );
	
	// Remove the special effect and the trigger
	dogtagTrigger notify("timed_out");
	wait (0.05);	
	dogtagTrigger delete();
	colorEffect delete();	
	
	// Remove the body 
	if ( isDefined( self ) ) {
		playfx( game[level.gameType]["pickup"], self.origin );
		self delete();	
	}	
}



/*
=============
removeTriggerOnPickup

Removes the trigger and the special effects from the map once the dog tags are picked up
=============
*/
removeTriggerOnPickup( dogtagsAmount, dogtagTrigger, colorEffect )
{
	dogtagTrigger endon("timed_out");
	
	dogtagTrigger waittill( "trigger", player );
	
	player playLocalSound( "dogtag_pickup" );
	player.dogtagsCollected += dogtagsAmount;
	player.carryAmount setValue( player.dogtagsCollected );
	
	// Give player a score of just one for at least picking them up
	player thread givePlayerScore( "take", dogtagsAmount );
			
	// Remove the special effect and the trigger
	dogtagTrigger notify("picked_up");
	wait (0.05);
	colorEffect delete();
	dogtagTrigger delete();
		
	// Remove the body 
	if ( isDefined( self ) ) {
		playfx( game[level.gameType]["pickup"], self.origin );
		self delete();	
	}				
}	



/*
=============
spawnPickupFX

Spawns an special effect in the given coordinates
=============
*/	
spawnPickupFX( groundpoint, fx )
{
	effect = spawnFx( fx, groundpoint, (0,0,1), (1,0,0) );
	triggerFx( effect );
	
	return effect;
}