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
	level.scr_player_connect_sound_enable = getdvarx( "scr_player_connect_sound_enable", "int", 0, 0, 1 );
	level.scr_player_disconnect_sound_enable = getdvarx( "scr_player_disconnect_sound_enable", "int", 0, 0, 1 );

	// If both sounds are disabled there's nothing else to do here
	if ( level.scr_player_connect_sound_enable == 0 && level.scr_player_disconnect_sound_enable == 0 )
		return;
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	// Check if we should play a sound for this player
	if( level.scr_player_connect_sound_enable && !isDefined( self.pers["connected"] ) ) {
		self.pers["connected"] = true;
		
		for ( index = 0; index < level.players.size; index++ ) {
			player = level.players[index];
			if ( isDefined( player ) && player != self ) {
				player playLocalSound( "player_connected" );
			}
		}
	}	
	
	if ( level.scr_player_disconnect_sound_enable ) {
		self thread onPlayerDisconnect();
	}
}


onPlayerDisconnect()
{
	// Store the name for display purposes
	playerName = self.name;
	
	self waittill( "disconnect" );
	
	iPrintLn( &"MP_DISCONNECTED", playerName );
	
	// Play disconnect sound for the rest of the players
	for ( index = 0; index < level.players.size; index++ ) {
		player = level.players[index];
		if ( isDefined( player ) ) {
			player playLocalSound( "player_disconnected" );
		}
	}
}