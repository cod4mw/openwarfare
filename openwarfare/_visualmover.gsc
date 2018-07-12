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

#include openwarfare\_eventmanager;
#include openwarfare\_utils;
#include maps\mp\_utility;

init()
{
	level.mover = getdvarx( "scr_visualmover", "int", 0, 0, 1 );
	
	//Check if we need to continue
	if ( !level.mover )
		return;
		
	level.mover_done = false;	
		
	level.mover_randomize = getdvarx( "scr_visualmover_randomize", "int", 0, 0, 1 ); // 0 = Cycle Incrementally, 1 = Random Cycle
	level.mover_singleConfig = getdvarx( "scr_visualmover_singleconfig", "int", 0, 0, 999 );
	level.mapname = getDvar( "mapname" );
	
	level.vm_gametype = getDvar( "g_gametype" );
		
	level.mover_done = false;	
	//If visual guide is gametype then we need the fake gametype
	if ( level.vm_gametype == "vg" )
		level.vm_gametype = level.vg_gametype;	
		
	initMover();
}


/*
*	Function:		initMover()
*	Purpose:		To move the maps critical gametype pieces based on the coordinates provided by the player.
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
initMover()
{
	//Check if we need to get the config count
	if ( !isDefined( game["mover_config_count"] ) || ( isDefined( game["mover_config_count"] ) && isDefined( game["mapname"] ) && ( game["mapname"] == level.mapname ) ) )
	{
		game["mapname"] = level.mapname;
		game["mover_config_count"] = 0;
		game["mover_config_count"] = getConfigurationCount();
	}	
	
	// If no config then stock is the only option
	if ( game["mover_config_count"] == 0 )
	{
		level.mover_done = true;
		return;
	}	
	
	if ( !isDefined( game["mover_config_current"] ) )
		game["mover_config_current"] = 0;

	//Check if we choose at random, cycle incrementally, or use a single config
	if ( ( level.mover_singleConfig <= game["mover_config_count"] ) && ( level.mover_singleConfig > 0 ) )
		game["mover_config_current"] = level.mover_singleConfig;
	else if ( level.mover_randomize )
		game["mover_config_current"] = randomIntRange( 1, game["mover_config_count"] + 1 );
	else
	{
		game["mover_config_current"]++;
		game["mover_config_current"] %= ( game["mover_config_count"] + 1 );
		
		if ( game["mover_config_current"] == 0 )
			game["mover_config_current"] = 1;
	}
	
	// We have the configuration number we will use for this round or map
	// Now, let's begin the moving process.
	moveThePieces();
}

/*
*	Function: 		getConfigurationCount()
*	Purpose: 		To retrieve the number of configurations for the current map and gametype.
*	Pre-Condition: 	None.
* 	Post-Condition: Returns the number of configurations.
*/
getConfigurationCount()
{
	dvarList = [];
	configCount = 0;
	tempCount = 0;
	
	switch( level.vm_gametype )
	{
		case "dm":
		case "gg":
		case "lms":
		case "ss":
		case "oitc":
					dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_spawns";
			break;
		case "dom":
		case "ftag":
		case "koth":
		case "lts":
		case "war":
		case "bel":
		case "hns":
					dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_spawns";
					dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_allies_start_spawns";
					dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_axis_start_spawns";
					
					if ( level.vm_gametype == "koth" )
						dvarList[dvarList.size] = level.mapname + "_move_koth_radios";
					else if ( level.vm_gametype == "twar" || level.vm_gametype == "dom" )
						dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_flags";
			break;
		case "ass":
		case "ch":
		case "ctf":
		case "sab":
					dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_allies_spawns";
					dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_axis_spawns";
					dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_allies_start_spawns";
					dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_axis_start_spawns";
					
					if ( level.vm_gametype == "ass" )
						dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_extract_zone";
					else if ( level.vm_gametype == "ch" || level.vm_gametype == "ctf" )
						dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_flags";
					else if ( level.vm_gametype == "sab" )
					{
						dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_objectives";
						dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_explosive";
					}
			break;
		case "sd":
		case "re":
					dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_attacker_spawns";
					dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_defender_spawns";
					dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_objectives";
					
					if ( level.vm_gametype == "sd" )
						dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_explosive";
					else
						dvarList[dvarList.size] = level.mapname + "_move_" + level.vm_gametype + "_extract_zone";
			break;
	}
	
	// Check each dvar from above to see how many iterations of each exist.
	// If the count on a specific dvar > the current config count then 
	// we have a new config count. 
	for ( idx = 0; idx < dvarList.size; idx++ )
	{
		for ( idx2 = configCount + 1; idx2 < 999; idx2++ )
		{
			if ( getDvar( dvarList[idx] + "_" + idx2 ) != "" )
				tempCount = idx2;
			else	
				break;
		}
		if ( tempCount > configCount )
		{
			configCount = tempCount;
			idx = -1; //Reset for loop to check all dvars for tempCount > configCount
		}
		tempCount = 0;	
	}
	
	return configCount;
}

