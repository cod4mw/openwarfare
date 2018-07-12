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
#include openwarfare\_eventmanager;

main()
{
	//Visual Guide Variables
	level.vg_gametype = getdvard( "scr_visualguide_gametype", "string", "dm" );
	level.guide_reticletype = getdvard( "scr_visualguide_reticletype", "int", 0, 0, 1 ); //0 = cursor 1 = entity
	level.guide_color = getdvard( "scr_visualguide_color", "string", "red" ); //red, blue, silver, gold
	
	
	//Standard Gametype Stuff
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.vg_gametype, 0, 0, 0 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.vg_gametype, 1, 0, 1 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.vg_gametype, 0, 0, 0 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.vg_gametype, 1440, 1440, 1440 );	
	
	//We have to determine which gametypes are team based and which gametypes that are not.
	switch( level.vg_gametype )
	{
		case "dm":
		case "lms":
		case "gg":
		case "ss":
		case "oitc":
			level.teamBased = false; break;
		default: level.teamBased = true; break;
	}
	level.onStartGameType = ::onStartGameType;
	
	//Precache Visual Guide stuff and gametype specific stuff
	precacheVisuals();
	
	game["dialog"]["gametype"] = gameTypeDialog( "visual_guide" );
}

/*
*	Function:		precacheVisuals()
*	Purpose:		Precache Visual Guide models and effects as well as gametype specific models
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
precacheVisuals()
{
	//Flags for Spawn Markers and flag objectives
	game["team_flag"]["opfor"] = "prop_flag_opfor";
	game["team_flag"]["marines"] = "prop_flag_american";
	game["team_flag"]["sas"] = "prop_flag_brit";
	game["team_flag"]["russian"] = "prop_flag_russian";
	game["team_flag"]["neutral"] = "prop_flag_neutral";
	
	precacheModel( game["team_flag"]["opfor"] );
	precacheModel( game["team_flag"]["marines"] );
	precacheModel( game["team_flag"]["sas"] );
	precacheModel( game["team_flag"]["russian"] );
	precacheModel( game["team_flag"]["neutral"] );
	
	//Circular Effect colors for reticle/flags/extract zone
	red_circle = "misc/ui_flagbase_red";
	black_circle = "misc/ui_flagbase_black";
	gold_circle = "misc/ui_flagbase_gold";
	silver_circle = "misc/ui_flagbase_silver";
	
	game["circle_effect"]["red"] = loadFx( red_circle );
	game["circle_effect"]["black"] = loadFx( black_circle );
	game["circle_effect"]["gold"] = loadFx( gold_circle );
	game["circle_effect"]["silver"] = loadFx( silver_circle );
		
	//For FX Reticle
	switch( level.guide_color )
	{
		case "red": color = game["circle_effect"]["red"]; break;
		case "black": color = game["circle_effect"]["black"]; break;
		case "gold": color = game["circle_effect"]["gold"]; break;
		case "silver": color = game["circle_effect"]["silver"]; break;
		
		default: color = game["circle_effect"]["red"]; break;
	}
	
	level.reticleColor = color;
	
	
	//Gametype specific models
	switch( level.vg_gametype )
	{
		case "sd":
		case "sab":
			precacheModel( "com_bomb_objective" );
			precacheModel( "prop_suitcase_bomb" );
		break;
		case "re":
			precacheModel( "com_office_book_red_flat" );
		break;
		case "koth":
			precacheModel( "com_laptop_2_open" );
			precacheModel( "com_plasticcase_beige_big" );
		break;
	}
}

/*
*	Function:		onStartGametype()
*	Purpose:		Sets up gametype critical information. Standard gametype function.
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
onStartGameType()
{
	setClientNameMode("auto_change");
	
	level.vg_attackers = "";
	level.vg_defenders = "";
	
	//Determine which side is attackers and which side is defenders if sd or re.
	if ( level.vg_gametype == "sd" || level.vg_gametype == "re" )
	{
		if ( isDefined( game["attackers"] ) && game["attackers"] == "allies" )
		{
			level.vg_attackers = "allies";
			level.vg_defenders = "axis";
		}
		else
		{
			level.vg_attackers = "axis";
			level.vg_defenders = "allies";
		}
	}

	//Pel - Must have this stuff...need to change to VG local strings
	maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OBJECTIVES_DM" );
	maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OBJECTIVES_DM" );
	maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OBJECTIVES_DM_SCORE" );
	maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OBJECTIVES_DM_SCORE" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"OBJECTIVES_DM_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"OBJECTIVES_DM_HINT" );
	
	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );

	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );

		
	// What entities should we allow?	
	switch( level.vg_gametype )
	{
		case "hns":
			allowed[0] = "war";
		break;
		case "koth":
			allowed[0] = "hq";
		break;
		case "sd":
		case "re":
			allowed[0] = "sd";
			allowed[1] = "bombzone";
			allowed[2] = "blocker";
		break;
		case "ass":
		case "ch":
			allowed[0] = "sab";
		break;
		case "ctf":
			if ( isDefined( getEnt( "ctf_trig_allies", "targetname" ) ) )
				allowed[0] = "ctf";
			else
				allowed[0] = "sab";
		break;		
		default: allowed[0] = level.vg_gametype; break;
	}
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
	
	//Remove extra clips
	removeAllBrushModels();
	if ( isDefined( level.mover_done ) && level.mover_done == false )
	{
		while ( level.mover_done == false )
		{
			wait 1;
		}	
	}

	//Loads the Visual Guide - What we are here for.
	initGuide();
}

/*
*	Function:		onPlayerConnected()
*	Purpose:		Calls funcitons and sets up information vital to the player when he/she connects.
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
onPlayerConnected()
{
	self thread addNewEvent( "onJoinedSpectators", ::onJoinedSpectators );
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	
	//Close menu and allow free look
	self closeMenu();
	self allowSpectateTeam( "freelook", true );
	
	if ( isDefined( level.mover_done ) && level.mover_done == false )
	{
		while ( level.mover_done == false )
		{
			wait 1;
		}	
	}

	//Default information for Visual Guide menu
	cat = level.catList[level.catIndex].label;
	cmd = level.cmdList[level.cmdIndex].label;
	self setClientDvars( "cat_info", cat, "item_info", cat, "item_index", level.itemIndex, "cmd_info", cmd );
	
	self thread useReticleOrigin();
	self thread monitorCmds();
}

/*
*	Function:		onJoinedSpectators()
*	Purpose:		Calls functions needed by the player when the player joins spectate.
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
onJoinedSpectators()
{
	self endon( "disconnect" );
	
	self allowSpectateTeam( "freelook", true );	
	self thread useReticleOrigin();
	self thread monitorCmds();
}

/*
*	Function:		onPlayerSpawned()
*	Purpose:		Calls functions and sets up information vital to the player when spawned.
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
onPlayerSpawned()
{
	self endon( "disconnect" );
	/*self takeAllWeapons();
	
	//Pel - Need to add all gametypes
	if(self.pers["team"] == game["attackers"])
		spawnPointName = "mp_sd_spawn_attacker";
	else
		spawnPointName = "mp_sd_spawn_defender";
	
	spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( spawnPointName );
	assert( spawnPoints.size );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );

	self spawn( spawnpoint.origin, spawnpoint.angles );
	self thread monitorCmds();*/
}

