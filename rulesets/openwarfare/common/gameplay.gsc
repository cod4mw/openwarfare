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
	// configs/gameplay/classes.cfg
	//******************************************************************************	
	// setDvar( "class_assault_movespeed", "0.95" );
	// setDvar( "class_specops_movespeed", "1.00" );
	// setDvar( "class_heavygunner_movespeed", "0.875" );
	// setDvar( "class_demolitions_movespeed", "1.00" );
	// setDvar( "class_sniper_movespeed", "1.00" );
	// setDvar( "scr_c4_ammo_count", "2" );
	// setDvar( "scr_claymore_ammo_count", "2" );
	// setDvar( "scr_rpg_ammo_count", "2" );
	// setDvar( "class_allies_assault_limit", "64" );
	// setDvar( "class_allies_specops_limit", "64" );
	// setDvar( "class_allies_heavygunner_limit", "64" );
	// setDvar( "class_allies_demolitions_limit", "64" );
	// setDvar( "class_allies_sniper_limit", "64" );
	// setDvar( "class_axis_assault_limit", "64" );
	// setDvar( "class_axis_specops_limit", "64" );
	// setDvar( "class_axis_heavygunner_limit", "64" );
	// setDvar( "class_axis_demolitions_limit", "64" );
	// setDvar( "class_axis_sniper_limit", "64" );
	// setDvar( "attach_assault_gl_limit", "64" );
	// setDvar( "smoke_grenade_limit", "64" );
	// setDvar( "class_assault_allowdrop", "1" );
	// setDvar( "class_specops_allowdrop", "1" );
	// setDvar( "class_heavygunner_allowdrop", "1" );
	// setDvar( "class_demolitions_allowdrop", "1" );
	// setDvar( "class_sniper_allowdrop", "1" );
	// setDvar( "scr_concussion_grenades_allowdrop", "0" );
	// setDvar( "scr_flash_grenades_allowdrop", "0" );
	// setDvar( "scr_frag_grenades_allowdrop", "0" );
	// setDvar( "scr_smoke_grenades_allowdrop", "0" );
	// setDvar( "weap_allow_beretta", "1" );
	// setDvar( "weap_allow_colt45", "1" );
	// setDvar( "weap_allow_usp", "1" );
	// setDvar( "weap_allow_deserteagle", "1" );
	// setDvar( "weap_allow_deserteaglegold", "1" );
	// setDvar( "attach_allow_pistol_none", "1" );
	// setDvar( "attach_allow_pistol_silencer", "1" );
	// setDvar( "weap_allow_binoculars", "0" );
	// setDvar( "weap_allow_frag_grenade", "1" );
	// setDvar( "weap_allow_concussion_grenade", "1" );
	// setDvar( "weap_allow_flash_grenade", "1" );
	// setDvar( "weap_allow_smoke_grenade", "1" );
	// setDvar( "weap_allow_assault_m16", "1" );
	// setDvar( "weap_allow_assault_ak47", "1" );
	// setDvar( "weap_allow_assault_m4", "1" );
	// setDvar( "weap_allow_assault_g3", "1" );
	// setDvar( "weap_allow_assault_g36c", "1" );
	// setDvar( "weap_allow_assault_m14", "1" );
	// setDvar( "weap_allow_assault_mp44", "1" );
	// setDvar( "attach_allow_assault_none", "1" );
	// setDvar( "attach_allow_assault_reflex", "1" );
	// setDvar( "attach_allow_assault_silencer", "1" );
	// setDvar( "attach_allow_assault_acog", "1" );
	// setDvar( "attach_allow_assault_gl", "1" );
	// setDvar( "class_assault_primary", "m16;m16;ak47" );
	// setDvar( "class_assault_primary_attachment", "gl" );
	// setDvar( "class_assault_secondary", "beretta;beretta;colt45" );
	// setDvar( "class_assault_secondary_attachment", "none" );
	// setDvar( "class_assault_perk1", "specialty_null" );
	// setDvar( "class_assault_perk2", "specialty_bulletdamage" );
	// setDvar( "class_assault_perk3", "specialty_longersprint" );
	// setDvar( "class_assault_sgrenade", "concussion_grenade" );
	// setDvar( "class_assault_camo", "camo_none" );
	// setDvar( "class_assault_pgrenade_count", "1" );
	// setDvar( "class_assault_sgrenade_count", "1" );
	// setDvar( "class_assault_lock_primary", "0" );
	// setDvar( "class_assault_lock_primary_attachment", "0" );
	// setDvar( "class_assault_lock_secondary", "0" );
	// setDvar( "class_assault_lock_perk1", "0" );
	// setDvar( "class_assault_lock_perk2", "0" );
	// setDvar( "class_assault_lock_perk3", "0" );
	// setDvar( "class_assault_lock_sgrenade", "0" );
	// setDvar( "weap_allow_specops_mp5", "1" );
	// setDvar( "weap_allow_specops_skorpion", "1" );
	// setDvar( "weap_allow_specops_uzi", "1" );
	// setDvar( "weap_allow_specops_ak74u", "1" );
	// setDvar( "weap_allow_specops_p90", "1" );
	// setDvar( "attach_allow_specops_none", "1" );
	// setDvar( "attach_allow_specops_reflex", "1" );
	// setDvar( "attach_allow_specops_silencer", "1" );
	// setDvar( "attach_allow_specops_acog", "1" );
	// setDvar( "class_specops_primary", "mp5;mp5;p90" );
	// setDvar( "class_specops_primary_attachment", "none" );
	// setDvar( "class_specops_secondary", "usp;usp;colt45" );
	// setDvar( "class_specops_secondary_attachment", "silencer" );
	// setDvar( "class_specops_perk1", "c4_mp" );
	// setDvar( "class_specops_perk2", "specialty_explosivedamage" );
	// setDvar( "class_specops_perk3", "specialty_bulletaccuracy" );
	// setDvar( "class_specops_sgrenade", "flash_grenade" );
	// setDvar( "class_specops_camo", "camo_none" );
	// setDvar( "class_specops_pgrenade_count", "1" );
	// setDvar( "class_specops_sgrenade_count", "1" );
	// setDvar( "class_specops_lock_primary", "0" );
	// setDvar( "class_specops_lock_primary_attachment", "0" );
	// setDvar( "class_specops_lock_secondary", "0" );
	// setDvar( "class_specops_lock_perk1", "0" );
	// setDvar( "class_specops_lock_perk2", "0" );
	// setDvar( "class_specops_lock_perk3", "0" );
	// setDvar( "class_specops_lock_sgrenade", "0" );
	// setDvar( "weap_allow_heavygunner_saw", "1" );
	// setDvar( "weap_allow_heavygunner_rpd", "1" );
	// setDvar( "weap_allow_heavygunner_m60e4", "1" );
	// setDvar( "attach_allow_heavygunner_none", "1" );
	// setDvar( "attach_allow_heavygunner_reflex", "1" );
	// setDvar( "attach_allow_heavygunner_grip", "1" );
	// setDvar( "attach_allow_heavygunner_acog", "1" );
	// setDvar( "class_heavygunner_primary", "saw;saw;rpd" );
	// setDvar( "class_heavygunner_primary_attachment", "none" );
	// setDvar( "class_heavygunner_secondary", "usp;usp;colt45" );
	// setDvar( "class_heavygunner_secondary_attachment", "none" );
	// setDvar( "class_heavygunner_perk1", "specialty_specialgrenade" );
	// setDvar( "class_heavygunner_perk2", "specialty_armorvest" );
	// setDvar( "class_heavygunner_perk3", "specialty_bulletpenetration" );
	// setDvar( "class_heavygunner_sgrenade", "concussion_grenade" );
	// setDvar( "class_heavygunner_camo", "camo_none" );
	// setDvar( "class_heavygunner_pgrenade_count", "1" );
	// setDvar( "class_heavygunner_sgrenade_count", "1" );
	// setDvar( "class_heavygunner_lock_primary", "0" );
	// setDvar( "class_heavygunner_lock_primary_attachment", "0" );
	// setDvar( "class_heavygunner_lock_secondary", "0" );
	// setDvar( "class_heavygunner_lock_perk1", "0" );
	// setDvar( "class_heavygunner_lock_perk2", "0" );
	// setDvar( "class_heavygunner_lock_perk3", "0" );
	// setDvar( "class_heavygunner_lock_sgrenade", "0" );
	// setDvar( "weap_allow_demolitions_winchester1200", "1" );
	// setDvar( "weap_allow_demolitions_m1014", "1" );
	// setDvar( "attach_allow_shotgun_none", "1" );
	// setDvar( "attach_allow_shotgun_reflex", "1" );
	// setDvar( "attach_allow_shotgun_grip", "1" );
	// setDvar( "class_demolitions_primary", "winchester1200;m1014;winchester1200" );
	// setDvar( "class_demolitions_primary_attachment", "none" );
	// setDvar( "class_demolitions_secondary", "beretta;beretta;colt45" );
	// setDvar( "class_demolitions_secondary_attachment", "none" );
	// setDvar( "class_demolitions_perk1", "rpg_mp" );
	// setDvar( "class_demolitions_perk2", "specialty_explosivedamage" );
	// setDvar( "class_demolitions_perk3", "specialty_longersprint" );
	// setDvar( "class_demolitions_sgrenade", "smoke_grenade" );
	// setDvar( "class_demolitions_camo", "camo_none" );
	// setDvar( "class_demolitions_pgrenade_count", "1" );
	// setDvar( "class_demolitions_sgrenade_count", "1" );
	// setDvar( "class_demolitions_lock_primary", "0" );
	// setDvar( "class_demolitions_lock_primary_attachment", "0" );
	// setDvar( "class_demolitions_lock_secondary", "0" );
	// setDvar( "class_demolitions_lock_perk1", "0" );
	// setDvar( "class_demolitions_lock_perk2", "0" );
	// setDvar( "class_demolitions_lock_perk3", "0" );
	// setDvar( "class_demolitions_lock_sgrenade", "0" );
	// setDvar( "weap_allow_sniper_dragunov", "1" );
	// setDvar( "weap_allow_sniper_m40a3", "1" );
	// setDvar( "weap_allow_sniper_barrett", "1" );
	// setDvar( "weap_allow_sniper_remington700", "1" );
	// setDvar( "weap_allow_sniper_m21", "1" );
	// setDvar( "attach_allow_sniper_none", "1" );
	// setDvar( "attach_allow_sniper_acog", "1" );
	// setDvar( "class_sniper_primary", "m40a3;m40a3;dragunov" );
	// setDvar( "class_sniper_primary_attachment", "none" );
	// setDvar( "class_sniper_secondary", "beretta;beretta;colt45" );
	// setDvar( "class_sniper_secondary_attachment", "silencer" );
	// setDvar( "class_sniper_perk1", "specialty_specialgrenade" );
	// setDvar( "class_sniper_perk2", "specialty_bulletdamage" );
	// setDvar( "class_sniper_perk3", "specialty_bulletpenetration" );
	// setDvar( "class_sniper_sgrenade", "flash_grenade" );
	// setDvar( "class_sniper_camo", "camo_none" );
	// setDvar( "class_sniper_pgrenade_count", "1" );
	// setDvar( "class_sniper_sgrenade_count", "1" );
	// setDvar( "class_sniper_lock_primary", "0" );
	// setDvar( "class_sniper_lock_primary_attachment", "0" );
	// setDvar( "class_sniper_lock_secondary", "0" );
	// setDvar( "class_sniper_lock_perk1", "0" );
	// setDvar( "class_sniper_lock_perk2", "0" );
	// setDvar( "class_sniper_lock_perk3", "0" );
	// setDvar( "class_sniper_lock_sgrenade", "0" );

	//******************************************************************************
	// configs/gameplay/fitnesscs.cfg
	//******************************************************************************
	// setDvar( "scr_fcs_enabled", "0" );
	// setDvar( "scr_fcs_crouch_on_spawn", "1" );
	// setDvar( "scr_fcs_sprint_delay", "0" );
	// setDvar( "scr_fcs_jump_allowed", "1" );
	// setDvar( "scr_fcs_jump_penalty", "40" );
	// setDvar( "scr_player_sprinttime", "4" );
	// setDvar( "scr_fcs_sprint_recovery_time", "2" );
	// setDvar( "scr_fcs_sprint_recovery_delay", "5" );
	// setDvar( "scr_fcs_sprint_slowsdown_max", "30" );
	// setDvar( "scr_fcs_walk_without_ads_allowed", "1" );
	// setDvar( "scr_fcs_pulse_enabled", "0" );
	// setDvar( "scr_fcs_pulse_modifier", "1.0" );

	//******************************************************************************
	// configs/gameplay/hardpoints.cfg
	//******************************************************************************
	// setDvar( "scr_game_hardpoints", "1" );
	// setDvar( "scr_hardpoint_show_reminder", "0" );
	// setDvar( "scr_remove_hardpoint_on_death", "0" );
	// setDvar( "scr_game_hardpoints_cycle", "0" );
	// setDvar( "scr_game_hardpoints_mode", "0" );
	// setDvar( "scr_announce_killstreak", "1" );
	// setDvar( "scr_hardpoint_allow_uav", "1" );
	// setDvar( "scr_game_forceuav", "0" );
	// setDvar( "scr_hardpoint_uav_streak", "3" );
	// setDvar( "scr_uav_view_time", "15" );
	// setDvar( "scr_announce_enemy_uav_online", "1" );
	// setDvar( "scr_uav_show_hardpoints", "1" );
	// setDvar( "scr_hardpoint_allow_airstrike", "1" );
	// setDvar( "scr_hardpoint_airstrike_streak", "5" );
	// setDvar( "scr_airstrike_hardpoint_interval", "0" );
	// setDvar( "scr_announce_enemy_airstrike_inbound", "1" );
	// setDvar( "scr_airstrike_kills_toward_streak", "1" );
	// setDvar( "scr_airstrike_delay", "0" );
	// setDvar( "scr_hardpoint_allow_helicopter", "1" );
	// setDvar( "scr_hardpoint_helicopter_streak", "7" );
	// setDvar( "scr_heli_hardpoint_interval", "0" );
	// setDvar( "scr_announce_enemy_heli_inbound", "1" );
	// setDvar( "scr_helicopter_kills_toward_streak", "1" );
	// setDvar( "scr_helicopter_delay", "0" );
	// setDvar( "scr_heli_maxhealth", "1300" );
	// setDvar( "scr_heli_target_recognition", "0.30" );

	//******************************************************************************
	// configs/gameplay/healthsystem.cfg
	//******************************************************************************
	setDvar( "scr_player_maxhealth", "100" );
	setDvar( "scr_healthregen_method", "2" );
	setDvar( "scr_player_healthregentime", "5" );
	setDvar( "scr_health_pain_sound", "3" );
	setDvar( "scr_health_death_sound", "1" );
	setDvar( "scr_health_hurt_sound", "1" );
	// setDvar( "scr_healthsystem_show_healthbar", "0" );
	// setDvar( "scr_healthsystem_bleeding_enable", "0" );
	// setDvar( "scr_healthsystem_bleeding_percentage", "0" );
	// setDvar( "scr_healthsystem_bleeding_icon", "1" );
	// setDvar( "scr_healthsystem_bandage_start", "3" );
	// setDvar( "scr_healthsystem_bandage_max", "5" );
	// setDvar( "scr_healthsystem_bandage_self", "1" );
	// setDvar( "scr_healthsystem_bandage_time", "3" );
	// setDvar( "scr_healthsystem_medic_enable", "0" );
	// setDvar( "scr_healthsystem_medic_bandaging", "1" );
	// setDvar( "scr_healthsystem_medic_healing", "1" );
	// setDvar( "scr_healthsystem_medic_healing_self", "1" );
	// setDvar( "scr_healthsystem_medic_healing_health", "25" );
	// setDvar( "scr_healthsystem_medic_healing_time", "3" );
	// setDvar( "scr_healthsystem_medic_take_bandage", "0" );
	// setDvar( "scr_healthsystem_healing_icon", "1" );
	// setDvar( "scr_healthsystem_healthpacks_enable", "0" );
	// setDvar( "scr_healthsystem_healthpacks_timeout", "60" );
	// setDvar( "scr_healthsystem_healthpacks_health", "25" );
	// setDvar( "scr_healthsystem_healthpacks_random_health", "0" );

	//******************************************************************************
	// configs/gameplay/hud.cfg
	//******************************************************************************
	setDvar( "scr_hardcore", "0" );
	setDvar( "scr_adjust_progress_bars", "1" );
	// setDvar( "scr_show_player_assignment", "0" );
	// setDvar( "scr_enable_globalchat", "1" );
	// setDvar( "scr_enable_deadchat", "0" );
	// setDvar( "scr_show_guid_on_firstspawn", "0" );
	// setDvar( "scr_relocate_chat_position", "0" );
	// setDvar( "scr_enable_hiticon", "1" );
	// setDvar( "scr_enable_bodyarmor_feedback", "1" );
	// setDvar( "scr_hud_show_enemy_names", "1" );
	// setDvar( "scr_hud_show_friendly_names", "1" );
	// setDvar( "scr_hud_show_friendly_names_distance", "10000" );
	// setDvar( "scr_hud_show_death_icons", "1" );
	// setDvar( "scr_hud_show_redcrosshairs", "1" );
	// setDvar( "scr_hud_show_grenade_indicator", "1" );
	// setDvar( "scr_hud_show_mantle_hint", "1" );
	// setDvar( "scr_hud_show_xp_points", "1" );
	// setDvar( "scr_hud_show_center_obituary", "1" );
	// setDvar( "scr_show_obituaries", "1" );
	// setDvar( "scr_show_ext_obituaries", "0" );
	// setDvar( "scr_ext_obituaries_unit", "meters" );
	// setDvar( "scr_hud_show_scores", "1" );
	setDvar( "scr_hud_show_stance", "1" );
	// setDvar( "scr_hud_show_2dicons", "1" );
	// setDvar( "scr_hud_show_3dicons", "1" );
	// setDvar( "scr_hardcore_show_minimap", "0" );
	setDvar( "scr_hardcore_show_compass", "1" );
	// setDvar( "scr_hud_compass_objectives", "0" );
	// setDvar( "scr_minimap_show_enemies_firing", "0" );
	setDvar( "scr_blackscreen_enable", "1" );
	setDvar( "scr_blackscreen_fadetime", "3" );
	// setDvar( "scr_blackscreen_spectators", "0" );
	// setDvar( "scr_blackscreen_spectators_guids", "" );
	// setDvar( "scr_bob_effect_enable", "1" );
	// setDvar( "scr_show_general_blood_splatters", "0" );
	// setDvar( "scr_show_headshot_blood_splatters", "0" );
	// setDvar( "scr_show_knifed_blood_splatters", "0" );
	// setDvar( "scr_drawfriend", "0" );
	setDvar( "scr_hud_show_inventory", "1" );
	// setDvar( "scr_show_player_status", "1" );
	// setDvar( "scr_show_team_status", "0" );
	// setDvar( "scr_hide_scores", "0" );
	// setDvar( "scr_thirdperson_enable", "0" );
	// setDvar( "scr_realtime_stats_enable", "0" );
	// setDvar( "scr_realtime_stats_default_on", "1" );
	// setDvar( "scr_realtime_stats_unit", "meters" );

	//******************************************************************************
	// configs/gameplay/others.cfg
	//******************************************************************************
	// setDvar( "scr_team_fftype", "0" );
	// setDvar( "scr_team_teamkillpointloss", "0" );
	// setDvar( "scr_team_teamkillspawndelay", "0" );
	// setDvar( "scr_game_deathpointloss", "0" );
	// setDvar( "scr_game_suicidepointloss", "0" );
	// setDvar( "scr_player_suicidespawndelay", "0" );
	// setDvar( "scr_game_allow_killcam", "0" );
	// setDvar( "scr_player_forcerespawn", "1" );
	// setDvar( "scr_com_maxfps", "0" );
	// setDvar( "scr_cl_maxpackets", "0" );
	// setDvar( "scr_quickactions_enable", "0" );
	setDvar( "scr_fallDamageMinHeight", "175" );
	setDvar( "scr_fallDamageMaxHeight", "350" );
	// setDvar( "scr_jump_height", "39" );
	// setDvar( "scr_jump_slowdown_enable", "1" );
	// setDvar( "scr_dogtags_enable", "0" );
	setDvar( "scr_bodyremoval_enable", "2" );
	// setDvar( "scr_bodyremoval_time", "20" );
	// setDvar( "scr_bullet_penetration_enabled", "1" );
	setDvar( "scr_enable_spawn_protection", "1" );
	// setDvar( "scr_spawn_protection_invisible", "0" );
	// setDvar( "scr_spawn_protection_time", "4" );
	// setDvar( "scr_spawn_protection_hiticon", "1" );
	// setDvar( "scr_spawn_protection_maxdistance", "0" );
	// setDvar( "scr_spawn_protection_punishment_time", "0" );
	// setDvar( "scr_enable_anti_bunny_hopping", "0" );
	// setDvar( "scr_enable_anti_dolphin_dive", "0" );
	// setDvar( "scr_anti_camping_enable", "0" );
	// setDvar( "scr_anti_camping_show", "0" );
	// setDvar( "scr_anti_camping_message", "" );
	// setDvar( "scr_anti_camping_distance", "100" );
	// setDvar( "scr_anti_camping_time", "60" );
	// setDvar( "scr_de_dropweapon_on_arm_hit", "0" );
	// setDvar( "scr_de_dropweapon_chance", "50" );
	// setDvar( "scr_de_falldown_on_leg_hit", "0" );
	// setDvar( "scr_de_falldown_chance", "50" );
	// setDvar( "scr_de_shiftview_on_damage", "0" );
	// setDvar( "scr_de_break_ankle_on_fall", "0" );
	// setDvar( "scr_de_slowdown_on_leg_hit", "0" );
	// setDvar( "scr_cap_enable", "0" );
	// setDvar( "scr_cap_time", "5.0" );
	// setDvar( "scr_cap_firstspawn", "0" );

	//******************************************************************************
	// configs/gameplay/perks.cfg
	//******************************************************************************
	// setDvar( "perk_allow_c4_mp", "1" );
	// setDvar( "perk_allow_specialty_specialgrenade", "1" );
	// setDvar( "perk_allow_rpg_mp", "1" );
	// setDvar( "perk_allow_claymore_mp", "1" );
	// setDvar( "perk_allow_specialty_fraggrenade", "1" );
	// setDvar( "perk_allow_specialty_extraammo", "1" );
	// setDvar( "perk_allow_specialty_detectexplosive", "1" );
	// setDvar( "perk_c4_mp_limit", "64" );
	// setDvar( "perk_rpg_mp_limit", "64" );
	// setDvar( "perk_claymore_mp_limit", "64" );
	// setDvar( "specialty_fraggrenade_ammo_count", "2" );
	// setDvar( "specialty_specialgrenade_ammo_count", "2" );
	// setDvar( "perk_allow_specialty_bulletdamage", "1" );
	// setDvar( "perk_allow_specialty_armorvest", "1" );
	// setDvar( "perk_allow_specialty_fastreload", "1" );
	// setDvar( "perk_allow_specialty_rof", "1" );
	// setDvar( "perk_allow_specialty_twoprimaries", "1" );
	// setDvar( "perk_allow_specialty_gpsjammer", "1" );
	// setDvar( "perk_allow_specialty_explosivedamage", "1" );
	// setDvar( "perk_armorvest", "75" );
	// setDvar( "perk_bulletdamage", "40" );
	// setDvar( "perk_explosivedamage", "25" );
	// setDvar( "perk_allow_specialty_longersprint", "1" );
	// setDvar( "perk_allow_specialty_bulletaccuracy", "1" );
	// setDvar( "perk_allow_specialty_pistoldeath", "1" );
	// setDvar( "perk_allow_specialty_grenadepulldeath", "1" );
	// setDvar( "perk_allow_specialty_bulletpenetration", "1" );
	// setDvar( "perk_allow_specialty_holdbreath", "1" );
	// setDvar( "perk_allow_specialty_quieter", "1" );
	// setDvar( "perk_allow_specialty_parabolic", "1" );
	setDvar( "specialty_grenadepulldeath_check_frags", "1" );
	setDvar( "specialty_pistoldeath_check_pistol", "1" );
	// setDvar( "perk_assault_allow_c4_mp", "1" );
	// setDvar( "perk_specops_allow_c4_mp", "1" );
	// setDvar( "perk_heavygunner_allow_c4_mp", "1" );
	// setDvar( "perk_demolitions_allow_c4_mp", "1" );
	// setDvar( "perk_sniper_allow_c4_mp", "1" );
	// setDvar( "perk_assault_allow_specialty_specialgrenade", "1" );
	// setDvar( "perk_specops_allow_specialty_specialgrenade", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_specialgrenade", "1" );
	// setDvar( "perk_demolitions_allow_specialty_specialgrenade", "1" );
	// setDvar( "perk_sniper_allow_specialty_specialgrenade", "1" );
	// setDvar( "perk_assault_allow_rpg_mp", "1" );
	// setDvar( "perk_specops_allow_rpg_mp", "1" );
	// setDvar( "perk_heavygunner_allow_rpg_mp", "1" );
	// setDvar( "perk_demolitions_allow_rpg_mp", "1" );
	// setDvar( "perk_sniper_allow_rpg_mp", "1" );
	// setDvar( "perk_assault_allow_claymore_mp", "1" );
	// setDvar( "perk_specops_allow_claymore_mp", "1" );
	// setDvar( "perk_heavygunner_allow_claymore_mp", "1" );
	// setDvar( "perk_demolitions_allow_claymore_mp", "1" );
	// setDvar( "perk_sniper_allow_claymore_mp", "1" );
	// setDvar( "perk_assault_allow_specialty_fraggrenade", "1" );
	// setDvar( "perk_specops_allow_specialty_fraggrenade", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_fraggrenade", "1" );
	// setDvar( "perk_demolitions_allow_specialty_fraggrenade", "1" );
	// setDvar( "perk_sniper_allow_specialty_fraggrenade", "1" );
	// setDvar( "perk_assault_allow_specialty_extraammo", "1" );
	// setDvar( "perk_specops_allow_specialty_extraammo", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_extraammo", "1" );
	// setDvar( "perk_demolitions_allow_specialty_extraammo", "1" );
	// setDvar( "perk_sniper_allow_specialty_extraammo", "1" );
	// setDvar( "perk_assault_allow_specialty_detectexplosive", "1" );
	// setDvar( "perk_specops_allow_specialty_detectexplosive", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_detectexplosive", "1" );
	// setDvar( "perk_demolitions_allow_specialty_detectexplosive", "1" );
	// setDvar( "perk_sniper_allow_specialty_detectexplosive", "1" );
	// setDvar( "perk_assault_allow_specialty_bulletdamage", "1" );
	// setDvar( "perk_specops_allow_specialty_bulletdamage", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_bulletdamage", "1" );
	// setDvar( "perk_demolitions_allow_specialty_bulletdamage", "1" );
	// setDvar( "perk_sniper_allow_specialty_bulletdamage", "1" );
	// setDvar( "perk_assault_allow_specialty_armorvest", "1" );
	// setDvar( "perk_specops_allow_specialty_armorvest", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_armorvest", "1" );
	// setDvar( "perk_demolitions_allow_specialty_armorvest", "1" );
	// setDvar( "perk_sniper_allow_specialty_armorvest", "1" );
	// setDvar( "perk_assault_allow_specialty_fastreload", "1" );
	// setDvar( "perk_specops_allow_specialty_fastreload", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_fastreload", "1" );
	// setDvar( "perk_demolitions_allow_specialty_fastreload", "1" );
	// setDvar( "perk_sniper_allow_specialty_fastreload", "1" );
	// setDvar( "perk_assault_allow_specialty_rof", "1" );
	// setDvar( "perk_specops_allow_specialty_rof", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_rof", "1" );
	// setDvar( "perk_demolitions_allow_specialty_rof", "1" );
	// setDvar( "perk_sniper_allow_specialty_rof", "1" );
	// setDvar( "perk_assault_allow_specialty_gpsjammer", "1" );
	// setDvar( "perk_specops_allow_specialty_gpsjammer", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_gpsjammer", "1" );
	// setDvar( "perk_demolitions_allow_specialty_gpsjammer", "1" );
	// setDvar( "perk_sniper_allow_specialty_gpsjammer", "1" );
	// setDvar( "perk_assault_allow_specialty_explosivedamage", "1" );
	// setDvar( "perk_specops_allow_specialty_explosivedamage", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_explosivedamage", "1" );
	// setDvar( "perk_demolitions_allow_specialty_explosivedamage", "1" );
	// setDvar( "perk_sniper_allow_specialty_explosivedamage", "1" );
	// setDvar( "perk_assault_allow_specialty_longersprint", "1" );
	// setDvar( "perk_specops_allow_specialty_longersprint", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_longersprint", "1" );
	// setDvar( "perk_demolitions_allow_specialty_longersprint", "1" );
	// setDvar( "perk_sniper_allow_specialty_longersprint", "1" );
	// setDvar( "perk_assault_allow_specialty_bulletaccuracy", "1" );
	// setDvar( "perk_specops_allow_specialty_bulletaccuracy", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_bulletaccuracy", "1" );
	// setDvar( "perk_demolitions_allow_specialty_bulletaccuracy", "1" );
	// setDvar( "perk_sniper_allow_specialty_bulletaccuracy", "1" );
	// setDvar( "perk_assault_allow_specialty_pistoldeath", "1" );
	// setDvar( "perk_specops_allow_specialty_pistoldeath", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_pistoldeath", "1" );
	// setDvar( "perk_demolitions_allow_specialty_pistoldeath", "1" );
	// setDvar( "perk_sniper_allow_specialty_pistoldeath", "1" );
	// setDvar( "perk_assault_allow_specialty_grenadepulldeath", "1" );
	// setDvar( "perk_specops_allow_specialty_grenadepulldeath", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_grenadepulldeath", "1" );
	// setDvar( "perk_demolitions_allow_specialty_grenadepulldeath", "1" );
	// setDvar( "perk_sniper_allow_specialty_grenadepulldeath", "1" );
	// setDvar( "perk_assault_allow_specialty_bulletpenetration", "1" );
	// setDvar( "perk_specops_allow_specialty_bulletpenetration", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_bulletpenetration", "1" );
	// setDvar( "perk_demolitions_allow_specialty_bulletpenetration", "1" );
	// setDvar( "perk_sniper_allow_specialty_bulletpenetration", "1" );
	// setDvar( "perk_assault_allow_specialty_holdbreath", "1" );
	// setDvar( "perk_specops_allow_specialty_holdbreath", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_holdbreath", "1" );
	// setDvar( "perk_demolitions_allow_specialty_holdbreath", "1" );
	// setDvar( "perk_sniper_allow_specialty_holdbreath", "1" );
	// setDvar( "perk_assault_allow_specialty_quieter", "1" );
	// setDvar( "perk_specops_allow_specialty_quieter", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_quieter", "1" );
	// setDvar( "perk_demolitions_allow_specialty_quieter", "1" );
	// setDvar( "perk_sniper_allow_specialty_quieter", "1" );
	// setDvar( "perk_assault_allow_specialty_parabolic", "1" );
	// setDvar( "perk_specops_allow_specialty_parabolic", "1" );
	// setDvar( "perk_heavygunner_allow_specialty_parabolic", "1" );
	// setDvar( "perk_demolitions_allow_specialty_parabolic", "1" );
	// setDvar( "perk_sniper_allow_specialty_parabolic", "1" );

	//******************************************************************************
	// configs/gameplay/scores.cfg
	//******************************************************************************
	// setDvar( "scr_enable_scoresystem", "0" );
	// setDvar( "scr_score_tk_affects_teamscore", "0" );
	// setDvar( "scr_score_standard_kill", "10" );
	// setDvar( "scr_score_headshot_kill", "10" );
	// setDvar( "scr_score_melee_kill", "10" );
	// setDvar( "scr_score_grenade_kill", "10" );
	// setDvar( "scr_score_vehicle_explosion_kill", "10" );
	// setDvar( "scr_score_barrel_explosion_kill", "10" );
	// setDvar( "scr_score_c4_kill", "10" );
	// setDvar( "scr_score_claymore_kill", "10" );
	// setDvar( "scr_score_rpg_kill", "10" );
	// setDvar( "scr_score_grenade_launcher_kill", "10" );
	// setDvar( "scr_score_airstrike_kill", "10" );
	// setDvar( "scr_score_helicopter_kill", "10" );
	// setDvar( "scr_score_assist_kill", "2" );
	// setDvar( "scr_score_assist_25_kill", "3" );
	// setDvar( "scr_score_assist_50_kill", "4" );
	// setDvar( "scr_score_assist_75_kill", "5" );
	// setDvar( "scr_score_player_death", "0" );
	// setDvar( "scr_score_player_suicide", "0" );
	// setDvar( "scr_score_player_teamkill", "-5" );
	// setDvar( "scr_score_hardpoint_used", "10" );
	// setDvar( "scr_score_shot_down_helicopter", "0" );
	// setDvar( "scr_score_capture_objective", "30" );
	// setDvar( "scr_score_take_objective", "7" );
	// setDvar( "scr_score_return_objective", "7" );
	// setDvar( "scr_score_defend_objective", "30" );
	// setDvar( "scr_score_holding_objective", "2" );
	// setDvar( "scr_score_kill_objective_carrier", "5" );
	// setDvar( "scr_score_assault_objective", "5" );
	// setDvar( "scr_score_plant_bomb", "20" );
	// setDvar( "scr_score_defuse_bomb", "15" );

	//******************************************************************************
	// configs/gameplay/sounds.cfg
	//******************************************************************************
	// setDvar( "scr_tactical_enable", "0" );
	// setDvar( "scr_countdown_sounds", "" );
	// setDvar( "scr_play_headshot_impact_sound", "1" );
	// setDvar( "scr_unreal_firstblood_sound", "0" );
	// setDvar( "scr_unreal_headshot_sound", "0" );
	// setDvar( "scr_killingspree_enable", "0" );
	// setDvar( "scr_killingspree_sounds", "2 doublekill;5 killingspree;7 rampage;9 dominating;12 unstoppable;15 godlike" );
	// setDvar( "scr_allowbattlechatter", "1" );
	// setDvar( "scr_battlechatter_reload_probability", "75" );
	// setDvar( "scr_battlechatter_frag_out_probability", "75" );
	// setDvar( "scr_battlechatter_flash_out_probability", "75" );
	// setDvar( "scr_battlechatter_smoke_out_probability", "75" );
	// setDvar( "scr_battlechatter_concussion_out_probability", "75" );
	// setDvar( "scr_battlechatter_c4_planted_probability", "75" );
	// setDvar( "scr_battlechatter_claymore_planted_probability", "75" );
	// setDvar( "scr_battlechatter_kill_probability", "75" );

	//******************************************************************************
	// configs/gameplay/spectate.cfg
	//******************************************************************************
	setDvar( "scr_game_spectatetype", "1" );
	setDvar( "scr_game_spectatetype_dm", "0" );
	setDvar( "scr_game_spectatetype_gg", "0" );
	setDvar( "scr_game_spectatetype_spectators", "2" );
	// setDvar( "scr_game_spectators_guids", "" );
	// setDvar( "scr_allow_thirdperson", "0" );
	// setDvar( "scr_allow_thirdperson_guids", "" );

	//******************************************************************************
	// configs/gameplay/visuals.cfg
	//******************************************************************************
	// setDvar( "scr_map_special_fx_enable", "1" );
	// setDvar( "scr_show_fog", "1" );
	// setDvar( "scr_dcs_enabled", "0" );
	// setDvar( "scr_dcs_dawn_length", "10" );
	// setDvar( "scr_dcs_day_length", "20" );
	// setDvar( "scr_dcs_dusk_length", "10" );
	// setDvar( "scr_dcs_night_length", "20" );
	// setDvar( "scr_dcs_first_cycle", "1" );
	// setDvar( "scr_dcs_sounds_enable", "1" );
	// setDvar( "scr_dcs_reset_cycle", "0" );
	
	//******************************************************************************
	// configs/gameplay/wdm.cfg
	//******************************************************************************
	// setDvar( "scr_wdm_enabled", "0" );
	// setDvar( "scr_wdm_m16", "100" );
	// setDvar( "scr_wdm_m16_silenced", "100" );
	// setDvar( "scr_wdm_ak47", "100" );
	// setDvar( "scr_wdm_ak47_silenced", "100" );
	// setDvar( "scr_wdm_m4", "100" );
	// setDvar( "scr_wdm_m4_silenced", "100" );
	// setDvar( "scr_wdm_g3", "100" );
	// setDvar( "scr_wdm_g3_silenced", "100" );
	// setDvar( "scr_wdm_g36c", "100" );
	// setDvar( "scr_wdm_g36c_silenced", "100" );
	// setDvar( "scr_wdm_m14", "100" );
	// setDvar( "scr_wdm_m14_silenced", "100" );
	// setDvar( "scr_wdm_mp44", "100" );
	// setDvar( "scr_wdm_mp5", "100" );
	// setDvar( "scr_wdm_mp5_silenced", "100" );
	// setDvar( "scr_wdm_skorpion", "100" );
	// setDvar( "scr_wdm_skorpion_silenced", "100" );
	// setDvar( "scr_wdm_uzi", "100" );
	// setDvar( "scr_wdm_uzi_silenced", "100" );
	// setDvar( "scr_wdm_ak74u", "100" );
	// setDvar( "scr_wdm_ak74u_silenced", "100" );
	// setDvar( "scr_wdm_p90", "100" );
	// setDvar( "scr_wdm_p90_silenced", "100" );
	// setDvar( "scr_wdm_m1014", "100" );
	// setDvar( "scr_wdm_winchester1200", "100" );
	// setDvar( "scr_wdm_saw", "100" );
	// setDvar( "scr_wdm_rpd", "100" );
	// setDvar( "scr_wdm_m60e4", "100" );
	// setDvar( "scr_wdm_dragunov", "100" );
	// setDvar( "scr_wdm_m40a3", "100" );
	// setDvar( "scr_wdm_barrett", "100" );
	// setDvar( "scr_wdm_remington700", "100" );
	// setDvar( "scr_wdm_m21", "100" );
	// setDvar( "scr_wdm_beretta", "100" );
	// setDvar( "scr_wdm_beretta_silenced", "100" );
	// setDvar( "scr_wdm_colt45", "100" );
	// setDvar( "scr_wdm_colt45_silenced", "100" );
	// setDvar( "scr_wdm_usp", "100" );
	// setDvar( "scr_wdm_usp_silenced", "100" );
	// setDvar( "scr_wdm_deserteagle", "100" );
	// setDvar( "scr_wdm_deserteaglegold", "100" );
	// setDvar( "scr_wdm_frag_grenades", "100" );
	// setDvar( "scr_wdm_gl", "100" );
	// setDvar( "scr_wdm_c4", "100" );
	// setDvar( "scr_wdm_claymore", "100" );
	// setDvar( "scr_wdm_rpg", "100" );
	// setDvar( "scr_wdm_vehicles", "100" );
	// setDvar( "scr_wdm_barrels", "100" );

	//******************************************************************************
	// configs/gameplay/weapons.cfg
	//******************************************************************************					
	// setDvar( "scr_dynamic_attachments_enable", "0" );
	setDvar( "scr_deleteexplosivesonspawn", "1" );
	// setDvar( "scr_deleteexplosivesondeath", "0" );
	// setDvar( "scr_explosives_allow_disarm", "0" );
	// setDvar( "scr_explosives_disarm_time", "5" );
	// setDvar( "scr_claymore_show_headicon", "1" );
	// setDvar( "scr_claymore_show_laser_beams", "1" );
	// setDvar( "scr_claymore_friendly_fire", "0" );
	// setDvar( "scr_claymore_arm_time", "0" );
	// setDvar( "scr_claymore_check_plant_distance", "0" );
	// setDvar( "scr_show_c4_blink_effect", "1" );
	// setDvar( "scr_allow_stationary_turrets", "1" );
	// setDvar( "scr_delay_frag_grenades", "0" );
	// setDvar( "scr_delay_grenade_launchers", "0" );
	// setDvar( "scr_delay_smoke_grenades", "0" );
	// setDvar( "scr_delay_flash_grenades", "0" );
	// setDvar( "scr_delay_concussion_grenades", "0" );
	// setDvar( "scr_delay_rpgs", "0" );
	// setDvar( "scr_delay_c4s", "0" );
	// setDvar( "scr_delay_claymores", "0" );
	// setDvar( "scr_delay_only_round_start", "1" );
	// setDvar( "scr_delay_sound_enable", "1" );
	// setDvar( "scr_concussion_grenades_base_time", "4" );
	// setDvar( "scr_enable_auto_melee", "1" );
	// setDvar( "scr_limit_planted_claymores", "0" );
	// setDvar( "scr_limit_planted_c4s", "0" );
	// setDvar( "scr_fire_tracer_chance", "0.2" );
	// setDvar( "scr_barrel_damage_enable", "1" );
	// setDvar( "scr_vehicle_damage_enable", "1" );
	// setDvar( "scr_rng_enabled", "0" );
	// setDvar( "scr_rng_distance", "200" );
	// setDvar( "scr_rng_damage_closer", "50" );
	// setDvar( "scr_rng_damage_longer", "5" );
	// setDvar( "scr_weaponjams_enable", "0" );
	// setDvar( "scr_weaponjams_probability", "250" );
	// setDvar( "scr_weaponjams_gap_time", "0" );
	// setDvar( "scr_sniperzoom_enable", "0" );
	// setDvar( "scr_sniperzoom_lower_levels", "8" );
	// setDvar( "scr_sniperzoom_upper_levels", "9" );
	// setDvar( "scr_rangefinder_enable", "0" );
	// setDvar( "scr_objective_safezone_enable", "0" );
	// setDvar( "scr_objective_safezone_radius", "100" );
	
	//******************************************************************************
	// configs/gameplay/wlm.cfg
	//******************************************************************************
	// setDvar( "scr_wlm_enabled", "0" );
	// setDvar( "scr_wlm_upper_arm", "100" );
	// setDvar( "scr_wlm_lower_arm", "100" );
	// setDvar( "scr_wlm_hand", "100" );
	// setDvar( "scr_wlm_upper_leg", "100" );
	// setDvar( "scr_wlm_lower_leg", "100" );
	// setDvar( "scr_wlm_foot", "100" );
	// setDvar( "scr_wlm_head", "100" );
	// setDvar( "scr_wlm_neck", "100" );
	// setDvar( "scr_wlm_upper_torso", "100" );
	// setDvar( "scr_wlm_lower_torso", "100" );
	
	//******************************************************************************
	// configs/gameplay/wrm.cfg
	//******************************************************************************
	// setDvar( "scr_wrm_enabled", "0" );
	// setDvar( "scr_wrm_m16", "215" );
	// setDvar( "scr_wrm_m16_silenced", "215" );
	// setDvar( "scr_wrm_ak47", "215" );
	// setDvar( "scr_wrm_ak47_silenced", "215" );
	// setDvar( "scr_wrm_m4", "215" );
	// setDvar( "scr_wrm_m4_silenced", "215" );
	// setDvar( "scr_wrm_g3", "215" );
	// setDvar( "scr_wrm_g3_silenced", "215" );
	// setDvar( "scr_wrm_g36c", "215" );
	// setDvar( "scr_wrm_g36c_silenced", "215" );
	// setDvar( "scr_wrm_m14", "215" );
	// setDvar( "scr_wrm_m14_silenced", "215" );
	// setDvar( "scr_wrm_mp44", "215" );
	// setDvar( "scr_wrm_mp5", "215" );
	// setDvar( "scr_wrm_mp5_silenced", "215" );
	// setDvar( "scr_wrm_skorpion", "215" );
	// setDvar( "scr_wrm_skorpion_silenced", "215" );
	// setDvar( "scr_wrm_uzi", "215" );
	// setDvar( "scr_wrm_uzi_silenced", "215" );
	// setDvar( "scr_wrm_ak74u", "215" );
	// setDvar( "scr_wrm_ak74u_silenced", "215" );
	// setDvar( "scr_wrm_p90", "215" );
	// setDvar( "scr_wrm_p90_silenced", "215" );
	// setDvar( "scr_wrm_m1014", "215" );
	// setDvar( "scr_wrm_winchester1200", "215" );
	// setDvar( "scr_wrm_saw", "215" );
	// setDvar( "scr_wrm_rpd", "215" );
	// setDvar( "scr_wrm_m60e4", "215" );
	// setDvar( "scr_wrm_dragunov", "215" );
	// setDvar( "scr_wrm_m40a3", "215" );
	// setDvar( "scr_wrm_barrett", "215" );
	// setDvar( "scr_wrm_remington700", "215" );
	// setDvar( "scr_wrm_m21", "215" );
	// setDvar( "scr_wrm_beretta", "215" );
	// setDvar( "scr_wrm_beretta_silenced", "215" );
	// setDvar( "scr_wrm_colt45", "215" );
	// setDvar( "scr_wrm_colt45_silenced", "215" );
	// setDvar( "scr_wrm_usp", "215" );
	// setDvar( "scr_wrm_usp_silenced", "215" );
	// setDvar( "scr_wrm_deserteagle", "215" );
	
	//******************************************************************************
	// configs/gameplay/wwm.cfg
	//******************************************************************************
	// setDvar( "scr_wwm_enabled", "0" );
	// setDvar( "scr_wwm_range_weight_1", "1.0" );
	// setDvar( "scr_wwm_range_speed_1", "1.10" );
	// setDvar( "scr_wwm_range_weight_2", "3.0" );
	// setDvar( "scr_wwm_range_speed_2", "1.00" );
	// setDvar( "scr_wwm_range_weight_3", "6.0" );
	// setDvar( "scr_wwm_range_speed_3", "0.80" );
	// setDvar( "scr_wwm_range_weight_4", "8.0" );
	// setDvar( "scr_wwm_range_speed_4", "0.70" );
	// setDvar( "scr_wwm_range_weight_5", "20.0" );
	// setDvar( "scr_wwm_range_speed_5", "0.60" );
	// setDvar( "scr_wwm_m16", "4" );
	// setDvar( "scr_wwm_ak47", "4" );
	// setDvar( "scr_wwm_m4", "4" );
	// setDvar( "scr_wwm_g3", "4" );
	// setDvar( "scr_wwm_g36c", "4" );
	// setDvar( "scr_wwm_m14", "4" );
	// setDvar( "scr_wwm_mp44", "4" );
	// setDvar( "scr_wwm_m16_gl", "5" );
	// setDvar( "scr_wwm_ak47_gl", "5" );
	// setDvar( "scr_wwm_m4_gl", "5" );
	// setDvar( "scr_wwm_g3_gl", "5" );
	// setDvar( "scr_wwm_g36c_gl", "5" );
	// setDvar( "scr_wwm_m14_gl", "5" );
	// setDvar( "scr_wwm_mp5", "2" );
	// setDvar( "scr_wwm_skorpion", "2" );
	// setDvar( "scr_wwm_uzi", "2" );
	// setDvar( "scr_wwm_ak74u", "2" );
	// setDvar( "scr_wwm_p90", "3" );
	// setDvar( "scr_wwm_m1014", "4" );
	// setDvar( "scr_wwm_winchester1200", "4" );
	// setDvar( "scr_wwm_saw", "9" );
	// setDvar( "scr_wwm_rpd", "9" );
	// setDvar( "scr_wwm_m60e4", "9" );
	// setDvar( "scr_wwm_dragunov", "4" );
	// setDvar( "scr_wwm_m40a3", "4" );
	// setDvar( "scr_wwm_barrett", "4" );
	// setDvar( "scr_wwm_remington700", "4" );
	// setDvar( "scr_wwm_m21", "4" );
	// setDvar( "scr_wwm_beretta", "0.5" );
	// setDvar( "scr_wwm_colt45", "0.5" );
	// setDvar( "scr_wwm_usp", "0.5" );
	// setDvar( "scr_wwm_deserteagle", "1" );
	// setDvar( "scr_wwm_deserteaglegold", "1" );
	// setDvar( "scr_wwm_bomb", "2" );
	// setDvar( "scr_wwm_frag_grenade", "1" );
	// setDvar( "scr_wwm_flash_grenade", "1" );
	// setDvar( "scr_wwm_smoke_grenade", "1" );
	// setDvar( "scr_wwm_concussion_grenade", "1" );
	// setDvar( "scr_wwm_c4", "2" );
	// setDvar( "scr_wwm_claymore", "2" );
	// setDvar( "scr_wwm_rpg", "5" );
}