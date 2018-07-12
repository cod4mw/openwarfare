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

eventManagerInit()
{
	level.eventManager = [];
	
	// Initialize level based arrays
	level.eventManager["onPlayerConnecting"] = [];
	level.eventManager["onPlayerConnected"] = [];
	
	// Initialize player based arrays
	level.eventManager["onPlayerSpawned"] = [];
	level.eventManager["onPlayerDeath"] = [];
	level.eventManager["onPlayerKilled"] = [];
	level.eventManager["onJoinedTeam"] = [];
	level.eventManager["onJoinedSpectators"] = [];
	
	// Start the level based threads
	level thread eventManagerOnPlayerConnecting();
	level thread eventManagerOnPlayerConnected();		
}


eventManagerOnPlayerConnecting()
{
	for(;;)
	{
		level waittill( "connecting", player );
		// Run the "onConnecting" functions
		for ( event=0; event < level.eventManager["onPlayerConnecting"].size; event++ ) {
			player thread [[level.eventManager["onPlayerConnecting"][event]]]();
		}
	}	
}


eventManagerOnPlayerConnected()
{
	for(;;)
	{
		level waittill( "connected", player );

		// Initialize arrays for this player
		entityNumber = player getEntityNumber();
		level.eventManager["onPlayerSpawned"][entityNumber] = [];
		level.eventManager["onPlayerDeath"][entityNumber] = [];
		level.eventManager["onPlayerKilled"][entityNumber] = [];
		level.eventManager["onJoinedTeam"][entityNumber] = [];
		level.eventManager["onJoinedSpectators"][entityNumber] = [];	
		
		// Run the "onConnected" functions
		for ( event=0; event < level.eventManager["onPlayerConnected"].size; event++ ) {
			player thread [[level.eventManager["onPlayerConnected"][event]]]();
		}	
		
		// Start the player based threads
		player thread eventManagerOnPlayerSpawned( entityNumber );
		player thread eventManagerOnPlayerDeath( entityNumber );
		player thread eventManagerOnPlayerKilled( entityNumber );
		player thread eventManagerOnJoinedTeam( entityNumber );
		player thread eventManagerOnJoinedSpectators( entityNumber );
	}	
}


eventManagerOnPlayerSpawned( entityNumber )
{
	self endon("disconnect");
	
	for (;;)
	{
		self waittill("spawned_player");
		// Run the "onPlayerSpawned" functions
		for ( event=0; event < level.eventManager["onPlayerSpawned"][entityNumber].size; event++ ) {
			self thread [[level.eventManager["onPlayerSpawned"][entityNumber][event]]]();
		}	
	}
}


eventManagerOnPlayerDeath( entityNumber )
{
	self endon("disconnect");
	
	for (;;)
	{
		self waittill("death");
		// Run the "onPlayerDeath" functions
		for ( event=0; event < level.eventManager["onPlayerDeath"][entityNumber].size; event++ ) {
			self thread [[level.eventManager["onPlayerDeath"][entityNumber][event]]]();
		}	
	}
}


eventManagerOnPlayerKilled( entityNumber )
{
	self endon("disconnect");
	
	for (;;)
	{
		self waittill("killed_player");
		// Run the "onPlayerKilled" functions
		for ( event=0; event < level.eventManager["onPlayerKilled"][entityNumber].size; event++ ) {
			self thread [[level.eventManager["onPlayerKilled"][entityNumber][event]]]();
		}	
	}
}


eventManagerOnJoinedTeam( entityNumber )
{
	self endon("disconnect");
	
	for (;;)
	{
		self waittill("joined_team");
		// Run the "onJoinedTeam" functions
		for ( event=0; event < level.eventManager["onJoinedTeam"][entityNumber].size; event++ ) {
			self thread [[level.eventManager["onJoinedTeam"][entityNumber][event]]]();
		}	
	}
}


eventManagerOnJoinedSpectators( entityNumber )
{
	self endon("disconnect");
	
	for (;;)
	{
		self waittill("joined_spectators");
		// Run the "onJoinedSpectators" functions
		for ( event=0; event < level.eventManager["onJoinedSpectators"][entityNumber].size; event++ ) {
			self thread [[level.eventManager["onJoinedSpectators"][entityNumber][event]]]();
		}	
	}
}


addNewEvent( eventType, functionPointer )
{
	// Check if we support the event type
	if ( isDefined( level.eventManager[eventType] ) ) {	
		// Check if this event is player related or not
		if ( isPlayer( self ) ) {
			entityNumber = self getEntityNumber();
			level.eventManager[eventType][entityNumber][level.eventManager[eventType][entityNumber].size] = functionPointer;		
		}	else {
			level.eventManager[eventType][level.eventManager[eventType].size] = functionPointer;
		}
	}
}