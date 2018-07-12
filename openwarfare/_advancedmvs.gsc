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

#include openwarfare\_eventmanager;
#include openwarfare\_utils;

init()
{
	// Get the main module's dvars
	level.scr_amvs_enable = getdvard( "scr_amvs_enable", "int", 0, 0, 2 );
	level.mapVotingInProgress = false;

	// Variable to be used to know if the admin has set the next gametype/map manually
	if ( !isDefined( game["amvs_skip_voting"] ) )
		game["amvs_skip_voting"] = false;	
		
	// If the advanced map voting system is not enabled then there's nothing else to do here
	if ( level.scr_amvs_enable == 0 )
		return;

	// Initialize the variables for this AMV session		
	level.amvsWinnerGametype = "";
	level.amvsWinnerMap = "";
	level.scr_amvs_gametypes_votes = [];
	level.scr_amvs_maps_votes = [];
	
	level.mapVoteFirstPlace = " (0)";
	level.mapVoteSecondPlace = " (0)";
	level.mapVoteThirdPlace = " (0)";

	// Load the rest of the modules's variables
	level.scr_amvs_gametype_time = getdvard( "scr_amvs_gametype_time", "float", 15, 5, 45 );
	level.scr_amvs_map_time = getdvard( "scr_amvs_map_time", "float", 15, 5, 45 );
	level.scr_amvs_winner_time = getdvard( "scr_amvs_winner_time", "float", 5, 5, 45 );
	level.scr_amvs_can_repeat_map = getdvard( "scr_amvs_can_repeat_map", "int", 0, 0, 1 );
	
	// Load allowed gametypes
	level.scr_amvs_gametypes = getdvard( "scr_amvs_gametypes", "string", level.defaultGametypeList );
	if ( level.scr_amvs_gametypes == "" )
		level.scr_amvs_gametypes = level.gametype;
	level.scr_amvs_gametypes = strtok( level.scr_amvs_gametypes, ";" );

	precacheMenu( "advancedmvs" );

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


mapVoting_Intermission()
{
	// Check if the map voting system is not enabled
	if ( level.scr_amvs_enable == 0 || game["amvs_skip_voting"] )
		return;

	// Save the next map in the rotation
	level.mapVoteNextGametype = level.nextMapInfo["gametype"];
	level.mapVoteNextMap = level.nextMapInfo["mapname"];

	logPrint( "MVS;D;" + level.mapVoteNextGametype + ";" + level.mapVoteNextMap + "\n" );
	
	if ( level.scr_amvs_enable == 1 ) {
		// Make sure we have the next gametype in the rotation in the array
		type = 0;
		while ( type < level.scr_amvs_gametypes.size && level.scr_amvs_gametypes[type] != level.mapVoteNextGametype ) {
			type++;
		}		
		if ( type == level.scr_amvs_gametypes.size ) {
			level.scr_amvs_gametypes[ level.scr_amvs_gametypes.size ] = level.mapVoteNextGametype;
		}
	
		// Load maps for each gametype
		level.scr_amvs_maps = [];
		for (type=0; type < level.scr_amvs_gametypes.size; type++ ) {
			thisGameType = [];
			// Check if we have maps just for this gametype first
			lineNumber = 1;
			for (;;) {
				thisLine = getdvarl( "scr_amvs_maps_" + level.scr_amvs_gametypes[type] + "_" + lineNumber, "string", "", undefined, undefined, true );
				if ( thisLine == "" ) {
					break;
				}
				// Process this line
				thisLine = strtok( thisLine, ";" );
				for ( index=0; index < thisLine.size; index++ ) {
					if ( level.scr_amvs_can_repeat_map == 1 || thisLine[index] != level.script ) {
						thisGameType[thisGameType.size] = thisLine[index];
					}
				}
				// Process next line
				lineNumber++;				
			}
			
			// Check if we found maps just for that gametype
			if ( thisGameType.size == 0 ) {
				// Check if we have maps just for this gametype first
				lineNumber = 1;
				for (;;) {
					thisLine = getdvarl( "scr_amvs_maps_" + lineNumber, "string", "", undefined, undefined, true );
					if ( thisLine == "" && lineNumber == 1 ) {
						thisLine = getdvarl( "scr_amvs_maps", "string", level.defaultMapList, undefined, undefined, true );
					} else if ( thisLine == "" ) {
						break;
					}
					// Process this line
					thisLine = strtok( thisLine, ";" );
					for ( index=0; index < thisLine.size; index++ ) {
						if ( level.scr_amvs_can_repeat_map == 1 || thisLine[index] != level.script ) {
							thisGameType[thisGameType.size] = thisLine[index];
						}
					}
					// Process next line
					lineNumber++;				
				}				
			}
			
			// Add the maps for this gametype
			level.scr_amvs_maps[ level.scr_amvs_gametypes[type] ] = thisGameType;
		}
		
	} else {
		// Get the current map/gametypes combinations and build the arrays
		mgCombinations = openwarfare\_maprotationcs::getMapGametypeCombinations();
		level.scr_amvs_gametypes = [];
		level.scr_amvs_maps = [];
		auxVar = [];
		
		for ( mg=0; mg < mgCombinations.size; mg++ ) {
			// Check if we have this gametype already
			if ( !isDefined( auxVar[ mgCombinations[mg]["gametype"] ] ) ) {
				auxVar[ mgCombinations[mg]["gametype"] ] = [];
				level.scr_amvs_gametypes[ level.scr_amvs_gametypes.size ] = mgCombinations[mg]["gametype"];
			}
			
			// Check if this is the first time we have this gametype
			if ( !isDefined( level.scr_amvs_maps[ mgCombinations[mg]["gametype"] ] ) ) {
				level.scr_amvs_maps[ mgCombinations[mg]["gametype"] ] = [];
			}
			
			// Check if we have this map already for the gametype
			if ( !isDefined( auxVar[ mgCombinations[mg]["gametype"] ][ mgCombinations[mg]["mapname"] ] ) ) {
				auxVar[ mgCombinations[mg]["gametype"] ][ mgCombinations[mg]["mapname"] ] = true;
				
				if ( level.scr_amvs_can_repeat_map == 1 || mgCombinations[mg]["mapname"] != level.script ) {
					level.scr_amvs_maps[ mgCombinations[mg]["gametype"] ][ level.scr_amvs_maps[ mgCombinations[mg]["gametype"] ].size ] = mgCombinations[mg]["mapname"];
				}
			}			
		}
	}

	level.mapVotingInProgress = true;

	// Reset internal votes and monitor for votes
	level thread monitorPlayerVotes();
	level thread openMapVotingMenu();

	// Check if there's only one gametype allowed to vote for gametype
	if ( level.scr_amvs_gametypes.size > 1 ) {
		level thread setGametypeVariables();		
		// Reset voting clock and wait for the time to be over
		thread maps\mp\gametypes\_globallogic::timeLimitClock_Intermission( level.scr_amvs_gametype_time, false );
		wait ( level.scr_amvs_gametype_time );
	}
	
	// Determine the gametype winner and send map variables to the players
	determineGametypeWinner();
	level thread setMapVariables();
	
	// Reset voting clock and wait for the time to be over
	thread maps\mp\gametypes\_globallogic::timeLimitClock_Intermission( level.scr_amvs_map_time, false );
	wait ( level.scr_amvs_map_time );
	
	// Determine the map winner and send the winner variables to the players
	determineMapWinner();
	
	logPrint( "MVS;W;" + level.amvsWinnerGametype + ";" + level.amvsWinnerMap + "\n" );
		
	// Check if we need to add the win combination to the map rotation
	if ( ( level.amvsWinnerGametype != "" && level.amvsWinnerGametype != level.mapVoteNextGametype ) || ( level.amvsWinnerMap != "" && level.amvsWinnerMap != level.mapVoteNextMap ) ) {
		nextRotation = " " + getDvar( "sv_mapRotationCurrent" );
		setDvar( "sv_mapRotationCurrent", "gametype " + level.amvsWinnerGametype + " map " + level.amvsWinnerMap + nextRotation );		
	}
	
	// Reset loading clock and wait for the time to be over
	thread maps\mp\gametypes\_globallogic::timeLimitClock_Intermission( level.scr_amvs_winner_time, true );
	wait ( level.scr_amvs_winner_time );
	
	level thread closeMapVotingMenu();
}


resetClientVariables()
{
	// Reset all the variables used in the menu 
	self setClientDvars(
		"ui_amvs_gametype_winner", level.amvsWinnerGametype,
		"ui_amvs_map_winner", level.amvsWinnerMap,
		"ui_amvs_firstplace", level.mapVoteFirstPlace,
		"ui_amvs_secondplace", level.mapVoteSecondPlace,
		"ui_amvs_thirdplace", level.mapVoteThirdPlace,
		"ui_welcome_modinfo", "^7Running " + getDvar( "_Mod" ) + " " + getDvar( "_ModVer" ) + ", please visit us at ^2http://openwarfaremod.com/^7."
	);
}

onPlayerConnected()
{
	// Open the menu
	self thread onMenuResponse();

	// Reset player variables
	self resetClientVariables();
			
	if ( level.mapVotingInProgress ) {

			
		// Check which variables we should be sending to the player
		if ( level.amvsWinnerGametype == "" ) {
			self sendPlayerGametypeVariables();
			
		} else if ( level.amvsWinnerMap == "" ) {
			self sendPlayerWinnerVariables();
			self sendPlayerMapVariables();
			
		} else {
			self sendPlayerWinnerVariables();
		}

		self closeMenu();
		self closeInGameMenu();
		self openMenu( "advancedmvs" );
	}
}


openMapVotingMenu()
{
	for ( index = 0; index < level.players.size; index++ ) {
		player = level.players[index];
		if ( isDefined( player ) ) {
			player closeMenu();
			player closeInGameMenu();
			player.sessionstate = "spectator";
			player openMenu( "advancedmvs" );
		}
	}
}


closeMapVotingMenu()
{
	for ( index = 0; index < level.players.size; index++ ) {
		player = level.players[index];
		if ( isDefined( player ) ) {
			player closeMenu();
			player closeInGameMenu();
			player.sessionstate = "intermission";
		}
	}
}


setGametypeVariables()
{
	for ( index = 0; index < level.players.size; index++ ) {
		player = level.players[index];
		if ( isDefined( player ) ) {
			player thread sendPlayerGametypeVariables();
		}
	}	
}

sendPlayerGametypeVariables()
{
	// Check if we should initialize the player's next gametype
	if ( !isDefined( self.mapVote ) || !isDefined( self.mapVote["gametype"] ) ) {
		self.mapVote["vote"] = "";
		
		// Set the initial gametype for this player
		// Search for the position of the next gametype
		newPosition = 0;
		while ( newPosition < level.scr_amvs_gametypes.size && level.scr_amvs_gametypes[newPosition] != level.mapVoteNextGametype )
			newPosition++;
			
		// If we couldn't find the position then we use the first element
		if ( newPosition == level.scr_amvs_gametypes.size )
			newPosition = 0;
			
		self.mapVote["gametype"] = newPosition;
	}
	
	// Get the previous gametype
	previousGametype = self.mapVote["gametype"] - 1;
	if ( previousGametype < 0 )
		previousGametype = level.scr_amvs_gametypes.size - 1;
	
	// Get the next gametype
	nextGametype = self.mapVote["gametype"] + 1;
	if ( nextGametype == level.scr_amvs_gametypes.size )
		nextGametype = 0;

	// Set the previous, current, and next gametypes for this player
	self setClientDvars(
		"ui_amvs_gametype_previous", getGameType( level.scr_amvs_gametypes[previousGametype] ),
		"ui_amvs_gametype_vote", getGameType( level.scr_amvs_gametypes[self.mapVote["gametype"]] ),
		"ui_amvs_gametype_next", getGameType( level.scr_amvs_gametypes[nextGametype] )
	);
}


determineGametypeWinner()
{
	// Count the votes
	voteWinner = countPlayerVotes();
	
	// Make sure we have a winner
	if ( voteWinner == "" ) {
		level.amvsWinnerGametype = level.mapVoteNextGametype;
	} else {
		level.amvsWinnerGametype = voteWinner;
	}
	
	// Send the gametype winner to all the players
	for ( index = 0; index < level.players.size; index++ ) {
		player = level.players[index];
		if ( isDefined( player ) ) {
			player setClientDvars( 
				"ui_amvs_gametype_winner", level.amvsWinnerGametype,
				"ui_amvs_gametype_vote", getGametype( level.amvsWinnerGametype ) );
		}
	}		
}


setMapVariables()
{
	level.mapVoteFirstPlace = " (0)";
	level.mapVoteSecondPlace = " (0)";
	level.mapVoteThirdPlace = " (0)";
		
	for ( index = 0; index < level.players.size; index++ ) {
		player = level.players[index];
		if ( isDefined( player ) ) {
			player thread sendPlayerMapVariables();
			player setClientDvars(
				"ui_amvs_firstplace", level.mapVoteFirstPlace,
				"ui_amvs_secondplace", level.mapVoteSecondPlace,
				"ui_amvs_thirdplace", level.mapVoteThirdPlace
			);
		}
	}	
}


sendPlayerMapVariables()
{
	// Check if we should initialize the player's current map
	if ( !isDefined( self.mapVote ) || !isDefined( self.mapVote["map"] ) ) {
		self.mapVote["vote"] = "";
	
		// Set the initial map for this player
		// Search for the position of the next map
		newPosition = 0;
		while ( newPosition < level.scr_amvs_maps[level.amvsWinnerGametype].size && level.scr_amvs_maps[level.amvsWinnerGametype][newPosition] != level.mapVoteNextMap )
			newPosition++;
			
		// If we couldn't find the position then we use the first element
		if ( newPosition == level.scr_amvs_maps[level.amvsWinnerGametype].size )
			newPosition = 0;
			
		self.mapVote["map"] = newPosition;
	}
	
	// Get the previous map
	previousMap = self.mapVote["map"] - 1;
	if ( previousMap < 0 )
		previousMap = level.scr_amvs_maps[level.amvsWinnerGametype].size - 1;
	
	// Get the next map
	nextMap = self.mapVote["map"] + 1;
	if ( nextMap == level.scr_amvs_maps[level.amvsWinnerGametype].size )
		nextMap = 0;

	// Set the previous, current, and next maps for this player
	self setClientDvars(
		"ui_amvs_map_previous", getMapName( level.scr_amvs_maps[level.amvsWinnerGametype][previousMap] ),
		"ui_amvs_map_vote", getMapName( level.scr_amvs_maps[level.amvsWinnerGametype][self.mapVote["map"]] ),
		"ui_amvs_map_next", getMapName( level.scr_amvs_maps[level.amvsWinnerGametype][nextMap] )
	);	
}



determineMapWinner()
{
	// Count the votes
	voteWinner = countPlayerVotes();

	// Check if we have a winner set
	if ( voteWinner == "" ) {
		// Check if the winner gametype was the next one
		if ( level.mapVoteNextGametype != level.amvsWinnerGametype ) {
			
			// Make sure this map is allowed for the gametype winner
			newPosition = 0;
			while ( newPosition < level.scr_amvs_maps[level.amvsWinnerGametype].size && level.scr_amvs_maps[level.amvsWinnerGametype][newPosition] != level.mapVoteNextMap )
				newPosition++;
			
			// If we couldn't find the position then we use the first element as long as the winner gametype is different from the default gametype
			if ( newPosition == level.scr_amvs_maps[level.amvsWinnerGametype].size ) {
				level.amvsWinnerMap = level.scr_amvs_maps[level.amvsWinnerGametype][0];
			} else {
				level.amvsWinnerMap = level.mapVoteNextMap;	
			}
		} else {
			level.amvsWinnerMap = level.mapVoteNextMap;	
		}
		
	} else {
		level.amvsWinnerMap = voteWinner;
	}
	
	// Send the map winner to all the players
	for ( index = 0; index < level.players.size; index++ ) {
		player = level.players[index];
		if ( isDefined( player ) ) {
			player setClientDvars( 
				"ui_amvs_map_winner", level.amvsWinnerMap,
				"ui_amvs_map_vote", getMapName( level.amvsWinnerMap ) );
		}
	}		
}


sendPlayerWinnerVariables()
{
	self setClientDvars(
		"ui_amvs_gametype_vote", getGameType( level.amvsWinnerGametype ),
		"ui_amvs_map_vote", getMapName( level.amvsWinnerMap ),
	
		"ui_amvs_gametype_winner", level.amvsWinnerGametype,
		"ui_amvs_map_winner", level.amvsWinnerMap
	);
}


onMenuResponse()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill( "menuresponse", menuName, menuOption );
		
		// Make sure we handle only responses coming from the Advanced MVS menu
		if ( menuName == "advancedmvs" ) {
			switch ( menuOption ) {
				case "previousgametype":
					self.mapVote["gametype"] = self.mapVote["gametype"] - 1;
					if ( self.mapVote["gametype"] < 0 )
						self.mapVote["gametype"] = level.scr_amvs_gametypes.size - 1;
					self thread sendPlayerGametypeVariables();
					break;

				case "nextgametype":
					self.mapVote["gametype"] = self.mapVote["gametype"] + 1;
					if ( self.mapVote["gametype"] == level.scr_amvs_gametypes.size )
						self.mapVote["gametype"] = 0;
					self thread sendPlayerGametypeVariables();
					break;

				case "votegametype":
					if ( self.mapVote["vote"] == "" || self.mapVote["vote"] != level.scr_amvs_gametypes[self.mapVote["gametype"]] ) {
						// Check if we need to remove previous vote
						if ( self.mapVote["vote"] != "" ) {
							level.scr_amvs_gametypes_votes[ self.mapVote["vote"] ]--;
						}
						
						// Check if this is the first vote against this gametype
						if ( !isDefined( level.scr_amvs_gametypes_votes[ level.scr_amvs_gametypes[self.mapVote["gametype"]] ] ) ) {
							level.scr_amvs_gametypes_votes[ level.scr_amvs_gametypes[self.mapVote["gametype"]] ] = 0;							
						}
						
						// Add the new vote
						self.mapVote["vote"] = level.scr_amvs_gametypes[self.mapVote["gametype"]];
						level.scr_amvs_gametypes_votes[ self.mapVote["vote"] ]++;
						level notify( "vote_casted" );
					}
					break;

				case "previousmap":
					self.mapVote["map"] = self.mapVote["map"] - 1;
					if ( self.mapVote["map"] < 0 )
						self.mapVote["map"] = level.scr_amvs_maps[level.amvsWinnerGametype].size - 1;
					self thread sendPlayerMapVariables();	
					break;

				case "nextmap":
					self.mapVote["map"] = self.mapVote["map"] + 1;
					if ( self.mapVote["map"] == level.scr_amvs_maps[level.amvsWinnerGametype].size )
						self.mapVote["map"] = 0;
					self thread sendPlayerMapVariables();
					break;

				case "votemap":
					if ( self.mapVote["vote"] == "" || self.mapVote["vote"] != level.scr_amvs_maps[level.amvsWinnerGametype][self.mapVote["map"]] ) {
						// Check if we need to remove previous vote
						if ( self.mapVote["vote"] != "" ) {
							level.scr_amvs_maps_votes[ self.mapVote["vote"] ]--;
						}
						
						// Check if this is the first vote against this map
						if ( !isDefined( level.scr_amvs_maps_votes[ level.scr_amvs_maps[level.amvsWinnerGametype][self.mapVote["map"]] ] ) ) {
							level.scr_amvs_maps_votes[ level.scr_amvs_maps[level.amvsWinnerGametype][self.mapVote["map"]] ] = 0;							
						}
						
						// Add the new vote
						self.mapVote["vote"] = level.scr_amvs_maps[level.amvsWinnerGametype][self.mapVote["map"]];
						level.scr_amvs_maps_votes[ self.mapVote["vote"] ]++;
						level notify( "vote_casted" );
					}
					break;
			}
		}
	}
}