/*
*	Function:		useReticleOrigin()
*	Purpose:		Just a setup function for which reticle to use
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
useReticleOrigin()
{
	self endon( "disconnect" );
	
	monitorReticle();	
}

/*
*	Function:		monitorReticle()
*	Purpose:		Monitors the reticle used by the player when in spectate.
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
monitorReticle()
{
	self endon( "disconnect" );

	while ( !isAlive( self ) ) //Pel - do we need to change this or not?
	{
		sOrigin = self getOrigin();
		sAngles = self getPlayerAngles();
		forwardAngle = anglesToForward( sAngles );
		eyePos = self getEye();
		
		// Find where the player is looking.
		trace = bullettrace( eyePos, eyePos + vector_scale( forwardAngle , 10000 ), 0, undefined );
		//Find the ground at the location the player is looking.
        trace2 = bullettrace(  trace["position"] + ( 0, 0, 5 ), trace["position"] - ( 0, 0, 10000 ), 0, undefined );
		
		self.reticlePos = trace2["position"];
		self.lookDirection = sAngles[1]; 	
			
		if ( level.guide_reticletype == 0 ) // FX Reticle w/ Color
		{ 
			drawReticle = spawnFX( level.reticleColor, self.reticlePos );
			triggerFX( drawReticle );
			
			delay = self waitWhileSame( sOrigin, sAngles );
			drawReticle delete();
		}
		else // Fake Object Model Reticle
		{
			model = level.itemList[level.catIndex][level.itemIndex].vg_model;
			if ( level.catList[level.catIndex].label == "extract_zone" )
			{
				reticleModel = spawnFx( game["circle_effect"]["black"], self.reticlePos );
				triggerFx( reticleModel );
			}
			else
			{
				//if ( model != "war_hq_obj" )
				//{
					reticleModel = spawn( "script_model", self.reticlePos );
					reticleModel.angles = ( 0, self.lookDirection, 0 );
				//}
				//else
				//{
				//	reticleModel = spawn( "script_model", self.reticlePos + (0, 0, 36 ) );
				//	reticleModel.angles = ( 0, ( self.lookDirection - 90 ), 15 );
				//}
				reticleModel setModel( model );
				
				if ( level.catList[level.catIndex].label == "flags" )
				{
					reticleModel.effect = spawnFx( game["circle_effect"]["silver"], self.reticlePos );
					triggerFx( reticleModel.effect );
				}
			}			
			delay = self waitWhileSame( sOrigin, sAngles );
			
			if ( level.catList[level.catIndex].label == "flags" && isDefined( reticleModel.effect ) )
				reticleModel.effect delete();
			reticleModel delete();
		}
	}
}

/*
*	Function:		isSame( <param1>, <param2> )
*	Purpose:		Helper function to the waitWhileSame function to check and see if origin or angles are the same as previous coords.
*	Pre-Condition:	begin: The original coords; end: the new coords.
*	Post-Condition: Returns true if new coords == old coords and false otherwise.
*/
isSame( begin, end )
{
	if ( int( begin[0] ) == int( end[0] ) )
	{
		if ( int( begin[1] ) == int( end[1] ) )
		{
			if ( int( begin[2] ) == int( end[2] ) )
				return true;
		}
	}
	return false;
}

