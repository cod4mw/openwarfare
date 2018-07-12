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

// Rallypoints should be destroyed on leaving your team/getting killed
// Compass icons need to be looked at
// Doesn't seem to be setting angle on spawn so that you are facing your rallypoint

/*
	Hide And Seek
	Attackers objective: Hunt down and kill the props.
	Defenders objective: Hide and survive the round.
	Round ends:	When all the props have been killed or round time is over.
	Respawning:	Players remain dead for the round and will respawn at the beginning of the next round

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


main()
{
	if(getdvar("mapname") == "mp_background")
		return;

	level.scr_hns_hidetime = getdvarx( "scr_hns_hidetime", "int", 30, 15, 60  );
	level.scr_hns_props_speed = getdvarx( "scr_hns_props_speed", "float", 1.2, 0.5, 1.5 );
	level.scr_hns_props_max_morphs = getdvarx( "scr_hns_props_max_morphs", "int", 0, 0, 10 );
	level.scr_hns_props_survive_score_time = getdvarx( "scr_hns_props_survive_score_time", "float", 30, 0, 120 );
	level.scr_hns_hunting_music_enable = getdvarx( "scr_hns_hunting_music_enable", "int", 1, 0, 1 );
	level.scr_hns_hunting_music_time = getdvarx( "scr_hns_hunting_music_time", "int", 0, 0, 3600 );

	// Force some server variables
	setDvar( "scr_allow_stationary_turrets_hns", "0" );
	setDvar( "scr_anti_camping_enable_hns", "0" );
	setDvar( "scr_blackscreen_enable_hns", "0" );
	setDvar( "scr_cap_enable_hns", "0" );
	setDvar( "scr_custom_teams_enable_hns", "0" );
	setDvar( "scr_dogtags_enable_hns", "0" );
	setDvar( "scr_drawfriend_hns", "1" );
	setDvar( "scr_enable_spawn_protection_hns", "0" );
	setDvar( "scr_game_forceuav_hns", "0" );
	setDvar( "scr_game_hardpoints_hns", "0" );
	setDvar( "scr_hns_playerrespawndelay", "-1" );
	setDvar( "scr_hud_show_enemy_names_hns", "0" );
	setDvar( "scr_hud_show_redcrosshairs_hns", "0" );
	setDvar( "scr_show_ext_obituaries_hns", "0" );
	setDvar( "scr_thirdperson_enable_hns", "0" );

	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();	

	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 1, 1, 1 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 5, 0, 500 );
	maps\mp\gametypes\_globallogic::registerRoundSwitchDvar( level.gameType, 2, 0, 500 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 3, 0, 5000 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 5.5, 0, 1440 );

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

	level.endGameOnScoreLimit = false;

	game["dialog"]["gametype"] = gameTypeDialog( "hideandseek" );
	level thread onPlayerConnect();
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player);
		player thread onJoinedTeam();
	}
}


onPrecacheGameType()
{
	// Precache the menu to select props, the headicon and teamicon for the props team
	precacheMenu( "changeclass_props" );
	precacheHeadIcon( "headicon_props" );
	precacheShader( "faction_128_props" );
	
	propLoaderMode = getdvard( "scr_hns_proploader", "int", 0, 0, 1 );
	if ( propLoaderMode == 0 ) {
		itemLimit = 46;
	} else {
		itemLimit = 500;
	}
	
	// Precache models for the current map
	for ( itemIndex = 1; itemIndex < itemLimit; itemIndex++ ) {
		resetTimeout();
		thisProp = tablelookup( "mp/propsTable.csv", 0, level.script + "_" + itemIndex, 1 );
		if ( thisProp != "" ) {
			level.maxPropNumber = itemIndex;
			precacheModel( thisProp );
		} else if( propLoaderMode == 0 ) {
			// We end the loop as soon as we can't find the next model
			break;
		}		
	}
}


onRoundSwitch()
{
	if ( !isdefined( game["switchedsides"] ) )
		game["switchedsides"] = false;

	if ( game["teamScores"]["allies"] == level.scorelimit - 1 && game["teamScores"]["axis"] == level.scorelimit - 1 )	{
		level.halftimeType = "overtime";
	}	else {
		level.halftimeType = "halftime";
	}

	game["switchedsides"] = !game["switchedsides"];
}


onStartGameType()
{
	if ( !isDefined( game["switchedsides"] ) )
		game["switchedsides"] = false;

	if ( game["switchedsides"] )
	{
		oldAttackers = game["attackers"];
		oldDefenders = game["defenders"];
		game["attackers"] = oldDefenders;
		game["defenders"] = oldAttackers;
	}

	// Change the "choose a class" menu for the props team
	game["menu_changeclass_"+game["defenders"]] = "changeclass_props";
	
	// Set strings, icons, and team name for props
	if ( game["defenders"] == "allies" ) {
		game["strings"]["allies_win"] = &"OW_PROPS_WIN_MATCH";
		game["strings"]["allies_win_round"] = &"OW_PROPS_WIN_ROUND";
		game["strings"]["allies_mission_accomplished"] = &"OW_PROPS_MISSION_ACCOMPLISHED";
		game["strings"]["allies_eliminated"] = &"OW_PROPS_ELIMINATED";
		game["strings"]["allies_forfeited"] = &"OW_PROPS_FORFEITED";
		
		level.scr_team_allies_name = &"OW_PROPS_SHORT";
		level.scr_team_allies_logo = "faction_128_props";	
		level.scr_team_allies_headicon = "headicon_props";
		game["headicon_allies"] = "headicon_props";
	
	} else {
		game["strings"]["axis_win"] = &"OW_PROPS_WIN_MATCH";
		game["strings"]["axis_win_round"] = &"OW_PROPS_WIN_ROUND";
		game["strings"]["axis_mission_accomplished"] = &"OW_PROPS_MISSION_ACCOMPLISHED";
		game["strings"]["axis_eliminated"] = &"OW_PROPS_ELIMINATED";
		game["strings"]["axis_forfeited"] = &"OW_PROPS_FORFEITED";
		
		level.scr_team_axis_name = &"OW_PROPS_SHORT";
		level.scr_team_axis_logo = "faction_128_props";	
		level.scr_team_axis_headicon = "headicon_props";
		game["headicon_axis"] = "headicon_props";					
	}
	maps\mp\gametypes\_scoreboard::setServerTeamResources();

	maps\mp\gametypes\_globallogic::setObjectiveText( game["attackers"], &"OW_OBJECTIVES_HNS_ATTACKER" );
	maps\mp\gametypes\_globallogic::setObjectiveText( game["defenders"], &"OW_OBJECTIVES_HNS_DEFENDER" );

	if ( level.splitscreen ) {
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["attackers"], &"OW_OBJECTIVES_HNS_ATTACKER" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["defenders"], &"OW_OBJECTIVES_HNS_DEFENDER" );
	}	else {
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["attackers"], &"OW_OBJECTIVES_HNS_ATTACKER_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["defenders"], &"OW_OBJECTIVES_HNS_DEFENDER_SCORE" );
	}
	maps\mp\gametypes\_globallogic::setObjectiveHintText( game["attackers"], &"OW_OBJECTIVES_HNS_ATTACKER_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( game["defenders"], &"OW_OBJECTIVES_HNS_DEFENDER_HINT" );

	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_axis_start" );

	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );

	level.displayRoundEndText = true;

	allowed[0] = "war";
	maps\mp\gametypes\_gameobjects::main(allowed);

	thread hideAndSeek();
}


onJoinedTeam()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_team");
		
		if ( self.pers["team"] == game["attackers"] ) {
			self setClientDvar( "cg_thirdPerson", "0" );
		} else {
			self setClientDvars( 
				"cg_thirdPerson", "1",
				"cg_thirdPersonAngle", "360",
				"cg_thirdPersonRange", "200"
			);
		}
	}
}


onSpawnPlayer()
{
	if( self.pers["team"] == game["attackers"] )
		spawnPointName = "mp_tdm_spawn_allies_start";
	else
		spawnPointName = "mp_tdm_spawn_axis_start";

	spawnPoints = getEntArray( spawnPointName, "classname" );
	assert( spawnPoints.size );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );

	// Humans will play the game in 1st person view and the props in 3rd person view
	if ( self.pers["team"] == game["attackers"] ) {
		self setClientDvar( "cg_thirdPerson", "0" );
	} else {
		self setClientDvars( 
			"cg_thirdPerson", "1",
			"cg_thirdPersonAngle", "360",
			"cg_thirdPersonRange", "200"
		);
	}

	// Spawn the player
	self spawn( spawnpoint.origin, spawnpoint.angles );

	// Check if we have a previous prop and delete it
	if ( isDefined( self.pers["myprop"] ) ) {
		self.pers["myprop"] delete();
		self.pers["myprop"] = undefined;	
	}
	
	// Check if this player is a prop and make the necessary changes
	if ( self.pers["team"] == game["defenders"] ) {
		// Check if we need to initialize the amount of morphs allowed
		if ( !isDefined( self.morphTimes ) ) {
			self.morphTimes = 0;
		}
		
		// Set prop speed for this player
		self thread openwarfare\_speedcontrol::setBaseSpeed( level.scr_hns_props_speed );

		// Remove all the weapons from this player and hide the player model
		self takeAllWeapons();
		self setModel("");
		self detachAll();
		self clearPerks();
		
		// Give the quieter perk so we don't hear footsteps
		self setPerk( "specialty_quieter" );

		// Create a new script_model to spawn the prop
		self.pers["myprop"] = spawn( "script_model", self.origin );
		self.pers["myprop"].health = 10000;
		self.pers["myprop"].owner = self;
		self.pers["myprop"].angles = self.angles;
		self.pers["myprop"] setModel( self.pers["prop"] );
		
		// Start threads to control prop behavior
		self.pers["myprop"] thread deleteonOwnerDisconnect( self );
		self.pers["myprop"] thread followOwner( self );
		
		// Monitor for the melee and attack keys
		self thread monitorMeleeAttackKey();
		self thread giveSurvivingScore();
	}
	
	level notify ( "spawned_player" );
}


deleteonOwnerDisconnect( owner )
{
	owner endon("death");
	owner endon( "killed_player" );	
	
	owner waittill("disconnect");
	propOrigin = self.origin;
	self delete();
	playfx( level._effect["body_remove"], propOrigin );
}


monitorMeleeAttackKey()
{
	self endon( "disconnect" );
	self endon( "killed_player" );
	self endon( "death" );
	
	level endon( "game_ended" );
	
	for (;;) {
		wait (0.05);

		// Melee button opens up the prop selection menu
		if ( self meleeButtonPressed() ) {
			// Check if we have reached the maximum number of morphs
			if ( level.scr_hns_props_max_morphs == 0 || self.morphTimes < level.scr_hns_props_max_morphs ) {
				self openMenu( game["menu_changeclass_" + self.pers["team"]] );
			} else {
				self iprintln( &"OW_MAXIMUM_MORPHS_REACHED", level.scr_hns_props_max_morphs );
			}
			while ( self meleeButtonPressed() ) wait (0.05);
		}
		
		// Fire button quickly aligns the model with the player's eyes
		if ( self attackButtonPressed() && isDefined( self.pers["myprop"] ) ) {
			self.pers["myprop"] rotateTo( ( 0, self.angles[1], 0 ), 0.5 );
			while ( self attackButtonPressed() ) wait (0.05);
		}		
	}
}


giveSurvivingScore()
{
	self endon( "disconnect" );
	self endon( "killed_player" );
	self endon( "death" );
	
	level endon( "game_ended" );
	
	if ( level.scr_hns_props_survive_score_time == 0 )
		return;
	
	// If we are in the hiding period wait until it's over
	if ( level.inHidingPeriod ) {
		level waittill( "hiding_time_over" );
	}
	
	// Get how many points will give to the player
	survivalScore = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
	
	for (;;) {
		xwait( level.scr_hns_props_survive_score_time );
		
		// Give the score to the player
		self maps\mp\gametypes\_rank::giveRankXP( "survival", survivalScore );
		self.pers["score"] += survivalScore;
		self maps\mp\gametypes\_persistence::statAdd( "score", ( self.pers["score"] - survivalScore ) );
		self.score = self.pers["score"];
		self notify ("update_playerscore_hud");		
	}		
}


rotateProp( angleChange )
{
	// Rotate the model of the prop by "angleChange" degrees
	if ( isAlive( self ) && isDefined( self.pers["myprop"] ) ) {
		self.pers["myprop"] rotateTo( ( 0, self.pers["myprop"].angles[1] + angleChange, 0 ), 0.1 );
	}	
}


followOwner( owner )
{
	owner endon( "disconnect" );
	owner endon( "killed_player" );
	owner endon( "death" );
	
	self endon( "death" );

	for (;;) {
		wait (0.01);
		
		// Check if the owner moved and update prop's position
		if ( self.origin != owner.origin ) {
			self moveTo( owner.origin, 0.1 );
		}		
	}	
}


killPropOwner( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	if ( isDefined( self.killingProp ) )
		return;
		
	self.killingProp = true;
	
	// Check if we need to remove the prop
	if ( isDefined( self.pers["myprop"] ) ) {
		if ( !isDefined( self.switching_teams ) && level.scr_hud_show_death_icons == 1 ) {
			thread maps\mp\gametypes\_deathicons::addDeathicon( self.pers["myprop"], self, self.pers["team"], 5.0 );
			wait (0.05);
		}
					
		propOrigin = self.pers["myprop"].origin;
		self.pers["myprop"] delete();
		wait (0.05);
		self.pers["myprop"] = undefined;
		
		playfx( level._effect["body_remove"], propOrigin );
	}
	
	self thread maps\mp\gametypes\_globallogic::Callback_PlayerKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, 0 );
}


onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	self.killingProp = undefined;
	thread checkAllowSpectating();
}


checkAllowSpectating()
{
	wait ( 0.05 );

	update = false;
	if ( !level.aliveCount[ game["attackers"] ] )
	{
		level.spectateOverride[game["attackers"]].allowEnemySpectate = 1;
		update = true;
	}
	if ( !level.aliveCount[ game["defenders"] ] )
	{
		level.spectateOverride[game["defenders"]].allowEnemySpectate = 1;
		update = true;
	}
	if ( update )
		maps\mp\gametypes\_spectating::updateSpectateSettings();
}


hns_endGame( winningTeam, endReasonText )
{
	if ( isdefined( winningTeam ) )
		[[level._setTeamScore]]( winningTeam, [[level._getTeamScore]]( winningTeam ) + 1 );

	thread maps\mp\gametypes\_globallogic::endGame( winningTeam, endReasonText );
}


onDeadEvent( team )
{
	if ( team == "all" )
	{
		thread maps\mp\gametypes\_globallogic::endGame( "tie", game["strings"]["round_draw"] );
	}
	else if ( team == game["attackers"] )
	{
		hns_endGame( game["defenders"], game["strings"][game["attackers"]+"_eliminated"] );
	}
	else if ( team == game["defenders"] )
	{
		hns_endGame( game["attackers"], game["strings"][game["defenders"]+"_eliminated"] );
	}
}


onOneLeftEvent( team )
{
	warnLastPlayer( team );
}


onTimeLimit()
{
	if ( level.teamBased )
		hns_endGame( game["defenders"], game["strings"]["time_limit_reached"] );
	else
		hns_endGame( undefined, game["strings"]["time_limit_reached"] );
}


warnLastPlayer( team )
{
	if ( !isdefined( level.warnedLastPlayer ) )
		level.warnedLastPlayer = [];

	if ( isDefined( level.warnedLastPlayer[team] ) )
		return;

	level.warnedLastPlayer[team] = true;

	players = level.players;
	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if ( isDefined( player.pers["team"] ) && player.pers["team"] == team && isdefined( player.pers["class"] ) )
		{
			if ( player.sessionstate == "playing" && !player.afk )
				break;
		}
	}

	if ( i == players.size )
		return;

	players[i] thread giveLastAttackerWarning();
}


giveLastAttackerWarning()
{
	self endon("death");
	self endon("disconnect");

	fullHealthTime = 0;
	interval = .05;

	while(1)
	{
		if ( self.health != self.maxhealth )
			fullHealthTime = 0;
		else
			fullHealthTime += interval;

		wait interval;

		if (self.health == self.maxhealth && fullHealthTime >= 3)
			break;
	}

	//self iprintlnbold(&"MP_YOU_ARE_THE_ONLY_REMAINING_PLAYER");
	self maps\mp\gametypes\_globallogic::leaderDialogOnPlayer( "last_alive" );
}


playSuspensefulMusic()
{
	// Start playing the suspenseful music
	musicObject = spawn( "script_origin", (0,0,0) );
	musicObject playLoopSound( "hidingtime" );

	// Wait for the signal to stop the sound
	level waittill( "stop_suspenseful_music" );
	musicObject stopLoopSound();
	
	// Check if we need to start playing the music during hunting
	if ( level.scr_hns_hunting_music_enable == 1 ) {
		wait(5);
		
		// Check if we need to stop the music after certain time
		if ( level.scr_hns_hunting_music_time > 0 ) {
			level thread sendStopMusicEvent();
		}		
		musicObject playLoopSound( "seekingtime" );
		level waittill_any( "game_ended", "stop_hunting_music" );
		musicObject stopLoopSound();
	}
	
	musicObject delete();
}


sendStopMusicEvent()
{
	level endon( "game_ended" );
	wait( level.scr_hns_hunting_music_time );
	level notify( "stop_hunting_music" );	
}


hideAndSeek()
{
	// Make sure this map is supported by the gametype
	if ( tableLookup( "mp/propsTable.csv", 0, level.script + "_1", 1 ) == "" ) {
		error( "Map not supported by Hide And Seek." );
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}

	// Load the effect we'll be using when a prop is killed
	level._effect["body_remove"] = loadfx( "props/crateExp_dust" );	
	
	// Wait for prematch to be over
	level waittill( "prematch_over" );

	// Hiding period starts
	level.inHidingPeriod = true;
	
	// Freeze controls for the attackers during the hiding period
	for ( i = 0; i < level.players.size; i++ ) {
		player = level.players[i];
		if ( isDefined( player ) && isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] == game["attackers"] ) {
			player freezeControls( true );
		}
	}
	
	// Play some suspenseful music during the hiding period
	level thread playSuspensefulMusic();
	
	// Create the black screen as well the countdown HUD elements
	hidingPeriodCountDown = createServerTimer( "objective", 2.6 );
	hidingPeriodCountDown.alignX = "center";
	hidingPeriodCountDown.alignY = "middle";
	hidingPeriodCountDown.horzAlign = "center";
	hidingPeriodCountDown.vertAlign = "top";
	hidingPeriodCountDown.x = 0;
	hidingPeriodCountDown.y = 65;	
	hidingPeriodCountDown.sort = 100;
	hidingPeriodCountDown.label = &"OW_PROPS_HIDING_TIME";
	hidingPeriodCountDown.alpha = 0.9;
	hidingPeriodCountDown.glowAlpha = 0.9;
	hidingPeriodCountDown.glowColor = (0,0,1);
	hidingPeriodCountDown.archived = false;
	hidingPeriodCountDown.hideWhenInMenu = true;
	hidingPeriodCountDown setTimer( level.scr_hns_hidetime );

	// Show hints the players during the hiding period
	level thread rotateHintMessages( game["defenders"] );
	level thread rotateHintMessages( game["attackers"] );

	blackscreen1 = createBlackscreenShader();
	blackscreen2 = createBlackscreenShader();
	
	// Wait for the countdown time
	wait ( level.scr_hns_hidetime - 5 );
	
	hidingPeriodCountDown.color = (1,0.5,0);
	hidingPeriodCountDown.glowColor = (1,0,0);
	hidingPeriodCountDown setTenthsTimer( 5 );
	
	for ( i = 0; i < 5; i++ ) {
		for ( p = 0; p < level.players.size; p++ ) {
			player = level.players[p];
			if ( isDefined( player ) ) {
				player playLocalSound( "ui_mp_suitcasebomb_timer" );
			}				
		}
		wait (1);
	}
	
	// Destroy the HUD elements
	level notify("stop_suspenseful_music");
	hidingPeriodCountDown destroy();
	blackscreen1 destroy();
	blackscreen2 destroy();
	
	// Unfreeze controls for all the players in the server (no need to check team assignment really)
	for ( i = 0; i < level.players.size; i++ ) {
		if ( isDefined( level.players[i] ) ) {
			level.players[i] freezeControls( false );
		}
	}

	// Show the gametype hints to the players
	for ( p = 0; p < level.players.size; p++ ) {
		player = level.players[p];
		if ( isDefined( player ) ) {
			if ( !player.hasSpawned )
				continue;
				
			player thread maps\mp\gametypes\_hud_message::hintMessage( maps\mp\gametypes\_globallogic::getObjectiveHintText( player.pers["team"] ) );
				
			if ( player.pers["team"] == game["attackers"] ) {
				player maps\mp\gametypes\_globallogic::leaderDialogOnPlayer( "offense_obj", "introboost" );
			}
		}				
	}	
	
	// Hiding period is over
	level.inHidingPeriod = false;
	level notify( "hiding_time_over" );	
}


createBlackscreenShader()
{
	blackScreen = createServerIcon( "black", 640, 480 , game["attackers"] );
	blackScreen.x = 0;
	blackScreen.y = 0;
	blackScreen.alignX = "left";
	blackScreen.alignY = "top";
	blackScreen.horzAlign = "fullscreen";
	blackScreen.vertAlign = "fullscreen";
	blackScreen.sort = 50;
	blackScreen.color = (0,0,0);
	blackScreen.archived = true;
	blackScreen.alpha = 1;
	blackScreen.hideWhenInMenu = false;	
	
	return blackscreen;	
}


rotateHintMessages( team )
{
	hidingPeriodHints = createServerFontString( "default", 1.8, team );
	hidingPeriodHints.alignX = "center";
	hidingPeriodHints.alignY = "middle";
	hidingPeriodHints.horzAlign = "center";
	hidingPeriodHints.vertAlign = "top";
	hidingPeriodHints.x = 0;
	hidingPeriodHints.y = 90;	
	hidingPeriodHints.sort = 100;
	hidingPeriodHints.alpha = 0;
	hidingPeriodHints.archived = true;
	hidingPeriodHints.hideWhenInMenu = true;
	hidingPeriodHints.stopRequested = false;
	hidingPeriodHints thread monitorForStopRequest();
	
	// Set up rotating messages
	rotateHints = [];
	if ( team == game["defenders"] ) {
		rotateHints[rotateHints.size] = &"OW_PROPS_HINT_LINE1";
		rotateHints[rotateHints.size] = &"OW_PROPS_HINT_LINE2";
		rotateHints[rotateHints.size] = &"OW_PROPS_HINT_LINE3";
		rotateHints[rotateHints.size] = &"OW_PROPS_HINT_LINE4";
		rotateHints[rotateHints.size] = &"OW_PROPS_HINT_LINE5";				
	} else {
		rotateHints[rotateHints.size] = &"OW_HUMANS_HINT_LINE1";
		rotateHints[rotateHints.size] = &"OW_HUMANS_HINT_LINE2";
		rotateHints[rotateHints.size] = &"OW_HUMANS_HINT_LINE3";		
	}
	showHint = 0;
	
	// Rotate messages until the hiding period is over
	while ( !hidingPeriodHints.stopRequested ) {
		// Set the new hint
		hidingPeriodHints setText( rotateHints[showHint] );
		hidingPeriodHints fadeOverTime(0.5);
		hidingPeriodHints.alpha = 0.9;
		
		// Show the hint for a couple of seconds and then fade it out
		wait (4);
		hidingPeriodHints fadeOverTime(0.5);
		hidingPeriodHints.alpha = 0;
		wait (0.5);		

		// Move to the next hint
		showHint++;
		if ( showHint == rotateHints.size ) {
			showHint = 0;
		}
	}
	
	hidingPeriodHints destroy();
}


monitorForStopRequest()
{
	level waittill( "stop_suspenseful_music" );
	self.stopRequested = true; 
}


choosePropClass( itemIndex )
{
	if ( game["state"] == "postgame" )
		return;

	// Get the new prop model
	newModel = tableLookup( "mp/propsTable.csv", 0, level.script + "_" + itemIndex, 1 );

	// Check if the model is different from the current one
	if ( !isDefined( self.pers["prop"] ) || newModel != self.pers["prop"] ) {
		
		// Store the new prop model to use for this player
		self.pers["prop"] = newModel;
		
		// Check if we need to change the existing model or just spawn the player
		if ( isAlive( self ) && isDefined( self.pers["myprop"] ) ) {
			// Check if we reach the limit of morphs
			if ( level.scr_hns_props_max_morphs == 0 || self.morphTimes < level.scr_hns_props_max_morphs ) {
				self.pers["myprop"] setModel( self.pers["prop"] );
				if ( !level.inPrematchPeriod ) {
					self.morphTimes++;
				}
			
			} else {
				self iprintln( &"OW_MAXIMUM_MORPHS_REACHED", level.scr_hns_props_max_morphs );
			}

		} else {
			self thread [[level.spawnClient]]();
		}
	}		
}