monitorPlayerVotes()
{
	for (;;)
	{
		level waittill( "vote_casted" );
		
		// Check which votes we should count
		if ( level.amvsWinnerGametype == "" ) {
			ballotsBox = level.scr_amvs_gametypes_votes;
			translationFunction = ::getGameType;
		} else {
			ballotsBox = level.scr_amvs_maps_votes;
			translationFunction = ::getMapName;
		}
	
		// Reset places variables
		votes1stPlace = "";	votes1stPlaceQty = 0;
		votes2ndPlace = "";	votes2ndPlaceQty = 0;
		votes3rdPlace = "";	votes3rdPlaceQty = 0;
		
		// Get the array keys from the ballots box and start counting
		ballotKeys = getArrayKeys( ballotsBox );
		for ( key=0; key < ballotKeys.size; key++ ) {
			// Check if this key has more votes than first place
			if ( ballotsBox[ ballotKeys[key] ] > votes1stPlaceQty ) {
				// Move 2nd place to 3rd place
				votes3rdPlace = votes2ndPlace;
				votes3rdPlaceQty = votes3rdPlaceQty;
				
				// Move 1st place to 2nd place
				votes2ndPlace = votes1stPlace;
				votes2ndPlaceQty = votes1stPlaceQty;
				
				// Set the new 1st place
				votes1stPlace = ballotKeys[key];
				votes1stPlaceQty = ballotsBox[ ballotKeys[key] ];
				
			} else 	if ( ballotsBox[ ballotKeys[key] ] > votes2ndPlaceQty ) {
				// Move 2nd place to 3rd place
				votes3rdPlace = votes2ndPlace;
				votes3rdPlaceQty = votes3rdPlaceQty;
				
				// Set the second place
				votes2ndPlace = ballotKeys[key];
				votes2ndPlaceQty = ballotsBox[ ballotKeys[key] ];
			
			}	else if ( ballotsBox[ ballotKeys[key] ] > votes3rdPlaceQty ) {
				// Set the new 3rd place
				votes3rdPlace = ballotKeys[key];
				votes3rdPlaceQty = ballotsBox[ ballotKeys[key] ];
			}									
			
		}
		
		// Update players' temporary results
		level.mapVoteFirstPlace = [[translationFunction]]( votes1stPlace ) + " (" + votes1stPlaceQty + ")";
		level.mapVoteSecondPlace = [[translationFunction]]( votes2ndPlace ) + " (" + votes2ndPlaceQty + ")";
		level.mapVoteThirdPlace = [[translationFunction]]( votes3rdPlace ) + " (" + votes3rdPlaceQty + ")";
	
		for ( index = 0; index < level.players.size; index++ ) {
			player = level.players[index];
			if ( isDefined( player ) ) {
				player setClientDvars(
					"ui_amvs_firstplace", level.mapVoteFirstPlace,
					"ui_amvs_secondplace", level.mapVoteSecondPlace,
					"ui_amvs_thirdplace", level.mapVoteThirdPlace
				);
			}
		}
	}
}


