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
#include openwarfare\_eventmanager;

init()
{
	level.scr_cap_enable = getdvarx( "scr_cap_enable", "int", 0, 0, 1 ); 
	level.scr_cap_time = getdvarx( "scr_cap_time", "float", 5.0, 1.0, 15.0 );
	level.scr_cap_activated = getdvarx( "scr_cap_time_activated", "float", 15.0, 5.0, 30.0 );
	level.scr_cap_firstspawn = getdvarx( "scr_cap_firstspawn", "int", 0, 0, 1 );
	
	if ( !level.scr_cap_enable || level.gametype == "ass" )
		return;
	
	initializeModelsArray();
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

initializeModelsArray()
{
	//Allies
	if ( game["allies_soldiertype"] == "desert" )
	{
		game["cap_allies_model"]["function"][0] = mptype\mptype_ally_rifleman::main;
		game["cap_allies_model"]["body_model"][0] = "body_mp_usmc_assault";
		game["cap_neutral_model"]["function"][0] = mptype\mptype_ally_rifleman::main;
		game["cap_neutral_model"]["body_model"][0] = "body_mp_usmc_assault";
		
		game["cap_allies_model"]["function"][1] = mptype\mptype_ally_cqb::main;
		game["cap_allies_model"]["body_model"][1] = "body_mp_usmc_specops";
		game["cap_neutral_model"]["function"][1] = mptype\mptype_ally_cqb::main;
		game["cap_neutral_model"]["body_model"][1] = "body_mp_usmc_specops";
		
		game["cap_allies_model"]["function"][2] = mptype\mptype_ally_support::main;
		game["cap_allies_model"]["body_model"][2] = "body_mp_usmc_support";
		game["cap_neutral_model"]["function"][2] = mptype\mptype_ally_support::main;
		game["cap_neutral_model"]["body_model"][2] = "body_mp_usmc_support";
		
		game["cap_allies_model"]["function"][3] = mptype\mptype_ally_engineer::main;
		game["cap_allies_model"]["body_model"][3] = "body_mp_usmc_recon";
		game["cap_neutral_model"]["function"][3] = mptype\mptype_ally_engineer::main;
		game["cap_neutral_model"]["body_model"][3] = "body_mp_usmc_recon";
		
		game["cap_allies_model"]["function"][4] = mptype\mptype_ally_sniper::main;
		game["cap_allies_model"]["body_model"][4] = "body_mp_usmc_sniper";
		game["cap_neutral_model"]["function"][4] = mptype\mptype_ally_sniper::main;
		game["cap_neutral_model"]["body_model"][4] = "body_mp_usmc_sniper";
	}
	else if ( game["allies_soldiertype"] == "urban" )
	{
		game["cap_allies_model"]["function"][0] = mptype\mptype_ally_urban_assault::main;
		game["cap_allies_model"]["body_model"][0] = "body_mp_sas_urban_assault";
		game["cap_neutral_model"]["function"][0] = mptype\mptype_ally_urban_assault::main;
		game["cap_neutral_model"]["body_model"][0] = "body_mp_sas_urban_assault";
		
		game["cap_allies_model"]["function"][1] = mptype\mptype_ally_urban_specops::main;
		game["cap_allies_model"]["body_model"][1] = "body_mp_sas_urban_specops";
		game["cap_neutral_model"]["function"][1] = mptype\mptype_ally_urban_specops::main;
		game["cap_neutral_model"]["body_model"][1] = "body_mp_sas_urban_specops";
		
		game["cap_allies_model"]["function"][2] = mptype\mptype_ally_urban_support::main;
		game["cap_allies_model"]["body_model"][2] = "body_mp_sas_urban_support";
		game["cap_neutral_model"]["function"][2] = mptype\mptype_ally_urban_support::main;
		game["cap_neutral_model"]["body_model"][2] = "body_mp_sas_urban_support";
		
		game["cap_allies_model"]["function"][3] = mptype\mptype_ally_urban_recon::main;
		game["cap_allies_model"]["body_model"][3] = "body_mp_sas_urban_recon";
		game["cap_neutral_model"]["function"][3] = mptype\mptype_ally_urban_recon::main;
		game["cap_neutral_model"]["body_model"][3] = "body_mp_sas_urban_recon";
		
		game["cap_allies_model"]["function"][4] = mptype\mptype_ally_urban_sniper::main;
		game["cap_allies_model"]["body_model"][4] = "body_mp_sas_urban_sniper";
		game["cap_neutral_model"]["function"][4] = mptype\mptype_ally_urban_sniper::main;
		game["cap_neutral_model"]["body_model"][4] = "body_mp_sas_urban_sniper";
	}
	else 
	{
		game["cap_allies_model"]["function"][0] = mptype\mptype_ally_woodland_assault::main;
		game["cap_allies_model"]["body_model"][0] = "body_mp_usmc_woodland_assault";
		game["cap_neutral_model"]["function"][0] = mptype\mptype_ally_woodland_assault::main;
		game["cap_neutral_model"]["body_model"][0] = "body_mp_usmc_woodland_assault";
		
		game["cap_allies_model"]["function"][1] = mptype\mptype_ally_woodland_specops::main;
		game["cap_allies_model"]["body_model"][1] = "body_mp_usmc_woodland_specops";
		game["cap_neutral_model"]["function"][1] = mptype\mptype_ally_woodland_specops::main;
		game["cap_neutral_model"]["body_model"][1] = "body_mp_usmc_woodland_specops";
		
		game["cap_allies_model"]["function"][2] = mptype\mptype_ally_woodland_support::main;
		game["cap_allies_model"]["body_model"][2] = "body_mp_usmc_woodland_support";
		game["cap_neutral_model"]["function"][2] = mptype\mptype_ally_woodland_support::main;
		game["cap_neutral_model"]["body_model"][2] = "body_mp_usmc_woodland_support";
		
		game["cap_allies_model"]["function"][3] = mptype\mptype_ally_woodland_recon::main;
		game["cap_allies_model"]["body_model"][3] = "body_mp_usmc_woodland_recon";
		game["cap_neutral_model"]["function"][3] = mptype\mptype_ally_woodland_recon::main;
		game["cap_neutral_model"]["body_model"][3] = "body_mp_usmc_woodland_recon";
		
		game["cap_allies_model"]["function"][4] = mptype\mptype_ally_woodland_sniper::main;
		game["cap_allies_model"]["body_model"][4] = "body_mp_usmc_woodland_sniper";
		game["cap_neutral_model"]["function"][4] = mptype\mptype_ally_woodland_sniper::main;
		game["cap_neutral_model"]["body_model"][4] = "body_mp_usmc_woodland_sniper";
	}
	
	//Opfor
	if ( game["axis_soldiertype"] == "desert" )
	{
		game["cap_axis_model"]["function"][0] = mptype\mptype_axis_rifleman::main;
		game["cap_axis_model"]["body_model"][0] = "body_mp_arab_regular_assault";
		game["cap_neutral_model"]["function"][5] = mptype\mptype_axis_rifleman::main;
		game["cap_neutral_model"]["body_model"][5] = "body_mp_arab_regular_assault";
		
		game["cap_axis_model"]["function"][1] = mptype\mptype_axis_cqb::main;
		game["cap_axis_model"]["body_model"][1] = "body_mp_arab_regular_cqb";
		game["cap_neutral_model"]["function"][6] = mptype\mptype_axis_cqb::main;
		game["cap_neutral_model"]["body_model"][6] = "body_mp_arab_regular_cqb";
		
		game["cap_axis_model"]["function"][2] = mptype\mptype_axis_support::main;
		game["cap_axis_model"]["body_model"][2] = "body_mp_arab_regular_support";
		game["cap_neutral_model"]["function"][7] = mptype\mptype_axis_support::main;
		game["cap_neutral_model"]["body_model"][7] = "body_mp_arab_regular_support";
		
		game["cap_axis_model"]["function"][3] = mptype\mptype_axis_engineer::main;
		game["cap_axis_model"]["body_model"][3] = "body_mp_arab_regular_engineer";
		game["cap_neutral_model"]["function"][8] = mptype\mptype_axis_engineer::main;
		game["cap_neutral_model"]["body_model"][8] = "body_mp_arab_regular_engineer";
		
		game["cap_axis_model"]["function"][4] = mptype\mptype_axis_sniper::main;
		game["cap_axis_model"]["body_model"][4] = "body_mp_arab_regular_sniper";
		game["cap_neutral_model"]["function"][9] = mptype\mptype_axis_sniper::main;
		game["cap_neutral_model"]["body_model"][9] = "body_mp_arab_regular_sniper";
	}
	else if ( game["axis_soldiertype"] == "urban" )
	{
		game["cap_axis_model"]["function"][0] = mptype\mptype_axis_urban_assault::main;
		game["cap_axis_model"]["body_model"][0] = "body_mp_opforce_assault";
		game["cap_neutral_model"]["function"][5] = mptype\mptype_axis_urban_assault::main;
		game["cap_neutral_model"]["body_model"][5] = "body_mp_opforce_assault";
		
		game["cap_axis_model"]["function"][1] = mptype\mptype_axis_urban_cqb::main;
		game["cap_axis_model"]["body_model"][1] = "body_mp_opforce_cqb";
		game["cap_neutral_model"]["function"][6] = mptype\mptype_axis_urban_cqb::main;
		game["cap_neutral_model"]["body_model"][6] = "body_mp_opforce_cqb";
		
		game["cap_axis_model"]["function"][2] = mptype\mptype_axis_urban_support::main;
		game["cap_axis_model"]["body_model"][2] = "body_mp_opforce_support";
		game["cap_neutral_model"]["function"][7] = mptype\mptype_axis_urban_support::main;
		game["cap_neutral_model"]["body_model"][7] = "body_mp_opforce_support";
		
		game["cap_axis_model"]["function"][3] = mptype\mptype_axis_urban_engineer::main;
		game["cap_axis_model"]["body_model"][3] = "body_mp_opforce_eningeer";
		game["cap_neutral_model"]["function"][8] = mptype\mptype_axis_urban_engineer::main;
		game["cap_neutral_model"]["body_model"][8] = "body_mp_opforce_eningeer";
		
		game["cap_axis_model"]["function"][4] = mptype\mptype_axis_urban_sniper::main;
		game["cap_axis_model"]["body_model"][4] = "body_mp_opforce_sniper_urban";
		game["cap_neutral_model"]["function"][9] = mptype\mptype_axis_urban_sniper::main;
		game["cap_neutral_model"]["body_model"][9] = "body_mp_opforce_sniper_urban";
	}
	else
	{
		game["cap_axis_model"]["function"][0] = mptype\mptype_axis_woodland_rifleman::main;
		game["cap_axis_model"]["body_model"][0] = "body_mp_opforce_assault";
		game["cap_neutral_model"]["function"][5] = mptype\mptype_axis_woodland_rifleman::main;
		game["cap_neutral_model"]["body_model"][5] = "body_mp_opforce_assault";
		
		game["cap_axis_model"]["function"][1] = mptype\mptype_axis_woodland_cqb::main;
		game["cap_axis_model"]["body_model"][1] = "body_mp_opforce_cqb";
		game["cap_neutral_model"]["function"][6] = mptype\mptype_axis_woodland_cqb::main;
		game["cap_neutral_model"]["body_model"][6] = "body_mp_opforce_cqb";
		
		game["cap_axis_model"]["function"][2] = mptype\mptype_axis_woodland_support::main;
		game["cap_axis_model"]["body_model"][2] = "body_mp_opforce_support";
		game["cap_neutral_model"]["function"][7] = mptype\mptype_axis_woodland_support::main;
		game["cap_neutral_model"]["body_model"][7] = "body_mp_opforce_support";
		
		game["cap_axis_model"]["function"][3] = mptype\mptype_axis_woodland_engineer::main;
		game["cap_axis_model"]["body_model"][3] = "body_mp_opforce_eningeer";
		game["cap_neutral_model"]["function"][8] = mptype\mptype_axis_woodland_engineer::main;
		game["cap_neutral_model"]["body_model"][8] = "body_mp_opforce_eningeer";
		
		game["cap_axis_model"]["function"][4] = mptype\mptype_axis_woodland_sniper::main;
		game["cap_axis_model"]["body_model"][4]= "body_mp_opforce_sniper";
		game["cap_neutral_model"]["function"][9] = mptype\mptype_axis_woodland_sniper::main;
		game["cap_neutral_model"]["body_model"][9] = "body_mp_opforce_sniper";
	}
}

onPlayerConnected()
{
	if ( level.scr_cap_firstspawn && !isDefined( self.pers["spawned_once"] ) )
		self.pers["spawned_once"] = false;
		
	self.isInCAP = false;
	
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onPlayerKilled", ::onPlayerKilled );
}

onPlayerSpawned()
{	
	if ( level.inReadyUpPeriod )
		return;
		
	if ( isDefined( level.inPrematchPeriod ) )
	{
		while ( level.inPrematchPeriod )
			wait .05;
	}	
	
	self.cap_protected = false;
	
	self checkAndChangeModel();
	if ( !isDefined( self.pers["isBot"] ) || ( isDefined( self.pers["isBot"] ) && self.pers["isBot"] == false ) )
	{
		if ( ( level.scr_cap_firstspawn && ( isDefined( self.pers["spawned_once"] ) && self.pers["spawned_once"] == false ) ) || !level.scr_cap_firstspawn )
		{
			if ( level.scr_cap_firstspawn && isDefined( self.pers["spawned_once"] ) )
				self.pers["spawned_once"] = true;
				
			if ( level.scr_player_forcerespawn == 0 )
				xWait(2);
			
			self setClientDvar( "cap_enable", "true" );	
			self thread customizePlayer();
		}
	}
}

onPlayerKilled()
{
	self.isInCAP = false;
	
	if ( level.scr_thirdperson_enable )
		self setClientDvars( "cg_thirdPerson", "1", "cg_thirdPersonAngle", "360", "cg_thirdPersonRange", "72", "cap_enable", "false" );
	else
		self setClientDvars( "cg_thirdPerson", "0", "cg_thirdPersonAngle", "0", "cg_thirdPersonRange", "120", "cap_enable", "false" );	
}

checkAndChangeModel()
{
	if ( isDefined( self.pers["current_body_model"] ) )
	{
		self.isHeadOff = false;
		//Detach Head Model (Original snip of script by BionicNipple)
		count = self getattachsize();
		for ( index = 0; index < count; index++ )
		{
			head = self getattachmodelname( index );
		
			if ( startsWith( head, "head" ) )
			{
				self detach( head );
				self.isHeadOff = true;
				break;
			}
		}
		
		if ( level.teamBased )
		{
			for ( index = 0; index < 5; index++ )
			{
				if ( game["cap_" + self.pers["team"] + "_model"]["body_model"][index] == self.pers["current_body_model"] )
				{
					self [[game["cap_" + self.pers["team"] + "_model"]["function"][index]]]();
					self.isHeadOff = false;
				}
			}
		}
		else
		{
			for ( index = 0; index < 10; index++ )
			{
				if ( game["cap_neutral_model"]["body_model"][index] == self.pers["current_body_model"] )
				{
					self [[game["cap_neutral_model"]["function"][index]]]();
					self.isHeadOff = false;
				}
			}
		}
		
		if ( self.isHeadOff ) //Something went wrong or dvar changed in game
		{
			//set player back to default
			self maps\mp\gametypes\_teams::playerModelForClass( self.pers["class"] );
		}
		
		if ( ( isDefined( level.scr_spawn_protection_invisible ) && level.scr_spawn_protection_invisible == 1 ) && isDefined( self.spawn_protected ) && self.spawn_protected )
			self hide();
	}
	return;
}

customizePlayer()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	//Begin countdown before cap access expires
	passedTime = openwarfare\_timer::getTimePassed();
	maxTime = level.scr_cap_time * 1000;
	timeDifference = 0;
	
	//Display Interface Message
	self setClientDvar( "cap_info", "open" );
	
	while ( !self useButtonPressed() && timeDifference < maxTime )
	{
		timeDifference = openwarfare\_timer::getTimePassed() - passedTime;
		wait .01;
	}
	
	if ( timeDifference >= maxTime )
	{
		self setClientDvar( "cap_enable", "false" );	
		return;	
	}
	
	self setClientDvar( "cap_info", "init", "cap_enable", "true" );
	wait 1;
	
	self.isInCAP = true;
	
	if ( ( isDefined( level.scr_spawn_protection_invisible ) && level.scr_spawn_protection_invisible == 1 ) && isDefined( self.spawn_protected ) && self.spawn_protected )
		self show();

	self setClientDvars( "cg_thirdPerson", "1", "cg_thirdPersonAngle", "180", "cg_thirdPersonRange", "120" );
	
	self thread openwarfare\_speedcontrol::setModifierSpeed( "_capeditor", 100 );
	self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
	self thread maps\mp\gametypes\_gameobjects::_disableJump();
	self thread maps\mp\gametypes\_gameobjects::_disableSprint();

	self setClientDvar( "cap_info", "cycle_close" );
	
	//How long player can be in CAP
	passedTime = openwarfare\_timer::getTimePassed();
	maxTime = level.scr_cap_activated * 1000;
	timeDifference = 0;
	
	while( !self meleeButtonPressed() && ( timeDifference < maxTime ) )
	{
		if ( !isDefined( self.cap_protected ) )
			self.cap_protected = true;	
			
		hudTimer = int( ( maxTime - timeDifference ) / 1000 );
		self setClientDvar( "cap_time", hudTimer );
			
		timeDifference = openwarfare\_timer::getTimePassed() - passedTime;
		if ( self useButtonPressed() )
		{			
			//Find current model of player
			modelIndex = self getCurrentModelIndex();
			
			//Detach Head Model (Original snip of script by BionicNipple)
			count = self getattachsize();
			for ( index = 0; index < count; index++ )
			{
				head = self getattachmodelname( index );
		
				if ( startsWith( head, "head" ) )
				{
					self detach( head );
					break;
				}
			}
		
			if ( level.teamBased && modelIndex + 1 == 5 )
				modelIndex = 0;
			else if ( !level.teamBased && modelIndex + 1 == 10 )
				modelIndex = 0;
			else 
				modelIndex++;
			
			//Change player model
			if ( level.teamBased )
				self [[game["cap_" + self.pers["team"] + "_model"]["function"][modelIndex]]]();
			else
				self [[game["cap_neutral_model"]["function"][modelIndex]]]();
			self.pers["current_body_model"] = self.model;
			
			wait .5;
		}
		wait .01;
	}
	self.cap_protected = false;
	
	if ( ( isDefined( level.scr_spawn_protection_invisible ) && level.scr_spawn_protection_invisible == 1 ) && isDefined( self.spawn_protected ) && self.spawn_protected )
		self hide();
	
	if ( level.scr_thirdperson_enable )
		self setClientDvars( "cg_thirdPerson", "1", "cg_thirdPersonAngle", "360", "cg_thirdPersonRange", "72", "cap_enable", "false" );
	else
		self setClientDvars( "cg_thirdPerson", "0", "cg_thirdPersonAngle", "0", "cg_thirdPersonRange", "120", "cap_enable", "false" );	
	
	self thread openwarfare\_speedcontrol::setModifierSpeed( "_capeditor", 0 );
	self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
	self thread maps\mp\gametypes\_gameobjects::_enableJump();
	self thread maps\mp\gametypes\_gameobjects::_enableSprint();
		
	wait 1;
	
	self.isInCAP = false;	
}

getCurrentModelIndex()
{
	if ( level.teamBased )
	{
		for ( index = 0; index < 5; index++ )
		{
			if ( game["cap_" + self.pers["team"] + "_model"]["body_model"][index] == self.model )
				return index;
		}
	}
	else
	{
		for ( index = 0; index < 10; index++ )
		{
			if ( game["cap_neutral_model"]["body_model"][index] == self.model )
				return index;
		}
	}
	
	return 0;
}

//Original Code by BionicNipple
startsWith( string, pattern )
{
    if ( string == pattern ) 
		return true;
    if ( pattern.size > string.size ) 
		return false;

    for ( index = 0; index < pattern.size; index++ )
	{
        if ( string[index] != pattern[index] ) 
			return false;
	}		

    return true;
}