/*
*	Function:		moveThePieces()
*	Purpose:		To move the gametype specific pieces to the new locations specified by the dvar coordinates provided by the player.
*	Pre-Condition:	None.
*	Post-Condition: None.
*/
moveThePieces()
{
	switch( level.vm_gametype )
	{
		case "dm":
		case "gg":
		case "lms":
		case "ss":
		case "oitc":
					moveSpawns( "mp_dm_spawn", level.mapname + "_move_" + level.vm_gametype + "_spawns_" + game["mover_config_current"] );
			break;
		case "ftag":
		case "koth":
		case "lts":
		case "war":
		case "bel":
		case "hns":
					if ( level.vm_gametype == "koth" )
						thread moveRadios( level.mapname + "_move_koth_radios_" + game["mover_config_current"] );
						
					moveSpawns( "mp_tdm_spawn", level.mapname + "_move_" + level.vm_gametype + "_spawns_" + game["mover_config_current"] );
					moveSpawns( "mp_tdm_spawn_allies_start", level.mapname + "_move_" + level.vm_gametype + "_allies_start_spawns_" + game["mover_config_current"] );
					moveSpawns( "mp_tdm_spawn_axis_start", level.mapname + "_move_" + level.vm_gametype + "_axis_start_spawns_" + game["mover_config_current"] );
			break;
		case "ass":
		case "ch":
		case "sab":
		case "ctf":
					if ( level.vm_gametype == "sab" )
					{
						thread moveExplosive( level.mapname + "_move_sab_explosive_" + game["mover_config_current"] );
						thread moveObjectives( level.mapname + "_move_sab_objectives_" + game["mover_config_current"] );
					}
					else if ( level.vm_gametype == "ass" )
						thread moveExtractZone( level.mapname + "_move_ass_extract_zone_" + game["mover_config_current"] );
					else
						thread moveFlags( level.mapname + "_move_" + level.vm_gametype + "_flags_" + game["mover_config_current"] );
						
					if ( level.vm_gametype == "ctf" && isDefined( getEnt( "ctf_trig_allies", "targetname" ) ) )
						spawnType = "ctf";
					else
						spawnType = "sab";
					
					moveSpawns( "mp_" + spawnType + "_spawn_allies", level.mapname + "_move_" + level.vm_gametype + "_allies_spawns_" + game["mover_config_current"] );
					moveSpawns( "mp_" + spawnType + "_spawn_axis", level.mapname + "_move_" + level.vm_gametype + "_axis_spawns_" + game["mover_config_current"] );
					moveSpawns( "mp_" + spawnType + "_spawn_allies_start", level.mapname + "_move_" + level.vm_gametype + "_allies_start_spawns_" + game["mover_config_current"] );
					moveSpawns( "mp_" + spawnType + "_spawn_axis_start", level.mapname + "_move_" + level.vm_gametype + "_axis_start_spawns_" + game["mover_config_current"] );
			break;
		case "sd":
		case "re":
					if ( level.vm_gametype == "sd" )
						thread moveExplosive( level.mapname + "_move_sd_explosive_" + game["mover_config_current"] );
					else
						thread moveExtractZone( level.mapname + "_move_re_extract_zone_" + game["mover_config_current"] );
					thread moveObjectives( level.mapname + "_move_" + level.vm_gametype + "_objectives_" + game["mover_config_current"] );
						
					moveSpawns( "mp_sd_spawn_attacker", level.mapname + "_move_sd_attacker_spawns_" + game["mover_config_current"] );
					moveSpawns( "mp_sd_spawn_defender", level.mapname + "_move_sd_defender_spawns_" + game["mover_config_current"] );
			break;	
		case "dom":
					thread moveFlags( level.mapname + "_move_" + level.vm_gametype + "_flags_" + game["mover_config_current"] );
					moveSpawns( "mp_" + level.vm_gametype + "_spawn", level.mapname + "_move_" + level.vm_gametype + "_spawns_" + game["mover_config_current"] );
					moveSpawns( "mp_" + level.vm_gametype + "_spawn_allies_start", level.mapname + "_move_" + level.vm_gametype + "_allies_start_spawns_" + game["mover_config_current"] );
					moveSpawns( "mp_" + level.vm_gametype + "_spawn_axis_start", level.mapname + "_move_" + level.vm_gametype + "_axis_start_spawns_" + game["mover_config_current"] );
			break;
		default: logPrint( "Gametype Not Supported by Visual Mover" ); return;	
	}
	level.mover_done = true;
}

