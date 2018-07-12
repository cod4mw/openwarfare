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
	// Initialize the standard kill and assist scores
	switch ( level.gametype ) {
		case "ch":
		case "ctf":
		case "dm":
		case "dom":
		case "koth":
		case "gg":
		case "lms":
		case "oitc":
		case "ss":
			vKill = 5;
			vAssist = 1;
			break;

		case "ass":
		case "re":
		case "sd":
			vKill = 5;
			vAssist = 2;
			break;

		default:
			if ( level.teamBased ) {
				vKill   = 10;
				vAssist = 2;
			} else {
				vKill   = 5;
				vAssist = 1;
			}
			break;
	}
	
	// Get the main module's dvar
  level.scr_enable_scoresystem = getdvarx("scr_enable_scoresystem", "int", 0, 0, 1 );

	// If the scoring system is enabled get the scores points for all the activities
	if ( level.scr_enable_scoresystem == 1 ) {
		
		// This is the only var we need to load for global use
		level.scr_score_tk_affects_teamscore = getdvarx("scr_score_tk_affects_teamscore", "int", 0, 0, 1 );
		
		// Type of kills		
		scr_score_standard_kill = getdvarx( "scr_score_standard_kill", "int", vKill, 0, 50 );
		scr_score_headshot_kill = getdvarx( "scr_score_headshot_kill", "int", scr_score_standard_kill, 0, 50 );
		scr_score_melee_kill = getdvarx( "scr_score_melee_kill", "int", scr_score_standard_kill, 0, 50 );
		scr_score_grenade_kill = getdvarx( "scr_score_grenade_kill", "int", scr_score_standard_kill, 0, 50 );
		scr_score_vehicle_explosion_kill = getdvarx( "scr_score_vehicle_explosion_kill", "int", scr_score_standard_kill, 0, 50 );
		scr_score_barrel_explosion_kill = getdvarx( "scr_score_barrel_explosion_kill", "int", scr_score_standard_kill, 0, 50 );
		scr_score_c4_kill = getdvarx( "scr_score_c4_kill", "int", scr_score_standard_kill, 0, 50 );
		scr_score_claymore_kill = getdvarx( "scr_score_claymore_kill", "int", scr_score_standard_kill, 0, 50 );
		scr_score_rpg_kill = getdvarx( "scr_score_rpg_kill", "int", scr_score_standard_kill, 0, 50 );
		scr_score_grenade_launcher_kill = getdvarx( "scr_score_grenade_launcher_kill", "int", scr_score_standard_kill, 0, 50 );
		scr_score_airstrike_kill = getdvarx( "scr_score_airstrike_kill", "int", scr_score_standard_kill, 0, 50 );
		scr_score_helicopter_kill = getdvarx( "scr_score_helicopter_kill", "int", scr_score_standard_kill, 0, 50 );

		// Assist kills
		scr_score_assist_kill = getdvarx( "scr_score_assist_kill", "int",  vAssist, 0, 10 );
		scr_score_assist_25_kill = getdvarx( "scr_score_assist_25_kill", "int",  vAssist, 0, 10 );
		scr_score_assist_50_kill = getdvarx( "scr_score_assist_50_kill", "int",  vAssist, 0, 10 );
		scr_score_assist_75_kill = getdvarx( "scr_score_assist_75_kill", "int",  vAssist, 0, 10 );

		// Death, suicide and team kill point losses
		scr_score_player_death = getdvarx( "scr_score_player_death", "int", 0, -50, 0 );
		scr_score_player_suicide = getdvarx( "scr_score_player_suicide", "int", 0, -50, 0 );
		scr_score_player_teamkill = getdvarx( "scr_score_player_teamkill", "int", 0, -50, 0 );
		
		// Freezetag Scores
		scr_score_defrost = getdvarx( "scr_score_defrost", "int", scr_score_standard_kill, 0, 50 );

		// Game actions scores
		scr_score_hardpoint_used = getdvarx("scr_score_hardpoint_used", "int", 10, 0, 50 );
		scr_score_shot_down_helicopter = getdvarx( "scr_score_shot_down_helicopter", "int", 0, 0, 50);
		scr_score_capture_objective = getdvarx( "scr_score_capture_objective", "int", 30, 0, 50);
		scr_score_take_objective = getdvarx( "scr_score_take_objective", "int", 7, 0, 50);
		scr_score_return_objective = getdvarx( "scr_score_return_objective", "int", 7, 0, 50);
		scr_score_defend_objective = getdvarx( "scr_score_defend_objective", "int", 30, 0, 50);
		scr_score_holding_objective = getdvarx( "scr_score_holding_objective", "int", 5, 0, 50);
		scr_score_kill_objective_carrier = getdvarx( "scr_score_kill_objective_carrier", "int", 5, 0, 50);
		scr_score_assault_objective = getdvarx( "scr_score_assault_objective", "int", 5, 0, 50);
		scr_score_plant_bomb = getdvarx( "scr_score_plant_bomb", "int", 20, 0, 50);
		scr_score_defuse_bomb = getdvarx( "scr_score_defuse_bomb", "int", 15, 0, 50);

		// End of game multipliers and challenge completion
		scr_score_win_multiplier = getdvarx("scr_score_win_multiplier", "float", 1.0, 0.0, 2.0);
		scr_score_loss_multiplier = getdvarx("scr_score_loss_multiplier", "float", 0.5, 0.0, 2.0);
		scr_score_tie_multiplier = getdvarx("scr_score_tie_multiplier", "float", 0.75, 0.0, 2.0);
		scr_score_completed_challenge = getdvarx("scr_score_completed_challenge", "int", 250, 0, 500);

	}	else	{
		// Get the point loss modifiers
		scr_game_deathpointloss = getdvarx("scr_game_deathpointloss", "int", 0, 0, 1);
		scr_game_suicidepointloss = getdvarx("scr_game_suicidepointloss", "int", 0, 0, 1);
		scr_team_teamkillpointloss = getdvarx("scr_team_teamkillpointloss", "int", 0, 0, 1);

		// This is the only var we need to load for global use
		level.scr_score_tk_affects_teamscore = 0;
		
		// Type of kills		
		scr_score_standard_kill = vKill;
		scr_score_headshot_kill = vKill;
		scr_score_melee_kill = vKill;
		scr_score_grenade_kill = vKill;
		scr_score_vehicle_explosion_kill = vKill;
		scr_score_barrel_explosion_kill = vKill;
		scr_score_c4_kill = vKill;
		scr_score_claymore_kill = vKill;
		scr_score_rpg_kill = vKill;
		scr_score_grenade_launcher_kill = vKill;
		scr_score_airstrike_kill = vKill;
		scr_score_helicopter_kill = vKill;

		// Assist kills
		scr_score_assist_kill = vAssist;
		scr_score_assist_25_kill = vAssist;
		scr_score_assist_50_kill = vAssist;
		scr_score_assist_75_kill = vAssist;

		// Death, suicide and team kill point losses
		scr_score_player_death = 0;
		scr_score_player_suicide = 0;
		scr_score_player_teamkill = 0;
		
		if ( getdvarx("scr_game_deathpointloss", "int", 0, 0, 1 ) == 1 )
			scr_score_player_death = vKill * -1;
		
		if ( getdvarx("scr_game_suicidepointloss", "int", 0, 0, 1 ) == 1)
			scr_score_player_suicide = vKill * -1;
		
		if ( getdvarx("scr_team_teamkillpointloss", "int", 0, 0, 1 ) == 1)
			scr_score_player_teamkill = vKill * -1;

		// Freezetag Scores
		scr_score_defrost = vKill;

		// Game actions scores
		scr_score_hardpoint_used = 10;
		scr_score_shot_down_helicopter = 0;
	
		switch ( level.gametype ) {
			case "ch":
			case "dom":
			case "koth":
				scr_score_capture_objective = 15;
				scr_score_defend_objective = 5;
				break;

			case "ctf":
				scr_score_capture_objective = 50;
				scr_score_defend_objective = 10;
				break;
			
			default:
				scr_score_capture_objective = 30;
				scr_score_defend_objective = 30;
				break;
		}				
		
		scr_score_take_objective = 7;
		scr_score_return_objective = 7;
		scr_score_holding_objective = 5;
		scr_score_kill_objective_carrier = 5;
		scr_score_assault_objective = 5;
		
		switch ( level.gametype ) {
			case "sd":
				scr_score_plant_bomb = 10;
				scr_score_defuse_bomb = 10;
				break;
				
			default:
				scr_score_plant_bomb = 20;
				scr_score_defuse_bomb = 15;
				break;
		}				


		// End of game multipliers and challenge completion
		switch ( level.gametype ) {
			case "sd":
			case "re":
				scr_score_win_multiplier = 2.0;
				scr_score_loss_multiplier = 1.0;
				scr_score_tie_multiplier = 1.5;
				break;
				
			default:
				scr_score_win_multiplier = 1.0;
				scr_score_loss_multiplier = 0.5;
				scr_score_tie_multiplier = 0.75;
		}

		scr_score_completed_challenge = 250;

	}

	// Register the different scores
	// Type of kills		
	maps\mp\gametypes\_rank::registerScoreInfo( "kill", scr_score_standard_kill );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", scr_score_headshot_kill );
	maps\mp\gametypes\_rank::registerScoreInfo( "melee", scr_score_melee_kill );
	maps\mp\gametypes\_rank::registerScoreInfo( "grenade", scr_score_grenade_kill ); 
	maps\mp\gametypes\_rank::registerScoreInfo( "vehicleexplosion", scr_score_vehicle_explosion_kill );
	maps\mp\gametypes\_rank::registerScoreInfo( "barrelexplosion", scr_score_barrel_explosion_kill );
	maps\mp\gametypes\_rank::registerScoreInfo( "c4", scr_score_c4_kill );
	maps\mp\gametypes\_rank::registerScoreInfo( "claymore", scr_score_claymore_kill );
	maps\mp\gametypes\_rank::registerScoreInfo( "rpg", scr_score_rpg_kill ); 
	maps\mp\gametypes\_rank::registerScoreInfo( "grenadelauncher", scr_score_grenade_launcher_kill ); 	
	maps\mp\gametypes\_rank::registerScoreInfo( "airstrike", scr_score_airstrike_kill ); 	
	maps\mp\gametypes\_rank::registerScoreInfo( "helicopter", scr_score_helicopter_kill ); 	

	// Assist kills
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", scr_score_assist_kill ); 	
	maps\mp\gametypes\_rank::registerScoreInfo( "assist_25", scr_score_assist_25_kill ); 
	maps\mp\gametypes\_rank::registerScoreInfo( "assist_50", scr_score_assist_50_kill ); 	
	maps\mp\gametypes\_rank::registerScoreInfo( "assist_75", scr_score_assist_75_kill ); 	
	
	// Death, suicide and team kill point losses
	maps\mp\gametypes\_rank::registerScoreInfo( "death", scr_score_player_death ); 
	maps\mp\gametypes\_rank::registerScoreInfo( "suicide", scr_score_player_suicide );
	maps\mp\gametypes\_rank::registerScoreInfo( "teamkill", scr_score_player_teamkill );		

	// Freezetag Scores
	maps\mp\gametypes\_rank::registerScoreInfo( "defrost", scr_score_defrost );

	// Game actions scores
	maps\mp\gametypes\_rank::registerScoreInfo( "hardpoint", scr_score_hardpoint_used );
	maps\mp\gametypes\_rank::registerScoreInfo( "helicopterdown", scr_score_shot_down_helicopter );	
	maps\mp\gametypes\_rank::registerScoreInfo( "helicopterdownrpg", scr_score_shot_down_helicopter * 2 );
	maps\mp\gametypes\_rank::registerScoreInfo( "capture", scr_score_capture_objective );
	maps\mp\gametypes\_rank::registerScoreInfo( "take", scr_score_take_objective );
	maps\mp\gametypes\_rank::registerScoreInfo( "return", scr_score_return_objective );
	maps\mp\gametypes\_rank::registerScoreInfo( "defend", scr_score_defend_objective );
	maps\mp\gametypes\_rank::registerScoreInfo( "defend_assist", 1 );
	maps\mp\gametypes\_rank::registerScoreInfo( "holding", scr_score_holding_objective );
	maps\mp\gametypes\_rank::registerScoreInfo( "killcarrier", scr_score_kill_objective_carrier );
	maps\mp\gametypes\_rank::registerScoreInfo( "assault", scr_score_assault_objective );
	maps\mp\gametypes\_rank::registerScoreInfo( "assault_assist", 1 );		
	maps\mp\gametypes\_rank::registerScoreInfo( "plant", scr_score_plant_bomb );
	maps\mp\gametypes\_rank::registerScoreInfo( "defuse", scr_score_defuse_bomb );
	
	// End of game multipliers and challenge completion
	maps\mp\gametypes\_rank::registerScoreInfo( "win", scr_score_win_multiplier );
	maps\mp\gametypes\_rank::registerScoreInfo( "loss", scr_score_loss_multiplier );
	maps\mp\gametypes\_rank::registerScoreInfo( "tie", scr_score_tie_multiplier );
	maps\mp\gametypes\_rank::registerScoreInfo( "challenge", scr_score_completed_challenge );
}


