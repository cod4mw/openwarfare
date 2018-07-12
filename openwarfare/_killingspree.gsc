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
	// Get the main module's dvars
	level.scr_killingspree_enable = getdvarx( "scr_killingspree_enable", "int", 0, 0, 1 );
	level.scr_unreal_headshot_sound = getdvarx( "scr_unreal_headshot_sound", "int", 0, 0, 1 );
	level.scr_unreal_firstblood_sound = getdvarx( "scr_unreal_firstblood_sound", "int", 0, 0, 1 );

	// If killing spree sounds are not enabled then there's nothing to do here
	if ( level.scr_killingspree_enable == 0 && level.scr_unreal_headshot_sound == 0 && level.scr_unreal_firstblood_sound == 0 )
		return;

	// Load the kills/sounds to be used
	if ( level.scr_killingspree_enable == 1 ) {
		killingSprees = getdvarx( "scr_killingspree_sounds", "string", "2 doublekill;5 killingspree;7 rampage;9 dominating;12 unstoppable;15 godlike" );
		killingSprees = strtok( killingSprees, ";" );
		level.scr_killingspree_kills = [];
		level.scr_killingspree_sounds = [];
		for ( iSpree = 0; iSpree < killingSprees.size; iSpree++ ) {
			thisSpree = strtok( killingSprees[ iSpree ], " " );
			level.scr_killingspree_kills[ iSpree ] = int( thisSpree[0] );
			level.scr_killingspree_sounds[ iSpree ] = thisSpree[1];
		}
	}

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread onPlayerKillStreak();
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}


onPlayerSpawned()
{
	self.killingSpree = 0;
}

onPlayerKillStreak()
{
	self endon("disconnect");
	level endon( "game_ended" );

	for(;;)
	{
		self waittill("kill_streak", killStreak, streakGiven, sMeansOfDeath );
		playedSound = false;

		// Check if we need to play first blood sound 
		if ( level.scr_unreal_firstblood_sound == 1 && !playedSound && !isDefined( level.firstBlood ) ) {
			playedSound = true;
			level.firstBlood = true;
			self playLocalSound( "firstblood" );
		}
		
		// Check if we need to play a sound for killing spree
		if ( level.scr_killingspree_enable == 1 && streakGiven && !playedSound ) {
			killingSpree = 0;
			while ( killingSpree < level.scr_killingspree_kills.size && level.scr_killingspree_kills[ killingSpree ] != killStreak )
				killingSpree++;
	
			// Check if we found a match and play the corresponding sound
			if ( killingSpree < level.scr_killingspree_kills.size ) {
				self playLocalSound( level.scr_killingspree_sounds[ killingSpree ] );
				playedSound = true;
			}
		}
		
		// Check if we need to play headshot sound
		if ( level.scr_unreal_headshot_sound == 1 && !playedSound && sMeansOfDeath == "MOD_HEAD_SHOT" ) {
			playedSound = true;
			self playLocalSound( "headshot" );
		}				
	}
}