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
	//******************************************************************************
	// configs/server/rank.cfg
	//******************************************************************************		
	setDvar( "scr_server_rank_type", "1" );

	setDvar( "class_allies_assault_limit", "0" );
	setDvar( "class_allies_specops_limit", "0" );
	setDvar( "class_allies_heavygunner_limit", "0" );
	setDvar( "class_allies_sniper_limit", "0" );

	setDvar( "class_axis_assault_limit", "0" );
	setDvar( "class_axis_specops_limit", "0" );
	setDvar( "class_axis_heavygunner_limit", "0" );
	setDvar( "class_axis_sniper_limit", "0" );		
}