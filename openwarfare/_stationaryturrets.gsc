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
	// Get the main module's dvar
	level.scr_allow_stationary_turrets = getdvarx( "scr_allow_stationary_turrets", "int", 1, 0, 1 );

	// If stationary turrets are enabled then there's nothing else to do here
	if ( level.scr_allow_stationary_turrets == 0 ) {
		thread removeStationaryTurrets();
	}

	return;
}


removeStationaryTurrets()
{
	// Classes for turrets (this way if something new comes out we just need to add an entry to the array)
	turretClasses = [];
	turretClasses[0] = "misc_turret";
	turretClasses[1] = "misc_mg42";

	// Cycle all the classes used by turrets
	for ( classix = 0; classix < turretClasses.size; classix++ )
	{
		// Get an array of entities for this class
		turretEntities = getentarray( turretClasses[ classix ], "classname" );

		// Cycle and delete all the entities retrieved
		if ( isDefined ( turretEntities ) ) {
			for ( turretix = 0; turretix < turretEntities.size; turretix++ ) {
				turretEntities[ turretix ] delete();
			}
		}
	}

	return;
}
