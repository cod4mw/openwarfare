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

#include maps\mp\gametypes\_hud_util;

#include openwarfare\_eventmanager;
#include openwarfare\_utils;

init()
{
	// Get the main module's dvar
	level.scr_weaponjams_enable = getdvarx( "scr_weaponjams_enable", "int", 0, 0, 1 );

	// If weapon jam is not enabled we'll stay in this module anyway as it's the one handling
	// the weapon sounds when they are empty

	if ( level.scr_weaponjams_enable == 1 ) {
		// Precache some shaders we'll be using and load an array with a shader for each weapon
		precacheShader( "jammed" );
		thread loadWS();
		
		// Get the rest of the module's dvars
		level.scr_weaponjams_probability = getdvarx( "scr_weaponjams_probability", "int", 250, 10, 1000 );	
		level.scr_weaponjams_gap_time = getdvarx( "scr_weaponjams_gap_time", "float", 0, 0, 300 ) * 1000;	
	}

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
		
	// There's no need to start the following thread if we are only playing the empty sounds
	if ( level.scr_weaponjams_enable == 1 ) {
		self thread addNewEvent( "onPlayerKilled", ::onPlayerKilled );
	}
}


onPlayerSpawned()
{
	self thread emptyWeaponSounds();
	
	// Check if we need to start the weapon jammer thread
	if ( level.scr_weaponjams_enable == 1 ) {
		// Initialize some internal variables
		self.jammedWeapon = [];
		self.jammedWeapon["unjamming"] = false;
		self.lastJam = level.scr_weaponjams_gap_time * -1;

		// Create the HUD elements will be using to indicate the weapon is jammed
		if ( !isDefined( self.jammedWeapon["shader"] ) ) {
			self.jammedWeapon["shader"] = createIcon( "white", 64, 32 );
			self.jammedWeapon["shader"].alpha = 0;
			self.jammedWeapon["shader"].sort = -1;
			self.jammedWeapon["shader"] setPoint( "CENTER", "BOTTOM", 0, -32 );
			self.jammedWeapon["shader"].archived = true;
			self.jammedWeapon["shader"].hideWhenInMenu = true;
			
			self.jammedWeapon["jammed"] = createIcon( "jammed", 12, 12 );
			self.jammedWeapon["jammed"].alpha = 0;
			self.jammedWeapon["jammed"] setPoint( "CENTER", "BOTTOM", 5, -37 );
			self.jammedWeapon["jammed"].archived = true;
			self.jammedWeapon["jammed"].hideWhenInMenu = true;			
		}
		
		self thread weaponJammer();
		self thread showWeaponJammed();
	}
}


onPlayerKilled()
{
	if ( isDefined( self.jammedWeapon ) && isDefined( self.jammedWeapon["shader"] ) ) {
		self.jammedWeapon["shader"] destroy();
		self.jammedWeapon["jammed"] destroy();
	}
}


emptyWeaponSounds()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );
	
	for (;;)
	{
		wait (0.05);
		
		// Get the current weapon
		currentWeapon = self getCurrentWeapon();
		
		// Check if the player is pressing the attack key and the current weapon is empty
		if ( self attackButtonPressed() && self getAmmoCount( currentWeapon ) == 0 ) {
			// Make sure the gun is not empty because it's actually jammed
			if ( level.scr_weaponjams_enable == 0 || !isDefined( self.jammedWeapon[currentWeapon] ) || !isDefined( self.jammedWeapon[currentWeapon]["jammed"] ) || !self.jammedWeapon[currentWeapon]["jammed"] ) {
				
				// Determine which sound we need to play based on the current weapon
				switch ( weaponClass( currentWeapon ) )
				{
					case "pistol":
						emptyFireSound = "weap_dryfire_pistol_npc";
						break;
					case "mg":
					case "smg":
						emptyFireSound = "weap_dryfire_smg_npc";
						break;
					case "spread":
					case "rifle":
						emptyFireSound = "weap_dryfire_rifle_npc";
						break;
					default:
						emptyFireSound = "";
						break;
				}
				// Check if we need to play a sound
				if ( emptyFireSound != "" ) {
					// Play the sound
					self playLocalSound( emptyFireSound );
					
					// Wait for the player to release the attack button
					while( self attackButtonPressed() )
						wait (0.05);
				}
			}
		}				
	}	
}