/*
*	Function:		initGuide()
*	Purpose:		Sets up the visual guide for player use.
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
initGuide()
{
	level.itemList = [];
	level.catList = [];
	level.cmdList = [];
	level.itemIndex = 0;
	level.catIndex = 0;
	level.cmdIndex = 0;
	
	//Commands to be used with visual guide
	thread setupCommands();
	
	//Setup Items list and categories list based on the different gametypes.
	switch( level.vg_gametype )
	{
		case "dm":
		case "gg":
		case "lms":
		case "ss":
		case "oitc":
			level.itemList[0] = createSpawnAssets( "dm_spawn", undefined, "spawns", &"OW_MOVER_CAT_NEUTRAL" );
		break;
		
		case "war":
		case "ftag":
		case "lts":
		case "koth":
		case "bel":
		case "hns":
			level.itemList[0] = createSpawnAssets( "tdm_spawn_allies_start", "allies", "allies_start_spawns", &"OW_MOVER_CAT_ALLIES_START" );
			level.itemList[1] = createSpawnAssets( "tdm_spawn_axis_start", "axis", "axis_start_spawns", &"OW_MOVER_CAT_AXIS_START" );
			level.itemList[2] = createSpawnAssets( "tdm_spawn", undefined, "spawns", &"OW_MOVER_CAT_NEUTRAL" );
			if ( level.vg_gametype == "koth" )
				level.itemList[3] = createRadioAssets( "radios", &"OW_MOVER_CAT_RADIO" );
		break;
		
		case "sab":
		case "ass":
		case "ch":
		case "ctf":
			level.itemList[0] = createSpawnAssets( "sab_spawn_allies_start", "allies", "allies_start_spawns", &"OW_MOVER_CAT_ALLIES_START" );
			level.itemList[1] = createSpawnAssets( "sab_spawn_axis_start", "axis", "axis_start_spawns", &"OW_MOVER_CAT_AXIS_START" );
			level.itemList[2] = createSpawnAssets( "sab_spawn_allies", "allies", "allies_spawns", &"OW_MOVER_CAT_ALLIES" );
			level.itemList[3] = createSpawnAssets( "sab_spawn_axis", "axis", "axis_spawns", &"OW_MOVER_CAT_AXIS" );
			if ( level.vg_gametype == "sab" )
			{
				level.itemList[4] = createObjectiveAssets( "objectives", "OW_MOVER_CAT_OBJECTIVE" );
				level.itemList[5] = createExplosiveAssets( "explosive", &"OW_MOVER_CAT_EXPLOSIVE" );
			}
			else if ( level.vg_gametype == "ass" )
				level.itemList[4] = createExtractZoneAssets( "extract_zone", &"OW_MOVER_CAT_EXTRACT" );
			else
				level.itemList[4] = createFlagAssets( "flags", &"OW_MOVER_CAT_FLAG" );
		break;
		
		case "sd":
		case "re":
			level.itemList[0] = createSpawnAssets( "sd_spawn_attacker", level.vg_attackers, "attacker_spawns", &"OW_MOVER_CAT_ATTACKER" );
			level.itemList[1] = createSpawnAssets( "sd_spawn_defender", level.vg_defenders, "defender_spawns", &"OW_MOVER_CAT_DEFENDER" );
			if ( level.vg_gametype == "sd" )
			{
				level.itemList[2] = createObjectiveAssets( "objectives", &"OW_MOVER_CAT_OBJECTIVE" );
				level.itemList[3] = createExplosiveAssets( "explosive", &"OW_MOVER_CAT_EXPLOSIVE" );
			}
			else
			{
				level.itemList[2] = createObjectiveAssets( "objectives", &"OW_MOVER_CAT_OBJECTIVE" );
				level.itemList[3] = createExtractZoneAssets( "extract_zone", &"OW_MOVER_CAT_EXTRACT" );
			}
		break;
		
		case "dom":
			level.itemList[0] = createSpawnAssets( "dom_spawn_allies_start", "allies", "allies_start_spawns", &"OW_MOVER_CAT_ALLIES_START" );
			level.itemList[1] = createSpawnAssets( "dom_spawn_axis_start", "axis", "axis_start_spawns", &"OW_MOVER_CAT_AXIS_START" );
			level.itemList[2] = createSpawnAssets( "dom_spawn", undefined, "spawns", &"OW_MOVER_CAT_NEUTRAL" );
			level.itemList[3] = createFlagAssets( "flags", &"OW_MOVER_CAT_FLAG" );
		break;
		
		case "twar":
			level.itemList[0] = createSpawnAssets( "twar_spawn_allies_start", "allies", "allies_start_spawns", &"OW_MOVER_CAT_ALLIES_START" );
			level.itemList[1] = createSpawnAssets( "twar_spawn_axis_start", "axis", "axis_start_spawns", &"OW_MOVER_CAT_AXIS_START" );
			level.itemList[2] = createSpawnAssets( "twar_spawn", undefined, "spawns", &"OW_MOVER_CAT_NEUTRAL" );
			level.itemList[3] = createFlagAssets( "flags", &"OW_MOVER_CAT_FLAG" );
		break;
		
		default: assertMsg( "Gametype is not supported." ); logPrint( "Visual Guide Error: Gametype Not Supported" ); break;
	}
}

/*
*	Function:		createSpawnAssets( <param1>, <param2>, <param3>, <param4> )
*	Purpose:		Sets up spawn markers for every spawn with the given spawnType.
*	Pre-Condition:	spawnType: Type of spawn to look for; team: allies or axis; label: label for spawn group; catString: The category local string
*	Post-Condition: Returns an array of the spawns.
*/
createSpawnAssets( spawnType, team, label, catString )
{
	spawns = getEntArray( "mp_" + spawnType, "classname" );
	
	if ( spawns.size == 0 ) return;
	
	itemArray = [];
	
	for ( idx = 0; idx < spawns.size; idx++ )
	{
		//Flags don't stick into the ground like they should so we need to find the ground for them.
		trace = bullettrace( spawns[idx].origin + ( 0, 0, 32 ), spawns[idx].origin - ( 0, 0, 100 ), 0, undefined );
		//spawns[idx].origin = trace["position"];
		
		visual = spawn( "script_model", trace["position"] );
		
		if ( isDefined( team ) )
			visual setModel( game["team_flag"][game[team]] );
		else	
			visual setModel( game["team_flag"]["neutral"] );
		
		visual.sOrigin = trace["position"];
		visual.sAngles = spawns[idx].angles;
		visual.origin = trace["position"]; 
		visual.angles = spawns[idx].angles; 
		visual.index = idx;
		
		if ( isDefined( team ) )
			visual.vg_model = game["team_flag"][game[team]];
		else	
			visual.vg_model = game["team_flag"]["neutral"];
		
		itemArray[itemArray.size] = visual;
		spawns[idx] delete();
		wait .01;
	}
	addCat( label, catString, &"OW_MOVER_ITEM_SPAWN" );
	return itemArray;
}

