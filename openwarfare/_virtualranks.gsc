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
	level.scr_enable_virtual_ranks = getdvarx( "scr_enable_virtual_ranks", "int", 0, 0, 2 );
	level.maxRank = int(tableLookup( "mp/rankTable.csv", 0, "maxrank", 1 ));
	
	// If virtual ranks are disabled then there's nothing else to do here
	if ( level.rankedMatch || level.scr_server_rank_type == 2 || level.scr_enable_virtual_ranks == 0 || level.gametype == "gg" ) {
		level.scr_enable_virtual_ranks = 0;
		return;
	}

	if ( level.scr_enable_virtual_ranks == 1 ) {
		level thread loadVirtualRanks();
		
	} else if ( level.scr_enable_virtual_ranks == 2 ) {
		level.scr_virtual_ranks_score = getdvarx( "scr_virtual_ranks_score", "int", 50, 1, 10000 );
		level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );	
	}
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}	


onPlayerSpawned()
{
	self thread monitorPlayerScore();	
}


monitorPlayerScore()
{
	self endon("disconnect");
	self endon("death");
	
	playerRank = -1;
	
	for (;;)
	{
		// Get the player's rank based on score
		newPlayerRank = self getRankForScore();
		
		// If the new rank if different than the current one update it
		if ( newPlayerRank != playerRank ) {
			playerRank = newPlayerRank;
			self setRank( playerRank );
		}		
		
		wait (1.0);
	}	
}


getRankForScore()
{
	// Get the current player rank based on his/her score
	playerRank = int( self.pers["score"] / level.scr_virtual_ranks_score );
	if ( playerRank > level.maxRank )
		playerRank = level.maxRank;
		
	return playerRank;	
}


loadVirtualRanks()
{
	// Get the virtual ranks
	// Syntax is "<text>=<level>;<text>=<level>;..."
	virtualRanks = getdvarx( "scr_virtual_ranks", "string", "Pfc.=3;LCpl.=6;Cpl.=9;Sgt.=12;SSgt.=15;GySgt.=18;MSgt.=21;MGySgt.=24;2ndLt.=27;1stLt.=30;Capt.=33;Maj.=36;LtCol.=39;Col.=42;BGen.=45;MajGen.=48;LtGen.=51;Gen.=54;CDR.=55" );

	// Split the ranks
	virtualRanks = strtok( virtualRanks, ";" );

	// Load the ranks into an array
	level.virtualRanks = [];
	for ( rankix = 0; rankix < virtualRanks.size; rankix++ )
	{
		// Split the rank text and the rank level
		thisRank = strtok( virtualRanks[ rankix ], "=" );

		// First element is the rank text and second element is the rank level
		level.virtualRanks[ level.virtualRanks.size ]["rank"] = thisRank[0];
		level.virtualRanks[ level.virtualRanks.size ]["level"] = int(thisRank[1]) -  1;
	}

	return;
}


getRankForName( player )
{
	if ( level.scr_enable_virtual_ranks != 1 )
		return (level.maxRank + 1);

	// Loop through the ranks and return on the first match
	for ( rankix = 0; rankix < level.virtualRanks.size; rankix += 2 )
	{
		// Check if we have a match and return the corresponding rank level if there is
		if ( issubstr( player.name, level.virtualRanks[rankix]["rank"] ) ) {
			return level.virtualRanks[rankix+1]["level"];
		}
	}

	// We couldn't find any matching rank so we return a higher rank than the supported by the game 
	return (level.maxRank + 1);
}