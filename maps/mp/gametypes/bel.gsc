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
	Behind Enemy Lines
	Number of Runners: The more people playing in the round the more runners there will be. Currently the runners:hunters radio is about 1:3-4
	Runners Objective: Kill as many hunter players as possible before being overrun. You gain more points the longer you stay alive
	Hunters objective: Hunt down runner players
	Map ends:	When a player reaches the score limit, or time limit is reached
	Respawning: 	Hunters respawn as hunters when they die, runner players respawn as hunters when they die
			A hunter who kills a runner player will take that runner player's spot on the runners team
			Uses TDM spawnpoints so all TDM maps automatically support this gametype

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
			This sets the nationalities of the teams. Allies can be marines, or sas. Axis can be opfor, arab, or russian.

		If using minefields or exploders:
			maps\mp\_load::main();

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
	
	level.scr_bel_alive_points = getdvarx( "scr_bel_alive_points", "int", 5, 1, 50 );
	level.scr_bel_alive_points_time = getdvarx( "scr_bel_alive_points_time", "int", 10, 1, 60 );
	
	level.scr_bel_showoncompass = getdvarx( "scr_bel_showoncompass", "int", 1, 0, 2 );
	level.scr_bel_showoncompass_points = getdvarx( "scr_bel_showoncompass_points", "int", 5, 0, 50 );
	level.scr_bel_showoncompass_interval = getdvarx( "scr_bel_showoncompass_interval", "float", 30, 1, 60 );
	level.scr_bel_showoncompass_time = getdvarx( "scr_bel_showoncompass_time", "float", 5, 1, 20 );	
	
	// Force some server variables
	setDvar( "scr_teambalance_bel", "0" );
	setDvar( "scr_force_autoassign_bel", "1" );
	setDvar( "scr_force_autoassign_clan_tags_bel", "" );
	setDvar( "scr_clan_vs_all_team_bel", "" );
	setDvar( "scr_healthsystem_bleeding_enable_bel", "0" );
	setDvar( "perk_allow_specialty_pistoldeath_bel", "0" );
	setDvar( "perk_allow_specialty_grenadepulldeath_bel", "0" );
	
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();
	level.autoassign = ::menuAutoAssign;

	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 0, 0, 0 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 1, 1, 1 );
	maps\mp\gametypes\_globallogic::registerRoundSwitchDvar( level.gameType, 0, 0, 0 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 0, 0, 5000 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 20, 0, 1440 );


	level.teamBased = true;
	level.overrideTeamScore = true;
	level.spawnPlayer= ::spawnPlayer;
	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onPlayerKilled = ::onPlayerKilled;
	
	game["dialog"]["gametype"] = gameTypeDialog( "behind_enemy_lines" );
}


/*
=============
onPrecacheGameType

Precache the models, shaders, and strings to be used
=============
*/
onPrecacheGameType()
{
	precacheShader( "compass_waypoint_target" );
	precacheShader( "waypoint_kill" );
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

	maps\mp\gametypes\_globallogic::setObjectiveText( game["attackers"], &"OW_OBJECTIVES_ATTACKERS_BEL" );
	maps\mp\gametypes\_globallogic::setObjectiveText( game["defenders"], &"OW_OBJECTIVES_DEFENDERS_BEL" );
	
	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["attackers"], &"OW_OBJECTIVES_ATTACKERS_BEL" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["defenders"], &"OW_OBJECTIVES_DEFENDERS_BEL" );
	}
	else
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["attackers"], &"OW_OBJECTIVES_ATTACKERS_BEL_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["defenders"], &"OW_OBJECTIVES_DEFENDERS_BEL_SCORE" );
	}
	maps\mp\gametypes\_globallogic::setObjectiveHintText( game["attackers"], &"OW_OBJECTIVES_ATTACKERS_BEL_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( game["defenders"], &"OW_OBJECTIVES_DEFENDERS_BEL_HINT" );
			
	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );	
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( game["attackers"], "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( game["defenders"], "mp_tdm_spawn" );

	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );
	
	allowed[0] = "war";
	
	if ( getDvarInt( "scr_oldHardpoints" ) > 0 )
		allowed[1] = "hardpoint";
	
	level.displayRoundEndText = false;
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	level thread balanceTeams();
}


