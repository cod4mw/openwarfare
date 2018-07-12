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

init()
{
	// Get the main module's dvar
	level.scr_clan_vs_all_team = getdvarx( "scr_clan_vs_all_team", "string", "" );

	// Check if we need to continue running this module
	if ( level.scr_clan_vs_all_team == "" ) {
		level thread addNewEvent( "onPlayerConnected", ::onPlayerConnectDefault );
		return;
	} else {
		// Make sure we have a valid value
		if ( level.scr_clan_vs_all_team != "allies" && level.scr_clan_vs_all_team != "axis" ) {
			level thread addNewEvent( "onPlayerConnected", ::onPlayerConnectDefault );
			return;
		}
	}

	// Load the rest of the module's dvars
	level.scr_clan_vs_all_tags = getdvarx( "scr_clan_vs_all_tags", "string", "" );

	// Transform clan tags into an array for easier handling (format for the variable should be "[FLOT] [TGW] {1stAD}"
	level.scr_clan_vs_all_tags = strtok( level.scr_clan_vs_all_tags, " " );

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnectDefault()
{
	self setClientDvars( "ui_force_allies", 0,
	                     "ui_force_axis", 0 );
}

onPlayerConnected()
{
	// Check if this player is a clan member
	if ( self isPlayerClanMember( level.scr_clan_vs_all_tags ) ) {
		self setClientDvars( "ui_force_allies", 0,
	                       "ui_force_axis", 0 );
	} else {
		self setClientDvars( "ui_force_allies", ( level.scr_clan_vs_all_team == "axis" ),
	                       "ui_force_axis", ( level.scr_clan_vs_all_team == "allies" ) );
	}
}