countPlayerVotes()
{
	// Check which votes we should count
	if ( level.amvsWinnerGametype == "" ) {
		ballotsBox = level.scr_amvs_gametypes_votes;
	} else {
		ballotsBox = level.scr_amvs_maps_votes;
	}
	
	// Reset first place array
	winnerOptions = [];
	winnerVotes = 0;
		
	// Get the array keys from the ballots box and start counting
	ballotKeys = getArrayKeys( ballotsBox );
	for ( key=0; key < ballotKeys.size; key++ ) {
		// Check if this key has more votes than first place
		if ( ballotsBox[ ballotKeys[key] ] > winnerVotes ) {
			winnerOptions = [];
			winnerOptions[0] = ballotKeys[key];
			winnerVotes = ballotsBox[ ballotKeys[key] ];
			
		} else if ( ballotsBox[ ballotKeys[key] ] > 0 && ballotsBox[ ballotKeys[key] ] == winnerVotes ) {
			winnerOptions[ winnerOptions.size ] = ballotKeys[key];
		}
	}
	
	// If we have more than one winner we'll randomly pick one
	if ( winnerOptions.size == 0 ) {
		voteWinner = "";
		
	} else if ( winnerOptions.size == 1 ) {
		voteWinner = winnerOptions[0];
		
	} else {
		randomPick = randomIntRange( 0, winnerOptions.size );
		voteWinner = winnerOptions[randomPick];		
	}
	
	return (voteWinner);
}