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
	Assassination

	Objective: Defenders need to kill the VIP or prevent him from reaching the extraction zone.
	Map ends: When the VIP reaches the extraction zone before the time limit or the VIP gets killed.
	Respawning: Players remain dead for the round and will respawn at the beginning of the next round.

	Level requirements
	------------------
		Spawnpoints:
			classname	mp_ass_spawn_attackers_start, mp_ass_spawn_defenders_start
			All players spawn from these at the beginning of the round. 

		Spectator spawnpoints:
			classname	mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			At least one is required, any more and they are randomly chosen between.

		Extraction Zone:
			classname trigger_radius targetname ass_extraction_zone
			Extraction zone that the VIP needs to reach.

		game["attackers"] = "allies";
		game["defenders"] = "axis";
			This sets which team is attacking and which team is defending. Defenders need to protect the extraction zone or kill the VIP.
			
		Note:
			In the case the map doesn't support the above VIP assets natively this
			implementation of VIP will try to use the location of the bombsites from
			Sabotage to determine the position of the extraction zones.
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
		
	if ( !isDefined( game["attackers"] ) || !isDefined( game["defenders"] ) ) {
		game["attackers"] = "allies";
		game["defenders"] = "axis";
	}

	// Additional variables that we'll be using
	level.scr_ass_vip_health = getdvarx( "scr_ass_vip_health", "int", 0, 0, 500 );
	level.scr_ass_force_vip_handgun = getdvarx( "scr_ass_force_vip_handgun", "string", "" );
	level.scr_ass_extracting_time = getdvarx( "scr_ass_extracting_time", "float", 3, 0, 60 );
	
	level.scr_ass_scoreboard_vip = getdvarx( "scr_ass_scoreboard_vip", "int", 0, 0, 1 );
	level.scr_ass_vip_clan_tags = getdvarx( "scr_ass_vip_clan_tags", "string", "" );
	level.scr_ass_vip_clan_tags = strtok( level.scr_ass_vip_clan_tags, " " );
	
	
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	// Get the dvars we need for this gametype
	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 1, 1, 1 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 5, 0, 500 );
	maps\mp\gametypes\_globallogic::registerRoundSwitchDvar( level.gameType, 2, 0, 500 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 3, 0, 5000 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 5, 0, 1440 );


	level.teamBased = true;
	level.overrideTeamScore = true;
	level.endGameOnScoreLimit = true;
	level.onDeadEvent = ::onDeadEvent;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onRoundSwitch = ::onRoundSwitch;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onStartGameType = ::onStartGameType;
	level.onTimeLimit = ::onTimeLimit;

	game["dialog"]["gametype"] = gameTypeDialog( "ass" );
	
	game["strings"]["vip_extracted"] = &"OW_ASSASSINATION_VIP_EXTRACTED";
	game["strings"]["vip_killed"] = &"OW_ASSASSINATION_VIP_ELIMINATED";	
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

	// Precache team dependent assets
	switch ( game[game["attackers"]] ) {
		case "marines":
			game[level.gameType]["extraction_base_effect"] = loadFX( "misc/ui_flagbase_silver" );
			break;
		case "sas":
			game[level.gameType]["extraction_base_effect"] = loadFX( "misc/ui_flagbase_black" );
			break;
		case "russian":
			game[level.gameType]["extraction_base_effect"] = loadFX( "misc/ui_flagbase_red" );
			break;
		case "opfor":
		case "arab":
		default:
			game[level.gameType]["extraction_base_effect"] = loadFX( "misc/ui_flagbase_gold" );
			break;
	}
	
	// Precache some resources needed 
	precacheStatusIcon( "hud_status_vip" );
	precacheShader( "icon_vip" );
	
	precacheShader( "compass_waypoint_extraction_zone" );
	precacheShader( "waypoint_extraction_zone" );
	
	precacheShader( "compass_waypoint_defend" );
	precacheShader( "waypoint_defend" );
	
	precacheModel( "body_complete_mp_zakhaev" );
}