weaponJammer()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );
	
	for (;;)
	{
		wait (0.05);

		if ( openwarfare\_timer::getTimePassed() - self.lastJam > level.scr_weaponjams_gap_time ) {
			// Get the current weapon
			currentWeapon = self getCurrentWeapon();			
			
			// Check if this weapon can jam and that it's not already jammed
			if ( isDefined( level.ws[ currentWeapon ] ) && ( !isDefined( self.jammedWeapon[currentWeapon] ) || !self.jammedWeapon[currentWeapon]["jammed"] ) ) {
				// Make sure this weapon has more than one round of ammo left
				currentAmmo = self getAmmoCount( currentWeapon );
				if ( currentAmmo > 1 ) {
					// Check if we should jam the weapon or not
					if ( self attackButtonPressed() && randomInt( level.scr_weaponjams_probability ) == 1 && !self isPlayerNearTurret() ) {
						// We need to jam the weapon!! I hope the poor guy is not in a big firefight... 
						if ( !isDefined( self.jammedWeapon[currentWeapon] ) ) {
							self.jammedWeapon[currentWeapon] = [];
						}
						self.jammedWeapon[currentWeapon]["jammed"] = true;
						self.jammedWeapon[currentWeapon]["ammo"] = self getAmmoCount( currentWeapon ) - 1;
						
						// Remove the ammo from the weapon
						self setWeaponAmmoStock( currentWeapon, 0 );
						self setWeaponAmmoClip( currentWeapon, 0 );	
						wait (0.5);
						self playLocalSound( game["voice"][self.pers["team"]] + "rsp_comeon" );
						self.lastJam = openwarfare\_timer::getTimePassed();
					}				
				}
			}
		}
	}	
}


showWeaponJammed()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	blinkState = 0;
	
	for (;;)
	{
		wait (0.05);

		// Get the current weapon
		currentWeapon = self getCurrentWeapon();

		// Check if the current weapon is jammed and display the shaders
		if ( isDefined( self.jammedWeapon[currentWeapon] ) && isDefined( self.jammedWeapon[currentWeapon]["jammed"] ) && self.jammedWeapon[currentWeapon]["jammed"] ) {
			// Remove any ammo that the player might pick up while the gun is jammed
			currentAmmo = self getAmmoCount( currentWeapon );
			if ( currentAmmo > 0 && !self.jammedWeapon["unjamming"] ) {
				self.jammedWeapon[currentWeapon]["ammo"] += currentAmmo;
				self setWeaponAmmoStock( currentWeapon, 0 );
				self setWeaponAmmoClip( currentWeapon, 0 );					
			}
			self.jammedWeapon["shader"] setShader( level.ws[currentWeapon], 64, 32);
			blinkState = !blinkState;
			self.jammedWeapon["shader"].alpha = blinkState;
			self.jammedWeapon["jammed"].alpha = blinkState;
			wait (0.5);
		} else {
			blinkState = 0;
			self.jammedWeapon["shader"].alpha = 0;
			self.jammedWeapon["jammed"].alpha = 0;				
		}
	}		
}


unjamWeapon()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	// Get the current weapon
	currentWeapon = self getCurrentWeapon();
	
	// Check if weapon jam is enabled, the player is not already unjamming the weapon and that the current weapon is really jammed
	if ( level.scr_weaponjams_enable == 0 || self.jammedWeapon["unjamming"] || !isDefined( self.jammedWeapon[currentWeapon] ) || !isDefined( self.jammedWeapon[currentWeapon]["jammed"] ) || !self.jammedWeapon[currentWeapon]["jammed"] ) 
		return;

	// Unjam the weapon
	self.jammedWeapon["unjamming"] = true;
	self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
	self setWeaponAmmoStock( currentWeapon, self.jammedWeapon[currentWeapon]["ammo"] );
	self playLocalSound( "scramble" );

	xWait(1.5);

	self.jammedWeapon[currentWeapon]["ammo"] = 0;
	self.jammedWeapon[currentWeapon]["jammed"] = false;
	self.jammedWeapon["unjamming"] = false;
	self thread maps\mp\gametypes\_gameobjects::_enableWeapon();	
}


