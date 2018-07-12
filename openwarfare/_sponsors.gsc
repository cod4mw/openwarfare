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
#include maps\mp\gametypes\_hud_util;

#include openwarfare\_eventmanager;
#include openwarfare\_utils;

init()
{
	// Get the main module's dvar
	level.scr_sponsor_enable = getdvarx( "scr_sponsor_enable", "int", 0, 0, 4 );

	// If sponsors are not enabled then there's nothing else to do here
	if ( level.scr_sponsor_enable == 0 )
		return;

	// Get the module's dvars
	level.scr_sponsor_time = getdvarx( "scr_sponsor_time", "int", 15, 5, 60 );
	level.scr_sponsor_interval = getdvarx( "scr_sponsor_interval", "int", 30, 5, 120 );
	
	level.scr_sponsor_logos = getDvarListx( "scr_sponsor_logo_", "string", "" );
	if ( level.scr_sponsor_logos.size == 0 )
		return;
		
	// Re-arrange the information into an array
	for ( iLogo = 0; iLogo < level.scr_sponsor_logos.size; iLogo++ ) {
		logoInformation = strtok( level.scr_sponsor_logos[iLogo], ";" );
		level.scr_sponsor_logos[iLogo] = [];
		level.scr_sponsor_logos[iLogo]["image"] = logoInformation[0];
		level.scr_sponsor_logos[iLogo]["width"] = int(logoInformation[1]);
		level.scr_sponsor_logos[iLogo]["height"] = int(logoInformation[2]);
		level.scr_sponsor_logos[iLogo]["origin"] = logoInformation[3];
		
		// Check if this one should be a negative shift
		if ( logoInformation[3] == "right" || logoInformation[3] == "bottom" ) {
			level.scr_sponsor_logos[iLogo]["shift"] = int(logoInformation[4]) * -1;
		} else if ( logoInformation[3] == "left" || logoInformation[3] == "top" ) {
			level.scr_sponsor_logos[iLogo]["shift"] = int(logoInformation[4]);
		} else {
			level.scr_sponsor_logos[iLogo]["shift"] = 0;
		}
	}

	// Precache shaders
	for ( iLogo = 0; iLogo < level.scr_sponsor_logos.size; iLogo++ ) {
		precacheShader( level.scr_sponsor_logos[iLogo]["image"] );
	}

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread onPlayerSpawned();
	
	if ( level.scr_sponsor_enable == 3 ) {
		self thread rotateSponsors();
		
		self thread addNewEvent( "onJoinedSpectators", ::onJoinedSpectators );
	}
}


onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");
		self thread rotateSponsors();	

		// Check if we are supposed to show the sponsors only once
		if ( level.scr_sponsor_enable == 2 || level.scr_sponsor_enable == 3 )
			break;
	}	
}


onJoinedSpectators()
{
	self thread rotateSponsors();	
}


