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
	// configs/server/advancedmvs.cfg
	//******************************************************************************	
	// setDvar( "scr_amvs_enable", "0" );
	// setDvar( "scr_amvs_gametype_time", "15" );
	// setDvar( "scr_amvs_map_time", "15" );
	// setDvar( "scr_amvs_winner_time", "5" );
	// setDvar( "scr_amvs_gametypes", "ass;bel;ch;ctf;dom;dm;ftag;gg;koth;lms;lts;re;sab;sd;war" );
	// setDvar( "scr_amvs_maps_1", "mp_convoy;mp_backlot;mp_bloc;mp_bog;mp_broadcast;mp_carentan;mp_countdown;mp_crash;mp_creek;mp_crossfire;mp_citystreets;mp_farm;mp_overgrown;mp_pipeline;mp_shipment;mp_showdown;mp_strike;mp_cargoship;mp_crash_snow;mp_vacant" );
	// setDvar( "scr_amvs_can_repeat_map", "0" );
	
	//******************************************************************************
	// configs/server/idlemonitor.cfg
	//******************************************************************************	
	// setDvar( "scr_idle_switch_spectator", "0" );
	// setDvar( "scr_idle_spectator_timeout", "0" );
	// setDvar( "scr_idle_show_warning", "0" );
	// setDvar( "scr_idle_protected_tags", "" );
	// setDvar( "scr_idle_protected_guids", "" );

	//******************************************************************************
	// configs/server/match.cfg
	//******************************************************************************		
	// setDvar( "scr_match_readyup_period", "0" );
	// setDvar( "scr_match_readyup_period_onsideswitch", "0" );
	// setDvar( "scr_match_readyup_disable_weapons", "0" );
	// setDvar( "scr_match_readyup_show_checksums", "0" );
	// setDvar( "scr_match_readyup_show_checksums_interval", "30" );
	// setDvar( "scr_match_readyup_time_match", "0" );
	// setDvar( "scr_match_readyup_time_round", "0" );
	setDvar( "scr_match_strategy_time", "15" );
	// setDvar( "scr_match_strategy_allow_bypass", "1" );
	// setDvar( "scr_match_strategy_show_bypassed", "1" );
	// setDvar( "scr_match_strategy_allow_movement", "0" );
	// setDvar( "scr_match_strategy_getready_time", "1.5" );
	// setDvar( "scr_timeouts_perteam", "0" );
	// setDvar( "scr_timeouts_length", "30" );
	// setDvar( "scr_timeouts_guids", "" );
	// setDvar( "scr_timeouts_tags", "" );
	// setDvar( "scr_guidcs_enable", "0" );
	// setDvar( "scr_guidcs_allowed_1", "" );
		
	//******************************************************************************
	// configs/server/others.cfg
	//******************************************************************************
	// setDvar( "scr_server_overall_admin_guids", "" );
	// setDvar( "scr_g_gravity", "800" );
	// setDvar( "scr_game_playerwaittime", "15" );
	// setDvar( "scr_game_matchstarttime", "15" );
	// setDvar( "scr_intermission_time", "15" );
	setDvar( "scr_endofgame_stats_enable", "1" );
	// setDvar( "scr_player_connect_sound_enable", "0" );
	// setDvar( "scr_player_disconnect_sound_enable", "0" );
	// setDvar( "scr_forfeit_enable", "1" );
	// setDvar( "scr_enable_nightvision", "1" );
	// setDvar( "scr_enable_music", "0" );
	// setDvar( "scr_allow_leader_dialog", "1" );
	// setDvar( "scr_antilag", "0" );
	// setDvar( "scr_b3_poweradmin_enable", "0" );
	// setDvar( "scr_allow_testclients", "0" );
	// setDvar( "scr_testclients", "0" );
	// setDvar( "scr_tk_limit", "0" );
	// setDvar( "scr_tk_punishment_time", "30" );
	// setDvar( "scr_tk_explosive_countasone", "0" );
	// setDvar( "scr_tk_punishment", "0" );
	// setDvar( "scr_server_load_on_startup", "low" );
	// setDvar( "scr_server_load_low", "6" );
	// setDvar( "scr_server_load_medium", "12" );

	//******************************************************************************
	// configs/server/overtime.cfg
	//******************************************************************************
	// setDvar( "scr_overtime_enable", "0" );
	// setDvar( "scr_overtime_timelimit", "0" );
	// setDvar( "scr_overtime_numlives", "0" );
	// setDvar( "scr_overtime_playerrespawndelay", "-1" );
	// setDvar( "scr_overtime_incrementalspawndelay", "0" );
	// setDvar( "scr_overtime_suddendeath", "1" );
		
	//******************************************************************************
	// configs/server/rank.cfg
	//******************************************************************************		
	// setDvar( "scr_server_rank_type", "0" );
	// setDvar( "scr_power_rank_mode", "0" );
	// setDvar( "scr_power_rank_delay", "0.5" );
	// setDvar( "scr_enable_virtual_ranks", "0" );
	// setDvar( "scr_virtual_ranks", "Pfc.=3;LCpl.=6;Cpl.=9;Sgt.=12;SSgt.=15;GySgt.=18;MSgt.=21;MGySgt.=24;2ndLt.=27;1stLt.=30;Capt.=33;Maj.=36;LtCol.=39;Col.=42;BGen.=45;MajGen.=48;LtGen.=51;Gen.=54;CDR.=55" );
	// setDvar( "scr_virtual_ranks_score", "50" );
	
	//******************************************************************************
	// configs/server/sponsors.cfg
	//******************************************************************************	
	// setDvar( "scr_sponsor_enable", "0" );
	// setDvar( "scr_sponsor_time", "15" );
	// setDvar( "scr_sponsor_interval", "30" );
	// setDvar( "scr_sponsor_logo_1", "sponsor_logo1;256;64;top;66" );
	// setDvar( "scr_sponsor_logo_2", "sponsor_logo2;64;256;right;66" );
	// setDvar( "scr_sponsor_logo_3", "sponsor_logo1;256;64;bottom;66" );
	// setDvar( "scr_sponsor_logo_4", "sponsor_logo2;64;256;left;66" );
	// setDvar( "scr_sponsor_logo_5", "openwarfare;128;64;center" );

	//******************************************************************************
	// configs/server/teams.cfg
	//******************************************************************************		
	setDvar( "scr_force_autoassign", "1" );
	// setDvar( "scr_force_autoassign_clan_tags", "" );
	// setDvar( "scr_switch_teams_at_halftime", "0" );
	setDvar( "scr_teambalance", "1" );
	// setDvar( "scr_teambalance_show_message", "1" );
	// setDvar( "scr_teambalance_check_interval", "59" );
	// setDvar( "scr_teambalance_delay", "15" );
	// setDvar( "scr_teambalance_protected_clan_tags", "" );
	// setDvar( "scr_custom_teams_enable", "0" );
	// setDvar( "scr_custom_teams_maintain_on_switch", "1" );
	// setDvar( "scr_custom_teams_strings", "have won the match!;have won the round!;mission accomplished;eliminated;forfeited;have been all frozen!" );
	// setDvar( "scr_custom_allies_name", "" );
	// setDvar( "scr_custom_allies_logo", "" );
	// setDvar( "scr_custom_allies_headicon", "" );
	// setDvar( "scr_custom_axis_name", "" );
	// setDvar( "scr_custom_axis_logo", "" );
	// setDvar( "scr_custom_axis_headicon", "" );
	// setDvar( "scr_clan_vs_all_team", "" );
	// setDvar( "scr_clan_vs_all_tags", "" );
	
	//******************************************************************************
	// configs/server/voting.cfg
	//******************************************************************************		
	// setDvar( "scr_allowvote_clan_tags", "" );
	// setDvar( "scr_allowvote", "0" );
	// setDvar( "scr_allowvote_restartmap", "1" );
	// setDvar( "scr_allowvote_nextmap", "1" );
	// setDvar( "scr_allowvote_changemap", "1" );
	// setDvar( "scr_allowvote_changegametype", "1" );
	// setDvar( "scr_allowvote_kickplayer", "1" );
}