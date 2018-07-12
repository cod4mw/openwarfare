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
	// Get the main module's dvars
	level.scr_reservedslots_enable = getdvarx( "scr_reservedslots_enable", "int", 0, 0, 1 );
	
	// If the reserved slots are disabled then there's nothing else to do here
	if ( level.scr_reservedslots_enable == 0 )
		return;

	level.scr_reservedslots_amount = getdvarx( "scr_reservedslots_amount", "int", 1, 1, 64 );

	// Transform clan tags into an array for easier handling (format for the variable should be "[FLOT] [TGW] {1stAD}"
	level.scr_reservedslots_clantags = getdvarx( "scr_reservedslots_clantags", "string", "" );
	level.scr_reservedslots_clantags = strtok( level.scr_reservedslots_clantags, " " );

	// Load the rest of the module's variables
	level.scr_reservedslots_redirectip = getdvarx( "scr_reservedslots_redirectip", "string", "" );
			
	// GUIDs with their respective priority levels
	tempGUIDs = getdvarlistx( "scr_reservedslots_guids_", "string", "" );
	level.scr_reservedslots_guids = [];
	for ( iLine=0; iLine < tempGUIDs.size; iLine++ ) {
		thisLine = toLower( tempGUIDs[iLine] );
		thisLine = strtok( thisLine, ";" );
		for ( iGUID = 0; iGUID < thisLine.size; iGUID++ ) {
			guidPriority = strtok( thisLine[iGUID], "=" );
			if ( isDefined ( guidPriority[1] ) ) {
				level.scr_reservedslots_guids[ ""+guidPriority[0] ] = int( guidPriority[1] );
			} else {
				level.scr_reservedslots_guids[ ""+guidPriority[0] ] = 1;
			}
		}
	}
	
	level thread checkReservedSlots();
}


checkReservedSlots()
{
	// Save the number of slots at which point we need to start disconnecting players
	maxClientsAllowed = getDvarInt( "sv_maxclients" ) - level.scr_reservedslots_amount;
	clanMembersOnlyAt = getDvarInt( "sv_maxclients" ) - 1;
	
	for (;;)
	{
		wait (2.5);
		
		// Check if we have reached the amount of allowed clients
		usedSlots = getUsedSlots();
		if ( usedSlots > maxClientsAllowed ) {
			// Prioritize all the players and disconnect the player with the lowest priority/time played combination
			disconnectPlayer = undefined;
			reservedSlotPriority = 0;
			reservedSlotTimePlayed = 0;
			
			for ( i = 0; i < level.players.size; i++ ) {
				player = level.players[i];
				
				// Calculate the priority for this player
				if ( isDefined( player ) ) {
					// Check if we have a special priority for this player
					if ( isDefined( level.scr_reservedslots_guids[ ""+player getGUID() ] ) ) {
						thisPlayerPriority = level.scr_reservedslots_guids[ ""+player getGUID() ];
					} else {
						thisPlayerPriority = 0;
					}
					
					// Check if we have to add a clan tag priority
					if ( player isPlayerClanMember( level.scr_reservedslots_clantags ) ) {
						// If we haven't reached the maximum amount of players in total we'll skip this player
						if ( usedSlots <= clanMembersOnlyAt ) {
							continue;
						} else {
							thisPlayerPriority += 100;
						}
					}
					
					// Get the time that this player has played already
					if ( isDefined( player.timePlayed ) ) {
						thisPlayerTimePlayed = player.timePlayed["total"];					
					} else {
						thisPlayerTimePlayed = 0;
					}
					
					// Debug message
					// iprintln( "Player " + player.name + " has a priority of " + thisPlayerPriority + " with a time played of " + thisPlayerTimePlayed );
					
					// Check if the priority of this player is lower than the existing one or if the time played is lower in case he/she has the same priority
					if ( !isDefined( disconnectPlayer ) || reservedSlotPriority > thisPlayerPriority || ( reservedSlotPriority == thisPlayerPriority && reservedSlotTimePlayed >= thisPlayerTimePlayed ) ) {
						disconnectPlayer = player;
						reservedSlotPriority = thisPlayerPriority;
						reservedSlotTimePlayed = thisPlayerTimePlayed;
					}
				}				
			}
			
			// Check if we have a player to disconnect
			if ( isDefined( disconnectPlayer ) ) {
				disconnectPlayer disconnectPlayer( false );
			}
		}		
	}	
}


getUsedSlots()
{
	usedSlots = 0;
	for ( i = 0; i < level.players.size; i++ ) {
		if ( isDefined( level.players[i] ) ) {
			usedSlots++;
		}
	}
	return usedSlots;	
}


disconnectPlayer( manualRedirect )
{
	// Check if this a manual redirect
	if ( manualRedirect ) {
		if ( level.scr_reservedslots_enable == 0 || level.scr_reservedslots_redirectip == "" )
			return;

		clientCommand = "disconnect; wait 50; connect " + level.scr_reservedslots_redirectip;
		
	} else {
		// Close any menu that the player might have on screen
		self closeMenu();
		self closeInGameMenu();
		
		// Check if we should just disconnect the player or redirect him/her to another server
		if ( level.scr_reservedslots_redirectip != "" ) {
			clientCommand = "disconnect; wait 50; connect " + level.scr_reservedslots_redirectip;
			self iprintlnbold( &"OW_RESERVEDSLOTS_MAKEROOM_REDIRECT" );
		} else {
			clientCommand = "disconnect";
			self iprintlnbold( &"OW_RESERVEDSLOTS_MAKEROOM_DISCONNECT" );
			self iprintlnbold( &"OW_RESERVEDSLOTS_TRYAGAIN" );
		}
	
		wait (5.0);
	}
	
	// Let the other players know about the reason this player disconnected
	if ( level.scr_reservedslots_redirectip != "" ) {
		if ( manualRedirect ) {
			iprintln( &"OW_RESERVEDSLOTS_MANUAL_REDIRECT", self.name, level.scr_reservedslots_redirectip );
		} else {
			iprintln( &"OW_RESERVEDSLOTS_REDIRECTED", self.name, level.scr_reservedslots_redirectip );
		}
	} else {
		iprintln( &"OW_RESERVEDSLOTS_DISCONNECTED", self.name );
	}

	// Close any menu that the player might have on screen
	self closeMenu();
	self closeInGameMenu();		
	self thread execClientCommand( clientCommand );	
}