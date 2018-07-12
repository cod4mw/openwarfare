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
	level.scr_dynamic_attachments_enable = getdvarx( "scr_dynamic_attachments_enable", "int", 0, 0, 2 );

	// If dynamic attachments is disabled there's nothing else to do here
	if ( level.scr_dynamic_attachments_enable == 0 )
		return;
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );	
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}	


onPlayerSpawned()
{
	self.attachmentPocket = "";
	self.attachmentAction = false;
}


attachDetachAttachment()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	// Make sure this module is active
	if ( level.scr_dynamic_attachments_enable == 0 || !isAlive(self) )
		return;
	
	// Make sure the current weapon supports an attach/detach action
	currentWeapon = self getCurrentWeapon();
	detachmentAction = validForDetachmentAction( currentWeapon );
	attachmentAction = validForAttachmentAction( currentWeapon, self.attachmentPocket );
	if ( detachmentAction != "" || attachmentAction ) {
		// If we already have something in the pocket we will not allow a second detachment
		if ( detachmentAction != "" && self.attachmentPocket != "" )
			return;
		
		// Initiate attaching/detaching action. If there's already another action running we'll cancel the request
		if ( self.attachmentAction ) {
			return;
		} else {
			self.attachmentAction = true;
		}
		
		// Get the ammo info for the current weapon
		totalAmmo = self getAmmoCount( currentWeapon );
		clipAmmo = self getWeaponAmmoClip( currentWeapon );
		
		// Disable the player's weapons
		self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
				
		// Wait for certain time to complete the requested action
		self playLocalSound( "scramble" );
		xWait (3);
		
		// Take the current weapon from the player
		self takeWeapon( currentWeapon );
		
		// Check which weapon we should give in exchange
		if ( detachmentAction != "" ) {
			// Construct the name of the weapon without the attachment
			newWeapon = getSubStr( currentWeapon, 0, currentWeapon.size - detachmentAction.size - 2 ) + "_mp";
			self.attachmentPocket = detachmentAction;
			
		} else {
			// Construct the name of the weapon with the attachment
			newWeapon = getSubStr( currentWeapon, 0, currentWeapon.size - 3 ) + self.attachmentPocket + "mp";
			self.attachmentPocket = "";				
		}
		
		if ( isDefined( self.camo_num ) ) {
			self giveWeapon( newWeapon, self.camo_num );
		} else {
			self giveWeapon( newWeapon );
		}
			
		// Assign the proper ammo again
		self setWeaponAmmoClip( newWeapon, clipAmmo );
		self setWeaponAmmoStock( newWeapon, totalAmmo - clipAmmo );
		
		self switchToWeapon( newWeapon );
		self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
		self.attachmentAction = false;		
	}	
}


validForDetachmentAction( currentWeapon )
{
	// Check if the weapon is a special firing mode weapon
	if ( isSubStr( currentWeapon, "_single_" ) || isSubStr( currentWeapon, "_burst_" ) || isSubStr( currentWeapon, "_full_" ) )
		return "";

	// Check if the current weapon is valid for detachment
	if ( isSubStr( currentWeapon, "_silencer_" ) ) {
		return "_silencer_";
	} else if ( level.scr_dynamic_attachments_enable == 2 && isSubStr( currentWeapon, "_acog_" ) ) {
		return "_acog_";
	} else {
		return "";
	}
}


validForAttachmentAction( currentWeapon, playerPocket )
{
	// Check if the weapon is a special firing mode weapon
	if ( isSubStr( currentWeapon, "_single_" ) || isSubStr( currentWeapon, "_burst_" ) || isSubStr( currentWeapon, "_full_" ) )
		return false;

	// Check if the current weapon is valid for the attachment that the player has in his pocket
	if ( playerPocket != "" ) {
		if ( playerPocket == "_silencer_" ) {
			if ( isSubStr( "ak47_mp;ak74u_mp;beretta_mp;colt45_mp;g36c_mp;g3_mp;m14_mp;m16_mp;m4_mp;mp5_mp;p90_mp;skorpion_mp;usp_mp;uzi_mp", currentWeapon ) ) {
				return true;
			}
		}	else if ( level.scr_dynamic_attachments_enable == 2 && playerPocket == "_acog_" ) {
			if ( isSubStr( "ak47_mp;ak74u_mp;barrett_mp;dragunov_mp;g36c_mp;g3_mp;m14_mp;m16_mp;m21_mp;m40a3_mp;m4_mp;m60e4_mp;mp5_mp;p90_mp;remington700_mp;rpd_mp;saw_mp;skorpion_mp;uzi_mp", currentWeapon ) ) {
				return true;
			}
		}	
	}
	
	return false;	
}