/*
*	Function:		createFlagAssets( <param1>, <param2> )
*	Purpose:		Sets up flag markers for every flag objective for the specified gametype
*	Pre-Condition:	label: label for flag group; catString: The category local string
*	Post-Condition: Returns an array of the flag objectives.
*/
createFlagAssets( label, catString )
{
	trig = [];
	flags = [];
	
	if ( level.vg_gametype == "twar" )
	{
		flags = getEntArray( "flag_primary_linked", "targetname" );
		for ( idx = 0; idx < flags.size; idx++ )
		{
			if ( isDefined( flags[idx].target ) )
				trig[idx] = getEnt( flags[idx].target, "targetname" );
			else
				trig[idx] = flags[idx];
		}
	}
	else if ( level.vg_gametype == "ctf" )
	{
		if ( isDefined( getEnt( "ctf_trig_allies", "targetname" ) ) )
		{
			flags[0] = getEnt( "ctf_flag_allies", "targetname" );
			flags[1] = getEnt( "ctf_flag_axis", "targetname" );
			trig[0] = getEnt( "ctf_trig_allies", "targetname" );
			trig[1] = getEnt( "ctf_trig_axis", "targetname" );
		}
		else
		{
			trig[0] = getEnt( "sab_bomb_allies", "targetname" );
			trig[1] = getEnt( "sab_bomb_axis", "targetname" );
			flags[0] = getEnt( trig[0].target, "targetname" );
			flags[1] = getEnt( trig[1].target, "targetname" );
		}
		
	}
	else if ( level.vg_gametype == "ch" )
		trig[0] = getEnt( "sab_bomb_pickup_trig", "targetname" );
	else if ( level.vg_gametype == "dom" )
	{
		flags =  getEntArray( "flag_primary", "targetname" );
		for ( idx = 0; idx < flags.size; idx++ )
		{
			if ( isDefined( flags[idx].target ) )
				trig[idx] = getEnt( flags[idx].target, "targetname" );
			else
				trig[idx] = flags[idx];
		}
	}
	
	if ( !isDefined( trig ) )
		return;
		
	itemArray = [];
	
	for ( idx = 0; idx < trig.size; idx++ )
	{
		visual = spawn( "script_model", trig[idx].origin );
		visual.sOrigin = trig[idx].origin;
		visual.sAngles = trig[idx].angles;
		visual.origin = trig[idx].origin;
		visual.angles = trig[idx].angles;
		visual.index = idx;
		if ( level.vg_gametype == "ctf" )
		{
			if ( idx == 0 )
			{
				visual setModel( game["team_flag"][game["allies"]] );
				visual.vg_model = game["team_flag"][game["allies"]];
			}
			else
			{
				visual setModel( game["team_flag"][game["axis"]] );
				visual.vg_model = game["team_flag"][game["axis"]];
			}
		}
		else
		{
			visual setModel( game["team_flag"]["neutral"] );
			visual.vg_model = game["team_flag"]["neutral"];
		}	
		effect = game["circle_effect"]["silver"];
		trace = bullettrace( visual.origin + ( 0, 0, 32 ), visual.origin - (0,0,100), 0, undefined );
		origin = trace["position"];
		
		visual.effect = spawnFx( effect, origin );
		triggerFx( visual.effect );
		
		itemArray[itemArray.size] = visual;
		
		if ( level.vg_gametype == "dom" && !isDefined( flags[idx].target ) )	
			trig[idx] delete();
		else if ( level.vg_gametype == "dom" )
		{
			trig[idx] delete();
			flags[idx] delete();
		}
		
		if ( level.vg_gametype == "ctf" )
		{
			trig[idx] delete();
			flags[idx] delete();
		}	
		
		wait .01;
	}

	addCat( label, catString, &"OW_MOVER_ITEM_FLAG" );
	return itemArray;
}