/*
*	Function:		moveSpawns( <classname>, <dvar> )
*	Purpose:		Move spawn points of type <classname> to new locations found in <dvar>.
*	Pre-Condition:	The classname of the spawn point and the dvar containing the new coordinates.
*	Post-Condition:	None.
*/
moveSpawns( classname, dvar )
{
	dvar = getDvar( dvar );
	if ( dvar == "" )
		return;
		
	spawnPoints = getEntArray( classname, "classname" );
	
	if ( spawnPoints.size == 0 )
		return;	
	
	coords = getParsedCoords( dvar );
		
	for ( idx = 0; idx < coords.size; idx++ )
	{
		curSpawn = coords[idx][0];
		
		if ( curSpawn >= spawnPoints.size || curSpawn < 0 )
			continue;
			
		spawnPoints[curSpawn].origin = ( coords[idx][1], coords[idx][2], coords[idx][3] );
		spawnPoints[curSpawn].angles = ( 0, coords[idx][4], 0 );
	}	
}

/*
*	Function: 		moveExplosive( <dvar> )
*	Purpose:		To move the explosive or bomb in SD & SAB to its new location found in <dvar>.
*	Pre-Condition:  The dvar containing the new coordinates
*	Post-Condition:	None.
*/
moveExplosive( dvar )
{
	dvar = getDvar( dvar );
	if ( dvar == "" )
		return;
	
	parts = [];
	parts[parts.size] = getEnt( level.vm_gametype + "_bomb", "targetname" );
	parts[parts.size] = getEnt( level.vm_gametype + "_bomb_pickup_trig", "targetname" );
	
	if ( parts.size == 0 )
		return;
	
	coords = getParsedCoords( dvar );
	// Selected a random location if more than one coordinate set exists
	coord = coords[randomInt( coords.size )]; 
	
	for ( idx = 0; idx < parts.size; idx++ )
	{
		parts[idx].origin = (coord[1], coord[2], coord[3]);
		parts[idx].angles = (0, coord[4], 0);
	}
}

/*
*	Function: 		moveObjectives( <dvar> )
*	Purpose:		To move the objectives of various gametypes to new locations found in <dvar>.
*	Pre-Condition:  The dvar containing the new coordinates
*	Post-Condition:	None.
*/
moveObjectives( dvar )
{
	dvar = getDvar( dvar );
	if ( dvar == "" )
		return;

	trigger = [];
	if ( level.vm_gametype == "sd" || level.vm_gametype == "re" )
		trigger = getEntArray( "bombzone", "targetname" );
	else
	{
		trigger[trigger.size] = getEnt( "sab_bomb_allies", "targetname" );
		trigger[trigger.size] = getEnt( "sab_bomb_axis", "targetname" );
	}
	
	if ( trigger.size == 0 )
		return;
		
	clips = [];
	exploder = [];
	if ( level.vm_gametype != "re" )
	{
		clips = getEntArray( "script_brushmodel", "classname" );
		exploder = getEntArray( "exploder", "targetname" );
	}	
	coords = getParsedCoords( dvar );
	
	sCoord0 = [];
	sCoord1 = [];
	//Sort into correct array for random selection
	for ( idx = 0; idx < coords.size; idx++ )
	{
		if ( coords[idx][0] == 0 )
			sCoord0[sCoord0.size] = coords[idx];
		else if ( coords[idx][0] == 1 )
			sCoord1[sCoord1.size] = coords[idx];
	}
	//Select the random bombsites 
	coords = [];
	if ( sCoord0.size > 0 )
		coords[coords.size] = sCoord0[randomint(sCoord0.size)];
	if ( sCoord1.size > 0 )	
		coords[coords.size] = sCoord1[randomint(sCoord1.size)];
	
	for ( idx = 0; idx < coords.size; idx++ )
	{
		newOrigin = ( coords[idx][1], coords[idx][2], coords[idx][3] );
		newAngles = ( 0, coords[idx][4], 0 );
		
		curObjective = coords[idx][0];
		
		if ( curobjective >= trigger.size || curObjective < 0 )
			continue;
		curTrigger = trigger[curObjective];
		
		if ( level.vm_gametype != "re" )
		{
			visuals = getEntArray( curTrigger.target, "targetname" );
		
			//Link visuals to clips
			for ( idx2 = 0; idx2 < clips.size; idx2++ )
			{
				if ( isDefined( clips[idx2].script_gameobjectname ) && ( clips[idx2].script_gameobjectname == "bombzone" || clips[idx2].script_gameobjectname == "sab" ) && distance( clips[idx2].origin, curTrigger.origin ) < 64 )
					clips[idx2] linkTo( visuals[0] );
			}
			
			//Move Linked Items and visuals
			for ( idx2 = 0; idx2 < visuals.size; idx2++ )
			{
				if ( isDefined( exploder[idx2].script_exploder ) && exploder[idx2].script_exploder == visuals[0].script_exploder )
				{
					exploder[idx2].origin = newOrigin;
					exploder[idx2].angles = newAngles;
				}
				visuals[idx2].origin = newOrigin;
				visuals[idx2].angles = newAngles;
			}
		}
		
		//Move curTrigger for all the gametypes
		curTrigger.origin = newOrigin;
		curTrigger.angles = newAngles;
	}
}

