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
	level.scr_livebroadcast_enable = getdvarx( "scr_livebroadcast_enable", "int", 0, 0, 1 );
	level.scr_livebroadcast_guids = getdvarx( "scr_livebroadcast_guids", "string", level.scr_server_overall_admin_guids );

	// We start this thread anyway so we can populate the internal value for broadcasters
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );

	// If the black screen is not enabled then there's nothing to do here
	if ( level.scr_livebroadcast_enable == 0 || level.scr_livebroadcast_guids == "" )
		return;
		
	level.scr_scoreboard_marshal_guids = getdvard( "scr_scoreboard_marshal_guids", "string", level.scr_server_overall_admin_guids );
	
	precacheStatusIcon( "hud_status_broadcaster" );
}


onPlayerConnected()
{
	// If there's no active ruleset we'll display the server's name instead
	if ( level.scr_league_ruleset != "" ) {
		rulesetInfo = level.scr_league_ruleset;
	} else {
		rulesetInfo = getDvar( "sv_hostname" );
	}		
		
	// Check if this player is a broadcaster
	if ( level.scr_livebroadcast_enable == 1 && isSubstr( level.scr_livebroadcast_guids, self getGUID() ) ) {
		self.pers["broadcaster"] = true;
		self setClientDvars( 
			"cg_drawSpectatorMessages", "1",
			"ui_broadcaster", "1",
			"lb_maxhealth", level.maxhealth,
			"lb_round", game["roundsplayed"]+1,
			"lb_ruleset", rulesetInfo
		);
		
		// Dummy data population for screen design purposes
		// self thread sendDummyData();
		
		// Start live broadcasting for this broadcaster
		self thread liveBroadcastGame();
		
		// We display the scoreboard icon for the broadcasters
		self thread showBroadcasterScoreboardIcon();

	} else {
		self.pers["broadcaster"] = false;
		self setClientDvars( 
			"cg_drawSpectatorMessages", "1",
			"ui_broadcaster", "0"
		);
	}	
}


showBroadcasterScoreboardIcon()
{
	self endon("disconnect");
	
	// If this player is also a marshal then we don't try to display this icon
	if ( level.scr_scoreboard_marshal_guids != "" && isSubstr( level.scr_scoreboard_marshal_guids, ""+self getGUID() ) )
		return;
	
	for (;;) {
		wait(1);

		// Check if we can set the broadcaster icon for this player as it might have changed if the player is playing and not spectating
		if ( isDefined( self.pers["team"] ) && self.pers["team"] == "spectator" && self.statusicon == "" ) {
			self.statusicon = "hud_status_broadcaster";
			
		} else if ( isDefined( self.pers["team"] ) && self.pers["team"] != "spectator" && self.statusicon == "hud_status_broadcaster" ) {
			self.statusicon = "";
		}
	}
}