/*
*	Function:		createExtractZoneAssets( <param1>, <param2> )
*	Purpose:		Sets up extraction zone markers for every extraction zone for the specified gametype
*	Pre-Condition:	label: label for extract_zone group; catString: The category local string
*	Post-Condition: Returns an array of extraction zones.
*/
createExtractZoneAssets( label, catString )
{
	if ( level.vg_gametype == "re" )
		zone = getEnt( "sd_bomb_pickup_trig", "targetname" );
	else
		zone = getEnt( "sab_bomb_axis", "targetname" );
		
	if ( !isDefined( zone ) )
		return;
		
	itemArray = [];
	
	
	visual = spawnStruct();
	visual.sOrigin = zone.origin;
	visual.sAngles = ( 0, 0, 0 );
	visual.origin = zone.origin;
	visual.angles = ( 0, 0, 0 );
	visual.index = 0;
	effect = game["circle_effect"]["black"];
	visual.vg_model = effect;
	visual.effect = spawnFX( effect, zone.origin );
	triggerFx( visual.effect );
	
	itemArray[itemArray.size] = visual;
	
	addCat( label, catString, &"OW_MOVER_ITEM_EXTRACT" );
	
	//Now we need to remove the gametype its modeled after.
	allowed[0] = level.vg_gametype; 
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	return itemArray;
}

/*
*	Function:		createObjectiveAssets( <param1>, <param2> )
*	Purpose:		Sets up objective markers for every objective for the specified gametype
*	Pre-Condition:	label: label for objective group; catString: The category local string
*	Post-Condition: Returns an array of objectives.
*/
createObjectiveAssets( label, catString )
{
	if ( level.vg_gametype == "sd" || level.vg_gametype == "re" )
	{
		bombzones = getEntArray( "bombzone", "targetname" );
	}
	else
	{
		bombzones[0] = getEnt( "sab_bomb_allies", "targetname" );
		bombzones[1] = getEnt( "sab_bomb_axis", "targetname" );
	}
	
	if ( !isDefined( bombzones ) )
		return;
		
	//Sorts objectives so objective A is always first
	if ( level.vg_gametype == "sd" || level.vg_gametype == "re" )
		bombzones = sortObjectives( "sd", bombzones );	
			
	itemArray = [];

	for ( idx = 0; idx < bombzones.size; idx++ )
	{
		visual = spawn( "script_model", bombzones[idx].origin );
		visual.sOrigin = bombzones[idx].origin;
		visual.sAngles = bombzones[idx].angles;
		visual.origin = bombzones[idx].origin;
		visual.angles = bombzones[idx].angles;
		visual.index = idx;
		if ( level.vg_gametype == "sd" || level.vg_gametype == "sab" )
			visual.vg_model = "com_bomb_objective";
		else
			visual.vg_model = "com_office_book_red_flat";
		visual setModel( visual.vg_model );
			
		itemArray[itemArray.size] = visual;
			
		//Delete original bomb model - We don't really care about the hidden entities
		origVisual = getEnt( bombzones[idx].target, "targetname" );
		origVisual delete();
			
		wait .01;
	}
	addCat( label, catString, &"OW_MOVER_ITEM_OBJECTIVE" );
	return itemArray;
}

