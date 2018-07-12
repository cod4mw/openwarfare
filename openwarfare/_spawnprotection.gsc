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

#include openwarfare\_eventmanager;
#include openwarfare\_utils;

init()
{
	// Get the main module's dvar
	level.scr_enable_spawn_protection = getdvarx( "scr_enable_spawn_protection", "int", 0, 0, 1 );
	level.scr_spawn_protection_hiticon = getdvarx( "scr_spawn_protection_hiticon", "int", 1, 0, 1 );

	// If spawn protection is not enabled then there's nothing else to do here
	if ( level.scr_enable_spawn_protection == 0 )
		return;

	// Get the module's dvars
	level.scr_spawn_protection_time = getdvarx( "scr_spawn_protection_time", "float", 4, 0.5, 60 );
	level.scr_spawn_protection_invisible = getdvarx( "scr_spawn_protection_invisible", "int", 0, 0, 1 );
	level.scr_spawn_protection_maxdistance = getdvarx( "scr_spawn_protection_maxdistance", "int", 0, 0, 5000 );
	level.scr_spawn_protection_punishment_time = getdvarx( "scr_spawn_protection_punishment_time", "float", 0, 0, 15 );

	// Precache the shield icon that will be use to indicate player protection
	precacheShader( "shield" );
	precacheShellShock( "frag_grenade_mp" );

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onPlayerKilled", ::onPlayerKilled );
}

onPlayerSpawned()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );
	
	// When the player spawns by default is not protected
	self.spawn_protected = false;

	if ( level.gametype == "ftag" && self.freezeTag["frozen"] )
		return;

	// Do not protect a player if the spawn happens during readyup, prematch, strategy period or a timeout
	while ( level.inReadyUpPeriod || level.inStrategyPeriod || level.inPrematchPeriod || level.inTimeoutPeriod )
		wait (0.05);

	// Create the hud element for the new connected player
	self.hud_shield_icon = newClientHudElem( self );
	self.hud_shield_icon.x = 0;
	self.hud_shield_icon.y = 142;
	self.hud_shield_icon.alignX = "center";
	self.hud_shield_icon.alignY = "middle";
	self.hud_shield_icon.horzAlign = "center_safearea";
	self.hud_shield_icon.vertAlign = "center_safearea";
	self.hud_shield_icon.alpha = 0.9;
	self.hud_shield_icon.archived = true;
	self.hud_shield_icon.hideWhenInMenu = true;
	self.hud_shield_icon setShader( "shield", 32, 32);

	self thread spawnProtectPlayer();
}

onPlayerKilled()
{
	// Destroy the hud element when the player dies
	// This has to be done because a protected player can still die from falling
	if ( isDefined( self.hud_shield_icon ) )
		self.hud_shield_icon destroy();
}


// Damage taken by the player during spawn protection is handled in maps\mp\gametypes\_globallogic.gsc::Callback_PlayerDamage()
spawnProtectPlayer()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	// Protection started
	self.spawn_protected = true;
	self.spawn_protection_time = gettime() + level.scr_spawn_protection_time * 1000;
	spawnOrigin = self getOrigin();

	// Check if we should make the player invisible
	if ( level.scr_spawn_protection_invisible == 1 ) {
		self hide();
		self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
	}

	// Wait until the time has passed or the player fires the gun, throws a frag grenade, throws a special grenade (smoke, stun, flash) or uses the knife
	while ( isDefined( self ) && self.spawn_protection_time > gettime() && self.spawn_protected && ( level.scr_spawn_protection_maxdistance == 0 || distance( spawnOrigin, self getOrigin() ) < level.scr_spawn_protection_maxdistance ) ) {
		if ( self attackButtonPressed() || self fragButtonPressed() || ( self meleeButtonPressed() && ( !isDefined( self.isInCAP ) || !self.isInCAP ) ) || self secondaryOffhandButtonPressed() ) {
			// The player trigger an action that disables the spawn protection
			self.spawn_protected = false;
		} else {
			wait ( 0.05 );
		}
	}

	if ( isDefined( self ) ) {
		// Check if we show make the player visible
		if ( level.scr_spawn_protection_invisible == 1 ) {
			self show();
			self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
		}
	
		// Deactivate spawn protection and destroy the hud element
		self.spawn_protected = false;
		if ( isDefined( self.hud_shield_icon ) )
			self.hud_shield_icon destroy();
	}
}


punishSpawnCamper()
{
	self endon("disconnect");
	self endon("death");
	
	// Shock and disable the player's weapon
	self shellshock( "frag_grenade_mp", level.scr_spawn_protection_punishment_time );
	self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
	
	// Re-enable the player's weapon after the punishment time
	wait( level.scr_spawn_protection_punishment_time );
	self thread maps\mp\gametypes\_gameobjects::_enableWeapon();	
}