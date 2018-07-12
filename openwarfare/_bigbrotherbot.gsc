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

#include openwarfare\_utils;

init()
{
	// Get the main module's dvar
	level.scr_b3_poweradmin_enable = getdvarx( "scr_b3_poweradmin_enable", "int", 0, 0, 1 );

	// If the Big Brother Bot is not enabled then there's nothing to do here
	if ( level.scr_b3_poweradmin_enable == 0 )
		return;

	level thread powerAdmin();
}


findPlayerByNumber( entityNumber )
{
	foundPlayer = undefined;
	
	// Search for the player
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		
		// Check if this the player we are looking for
		if ( player getEntityNumber() == entityNumber ) {
			foundPlayer = player;
			break;
		}		
	}
	return foundPlayer;	
}


powerAdmin()
{
	level endon( "game_ended" );
	
	// Intialize the commands we support and precache some effects
	thread precacheEffects();
	initializeCommands();
		
	for (;;)
	{
		wait (0.5);
		// Check if any of the variables we support has been set
		for ( index = 0; index < level.b3Commands.size; index++ )
		{
			dVarName = level.b3Commands[index]["dvar"];
			dVarValue = getDvar( dVarName );
			// If the variable was set we'll just clean it and call the respective function
			if ( dVarValue != "" ) {
				setDvar( dVarName, "" );
				thread [[level.b3Commands[index]["function"]]]( dVarValue );				
			}
		}		
	}	
}


precacheEffects()
{
	// Precache the shellshock effects
	precacheShellShock( "frag_grenade_mp" );
	
	// Load the effects we'll be using
	level._effect["b3_explode"] = loadfx( "props/barrelexp" );
	level._effect["b3_burn"] = loadfx( "props/barrel_fire" );
}


initializeCommands()
{
	// Sets a player on fire and kills him
	addB3Command( "b3_burn", ::b3_burn );

	// Increase player's score by one and decrease player's deaths by 1
	addB3Command( "b3_compensate", ::b3_compensate );

	// Change a player's death count to "b3_death"
	addB3Command( "b3_deathcid", ::b3_deathcid );

	// End the current map gracefully
	addB3Command( "b3_endmap", ::b3_endmap );

	// Blows up a player
	addB3Command( "b3_explode", ::b3_explode );

	// Forces a player into the team "b3_forceteamname"
	addB3Command( "b3_forceteamcid", ::b3_forceteamcid );

	// Decrease a player's score by 1
	addB3Command( "b3_losepoint", ::b3_losepoint );

	// Renames a player's name to "b3_rname"
	addB3Command( "b3_rcid", ::b3_rename );

	// Display a bold message on the center of all screens
	addB3Command( "b3_saybold", ::b3_saybold );

	// Makes a scary claymore activation sound
	addB3Command( "b3_scarynade", ::b3_scarynade );
			
	// Makes a scary headshot sound
	addB3Command( "b3_scaryshot", ::b3_scaryshot );

	// Changes the a player's score to "b3_score"
	addB3Command( "b3_scorecid", ::b3_scorecid );

	// Applies a shellshock effect to a player for "b3_shocktime" seconds
	addB3Command( "b3_shock", ::b3_shock );

	// Kills the player immediately
	addB3Command( "g_killplayer", ::b3_killplayer );

	// Swith one or all players to spectator
	addB3Command( "g_switchspec", ::b3_switchspec );

	// Switch one or all players to the other team
	addB3Command( "g_switchteam", ::b3_switchteam );

	// Clean all the variables just in case
	for ( index = 0; index < level.b3Commands.size; index++ )
		setDvar( level.b3Commands[index]["dvar"], "" );

	// Initialize auxiliary variables so they can be set without using the "set" command
	setDvar( "b3_burntime", "" );
	setDvar( "b3_death", "" );
	setDvar( "b3_forceteamname", "" );
	setDvar( "b3_rname", "" );
	setDvar( "b3_score", "" );
	setDvar( "b3_shocktime", "" );
}


