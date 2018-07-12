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

main()
{
	// Check if we should load the effects or not
	if ( level.scr_map_special_fx_enable == 0 )
		return;
		
	// Load the effects
	level._effect[ "paper_falling_burning" ] = loadfx( "misc/paper_falling_burning" );
	level._effect[ "ground_smoke_launch_a" ] = loadfx( "smoke/ground_smoke_launch_a" );
	level._effect[ "amb_dust_hangar" ] = loadfx( "dust/amb_dust_hangar_mp" );
	level._effect[ "light_shaft_dust_large" ] = loadfx( "dust/light_shaft_dust_large" );
	level._effect[ "light_shaft_dust_med" ] = loadfx( "dust/light_shaft_dust_med" );	
	
 	ent = maps\mp\_utility::createOneshotEffect( "amb_dust_hangar" );
 	ent.v[ "origin" ] = ( 634.754, 919.889, 248.125 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "fxid" ] = "amb_dust_hangar";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "amb_dust_hangar" );
 	ent.v[ "origin" ] = ( 693.875, 1471.26, 279.095 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "fxid" ] = "amb_dust_hangar";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "amb_dust_hangar" );
 	ent.v[ "origin" ] = ( 615.771, 2360.61, 303.114 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "fxid" ] = "amb_dust_hangar";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "amb_dust_hangar" );
 	ent.v[ "origin" ] = ( 546.383, 1868.54, 238.682 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "fxid" ] = "amb_dust_hangar";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "ground_smoke_launch_a" );
 	ent.v[ "origin" ] = ( 496.461, 2137.29, 28.125 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "fxid" ] = "ground_smoke_launch_a";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "ground_smoke_launch_a" );
 	ent.v[ "origin" ] = ( 532.291, 920.723, 28.125 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "fxid" ] = "ground_smoke_launch_a";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "ground_smoke_launch_a" );
 	ent.v[ "origin" ] = ( 651.757, 1486.79, 40.125 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "fxid" ] = "ground_smoke_launch_a";
 	ent.v[ "delay" ] = -15;

	// Play the ambient sound
	ambientPlay("ambient_overgrown_day"); 

	return;
 
}
