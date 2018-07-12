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

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

#include openwarfare\_utils;

init()
{
	if( !isDefined( game["class_counts"] ) )
	{
		game["class_counts"] = [];

		game["class_counts"]["allies_assault"] = 0;
		game["class_counts"]["allies_assault_gl"] = 0;
		game["class_counts"]["allies_specops"] = 0;
		game["class_counts"]["allies_heavygunner"] = 0;
		game["class_counts"]["allies_demolitions"] = 0;
		game["class_counts"]["allies_sniper"] = 0;

		game["class_counts"]["axis_assault"] = 0;
		game["class_counts"]["axis_assault_gl"] = 0;
		game["class_counts"]["axis_specops"] = 0;
		game["class_counts"]["axis_heavygunner"] = 0;
		game["class_counts"]["axis_demolitions"] = 0;
		game["class_counts"]["axis_sniper"] = 0;
	}

	if( !isDefined( game["perk_counts"] ) )
	{
		game["perk_counts"] = [];

		game["perk_counts"]["allies_claymore"] = 0;
		game["perk_counts"]["allies_c4"] = 0;
		game["perk_counts"]["allies_rpg"] = 0;
		
		game["perk_counts"]["axis_claymore"] = 0;
		game["perk_counts"]["axis_c4"] = 0;
		game["perk_counts"]["axis_rpg"] = 0;
	}

	if( !isDefined( game["misc"] ) )
	{
		game["misc"] = [];

		game["misc"]["allies_smoke"] = 0;
		game["misc"]["axis_smoke"] = 0;
	}
	
	// Initialize arrays
	game["mwf_classes"] = [];
	game["mwf_weapons"] = [];
	game["mwf_weapons_aux"] = [];
	game["mwf_attachments"] = [];
	game["mwf_perks"] = [];

	// Initialize variable to control updateClassLimits()
	level.updateClassLimitsWaiting = false;
	level.updateClassLimitsRunning = false;
	level.ignoreUpdateClassLimit = false;

	//**************************************************************************
	// Assault weapons:
	//**************************************************************************
	initWeaponData( "m16", "assault", "allies" );
	initWeaponData( "ak47", "assault", "axis" );
	initWeaponData( "m4", "assault", "allies" );
	initWeaponData( "g3", "assault", "axis" );
	initWeaponData( "g36c", "assault", "allies" );
	initWeaponData( "m14", "assault", "allies" );
	initWeaponData( "mp44", "assault", "axis" );
	initWeaponAttachments( "assault", "none;gl;reflex;silencer;acog" );
	game["attach_assault_gl_limit"] = getdvarx( "attach_assault_gl_limit", "int", 64, 0, 64 );
			
	//**************************************************************************
	// Specops weapons:
	//**************************************************************************
	initWeaponData( "mp5", "specops", "allies" );
	initWeaponData( "skorpion", "specops", "axis" );
	initWeaponData( "uzi", "specops", "axis" );
	initWeaponData( "ak74u", "specops", "axis" );
	initWeaponData( "p90", "specops", "allies" );
	initWeaponAttachments( "specops", "none;reflex;silencer;acog" );

	//**************************************************************************
	// Heavygunner weapons:
	//**************************************************************************
	initWeaponData( "saw", "heavygunner", "allies" );
	initWeaponData( "rpd", "heavygunner", "axis" );
	initWeaponData( "m60e4", "heavygunner", "allies" );
	initWeaponAttachments( "heavygunner", "none;reflex;grip;acog" );
	
	//**************************************************************************
	// Demolitions weapons:
	//**************************************************************************
	initWeaponData( "winchester1200", "demolitions", "axis" );
	initWeaponData( "m1014", "demolitions", "allies" );
	initWeaponAttachments( "demolitions", "none;reflex;grip" );
	
	//**************************************************************************
	// Sniper weapons:
	//**************************************************************************
	initWeaponData( "dragunov", "sniper", "axis" );
	initWeaponData( "m40a3", "sniper", "allies" );
	initWeaponData( "barrett", "sniper", "allies" );
	initWeaponData( "remington700", "sniper", "axis" );
	initWeaponData( "m21", "sniper", "allies" );
	initWeaponAttachments( "sniper", "none;acog" );
		
	//**************************************************************************
	// Handguns
	//**************************************************************************
	initWeaponData( "beretta", "all", "allies" );
	initWeaponData( "colt45", "all", "axis" );
	initWeaponData( "usp", "all", "allies" );
	initWeaponData( "deserteagle", "all", "axis" );
	initWeaponData( "deserteaglegold", "all", "axis" );
	initWeaponAttachments( "pistol", "none;silencer" );
	
	//**************************************************************************
	// Primary and Special Grenades
	//**************************************************************************
	initWeaponData( "frag_grenade", "all", "all" );
	initWeaponData( "concussion_grenade", "all", "all" );
	initWeaponData( "flash_grenade", "all", "all" );
	initWeaponData( "smoke_grenade", "all", "all" );
	
	//**************************************************************************
	// Perks
	//**************************************************************************
	initPerkData( "c4_mp" );
	initPerkData( "specialty_specialgrenade" );
	initPerkData( "rpg_mp" );
	initPerkData( "claymore_mp" );
	initPerkData( "specialty_fraggrenade" );
	initPerkData( "specialty_extraammo" );
	initPerkData( "specialty_detectexplosive" );
	
	game["perk_claymore_mp_limit"] = getdvarx( "perk_claymore_mp_limit", "int", 64, 0, 64 );
	game["perk_rpg_mp_limit"] = getdvarx( "perk_rpg_mp_limit", "int", 64, 0, 64 );
	game["perk_c4_mp_limit"] = getdvarx( "perk_c4_mp_limit", "int", 64, 0, 64 );
	
	game["smoke_grenade_limit"] = getdvarx( "smoke_grenade_limit", "int", 64, 0, 64 );
	
	initPerkData( "specialty_bulletdamage" );
	initPerkData( "specialty_armorvest" );
	initPerkData( "specialty_fastreload" );
	initPerkData( "specialty_rof" );
	initPerkData( "specialty_gpsjammer" );
	initPerkData( "specialty_explosivedamage" );
	
	initPerkData( "specialty_longersprint" );
	initPerkData( "specialty_bulletaccuracy" );
	initPerkData( "specialty_pistoldeath" );
	initPerkData( "specialty_grenadepulldeath" );
	initPerkData( "specialty_bulletpenetration" );
	initPerkData( "specialty_holdbreath" );
	initPerkData( "specialty_quieter" );
	initPerkData( "specialty_parabolic" );
	
	// Classes
	initClassData( "assault", "m16;m16;ak47", "gl", "camo_none", "beretta;beretta;deserteagle", "none", "specialty_null", "specialty_bulletdamage", "specialty_longersprint", "frag_grenade", 1, "concussion_grenade", 1 );
	initClassData( "specops", "mp5;mp5;p90", "none", "camo_none", "usp;usp;deserteagle", "silencer", "c4_mp", "specialty_explosivedamage", "specialty_bulletaccuracy", "frag_grenade", 1, "flash_grenade", 1 );
	initClassData( "heavygunner", "saw;saw;rpd", "none", "camo_none", "usp;usp;deserteagle", "none", "specialty_specialgrenade", "specialty_armorvest", "specialty_bulletpenetration", "frag_grenade", 1, "concussion_grenade", 1 );
	initClassData( "demolitions", "winchester1200;m1014;winchester1200", "none", "camo_none", "beretta;beretta;deserteagle", "none", "rpg_mp", "specialty_explosivedamage", "specialty_longersprint", "frag_grenade", 1, "smoke_grenade", 1 );
	initClassData( "sniper", "m40a3;m40a3;dragunov", "none", "camo_none", "beretta;beretta;deserteagle", "silencer", "specialty_specialgrenade", "specialty_bulletdamage", "specialty_bulletpenetration", "frag_grenade", 1, "flash_grenade", 1 );

	level thread onPlayerConnect();
	//level thread openwarfare\unrankedbots::init();
}