liveBroadcastGame()
{
	self endon("disconnect");
	level endon("game_ended");
	
	// Initialize tracker array so we only send the things that changed and nothing more
	maxPlayersPerTeam = 12;
	statusTracker = [];
	
	for (;;)
	{
		// We stop refreshing player status during a time out
		xwait(0.25);
		
		// Do not update anything if the player is not playing
		if ( !isDefined( self.pers["team"] ) || self.pers["team"] != "spectator" )
			continue;

		// Init variables for this cycle
		statusChanged = [];
		
		teamPlayers = [];
		teamPlayers["allies"] = 0;
		teamPlayers["axis"] = 0;

		// Check and save status of all the players in the server	
		for ( index = 0; index < level.players.size; index++ ) {
			
			player = level.players[index];
			team = player.pers["team"];
			
			// We are only interested in the players assigned to a team
			if ( team == "allies" || team == "axis" ) {
				// Make sure we still have a free slot in this team
				if ( teamPlayers[team] < maxPlayersPerTeam ) {
					teamPlayers[team]++;
					
					// Check if this player's name has changed
					if ( !isDefined( statusTracker["lb_"+team+"_p"+teamPlayers[team]] ) || statusTracker["lb_"+team+"_p"+teamPlayers[team]] != player.name ) {
						statusTracker["lb_"+team+"_p"+teamPlayers[team]] = player.name;
						newElement = statusChanged.size;
						statusChanged[newElement]["name"] = "lb_"+team+"_p"+teamPlayers[team];
						statusChanged[newElement]["value"] = player.name;
					}
					// Check if this player's health has changed
					if ( !isDefined( statusTracker["lb_"+team+"_h"+teamPlayers[team]] ) || statusTracker["lb_"+team+"_h"+teamPlayers[team]] !=  player.health ) {
						statusTracker["lb_"+team+"_h"+teamPlayers[team]] = player.health;
						newElement = statusChanged.size;
						statusChanged[newElement]["name"] = "lb_"+team+"_h"+teamPlayers[team];
						statusChanged[newElement]["value"] = player.health;
					}					
				}
			}
		}
		
		// Complete the arrays just in case players have disconnected
		teamKeys = getArrayKeys( teamPlayers );
		for ( index = 0; index < teamKeys.size; index++ ) {
			team = teamKeys[index];
			
			for ( slot = teamPlayers[team]; slot < maxPlayersPerTeam; slot++ ) {
				teamPlayers[team]++;
				
				// Check if this player slot used to be assigned
				if ( !isDefined( statusTracker["lb_"+team+"_p"+teamPlayers[team]] ) || statusTracker["lb_"+team+"_p"+teamPlayers[team]] != "" ) {
					statusTracker["lb_"+team+"_p"+teamPlayers[team]] = "";
					newElement = statusChanged.size;
					statusChanged[newElement]["name"] = "lb_"+team+"_p"+teamPlayers[team];
					statusChanged[newElement]["value"] = "";
	
					statusTracker["lb_"+team+"_h"+teamPlayers[team]] = 0;
					newElement = statusChanged.size;
					statusChanged[newElement]["name"] = "lb_"+team+"_h"+teamPlayers[team];
					statusChanged[newElement]["value"] = 0;
				}
			}
		}

		// Check if we have any new status to send
		if ( statusChanged.size > 0 ) {
			
			// Because we make calls sending up to 16 variables at the same time for performance
			// reasons we need to complete the array with dummy variables
			addDummy = 10 - ( statusChanged.size % 10 );
			if ( addDummy != 10 ) {
				for ( i = 0; i < addDummy; i++ ) {
					newElement = statusChanged.size;
					statusChanged[newElement]["name"] = "dv"+i;
					statusChanged[newElement]["value"] = "";
				}
			}
			
			// Calculate how many cycles we'll need to send all the variables
			sendCycles = int( statusChanged.size / 10 );
			
			// Send the updates to the current broadcaster
			for ( cycle = 0; cycle < sendCycles; cycle++ ) {
				firstElement = 10 * cycle;
				
				// Send this cycle
				self setClientDvars(
					statusChanged[ firstElement + 0 ]["name"], statusChanged[ firstElement + 0 ]["value"],
					statusChanged[ firstElement + 1 ]["name"], statusChanged[ firstElement + 1 ]["value"],
					statusChanged[ firstElement + 2 ]["name"], statusChanged[ firstElement + 2 ]["value"],
					statusChanged[ firstElement + 3 ]["name"], statusChanged[ firstElement + 3 ]["value"],
					statusChanged[ firstElement + 4 ]["name"], statusChanged[ firstElement + 4 ]["value"],
					statusChanged[ firstElement + 5 ]["name"], statusChanged[ firstElement + 5 ]["value"],
					statusChanged[ firstElement + 6 ]["name"], statusChanged[ firstElement + 6 ]["value"],
					statusChanged[ firstElement + 7 ]["name"], statusChanged[ firstElement + 7 ]["value"],
					statusChanged[ firstElement + 8 ]["name"], statusChanged[ firstElement + 8 ]["value"],
					statusChanged[ firstElement + 9 ]["name"], statusChanged[ firstElement + 9 ]["value"]
				);
				
				// We only wait if we need to send another set of variables to this client
				if ( (cycle+1) < sendCycles ) {
					wait(0.1);
				}
			}		
		}
	}
}



sendDummyData()
{
	self setClientDvars(
		"lb_allies_p1", "Captain Crandal",
		"lb_allies_h1", "100",
		"lb_allies_p2", "Governor Kevin",
		"lb_allies_h2", "90",
		"lb_allies_p3", "The Chief",
		"lb_allies_h3", "95",
		"lb_allies_p4", "Mr. Paulson",
		"lb_allies_h4", "100",
		"lb_allies_p5", "Captain Excellent",
		"lb_allies_h5", "100",
		"lb_allies_p6", "Viva Voom",
		"lb_allies_h6", "20",
		"lb_allies_p7", "Earth Mom",
		"lb_allies_h7", "0",
		"lb_allies_p8", "Skate Lad",
		"lb_allies_h8", "78",
		"lb_allies_p9", "Gordon",
		"lb_allies_h9", "100",
		"lb_allies_p10", "Diaper Dude",
		"lb_allies_h10", "100",
		"lb_allies_p11", "Patience",
		"lb_allies_h11", "47",
		"lb_allies_p12", "The Comedian",
		"lb_allies_h12", "65"				
	);
	wait(0.1);
	
	self setClientDvars(
		"lb_axis_p1", "Baron Blitz",
		"lb_axis_h1", "100",
		"lb_axis_p2", "Captain Crandall",
		"lb_axis_h2", "90",
		"lb_axis_p3", "Chopper Daddy",
		"lb_axis_h3", "95",
		"lb_axis_p4", "Scooter Lad",
		"lb_axis_h4", "100",
		"lb_axis_p5", "Birthday Bandit",
		"lb_axis_h5", "100",
		"lb_axis_p6", "Madam Snake",
		"lb_axis_h6", "20",
		"lb_axis_p7", "Mr. Large",
		"lb_axis_h7", "0",
		"lb_axis_p8", "Helius Inflato",
		"lb_axis_h8", "78",
		"lb_axis_p9", "Laser Pirate",
		"lb_axis_h9", "100",
		"lb_axis_p10", "The Gauntlet",
		"lb_axis_h10", "100",
		"lb_axis_p11", "Hypnotheria",
		"lb_axis_h11", "47",
		"lb_axis_p12", "Dehydro",
		"lb_axis_h12", "65"		
	);
}