/*
=============
balanceTeams

Auto-balances the teams in case players disconnect or switch to spectator 
=============
*/
balanceTeams()
{
	level endon("game_ended");
	
	for (;;)
	{
		xWait( level.scr_teambalance_delay );
		
		// Get the number of defenders allowed
		allowedDefenders = numberOfAllowedDefenders();
		autoBalance = true;

		// Move players until the teams are balanced again
		while ( autoBalance ) {
			autoBalance = false;	
			totalDefenders = getNumberOfPlayers( game["defenders"] );
			
			// Check if we need to move attackers to defenders
			if ( totalDefenders < allowedDefenders ) {
				autoBalance = moveRandomPlayer( game["defenders"] );
				
			// Check if we need to move defenders to attackers
			} else if ( totalDefenders > ( allowedDefenders + 1 ) ) {
				autoBalance = moveRandomPlayer( game["attackers"] );
			}
		}
	}	
}


/*
=============
menuAutoAssign

Replaces the stock function that handles the auto assign of players to teams
=============
*/
menuAutoAssign()
{
	self maps\mp\gametypes\_globallogic::closeMenus();

	// Get the number of defenders allowed
	allowedDefenders = numberOfAllowedDefenders();
	totalDefenders = getNumberOfPlayers( game["defenders"] );
	
	// Check if we have enough defenders already
	if ( totalDefenders < allowedDefenders ) {
		assignment = game["defenders"];
	} else {
		assignment = game["attackers"];
	}

	self.pers["team"] = assignment;
	self.team = assignment;
	self.pers["class"] = undefined;
	self.class = undefined;
	self.pers["weapon"] = undefined;
	self.pers["savedmodel"] = undefined;

	self maps\mp\gametypes\_globallogic::updateObjectiveText();

	self.sessionteam = assignment;

	if ( !isAlive( self ) ) {
		// Check if we should show the player status
		if ( level.scr_show_player_status == 1 ) {
			self.statusicon = "hud_status_dead";
		} else {
			self.statusicon = "";
		}
	}

	lpselfnum = self getEntityNumber();
	lpselfname = self.name;
	lpselfteam = self.pers["team"];
	lpselfguid = self getGuid();

	logPrint( "JT;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + "\n" );

	self notify("joined_team");
	self thread maps\mp\gametypes\_globallogic::showPlayerJoinedTeam();
	self notify("end_respawn");

	self maps\mp\gametypes\_globallogic::beginClassChoice();

	self setclientdvar( "g_scriptMainMenu", game[ "menu_class_" + self.pers["team"] ] );
}


spawnPlayer()
{
	self endon("disconnect");
	
	// Check if we should switch the player to the other team before he/she spawns
	if ( isDefined( self.needsMove ) && self.needsMove ) {
		self.beingMoved = true;
		
		// Switch the player's team
		newTeam = level.otherTeam[self.pers["team"]];
		self.pers["team"] = newTeam;
		self.team = newTeam;
		self.pers["savedmodel"] = undefined;
		self.pers["teamTime"] = 0;
		self.sessionteam = newTeam;		
		
		// Make sure we don't move twice
		self.needsMove = false;
		self.beingMoved = false;
	}
	
	// Continue with the stock routine to spawn the player
	self thread maps\mp\gametypes\_globallogic::spawnPlayer();
	
}

/*
=============
onSpawnPlayer

Spawns the player close to their teammates and starts some modules in case the player is a defender
=============
*/
onSpawnPlayer( teamMove )
{
	spawnTeam =  self.pers["team"];
	self.usingObj = undefined;

	if ( level.inGracePeriod )
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
	
	// If it's a team move we just return where the player needs to be moved
	if ( isDefined( teamMove ) && teamMove ) {
		return spawnPoint;
	} else {
		self spawn( spawnPoint.origin, spawnPoint.angles );

		// Show the player if he is a defender or attacker
		if ( self.pers["team"] == game["defenders"] ) {
			textLine = &"OW_BEL_SPAWNED_DEFENDER";
			glowColor = (0.2, 0.3, 0.7);
		} else {
			textLine = &"OW_BEL_SPAWNED_ATTACKER";
			glowColor = (0.7, 0.2, 0.2);
		}
		self thread spawnInformation( textLine, glowColor );
	}
	
	// If this player is a defender start giving score points for surviving
	if ( self.pers["team"] == game["defenders"] ) {
		self thread createHudElements();
		
		// Check if we need to show the player in the compass
		if ( level.scr_bel_showoncompass != 0 ) {
			self thread showOnCompass();
		}
	}
}


/*
=============
createHudElements

Creates the HUD elements for defenders to see how much time they have been alive and how many points they have earned so far
=============
*/
createHudElements()
{
	self endon("disconnect");
	
	if ( !isDefined( self.hudTimeAlive ) ) {
		// Total time alive as defender
		self.hudTimeAlive = createFontString( "objective", 1.4 );
		self.hudTimeAlive setPoint( "BOTTOMRIGHT", "BOTTOMRIGHT", 0, -105 );
		self.hudTimeAlive.glowColor = (0.7, 0.2, 0.2);
		self.hudTimeAlive.archived = false;
		self.hudTimeAlive.label = &"OW_BEL_TIME_ALIVE";
		self.hudTimeAlive setValue(0);
		self.hudTimeAlive.myValue = 0;
	}
	self.hudTimeAlive.color = (1,1,1);
	self.hudTimeAlive.glowAlpha = 0;
	self.hudTimeAlive.alpha = 1;
	
	if ( !isDefined( self.hudPointsEarned ) ) {
		// Total points gained as defender
		self.hudPointsEarned = createFontString( "objective", 1.4 );
		self.hudPointsEarned setPoint( "BOTTOMRIGHT", "BOTTOMRIGHT", 0, -90 );
		self.hudPointsEarned.glowColor = (0.7, 0.2, 0.2);
		self.hudPointsEarned.archived = false;
		self.hudPointsEarned.label = &"OW_BEL_POINTS_EARNED";
		self.hudPointsEarned setValue(0);
		if ( level.scr_bel_alive_points_time >= 5 ) {
			self.hudPointsEarned maps\mp\gametypes\_hud::fontPulseInit();
			self.maxFontScale = 4.6;
		}
		self.hudPointsEarned.myValue = 0;
	}
	self.hudPointsEarned.color = (1,1,1);
	self.hudPointsEarned.glowAlpha = 0;
	self.hudPointsEarned.alpha = 1;

	// Start giving score to the player and refresh the time alive
	self thread giveSurvivalScore();
	
	// Wait for the player to be killed and hide the elements
	self waittill_any( "killed_player", "stop_survivalscore" );
	self.hudTimeAlive.alpha = 0;
	self.hudPointsEarned.alpha = 0;
}


/*
=============
giveSurvivalScore

Gives the survival score to defenders
=============
*/
giveSurvivalScore()
{
	self endon("disconnect");
	self endon("death");
	self endon("stop_survivalscore");
	level endon("game_ended");
	
	for (;;)
	{
		// Wait for the proper amount of time
		xWait(1);
		
		// Make sure there are attackers in the server
		if ( getNumberOfPlayers( game["attackers"] ) == 0 )
			continue;

		// Increase the alive time
		self.hudTimeAlive.myValue++;
		self.hudTimeAlive setValue(self.hudTimeAlive.myValue);		
		
		if ( self.hudTimeAlive.myValue % level.scr_bel_alive_points_time != 0 )
			continue;
		
		// Give and check player score
		self.hudPointsEarned.myValue += level.scr_bel_alive_points;
		self.hudPointsEarned setValue(self.hudPointsEarned.myValue);
		if ( level.scr_bel_alive_points_time >= 5 ) {
			self.hudPointsEarned thread maps\mp\gametypes\_hud::fontPulse( self );
		}
		
		score = self.pers["score"];
		self.pers["score"] += level.scr_bel_alive_points;
	
		self maps\mp\gametypes\_rank::giveRankXP( "survival", level.scr_bel_alive_points, true );
		self maps\mp\gametypes\_persistence::statAdd( "score", ( self.pers["score"] - score ) );
		self.score = self.pers["score"];
	
		thread maps\mp\gametypes\_globallogic::sendUpdatedDMScores();
		self notify ( "update_playerscore_hud" );
	
		self thread maps\mp\gametypes\_globallogic::checkScoreLimit();		
	}	
}


/*
=============
showOnCompass

Shows defenders on the compass every certain interval
=============
*/
showOnCompass()
{
	self endon("disconnect");
	self endon("death");
	self endon( "stop_showoncompass" );
	level endon("game_ended");
	
	// If both type of icons are disabled there's nothing to do here
	if ( level.scr_hud_show_2dicons == 0 && level.scr_hud_show_3dicons == 0 )
		return;
	
	for (;;)
	{
		// Wait for the proper amount of time
		xWait( level.scr_bel_showoncompass_interval );
		
		// Make sure this player is not being point out already (compatible with the AACP functionality)
		if ( isDefined( self.pointOut ) && self.pointOut ) {
			continue;
		} else {
			self.pointOut = true;
		}
	
		// Get the next objective ID to use
		if ( level.scr_hud_show_2dicons == 1 ) {
			objCompass = maps\mp\gametypes\_gameobjects::getNextObjID();
			if ( objCompass != -1 ) {
				objective_add( objCompass, "active", self.origin + (0,0,75) );
				objective_icon( objCompass, "compass_waypoint_target" );
				// Check if we should follow the player
				if ( level.scr_bel_showoncompass == 2 ) {
					objective_onentity( objCompass, self );
				}
				objective_team( objCompass, level.otherTeam[ self.pers["team"] ] );
			}
		} else {
			objCompass = -1;
		}
		
		// Create 3D icon
		if ( level.scr_hud_show_3dicons == 1 ) {
			objWorld = newTeamHudElem( level.otherTeam[ self.pers["team"] ] );		
			origin = self.origin + (0,0,75);
			objWorld.name = "pointout_" + self getEntityNumber();
			objWorld.x = origin[0];
			objWorld.y = origin[1];
			objWorld.z = origin[2];
			objWorld.baseAlpha = 1.0;
			objWorld.isFlashing = false;
			objWorld.isShown = true;
			objWorld setShader( level.aacpIconShader, level.objPointSize, level.objPointSize );
			objWorld setWayPoint( true, "waypoint_kill" );
			// Check if we should follow the player
			if ( level.scr_bel_showoncompass == 2 ) {
				objWorld setTargetEnt( self );
			}
		} else {
			objWorld = undefined;
		}
					
		// Start the thread to delete the objective once the player dies, disconnects, or time passes
		self thread deleteObjectiveOnDDH( objCompass, objWorld );
	
		// Check if we need to give score to the player
		if ( level.scr_bel_showoncompass_points > 0 && getNumberOfPlayers( game["attackers"] ) > 0 ) {
			score = self.pers["score"];
			self.pers["score"] += level.scr_bel_showoncompass_points;
		
			self maps\mp\gametypes\_rank::giveRankXP( "survival", level.scr_bel_showoncompass_points, true );
			self maps\mp\gametypes\_persistence::statAdd( "score", ( self.pers["score"] - score ) );
			self.score = self.pers["score"];
		
			thread maps\mp\gametypes\_globallogic::sendUpdatedDMScores();
			self notify ( "update_playerscore_hud" );
		
			self thread maps\mp\gametypes\_globallogic::checkScoreLimit();			
		}
	
		// Change the color of the HUD elements to red so the player knows he is being pointed out
		self.hudTimeAlive.color = (1,0,0);
		self.hudTimeAlive.glowAlpha = 1;
		self.hudPointsEarned.color = (1,0,0);
		self.hudPointsEarned.glowAlpha = 1;
		self playLocalSound( "mp_obj_taken" );
	
		xWait( level.scr_bel_showoncompass_time );
		self notify( "hide_playeroncompass" );
	}		
}


/*
=============
deleteObjectiveOnDDH

Removes the location items once the time has passed or if the player gets killed or disconnects
=============
*/
deleteObjectiveOnDDH( objID, objWorld )
{
	self waittill_any( "killed_player", "disconnect", "hide_playeroncompass", "game_ended" );
	
	// Make sure this player can be pointed out again
	if ( isDefined( self ) )
		self.pointOut = false;

	// Delete the objective
	if ( objID != -1 ) {
		objective_delete( objID );
		maps\mp\gametypes\_gameobjects::resetObjID( objID );
	}
	
	if ( isDefined( objWorld ) ) {
		objWorld destroy();
	}

	// Change the HUD elements back to white
	self.hudTimeAlive.color = (1,1,1);
	self.hudTimeAlive.glowAlpha = 0;
	self.hudPointsEarned.color = (1,1,1);
	self.hudPointsEarned.glowAlpha = 0;
}


/*
=============
onPlayerKilled

Monitors and switches players from defenders to attackers and vice versa based on the who was killed and how
=============
*/
onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	// If the victim was an attacker we don't do anything at all
	if ( self.pers["team"] == game["attackers"] )
		return;
		
	// If it was a team kill we don't do anything at all
	if ( isDefined( attacker ) && isPlayer( attacker ) && attacker != self && attacker.pers["team"] == self.pers["team"] )
		return;
		
	// The victim will need to switch
	self.needsMove = true;

	// If the attacker is a player and is not already switching or switched we'll switch him to defenders. If the attacker already moved we won't
	// moved the victim as it means the attacker probably got multiple kills at the sametime and it will unbalance the teams.
	if ( isDefined( attacker ) && isPlayer( attacker ) && attacker.pers["team"] == game["attackers"] ) {
		if ( !isDefined( attacker.beingMoved ) || !attacker.beingMoved ) {
			// Move the attacker
			attacker thread movePlayer( game["defenders"], false );			
		}		
	}
}