initWeaponData( weaponName, weaponClass, weaponTeam )
{
	// Check if we already have this class
	if ( !isDefined( game["mwf_weapons"][weaponClass] ) ) {
		game["mwf_weapons"][weaponClass] = [];
		game["mwf_weapons_aux"][weaponClass] = [];
	}
	
	// Get the new element
	newElement = game["mwf_weapons"][weaponClass].size;
	
	// Save the new index for quick access
	game["mwf_weapons_aux"][weaponClass][weaponName] = newElement;
	
	game["mwf_weapons"][weaponClass][newElement] = [];
	game["mwf_weapons"][weaponClass][newElement]["name"] = weaponName;
	
	if ( weaponClass != "all" )
		game["mwf_weapons"][weaponClass][newElement]["allow"] = getdvarx( "weap_allow_" + weaponClass + "_" + weaponName, "int", 1, 0, 2 );
	else
		game["mwf_weapons"][weaponClass][newElement]["allow"] = getdvarx( "weap_allow_" + weaponName, "int", 1, 0, 2 );
		
	game["mwf_weapons"][weaponClass][newElement]["team"] = weaponTeam;
}

isWeaponAllowed( weaponClass, weaponName, playerTeam )
{
	weaponAllowed = 0;
	
	iWeapon = game["mwf_weapons_aux"][weaponClass][weaponName];
	if ( isDefined( iWeapon ) ) {
		// 0 = Not allowed, 1 = Allowed for all, 2 = Allowed for team
		if ( game["mwf_weapons"][weaponClass][iWeapon]["allow"] == 1 ) {
			weaponAllowed = 1;
		} else if ( game["mwf_weapons"][weaponClass][iWeapon]["allow"] == 2 && ( game["mwf_weapons"][weaponClass][iWeapon]["team"] == "all" || game["mwf_weapons"][weaponClass][iWeapon]["team"] == playerTeam ) ) {
			weaponAllowed = 1;
		}					
	}
	
	return weaponAllowed;	
}

initWeaponAttachments( weaponClass, weaponAttachments )
{
	game["mwf_attachments"][weaponClass] = [];
	
	// Spam list of attachments
	weaponAttachments = strtok( weaponAttachments, ";" );
	for ( iAttach = 0; iAttach < weaponAttachments.size; iAttach++ ) {		
		game["mwf_attachments"][weaponClass][weaponAttachments[iAttach]] = getdvarx( "attach_allow_" + weaponClass + "_" + weaponAttachments[iAttach], "int", 1, 0, 1 );
	}
}

