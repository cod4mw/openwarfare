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
	// configs/gameplay/hud.cfg
	//******************************************************************************
	setDvar( "scr_show_player_assignment", "0" );

	//******************************************************************************
	// configs/server/advancedmvs.cfg
	//******************************************************************************	
	setDvar( "scr_amvs_enable", "0" );

	//******************************************************************************
	// configs/server/idlemonitor.cfg
	//******************************************************************************	
	setDvar( "scr_idle_switch_spectator", "0" );
	setDvar( "scr_idle_spectator_timeout", "0" );

	//******************************************************************************
	// configs/server/match.cfg
	//******************************************************************************		
	setDvar( "scr_match_readyup_period", "1" );
	setDvar( "scr_match_readyup_period_onsideswitch", "1" );
	setDvar( "scr_match_readyup_disable_weapons", "0" );
	setDvar( "scr_match_readyup_show_checksums", "0" );
	setDvar( "scr_match_readyup_show_checksums_interval", "30" );
	setDvar( "scr_match_readyup_time_match", "0" );
	setDvar( "scr_match_readyup_time_round", "5" );
	setDvar( "scr_match_strategy_time", "15" );
	setDvar( "scr_match_strategy_allow_bypass", "1" );
	setDvar( "scr_match_strategy_show_bypassed", "1" );
	setDvar( "scr_match_strategy_allow_movement", "1" );
	setDvar( "scr_match_strategy_getready_time", "1.5" );
	setDvar( "scr_timeouts_perteam", "3" );
	setDvar( "scr_timeouts_length", "30" );
	setDvar( "scr_timeouts_guids", "" );
	setDvar( "scr_timeouts_tags", ""	 );
	
	//******************************************************************************
	// configs/server/others.cfg
	//******************************************************************************		
	setDvar( "scr_tk_limit", "0" );

	//******************************************************************************
	// configs/server/rank.cfg
	//******************************************************************************		
	setDvar( "scr_server_rank_type", "1" );
	
	//******************************************************************************
	// configs/server/sponsors.cfg
	//******************************************************************************	
	setDvar( "scr_sponsor_enable", "1" );
	setDvar( "scr_sponsor_time", "15" );
	setDvar( "scr_sponsor_logo_1", "openwarfare;128;64;bottom;82" );
	
	//******************************************************************************
	// configs/server/teams.cfg
	//******************************************************************************		
	setDvar( "scr_force_autoassign", "0" );
	setDvar( "scr_teambalance", "0" );
}