/*
=============
moveRandomPlayer

Moves a random players from one team to the other
=============
*/
moveRandomPlayer( toTeam )
{
	fromTeam = level.otherTeam[toTeam];
	
	// Fill an array with all the players in the source team
	sourceTeam = [];
	for ( index = 0; index < level.players.size; index++ ) {
		if ( isDefined( level.players[index].pers["team"] ) ) {
			if ( ( !isDefined( level.players[index].beingMoved ) || !level.players[index].beingMoved ) && ( !isDefined( level.players[index].needsMove ) || !level.players[index].needsMove ) && level.players[index].pers["team"] == fromTeam ) {
				sourceTeam[sourceTeam.size] = level.players[index];
			}
		}
	}
	
	// Check that we have at least one player to move
	if ( sourceTeam.size > 0 ) {
		// Get a random player
		randomPlayer = randomInt( sourceTeam.size );
		sourceTeam[randomPlayer] movePlayer( toTeam, true );
		return true;
	} else {
		return false;
	}
}


/*
=============
movePlayer

Moves a player to the other team. If the player is alive the player will just be "transported" into the new location.
=============
*/
movePlayer( newTeam, autoBalance )
{
	self endon("disconnect");
	
	if ( isDefined( self.beingMoved ) && self.beingMoved )
		return;
	
	if ( self.pers["team"] == newTeam )
		return;
	
	// Make sure this player is not already being switched
	self.beingMoved = true;
	playerAlive = isAlive( self );
	
	if ( playerAlive ) {
		self maps\mp\gametypes\_globallogic::closeMenus();

		// Protect and freeze the player during the switch
		self.spawn_protected = true;
		self freezeControls( true );
		
		// Give full health and remove previous planted explosives from this player
		self.health = self.maxhealth;
		self deleteExplosives();

		// Let the player know he/she is switching to the other team
		if ( newTeam == game["defenders"] ) {
			textLine = &"OW_BEL_WILLSPAWN_DEFENDER";
			glowColor = (0.2, 0.3, 0.7);
		} else {
			textLine = &"OW_BEL_WILLSPAWN_ATTACKER";
			glowColor = (0.7, 0.2, 0.2);
		}
		self autoBalanceInformation( textLine, glowColor, autoBalance );
	}	

	self.pers["team"] = newTeam;
	self.team = newTeam;
	self.pers["savedmodel"] = undefined;
	self.pers["teamTime"] = 0;
	self.sessionteam = newTeam;
	self.tag_stowed_back = undefined;
	self.tag_stowed_hip = undefined;
	self maps\mp\gametypes\_globallogic::updateObjectiveText();
	
	// Re-adjust the model of the player and give him full ammo again
	if ( !level.rankedMatch ) {
		self maps\mp\gametypes\_class_unranked::giveLoadout( self.team, self.class );
	} else {
		self maps\mp\gametypes\_class::giveLoadout( self.team, self.class );
	}

	// We indicate the player is not being moved anymore as soon as we switch the team
	self.beingMoved = false;	

	if ( playerAlive ) {
		// Get the new spawn point for this player
		spawnPoint = self onSpawnPlayer( true );
		
		// Move the player
		self setOrigin( spawnPoint.origin );
		self setPlayerAngles( spawnPoint.angles );
		
		self notify( "weapon_change", "none" );
		self thread maps\mp\gametypes\_friendicons::showFriendIcon();
		
		// Release the player
		self freezeControls( false );	
		self.spawn_protected = false;
		
		if ( level.scr_explosives_allow_disarm == 1 )
			self thread openwarfare\_disarmexplosives::onPlayerSpawned();
		if ( level.specialty_grenadepulldeath_check_frags == 1 )
			self thread openwarfare\_martyrdom::onPlayerSpawned();
		if ( level.scr_enable_spawn_protection == 1 )
			self thread openwarfare\_spawnprotection::onPlayerSpawned();		
			
		// If this player is a defender start giving score points for surviving
		if ( self.pers["team"] == game["defenders"] ) {
			self thread createHudElements();
			
			// Check if we need to show the player in the compass
			if ( level.scr_bel_showoncompass != 0 ) {
				self thread showOnCompass();
			}
		} else {
			// Stop all the defender's threads
			self notify( "hide_playeroncompass" );
			self notify( "stop_showoncompass" );
			self notify( "stop_survivalscore" );		
		}
	}
	
	// Notify other modules about the team switch
	self notify("joined_team");	
	self thread maps\mp\gametypes\_globallogic::showPlayerJoinedTeam();
}