isAttachmentAllowed( weaponClass, attachmentName )
{
	return game["mwf_attachments"][weaponClass][attachmentName];	
}

initClassData( className, primary, attachment, camo, secondary, sattachment, perk1, perk2, perk3, pgrenade, pgrenade_count, sgrenade, sgrenade_count )
{
	// Load class limits
	game[ "allies_" + className + "_limit" ] = getdvarx( "class_allies_" + className + "_limit", "int", 64, 0, 64 );
	game[ "axis_" + className + "_limit" ] = getdvarx( "class_axis_" + className + "_limit", "int", 64, 0, 64 );
	
	// Add new element
	game["mwf_classes"][className] = [];
	game["mwf_classes"][className]["primary"] = getdvarx( "class_" + className + "_primary", "string", primary );
	game["mwf_classes"][className]["primary_attachment"] = getdvarx( "class_" + className + "_primary_attachment", "string", attachment );
	game["mwf_classes"][className]["secondary"] = getdvarx( "class_" + className + "_secondary", "string", secondary );
	game["mwf_classes"][className]["secondary_attachment"] = getdvarx( "class_" + className + "_secondary_attachment", "string", sattachment );
	game["mwf_classes"][className]["perk1"] = getDefaultPerk( className, 1, perk1 );
	game["mwf_classes"][className]["perk2"] = getDefaultPerk( className, 2, perk2 );
	game["mwf_classes"][className]["perk3"] = getDefaultPerk( className, 3, perk3 );
	game["mwf_classes"][className]["pgrenade_count"] = getdvarx( "class_" + className + "_pgrenade_count", "int", pgrenade_count, 0, 4 );
	game["mwf_classes"][className]["sgrenade"] = getdvarx( "class_" + className + "_sgrenade", "string", sgrenade );
	game["mwf_classes"][className]["sgrenade_count"] = getdvarx( "class_" + className + "_sgrenade_count", "int", sgrenade_count, 0, 4 );
	game["mwf_classes"][className]["camo"] = getdvarx( "class_" + className + "_camo", "string", camo );

	// Lock menu options
	game["mwf_classes"][className]["lock_primary"] = getdvarx( "class_" + className + "_lock_primary", "int", 0, 0, 1 );
	game["mwf_classes"][className]["lock_primary_attachment"] = getdvarx( "class_" + className + "_lock_primary_attachment", "int", 0, 0, 1 );
	game["mwf_classes"][className]["lock_secondary"] = getdvarx( "class_" + className + "_lock_secondary", "int", 0, 0, 1 );
	game["mwf_classes"][className]["lock_secondary_attachment"] = getdvarx( "class_" + className + "_lock_secondary_attachment", "int", 0, 0, 1 );
	game["mwf_classes"][className]["lock_perk1"] = getdvarx( "class_" + className + "_lock_perk1", "int", 0, 0, 1 );
	game["mwf_classes"][className]["lock_perk2"] = getdvarx( "class_" + className + "_lock_perk2", "int", 0, 0, 1 );
	game["mwf_classes"][className]["lock_perk3"] = getdvarx( "class_" + className + "_lock_perk3", "int", 0, 0, 1 );
	game["mwf_classes"][className]["lock_sgrenade"] = getdvarx( "class_" + className + "_lock_sgrenade", "int", 0, 0, 1 );
}

getDefaultPerk( className, perkNumber, defaultValue )
{
	// Get the default perk to use
	perkName = getdvarx( "class_" + className + "_perk" + perkNumber, "string", defaultValue );
	// Validate the perk
	if ( !isPerkAllowed( perkName, className ) ) {
		perkName = "specialty_null";
	}
	return perkName;	
}

initPerkData( perkName, varName )
{
	if ( !isDefined( varName ) ) {
		varName = perkName;
	}
	
	game["mwf_perks"][perkName] = [];
	perkAllowed = getdvarx( "perk_allow_" + varName, "int", 1, 0, 1 );	
	
	// Check if the perk status for the classes
	game["mwf_perks"][perkName]["assault"] = ( perkAllowed && getdvarx( "perk_assault_allow_" + varName, "int", perkAllowed, 0, 1 ) );	
	game["mwf_perks"][perkName]["specops"] = ( perkAllowed && getdvarx( "perk_specops_allow_" + varName, "int", perkAllowed, 0, 1 ) );	
	game["mwf_perks"][perkName]["heavygunner"] = ( perkAllowed && getdvarx( "perk_heavygunner_allow_" + varName, "int", perkAllowed, 0, 1 ) );	
	game["mwf_perks"][perkName]["demolitions"] = ( perkAllowed && getdvarx( "perk_demolitions_allow_" + varName, "int", perkAllowed, 0, 1 ) );	
	game["mwf_perks"][perkName]["sniper"] = ( perkAllowed && getdvarx( "perk_sniper_allow_" + varName, "int", perkAllowed, 0, 1 ) );	
	
}

isPerkAllowed( perkName, className )
{
	if ( isDefined( game["mwf_perks"][perkName] ) && isDefined( game["mwf_perks"][perkName][className] ) ) 
		return ( game["mwf_perks"][perkName][className] );	
	else
		return 0;
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		
		player thread onPlayerDisconnect();
		player thread onJoinedTeam();
		player thread onJoinedSpectators();		
		
		player thread setNonClassSpecificDvars();		
	}
}

