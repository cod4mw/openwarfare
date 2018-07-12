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
	level.scr_blackscreen_enable = getdvarx( "scr_blackscreen_enable", "int", 0, 0, 1 );
	
	level.scr_blackscreen_spectators = getdvarx( "scr_blackscreen_spectators", "int", 0, 0, 1 );
	level.scr_blackscreen_spectators_guids = getdvarx( "scr_blackscreen_spectators_guids", "string", level.scr_server_overall_admin_guids );

	// If the black screen is not enabled then there's nothing to do here
	if ( level.scr_blackscreen_enable == 0 && level.scr_blackscreen_spectators == 0 )
		return;
		
	/// Check if we should precache the shader
	if ( level.scr_blackscreen_spectators == 1 || level.numlives ) {
		precacheShader( "clanlogo" );
	}

	// Get the rest of the module's dvars
	level.scr_blackscreen_fadetime = getdvarx( "scr_blackscreen_fadetime", "float", 0, 0, 60 );

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onJoinedSpectators", ::onJoinedSpectators );
	
	if ( level.scr_blackscreen_enable == 1 ) {
		self thread addNewEvent( "onPlayerDeath", ::onPlayerDeath );
	}
	
	if ( level.scr_blackscreen_spectators == 1 && !isSubstr( level.scr_blackscreen_spectators_guids, self getGUID() ) ) {
		self createBlackScreen();
	}
}


onJoinedSpectators()
{
	// Destroy the screen if the player when into spectating mode and spectators blackscreen is disabled
	if ( isDefined( self.blackscreen ) && level.scr_blackscreen_spectators == 0 ) {
		if ( isDefined( self.blackscreen ) ) {
			self.blackscreen destroy();
		}
		if ( isDefined( self.blackscreen2 ) ) {
			self.blackscreen2 destroy();
		}
		if ( isDefined( self.clanlogo ) ) {
			self.clanlogo destroy();
		}
		if ( isDefined( self.nextround ) ) {
			self.nextround destroy();
		}

	// Destroy the screen if the person joined the spectators and he is allowed to see the game
	} else if ( isDefined( self.blackscreen ) && level.scr_blackscreen_spectators == 1 && isSubstr( level.scr_blackscreen_spectators_guids, self getGUID() ) ) {
		if ( isDefined( self.blackscreen ) ) {
			self.blackscreen destroy();
		}
		if ( isDefined( self.blackscreen2 ) ) {
			self.blackscreen2 destroy();
		}
		if ( isDefined( self.clanlogo ) ) {
			self.clanlogo destroy();
		}
		if ( isDefined( self.nextround ) ) {
			self.nextround destroy();
		}
			
	} else if ( level.scr_blackscreen_spectators == 1 && !isSubstr( level.scr_blackscreen_spectators_guids, self getGUID() ) ) {
		self createBlackScreen();		
	}
}


onPlayerSpawned()
{
	// Check if the element is already defined and destroy it
	if ( isDefined( self.blackscreen ) ) {
		self.blackscreen destroy();
	}
	if ( isDefined( self.blackscreen2 ) ) {
		self.blackscreen2 destroy();
	}
	if ( isDefined( self.clanlogo ) ) {
		self.clanlogo destroy();
	}
	if ( isDefined( self.nextround ) ) {
		self.nextround destroy();
	}
}


onPlayerDeath()
{
	self endon("disconnect");
	
	// Only blackout the screen if the player is not spectator and we are not in the ready-up period
	if ( self.pers["team"] != "spectator" && !level.inReadyUpPeriod ) {
		self createBlackScreen();
	
		// Check if we need to fade it
		if ( level.scr_blackscreen_spectators == 0 || !level.numlives || self.pers["lives"] ) {
			if ( level.scr_blackscreen_fadetime != 0 ) {
				xWait( level.scr_blackscreen_fadetime );
				if ( self.pers["team"] != "spectator" ) {
					if ( isDefined( self.blackscreen ) ) {
						self.blackscreen fadeOverTime(3);
						self.blackscreen.alpha = 0;
					}
					if ( isDefined( self.blackscreen2 ) ) {
						self.blackscreen2 fadeOverTime(3);
						self.blackscreen2.alpha = 0;
					}
					if ( isDefined( self.clanlogo ) ) {
						self.clanlogo fadeOverTime(3);
						self.clanlogo.alpha = 0;						
					}
					if ( isDefined( self.nextround ) ) {
						self.nextround fadeOverTime(3);
						self.nextround.alpha = 0;						
					}					
				}
			}
		}
	}			
}


createBlackScreen()
{
	// We show the logo on the last live or if the player is spectator
	if ( !isDefined( self.clanlogo ) && ( ( level.numlives && !self.pers["lives"] ) || ( level.scr_blackscreen_spectators == 1 && self.pers["team"] == "spectator" ) ) ) {
		self.clanlogo = newClientHudElem( self );
		self.clanlogo.x = 0;
		self.clanlogo.y = -20;
		self.clanlogo.alignX = "center";
		self.clanlogo.alignY = "middle";
		self.clanlogo.horzAlign = "center";
		self.clanlogo.vertAlign = "middle";
		self.clanlogo.sort = -3;
		self.clanlogo.archived = false;
		self.clanlogo setShader( "clanlogo", 400, 200 );	
		self.clanlogo.alpha = 1;
	}
	
	if ( self.pers["team"] != "spectator" && !isDefined( self.nextround ) && level.numlives && !self.pers["lives"] ) {
		self.nextround = createFontString( "default", 2.6 );
		self.nextround.archived = false;
		self.nextround.hideWhenInMenu = true;
		self.nextround.alignX = "center";
		self.nextround.alignY = "top";
		self.nextround.horzAlign = "center";
		self.nextround.vertAlign = "top";
		self.nextround.sort = -1;
		self.nextround.x = 0;
		self.nextround.y = 86;
		self.nextround.alpha = 1;
		self.nextround.color = ( 1, 1, 0 );
		self.nextround setText( game["strings"]["spawn_next_round"] );
	}	
	
	// Create the hud elements will be using for the black out
	if ( !isDefined( self.blackscreen ) ) {
		self.blackscreen = newClientHudElem( self );
		self.blackscreen.x = 0;
		self.blackscreen.y = 0;
		self.blackscreen.alignX = "left";
		self.blackscreen.alignY = "top";
		self.blackscreen.horzAlign = "fullscreen";
		self.blackscreen.vertAlign = "fullscreen";
		self.blackscreen.sort = -5;
		self.blackscreen.color = (0,0,0);
		self.blackscreen.archived = false;
		self.blackscreen setShader( "black", 640, 480 );	
		self.blackscreen.alpha = 1;
	}
	
	if ( !isDefined( self.blackscreen2 ) ) {	
		self.blackscreen2 = newClientHudElem( self );
		self.blackscreen2.x = 0;
		self.blackscreen2.y = 0;
		self.blackscreen2.alignX = "left";
		self.blackscreen2.alignY = "top";
		self.blackscreen2.horzAlign = "fullscreen";
		self.blackscreen2.vertAlign = "fullscreen";
		self.blackscreen2.sort = -4;
		self.blackscreen2.color = (0,0,0);
		self.blackscreen2.archived = false;
		self.blackscreen2 setShader( "black", 640, 480 );	
		self.blackscreen2.alpha = 1;		
	}
}