/*
=============
autoBalanceInformation

Displays the message to the player that is being switched to the other team
=============
*/
autoBalanceInformation( textLine, glowColor, autoBalance )
{
	self notify("hide_spawninformation");
	self endon("disconnect");

	autoBalanceHud = undefined;

	// Create the black screen
	blackScreenHud = newClientHudElem( self );
	blackScreenHud.x = 0;
	blackScreenHud.y = 0;
	blackScreenHud.alignX = "left";
	blackScreenHud.alignY = "top";
	blackScreenHud.horzAlign = "fullscreen";
	blackScreenHud.vertAlign = "fullscreen";
	blackScreenHud.sort = -5;
	blackScreenHud.color = (0,0,0);
	blackScreenHud.archived = true;
	blackScreenHud setShader( "black", 640, 480 );	
	blackScreenHud.alpha = 0.5;
	
	// Show the message that this is an auto-balance 
	if ( autoBalance ) {
		autoBalanceHud = createFontString( "objective", 2.0 );
		autoBalanceHud.archived = true;
		autoBalanceHud.hideWhenInMenu = true;
		autoBalanceHud.alignX = "center";
		autoBalanceHud.alignY = "top";
		autoBalanceHud.horzAlign = "center";
		autoBalanceHud.vertAlign = "top";
		autoBalanceHud.sort = 5;
		autoBalanceHud.x = 0;
		autoBalanceHud.y = 60;
		autoBalanceHud setText( game["strings"]["autobalance"] );
	} else {		
		self playLocalSound( "mp_obj_returned" );
	}

	// Show the new team information
	textLineHud = createFontString( "objective", 3.0 );
	textLineHud.glowAlpha = 1;
	textLineHud.glowColor = glowColor;
	textLineHud.archived = true;
	textLineHud.hideWhenInMenu = true;
	textLineHud.alignX = "center";
	textLineHud.alignY = "top";
	textLineHud.horzAlign = "center";
	textLineHud.vertAlign = "top";
	textLineHud.sort = 5;
	textLineHud.x = 0;
	if ( autoBalance ) {
		textLineHud.y = 85;
	} else {
		textLineHud.y = 60;
	}
	textLineHud setText( textLine );
	textLineHud maps\mp\gametypes\_hud::fontPulseInit();
	textLineHud.maxFontScale = 4.6;
	textLineHud thread maps\mp\gametypes\_hud::fontPulse( self );
			
	xWait(3);
	
	// Destroy the elements
	blackScreenHud destroy();
		
	if ( isDefined( autoBalanceHud ) )
		autoBalanceHud destroy();
		
	textLineHud destroy();	
}