onPlayerDisconnect()
{
	self waittill( "disconnect" );
	level thread updateClassLimits();
}

onJoinedTeam()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_team");
		// If this player already has a class it means it switched teams 
		if ( isDefined( self.pers["class"] ) && self resetPlayerClassOnTeamSwitch( false ) ) {
			self thread setLoadoutForClass( self.pers["class"] );
		}
		
		// Get player's team
		playerTeam = self.pers["team"];
		
		self thread setClassIndependent( playerTeam );
		self thread setClassDependent( playerTeam );
		
		if ( !level.ignoreUpdateClassLimit ) {
			level thread updateClassLimits();
		}
	}
}

onJoinedSpectators()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_spectators");
		self.pers["oldteam"] = "spectator";
		level thread updateClassLimits();
	}
}

updateClassLimits()
{
	// Check if there's another thread waiting
	if ( level.updateClassLimitsWaiting )
		return;
		
	// Check if there's another thread running
	if ( level.updateClassLimitsRunning ) {
		// Flag that the thread is waiting and wait for the running thread to finish
		level.updateClassLimitsWaiting = true;
		while ( level.updateClassLimitsRunning )
			wait (0.05);
		// Flag that we stopped waiting
		level.updateClassLimitsWaiting = false;
	}
	
	// Flag that we are running
	level.updateClassLimitsRunning = true;	
	
	counts = [];

	counts["axis_assault"] = 0;
	counts["axis_gl"] = 0;	
	counts["axis_specops"] = 0;
	counts["axis_heavygunner"] = 0;
	counts["axis_demolitions"] = 0;
	counts["axis_sniper"] = 0;

	counts["allies_assault"] = 0;
	counts["allies_gl"] = 0;
	counts["allies_specops"] = 0;
	counts["allies_heavygunner"] = 0;
	counts["allies_demolitions"] = 0;
	counts["allies_sniper"] = 0;

	perkcounts = [];
	perkcounts["allies_claymore"] = 0;
	perkcounts["allies_c4"] = 0;
	perkcounts["allies_rpg"] = 0;
	
	perkcounts["axis_claymore"] = 0;
	perkcounts["axis_c4"] = 0;
	perkcounts["axis_rpg"] = 0;

	misc = [];
	misc["allies_smoke"] = 0;
	misc["axis_smoke"] = 0;

	players = level.players;
	for( i=0; i<players.size; i++ )
	{
		player = players[i];
		if( isDefined( player ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" && isDefined( player.pers["class"] ) )
		{
			counts[ player.pers["team"] + "_" + player.pers["class"] ]++;
			
			// Check if this player is using the grenade launcher
			if ( ( player.pers["class"] == "assault" && player.pers["assault"]["loadout_primary_attachment"] == "gl" ) ) {
				counts[ player.pers["team"] + "_gl" ]++;
			}
			
			// Check for perk1 
			switch ( player.pers[player.pers["class"]]["loadout_perk1"] ) {
				case "claymore_mp":
					perkcounts[ player.pers["team"] + "_claymore" ]++;
					break;
				case "rpg_mp":
					perkcounts[ player.pers["team"] + "_rpg" ]++;
					break;
				case "c4_mp":
					perkcounts[ player.pers["team"] + "_c4" ]++;
					break;															
			}
			
			// Check for special grenades
			switch ( player.pers[player.pers["class"]]["loadout_sgrenade"] ) {
				case "smoke_grenade":
					misc[ player.pers["team"] + "_smoke" ]++;
					break;
			}
						
		}
	}

	game["class_counts"] = counts;
	game["perk_counts"] = perkcounts;
	game["misc"] = misc;

	players = level.players;
	for( i=0; i<players.size; i++ )
		players[i] thread updateAvailableClasses();
		
	// Thread completed
	level.updateClassLimitsRunning = false;
}

setNonClassSpecificDvars()
{
	self endon("disconnect");
	
	// Wait until the player joins a team to delay settings of variables
	self waittill("joined_team");
	
	self setClientDvars( 
		"attach_allow_assault_none", game["mwf_attachments"]["assault"]["none"],
		"attach_allow_assault_reflex", game["mwf_attachments"]["assault"]["reflex"],
		"attach_allow_assault_silencer", game["mwf_attachments"]["assault"]["silencer"],
		"attach_allow_assault_acog", game["mwf_attachments"]["assault"]["acog"],
		
		"attach_allow_specops_none", game["mwf_attachments"]["specops"]["none"],
		"attach_allow_specops_reflex", game["mwf_attachments"]["specops"]["reflex"],
		"attach_allow_specops_silencer", game["mwf_attachments"]["specops"]["silencer"],
		"attach_allow_specops_acog", game["mwf_attachments"]["specops"]["acog"]		
	);

	self setClientDvars( 
		"attach_allow_heavygunner_none", game["mwf_attachments"]["heavygunner"]["none"],
		"attach_allow_heavygunner_reflex", game["mwf_attachments"]["heavygunner"]["reflex"],
		"attach_allow_heavygunner_grip", game["mwf_attachments"]["heavygunner"]["grip"],
		"attach_allow_heavygunner_acog", game["mwf_attachments"]["heavygunner"]["acog"],
		
		"attach_allow_demolitions_none", game["mwf_attachments"]["demolitions"]["none"],
		"attach_allow_demolitions_reflex", game["mwf_attachments"]["demolitions"]["reflex"],
		"attach_allow_demolitions_grip", game["mwf_attachments"]["demolitions"]["grip"],

		"attach_allow_sniper_none", game["mwf_attachments"]["sniper"]["none"],
		"attach_allow_sniper_acog", game["mwf_attachments"]["sniper"]["acog"],

		"attach_allow_pistol_none", game["mwf_attachments"]["pistol"]["none"],
		"attach_allow_pistol_silencer", game["mwf_attachments"]["pistol"]["silencer"]
	);
}

updateAvailableClasses()
{
	// Get the player's current class
	if ( !isDefined( self.pers["class"] ) ) {
		playerClass = "";
	} else {
		playerClass = self.pers["class"];
	}

	// Item limitations
	playerTeam = self.pers["team"];
	if ( isDefined( playerTeam ) && playerTeam != "spectator" && playerClass != "" ) {
		perkClaymore = isUnderLimit( game["mwf_perks"]["claymore_mp"][playerClass], game["perk_claymore_mp_limit"], game["perk_counts"][playerTeam+"_claymore"] );
		perkRPG = isUnderLimit( game["mwf_perks"]["rpg_mp"][playerClass], game["perk_rpg_mp_limit"], game["perk_counts"][playerTeam+"_rpg"] );
		perkC4 = isUnderLimit( game["mwf_perks"]["c4_mp"][playerClass], game["perk_c4_mp_limit"], game["perk_counts"][playerTeam+"_c4"] );
	} else {
		perkClaymore = 0;
		perkRPG = 0;
		perkC4 = 0;
	}

	// Item limitations
	if ( isDefined( playerTeam ) && playerTeam != "spectator" ) {
		assaultGL = isUnderLimit( game["mwf_attachments"]["assault"]["gl"], game["attach_assault_gl_limit"], game["class_counts"][playerTeam + "_gl"] );
		smokeGrenade = isUnderLimit( isWeaponAllowed( "all", "smoke_grenade", "all" ), game["smoke_grenade_limit"], game["misc"][playerTeam +"_smoke"] );
	} else {
		assaultGL = 0;
		smokeGrenade = 0;
	}
	
	self setClientDvars(
		"perk_allow_claymore_mp", ( perkClaymore ),
		"perk_allow_rpg_mp", ( perkRPG ),
		"perk_allow_c4_mp", ( perkC4 ),

		"allies_allow_assault", ( game["allies_assault_limit"] > game["class_counts"]["allies_assault"] || ( game["allies_assault_limit"] > 0 && playerClass == "assault" )),
		"allies_allow_specops", ( game["allies_specops_limit"] > game["class_counts"]["allies_specops"] || ( game["allies_specops_limit"] > 0 && playerClass == "specops" )),
		"allies_allow_heavygunner", ( game["allies_heavygunner_limit"] > game["class_counts"]["allies_heavygunner"] || ( game["allies_heavygunner_limit"] > 0 && playerClass == "heavygunner" )),
		"allies_allow_demolitions", ( game["allies_demolitions_limit"] > game["class_counts"]["allies_demolitions"] || ( game["allies_demolitions_limit"] > 0 && playerClass == "demolitions" )),
		"allies_allow_sniper", ( game["allies_sniper_limit"] > game["class_counts"]["allies_sniper"] || ( game["allies_sniper_limit"] > 0 && playerClass == "sniper" )),

		
		"axis_allow_assault", ( game["axis_assault_limit"] > game["class_counts"]["axis_assault"] || ( game["axis_assault_limit"] > 0 && playerClass == "assault" )),
		"axis_allow_specops", ( game["axis_specops_limit"] > game["class_counts"]["axis_specops"] || ( game["axis_specops_limit"] > 0 && playerClass == "specops" )),
		"axis_allow_heavygunner", ( game["axis_heavygunner_limit"] > game["class_counts"]["axis_heavygunner"] || ( game["axis_heavygunner_limit"] > 0 && playerClass == "heavygunner" )),
		"axis_allow_demolitions", ( game["axis_demolitions_limit"] > game["class_counts"]["axis_demolitions"] || ( game["axis_demolitions_limit"] > 0 && playerClass == "demolitions" )),
		"axis_allow_sniper", ( game["axis_sniper_limit"] > game["class_counts"]["axis_sniper"] || ( game["axis_sniper_limit"] > 0 && playerClass == "sniper" )),
						 
		"attach_allow_assault_gl", ( assaultGL ),
		"weap_allow_smoke_grenade", ( smokeGrenade )
	);
}

isUnderLimit( itemEnabled, itemLimit, itemCount )
{
	if ( itemEnabled == 1 ) {
		if ( itemLimit > itemCount ) {
			itemAllowed = 1;
		} else {
			itemAllowed = 0;
		}
	} else {
		itemAllowed = 0;
	}		
	
	return itemAllowed;
}

setLoadoutForClass( classType )
{
	// Check if this player changed teams
	if ( !isDefined( self.pers["oldteam"] ) || self.pers["team"] != self.pers["oldteam"] ) {
		changedTeam = true;
		self.pers["oldteam"] = self.pers["team"];
	} else {
		changedTeam = false;		
	}
	
	if ( !isDefined( self.pers[classType] ) || changedTeam || self resetPlayerClassOnTeamSwitch( false ) )
	{
		self.pers[classType]["loadout_primary"] = self getDefaultLoadoutWeapon( classType, game["mwf_classes"][classType]["primary"] );
		if ( isSubstr( "mp44", self.pers[classType]["loadout_primary"] ) ) {
			self.pers[classType]["loadout_primary_attachment"] = "none";
		} else {		
			self.pers[classType]["loadout_primary_attachment"] = game["mwf_classes"][classType]["primary_attachment"];
		}
		
		self.pers[classType]["loadout_secondary"] = self getDefaultLoadoutWeapon( "all", game["mwf_classes"][classType]["secondary"] );
		if ( isSubstr( "deserteagle", self.pers[classType]["loadout_secondary"] ) ) {
			self.pers[classType]["loadout_secondary_attachment"] = "none";
		} else {
			self.pers[classType]["loadout_secondary_attachment"] = game["mwf_classes"][classType]["secondary_attachment"];		
		}
		
		self.pers[classType]["loadout_perk1"] = game["mwf_classes"][classType]["perk1"];
		self.pers[classType]["loadout_perk2"] = game["mwf_classes"][classType]["perk2"];
		self.pers[classType]["loadout_perk3"] = game["mwf_classes"][classType]["perk3"];
		self.pers[classType]["loadout_sgrenade"] = game["mwf_classes"][classType]["sgrenade"];
		self.pers[classType]["loadout_sgrenade_count"] = game["mwf_classes"][classType]["sgrenade_count"];
		self.pers[classType]["loadout_pgrenade_count"] = game["mwf_classes"][classType]["pgrenade_count"];
		self.pers[classType]["loadout_camo"] = game["mwf_classes"][classType]["camo"];
	}

	self setClientDvars(
		"loadout_class", classType,
		"loadout_primary", self.pers[classType]["loadout_primary"],
		"loadout_primary_attachment", self.pers[classType]["loadout_primary_attachment"],
		"loadout_secondary", self.pers[classType]["loadout_secondary"],
		"loadout_secondary_attachment", self.pers[classType]["loadout_secondary_attachment"],
		"loadout_perk1", self.pers[classType]["loadout_perk1"],
		"loadout_perk2", self.pers[classType]["loadout_perk2"],
		"loadout_perk3", self.pers[classType]["loadout_perk3"],
		"loadout_grenade",	self.pers[classType]["loadout_sgrenade"],
		"loadout_camo", self.pers[classType]["loadout_camo"],
		"loadout_frags", self.pers[classType]["loadout_pgrenade_count"],
		"loadout_special", self.pers[classType]["loadout_sgrenade_count"]
	);

	
	self setClientDvars(
		"lock_primary", game["mwf_classes"][classType]["lock_primary"],
		"lock_primary_attachment", game["mwf_classes"][classType]["lock_primary_attachment"],
		"lock_secondary", game["mwf_classes"][classType]["lock_secondary"],
		"lock_secondary_attachment", game["mwf_classes"][classType]["lock_secondary_attachment"],
		"lock_perk1", game["mwf_classes"][classType]["lock_perk1"],
		"lock_perk2", game["mwf_classes"][classType]["lock_perk2"],
		"lock_perk3", game["mwf_classes"][classType]["lock_perk3"],
		"lock_grenade", game["mwf_classes"][classType]["lock_sgrenade"]
	);
}

getDefaultLoadoutWeapon( weaponClass, defaultWeapons )
{
	// Get player's team
	playerTeam = self.pers["team"];

	// Spam the weapon names
	// [0] = No restriction, [1] = Allies default weapon, [2] = Axis default weapon
	defaultWeapons = strtok( defaultWeapons, ";" );
	defaultWeapon = defaultWeapons[0];
	arrayPosition = 0;
	
	iWeapon = game["mwf_weapons_aux"][weaponClass][defaultWeapon];
	
	if ( isDefined( iWeapon ) ) {
		if ( game["mwf_weapons"][weaponClass][iWeapon]["allow"] == 2 ) {
			if ( playerTeam == "allies" ) {
				arrayPosition = 1;
			} else {
				arrayPosition = 2;					
			}				
		}
		
		// Check if the element has been defined
		if ( isDefined( defaultWeapons[arrayPosition] ) ) {
			defaultWeapon = defaultWeapons[arrayPosition];
		}
	}
	
	return defaultWeapon;	
}


verifyClassChoice( teamName, classType )
{
	if( isDefined( self.class ) && self.class == classType && game[teamName+"_"+classType+"_limit"] )
		return true;

	return ( game[teamName+"_"+classType+"_limit"] > game["class_counts"][teamName+"_"+classType] );
}

setClassChoice( classType )
{
	// Check if the player already had a class
	if ( !isDefined( self.pers["class"] ) || self.pers["class"] != classType || self resetPlayerClassOnTeamSwitch( false ) ) {
		self.pers["class"] = classType;
		self.class = classType;
	
		self thread setLoadoutForClass( classType );
	}

	self thread setClassPerks( classType );
	level thread updateClassLimits();
}


setClassPerks( classType )
{
	// Process which perks are allowed under the player's class
	self setClientDvars( 
		"perk_allow_specialty_specialgrenade", game["mwf_perks"]["specialty_specialgrenade"][classType],
		"perk_allow_specialty_fraggrenade", game["mwf_perks"]["specialty_fraggrenade"][classType],
		"perk_allow_specialty_extraammo", game["mwf_perks"]["specialty_extraammo"][classType],
		"perk_allow_specialty_detectexplosive", game["mwf_perks"]["specialty_detectexplosive"][classType],

		"perk_allow_specialty_bulletdamage", game["mwf_perks"]["specialty_bulletdamage"][classType],
		"perk_allow_specialty_armorvest", game["mwf_perks"]["specialty_armorvest"][classType],
		"perk_allow_specialty_fastreload", game["mwf_perks"]["specialty_fastreload"][classType],
		"perk_allow_specialty_rof", game["mwf_perks"]["specialty_rof"][classType],
		"perk_allow_specialty_gpsjammer", game["mwf_perks"]["specialty_gpsjammer"][classType]
	);
	self setClientDvars( 
		"perk_allow_specialty_explosivedamage", game["mwf_perks"]["specialty_explosivedamage"][classType],

		"perk_allow_specialty_longersprint", game["mwf_perks"]["specialty_longersprint"][classType],
		"perk_allow_specialty_bulletaccuracy", game["mwf_perks"]["specialty_bulletaccuracy"][classType],
		"perk_allow_specialty_pistoldeath", game["mwf_perks"]["specialty_pistoldeath"][classType],
		"perk_allow_specialty_grenadepulldeath", game["mwf_perks"]["specialty_grenadepulldeath"][classType],
		"perk_allow_specialty_bulletpenetration", game["mwf_perks"]["specialty_bulletpenetration"][classType],
		"perk_allow_specialty_holdbreath", game["mwf_perks"]["specialty_holdbreath"][classType],
		"perk_allow_specialty_quieter", game["mwf_perks"]["specialty_quieter"][classType],
		"perk_allow_specialty_parabolic", game["mwf_perks"]["specialty_parabolic"][classType]
	);		
}

setClassDependent( playerTeam )
{
	// Initialize classes
	classTypes =[];
	classTypes[classTypes.size] = "assault";
	classTypes[classTypes.size] = "specops";
	classTypes[classTypes.size] = "heavygunner";
	classTypes[classTypes.size] = "demolitions";
	classTypes[classTypes.size] = "sniper";
	
	for ( iClass = 0; iClass < classTypes.size; iClass++ ) {
		classType = classTypes[iClass];
		
		// Process the weapons for this class
		for ( iWeapon=0; iWeapon < game["mwf_weapons"][classType].size; iWeapon++ ) {
		
			varName = "weap_allow_" + classType + "_" + game["mwf_weapons"][classType][iWeapon]["name"];
			weaponAllowed = isWeaponAllowed( classType, game["mwf_weapons"][classType][iWeapon]["name"], playerTeam );
			
			self setClientDvar( varName, weaponAllowed );		
		}	
	}
}

setClassIndependent( playerTeam )
{
	// Process the weapons that apply for all the classes
	for ( iWeapon=0; iWeapon < game["mwf_weapons"]["all"].size; iWeapon++ ) {
		wait (0.01);
		
		varName = "weap_allow_" + game["mwf_weapons"]["all"][iWeapon]["name"];
		// Make sure we don't do set the smoke grenade here anymore
		if ( varName != "weap_allow_smoke_grenade" ) {
			weaponAllowed = isWeaponAllowed( "all", game["mwf_weapons"]["all"][iWeapon]["name"], playerTeam );
			self setClientDvar( varName, weaponAllowed );			
		}
	}	
}


// handle script menu responses related to loadout changes
processLoadoutResponse( respString )
{
	commandTokens = strTok( respString, "," );

	// Get player's team
	playerTeam = self.pers["team"];

	for ( index = 0; index < commandTokens.size; index++ )
	{
		subTokens = strTok( commandTokens[index], ":" );
		assert( subTokens.size > 1 );

		switch ( subTokens[0] )
		{
			case "loadout_primary":
				if ( isWeaponAllowed( self.class, subTokens[1], playerTeam ) && self verifyWeaponChoice( subTokens[1], self.class ) )
				{
					self.pers[self.class][subTokens[0]] = subTokens[1];
					self setClientDvar( subTokens[0], subTokens[1] );
	
					if ( subTokens[1] == "mp44" )
					{
						self.pers[self.class]["loadout_primary_attachment"] = "none";
						self setClientDvar( "loadout_primary_attachment", "none" );
					}
				}
				else
				{
					// invalid selection, so reset them to their class default
					self setClientDvar( subTokens[0], self.pers[self.class][subTokens[0]] );
				}
				break;
				
			case "loadout_secondary":
				if ( isWeaponAllowed( "all", subTokens[1], playerTeam ) && self verifyWeaponChoice( subTokens[1], self.class ) )
				{
					self.pers[self.class][subTokens[0]] = subTokens[1];
					self setClientDvar( subTokens[0], subTokens[1] );
					
					if ( subTokens[1] == "deserteagle" || subTokens[1] == "deserteaglegold" )
					{
						self.pers[self.class]["loadout_secondary_attachment"] = "none";
						self setClientDvar( "loadout_secondary_attachment", "none" );
					}
				}
				else
				{
					// invalid selection, so reset them to their class default
					self setClientDvar( subTokens[0], self.pers[self.class][subTokens[0]] );
				}
				break;

			case "loadout_primary_attachment":
			case "loadout_secondary_attachment":				
				if ( subTokens[0] == "loadout_primary_attachment" && self.pers[self.class]["loadout_primary"] == "mp44" )
				{
					self.pers[self.class]["loadout_primary_attachment"] = "none";
					self setClientDvar( "loadout_primary_attachment", "none" );
				} else if ( isAttachmentAllowed( subTokens[1], subTokens[2] ) ) {
					self.pers[self.class][subTokens[0]] = subTokens[2];
					self setClientDvar( subTokens[0], subTokens[2] );
					// grenade launchers and grips take up the perk 1 slot
					if ( subTokens[2] == "gl" || subTokens[2] == "grip" )
					{
						self.pers[self.class]["loadout_perk1"] = "specialty_null";
						self setClientDvar( "loadout_perk1", "specialty_null" );
					}
				}
				else
				{
					// invalid selection, so reset them to their class default
					self setClientDvar( subTokens[0], self.pers[self.class][subTokens[0]] );
				}
				
				level thread updateClassLimits();
				break;

			case "loadout_perk1":
			case "loadout_perk2":
			case "loadout_perk3":
				if ( isPerkAllowed( subTokens[1], self.class ) )
				{
					self.pers[self.class][subTokens[0]] = subTokens[1];
					self setClientDvar( subTokens[0], subTokens[1] );
				}
				else
				{
					// invalid selection, so reset them to their class default
					self setClientDvar( subTokens[0], self.pers[self.class][subTokens[0]] );
				}
				
				if ( subTokens[0] == "loadout_perk1" ) {
					level thread updateClassLimits();
				}
				break;

			case "loadout_grenade":
				if ( isWeaponAllowed( "all", subTokens[1], playerTeam ) )
				{
					self.pers[self.class]["loadout_sgrenade"] = subTokens[1];
					self setClientDvar( subTokens[0], subTokens[1] );
					level thread updateClassLimits();
				}
				else
				{
					// invalid selection, so reset them to their class default
					self setClientDvar( subTokens[0], self.pers[self.class][subTokens[0]] );
				}
				break;

			case "loadout_camo":
				if ( getdvarint("scr_disable_camo") == 0 )
				{
					self.pers[self.class][subTokens[0]] = subTokens[1];
					self setClientDvar( subTokens[0], subTokens[1] );
				}
				else
				{
					// invalid selection, so reset them to their class default
					self setClientDvar( subTokens[0], self.pers[self.class][subTokens[0]] );
				}
				break;

		}
	}
}

verifyWeaponChoice( weaponName, classType )
{
	if ( tableLookup( "mp/statsTable.csv", 4, weaponName, 2 ) == "weapon_pistol" )
		return true;

	switch ( classType )
	{
		case "assault":
			if ( tableLookup( "mp/statsTable.csv", 4, weaponName, 2 ) == "weapon_assault" )
				return true;
			break;
		case "specops":
			if ( tableLookup( "mp/statsTable.csv", 4, weaponName, 2 ) == "weapon_smg" )
				return true;
			break;
		case "heavygunner":
			if ( tableLookup( "mp/statsTable.csv", 4, weaponName, 2 ) == "weapon_lmg" )
				return true;
			break;
		case "demolitions":
			if ( tableLookup( "mp/statsTable.csv", 4, weaponName, 2 ) == "weapon_shotgun" )
				return true;
			break;
		case "sniper":
			if ( tableLookup( "mp/statsTable.csv", 4, weaponName, 2 ) == "weapon_sniper" )
				return true;
			break;
	}

	return false;
}

menuAcceptClass()
{
	self maps\mp\gametypes\_globallogic::closeMenus();

	// this should probably be an assert
	if(!isDefined(self.pers["team"]) || (self.pers["team"] != "allies" && self.pers["team"] != "axis"))
		return;

	// already playing
	if ( self.sessionstate == "playing" )
	{
		self.pers["primary"] = undefined;
		self.pers["weapon"] = undefined;

		if ( game["state"] == "postgame" )
			return;

		if ( ( ( level.inGracePeriod || level.inStrategyPeriod ) && !self.hasDoneCombat && ( level.gametype != "ass" || !isDefined( self.isVIP ) || !self.isVIP ) ) || ( level.gametype == "ftag" && self.freezeTag["frozen"] ) )
		{
			self thread deleteExplosives();
			self.tag_stowed_back = undefined;
			self.tag_stowed_hip = undefined;
			self maps\mp\gametypes\_class_unranked::giveLoadout( self.pers["team"], self.pers["class"] );
		}
		else
		{
			self iPrintLnBold( game["strings"]["change_class"] );

			if ( level.numLives == 1 && !level.inGracePeriod && self.curClass != self.pers["class"] )
			{
				self setClientDvar( "loadout_curclass", "" );
				self.curClass = undefined;
			}
		}
	}
	else
	{
		self.pers["primary"] = undefined;
		self.pers["weapon"] = undefined;

		if ( game["state"] == "postgame" )
			return;

		if ( game["state"] == "playing" )
			self thread [[level.spawnClient]]();
	}

	level thread maps\mp\gametypes\_globallogic::updateTeamStatus();
	self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
}
