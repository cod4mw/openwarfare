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

#include openwarfare\_utils;

init()
{
  level.scr_allow_testclients = getdvarx( "scr_allow_testclients", "int", 0, 0, 1 );
  
  if ( level.scr_allow_testclients == 0 )
  	return;
  	
  level thread addTestClients();
}


addTestClients()
{
	wait 5;
	
	for (;;) {
		wait (1);
		
		testClients = getdvarInt( "scr_testclients" );
		if ( testClients == 0 )
			continue;
			
		setDvar( "scr_testclients", 0 );
		
		for( i = 0; i < testClients; i++ )	{
			newBot = addTestClient();
	
			if ( !isdefined( newBot ) ) {
				println( "Could not add test client" );
				wait 1;
				break;
			}
				
			newBot.pers["isBot"] = true;
			newBot thread initBotClass();
		}
	}
}


initBotClass()
{
	self endon( "disconnect" );

	while( !isDefined( self.pers ) || !isDefined( self.pers["team"] ) )
		wait(1);
		
	self notify( "menuresponse", game["menu_team"], "autoassign" );

	while( self.pers["team"] == "spectator" )
		wait(1);

	if ( !level.oldschool )	{
		if ( level.gametype != "hns" || self.pers["team"] == game["attackers"] ) {
			if ( level.rankedMatch ) {
				self notify( "menuresponse", game["menu_changeclass"], "assault_mp" );			
			} else {		
				self notify( "menuresponse", game["menu_changeclass_" + self.pers["team"] ], "assault" );
				wait(1);
				self notify( "menuresponse", game["menu_changeclass"] , "go" );
			}
		} else {
				self notify( "menuresponse", game["menu_changeclass_" + self.pers["team"] ], "" + randomIntRange( 1, level.maxPropNumber + 1 ) );			
		}
	}
}