addB3Command( dVarName, functionCall )
{
	// Check if the array for commands is already defined
	if ( !isDefined( level.b3Commands ) )
		level.b3Commands = [];
		
	// Add new element
	newElement = level.b3Commands.size;
	level.b3Commands[ newElement ] = [];
	level.b3Commands[ newElement ]["dvar"] = dVarName;
	level.b3Commands[ newElement ]["function"] = functionCall;
}


playSoundOnEveryone( soundName )
{
	level endon( "game_ended" );
	
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		player playLocalSound( soundName );
	}	
}


b3_burn( dVarValue )
{
	level endon( "game_ended" );
	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	// Get the time or use a default one
	burnTime = getdvard( "b3_burntime", "int", 5, 1, 10 );
	
	// Search for the player
	player = findPlayerByNumber( dVarValue );
	if ( !isDefined( player ) || !isAlive( player ) )
		return;	
	
	// See which sound we'll use
	if ( !isDefined( player.myPainSound ) )
		player.myPainSound = "generic_pain_american_" + randomIntRange(1, 9);
	
	player iprintlnbold( &"OW_B3_PUNISHED" );
	
	// Shock the player
	killPlayerTime = gettime() + burnTime * 1000;
	lastSound = gettime();
	while ( isDefined( player ) && killPlayerTime > gettime() ) {
		wait (0.1);
		playfx( level._effect["b3_burn"], player.origin );
		if ( gettime() - lastSound > 1000 ) {
			lastSound = gettime();
			player playLocalSound( player.myPainSound );
		}		
	}
	
	// Kill the player
	if ( isDefined( player ) ) {
		player suicidePlayer();	
	}
}


b3_compensate( dVarValue )
{
	// Let the other modules takes care of this request
	setDvar( "b3_death", "-1" );
	setDvar( "b3_deathcid", dVarValue );
	setDvar( "b3_score", "1" );
	setDvar( "b3_scorecid", dVarValue );	
}


b3_deathcid( dVarValue )
{
	level endon( "game_ended" );
	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	// Make sure we have which value we need to apply to the player's death counter
	deathDif = getDvarInt( "b3_death" );
	if ( deathDif == 0 )
		return;
	
	// Search for the player
	player = findPlayerByNumber( dVarValue );
	if ( !isDefined( player ) )
		return;
		
	// Change the player's score
	player.deaths += deathDif;
	player.pers["deaths"] += deathDif;
	
	// Display a message to the players
	if ( deathDif > 0 ) {
		iprintln( &"OW_B3_DEATHUP", player.name, deathDif );
	} else {
		iprintln( &"OW_B3_DEATHDOWN", player.name, deathDif * -1 );
	}	
}


b3_endmap( dVarValue )
{
	// End the current map
	level.forcedEnd = true;
	thread maps\mp\gametypes\_globallogic::endGame( "tie", game["strings"]["round_draw"] );
}


b3_explode( dVarValue )
{
	level endon( "game_ended" );
	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	
	// Search for the player
	player = findPlayerByNumber( dVarValue );
	if ( !isDefined( player ) || !isAlive( player ) )
		return;	
	
	player iprintlnbold( &"OW_B3_PUNISHED" );
	
	// Shock the player
	playfx( level._effect["b3_explode"], player.origin );
	player playLocalSound( "exp_suitcase_bomb_main" );
	player suicidePlayer();	
}