/*
*	Function:		createExplosiveAssets( <param1>, <param2> )
*	Purpose:		Sets up explosive markers for every explosive for the specified gametype
*	Pre-Condition:	label: label for explosive group; catString: The category local string
*	Post-Condition: Returns an array of the explosives.
*/
createExplosiveAssets( label, catString )
{
	if ( level.vg_gametype == "sd" )
		bomb = getEnt( "sd_bomb", "targetname" );
	else
		bomb = getEnt( "sab_bomb", "targetname" );
	
	if ( !isDefined( bomb ) )
		return;
	
	itemArray = [];
		
	visual = spawn( "script_model", bomb.origin );
	visual.sOrigin = bomb.origin;
	visual.sAngles = bomb.angles;
	visual.origin = bomb.origin;
	visual.angles = bomb.angles;
	visual.index = 0;
	visual.vg_model = "prop_suitcase_bomb";
	visual setModel( visual.vg_model );
	
	itemArray[itemArray.size] = visual;
	
	bomb delete();
	
	addCat( label, catString, &"OW_MOVER_ITEM_EXPLOSIVE" );
	return itemArray;
}

/*
*	Function:		createRadioAssets( <param1>, <param2> )
*	Purpose:		Sets up radio markers for every radio objective for koth
*	Pre-Condition:	label: label for radio group; catString: The category local string
*	Post-Condition: Returns an array of the radio objectives.
*/
createRadioAssets( label, catString )
{
	hardpoint = getEntArray( "hq_hardpoint", "targetname" );
	
	if ( hardpoint.size == 0 )
		return;
		
	itemArray = [];

	for ( idx = 0; idx < hardpoint.size; idx++ )
	{
		hardpoint_visuals = getEntArray( hardpoint[idx].target, "targetname" );
		
		radio = spawn( "script_model", hardpoint[idx].origin );
		radio setModel( "com_laptop_2_open" );
		radio.origin = hardpoint[idx].origin;
		radio.angles = hardpoint[idx].angles;
		
		origin = hardpoint_visuals[0].origin;
		angles = hardpoint_visuals[0].angles;
		visual = spawn( "script_model", origin );
		visual.sOrigin = origin;
		visual.sAngles = angles;
		visual.origin = origin;
		visual.angles = angles;
		visual.index = idx;
		visual.vg_model = "com_plasticcase_beige_big";
		visual setModel( "com_plasticcase_beige_big" );
		
		radio linkTo( visual );
		
		itemArray[itemArray.size] = visual;
		
		hardpoint_visuals[0] delete();
		hardpoint[idx] delete();
		
		wait .01;
	} 
	addCat( label, catString, "OW_MOVER_ITEM_RADIO" );
	return itemArray;
}

/*
*	Function:		setupCommands()
*	Purpose:		Sets up the commands for the visual guide
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
setupCommands()
{
	addCmd( &"OW_MOVER_CMD_CAT_NEXT", "next_category", ::nextCat );
	addCmd( &"OW_MOVER_CMD_CAT_PREV", "prev_category", ::prevCat );
	addCmd( &"OW_MOVER_CMD_ITEM_NEXT", "next_item", ::nextItem );
	addCmd( &"OW_MOVER_CMD_ITEM_PREV", "prev_item", ::prevItem );
	addCmd( &"OW_MOVER_CMD_SHOW", "location", ::showItem );
	addCmd( &"OW_MOVER_CMD_RESET_ITEM", "reset_item_loc", ::resetItem );
	addCmd( &"OW_MOVER_CMD_RESET_ALL", "reset_all_loc", ::resetAll );
	addCmd( &"OW_MOVER_CMD_WRITE_ITEM", "write_item_log", ::writeItemLog );
	addCmd( &"OW_MOVER_CMD_WRITE_ALL", "write_all_log", ::writeAllLog );
}

/*
*	Function:		addCmd( <param1>, <param2>, <param3> )
*	Purpose:		Creates a command struct with fields and adds it to the command list
*	Pre-Condition:	string: Local String for command; label: label given for command; function: the function to call when the command is selected
*	Post-Condition: None.
*/
addCmd( string, label, function )
{
	cmd = spawnStruct();
	cmd.string = string;
	cmd.label = label;
	cmd.function = function;
	
	level.cmdList[level.cmdList.size] = cmd;
}

/*
*	Function:		addCat( <param1>, <param2>, <param3> )
*	Purpose:		Creates a category struct with fields and adds it to the category list
*	Pre-Condition:	label: Label given for the category; catString: Local String for category; itemString: Local String for item
*	Post-Condition: None.
*/
addCat( label, catString, itemString )
{
	cat = spawnStruct();
	cat.label = label;
	cat.catString = catString;
	cat.itemString = itemString;
	cat.dvar = level.script + "_move_" + level.vg_gametype + "_" + cat.label;
	
	level.catList[level.catList.size] = cat;
}

