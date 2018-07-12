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
#include maps\mp\gametypes\_hud_util;

#include openwarfare\_eventmanager;
#include openwarfare\_utils;


init()
{
	// Get the main module's dvar
	level.scr_power_rank_mode = getdvarx( "scr_power_rank_mode", "int", 0, 0, 2 );

	// Check if we need to run this process
	if ( level.scr_power_rank_mode == 0 || !level.rankedMatch )
		return;

	level.scr_power_rank_delay = getdvarx( "scr_power_rank_delay", "float", 0.5, 0.5, 2.0 );
	
	// Let's load the minimum experience here to make everything faster
	level.maxPower = int(tableLookup( "mp/rankTable.csv", 0, "maxpower", 1 ));
	level.powerRankInfoMinXp = [];
	for ( rankId = 1; rankId <= level.maxPower; rankId++ ) {
		level.powerRankInfoMinXp[ rankId ] = maps\mp\gametypes\_rank::getRankInfoMinXp( rankId );
	}

	precacheString( &"OW_POWER_RANK_ATTACHMENTS" );
	precacheString( &"OW_POWER_RANK_CAMOS" );

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self.powerRanked = false;
	self thread onPlayerSpawned();
}

onPlayerSpawned()
{
	self endon("disconnect");

	self waittill("spawned_player");
	self thread givePowerRankXP();
}


givePowerRankXP()
{
	self endon("disconnect");
	
	// Check if we need to give XP to the player	
	if ( self.pers["rankxp"] < level.powerRankInfoMinXp[ level.maxPower ] ) {
		
		// Assign enough XP to advance 3 ranks at a time
		for ( rankId = 1; rankId <= level.maxPower; rankId++ ) {
			rankXp = level.powerRankInfoMinXp[ rankId ];
			
			if ( rankXp > self.pers["rankxp"] ) {
				rankXp -= self.pers["rankxp"];
				self maps\mp\gametypes\_rank::giveRankXP( "powerrank", rankXp, true );
				self maps\mp\gametypes\_rank::updateRank();
				wait ( level.scr_power_rank_delay );
			}
		}
		
		// Let the player know about the promotion to max level
		self maps\mp\gametypes\_rank::updateRankAnnounceHUD( true );
	}
	
	// Check if we need to unlock the special attachments and camos for the player
	if ( level.scr_power_rank_mode == 2 ) {
		self unlockSpecialAttachments();
		self unlockSpecialCamos();				
	}

	return;
}


unlockSpecialAttachments()
{
	// Initialize a list of attachments that we need to unlock
	attachmentList = [];
	attachmentList[0] = "ak47 reflex;ak74u reflex;m1014 reflex;g3 reflex;g36c reflex;m14 reflex";
	attachmentList[1] = "m16 reflex;m4 reflex;m60e4 reflex;mp5 reflex;p90 reflex;rpd reflex";
	attachmentList[2] = "saw reflex;skorpion reflex;uzi reflex;winchester1200 reflex;ak47 silencer;ak74u silencer";
	attachmentList[3] = "g3 silencer;g36c silencer;m14 silencer;m16 silencer;m4 silencer;mp5 silencer";
	attachmentList[4] = "p90 silencer;skorpion silencer;uzi silencer;ak47 acog;ak74u acog;barrett acog";
	attachmentList[5] = "dragunov acog;g3 acog;g36c acog;m14 acog;m16 acog;m21 acog";
	attachmentList[6] = "m4 acog;m40a3 acog;m60e4 acog;mp5 acog;p90 acog;remington700 acog;rpd acog";
	attachmentList[7] = "saw acog;skorpion acog;uzi acog;ak47 gl;g3 gl;g36c gl;m14 gl";
	attachmentList[8] = "m16 gl;m4 gl;m1014 grip;m60e4 grip;rpd grip;saw grip;winchester1200 grip";

	// Get the last array of attachments unlocked for this player
	attachix = self getStat( 3150 );
	
	// Check if we need to unlock attachments
	if ( attachix >= attachmentList.size )
		return;
	
	// Cycle the list of attachments and unlock them
	while( attachix < attachmentList.size ) {
		self maps\mp\gametypes\_rank::unlockAttachment( attachmentList[ attachix ] );
		self setStat( 3150, attachix );
		attachix++;
		wait ( level.scr_power_rank_delay );
	}	
	self setStat( 3150, attachmentList.size );
	self iprintlnbold( &"OW_POWER_RANK_ATTACHMENTS" );
	
	return;
}


unlockSpecialCamos()
{
	// Initialize a list of camos that we need to unlock
	camoList = [];
	camoList[0] = "ak47 camo_blackwhitemarpat;ak74u camo_blackwhitemarpat;barrett camo_blackwhitemarpat;m1014 camo_blackwhitemarpat;dragunov camo_blackwhitemarpat;g3 camo_blackwhitemarpat;g36c camo_blackwhitemarpat;m14 camo_blackwhitemarpat";
	camoList[1] = "m16 camo_blackwhitemarpat;m21 camo_blackwhitemarpat;m4 camo_blackwhitemarpat;m40a3 camo_blackwhitemarpat;m60e4 camo_blackwhitemarpat;mp44 camo_blackwhitemarpat;mp5 camo_blackwhitemarpat;p90 camo_blackwhitemarpat";
	camoList[2] = "remington700 camo_blackwhitemarpat;rpd camo_blackwhitemarpat;saw camo_blackwhitemarpat;skorpion camo_blackwhitemarpat;uzi camo_blackwhitemarpat;winchester1200 camo_blackwhitemarpat";
	camoList[3] = "ak47 camo_stagger;ak74u camo_stagger;barrett camo_stagger;m1014 camo_stagger;dragunov camo_stagger;g3 camo_stagger;g36c camo_stagger;m14 camo_stagger";
	camoList[4] = "m16 camo_stagger;m21 camo_stagger;m4 camo_stagger;m40a3 camo_stagger;m60e4 camo_stagger;mp44 camo_stagger;mp5 camo_stagger;p90 camo_stagger";
	camoList[5] = "remington700 camo_stagger;rpd camo_stagger;saw camo_stagger;skorpion camo_stagger;uzi camo_stagger;winchester1200 camo_stagger";
	camoList[6] = "ak47 camo_tigerred;ak74u camo_tigerred;barrett camo_tigerred;m1014 camo_tigerred;dragunov camo_tigerred;g3 camo_tigerred;g36c camo_tigerred;m14 camo_tigerred";
	camoList[7] = "m16 camo_tigerred;m21 camo_tigerred;m4 camo_tigerred;m40a3 camo_tigerred;m60e4 camo_tigerred;mp44 camo_tigerred;mp5 camo_tigerred;p90 camo_tigerred";
	camoList[8] = "remington700 camo_tigerred;rpd camo_tigerred;saw camo_tigerred;skorpion camo_tigerred;uzi camo_tigerred;winchester1200 camo_tigerred";
	camoList[9] = "ak47 camo_gold;uzi camo_gold;m60e4 camo_gold;m1014 camo_gold;dragunov camo_gold";

	// Get the last array of camos unlocked for this player
	camoix = self getStat( 3151 );
	
	// Check if we need to unlock attachments
	if ( camoix >= camoList.size )
		return;
			
	// Cycle the list of camos and unlock them
	while ( camoix < camoList.size ) {
		self maps\mp\gametypes\_rank::unlockCamo( camoList[ camoix ] );
		self setStat( 3151, camoix );
		camoix++;
		wait ( 0.5 );
	}	
	self setStat( 3151, camoList.size );
	self iprintlnbold( &"OW_POWER_RANK_CAMOS" );
	
	return;	
}