b3_forceteamcid( dVarValue )
{
	level endon( "game_ended" );
	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	// Make sure we have the new team for the player and that the game is really team based
	newTeam = getDvar( "b3_forceteamname" );
	if ( !level.teamBased || newTeam == "" || ( newTeam != "allies" && newTeam != "axis" && newTeam != "spectator" ) )
		return;
			
	// Search for the player
	player = findPlayerByNumber( dVarValue );
	if ( !isDefined( player ) || player.pers["team"] == newTeam )
		return;		

	// Kill the player if it's alive
	if ( isAlive( player ) ) {
		// Set a flag on the player to they aren't robbed points for dying - the callback will remove the flag
		player.switching_teams = true;
		player.joining_team = newTeam;
		player.leaving_team = player.pers["team"];
	
		// Suicide the player so they can't hit escape
		player suicidePlayer();
	}
	player.pers["team"] = newTeam;
	player.team = newTeam;
						
	if ( newTeam != "spectator" ) {	
		player iprintlnbold( &"OW_B3_TEAMSWITCH" );
			
		player.pers["teamTime"] = undefined;
		player.sessionteam = player.pers["team"];
		player maps\mp\gametypes\_globallogic::updateObjectiveText();
	
		// update spectator permissions immediately on change of team
		player maps\mp\gametypes\_spectating::setSpectatePermissions();
	
		if ( player.pers["team"] == "allies" ) {
			player setclientdvar("g_scriptMainMenu", game["menu_class_allies"]);
			player openMenu( game[ "menu_changeclass_allies" ] );
		}	else if ( player.pers["team"] == "axis" ) {
			player setclientdvar("g_scriptMainMenu", game["menu_class_axis"]);
			player openMenu( game[ "menu_changeclass_axis" ] );
		}
	
		player notify( "end_respawn" );	
	} else {
		player.pers["class"] = undefined;
		player.class = undefined;
		player.pers["weapon"] = undefined;
		player.pers["savedmodel"] = undefined;

		player maps\mp\gametypes\_globallogic::updateObjectiveText();

		player.sessionteam = "spectator";
		player [[level.spawnSpectator]]();

		player setclientdvar("g_scriptMainMenu", game["menu_team"]);

		player notify("joined_spectators");	
	}
}


b3_killplayer( dVarValue )
{
	level endon( "game_ended" );
	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	
	// Search for the player
	player = findPlayerByNumber( dVarValue );
	if ( !isDefined( player ) || !isAlive( player ) )
		return;	
	
	player iprintlnbold( &"OW_B3_PUNISHED" );
	
	player suicidePlayer();	
}


b3_losepoint( dVarValue )
{
	level endon( "game_ended" );
	
	// Re-use b3_score by setting the correct value
	setDvar( "b3_score", "-1" );
	setDvar( "b3_scorecid", dVarValue );	
}


b3_rename( dVarValue )
{
	level endon( "game_ended" );
	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	// Make sure we have the new name we need to apply
	newName = getDvar( "b3_rname" );
	if ( newName == "" )
		return;
	
	// Search for the player
	player = findPlayerByNumber( dVarValue );
	if ( !isDefined( player ) )
		return;	

	// Change the player's name
	player unlink();
	player setClientDvar( "name", newName );	
}


b3_saybold( dVarValue )
{
	level endon( "game_ended" );
	
	// Play a sound on all the players and print the message
	level thread playSoundOnEveryone( "mp_last_stand" );
	iprintlnbold( dVarValue );	
}


b3_scarynade( dVarValue )
{
	level endon( "game_ended" );
	
	// Play a sound on all the players 
	level thread playSoundOnEveryone( "grenade_bounce_default" );		
}


b3_scaryshot( dVarValue )
{
	level endon( "game_ended" );
	
	// Play a sound on all the players 
	for ( times = 0; times < 3; times++ ) {
		level thread playSoundOnEveryone( "bullet_impact_headshot_2" );		
		wait ( randomFloatRange( 0.15, 0.35 ) );
	}
}


b3_scorecid( dVarValue )
{
	level endon( "game_ended" );
	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	// Make sure we have which value we need to apply to the player's score
	scoreDif = getDvarInt( "b3_score" );
	if ( scoreDif == 0 )
		return;
	
	// Search for the player
	player = findPlayerByNumber( dVarValue );
	if ( !isDefined( player ) )
		return;
		
	// Change the player's score
	player.score += scoreDif;
	player.pers["score"] += scoreDif;
	
	// Display a message to the players
	if ( scoreDif > 0 ) {
		iprintln( &"OW_B3_SCOREUP", player.name, scoreDif );
	} else {
		iprintln( &"OW_B3_SCOREDOWN", player.name, scoreDif * -1 );
	}	
}


