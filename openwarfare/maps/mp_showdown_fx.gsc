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
	level._effect[ "wood" ] = loadfx( "explosions/grenadeExp_wood" );
	level._effect[ "dust" ] = loadfx( "explosions/grenadeExp_dirt_1" );
	level._effect[ "brick" ] = loadfx( "explosions/grenadeExp_concrete_1" );
	level._effect["firelp_med_pm"] = loadfx ("fire/firelp_med_pm_nodistort");	
	level._effect["firelp_small_pm"] = loadfx ("fire/firelp_small_pm");
	level._effect["firelp_small_pm_a"] = loadfx ("fire/firelp_small_pm_a");
	level._effect["dust_wind_fast"] = loadfx ("dust/dust_wind_fast");
	level._effect["dust_wind_slow"] = loadfx ("dust/dust_wind_slow_yel_loop");
	level._effect["dust_wind_spiral"] = loadfx ("dust/dust_spiral_runner");
	level._effect["hawk"] = loadfx ("weather/hawk");
	level._effect["hallway_smoke_light"] = loadfx ("smoke/hallway_smoke_light");	
	
 	ent = maps\mp\_utility::createOneshotEffect( "dust_wind_spiral" );
 	ent.v[ "origin" ] = ( -244.599, 76.2966, 0.124995 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "fxid" ] = "dust_wind_spiral";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "dust_wind_spiral" );
 	ent.v[ "origin" ] = ( 229.119, 77.9091, 0.124999 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "fxid" ] = "dust_wind_spiral";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "dust_wind_fast" );
 	ent.v[ "origin" ] = ( -3.19453, 1549.1, -6.30992 );
 	ent.v[ "angles" ] = ( 270, 4, 72 );
 	ent.v[ "fxid" ] = "dust_wind_fast";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "dust_wind_slow" );
 	ent.v[ "origin" ] = ( 829.028, 933.758, 0.124999 );
 	ent.v[ "angles" ] = ( 270, 352, 52 );
 	ent.v[ "fxid" ] = "dust_wind_slow";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "dust_wind_spiral" );
 	ent.v[ "origin" ] = ( 821.598, -1004.79, 22.5629 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "fxid" ] = "dust_wind_spiral";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "dust_wind_slow" );
 	ent.v[ "origin" ] = ( 1012.3, -235.562, 16 );
 	ent.v[ "angles" ] = ( 270, 2.79249, -6.79244 );
 	ent.v[ "fxid" ] = "dust_wind_slow";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "dust_wind_fast" );
 	ent.v[ "origin" ] = ( 27.8876, -1473.36, 16 );
 	ent.v[ "angles" ] = ( 270, 20.5288, -112.529 );
 	ent.v[ "fxid" ] = "dust_wind_fast";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "dust_wind_slow" );
 	ent.v[ "origin" ] = ( -826.502, -922.302, 16 );
 	ent.v[ "angles" ] = ( 270, 5.46233, -157.462 );
 	ent.v[ "fxid" ] = "dust_wind_slow";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "dust_wind_spiral" );
 	ent.v[ "origin" ] = ( -818.221, 979.518, 8.33664 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "fxid" ] = "dust_wind_spiral";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hawk" );
 	ent.v[ "origin" ] = ( -26.022, 151.293, -0.500002 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "fxid" ] = "hawk";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hallway_smoke_light" );
 	ent.v[ "origin" ] = ( -3.67769, 1068.43, 50.125 );
 	ent.v[ "angles" ] = ( 358, 272, 180 );
 	ent.v[ "fxid" ] = "hallway_smoke_light";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hallway_smoke_light" );
 	ent.v[ "origin" ] = ( -6.20258, 693.326, 47.125 );
 	ent.v[ "angles" ] = ( 358, 272, 180 );
 	ent.v[ "fxid" ] = "hallway_smoke_light";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hallway_smoke_light" );
 	ent.v[ "origin" ] = ( 3.87154, -869.234, 49.125 );
 	ent.v[ "angles" ] = ( 358, 272, 180 );
 	ent.v[ "fxid" ] = "hallway_smoke_light";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hallway_smoke_light" );
 	ent.v[ "origin" ] = ( 698.067, 48.5627, 48.125 );
 	ent.v[ "angles" ] = ( 358, 272, 180 );
 	ent.v[ "fxid" ] = "hallway_smoke_light";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hallway_smoke_light" );
 	ent.v[ "origin" ] = ( -703.001, -92.0622, 64.125 );
 	ent.v[ "angles" ] = ( 358, 272, 180 );
 	ent.v[ "fxid" ] = "hallway_smoke_light";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hallway_smoke_light" );
 	ent.v[ "origin" ] = ( -562.924, -436.897, 50.125 );
 	ent.v[ "angles" ] = ( 358, 0, -180 );
 	ent.v[ "fxid" ] = "hallway_smoke_light";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hallway_smoke_light" );
 	ent.v[ "origin" ] = ( -37.0429, -443.918, 47.125 );
 	ent.v[ "angles" ] = ( 358, 0, -180 );
 	ent.v[ "fxid" ] = "hallway_smoke_light";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hallway_smoke_light" );
 	ent.v[ "origin" ] = ( 402.347, -446.428, 58.125 );
 	ent.v[ "angles" ] = ( 358, 0, -180 );
 	ent.v[ "fxid" ] = "hallway_smoke_light";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hallway_smoke_light" );
 	ent.v[ "origin" ] = ( 685.417, -194.254, 220.125 );
 	ent.v[ "angles" ] = ( 0, 88, 0 );
 	ent.v[ "fxid" ] = "hallway_smoke_light";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hallway_smoke_light" );
 	ent.v[ "origin" ] = ( 690.581, 391.067, 213.125 );
 	ent.v[ "angles" ] = ( 0, 88, 0 );
 	ent.v[ "fxid" ] = "hallway_smoke_light";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hallway_smoke_light" );
 	ent.v[ "origin" ] = ( -702.32, -215.862, 205.125 );
 	ent.v[ "angles" ] = ( 0, 88, 0 );
 	ent.v[ "fxid" ] = "hallway_smoke_light";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hallway_smoke_light" );
 	ent.v[ "origin" ] = ( -690.674, 374.937, 226.125 );
 	ent.v[ "angles" ] = ( 0, 88, 0 );
 	ent.v[ "fxid" ] = "hallway_smoke_light";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hallway_smoke_light" );
 	ent.v[ "origin" ] = ( -452.833, 582.863, 210.125 );
 	ent.v[ "angles" ] = ( 0, 180, 0 );
 	ent.v[ "fxid" ] = "hallway_smoke_light";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hallway_smoke_light" );
 	ent.v[ "origin" ] = ( -60.4314, 579.063, 218.125 );
 	ent.v[ "angles" ] = ( 0, 180, 0 );
 	ent.v[ "fxid" ] = "hallway_smoke_light";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hallway_smoke_light" );
 	ent.v[ "origin" ] = ( 339.57, 571.046, 208.125 );
 	ent.v[ "angles" ] = ( 0, 180, 0 );
 	ent.v[ "fxid" ] = "hallway_smoke_light";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hallway_smoke_light" );
 	ent.v[ "origin" ] = ( 351.095, -437.19, 208.125 );
 	ent.v[ "angles" ] = ( 0, 180, 0 );
 	ent.v[ "fxid" ] = "hallway_smoke_light";
 	ent.v[ "delay" ] = -15;

 	ent = maps\mp\_utility::createOneshotEffect( "hallway_smoke_light" );
 	ent.v[ "origin" ] = ( -375.021, -440.109, 217.125 );
 	ent.v[ "angles" ] = ( 0, 180, 0 );
 	ent.v[ "fxid" ] = "hallway_smoke_light";
 	ent.v[ "delay" ] = -15;