/*
=============
spawnInformation

Displays the message to the player when he/she spawns
=============
*/
spawnInformation( textLine, glowColor )
{
	self endon("disconnect");

	textLineHud = createFontString( "objective", 3.0 );
	textLineHud.glowAlpha = 1;
	textLineHud.glowColor = glowColor;
	textLineHud.archived = true;
	textLineHud.hideWhenInMenu = true;
	textLineHud.alignX = "center";
	textLineHud.alignY = "top";
	textLineHud.horzAlign = "center";
	textLineHud.vertAlign = "top";
	textLineHud.sort = 5;
	textLineHud.x = 0;
	textLineHud.y = 60;
	textLineHud setText( textLine );
	textLineHud maps\mp\gametypes\_hud::fontPulseInit();
	textLineHud.maxFontScale = 4.6;
	textLineHud thread maps\mp\gametypes\_hud::fontPulse( self );
			
	self thread waitAndSendEvent( 4, "hide_spawninformation" );
	self waittill( "hide_spawninformation" );
	
	// Destroy the elements
	textLineHud destroy();	
}


/*
=============
getNumberOfPlayers

Counts the number of player in certain team taking into consideration players that are being switched to the other team
=============
*/
getNumberOfPlayers( team )
{
	amountOfPlayers = 0;
	
	for ( index = 0; index < level.players.size; index++ ) {
		if ( isDefined( level.players[index].pers["team"] ) ) {
			// Check if this player is in the process of being moved
			if ( isDefined( level.players[index].beingMoved ) && level.players[index].beingMoved && level.players[index].pers["team"] == level.otherTeam[team] ) {
				amountOfPlayers++;
				
			// Check if this player will already be moved on his next spawn
			} else if ( isDefined( level.players[index].needsMove ) && level.players[index].needsMove && level.players[index].pers["team"] == level.otherTeam[team] ) { 
				amountOfPlayers++;
				
			// Check if this player belongs to the team we are looking for
			} else if ( level.players[index].pers["team"] == team ) {
				amountOfPlayers++;
			}
		}		
	}
	
	return amountOfPlayers;	
}


/*
=============
numberOfAllowedDefenders

Calculates how many defenders should be allowed in the game based on the total number of players playing the game
=============
*/
numberOfAllowedDefenders()
{
	// Count the total number of players
	totalPlayers = 0;
	for ( index = 0; index < level.players.size; index++ ) {
		if ( isDefined( level.players[index].pers["team"] ) && ( level.players[index].pers["team"] == "allies" || level.players[index].pers["team"] == "axis" ) ) {
			totalPlayers++;
		}		
	}
	
	// Calculate how many defenders
	totalPlayers = int( totalPlayers / 3 );
	if ( totalPlayers == 0 ) {
		totalPlayers = 1;
	} else if ( totalPlayers > 16 ) {
		totalPlayers = 16;
	}
	
	return totalPlayers;	
}