/*
*	Function:		placeItem()
*	Purpose:		Places the item at the specified origin from the reticle used by the player.
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
placeItem()
{
	cat = level.catList[level.catIndex].label;
	item = level.itemList[level.catIndex][level.itemIndex];
	
	//Set new position
	if ( cat != "extract_zone" )
	{
		item.origin = self.reticlePos;
		item.angles = ( 0, self.lookDirection, 0 );
		
		if ( cat == "flags" )
		{
			item.effect delete();
			item.effect = spawnFx( game["circle_effect"]["silver"], self.reticlePos );
			triggerFx( item.effect );
		}
	}
	//else if ( cat != "extract_zone" )
	//{
	//	item.origin = self.reticlePos + ( 0, 0, 36 );
	//	item.angles = ( 0, ( self.lookDirection - 90 ), 15 );
	//}
	else //Extract zone
	{
		if ( isDefined( item.effect ) )
			item.effect delete();
		
		item.effect = spawnFx( game["circle_effect"]["black"], self.reticlePos );
		item.origin = self.reticlePos;
		item.angles = ( 0, 0, 0 );
		
		triggerFx( item.effect );
	}
}

/*
*	Function:		nextCat()
*	Purpose:		Increments to the next category in the list
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
nextCat()
{
	level.catIndex++;
	level.catIndex %= level.catList.size;
	level.itemIndex = 0;
	
	updateInfo();
}

/*
*	Function:		prevCat()
*	Purpose:		Decrements to the previous category in the list
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
prevCat()
{
	level.catIndex--;
	
	if ( level.catIndex < 0 )
		level.catIndex = level.catList.size - 1;
	level.itemIndex = 0;

	updateInfo();
}

/*
*	Function:		nextItem()
*	Purpose:		Increments to the next item in the list
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
nextItem()
{
	level.itemIndex++;
	level.itemIndex %= level.itemList[level.catIndex].size;
	
	self setClientDvar( "item_index", level.itemIndex );
}

/*
*	Function:		prevItem()
*	Purpose:		Decrements to the previous item in the list
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
prevItem()
{
	level.itemIndex--;
	
	if ( level.itemIndex < 0 )
		level.itemIndex = level.itemList[level.catIndex].size - 1;
		
	self setClientDvar( "item_index", level.itemIndex );
}

/*
*	Function:		showItem()
*	Purpose:		Takes the player to the location of the selected item.
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
showItem()
{
	item = level.itemList[level.catIndex][level.itemIndex];
	
	self setOrigin( item.origin + ( 0, 0, 96 ) );
	self setPlayerAngles( item.angles + ( 90, 0, 0 ) );
}

/*
*	Function:		resetItem()
*	Purpose:		Resets the current items origin and angles to its starting origin and angles.
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
resetItem()
{
	cat = level.catList[level.catIndex].label;
	item = level.itemList[level.catIndex][level.itemIndex];
	
	item.origin = item.sOrigin;
	item.angles = item.sAngles;
	
	if ( ( cat == "flags" || cat == "extract_zone" ) && isDefined( item.effect ) )
	{
		if ( isDefined( item.effect ) )
			item.effect delete();
		if ( cat == "flags" )
			item.effect = spawnFx( game["circle_effect"]["silver"], item.sOrigin );
		else
			item.effect = spawnFx( game["circle_effect"]["black"], item.sOrigin );
		triggerFx( item.effect );
	}
}

/*
*	Function:		resetAll()
*	Purpose:		Resets all items regardless of which item is selected to itsstarting origin and angles
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
resetAll()
{
	for ( idx = 0; idx < level.catList.size; idx++ )
	{
		cat = level.catList[idx].label;
		for ( idx2 = 0; idx2 < level.itemList[idx].size; idx2++ )
		{
			item = level.itemList[idx][idx2];
			item.origin = item.sOrigin;
			item.angles = item.sAngles;
			
			if ( cat == "flags" || cat == "extract_zone" )
			{
				if ( isDefined( item.effect ) )
					item.effect delete();
				if ( cat == "flags" )
					item.effect = spawnFx( game["circle_effect"]["silver"], item.sOrigin );
				else
					item.effect = spawnFx( game["circle_effect"]["black"], item.sOrigin );
				triggerFx( item.effect );
			}
		}
	}
}

/*
*	Function:		writeItemLog()
*	Purpose:		Writes the current items origin and angles in the form of a dvar into the games_mp.log for use with the visual mover.
*					Doesn't write the item if it is in the same origin and angles as its starting origin and angles.
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
writeItemLog()
{
	item = level.itemList[level.catIndex][level.itemIndex];
	dvar = level.catList[level.catIndex].dvar;
	
	if ( ( item.origin == item.sOrigin ) && ( item.angles == item.sAngles ) )
	{
		//Pel Change to menu response
		//self iprintln( "Write Aborted: Item is in stock location." );
		return;
	}
	
	itemLine = "\"";
	itemLine += createDvarInfo( item, level.itemIndex );
	itemLine += "\"";
	
	logPrint( "=====OPENWARFARE VISUAL GUIDE (Write Item)=====\n" );
	logPrint( "set " + dvar + " " + itemLine + "\n" );
	logPrint( "=====END OPENWARFARE VISUAL GUIDE (Write Item)=====\n\n" );
}

/*
*	Function:		writeAllLog()
*	Purpose:		Writes all moved items into dvar format for use with the visual mover. Does not write items that
*					are at their starting origin and angles.
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
writeAllLog()
{
	logPrint( "=====OPENWARFARE VISUAL GUIDE (Write All)=====\n" );
	for ( idx = 0; idx < level.catList.size; idx++ )
	{
		itemLine = "\"";
		dvar = level.catList[idx].dvar;
		for ( idx2 = 0; idx2 < level.itemList[idx].size; idx2++ )
		{
			item = level.itemList[idx][idx2];
			if ( ( item.origin == item.sOrigin ) && ( item.angles == item.sAngles ) )
				continue;
			
			if ( itemLine != "\"" )
				itemLine += "/";	
			itemLine += createDvarInfo( item, idx2 );
		}
		
		itemLine += "\"";
		if ( itemLine != "" )
			logPrint( "set " + dvar + " " + itemLine + "\n" );
	}
	logPrint( "=====END OPENWARFARE VISUAL GUIDE (Write All)=====\n\n" );
}

/*
*	Function:		createDvarInfo( <param1>, <param2> )
*	Purpose:		Creates the dvar information for writing to the output log.
*	Pre-Condition:	item: current selected item; index: the number of the item in the array
*	Post-Condition: Returns a string with the created dvar information
*/
createDvarInfo( item, index )
{
	origin = item.origin;
	angle = item.angles[1];
	string = index + "," + int( origin[0] ) + "," + int( origin[1] ) + "," + int( origin[2] ) + "," + int( angle );
	
	return string;
}

