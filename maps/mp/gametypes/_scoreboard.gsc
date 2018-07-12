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
	// Use this variable to know if players have switched teams
	if ( !isDefined( game["switchedteams"] ) )
		game["switchedteams"] = false;

	// Make sure the mapper has defined the teams correctly
	if ( !isDefined( game["allies"] ) || ( game["allies"] != "marines" && game["allies"] != "sas" ) ) {
		game["allies"] = "marines";
	}
	if ( !isDefined( game["axis"] ) || ( game["axis"] != "opfor" && game["axis"] != "arab" && game["axis"] != "russian" ) ) {
		game["axis"] = "opfor";
	}	

	// Get some variables
	level.scr_custom_teams_enable = getdvarx( "scr_custom_teams_enable", "int", 0, 0, 1 );
	level.scr_custom_teams_maintain_on_switch = getdvarx( "scr_custom_teams_maintain_on_switch", "int", 1, 0, 1 );
	
	level.scr_custom_teams_strings = getdvarx( "scr_custom_teams_strings", "string", "have won the match!;have won the round!;mission accomplished;eliminated;forfeited;have been all frozen!" );
	level.scr_custom_teams_strings = strtok( level.scr_custom_teams_strings, ";" );
	
	level.scr_custom_allies_name = getdvarx( "scr_custom_allies_name", "string", "" );
	level.scr_custom_allies_logo = getdvarx( "scr_custom_allies_logo", "string", "" );
	level.scr_custom_allies_headicon = getdvarx( "scr_custom_allies_headicon", "string", "" );
	level.scr_custom_axis_name = getdvarx( "scr_custom_axis_name", "string", "" );
	level.scr_custom_axis_logo = getdvarx( "scr_custom_axis_logo", "string", "" );
	level.scr_custom_axis_headicon = getdvarx( "scr_custom_axis_headicon", "string", "" );

	// Set default resources
	teamNames["sas"] = &"MPUI_SAS_SHORT";
	teamNames["marines"] = &"MPUI_MARINES_SHORT";
	teamNames["opfor"] = &"MPUI_OPFOR_SHORT";
	teamNames["arab"] = &"MPUI_OPFOR_SHORT";
	teamNames["russian"] = &"MPUI_SPETSNAZ_SHORT";
	
	logoNames["sas"] = "faction_128_sas";
	logoNames["marines"] = "faction_128_usmc";
	logoNames["opfor"] = "faction_128_arab";
	logoNames["arab"] = "faction_128_arab";
	logoNames["russian"] = "faction_128_ussr";
	
	headIconNames["sas"] = "headicon_british";
	headIconNames["marines"] = "headicon_american";
	headIconNames["opfor"] = "headicon_opfor";
	headIconNames["arab"] = "headicon_opfor";
	headIconNames["russian"] = "headicon_russian";

	switch ( game["allies"] )
	{
		case "sas":
			game["strings"]["allies_win"] = &"MP_SAS_WIN_MATCH";
			game["strings"]["allies_win_round"] = &"MP_SAS_WIN_ROUND";
			game["strings"]["allies_mission_accomplished"] = &"MP_SAS_MISSION_ACCOMPLISHED";
			game["strings"]["allies_eliminated"] = &"MP_SAS_ELIMINATED";
			game["strings"]["allies_forfeited"] = &"MP_SAS_FORFEITED";				
			break;
			
		case "marines":
		default:
			game["strings"]["allies_win"] = &"MP_MARINES_WIN_MATCH";
			game["strings"]["allies_win_round"] = &"MP_MARINES_WIN_ROUND";
			game["strings"]["allies_mission_accomplished"] = &"MP_MARINES_MISSION_ACCOMPLISHED";
			game["strings"]["allies_eliminated"] = &"MP_MARINES_ELIMINATED";
			game["strings"]["allies_forfeited"] = &"MP_MARINES_FORFEITED";
			break;
	}
	
	switch ( game["axis"] )
	{
		case "russian":
			game["strings"]["axis_win"] = &"MP_SPETSNAZ_WIN_MATCH";
			game["strings"]["axis_win_round"] = &"MP_SPETSNAZ_WIN_ROUND";
			game["strings"]["axis_mission_accomplished"] = &"MP_SPETSNAZ_MISSION_ACCOMPLISHED";
			game["strings"]["axis_eliminated"] = &"MP_SPETSNAZ_ELIMINATED";
			game["strings"]["axis_forfeited"] = &"MP_SPETSNAZ_FORFEITED";
			break;
				
		case "arab":
		case "opfor":
		default:
			game["strings"]["axis_win"] = &"MP_OPFOR_WIN_MATCH";
			game["strings"]["axis_win_round"] = &"MP_OPFOR_WIN_ROUND";
			game["strings"]["axis_mission_accomplished"] = &"MP_OPFOR_MISSION_ACCOMPLISHED";
			game["strings"]["axis_eliminated"] = &"MP_OPFOR_ELIMINATED";
			game["strings"]["axis_forfeited"] = &"MP_OPFOR_FORFEITED";
			break;
	}				
				
	// Check if we should use custom content or not
	if ( level.scr_custom_teams_enable == 1 ) {
		// Check value by value and change the default one when set
		if ( level.scr_custom_allies_name != "" )
			teamNames[ game[ "allies" ] ] = level.scr_custom_allies_name;

		if ( level.scr_custom_axis_name != "" )
			teamNames[ game[ "axis" ] ] = level.scr_custom_axis_name;			
			
		if ( level.scr_custom_allies_logo != "" )
			logoNames[ game[ "allies" ] ] = level.scr_custom_allies_logo;

		if ( level.scr_custom_axis_logo != "" )
			logoNames[ game[ "axis" ] ] = level.scr_custom_axis_logo;

		if ( level.scr_custom_allies_headicon != "" )
			headIconNames[ game[ "allies" ] ] = level.scr_custom_allies_headicon;

		if ( level.scr_custom_axis_headicon != "" )
			headIconNames[ game[ "axis" ] ] = level.scr_custom_axis_headicon;								

		// Change the localized strings
		game["strings"]["allies_win"] = level.scr_custom_allies_name + " " + level.scr_custom_teams_strings[0];
		game["strings"]["allies_win_round"] = level.scr_custom_allies_name + " " + level.scr_custom_teams_strings[1];
		game["strings"]["allies_mission_accomplished"] = level.scr_custom_allies_name + " " + level.scr_custom_teams_strings[2];
		game["strings"]["allies_eliminated"] = level.scr_custom_allies_name + " " + level.scr_custom_teams_strings[3];
		game["strings"]["allies_forfeited"] = level.scr_custom_allies_name + " " + level.scr_custom_teams_strings[4];	

		game["strings"]["axis_win"] = level.scr_custom_axis_name + " " + level.scr_custom_teams_strings[0];
		game["strings"]["axis_win_round"] = level.scr_custom_axis_name + " " + level.scr_custom_teams_strings[1];
		game["strings"]["axis_mission_accomplished"] = level.scr_custom_axis_name + " " + level.scr_custom_teams_strings[2];
		game["strings"]["axis_eliminated"] = level.scr_custom_axis_name + " " + level.scr_custom_teams_strings[3];
		game["strings"]["axis_forfeited"] = level.scr_custom_axis_name + " " + level.scr_custom_teams_strings[4];
	}

	// Set the values that we'll be using
	level.scr_team_allies_name = teamNames[ game[ "allies" ] ];
	level.scr_team_allies_logo = logoNames[ game[ "allies" ] ];
	level.scr_team_allies_headicon = headIconNames[ game[ "allies" ] ];
	
	level.scr_team_axis_name = teamNames[ game[ "axis" ] ];
	level.scr_team_axis_logo = logoNames[ game[ "axis" ] ];
	level.scr_team_axis_headicon = headIconNames[ game[ "axis" ] ];	


	// Set variables and internal values according to team sides
	level thread setTeamResources();
	
	// Set the colors for names
	switch(game["allies"])
	{
		case "sas":
			setDvar( "g_TeamColor_Allies", ".5 .5 .5" );
			setDvar( "g_ScoresColor_Allies", "0 0 0" );
			break;
		
		default:
			setDvar( "g_TeamColor_Allies", "0.6 0.64 0.69" );
			setDvar( "g_ScoresColor_Allies", "0.6 0.64 0.69" );
			break;
	}


	switch(game["axis"])
	{
		case "opfor":
		case "arab":
			setDvar( "g_TeamColor_Axis", "0.65 0.57 0.41" );		
			setDvar( "g_ScoresColor_Axis", "0.65 0.57 0.41" );
			break;
		
		default:
			setDvar( "g_TeamColor_Axis", "0.52 0.28 0.28" );		
			setDvar( "g_ScoresColor_Axis", "0.52 0.28 0.28" );
			break;
	}
	
	setDvar( "g_ScoresColor_Spectator", ".25 .25 .25" );
	setDvar( "g_ScoresColor_Free", ".76 .78 .10" );
	setDvar( "g_teamColor_MyTeam", ".6 .8 .6" );
	setDvar( "g_teamColor_EnemyTeam", "1 .45 .5" );	
}


