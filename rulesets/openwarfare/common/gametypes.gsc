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
	// configs/gametypes/assassination.cfg
	//******************************************************************************	
	setDvar( "scr_ass_roundlimit", "5" );
	setDvar( "scr_ass_roundswitch", "2" );
	setDvar( "scr_ass_scorelimit", "3" );
	setDvar( "scr_ass_timelimit", "5" );
	setDvar( "scr_ass_extracting_time", "3" );
	setDvar( "scr_ass_scoreboard_vip", "1" );
	setDvar( "scr_ass_vip_health", "0" );
	setDvar( "scr_ass_force_vip_handgun", "" );
	setDvar( "scr_ass_vip_clan_tags", "" );
	setDvar( "scr_ass_teambalanceendofround", "1" );

	//******************************************************************************
	// configs/gametypes/behindenemylines.cfg
	//******************************************************************************	
	setDvar( "scr_bel_alive_points_time", "10" );
	setDvar( "scr_bel_alive_points", "5" );
	setDvar( "scr_bel_showoncompass", "1" );
	setDvar( "scr_bel_showoncompass_interval", "30" );
	setDvar( "scr_bel_showoncompass_time", "5" );
	setDvar( "scr_bel_showoncompass_points", "5" );
	setDvar( "scr_bel_playerrespawndelay", "3.5" );
	setDvar( "scr_bel_scorelimit", "0" );
	setDvar( "scr_bel_timelimit", "20" );
	setDvar( "scr_bel_waverespawndelay", "0" );
	setDvar( "scr_bel_teambalanceendofround", "0" );

	//******************************************************************************
	// configs/gametypes/captureandhold.cfg
	//******************************************************************************		
	setDvar( "scr_ch_chmode", "0" );
	setDvar( "scr_ch_suddendeath_show_enemies", "0" );
	setDvar( "scr_ch_suddendeath_timelimit", "90" );
	setDvar( "scr_ch_holdtime", "100" );
	setDvar( "scr_ch_neutraltime", "15" );
	setDvar( "scr_ch_numlives", "0" );
	setDvar( "scr_ch_playerrespawndelay", "7.5" );
	setDvar( "scr_ch_ownerspawndelay", "0" );
	setDvar( "scr_ch_roundlimit", "5" );
	setDvar( "scr_ch_roundswitch", "2" );
	setDvar( "scr_ch_scorelimit", "3" );
	setDvar( "scr_ch_timelimit", "20" );
	setDvar( "scr_ch_waverespawndelay", "0" );
	setDvar( "scr_ch_scoreboard_flag_carrier", "1" );
	setDvar( "scr_ch_show_flag_carrier", "0" );
	setDvar( "scr_ch_show_flag_carrier_time", "5" );
	setDvar( "scr_ch_show_flag_carrier_distance", "0" );
	setDvar( "scr_ch_teambalanceendofround", "0" );
	
	//******************************************************************************
	// configs/gametypes/capturetheflag.cfg
	//******************************************************************************		
	setDvar( "scr_ctf_ctfmode", "0" );
	setDvar( "scr_ctf_idleflagreturntime", "60" );
	setDvar( "scr_ctf_endround_on_capture", "0" );
	setDvar( "scr_ctf_suddendeath_show_enemies", "0" );
	setDvar( "scr_ctf_suddendeath_timelimit", "90" );
	setDvar( "scr_ctf_numlives", "0" );
	setDvar( "scr_ctf_playerrespawndelay", "7.5" );
	setDvar( "scr_ctf_roundlimit", "2" );
	setDvar( "scr_ctf_roundswitch", "1" );
	setDvar( "scr_ctf_scorelimit", "0" );
	setDvar( "scr_ctf_timelimit", "20" );
	setDvar( "scr_ctf_waverespawndelay", "0" );
	setDvar( "scr_ctf_flag_carrier_can_return", "1" );
	setDvar( "scr_ctf_scoreboard_flag_carrier", "1" );
	setDvar( "scr_ctf_show_flag_carrier", "0" );
	setDvar( "scr_ctf_show_flag_carrier_time", "5" );
	setDvar( "scr_ctf_show_flag_carrier_distance", "0" );
	setDvar( "scr_ctf_teambalanceendofround", "0" );
	
	//******************************************************************************
	// configs/gametypes/domination.cfg
	//******************************************************************************		
	setDvar( "scr_dom_numlives", "0" );
	setDvar( "scr_dom_playerrespawndelay", "7.5" );
	setDvar( "scr_dom_roundlimit", "2" );
	setDvar( "scr_dom_roundswitch", "1" );
	setDvar( "scr_dom_scorelimit", "0" );
	setDvar( "scr_dom_timelimit", "25" );
	setDvar( "scr_dom_waverespawndelay", "0" );
	setDvar( "scr_dom_flash_on_capture", "1" );
	setDvar( "scr_dom_announce_on_capture", "1" );
	setDvar( "scr_dom_secured_all_bonus_time", "20" );
	setDvar( "scr_dom_flag_capture_time", "10" );
	setDvar( "scr_dom_teambalanceendofround", "0" );

	//******************************************************************************
	// configs/gametypes/freeforall.cfg
	//******************************************************************************
	setDvar( "scr_dm_numlives", "0" );
	setDvar( "scr_dm_playerrespawndelay", "3.5" );
	setDvar( "scr_dm_roundlimit", "1" );
	setDvar( "scr_dm_scorelimit", "0" );
	setDvar( "scr_dm_timelimit", "30" );

	//******************************************************************************
	// configs/gametypes/freezetag.cfg
	//******************************************************************************
	setDvar( "scr_ftag_numlives", "0" );
	setDvar( "scr_ftag_roundlimit", "5" );
	setDvar( "scr_ftag_roundswitch", "2" );
	setDvar( "scr_ftag_scorelimit", "3" );
	setDvar( "scr_ftag_timelimit", "20" );
	setDvar( "scr_ftag_forcestartspawns", "0" );
	setDvar( "scr_ftag_frozen_freelook", "1" );
	setDvar( "scr_ftag_unfreeze_score", "1" );
	setDvar( "scr_ftag_unfreeze_time", "250" );
	setDvar( "scr_ftag_auto_unfreeze_time", "1430" );
	setDvar( "scr_ftag_unfreeze_maxdistance", "1000" );
	setDvar( "scr_ftag_unfreeze_beam", "1" );
	setDvar( "scr_ftag_unfreeze_melt_iceberg", "1" );
	setDvar( "scr_ftag_unfreeze_respawn", "0" );
	setDvar( "scr_ftag_show_stats", "1" );
	setDvar( "scr_ftag_teambalanceendofround", "1" );

	//******************************************************************************
	// configs/gametypes/greed.cfg
	//******************************************************************************
	setDvar( "scr_gr_active_drop_zones", "2" );
	setDvar( "scr_gr_drop_zones_relocation_time", "60" );
	setDvar( "scr_gr_base_dogtag_score", "10" );
	setDvar( "scr_gr_minimap_mark_red_drops", "1" );
	setDvar( "scr_gr_dogtag_autoremoval_time", "60" );
	setDvar( "scr_gr_playerrespawndelay", "3.5" );
	setDvar( "scr_gr_roundlimit", "1" );
	setDvar( "scr_gr_scorelimit", "0" );
	setDvar( "scr_gr_timelimit", "30" );
		
	//******************************************************************************
	// configs/gametypes/gungame.cfg
	//******************************************************************************
	setDvar( "scr_gg_playerrespawndelay", "3.5" );
	setDvar( "scr_gg_timelimit", "0" );
	setDvar( "scr_gg_weapon_order", "beretta_mp;colt45_mp;usp_mp;deserteagle_mp;winchester1200_mp;m1014_mp;skorpion_mp;uzi_mp;ak74u_mp;mp5_mp;p90_mp;m14_mp;g3_mp;m16_mp;ak47_mp;g36c_mp;m4_mp;rpd_mp;m60e4_mp;frag_grenade_mp:1;knife_mp:1" );
	setDvar( "scr_gg_specialty_slot1", "specialty_fastreload" );
	setDvar( "scr_gg_specialty_slot2", "specialty_longersprint" );
	setDvar( "scr_gg_knife_pro", "0" );
	setDvar( "scr_gg_death_penalty", "5" );
	setDvar( "scr_gg_knifed_penalty", "0" );
	setDvar( "scr_gg_handicap_on", "2" );
	setDvar( "scr_gg_nade_knife_weapon", "c4_mp:0" );
	setDvar( "scr_gg_explosives_special", "0" );
	setDvar( "scr_gg_extra_explosives", "1" );
	setDvar( "scr_gg_explosives_refresh", "10" );
	setDvar( "scr_gg_kills_per_lvl", "2" );
	setDvar( "scr_gg_refill_on_kill", "1" );
	setDvar( "scr_gg_auto_levelup", "0" );
	setDvar( "scr_gg_auto_levelup_time", "60" );

	//******************************************************************************
	// configs/gametypes/headquarters.cfg
	//******************************************************************************
	setDvar( "scr_koth_kothmode", "0" );
	setDvar( "scr_koth_autodestroytime", "60" );
	setDvar( "scr_koth_capturetime", "35" );
	setDvar( "scr_koth_delayPlayer", "1" );
	setDvar( "scr_koth_destroytime", "15" );
	setDvar( "scr_koth_numlives", "0" );
	setDvar( "scr_koth_playerrespawndelay", "7.5" );
	setDvar( "scr_koth_roundlimit", "2" );
	setDvar( "scr_koth_roundswitch", "1" );
	setDvar( "scr_koth_scorelimit", "0" );
	setDvar( "scr_koth_spawnDelay", "60" );
	setDvar( "scr_koth_spawntime", "40" );
	setDvar( "scr_koth_timelimit", "25" );
	setDvar( "scr_koth_waverespawndelay", "0" );
	setDvar( "scr_koth_flash_on_capture", "1" );
	setDvar( "scr_koth_flash_on_destroy", "1" );
	setDvar( "scr_koth_teambalanceendofround", "0" );

	//******************************************************************************
	// configs/gametypes/headquarters.cfg
	//******************************************************************************
	setDvar( "scr_hns_hidetime", "30" );
	setDvar( "scr_hns_props_speed", "1.2" );
	setDvar( "scr_hns_props_max_morphs", "0" );
	setDvar( "scr_hns_props_survive_score_time", "30" );
	setDvar( "scr_hns_hunting_music_enable", "1" );
	setDvar( "scr_hns_hunting_music_time", "0" );	
	setDvar( "scr_hns_roundlimit", "5" );
	setDvar( "scr_hns_roundswitch", "2" );
	setDvar( "scr_hns_scorelimit", "3" );
	setDvar( "scr_hns_timelimit", "5.5" );
	setDvar( "scr_hns_teambalanceendofround", "1"	 );
		
	//******************************************************************************
	// configs/gametypes/lastmanstanding.cfg
	//******************************************************************************	
	setDvar( "scr_lms_numlives", "1" );
	setDvar( "scr_lms_roundlimit", "0" );
	setDvar( "scr_lms_scorelimit", "3" );
	setDvar( "scr_lms_timelimit", "0" );
	
	//******************************************************************************
	// configs/gametypes/lastteamstanding.cfg
	//******************************************************************************	
	setDvar( "scr_lts_numlives", "1" );
	setDvar( "scr_lts_roundlimit", "5" );
	setDvar( "scr_lts_roundswitch", "2" );
	setDvar( "scr_lts_scorelimit", "3" );
	setDvar( "scr_lts_timelimit", "0" );
	setDvar( "scr_lts_teambalanceendofround", "1" );

	//******************************************************************************
	// configs/gametypes/oneinthechamber.cfg
	//******************************************************************************	
	setDvar( "scr_oitc_playerrespawndelay", "3.5" );
	setDvar( "scr_oitc_roundlimit", "0" );
	setDvar( "scr_oitc_scorelimit", "3" );
	setDvar( "scr_oitc_timelimit", "5" );
	setDvar( "scr_oitc_suddendeath_show_enemies", "1" );
	setDvar( "scr_oitc_suddendeath_timelimit", "0" );		
	setDvar( "scr_oitc_handgun", "beretta_mp;colt45_mp;usp_mp;deserteagle_mp" );
	setDvar( "scr_oitc_specialty_slot1", "specialty_fastreload" );
	setDvar( "scr_oitc_specialty_slot2", "specialty_longersprint" );
	
	//******************************************************************************
	// configs/gametypes/retrieval.cfg
	//******************************************************************************	
	setDvar( "scr_re_objectives_enabled", "0" );
	setDvar( "scr_re_defenders_show_both", "0" );
	setDvar( "scr_re_numlives", "1" );
	setDvar( "scr_re_playerrespawndelay", "0" );
	setDvar( "scr_re_defenders_spawndelay", "0" );
	setDvar( "scr_re_waverespawndelay", "0" );
	setDvar( "scr_re_roundlimit", "5" );
	setDvar( "scr_re_roundswitch", "2" );
	setDvar( "scr_re_scoreboard_objective_carrier", "0" );
	setDvar( "scr_re_one_retrieve", "0" );
	setDvar( "scr_re_objective_autoresettime", "0" );
	setDvar( "scr_re_scorelimit", "3" );
	setDvar( "scr_re_timelimit", "7" );
	setDvar( "scr_re_teambalanceendofround", "1" );

	//******************************************************************************
	// configs/gametypes/sabotage.cfg
	//******************************************************************************
	setDvar( "scr_sab_bombtimer", "60" );
	setDvar( "scr_sab_defusetime", "8" );
	setDvar( "scr_sab_hotpotato", "1" );
	setDvar( "scr_sab_numlives", "0" );
	setDvar( "scr_sab_planttime", "5" );
	setDvar( "scr_sab_playerrespawndelay", "7.5" );
	setDvar( "scr_sab_roundlimit", "5" );
	setDvar( "scr_sab_roundswitch", "2" );
	setDvar( "scr_sab_scorelimit", "3" );
	setDvar( "scr_sab_timelimit", "15" );
	setDvar( "scr_sab_waverespawndelay", "0" );
	setDvar( "scr_sab_suddendeath_show_enemies", "0" );
	setDvar( "scr_sab_suddendeath_timelimit", "90" );
	setDvar( "scr_sab_planting_sound", "1" );
	setDvar( "scr_sab_show_briefcase", "1" );
	setDvar( "scr_sab_scoreboard_bomb_carrier", "1" );
	setDvar( "scr_sab_show_bomb_carrier", "0" );
	setDvar( "scr_sab_show_bomb_carrier_time", "5" );
	setDvar( "scr_sab_show_bomb_carrier_distance", "0" );
	setDvar( "scr_sab_teambalanceendofround", "0" );

	//******************************************************************************
	// configs/gametypes/searchanddestroy.cfg
	//******************************************************************************
	setDvar( "scr_sd_sdmode", "1" );
	setDvar( "scr_sd_bombsites_enabled", "0" );
	setDvar( "scr_sd_defenders_show_both", "0" );
	setDvar( "scr_sd_bomb_notification_enable", "1" );
	setDvar( "scr_sd_bombtimer", "60" );
	setDvar( "scr_sd_bombtimer_modifier", "0" );
	setDvar( "scr_sd_bombtimer_show", "1" );
	setDvar( "scr_sd_defusetime", "8" );
	setDvar( "scr_sd_defusing_sound", "1" );
	setDvar( "scr_sd_multibomb", "0" );
	setDvar( "scr_sd_planting_sound", "1" );
	setDvar( "scr_sd_planttime", "4" );
	setDvar( "scr_sd_roundlimit", "5" );
	setDvar( "scr_sd_roundswitch", "2" );
	setDvar( "scr_sd_scoreboard_bomb_carrier", "0" );
	setDvar( "scr_sd_scorelimit", "3" );
	setDvar( "scr_sd_show_briefcase", "1" );
	setDvar( "scr_sd_timelimit", "4" );
	setDvar( "scr_sd_allow_defender_explosivepickup", "0" );
	setDvar( "scr_sd_allow_defender_explosivedestroy", "0" );
	setDvar( "scr_sd_allow_defender_explosivedestroy_time", "10" );
	setDvar( "scr_sd_allow_defender_explosivedestroy_win", "0" );
	setDvar( "scr_sd_allow_defender_explosivedestroy_sound", "0" );
	setDvar( "scr_sd_allow_quickdefuse", "0" );
	setDvar( "scr_sd_objective_takedamage_enable", "0" );
	setDvar( "scr_sd_objective_takedamage_option", "0" );
	setDvar( "scr_sd_objective_takedamage_counter", "5" );
	setDvar( "scr_sd_objective_takedamage_health", "500" );
	setDvar( "scr_sd_teambalanceendofround", "1" );

	//******************************************************************************
	// configs/gametypes/sharpshooter.cfg
	//******************************************************************************
	setDvar( "scr_ss_playerrespawndelay", "3.5" );
	setDvar( "scr_ss_roundlimit", "1" );
	setDvar( "scr_ss_scorelimit", "0" );
	setDvar( "scr_ss_timelimit", "30" );
	setDvar( "scr_ss_weapon_switch_time", "45" );
	setDvar( "scr_ss_available_weapons", "ak47_mp;ak74u_mp;g3_mp;g36c_mp;m4_mp;m14_mp;m16_mp;m60e4_mp;m1014_mp;mp5_mp;mp44_mp;p90_mp;rpd_mp;saw_mp;skorpion_mp;uzi_mp;winchester1200_mp" );
	setDvar( "scr_ss_explosives_special", "0" );
	setDvar( "scr_ss_specialty_slot1", "specialty_fastreload" );
	setDvar( "scr_ss_specialty_slot2", "specialty_longersprint" );
	
	//******************************************************************************
	// configs/gametypes/teamdeathmatch.cfg
	//******************************************************************************
	setDvar( "scr_war_numlives", "0" );
	setDvar( "scr_war_playerrespawndelay", "3.5" );
	setDvar( "scr_war_roundlimit", "2" );
	setDvar( "scr_war_roundswitch", "1" );
	setDvar( "scr_war_scorelimit", "0" );
	setDvar( "scr_war_timelimit", "20" );
	setDvar( "scr_war_waverespawndelay", "0" );
	setDvar( "scr_war_forcestartspawns", "0" );
	setDvar( "scr_war_teambalanceendofround", "0" );

	//******************************************************************************
	// configs/gametypes/teamgreed.cfg
	//******************************************************************************	
	setDvar( "scr_tgr_base_dogtag_score", "10" );
	setDvar( "scr_tgr_minimap_mark_red_drops", "1" );
	setDvar( "scr_tgr_dogtag_autoremoval_time", "60" );
	setDvar( "scr_tgr_playerrespawndelay", "3.5" );
	setDvar( "scr_tgr_roundlimit", "2" );
	setDvar( "scr_tgr_roundswitch", "1" );
	setDvar( "scr_tgr_scorelimit", "0" );
	setDvar( "scr_tgr_timelimit", "20" );
	setDvar( "scr_tgr_waverespawndelay", "0" );
	setDvar( "scr_tgr_forcestartspawns", "0" );
	setDvar( "scr_tgr_teambalanceendofround", "0" );	
}