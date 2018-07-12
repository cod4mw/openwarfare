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
	level.scr_enable_globalchat = getdvarx( "scr_enable_globalchat", "int", 1, 0, 1 );

	// By default is on. We leave this thread running even when scr_enable_all_chat is ON
	// just in case a player played in a server where it was deactivated and left before
	// the game was over.
	setDvar( "globalchat", 1 );

	level thread monitorAllChat();
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );

	// Check if we need to disable all chat during the game
	if ( level.scr_enable_globalchat == 0 ) {
		level thread onReadyupPeriodStarted();
		level thread onPrematchOver();
		level thread onGameEnded();
	}
}


onPlayerConnected()
{
	self setClientDvar( "cg_TeamChatsOnly", !getDvarInt( "globalchat" ) );
}


onReadyupPeriodStarted()
{
	level endon( "game_ended" );

	for (;;) {
		level waittill( "readyupperiod_started" );
		setDvar( "globalchat", 1 );
	}
}


onPrematchOver()
{
	level endon( "game_ended" );

	for (;;) {
		level waittill( "prematch_over" );
		setDvar( "globalchat", 0 );
	}
}


onGameEnded()
{
	level waittill( "game_ended" );
	setDvar( "globalchat", 1 );

	return;
}


monitorAllChat()
{
	globalChat = getDvarInt( "globalchat" );

	for (;;)
	{
		wait (1.0);

		// Get the current value of globalchat
		newGlobalChat = getDvarInt( "globalchat" );

		// Check if globalchat has changed
		if ( globalChat != newGlobalChat ) {
			// Globalchat variable has changed, set the players to the new value
			globalChat = newGlobalChat;
			thread playersResetAllChat( globalChat );
		}
	}
}


playersResetAllChat( globalChat )
{
	// Adjust the chat option for all the players in the game
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		player setClientDvar( "cg_TeamChatsOnly", !globalChat );
	}

	return;
}