setTeamResources()
{
	// Check if we should switch names/icons
	if ( level.scr_custom_teams_maintain_on_switch == 1 && game["switchedteams"] ) {
		// Switch names
		if ( level.scr_custom_allies_name != "" || level.scr_custom_axis_name != "" ) {
			tempName = level.scr_team_axis_name;
			level.scr_team_axis_name = level.scr_team_allies_name;
			level.scr_team_allies_name = tempName;

			// Switch strings
			axisWin = game["strings"]["axis_win"];
			axisWinRound = game["strings"]["axis_win_round"];
			axisMissionAccomplished = game["strings"]["axis_mission_accomplished"];
			axisEliminated = game["strings"]["axis_eliminated"];
			axisForfeited = game["strings"]["axis_forfeited"];
	
			game["strings"]["axis_win"] = game["strings"]["allies_win"];
			game["strings"]["axis_win_round"] = game["strings"]["allies_win_round"];
			game["strings"]["axis_mission_accomplished"] = game["strings"]["allies_mission_accomplished"];
			game["strings"]["axis_eliminated"] = game["strings"]["allies_eliminated"];
			game["strings"]["axis_forfeited"] = game["strings"]["allies_forfeited"];		
					
			game["strings"]["allies_win"] = axisWin;
			game["strings"]["allies_win_round"] = axisWinRound;
			game["strings"]["allies_mission_accomplished"] = axisMissionAccomplished;
			game["strings"]["allies_eliminated"] = axisEliminated;
			game["strings"]["allies_forfeited"] = axisForfeited;	
		}
				
		// Switch logos
		if ( level.scr_custom_allies_logo != "" || level.scr_custom_axis_logo != "" ) {
			tempLogo = level.scr_team_axis_logo;
			level.scr_team_axis_logo = level.scr_team_allies_logo;
			level.scr_team_allies_logo = tempLogo;
		}
		
		// Switch Head Icons
		if ( level.scr_custom_allies_headicon != "" || level.scr_custom_axis_headicon != "" ) {
			tempHeadIcon = level.scr_team_axis_headicon;
			level.scr_team_axis_headicon = level.scr_team_allies_headicon;
			level.scr_team_allies_headicon = tempHeadIcon;
		}
	}

	setServerTeamResources();
}


setServerTeamResources()
{
	// Set server and internal variables
	precacheShader( level.scr_team_allies_logo );
	setDvar( "g_TeamIcon_Allies", level.scr_team_allies_logo );
	setDvar( "g_TeamName_Allies", level.scr_team_allies_name );	
	game["strings"]["allies_name"] = level.scr_team_allies_name;
	game["icons"]["allies"] = level.scr_team_allies_logo;		
	
	precacheShader( level.scr_team_axis_logo );
	setDvar( "g_TeamIcon_Axis", level.scr_team_axis_logo );
	setDvar( "g_TeamName_Axis", level.scr_team_axis_name );
	game["strings"]["axis_name"] = level.scr_team_axis_name;			
	game["icons"]["axis"] = level.scr_team_axis_logo;
}