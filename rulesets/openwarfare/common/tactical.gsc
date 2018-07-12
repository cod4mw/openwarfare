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
	// configs/gameplay/fitnesscs.cfg
	//******************************************************************************
	setDvar( "scr_fcs_enabled", "1" );

	//******************************************************************************
	// configs/gameplay/hardpoints.cfg
	//******************************************************************************
	setDvar( "scr_remove_hardpoint_on_death", "1" );
	setDvar( "scr_game_hardpoints_cycle", "1" );
	setDvar( "scr_announce_killstreak", "0" );
	setDvar( "scr_hardpoint_allow_uav", "0" );
	setDvar( "scr_hardpoint_airstrike_streak", "7" );
	setDvar( "scr_announce_enemy_airstrike_inbound", "0" );
	setDvar( "scr_hardpoint_allow_helicopter", "0" );

	//******************************************************************************
	// configs/gameplay/healthsystem.cfg
	//******************************************************************************
	setDvar( "scr_player_maxhealth", "42" );
	setDvar( "scr_healthregen_method", "0" );
	setDvar( "scr_healthsystem_show_healthbar", "0" );
	setDvar( "scr_healthsystem_bleeding_enable", "1" );
	setDvar( "scr_healthsystem_medic_enable", "1" );

	//******************************************************************************
	// configs/gameplay/hud.cfg
	//******************************************************************************
	setDvar( "scr_hardcore", "1" );
	setDvar( "scr_enable_hiticon", "0" );
	setDvar( "scr_enable_bodyarmor_feedback", "0" );
	setDvar( "scr_hud_show_enemy_names", "0" );
	setDvar( "scr_hud_show_friendly_names_distance", "100" );
	setDvar( "scr_hud_show_mantle_hint", "0" );
	setDvar( "scr_hud_show_center_obituary", "0" );
	setDvar( "scr_show_obituaries", "0" );
	setDvar( "scr_show_ext_obituaries", "1" );
	setDvar( "scr_hud_show_scores", "0" );
	setDvar( "scr_hardcore_show_compass", "1" );
	setDvar( "scr_hud_compass_objectives", "1" );
	setDvar( "scr_blackscreen_enable", "1" );
	setDvar( "scr_blackscreen_fadetime", "3" );
	setDvar( "scr_drawfriend", "0" );
	setDvar( "scr_hud_show_inventory", "0" );
	setDvar( "scr_show_player_status", "0" );
	setDvar( "scr_show_team_status", "0" );
	setDvar( "scr_hide_scores", "1" );

	//******************************************************************************
	// configs/gameplay/others.cfg
	//******************************************************************************
	setDvar( "scr_team_fftype", "1" );
	setDvar( "scr_game_allow_killcam", "0" );
	setDvar( "scr_quickactions_enable", "1" );

	setDvar( "scr_dogtags_enable", "0" );
	setDvar( "scr_bodyremoval_enable", "2" );
	setDvar( "scr_dogtags_enable_ass", "1" );
	setDvar( "scr_bodyremoval_enable_ass", "0" );
	setDvar( "scr_dogtags_enable_sd", "1" );
	setDvar( "scr_bodyremoval_enable_sd", "0" );
	
	setDvar( "scr_enable_spawn_protection", "1" );
	setDvar( "scr_enable_anti_bunny_hopping", "1" );
	setDvar( "scr_enable_anti_dolphin_dive", "1" );
	setDvar( "scr_damage_effect_dropweapon", "1" );
	setDvar( "scr_damage_effect_dropweapon_chance", "25" );
	setDvar( "scr_damage_effect_falldown", "1" );
	setDvar( "scr_damage_effect_falldown_chance", "25" );
	setDvar( "scr_damage_effect_shiftview", "1" );

	//******************************************************************************
	// configs/gameplay/perks.cfg
	//******************************************************************************
	setDvar( "perk_allow_specialty_pistoldeath", "0" );
	setDvar( "perk_allow_specialty_grenadepulldeath", "0" );

	//******************************************************************************
	// configs/gameplay/sounds.cfg
	//******************************************************************************
	setDvar( "scr_tactical_enable", "1" );
	setDvar( "scr_play_headshot_impact_sound", "0" );

	//******************************************************************************
	// configs/gameplay/weapons.cfg
	//******************************************************************************					
	setDvar( "scr_explosives_allow_disarm", "1" );
	setDvar( "scr_claymore_show_headicon", "0" );
	setDvar( "scr_claymore_show_laser_beams", "0" );
	setDvar( "scr_claymore_friendly_fire", "1" );
	setDvar( "scr_show_c4_blink_effect", "0" );
	setDvar( "scr_allow_stationary_turrets", "0" );
	setDvar( "scr_enable_auto_melee", "0" );
}