/*
=============
onStartGameType

Show objectives to the player, initialize spawn points, and register score information
=============
*/
onStartGameType()
{
	if ( game["switchedsides"] ) {
		oldAttackers = game["attackers"];
		oldDefenders = game["defenders"];
		game["attackers"] = oldDefenders;
		game["defenders"] = oldAttackers;
	}

	// Check if this map supports native Assassination
	nativeASS = isDefined( getEnt( "ass_extraction_zone", "targetname" ) );

	maps\mp\gametypes\_globallogic::setObjectiveText( game["attackers"], &"OW_ASSASSINATION_ATTACKER" );
	maps\mp\gametypes\_globallogic::setObjectiveText( game["defenders"], &"OW_ASSASSINATION_DEFENDER" );

	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["attackers"], &"OW_ASSASSINATION_ATTACKER" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["defenders"], &"OW_ASSASSINATION_DEFENDER" );
	}
	else
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["attackers"], &"OW_ASSASSINATION_ATTACKER_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["defenders"], &"OW_ASSASSINATION_DEFENDER_SCORE" );
	}
	maps\mp\gametypes\_globallogic::setObjectiveHintText( game["attackers"], &"OW_ASSASSINATION_ATTACKER" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( game["defenders"], &"OW_ASSASSINATION_DEFENDER" );

	setClientNameMode("auto_change");

	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );

	// If the map doesn't support Assassination natively we'll use the location of Sabotage's assets
	if ( nativeASS ) {
		maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_ass_spawn_attackers_start" );
		maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_ass_spawn_defenders_start" );			
	} else {
		// Let's get the trigger origins of the defender's bombsite before we get rid of all the map assets
		level.extractionZoneOrigin = getOriginFromBombZone( "sab_bomb_axis" );
		maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sab_spawn_allies_start" );
		maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sab_spawn_axis_start" );		
	}

	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );

	if ( nativeASS ) {
		level.spawn_attackers_start = getentarray( "mp_ass_spawn_attackers_start", "classname" );
		level.spawn_defenders_start = getentarray( "mp_ass_spawn_defenders_start", "classname" );
	} else {
		level.spawn_attackers_start = getentarray( "mp_sab_spawn_allies_start", "classname" );
		level.spawn_defenders_start = getentarray( "mp_sab_spawn_axis_start", "classname" );			
	}
	
	if ( game["attackers"] == "allies" ) {
		level.startPos["allies"] = level.spawn_attackers_start[0].origin;
		level.startPos["axis"] = level.spawn_defenders_start[0].origin;
	} else {
		level.startPos["allies"] = level.spawn_defenders_start[0].origin;
		level.startPos["axis"] = level.spawn_attackers_start[0].origin;
	}

	level.displayRoundEndText = true;

	allowed[0] = "ass";
	maps\mp\gametypes\_gameobjects::main(allowed);

	thread veryImportantPerson();
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
onTimeLimit

