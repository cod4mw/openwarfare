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

#include maps\mp\gametypes\_hud_util;

#include openwarfare\_eventmanager;
#include openwarfare\_utils;

init()
{
	// Get the main module's dvar
	level.scr_dogtags_enable = getdvarx( "scr_dogtags_enable", "int", 0, 0, 1 );

	// If dog tags are not enabled then there's nothing else to do here
	if ( level.scr_dogtags_enable == 0 )
		return;

	// Precache the dogtag shader
	precacheShader( "dogtag" );

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onPlayerKilled", ::onPlayerKilled );
	self thread onPlayerBody();
}


onPlayerSpawned()
{
	// Initialize some variables and create the HUD elements		
	self.checkingBody = false;

	self.dogTags["name"] = createFontString( "default", 1.4 );
	self.dogTags["name"].alpha = 0;
	self.dogTags["name"] setPoint( "LEFT", "LEFT", 20, 0 );
	self.dogTags["name"].hideWhenInMenu = true;
	self.dogTags["name"].archived = true;
	
	self.dogTags["image"] = createIcon( "dogtag", 16, 16 );
	self.dogTags["image"].alpha = 0;
	self.dogTags["image"] setPoint( "LEFT", "LEFT", 2, 0 );
	self.dogTags["image"].hideWhenInMenu = true;
	self.dogTags["image"].archived = true;		
	
	// Remove this player's body 
	if ( isDefined( self.body ) ) {
		self.body delete();
		self.body = undefined;
	}
	// Remove also the body trigger
	if ( isDefined( self.bodyTrigger ) ) {
		self.bodyTrigger delete();
		self.bodyTrigger = undefined;
	}
}


onPlayerKilled()
{
	// Hide the HUD elements
	if ( isDefined( self.dogTags ) ) {
		self.dogTags["image"] destroy();
		self.dogTags["name"] destroy();
	}
}


onPlayerBody()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("player_body");
		self thread dogTagMonitor();
	}
}


dogTagMonitor()
{
	self endon("spawned_player");
	self endon("disconnect");	
	level endon( "game_ended" );
	
	// Wait until the body is not moving anymore
	self.body maps\mp\gametypes\_weapons::waitTillNotMoving();
	
	// Create the trigger we'll be using for players to check the dog tags
	self.bodyTrigger = spawn( "trigger_radius", self.body.origin, 0, 32 , 32 );
	self thread removeTriggerOnDisconnect();
	
	for (;;)
	{
		wait (0.05);
		self.bodyTrigger waittill("trigger", player);
		if ( !player.checkingBody ) {
			player.checkingBody = true;
			player thread monitorCheckDogTag( self );		
		}
	}	
}


removeTriggerOnDisconnect()
{
	self endon("spawned_player");
	
	// Save the body and trigger
	body = self.body;
	bodyTrigger = self.bodyTrigger;
	
	// Wait for the player to disconnect and remove his body and trigger from the game
	self waittill("disconnect");
	
	if ( isDefined( body ) )
		body delete();
		
	if ( isDefined( bodyTrigger ) )
		bodyTrigger delete();	
}


monitorCheckDogTag( deadPlayer )
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );
	
	// Stay here as long as the body exists and the player is touching it
	while ( isDefined( self ) && isDefined( deadPlayer.body ) && self isTouching( deadPlayer.bodyTrigger ) ) {
		wait (0.05);
		
		// Check if the player is crouched or proned
		if ( isDefined( self ) && ( self getStance() == "crouch" || self getStance() == "prone" ) ) {
			// Update the information with the dead player's name and show the HUD elements
			self.dogTags["name"] setPlayerNameString( deadPlayer );
			self.dogTags["name"] fadeOverTime(1); self.dogTags["image"] fadeOverTime(1);
			self.dogTags["name"].alpha = 1;	self.dogTags["image"].alpha = 1;
			
			// Wait for the body to be removed, player leaving the trigger zone or player is not crouched or proned
			while ( isDefined( self ) && isDefined( deadPlayer.body ) && self isTouching( deadPlayer.bodyTrigger ) && ( self getStance() == "crouch" || self getStance() == "prone" ) )
				wait (0.05);
				
			// Hide the HUD elements
			if ( isDefined( self ) )
				self.dogTags["name"].alpha = 0;	self.dogTags["image"].alpha = 0;			
		}		
	}

	// Body is not there or the player is not touching the trigger anymore	
	self.checkingBody = false;	
}