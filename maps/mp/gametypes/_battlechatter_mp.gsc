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

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include openwarfare\_utils;

init()
{
	// Get the main module's dvar
	level.scr_allowbattlechatter = getdvarx( "scr_allowbattlechatter", "int", 1, 0, 1 );

	if ( game["allies"] == "sas" )
		level.teamPrefix["allies"] = "UK_1";
	else
		level.teamPrefix["allies"] = "US_1";

	if ( game["axis"] == "russian" )
		level.teamPrefix["axis"] = "RU_1";
	else
		level.teamPrefix["axis"] = "AB_1";

	level.speakers["allies"] = [];
	level.speakers["axis"] = [];
	
	// Load the rest of the module's variables
	level.scr_battlechatter_reload_probability = getdvarx( "scr_battlechatter_reload_probability", "int", 75, 0, 100 );
	level.scr_battlechatter_frag_out_probability = getdvarx( "scr_battlechatter_frag_out_probability", "int", 75, 0, 100 );
	level.scr_battlechatter_flash_out_probability = getdvarx( "scr_battlechatter_flash_out_probability", "int", 75, 0, 100 );
	level.scr_battlechatter_smoke_out_probability = getdvarx( "scr_battlechatter_smoke_out_probability", "int", 75, 0, 100 );
	level.scr_battlechatter_concussion_out_probability = getdvarx( "scr_battlechatter_concussion_out_probability", "int", 75, 0, 100 );
	level.scr_battlechatter_c4_planted_probability = getdvarx( "scr_battlechatter_c4_planted_probability", "int", 75, 0, 100 );
	level.scr_battlechatter_claymore_planted_probability = getdvarx( "scr_battlechatter_claymore_planted_probability", "int", 75, 0, 100 );
	level.scr_battlechatter_kill_probability = getdvarx( "scr_battlechatter_kill_probability", "int", 75, 0, 100 );

	// If battlechatter is not enabled there's nothing else to do here
	if ( level.scr_allowbattlechatter == 0 )
		return;
		
	level.isTeamSpeaking["allies"] = false;
	level.isTeamSpeaking["axis"] = false;
	
	level.bcSounds = [];
	level.bcSounds["reload"] = "inform_reloading_generic";
	level.bcSounds["frag_out"] = "inform_attack_grenade";
	level.bcSounds["flash_out"] = "inform_attack_flashbang";
	level.bcSounds["smoke_out"] = "inform_attack_smoke";
	level.bcSounds["conc_out"] = "inform_attack_stun";
	level.bcSounds["c4_plant"] = "inform_attack_thwc4";
	level.bcSounds["claymore_plant"] = "inform_plant_claymore";
	level.bcSounds["kill"] = "inform_killfirm_infantry";

	level thread onPlayerConnect();	
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill ( "connecting", player );
		player thread onPlayerSpawned();
	}
}


onPlayerSpawned()
{
	self endon( "disconnect" );

	for(;;)
	{
		self waittill( "spawned_player" );
		
		// help players be stealthy in splitscreen by not announcing their intentions
		if ( level.splitscreen )
			continue;
		
		self thread claymoreTracking();
		self thread reloadTracking();
		self thread grenadeTracking();
	}
}


claymoreTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	while(1)
	{
		self waittill( "begin_firing" );
		weaponName = self getCurrentWeapon();
		if ( weaponName == "claymore_mp" && shouldPlayBattlechatter( level.scr_battlechatter_claymore_planted_probability ) )
			level thread sayLocalSound( self, "claymore_plant" );
	}
}


reloadTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	for( ;; )
	{
		self waittill ( "reload_start" );
		if ( shouldPlayBattlechatter( level.scr_battlechatter_reload_probability ) )
			level thread sayLocalSound( self, "reload" );
	}
}


grenadeTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	for( ;; )
	{
		self waittill ( "grenade_fire", grenade, weaponName );
		
		if ( weaponName == "frag_grenade_mp" && shouldPlayBattlechatter( level.scr_battlechatter_frag_out_probability ) )
			level thread sayLocalSound( self, "frag_out" );
			
		else if ( weaponName == "flash_grenade_mp" && shouldPlayBattlechatter( level.scr_battlechatter_flash_out_probability ) )
			level thread sayLocalSound( self, "flash_out" );
			
		else if ( weaponName == "concussion_grenade_mp" && shouldPlayBattlechatter( level.scr_battlechatter_concussion_out_probability ) )
			level thread sayLocalSound( self, "conc_out" );
			
		else if ( weaponName == "smoke_grenade_mp" && shouldPlayBattlechatter( level.scr_battlechatter_smoke_out_probability ) )
			level thread sayLocalSound( self, "smoke_out" );
			
		else if ( weaponName == "c4_mp" && shouldPlayBattlechatter( level.scr_battlechatter_c4_planted_probability ) )
			level thread sayLocalSound( self, "c4_plant" );
	}
}


sayLocalSoundDelayed( player, soundType, delay )
{
	player endon ( "death" );
	player endon ( "disconnect" );
	
	wait ( delay );
	
	sayLocalSound( player, soundType );
}


sayLocalSound( player, soundType )
{
	player endon ( "death" );
	player endon ( "disconnect" );
	
	if ( level.scr_allowbattlechatter == 0 )
		return;

	if ( isSpeakerInRange( player ) )
		return;
		
	if( player.pers["team"] != "spectator" )
	{
		soundAlias = level.teamPrefix[player.pers["team"]] + "_" + level.bcSounds[soundType];
		player thread doSound( soundAlias );
	}
}


doSound( soundAlias )
{
	team = self.pers["team"];
	level addSpeaker( self, team );
	self playSoundToTeam( soundAlias, team );
	self thread timeHack( soundAlias ); // workaround because soundalias notify isn't happening
	self waittill_any( soundAlias, "death", "disconnect" );
	level removeSpeaker( self, team );
}


timeHack( soundAlias )
{
	self endon ( "death" );
	self endon ( "disconnect" );

	wait ( 2.0 );
	self notify ( soundAlias );
}


isSpeakerInRange( player )
{
	player endon ( "death" );
	player endon ( "disconnect" );

	distSq = 1000 * 1000;

	// to prevent player switch to spectator after throwing a granade causing damage to someone and result in attacker.pers["team"] = "spectator"
	if( isdefined( player ) && isdefined( player.pers["team"] ) && player.pers["team"] != "spectator" )
	{
		for ( index = 0; index < level.speakers[player.pers["team"]].size; index++ )
		{
			teammate = level.speakers[player.pers["team"]][index];
			if ( teammate == player )
				return true;
				
			if ( distancesquared( teammate.origin, player.origin ) < distSq )
				return true;
		}
	}

	return false;
}


addSpeaker( player, team )
{
	level.speakers[team][level.speakers[team].size] = player;
}


// this is lazy... fix up later by tracking ID's and doing array slot swapping
removeSpeaker( player, team )
{
	newSpeakers = [];
	for ( index = 0; index < level.speakers[team].size; index++ )
	{
		if ( level.speakers[team][index] == player )
			continue;
			
		newSpeakers[newSpeakers.size] = level.speakers[team][index]; 
	}
	
	level.speakers[team] = newSpeakers;
}


shouldPlayBattlechatter( bcProbability )
{
	if ( bcProbability == 0 )
		return false;
	else if ( bcProbability == 100 || randomIntRange( 1, 101 ) <= bcProbability )
		return true;
		
	return false;	
}