/*
*	Function:		monitorCmds()
*	Purpose:		Monitors for commands inputed by the player.
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
monitorCmds()
{
	self endon( "disconnect" );
	
	while ( 1 )
	{
		if ( self useButtonPressed() ) //Command Forward
		{ 
			level.cmdIndex++;
			level.cmdIndex %= level.cmdList.size;
			
			self setClientDvar( "cmd_info", level.cmdList[level.cmdIndex].label );
			wait .5;
		}
		else if ( self fragButtonPressed() ) //Command Backward
		{
			if ( level.cmdIndex == 0 )
				level.cmdIndex = level.cmdList.size - 1;
			else
				level.cmdIndex--;
				
			self setClientDvar( "cmd_info", level.cmdList[level.cmdIndex].label );	
			wait .5;
		}
		else if ( self attackButtonPressed() ) //Place Item
		{
			self placeItem();
			wait .5;
		}
		else if ( self meleeButtonPressed() ) //Execute Command
		{ 
			self [[level.cmdList[level.cmdIndex].function]]();
			wait .5;
		}
		else
		{
			wait .1;
		}
	}
}

/*
*	Function:		sortObjectives( <param1>, <param2> )
*	Purpose:		Sorts the objectives of the specified gametype to be in alphabetical order.
*	Pre-Condition:	gametype: specified gametype; type: the unsorted entity array
*	Post-Condition: Returns the sorted entity array
*/
sortObjectives( gametype, type )
{
	if ( gametype == "sd" )
	{
		temp = undefined;
		if ( type[0].script_label != "_a" )
		{
			temp = type[0];
			type[0] = type[1];
			type[1] = temp;
			
			return type;
		}
	}
	return type;
}

/*
*	Function:		removeAllBrushModels()
*	Purpose:		Removes any entities from the map that have the classname "script_brushmodel".
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
removeAllBrushModels()
{
	brushmodels = getentarray( "script_brushmodel", "classname" );
	for ( idx = 0; idx < brushmodels.size; idx++ )
	{
		brushmodels[idx] delete();
	}
}

/*
*	Function:		waitWhileSame( <param1>, <param2> )
*	Purpose:		Delays the reticle from being deleted and recreated until the player is at a different origin 
*					or looking at a different angle.
*	Pre-Condition:	sOrigin: Current Origin; sAngles: Current Angles
*	Post-Condition: Returns 0 when the origin and angles change from the current ones (dummy number).
*/
waitWhileSame( sOrigin, sAngles )
{
	sameOrigin = true;
	sameAngles = true; 
	
	while ( sameOrigin && sameAngles )
	{
		fOrigin = self getOrigin();
		fAngles = self getPlayerAngles();
				
		sameOrigin = isSame( sOrigin, fOrigin );
		if ( sameOrigin ) //Only check angles if origin is same
		{
			sameAngles = isSame( sAngles, fAngles );
		}
		
		wait .01;	
	}
	return 0;
}

/*
*	Function:		updateInfo()
*	Purpose:		Updates some info being displayed in the Visual Guide menu.
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
updateInfo()
{
	cat = level.catList[level.catIndex].label;
	itemIndex = level.itemIndex;
	
	self setClientDvars( "cat_info", cat, "item_info", cat, "item_index", itemIndex );
}