getPointsForKill( pMeansOfDeath, pWeapon, pAttacker)
{
	// Initialize the score info array with the default kill values
	scoreInfo = [];
	scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
	scoreInfo["type"] = "kill";


	// Headshot kill
	if ( pMeansOfDeath == "MOD_HEAD_SHOT" )	{
		pAttacker  maps\mp\gametypes\_globallogic::incPersStat( "headshots", 1 );
		pAttacker.headshots = pAttacker maps\mp\gametypes\_globallogic::getPersStat( "headshots" );
		
		scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "headshot" );
		scoreInfo["type"] = "headshot";
	
		if ( isDefined( pAttacker.lastStand ) )
			scoreInfo["score"] *= 2;
		
		if ( level.scr_play_headshot_impact_sound == 1 )
			pAttacker playLocalSound( "bullet_impact_headshot_2" );
		
	// Melee kill
	} else if ( pMeansOfDeath == "MOD_MELEE" ) {
		scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "melee" );
		scoreInfo["type"] = "melee";

	// Grenade kill		
	} else if ( issubstr( pMeansOfDeath, "MOD_GRENADE" ) && ( pWeapon == "frag_grenade_mp" || pWeapon == "frag_grenade_short_mp" ) ) {
		scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "grenade" );
		scoreInfo["type"] = "grenade";
		
	// C4 kill
	} else if ( issubstr( pMeansOfDeath, "MOD_GRENADE" ) && pWeapon == "c4_mp") {
		scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "c4" );
		scoreInfo["type"] = "c4";

	// Claymore kill		
	} else if ( issubstr( pMeansOfDeath, "MOD_GRENADE" ) && pWeapon == "claymore_mp") {
		scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "claymore" );
		scoreInfo["type"] = "claymore";
		
	// Grenade launcher kill
	} else if ( issubstr( pMeansOfDeath, "MOD_GRENADE" ) && issubstr( pWeapon, "gl_") ) {
		scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "grenadelauncher" );
		scoreInfo["type"] = "grenadelauncher";

	// Exploding car kill
	} else if ( issubstr( pMeansOfDeath, "MOD_EXPLOSIVE" ) && pWeapon == "destructible_car" ) {
		scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "vehicleexplosion" );
		scoreInfo["type"] = "vehicleexplosion";
		
	// Exploding barrel kill
	} else if ( issubstr( pMeansOfDeath, "MOD_CRUSH" ) && pWeapon == "explodable_barrel" ) {
		scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "barrelexplosion" );
		scoreInfo["type"] = "barrelexplosion";

	// RPG kill 
	} else if ( issubstr( pMeansOfDeath, "MOD_PROJECTILE" ) && pWeapon == "rpg_mp") {
		scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "rpg" );
		scoreInfo["type"] = "rpg";

	// airstrike kill
	} else if ( issubstr( pMeansOfDeath, "MOD_PROJECTILE" ) && pWeapon == "artillery_mp") {
		scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "airstrike" );
		scoreInfo["type"] = "airstrike";

	// helicopter kill
	} else if ( issubstr( pMeansOfDeath, "MOD_PISTOL_BULLET" ) && (issubstr(pWeapon, "cobra") || issubstr(pWeapon, "hind")) ){
		scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "helicopter" );
		scoreInfo["type"] = "helicopter";

	// Helicopter down score
	} else if ( issubstr( pMeansOfDeath, "MOD_HELIDOWN" ) ) {
		if ( ( pWeapon == "MOD_RIFLE_BULLET" ) || ( pWeapon == "MOD_PISTOL_BULLET" ) ) {
			scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "helicopterdown" );
			scoreInfo["type"] = "helicopterdown";
		} else {
			scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "helicopterdownrpg" );
			scoreInfo["type"] = "helicopterdownrpg";
		}
	}

	return scoreInfo;
}
