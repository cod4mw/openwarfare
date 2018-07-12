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
	level.scr_enable_anti_bunny_hopping = getdvarx( "scr_enable_anti_bunny_hopping", "int", 0, 0, 4 );
	level.scr_enable_anti_dolphin_dive = getdvarx( "scr_enable_anti_dolphin_dive", "int", 0, 0, 1 );
	
	if ( level.scr_enable_anti_bunny_hopping == 0 && level.scr_enable_anti_dolphin_dive == 0 )
		return;
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}

onPlayerSpawned()
{
	if ( level.scr_enable_anti_bunny_hopping != 0 )
		self thread antiBunnyHopping();
	
	if ( level.scr_enable_anti_dolphin_dive != 0 )
		self thread antiDolphinDive();
}


antiBunnyHopping()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	// Initialize some variables we need to detect jumping
	self.jumping = false;
	self.lastGrounding = gettime() - 1000;
	heightTracker = 0;
	lastDistance = 0;
	weaponsDisabled = false;

	for (;;)
	{
		wait (0.05);

		// If player is on the ground and was jumping enable weapons again and reset vars
		if ( self isOnGround() && self.jumping ) {
			wait 0.3;
			// Player is not jumping anymore
			if ( weaponsDisabled ) {
				self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
				weaponsDisabled = false;
			}
			self.jumping = false;
			self.lastGrounding = gettime();
			lastDistance = 0;
		} else {
			// Make sure the player has not already being detected jumping and that it's not
			// using a ladder, mantling or on the ground
			if ( !self.jumping && !( self isOnGround() ) && !( self isMantling() ) && !( self isOnLadder() ) ) {
				playerOrigin = self.origin;

				// Player is airborne... Get the distance from the player to the ground
				groundOrigin = playerphysicstrace( playerOrigin, playerOrigin + (0,0,-1000) );
				newDistance = int( distance( playerOrigin, groundOrigin ) );

				// If distance is higher than the one measured before then the player might be jumping
				if ( newDistance > lastDistance ) {
					heightTracker++;

					// If we have 3 consecutive measures increasing the  distance from the ground
					// then the player is considered being jumping so we disable the weapons
					if ( heightTracker >= 3 ) {
						self.jumping = true;
						heightTracker = 0;

						if ( ( level.scr_enable_anti_bunny_hopping == 1 || level.scr_enable_anti_bunny_hopping == 3 || ( gettime() - self.lastGrounding ) < 1000 ) && self getCurrentWeapon() != "c4_mp" && self getCurrentWeapon() != "claymore_mp" ) {
							if ( level.scr_enable_anti_bunny_hopping == 3 || level.scr_enable_anti_bunny_hopping == 4 ) {
								self thread shiftPlayerView( 5 );
							} else {
								self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
								weaponsDisabled = true;
							}
						}
					}
				} else {
					heightTracker = 0;
				}

				lastDistance = newDistance;
			} else {
				heightTracker = 0;
			}
		}
	}
}

antiDolphinDive()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

  self.previousStance = "";

  for (;;)
	{
		wait (0.05);
		if (self.previousstance != "prone" && ( self getStance() == "prone" ) && ( self attackButtonPressed() ) )
			self thread shiftPlayerView( 30 );

   	self.previousStance = self getStance();
  }
}