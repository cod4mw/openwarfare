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
	level.sv_enable_server_banners = getdvarx( "sv_enable_server_banners", "int", 0, 0, 1 );

	level.serverBanners = getDvarListx( "sv_server_banner_", "string", "" );

	if ( (level.sv_enable_server_banners == 0 || level.serverBanners.size == 0) && level.scr_league_ruleset == "" )
		return;

	// Get the module's dvars
	level.sv_server_banners_delay = getdvarx( "sv_server_banners_delay", "int", 10, 1, 600 );
	level.sv_server_banners_time = getdvarx( "sv_server_banners_time", "int", 0, 0, 600 );

	addNewEvent( "onPlayerConnected", ::displayServerBanners );
}

displayServerBanner( bannerMessage )
{
	self.hud_server_banner setText( bannerMessage );

	self.hud_server_banner fadeOverTime(1);
	self.hud_server_banner.alpha = 1;

	// Check how long we should show this banner
	if ( level.sv_server_banners_time != 0 ) {
		wait ( level.sv_server_banners_time - 1 );
	} else {
		wait ( level.sv_server_banners_delay - 1 );
	}

	self.hud_server_banner fadeOverTime(1);
	self.hud_server_banner.alpha = 0;
	wait (1);
	
	// Check if we should wait to show the next one
	if ( level.sv_server_banners_time != 0 ) {
		wait ( level.sv_server_banners_delay );
	}	
}

displayServerBanners() {
	self endon("disconnect");

	// Create the new HUD element
	if ( isDefined( self.hud_server_banner ) )
		self.hud_server_banner destroy();

	// Set some standard values
	self.hud_server_banner = createFontString( "default", 1.4 );
	self.hud_server_banner setPoint( "CENTER", "BOTTOM", 0, -8 );
	self.hud_server_banner.archived = false;
	self.hud_server_banner.hideWhenInMenu = true;
	self.hud_server_banner.alpha = 0;
	
	// Set the banners to be displayer during a match in ready up period
	level.matchServerBanners = [];
	if ( isDefined( level.scr_league_ruleset ) )
		level.matchServerBanners[ level.matchServerBanners.size ] = level.scr_league_ruleset;

	// Add the mod version to the banner
	level.matchServerBanners[ level.matchServerBanners.size ] = "^3" + getDvar( "_Mod" ) + " " + getDvar( "_ModVer" );

	// Loop forever until the player disconnects
	for(;;)
	{
		wait (0.05);

		// Check if we need to display server banners
		if ( level.sv_enable_server_banners != 0 && level.serverBanners.size > 0 ) {
			self each( level.serverBanners, ::displayServerBanner );
		}

		// Check if we need to display match server banners
		if ( level.inReadyUpPeriod ) {
			self each( level.matchServerBanners, ::displayServerBanner );
		}
	}
}