/*
*	Function: 		moveExtractZone( <dvar> )
*	Purpose:		To move the extraction zone pieces for ass and re to new locations found in <dvar>
*	Pre-Condition:  The dvar containing the new coordinates
*	Post-Condition:	None.
*/
moveExtractZone( dvar )
{
	dvar = getDvar( dvar );
	if ( dvar == "" )
		return;
	
	if ( level.vm_gametype == "ass" )
		extract_zone = getEnt( "sab_bomb_axis", "targetname" );
	else
		extract_zone = getEnt( "sd_bomb", "targetname" );
	
	if ( !isDefined( extract_zone ) )
		return;
	
	coords = getParsedCoords( dvar );
	rCoord = coords[randomInt( coords.size )];
	
	extract_zone.origin = ( rCoord[1], rCoord[2], rCoord[3] );
}

/*
*	Function: 		moveFlags( <dvar> )
*	Purpose:		To move the flags of various gametypes to new locations found in <dvar>
*	Pre-Condition:  The dvar containing the new coordinates
*	Post-Condition:	None.
*/
moveFlags( dvar )
{
	dvar = getDvar( dvar );
	if ( dvar == "" )
		return;
		
	coords = getParsedCoords( dvar );	
	
	if ( level.vm_gametype == "ch" )
	{
		trigger = getent("sab_bomb_pickup_trig", "targetname");
		
		if ( !isDefined( trigger ) )
			return;
		
		coord = coords[randomint( coords.size )];	
		
		trigger.origin = ( coord[1], coord[2], coord[3] );
		trigger.angles = ( 0, coord[4], 0 );	
	}
	else if ( level.vm_gametype == "ctf" )
	{
		triggers = [];
		triggers[0] = getEnt( "ctf_trig_allies", "targetname" );
		
		if ( !isDefined( triggers[0] ) )
		{
			trigs = "sab";
			triggers[0] = getEnt( "sab_bomb_allies", "targetname" );
			triggers[1] = getEnt( "sab_bomb_axis", "targetname" );
		}
		else
		{
			trigs = "ctf";
			triggers[1] = getEnt( "ctf_trig_axis", "targetname" );
		}
		
		if ( triggers.size == 0 )
		{
			return;
		}
		
		sCoord0 = [];
		sCoord1 = [];
		//Sort into correct array for random selection
		for ( idx = 0; idx < coords.size; idx++ )
		{
			if ( coords[idx][0] == 0 )
				sCoord0[sCoord0.size] = coords[idx];
			else if ( coords[idx][0] == 1 )
				sCoord1[sCoord1.size] = coords[idx];
		}

		//Select the random bombsites 
		coords = [];
		if ( sCoord0.size > 0 )
			coords[coords.size] = sCoord0[randomint(sCoord0.size)];
		if ( sCoord1.size > 0 )	
			coords[coords.size] = sCoord1[randomint(sCoord1.size)];
		
		flags = [];
		zones = [];
		if ( trigs == "ctf" )
		{
			flags[0] = getEnt( "ctf_flag_allies", "targetname" );
			flags[1] = getEnt( "ctf_flag_axis", "targetname" );
			
			zones[0] =  getEnt( "ctf_zone_allies", "targetname" );
			zones[1] =  getEnt( "ctf_zone_axis", "targetname" );
		}
		
		for ( idx = 0; idx < coords.size; idx++ )
		{
			newOrigin = ( coords[idx][1], coords[idx][2], coords[idx][3] );
			newAngles = ( 0, coords[idx][4], 0 );
		
			curFlag = coords[idx][0];
			
			if ( curFlag >= triggers.size || curFlag < 0 )
				continue;
				
			triggers[curFlag].origin = newOrigin;
			triggers[curFlag].angles = newAngles;
			
			if ( trigs == "ctf" )
			{
				flags[curFlag].origin = newOrigin;
				flags[curFlag].angles = newAngles;
				zones[curFlag].origin = newOrigin;
				zones[curFlag].angles = newAngles;
			}	
		}
	}	
	else 
	{
		triggers = getEntArray( "flag_primary", "targetname" );
		
		if ( triggers.size == 0 )
			return;
			
		descriptors = getEntArray("flag_descriptor", "targetname");	
	
		sCoord0 = [];
		sCoord1 = [];
		sCoord2 = [];
		//Sort into correct array for random selection
		for ( idx = 0; idx < coords.size; idx++ )
		{
			if ( coords[idx][0] == 0 )
				sCoord0[sCoord0.size] = coords[idx];
			else if ( coords[idx][0] == 1 )
				sCoord1[sCoord1.size] = coords[idx];
			else if ( coords[idx][0] == 2 )
				sCoord2[sCoord2.size] = coords[idx];
		}
		//Select the random bombsites 
		coords = [];
		if ( sCoord0.size > 0 )
			coords[coords.size] = sCoord0[randomint(sCoord0.size)];
		if ( sCoord1.size > 0 )	
			coords[coords.size] = sCoord1[randomint(sCoord1.size)];
		if ( sCoord2.size > 0 )	
			coords[coords.size] = sCoord2[randomint(sCoord2.size)];
			
		for ( idx = 0; idx < coords.size; idx++ )
		{
			newOrigin = ( coords[idx][1], coords[idx][2], coords[idx][3] );
			newAngles = ( 0, coords[idx][4], 0 );
		
			curFlag = coords[idx][0];
		
			if ( curFlag >= triggers.size || curFlag < 0 )
				continue;
		
			triggers[curFlag].origin = newOrigin;
			triggers[curFlag].angles = newAngles;
			
			descriptors[curFlag].origin = newOrigin;
			descriptors[curFlag].angles = newAngles;
		}	
	}
}

