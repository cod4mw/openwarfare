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

	setDvar( "class_assault_primary", "none" );
	setDvar( "class_assault_lock_primary", "1" );
	setDvar( "class_assault_primary_attachment", "none" );
	setDvar( "class_assault_lock_primary_attachment", "1" );
	setDvar( "class_assault_perk1", "specialty_extraammo" );	

	setDvar( "class_specops_primary", "none" );
	setDvar( "class_specops_lock_primary", "1" );
	setDvar( "class_specops_primary_attachment", "none" );
	setDvar( "class_specops_lock_primary_attachment", "1" );
	setDvar( "class_specops_perk1", "specialty_extraammo" );
	
	setDvar( "class_heavygunner_primary", "none" );
	setDvar( "class_heavygunner_lock_primary", "1" );	
	setDvar( "class_heavygunner_primary_attachment", "none" );
	setDvar( "class_heavygunner_lock_primary_attachment", "1" );	
	setDvar( "class_heavygunner_perk1", "specialty_extraammo" );

	setDvar( "class_demolitions_primary", "none" );
	setDvar( "class_demolitions_lock_primary", "1" );
	setDvar( "class_demolitions_primary_attachment", "none" );
	setDvar( "class_demolitions_lock_primary_attachment", "1" );
	setDvar( "class_demolitions_perk1", "specialty_extraammo" );
	
	setDvar( "class_sniper_primary", "none" );
	setDvar( "class_sniper_lock_primary", "1" );
	setDvar( "class_sniper_primary_attachment", "none" );
	setDvar( "class_sniper_lock_primary_attachment", "1" );
	setDvar( "class_sniper_perk1", "specialty_extraammo" );
	
	setDvar( "perk_allow_c4_mp", "0" );
	setDvar( "perk_allow_rpg_mp", "0" );
	setDvar( "perk_allow_claymore_mp", "0" );
}