b3_shock( dVarValue )
{
	level endon( "game_ended" );
	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	// Get the time or use a default one
	shockTime = getdvard( "b3_shocktime", "int", 5, 1, 10 );
	
	// Search for the player
	player = findPlayerByNumber( dVarValue );
	if ( !isDefined( player ) || !isAlive( player ) )
		return;	
	
	player iprintlnbold( &"OW_B3_PUNISHED" );
	
	// Shock the player
	player shellshock( "frag_grenade_mp", shockTime );	
}


b3_switchspec( dVarValue )
{
	level endon( "game_ended" );	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	
	// If it's only one player we'll use the other modules
	if ( dVarValue != -1 ) {
		setDvar( "b3_forceteamname", "spectator" );
		setDvar( "b3_forceteamcid", dVarValue );
		return;		
	}	
	
	// We need to switch all the players to spectator
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];

		// Make sure this player is not already an spectator
		if( player.pers["team"] != "spectator" ) {
			if( isAlive( player ) )	{
				player.switching_teams = true;
				player.joining_team = "spectator";
				player.leaving_team = player.pers["team"];
				player suicidePlayer();
			}
	
			player.pers["team"] = "spectator";
			player.team = "spectator";
			player.pers["class"] = undefined;
			player.class = undefined;
			player.pers["weapon"] = undefined;
			player.pers["savedmodel"] = undefined;
	
			player maps\mp\gametypes\_globallogic::updateObjectiveText();
	
			player.sessionteam = "spectator";
			player [[level.spawnSpectator]]();
	
			player setclientdvar("g_scriptMainMenu", game["menu_team"]);
	
			player notify("joined_spectators");
		}
	}	
}


b3_switchteam( dVarValue )
{
	level endon( "game_ended" );	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	
	// If it's only one player we'll use the other modules
	if ( dVarValue != -1 ) {
		// Search for the player
		player = findPlayerByNumber( dVarValue );
		if ( !isDefined( player ) || player.pers["team"] == "spectator" )
			return;			
		
		setDvar( "b3_forceteamname", level.otherTeam[player.pers["team"]] );
		setDvar( "b3_forceteamcid", dVarValue );
		return;		
	}	
	
	// We need to switch all the players to the other team
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		otherTeam = level.otherTeam[player.pers["team"]];
		
		// Make sure the player is not an spectator
		if ( player.pers["team"] != "spectator" ) {
			player iprintlnbold( &"OW_B3_TEAMSWITCH" );
				
			if ( isAlive( player ) ) {
				// Set a flag on the player to they aren't robbed points for dying - the callback will remove the flag
				player.switching_teams = true;
				player.joining_team = otherTeam;
				player.leaving_team = player.pers["team"];
			
				// Suicide the player so they can't hit escape
				player suicidePlayer();
			}
			
			player.pers["team"] = otherTeam;
			player.team = otherTeam;
			player.pers["teamTime"] = undefined;
			player.sessionteam = player.pers["team"];
			player maps\mp\gametypes\_globallogic::updateObjectiveText();
		
			// update spectator permissions immediately on change of team
			player maps\mp\gametypes\_spectating::setSpectatePermissions();
		
			if ( player.pers["team"] == "allies" ) {
				player setclientdvar("g_scriptMainMenu", game["menu_class_allies"]);
				player openMenu( game[ "menu_changeclass_allies" ] );
			}	else if ( player.pers["team"] == "axis" ) {
				player setclientdvar("g_scriptMainMenu", game["menu_class_axis"]);
				player openMenu( game[ "menu_changeclass_axis" ] );
			}
		
			player notify( "end_respawn" );			
		}		
	}	
}
