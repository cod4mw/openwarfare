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
	// Overall admin GUIDs
	level.scr_server_overall_admin_guids = getdvarx( "scr_server_overall_admin_guids", "string", "" );	

	// Gametype objective variables
	level.scr_gametype_objectives_sound = getdvarx( "scr_gametype_objectives_sound", "int", 1, 0, 1 );
	level.scr_gametype_objectives_print = getdvarx( "scr_gametype_objectives_print", "int", 1, 0, 1 );
	
	// Special FXs
	level.scr_map_special_fx_enable = getdvarx( "scr_map_special_fx_enable", "int", 1, 0, 2 );

	// Jump height based on oldschool or normal game
	if ( level.oldschool ) {
		level.scr_jump_height = getdvarx( "scr_jump_height", "int", 64, 0, 1000 );
		level.scr_jump_slowdown_enable = getdvarx( "scr_jump_slowdown_enable", "int", 0, 0, 1 );
	} else {
		level.scr_jump_height = getdvarx( "scr_jump_height", "int", 39, 0, 1000 );
		level.scr_jump_slowdown_enable = getdvarx( "scr_jump_slowdown_enable", "int", 1, 0, 1 );
	}
	
	level thread onPrematchStart();
	
	setDvar( "scr_game_allowkillcam", getdvarx( "scr_game_allow_killcam", "int", 0, 0, 1 ) );

	level.scr_game_playerwaittime = getdvarx( "scr_game_playerwaittime", "int", 15, 1, 120 );
	level.scr_game_matchstarttime = getdvarx( "scr_game_matchstarttime", "int", 15, 0, 120 );
	level.scr_intermission_time = getdvarx( "scr_intermission_time", "int", 15, 0, 120 );

	level.scr_allow_thirdperson = getdvarx( "scr_allow_thirdperson", "int", 0, 0, 1 );
	level.scr_allow_thirdperson_guids = getdvarx( "scr_allow_thirdperson_guids", "string", "" );
	
	level.scr_enable_nightvision = getdvarx( "scr_enable_nightvision", "int", 1, 0, 1 );
	
	level.scr_player_forcerespawn = getdvarx( "scr_player_forcerespawn", "int", 1, 0, 1 );
	
	level.scr_forfeit_enable = getdvarx( "scr_forfeit_enable", "int", 1, 0, 1 );

	// Used to disable the GL in ranked mode
	level.attach_allow_assault_gl =	getdvarx( "attach_allow_assault_gl", "int", 1, 0, 1 );

	// Hide player status
	level.scr_show_player_status = getdvarx( "scr_show_player_status", "int", 1, 0, 1 );

	// Progress bars adjustment
	level.scr_adjust_progress_bars = getdvarx( "scr_adjust_progress_bars", "int", 0, 0, 2 );

	// Hiticon dvars
	level.scr_enable_hiticon = getdvarx( "scr_enable_hiticon", "int", 1, 0, 2 );
	level.scr_enable_bodyarmor_feedback = getdvarx( "scr_enable_bodyarmor_feedback", "int", 1, 0, 1 );

	// Fall damage based on oldschool or normal game
	if ( level.oldschool ) {
		level.scr_fallDamageMinHeight = getdvarx( "scr_fallDamageMinHeight", "int", 256, 50, 999 );
		level.scr_fallDamageMaxHeight = getdvarx( "scr_fallDamageMaxHeight", "int", 512, 50, 999 );
	} else {
		level.scr_fallDamageMinHeight = getdvarx( "scr_fallDamageMinHeight", "int", 128, 50, 999 );
		level.scr_fallDamageMaxHeight = getdvarx( "scr_fallDamageMaxHeight", "int", 300, 50, 999 );
	}

	// Health regen method and related dvars
	level.scr_healthregen_method = getdvarx( "scr_healthregen_method", "int", 1, 0, 2 );
	level.scr_player_healthregentime = getdvarx( "scr_player_healthregentime", "int", 5, 0, 120 );

	// HUD elements
	level.scr_hud_show_death_icons = getdvarx( "scr_hud_show_death_icons", "int", 1, 0, 1 );

	// Variables used in menu files
	level.scr_hud_show_inventory = getdvarx( "scr_hud_show_inventory", "int", 0, 0, 2 );

	ui_hud_show_mantle_hint = getdvarx( "scr_hud_show_mantle_hint", "int", 1, 0, 2 );
	setdvar( "ui_hud_show_mantle_hint", ui_hud_show_mantle_hint );
	makeDvarServerInfo( "ui_hud_show_mantle_hint" );

	ui_hud_show_center_obituary = getdvarx( "scr_hud_show_center_obituary", "int", 1, 0, 1 );
	setdvar( "ui_hud_show_center_obituary", ui_hud_show_center_obituary );
	makeDvarServerInfo( "ui_hud_show_center_obituary" );

	ui_hud_show_hardpoints = getdvarx( "scr_uav_show_hardpoints", "int", 1, 0, 1 );
	setdvar( "ui_hud_show_hardpoints", ui_hud_show_hardpoints );
	makeDvarServerInfo( "ui_hud_show_hardpoints" );

	ui_hud_show_scores = getdvarx( "scr_hud_show_scores", "int", ( level.hardcoreMode == 0 ), 0, 1 );
	setdvar( "ui_hud_show_scores", ui_hud_show_scores );
	makeDvarServerInfo( "ui_hud_show_scores" );

	ui_hud_show_stance = getdvarx( "scr_hud_show_stance", "int", 0, 0, 1 );
	setdvar( "ui_hud_show_stance", ui_hud_show_stance );
	makeDvarServerInfo( "ui_hud_show_stance" );

	level.scr_hud_show_xp_points = getdvarx( "scr_hud_show_xp_points", "int", 1, 0, 2 );

	// Red blips when enemies fire non-silenced weapons
	// Default depends on hardcore mode
	if ( getDvarInt( "scr_hardcore" ) == 1 ) {
		ui_minimap_show_enemies_firing  = getdvarx( "scr_minimap_show_enemies_firing", "int", 0, 0, 1 );
	} else {
		ui_minimap_show_enemies_firing  = getdvarx( "scr_minimap_show_enemies_firing", "int", 1, 0, 1 );
	}
	setdvar( "ui_minimap_show_enemies_firing", ui_minimap_show_enemies_firing );
	makeDvarServerInfo( "ui_minimap_show_enemies_firing" );

	// 2d/3d icons control
	level.scr_hud_show_3dicons = getdvarx( "scr_hud_show_3dicons", "int", 1, 0, 1 );
	level.scr_hud_show_2dicons = getdvarx( "scr_hud_show_2dicons", "int", 1, 0, 1 );

	// Show always the minimap in hardcore mode
	level.scr_hud_hardcore_show_minimap = getdvarx( "scr_hardcore_show_minimap", "int", 0, 0, 1 );

	// Show only the compass (North, South, West, East)
	level.scr_hud_hardcore_show_compass = getdvarx( "scr_hardcore_show_compass", "int", 0, 0, 1 );

	level.perk_allow_c4_mp = getdvarx( "perk_allow_c4_mp", "int", 1, 0, 1 );
	level.perk_allow_rpg_mp = getdvarx( "perk_allow_rpg_mp", "int", 1, 0, 1 );
	level.perk_allow_claymore_mp = getdvarx( "perk_allow_claymore_mp", "int", 1, 0, 1 );

	// Delay grenades and GL at the start of the round
	level.scr_delay_only_round_start = getdvarx( "scr_delay_only_round_start", "int", 1, 0, 1 );
	level.scr_delay_sound_enable = getdvarx( "scr_delay_sound_enable", "int", 1, 0, 1 );
	level.scr_delay_frag_grenades = getdvarx( "scr_delay_frag_grenades", "float", 0, 0, 30 );
	level.scr_delay_smoke_grenades = getdvarx( "scr_delay_smoke_grenades", "float", 0, 0, 30 );
	level.scr_delay_flash_grenades = getdvarx( "scr_delay_flash_grenades", "float", 0, 0, 30 );
	level.scr_delay_concussion_grenades = getdvarx( "scr_delay_concussion_grenades", "float", 0, 0, 30 );
	level.scr_delay_grenade_launchers = getdvarx( "scr_delay_grenade_launchers", "float", 0, 0, 30 );
	level.scr_delay_rpgs = getdvarx( "scr_delay_rpgs", "float", 0, 0, 30 );
	level.scr_delay_c4s = getdvarx( "scr_delay_c4s", "float", 0, 0, 30 );
	level.scr_delay_claymores = getdvarx( "scr_delay_claymores", "float", 0, 0, 30 );

	// Leader Dialog
	level.scr_allow_leader_dialog = getdvarx( "scr_allow_leader_dialog", "int", 1, 0, 1 );

	level.scr_show_obituaries = getdvarx( "scr_show_obituaries", "int", 1, 0, 2 );
	level.scr_play_headshot_impact_sound = getdvarx( "scr_play_headshot_impact_sound", "int", 1, 0, 1 );

	// Last stand tweaks
	level.specialty_pistoldeath_check_pistol = getdvarx( "specialty_pistoldeath_check_pistol", "int", 0, 0, 1 );

	level.scr_switch_teams_at_halftime = getdvarx( "scr_switch_teams_at_halftime", "int", 0, 0, 1 );

	// If we are running unranked load some variables that are only loaded in _modwarfare.gsc
	if ( level.rankedMatch ) {
		game["loadout_CLASS_ASSAULT_frags"] =	getdvarx( "class_assault_frags", "int", 1, 0, 4 );
		game["loadout_CLASS_ASSAULT_special"] = getdvarx( "class_assault_special", "int", 1, 0, 4 );
		game["loadout_CLASS_SPECOPS_frags"] =	getdvarx( "class_specops_frags", "int", 1, 0, 4 );
		game["loadout_CLASS_SPECOPS_special"] = getdvarx( "class_specops_special", "int", 1, 0, 4 );
		game["loadout_CLASS_HEAVYGUNNER_frags"] = getdvarx( "class_heavygunner_frags", "int", 1, 0, 4 );
		game["loadout_CLASS_HEAVYGUNNER_special"] = getdvarx( "class_heavygunner_special", "int", 1, 0, 4 );
		game["loadout_CLASS_DEMOLITIONS_frags"] = getdvarx( "class_demolitions_frags", "int", 1, 0, 4 );
		game["loadout_CLASS_DEMOLITIONS_special"] = getdvarx( "class_demolitions_special", "int", 1, 0, 4 );
		game["loadout_CLASS_SNIPER_frags"] = getdvarx( "class_sniper_frags", "int", 1, 0, 4 );
		game["loadout_CLASS_SNIPER_special"] = getdvarx( "class_sniper_special", "int", 1, 0, 4 );
		game["loadout_CLASS_UNKNOWN_frags"] = 0;
		game["loadout_CLASS_UNKNOWN_special"] = 0;
	}

	level.scr_relocate_chat_position = getdvarx( "scr_relocate_chat_position", "int", 0, 0, 2 );
	if ( level.scr_relocate_chat_position == 1 ) {
		chatPosition = "bottom";
	} else if ( level.scr_relocate_chat_position == 2 ) {
		chatPosition = "top";
	} else {
		chatPosition = "standard";
	}
	setdvar( "ui_chat_position", chatPosition );
	makeDvarServerInfo( "ui_chat_position" );

	// Control bullet penetration
	level.scr_bullet_penetration_enabled = getdvarx( "scr_bullet_penetration_enabled", "int", 1, 0, 1 );

	return;
}


onPrematchStart()
{
	level waittill( "prematch_start" );
	
	setDvar( "g_gravity", getdvarx( "scr_g_gravity", "int", 800, 0, 1000 ) );
	setDvar( "jump_height", level.scr_jump_height );
	setDvar( "jump_slowdownEnable", level.scr_jump_slowdown_enable );

	// If special effects are disable make sure we disable ambient sound (for custom maps)
	if ( level.scr_map_special_fx_enable == 0 ) {
		ambientStop();
	}	
}