ent = maps\mp\_createfx::createLoopSound();
 	ent.v[ "origin" ] = ( -1237.28, 1231.79, 328.679 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "soundalias" ] = "emt_tree_palm_rustle";

 	ent = maps\mp\_createfx::createLoopSound();
 	ent.v[ "origin" ] = ( -740.69, -813.967, 392.987 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "soundalias" ] = "emt_tree_palm_rustle";

 	ent = maps\mp\_createfx::createLoopSound();
 	ent.v[ "origin" ] = ( -785.338, -1071.09, 394.079 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "soundalias" ] = "emt_tree_palm_rustle";

 	ent = maps\mp\_createfx::createLoopSound();
 	ent.v[ "origin" ] = ( 1247.73, -365.182, 421.908 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "soundalias" ] = "emt_tree_palm_rustle";

 	ent = maps\mp\_createfx::createLoopSound();
 	ent.v[ "origin" ] = ( 1252.12, 500.095, 463.898 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "soundalias" ] = "emt_tree_palm_rustle";

 	ent = maps\mp\_createfx::createLoopSound();
 	ent.v[ "origin" ] = ( -1151.88, -1367.79, 408.635 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "soundalias" ] = "emt_metal_rattle_dull";

 	ent = maps\mp\_createfx::createLoopSound();
 	ent.v[ "origin" ] = ( -19.4857, -2266.95, 173.518 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "soundalias" ] = "emt_distant_traffic";

 	ent = maps\mp\_createfx::createLoopSound();
 	ent.v[ "origin" ] = ( -466.548, -805.038, 389.945 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "soundalias" ] = "emt_metal_rattle_ring";

 	ent = maps\mp\_createfx::createLoopSound();
 	ent.v[ "origin" ] = ( -1057.84, 85.5468, 94.5993 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "soundalias" ] = "emt_fly_loop";

 	ent = maps\mp\_createfx::createLoopSound();
 	ent.v[ "origin" ] = ( -874.467, 714.297, 81.0645 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "soundalias" ] = "emt_fly_loop";

 	ent = maps\mp\_createfx::createLoopSound();
 	ent.v[ "origin" ] = ( 5.40002, 2560.14, 108.99 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "soundalias" ] = "emt_distant_traffic";

 	ent = maps\mp\_createfx::createLoopSound();
 	ent.v[ "origin" ] = ( 1205.12, 1164.75, 458.125 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "soundalias" ] = "emt_metal_rattle_ring";

 	ent = maps\mp\_createfx::createLoopSound();
 	ent.v[ "origin" ] = ( 1024.52, -1426.88, 533.311 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "soundalias" ] = "emt_metal_rattle_pole";

 	ent = maps\mp\_createfx::createLoopSound();
 	ent.v[ "origin" ] = ( 471.025, -1938.12, 503.922 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "soundalias" ] = "emt_metal_rattle_ring";

 	ent = maps\mp\_createfx::createLoopSound();
 	ent.v[ "origin" ] = ( -3.12463, -378.601, 433.125 );
 	ent.v[ "angles" ] = ( 270, 0, 0 );
 	ent.v[ "soundalias" ] = "emt_metal_rattle_pole";


	// Play the ambient sound
	ambientPlay("ambient_crossfire"); 

	return;
	 
}
