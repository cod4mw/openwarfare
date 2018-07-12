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
	level.scr_switch_firing_mode_enable = getdvarx( "scr_switch_firing_mode_enable", "int", 0, 0, 1 );

	// If switching fire modes is disabled there's nothing else to do here
	if ( level.scr_switch_firing_mode_enable == 0 )
		return;

	// Precache shaders and new weapons' fire modes
	precacheShader( "icon_singleshot" );
	precacheShader( "icon_3roundburst" );
	precacheShader( "icon_fullauto" );
	addWeaponFireModes( "m16", "none", "single" );
	addWeaponFireModes( "ak47", "none", "single" );
	addWeaponFireModes( "m4", "none", "single" );

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


addWeaponFireModes( weaponName, weaponAttachments, fireTypes )
{
	// Check if this weapon is allowed to switch fire modes
	if ( getdvarx( "scr_switch_firing_mode_allow_" + weaponName, "int", 1, 0, 1 ) == 0 )
		return;
	
	// Initialize the array if this is the first time that the function is called
	if ( !isDefined( level.weaponNextFireMode ) ) {
		level.weaponNextFireMode = [];
	}
		
	weaponAttachments = strtok( weaponAttachments, ";" );
	fireTypes = strtok( fireTypes, ";" );
	
	for ( ft = 0; ft < fireTypes.size; ft++ ) {
		// Precache the new weapon with its attachments in the new supported fire mode
		for ( wa = 0; wa < weaponAttachments.size; wa++ ) {
			resetTimeout();
	
			// If attachment is "none" replace it with an empty value
			if ( weaponAttachments[wa] == "none" ) {
				thisWeaponAttachment = "";
			} else {
				thisWeaponAttachment = "_" + weaponAttachments[wa];
			}
			
			// Add new weapon to the array for fast switching between the modes
			if ( ft == fireTypes.size - 1 ) {
				level.weaponNextFireMode[ weaponName + thisWeaponAttachment + "_" + fireTypes[ft] + "_mp" ] = weaponName + thisWeaponAttachment + "_mp";
				level.weaponNextFireMode[ weaponName + thisWeaponAttachment + "_mp" ] = weaponName + thisWeaponAttachment + "_" + fireTypes[0] + "_mp";
			} else {
				level.weaponNextFireMode[ weaponName + thisWeaponAttachment + "_" + fireTypes[ft] + "_mp" ] = weaponName + thisWeaponAttachment + "_" + fireTypes[ft + 1] + "_mp";
			}			
			
			// Add the new weapon to the primary weapons array and precache it
			level.primary_weapon_array[ weaponName + thisWeaponAttachment + "_" + fireTypes[ft] + "_mp" ] = level.primary_weapon_array[ weaponName + "_mp" ];
			precacheItem( weaponName + thisWeaponAttachment + "_" + fireTypes[ft] + "_mp" );
		}
	}
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}	


onPlayerSpawned()
{
	self thread watchWeaponChange();
}


watchWeaponChange()
{
	self endon("death");
	self endon("disconnect");

	// Display the fire mode icon if this weapon is supported
	currentWeapon = self getCurrentWeapon();
	if ( isDefined( level.weaponNextFireMode[ currentWeapon ] ) ) {
		fireModeShader = getFireModeShader( currentWeapon );
		self thread showFireModeShader( fireModeShader );		
	}

	for (;;) {
		self waittill( "weapon_change", newWeapon );
		if ( isDefined( level.weaponNextFireMode[ newWeapon ] ) ) {
			fireModeShader = getFireModeShader( newWeapon );
			self thread showFireModeShader( fireModeShader );		
		}
	}
}


switchFiringMode()
{
	// If switching fire mode is disabled or the player is not alive get out of there
	if ( level.scr_switch_firing_mode_enable == 0 || !isAlive( self ) || self playerADS() > 0 || ( isDefined( self.changingFireMode ) && self.changingFireMode ) )
		return;
	
	// Check if this weapon supports fire mode switching
	currentWeapon = self getCurrentWeapon();
	if ( !isDefined( level.weaponNextFireMode[ currentWeapon ] ) )
		return;

	// Get the ammo info for the current weapon
	totalAmmo = self getAmmoCount( currentWeapon );
	clipAmmo = self getWeaponAmmoClip( currentWeapon );
	newWeapon = level.weaponNextFireMode[ currentWeapon ];

	// Remove the current weapon
	self.changingFireMode = true;
	self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
	self takeWeapon( currentWeapon );
	
	// Give the new weapon
	if ( isDefined( self.camo_num ) ) {
		self giveWeapon( newWeapon, self.camo_num );
	} else {
		self giveWeapon( newWeapon );
	}

	// Assign the proper ammo again and make the weapon the active one
	self setWeaponAmmoClip( newWeapon, clipAmmo );
	self setWeaponAmmoStock( newWeapon, totalAmmo - clipAmmo );
	self switchToWeapon( newWeapon );	
	self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
		
	self.changingFireMode = false;
}


getFireModeShader( weaponName ) {
	// Some weapons need some special treatment (shotguns and sniper rifles are not taken into consideration)
	if ( isSubStr( weaponName, "_full_" ) ) {
		return "icon_fullauto";
	} else 	if ( isSubStr( weaponName, "_burst_" ) ) {
		return "icon_3roundburst";
	} else if ( isSubStr( weaponName, "_single_" ) || isSubStr( weaponName, "g3_" ) || isSubStr( weaponName, "m14_" ) ) {
		return "icon_singleshot";
	} else if ( isSubStr( weaponName, "m16_" ) ) {
		return "icon_3roundburst";
	} else {
		return "icon_fullauto";
	}	
}


showFireModeShader( shaderImage )
{
	// Auto destroy any other previous instance of this function
	self notify( "showFireModeShader" );
	wait (0.05);
	
	self endon( "disconnect" );
	self endon( "showFireModeShader" );
	
	// Display the new fire mode to the player
	if ( isDefined( self.hud_fire_mode ) ) {
		self.hud_fire_mode destroy();
	}		
	self.hud_fire_mode = newClientHudElem( self );
	self.hud_fire_mode.x = 0;
	if ( level.scr_enable_spawn_protection != 0 && self.spawn_protected ) {
		self.hud_fire_mode.y = 110;
	} else {
		self.hud_fire_mode.y = 142;
	}
	self.hud_fire_mode.alignX = "center";
	self.hud_fire_mode.alignY = "middle";
	self.hud_fire_mode.horzAlign = "center_safearea";
	self.hud_fire_mode.vertAlign = "center_safearea";
	self.hud_fire_mode.alpha = 1;
	self.hud_fire_mode.archived = true;
	self.hud_fire_mode.hideWhenInMenu = true;
	self.hud_fire_mode setShader( shaderImage, 32, 32);
	
	// Fade the icon (we need to check for the validity of the icon just in case the player
	// switched fire modes very quickly)
	wait (0.25);
		
	if ( isDefined( self.hud_fire_mode ) ) {
		self.hud_fire_mode fadeOverTime(1);
		self.hud_fire_mode.alpha = 0;
		wait (1.0);
		if ( isDefined( self.hud_fire_mode ) ) {
			self.hud_fire_mode destroy();
		}
	}
}