Defenders win in case of time limit reaches as the VIP wasn't able to reach the extraction zone
=============
*/
onTimeLimit()
{
	[[level._setTeamScore]]( game["defenders"], [[level._getTeamScore]]( game["defenders"] ) + 1 );
	thread maps\mp\gametypes\_globallogic::endGame( game["defenders"], game["strings"][game["defenders"]+"_win_round"] );
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

Declares attackers as the winner in the case the defenders team has been eliminated
=============
*/
onDeadEvent( team )
{
	// The elimination of the attackers team means the VIP has been killed
	if ( team ==  game["defenders"] ) {
		[[level._setTeamScore]]( game["attackers"], [[level._getTeamScore]]( game["attackers"] ) + 1 );
		thread maps\mp\gametypes\_globallogic::endGame( game["attackers"], game["strings"][game["defenders"] + "_eliminated"] );
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
	self.isVIP = false;

	if ( self.pers["team"] == game["attackers" ] ) {
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( level.spawn_attackers_start );
	} else {
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( level.spawn_defenders_start );
	}
	assert( isDefined(spawnPoint) );

	self spawn( spawnPoint.origin, spawnPoint.angles );
}


/*
=============
veryImportantPerson

Initializes all the map entities to be used or creates them (based on Sabotage) in the case
the native ASS assets are not present. 
=============
*/
veryImportantPerson()
{
	// Make sure the map has all the assets we need
	gametypeAssets = [];
	gametypeAssets["extractionzone_trigger"] = getEnt( "ass_extraction_zone", "targetname" );
	if ( !isDefined( gametypeAssets["extractionzone_trigger"] ) ) {
		// Check if we can manually create the trigger
		if ( isDefined( level.extractionZoneOrigin ) ) {
			gametypeAssets["extractionzone_trigger"] = spawn( "trigger_radius", level.extractionZoneOrigin, 0, 40, 10 );
		} else {
			error( "No ass_extraction_zone trigger found in map." );
			maps\mp\gametypes\_callbacksetup::AbortLevel();
			return;
		}
	}
	
	// Create the extraction zone
	level.extractionZone = createExtractionZone( game["attackers"], gametypeAssets["extractionzone_trigger"] );
	
	// Pick the VIP 
	level thread pickVIP();
}


/*
=============
createExtractionZone

Creates the extraction zone that the VIP needs to reach
=============
*/
createExtractionZone( attackerTeam, zoneTrigger )
{
	// Create the use object with 0 useTime so it's immediate
	extractionZone = maps\mp\gametypes\_gameobjects::createUseObject( attackerTeam, zoneTrigger, undefined, (0,0,100) );
	extractionZone maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	extractionZone maps\mp\gametypes\_gameobjects::setUseTime( level.scr_ass_extracting_time );
	if ( level.scr_ass_extracting_time > 0 ) {
		extractionZone maps\mp\gametypes\_gameobjects::setUseText( &"OW_ASSASSINATION_EXTRACTING_VIP" );
	}
	extractionZone maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_extraction_zone" );
	extractionZone maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_extraction_zone" );
	extractionZone maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_extraction_zone" );
	extractionZone maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_extraction_zone" );
	extractionZone maps\mp\gametypes\_gameobjects::allowUse( "friendly" );
	extractionZone.onUse = ::onUse;

	// Spawn an special effect at the base of the extraction zone to indicate where it is located
	traceStart = zoneTrigger.origin + (0,0,32);
	traceEnd = zoneTrigger.origin + (0,0,-32);
	trace = bulletTrace( traceStart, traceEnd, false, undefined );
	upangles = vectorToAngles( trace["normal"] );
	extractionZone.baseEffect = spawnFx( game[level.gameType]["extraction_base_effect"], trace["position"], anglesToForward( upangles ), anglesToRight( upangles ) );
	triggerFx( extractionZone.baseEffect );
	
	return extractionZone;
}


/*
=============
onUse

Checks if the player that has entered the extraction zone is the VIP and gives the corresponding score
=============
*/
onUse( player )
{
	// Check if this player is the VIP
	if ( isPlayer( player ) && player.isVIP ) {
		self maps\mp\gametypes\_gameobjects::allowUse( "none" );
		player notify("vipextracted");
		
		// Give the player the extracted score and the team 1 point
		player thread [[level.onXPEvent]]( "capture" );
		maps\mp\gametypes\_globallogic::givePlayerScore( "capture", player );
		[[level._setTeamScore]]( game["attackers"], [[level._getTeamScore]]( game["attackers"] ) + 1 );
	
		lpselfnum = player getEntityNumber();
		lpGuid = player getGuid();
		logPrint("EV;" + lpGuid + ";" + lpselfnum + ";" + player.name + "\n");	
			
		thread maps\mp\gametypes\_globallogic::endGame( game["attackers"], game["strings"]["vip_extracted"] );
	}
}


/*
=============
onPlayerKilled

Checks if the victim was killed within 20 meters of the VIP and gives the score for defending the VIP
to the attacker
=============
*/
onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	// Check if the victim was the VIP
	if ( self.isVIP ) {
		self notify( "vipkilled" );
		
		if ( isPlayer( attacker ) ) {
			if ( self.pers["team"] != attacker.pers["team"] ) {
				attacker thread [[level.onXPEvent]]( "capture" );
				maps\mp\gametypes\_globallogic::givePlayerScore( "capture", attacker );		
		
				lpselfnum = attacker getEntityNumber();
				lpGuid = attacker getGuid();
				logPrint("KV;" + lpGuid + ";" + lpselfnum + ";" + attacker.name + "\n");
			} else {
				lpselfnum = attacker getEntityNumber();
				lpGuid = attacker getGuid();
				logPrint("TKV;" + lpGuid + ";" + lpselfnum + ";" + attacker.name + "\n");
			}
		}				
		
		[[level._setTeamScore]]( game["defenders"], [[level._getTeamScore]]( game["defenders"] ) + 1 );
		thread maps\mp\gametypes\_globallogic::endGame( game["defenders"], game["strings"]["vip_killed"] );

	} else if ( self.pers["team"] == game["defenders"] ) {	
		// Make sure the attacker is not in the same team
		if ( isPlayer( attacker ) && self.pers["team"] != attacker.pers["team"] ) {
			// Give double the XP if the killer was the VIP
			if ( attacker.isVIP ) {
				attacker thread [[level.onXPEvent]]( "kill" );
				maps\mp\gametypes\_globallogic::givePlayerScore( "kill", attacker );				
			} else {	
				// Get the distance between the victim and the VIP
				distanceToVIP = distance( self.origin, level.playerVIP.origin );
		
				// 197 units = 20 meters
				if ( distanceToVIP <= 788 ) {
					attacker thread [[level.onXPEvent]]( "defend" );
					maps\mp\gametypes\_globallogic::givePlayerScore( "defend", attacker );
				}
			}
		}
	}
}


/*
=============
pickVIP

Pick a player from the "attackers" team as the VIP
=============
*/
pickVIP()
{
	// Wait until prematch period is over 
	while ( level.inPrematchPeriod )
		wait (0.05);
	
	// Build an array with all the attacking players that are alive at the end of the prematch period
	vipCandidates = [];
	while ( vipCandidates.size == 0 ) {
		wait (0.05);
	
		// Check if we should allow only clan members to be VIP	
		if ( level.scr_ass_vip_clan_tags.size > 0 ) {
			for ( index = 0; index < level.players.size; index++ ) {
				player = level.players[index];
				if ( isDefined( player ) && player.pers["team"] == game["attackers"] && isAlive( player ) && player isPlayerClanMember( level.scr_ass_vip_clan_tags ) ) {
					vipCandidates[vipCandidates.size] = player;
				}
			}			
		}
		
		// Make sure we don't have clan members already in (if there are no clan members we'll pick another player)
		if ( vipCandidates.size == 0 ) {
			for ( index = 0; index < level.players.size; index++ ) {
				player = level.players[index];
				if ( isDefined( player ) && player.pers["team"] == game["attackers"] && isAlive( player ) ) {
					vipCandidates[vipCandidates.size] = player;
				}
			}
		}
	}
	
	// Get a random player from the list of candidates
	vipPlayer = randomIntRange( 0, vipCandidates.size );
	
	// And we have the VIP!
	level.playerVIP = vipCandidates[vipPlayer];
	level.playerVIP.isVIP = true;
	
	// Change the model of the VIP
	level.playerVIP detachHead();
	level.playerVIP setModel( "body_complete_mp_zakhaev" );

	// Verify weapons and remove anyone considered invalid
	level.playerVIP thread removeInvalidWeapons();
	
	// Mark the VIP player for his teammates
	level.playerVIP thread defendVIP();
	
	// Start monitoring threads
	level.playerVIP thread preventInvalidWeaponsPickup();
	level.playerVIP thread onDisconnetVIP();
		
	// Make sure the VIP won't be auto-balanced
	level.playerVIP.dont_auto_balance = true;
	
	// Set the status icon on the scoreboard if enabled
	if ( level.scr_ass_scoreboard_vip == 1 ) {
		level.playerVIP.statusicon = "hud_status_vip";
	}
	
	// Set the Special Ops speed and reset the health if set
	level.playerVIP thread openwarfare\_speedcontrol::setBaseSpeed( getdvarx( "class_specops_movespeed", "float", 1.0, 0.5, 1.5 ) );
	if ( level.scr_ass_vip_health > 0 ) {
		level.playerVIP.maxhealth = level.scr_ass_vip_health;
		level.playerVIP.health = level.scr_ass_vip_health;
	}
	
	// Create the VIP icon and tell the player about it
	level.playerVIP.vipIcon = level.playerVIP createIcon( "icon_vip", 50, 50 );
	level.playerVIP.vipIcon setPoint( "CENTER", "CENTER", 220, 140 );
	level.playerVIP.vipIcon.alpha = 0.75;
	
	level.playerVIP playLocalSound( "mp_challenge_complete" );
}


/*
=============
removeInvalidWeapons

Removes primary and secondary (when necessary) weapons from the VIP player
=============
*/
removeInvalidWeapons()
{
	weaponsList = self getWeaponsList();
	handGun = "";
	
	// Check if we need to force a weapon
	if ( level.scr_ass_force_vip_handgun != "" ) {
		handGun = level.scr_ass_force_vip_handgun;
				
		// Remove all the weapons except grenades and pistols (in case forced weapon is a pistol)
		for( i = 0; i < weaponsList.size; i++ )	{
			currentWeapon = weaponsList[i];
			
			if ( weaponClass( currentWeapon ) == "grenade" )
				continue;
				
			if ( weaponClass( currentWeapon ) == "pistol" && currentWeapon == "binoculars_mp" )
				continue;
				
			self takeWeapon( currentWeapon );
		}
		
	} else {
		// Remove everything except grenades
		for( i = 0; i < weaponsList.size; i++ )	{
			currentWeapon = weaponsList[i];
			
			if ( weaponClass( currentWeapon ) == "grenade" )
				continue;
				
			if ( weaponClass( currentWeapon ) == "pistol" && currentWeapon == "binoculars_mp" )
				continue;				
				
			if ( weaponClass( currentWeapon ) == "pistol" )
					handGun = currentWeapon;
				
			self takeWeapon( currentWeapon );
		}
		
		// Check if the player had no pistol
		if ( handGun == "" ) {
			handGun = "deserteaglegold_mp";
		}		
	}
	
	// Give maximum amount of ammo for the weapon and switch to it
	self giveWeapon( handGun );
	self giveMaxAmmo( handGun );
	self setSpawnWeapon( handGun );
	self switchToWeapon( handGun );
}


/*
=============
preventInvalidWeaponsPickup

Prevents the VIP player from picking up invalid weapons
=============
*/
preventInvalidWeaponsPickup()
{
   self endon("death");
   self endon("disconnect");
   
   for (;;)
   {
      wait (0.05);
      currentWeapon = self getCurrentWeapon();
      
      // If the current weapon is considered "primary" we'll remove it
      if ( weaponClass( currentWeapon ) != "pistol" && weaponClass( currentWeapon ) != "grenade" && currentWeapon != level.scr_ass_force_vip_handgun ) {
      	self dropItem( currentWeapon );
      	
      	// Check if the player has a pistol and automatically switch to it
       	weaponsList = self getWeaponsList();
				for( i = 0; i < weaponsList.size; i++ )	{
					if ( weaponClass( weaponsList[i] ) == "pistol" || weaponsList[i] == level.scr_ass_force_vip_handgun ) {
						self switchToWeapon( weaponsList[i] );
						break;
					}
				}
      }   
   }
}


/*
=============
onDisconnetVIP

Monitor the VIP just in case he/she disconnects... Round will be over in the case the VIP disconnects!
=============
*/
onDisconnetVIP()
{
	self endon("vipextracted");
	self endon("vipkilled");
	
	// If the VIP disconnectes the game ends
	self waittill( "disconnect" );
	[[level._setTeamScore]]( game["defenders"], [[level._getTeamScore]]( game["defenders"] ) + 1 );
	thread maps\mp\gametypes\_globallogic::endGame( game["defenders"], game["strings"]["vip_killed"] );	
}


/*
=============
defendVIP

Sets the corresponding icons on the VIP so players in attackers team know where he is
=============
*/
defendVIP()
{
	// Check if we should show the icon on the compass
	if ( level.scr_hud_show_2dicons == 1 ) {
		// Get the next objective ID to use
		objCompass = maps\mp\gametypes\_gameobjects::getNextObjID();
		objective_add( objCompass, "active", self.origin + (0,0,75) );
		objective_icon( objCompass, "compass_waypoint_defend" );
		objective_onentity( objCompass, self );
		objective_team( objCompass, game["attackers"] );
	}
		
	// Check if we should show the world icon
	if ( level.scr_hud_show_3dicons == 1 ) {
		objWorld = newTeamHudElem( game["attackers"] );		
			
		// Set stuff for world icon
		origin = self.origin + (0,0,75);
		objWorld.name = "defend_vip";
		objWorld.x = origin[0];
		objWorld.y = origin[1];
		objWorld.z = origin[2];
		objWorld.baseAlpha = 0.9;
		objWorld.isFlashing = false;
		objWorld.isShown = true;
		objWorld setShader( "waypoint_defend", level.objPointSize, level.objPointSize );
		objWorld setWayPoint( true, "waypoint_defend" );
		objWorld setTargetEnt( self );	
	}
}


detachHead()
{
	// Get all the attached models from the player
	attachedModels = self getAttachSize();
	
	// Check which one is the head and detach it
	for ( am=0; am < attachedModels; am++ ) {
		thisModel = self getAttachModelName( am );
		
		// Check if this one is the head and remove it
		if ( isSubstr( thisModel, "head_mp_" ) ) {
			self detach( thisModel, "" );
			break;
		}		
	}
	
	return;
}