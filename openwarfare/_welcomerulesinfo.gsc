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
	game["menu_serverinfo"] = "serverinfo";
	
	// Get the main module's dvar
	level.scr_welcome_enable = getdvarx( "scr_welcome_enable", "int", 0, 0, 2 );	

	// If the welcome screen is not enabled then there's nothing else to do here
	if ( level.scr_welcome_enable == 0 )
		return;
		
	precacheMenu( game["menu_serverinfo"] );

	// Initialize the mod information and the title for the screen
	level.scr_welcome_modinfo = "^7Running " + getDvar( "_Mod" ) + " " + getDvar( "_ModVer" ) + ", please visit us at ^2http://openwarfaremod.com/^7.";
	level.scr_welcome_title = getdvarx( "scr_welcome_title", "string", getDvar( "sv_hostname" ) );

	// Load the messages to display
	level.scr_welcome_lines = [];
	for ( iLine = 1; iLine <= 8; iLine++ ) {
		level.scr_welcome_lines[ iLine - 1 ] = getdvarx( "scr_welcome_line_" + iLine, "string", "" );
	}

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnected()
{
	self thread setServerInformation();
}

setServerInformation()
{
	self endon("disconnect");

	// Set the title of the welcome screen, mod information line to be displayed at the bottom of the screen, and lines
	self setClientDvars( 
		"ui_welcome_title", level.scr_welcome_title,
		"ui_welcome_modinfo", level.scr_welcome_modinfo,
		"ui_welcome_line_0", level.scr_welcome_lines[ 0 ],
		"ui_welcome_line_1", level.scr_welcome_lines[ 1 ],
		"ui_welcome_line_2", level.scr_welcome_lines[ 2 ],
		"ui_welcome_line_3", level.scr_welcome_lines[ 3 ],
		"ui_welcome_line_4", level.scr_welcome_lines[ 4 ],
		"ui_welcome_line_5", level.scr_welcome_lines[ 5 ],
		"ui_welcome_line_6", level.scr_welcome_lines[ 6 ],
		"ui_welcome_line_7", level.scr_welcome_lines[ 7 ]
	);
}