loadWS()
{
	// Load all the weapon shaders
	level.ws = [];

	// Assault class weapons
	/*level.ws[ "m16_acog_mp" ] = "weapon_m16a4";
	level.ws[ "m16_gl_mp" ] = "weapon_m16a4";
	level.ws[ "m16_mp" ] = "weapon_m16a4";
	level.ws[ "m16_reflex_mp" ] = "weapon_m16a4";
	level.ws[ "m16_silencer_mp" ] = "weapon_m16a4";
	level.ws[ "gl_m16_mp" ] = "weapon_m16a4";
	precacheShader( "weapon_m16a4" );*/

	level.ws[ "ak47_acog_mp" ] = "weapon_ak47";
	level.ws[ "ak47_gl_mp" ] = "weapon_ak47";
	level.ws[ "ak47_mp" ] = "weapon_ak47";
	level.ws[ "ak47_reflex_mp" ] = "weapon_ak47";
	level.ws[ "ak47_silencer_mp" ] = "weapon_ak47";
	level.ws[ "gl_ak47_mp" ] = "weapon_ak47";
	precacheShader( "weapon_ak47" );

	level.ws[ "m4_acog_mp" ] = "weapon_m4carbine";
	level.ws[ "m4_gl_mp" ] = "weapon_m4carbine";
	level.ws[ "m4_mp" ] = "weapon_m4carbine";
	level.ws[ "m4_reflex_mp" ] = "weapon_m4carbine";
	level.ws[ "m4_silencer_mp" ] = "weapon_m4carbine";
	level.ws[ "gl_m4_mp" ] = "weapon_m4carbine";
	precacheShader( "weapon_m4carbine" );

	level.ws[ "g3_acog_mp" ] = "weapon_g3";
	level.ws[ "g3_gl_mp" ] = "weapon_g3";
	level.ws[ "g3_mp" ] = "weapon_g3";
	level.ws[ "g3_reflex_mp" ] = "weapon_g3";
	level.ws[ "g3_silencer_mp" ] = "weapon_g3";
	level.ws[ "gl_g3_mp" ] = "weapon_g3";
	precacheShader( "weapon_g3" );

	level.ws[ "g36c_acog_mp" ] = "weapon_g36c";
	level.ws[ "g36c_gl_mp" ] = "weapon_g36c";
	level.ws[ "g36c_mp" ] = "weapon_g36c";
	level.ws[ "g36c_reflex_mp" ] = "weapon_g36c";
	level.ws[ "g36c_silencer_mp" ] = "weapon_g36c";
	level.ws[ "gl_g36c_mp" ] = "weapon_g36c";
	precacheShader( "weapon_g36c" );

	level.ws[ "m14_acog_mp" ] = "weapon_m14";
	level.ws[ "m14_gl_mp" ] = "weapon_m14";
	level.ws[ "m14_mp" ] = "weapon_m14";
	level.ws[ "m14_reflex_mp" ] = "weapon_m14";
	level.ws[ "m14_silencer_mp" ] = "weapon_m14";
	level.ws[ "gl_m14_mp" ] = "weapon_m14";
	precacheShader( "weapon_m14" );

	level.ws[ "mp44_mp" ] = "weapon_mp44";
	precacheShader( "weapon_mp44" );

	// Special Ops class weapons
	level.ws[ "mp5_acog_mp" ] = "weapon_mp5";
	level.ws[ "mp5_mp" ] = "weapon_mp5";
	level.ws[ "mp5_reflex_mp" ] = "weapon_mp5";
	level.ws[ "mp5_silencer_mp" ] = "weapon_mp5";
	precacheShader( "weapon_mp5" );

	level.ws[ "skorpion_acog_mp" ] = "weapon_skorpion";
	level.ws[ "skorpion_mp" ] = "weapon_skorpion";
	level.ws[ "skorpion_reflex_mp" ] = "weapon_skorpion";
	level.ws[ "skorpion_silencer_mp" ] = "weapon_skorpion";
	precacheShader( "weapon_skorpion" );

	level.ws[ "uzi_acog_mp" ] = "weapon_mini_uzi";
	level.ws[ "uzi_mp" ] = "weapon_mini_uzi";
	level.ws[ "uzi_reflex_mp" ] = "weapon_mini_uzi";
	level.ws[ "uzi_silencer_mp" ] = "weapon_mini_uzi";
	precacheShader( "weapon_mini_uzi" );

	level.ws[ "ak74u_acog_mp" ] = "weapon_aks74u";
	level.ws[ "ak74u_mp" ] = "weapon_aks74u";
	level.ws[ "ak74u_reflex_mp" ] = "weapon_aks74u";
	level.ws[ "ak74u_silencer_mp" ] = "weapon_aks74u";
	precacheShader( "weapon_aks74u" );

	level.ws[ "p90_acog_mp" ] = "weapon_p90";
	level.ws[ "p90_mp" ] = "weapon_p90";
	level.ws[ "p90_reflex_mp" ] = "weapon_p90";
	level.ws[ "p90_silencer_mp" ] = "weapon_p90";
	precacheShader( "weapon_p90" );


	// Demolition class weapons 
	level.ws[ "m1014_grip_mp" ] = "weapon_benelli_m4";
	level.ws[ "m1014_mp" ] = "weapon_benelli_m4";
	level.ws[ "m1014_reflex_mp" ] = "weapon_benelli_m4";
	precacheShader( "weapon_benelli_m4" );

	level.ws[ "winchester1200_grip_mp" ] = "weapon_winchester1200";
	level.ws[ "winchester1200_mp" ] = "weapon_winchester1200";
	level.ws[ "winchester1200_reflex_mp" ] = "weapon_winchester1200";
	precacheShader( "weapon_winchester1200" );
	

	// Heavy gunner class weapons
	level.ws[ "saw_acog_mp" ] = "weapon_m249saw";
	level.ws[ "saw_grip_mp" ] = "weapon_m249saw";
	level.ws[ "saw_mp" ] = "weapon_m249saw";
	level.ws[ "saw_reflex_mp" ] = "weapon_m249saw";
	precacheShader( "weapon_m249saw" );

	level.ws[ "rpd_acog_mp" ] = "weapon_rpd";
	level.ws[ "rpd_grip_mp" ] = "weapon_rpd";
	level.ws[ "rpd_mp" ] = "weapon_rpd";
	level.ws[ "rpd_reflex_mp" ] = "weapon_rpd";
	precacheShader( "weapon_rpd" );

	level.ws[ "m60e4_acog_mp" ] = "weapon_m60e4";
	level.ws[ "m60e4_grip_mp" ] = "weapon_m60e4";
	level.ws[ "m60e4_mp" ] = "weapon_m60e4";
	level.ws[ "m60e4_reflex_mp" ] = "weapon_m60e4";
	precacheShader( "weapon_m60e4" );


	// Sniper class weapons
	level.ws[ "dragunov_acog_mp" ] = "weapon_dragunovsvd";
	level.ws[ "dragunov_mp" ] = "weapon_dragunovsvd";
	precacheShader( "weapon_dragunovsvd" );

	level.ws[ "m40a3_acog_mp" ] = "weapon_m40a3";
	level.ws[ "m40a3_mp" ] = "weapon_m40a3";
	precacheShader( "weapon_m40a3" );

	level.ws[ "barrett_acog_mp" ] = "weapon_barrett50cal";
	level.ws[ "barrett_mp" ] = "weapon_barrett50cal";
	precacheShader( "weapon_barrett50cal" );

	level.ws[ "remington700_acog_mp" ] = "weapon_remington700";
	level.ws[ "remington700_mp" ] = "weapon_remington700";
	precacheShader( "weapon_remington700" );

	level.ws[ "m21_acog_mp" ] = "weapon_m14_scoped";
	level.ws[ "m21_mp" ] = "weapon_m14_scoped";
	precacheShader( "weapon_m14_scoped" );

	return;
}