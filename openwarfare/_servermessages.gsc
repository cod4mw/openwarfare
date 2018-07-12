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
	level.sv_enable_server_messages = getdvarx( "sv_enable_server_messages", "int", 0, 0, 1 );
	level.sv_server_message_nextmap = getdvarx( "sv_server_message_nextmap", "int", 0, 0, 1 );

	// Fetch the server messages and store them in a list.
	level.sv_server_messages = getDvarListx( "sv_server_message_", "string", "" );

	if ( (level.sv_enable_server_messages == 0 || level.sv_server_messages.size == 0) && level.sv_server_message_nextmap == 0 )
		return;

	// Get the module's dvars
	level.sv_server_messages_delay = getdvarx( "sv_server_messages_delay", "float", 15, 1, 120 );
	level.sv_server_messages_linebreak = getdvarx( "sv_server_messages_linebreak", "string", "|" );
	level.sv_server_message_deadonly = getdvarx( "sv_server_message_deadonly", "int", 0, 0, 1 );

	level thread addNewEvent( "onPlayerConnected", ::displayServerMessages );

	if ( level.sv_server_message_nextmap == 1 ) {
		precacheString( &"MPUI_NEXT_MAP" );
		precacheString( &"OW_NEXT_MAP" );
	}
}

displayServerMessages()
{
	self endon("disconnect");

	iMessage = 0;
	
	// Loop forever until the player disconnects
	for(;;)
	{
		xwait(0.05);
		
		// Show server messages if enabled
		while ( level.sv_enable_server_messages == 1 && iMessage < level.sv_server_messages.size && ( level.sv_server_message_deadonly == 0 || ( level.sv_server_message_deadonly == 1 && !isAlive( self ) ) ) ) {
			messageToDisplay = level.sv_server_messages[ iMessage ];
			linesToDisplay = strtok( messageToDisplay, level.sv_server_messages_linebreak );
			for ( iLine = 0; iLine < linesToDisplay.size; iLine++ ) {
				self iPrintLn( linesToDisplay[iLine] );
			}			
			iMessage++;
			xWait( level.sv_server_messages_delay );
		}
		// Check if we finished the cycle because we reach the end of the messages
		if ( iMessage == level.sv_server_messages.size ) {
			iMessage = 0;
		}

		// Show 'next map' message if enabled
		if (level.sv_server_message_nextmap == 1 && isDefined(level.nextMapInfo)&& ( level.sv_server_message_deadonly == 0 || ( level.sv_server_message_deadonly == 1 && !isAlive( self ) ) ) )
		{
			self iprintln( &"OW_NEXT_MAP", &"MPUI_NEXT_MAP", getMapName( level.nextMapInfo["mapname"] ), getGameType( level.nextMapInfo["gametype"] ) );
			wait level.sv_server_messages_delay;
		}
	}
}