/*
*	Function: 		moveRadios( <dvar> )
*	Purpose:		To move the radios in koth to new locations found in <dvar>
*	Pre-Condition:  The dvar containing the new coordinates
*	Post-Condition:	None.
*/
moveRadios( dvar )
{
	dvar = getDvar( dvar );
	if ( dvar == "" )
		return;
	
	triggers = getEntArray( "radiotrigger", "targetname" );
	
	if ( triggers.size == 0 )
		return;
	
	hardPoints = getEntArray( "hq_hardpoint", "targetname" );
	coords = getParsedCoords( dvar );
	
	for ( idx = 0; idx < coords.size; idx++ )
	{
		newOrigin = ( coords[idx][1], coords[idx][2], coords[idx][3] );
		newAngles = ( 0, coords[idx][4], 0 );
		
		curRadio = coords[idx][0];
		
		if ( curRadio >= triggers.size || curRadio < 0 )
			continue;
		
		visuals = getEntArray( hardPoints[curRadio].target, "targetname" );
		hardPoints[curRadio] linkTo( visuals[0] );
				
		//Link together everything for the move - makes it so much easier
		for ( idx2 = 0; idx2 < visuals.size; idx2++ )
		{
			if ( idx2 != 0 )
				visuals[idx2] linkTo( visuals[0] );
		}
				
		//Move the visuals
		for ( idx2 = 0; idx2 < visuals.size; idx2++ )
		{
			visuals[idx2].origin = newOrigin;
			visuals[idx2].angles = newAngles;
		}
				
		hardPoints[curRadio].origin = newOrigin;
		hardPoints[curRadio].angles = newAngles;
		triggers[curRadio].origin = newOrigin;
		triggers[curRadio].angles = newAngles;
	}
}

/*
*	Function: 		getParsedCoords( <dvar> )
*	Purpose:		To parse the string of coordinates into an array of coordinates.
*	Pre-Condition:  Need the dvar continaing the new coordinates.
*	Post-Condition: Returns an array of coordinates.
*/
getParsedCoords( coordString )
{
	coordSets = strTok( coordString, "/" );
	array = [];
	
	for ( idx = 0; idx < coordSets.size; idx++ )
	{
		coordParams = strTok( coordSets[idx], "," );
		coords = [];
		
		if ( coordParams.size < 5 )
			continue;
		
		coords[0] = int( coordParams[0] );
		coords[1] = int( coordParams[1] ); 
		coords[2] = int( coordParams[2] );
		coords[3] = int( coordParams[3] );
		coords[4] = int( coordParams[4] );
		
		array[array.size] = coords;
	}
	return array;
}