rotateSponsors()
{
	self endon("disconnect");

	// Check if this thread can run at this point or if it's already running
	if ( level.scr_sponsor_enable == 1 && !level.inReadyUpPeriod )
		return;
		
	if ( isDefined( self.sponsorsActive ) && self.sponsorsActive )
		return;
		
	self.sponsorsActive = true;
	wait ( level.scr_sponsor_time );
	
	// Create the HUD element to display the sponsors' logos
	sponsorLogo = newClientHudElem( self );
	sponsorLogo.x = 0;
	sponsorLogo.y = 0;	
	sponsorLogo.archived = false;
	sponsorLogo.hideWhenInMenu = true;
	sponsorLogo.sort = 1000;
	
	iLogo = 0;
	while ( isDefined( self ) && game["state"] != "postgame" && ( ( level.scr_sponsor_enable == 1 && level.inReadyUpPeriod ) || level.scr_sponsor_enable == 2 || ( level.scr_sponsor_enable == 3 && self.pers["team"] == "spectator" ) || level.scr_sponsor_enable == 4 ) ) {
		// Setup logo's origin
		switch ( level.scr_sponsor_logos[iLogo]["origin"] ) {
			case "top":
				sponsorLogo.alignX = "center";
				sponsorLogo.alignY = "bottom";
				sponsorLogo.horzAlign = "center";
				sponsorLogo.vertAlign = "top";
				break;
			case "right":
				sponsorLogo.alignX = "left";
				sponsorLogo.alignY = "middle";
				sponsorLogo.horzAlign = "right";
				sponsorLogo.vertAlign = "middle";
				break;	
			case "bottom":
				sponsorLogo.alignX = "center";
				sponsorLogo.alignY = "top";
				sponsorLogo.horzAlign = "center";
				sponsorLogo.vertAlign = "bottom";
				break;	
			case "left":
				sponsorLogo.alignX = "right";
				sponsorLogo.alignY = "middle";
				sponsorLogo.horzAlign = "left";
				sponsorLogo.vertAlign = "middle";
				break;
			case "center":
				sponsorLogo.alignX = "center";
				sponsorLogo.alignY = "middle";
				sponsorLogo.horzAlign = "center";
				sponsorLogo.vertAlign = "middle";				
		}		
		
		// Check if we just show this one
		if ( level.scr_sponsor_logos[iLogo]["origin"] == "center" ) {
			sponsorLogo.alpha = 0;
		} else {
			sponsorLogo.alpha = 0.9;
		}
		
		// Set the image for the logo
		sponsorLogo setShader( level.scr_sponsor_logos[iLogo]["image"], level.scr_sponsor_logos[iLogo]["width"], level.scr_sponsor_logos[iLogo]["height"]);
		
		// Show the logo on screen
		if ( level.scr_sponsor_logos[iLogo]["origin"] == "center" ) {
			sponsorLogo fadeOverTime(1);
			sponsorLogo.alpha = 0.9;
		} else {
			sponsorLogo moveOverTime(1);
			if ( level.scr_sponsor_logos[iLogo]["origin"] == "top" || level.scr_sponsor_logos[iLogo]["origin"] == "bottom" ) {
				sponsorLogo.y = level.scr_sponsor_logos[iLogo]["shift"];
			} else {
				sponsorLogo.x = level.scr_sponsor_logos[iLogo]["shift"];
			}
		}
		
		// Hide the logo back in scr_sponsor_time seconds
		waitEnds = gettime() + ( level.scr_sponsor_time + 1 ) * 1000;
		while ( game["state"] != "postgame" && waitEnds > gettime() && ( ( level.scr_sponsor_enable == 1 && level.inReadyUpPeriod ) || level.scr_sponsor_enable == 2 || ( level.scr_sponsor_enable == 3 && self.pers["team"] == "spectator" ) || level.scr_sponsor_enable == 4 ) )
			wait (0.05);
			
		// Hide the logo back
		if ( level.scr_sponsor_logos[iLogo]["origin"] == "center" ) {
			sponsorLogo fadeOverTime(1);
			sponsorLogo.alpha = 0;			
		} else {
			sponsorLogo moveOverTime(1);
			if ( level.scr_sponsor_logos[iLogo]["origin"] == "top" || level.scr_sponsor_logos[iLogo]["origin"] == "bottom" ) {
				sponsorLogo.y = 0;
			} else {
				sponsorLogo.x = 0;
			}
		}

		// Move to the next logo	
		iLogo++;
		if ( iLogo == level.scr_sponsor_logos.size ) {
			if ( level.scr_sponsor_enable == 2 || level.scr_sponsor_enable == 4 ) {
				break;
			}
			iLogo = 0;
		}
		
		// Wait for the proper interval to show the next sponsor's logo
		waitEnds = gettime() + ( level.scr_sponsor_interval + 1 ) * 1000;
		while ( game["state"] != "postgame" && waitEnds > gettime() && ( ( level.scr_sponsor_enable == 1 && level.inReadyUpPeriod ) || level.scr_sponsor_enable == 2 || ( level.scr_sponsor_enable == 3 && self.pers["team"] == "spectator" ) || level.scr_sponsor_enable == 4 ) )
			wait (0.05);
	}
	
	// Destroy the HUD element
	wait (1);
	sponsorLogo destroy();
	if ( isDefined( self ) )
		self.sponsorsActive = false;	
}