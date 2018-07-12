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
	level.scr_fcs_enabled = getdvarx( "scr_fcs_enabled", "int", 0, 0, 1 );
	
	level.scr_player_sprinttime = getdvarx( "scr_player_sprinttime", "float", 4, 0, 12.8 );
	setDvar( "player_sprintTime", level.scr_player_sprinttime );
	
	// We'll monitor this event in any case to make sure we set the players' player_sprintTime variable
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
	
	// If the fcs is not enabled then there's nothing to do here
	if ( level.scr_fcs_enabled == 0 )
		return;

	// Get the rest of the module's dvars
	level.scr_fcs_crouch_on_spawn = getdvarx( "scr_fcs_crouch_on_spawn", "int", 1, 0, 1 );
	level.scr_fcs_jump_allowed = getdvarx( "scr_fcs_jump_allowed", "int", 1, 0, 1 );
		
	level.scr_fcs_sprint_delay = getdvarx( "scr_fcs_sprint_delay", "float", 0, 0, 60 );	

	level.scr_fcs_walk_without_ads_allowed = getdvarx( "scr_fcs_walk_without_ads_allowed", "int", 1, 0, 1 );
	
	level.scr_fcs_jump_penalty = level.scr_player_sprinttime * getdvarx( "scr_fcs_jump_penalty", "int", 40, 0, 100 ) * 10;
	
	level.scr_fcs_sprint_slowsdown_max = getdvarx( "scr_fcs_sprint_slowsdown_max", "int", 30, 0, 50 );	
	
	level.scr_fcs_sprint_recovery_delay = getdvarx( "scr_fcs_sprint_recovery_delay", "float", 5, 1, 30 );	
	level.scr_fcs_sprint_recovery_time = getdvarx( "scr_fcs_sprint_recovery_time", "float", 2, 1, 10 );	

	level.scr_fcs_pulse_enabled = getdvarx( "scr_fcs_pulse_enabled", "int", 0, 0, 3 );
	level.scr_fcs_pulse_modifier = getdvarx( "scr_fcs_pulse_modifier", "float", 1, 0.01, 1.0 );
	// Precalculate sway values if pulse is enabled
	if ( level.scr_fcs_pulse_enabled != 0 ) {		
		level.swaySin = [];
		level.swayCos = [];
		for ( i=0; i < 361; i += 3 ) {
			level.swaySin[ level.swaySin.size ] = sin(i) / 3;
			level.swayCos[ level.swayCos.size ] = cos(i) / 3;
		}		
	}	
}


onPlayerConnected()
{
	// Only monitor this event if the fcs is enabled
	if ( level.scr_fcs_enabled != 0 ) {
		self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	}
	
	self setClientDvars( 
		"player_sprintTime", level.scr_player_sprinttime,
		"ui_stance_color", 0
	);
}


onPlayerSpawned()
{
	// Check if player is allowed to jump
	if ( level.scr_fcs_jump_allowed == 0 ) {
		self thread maps\mp\gametypes\_gameobjects::_disableJump();
	}
	
	// Check if player is allowed to sprint
	if ( level.scr_player_sprinttime == 0 ) {
		self thread maps\mp\gametypes\_gameobjects::_disableSprint();
	} else {
		// Check if we need to delay sprinting
		if ( level.scr_fcs_sprint_delay != 0 ) {
			self thread delaySprinting();
		}
	}
	
	// Initialize some player dependent values
	if ( self hasPerk( "specialty_longersprint" ) ) {
		maxSprintTime = level.scr_player_sprinttime * 2 * 1000;
	} else {
		maxSprintTime = level.scr_player_sprinttime * 1000;
	}
	self.fcs["time"] = maxSprintTime;
	self.fcs["sprinting"] = false;
	self.fcs["walking"] = false;
	self.fcs["jumping"] = false;
	self.fcs["disabled"] = false;
	self.fcs["canrecover"] = true;
	
	// Start the monitoring sprint threads
	if ( level.scr_player_sprinttime != 0 ) {
		self thread monitorSprintStart();
		self thread monitorSprintEnd();
	}
	if ( level.scr_fcs_walk_without_ads_allowed == 0 ) {
		self thread monitorWalkWithoutADS();
	}
	if ( level.scr_fcs_jump_penalty != 0 ) {
		self thread monitorJumping();
	}	
	
	// Start the overall sprint/walk without ads monitoring thread
	if (  level.scr_player_sprinttime != 0 || level.scr_fcs_walk_without_ads_allowed == 0 ) {
		// Check if player will get tired when sprinting
		if ( level.scr_fcs_sprint_slowsdown_max != 0 ) {
			self thread speedScaleControl( maxSprintTime );
		}
		self thread sprintControl();
		self thread recoveryControl( maxSprintTime );
		self thread hudColorControl( maxSprintTime );
	}	
	
	// Check if we need to enable the pulse control
	if ( level.scr_fcs_pulse_enabled != 0 ) {
		self thread pulseControl( maxSprintTime, self.maxhealth );
	}
	
	// Check if we need to force the player to crouch on spawn
	if ( level.scr_fcs_crouch_on_spawn == 1 ) {
		self execClientCommand("gocrouch");
	}
}


delaySprinting()
{
	self endon("death");
	self endon("disconnect");
	level endon("game_ended");
	
	// Disable sprint for this player
	self thread maps\mp\gametypes\_gameobjects::_disableSprint();
	
	// Wait for the set time to allow sprinting for the player	
	sprintAllowed = openwarfare\_timer::getTimePassed() + level.scr_fcs_sprint_delay * 1000;
	while ( openwarfare\_timer::getTimePassed() < sprintAllowed )
		wait (0.05);
		
	// Enable sprinting for this player
	self thread maps\mp\gametypes\_gameobjects::_enableSprint();	
}


monitorSprintStart()
{
	self endon("death");
	self endon("disconnect");
	level endon("game_ended");
	
	for (;;)
	{
		self waittill("sprint_begin");
		self.fcs["sprinting"] = true;
	}	
}


monitorSprintEnd()
{
	self endon("death");
	self endon("disconnect");
	level endon("game_ended");
	
	for (;;)
	{
		self waittill("sprint_end");
		self.fcs["sprinting"] = false;
	}	
}


monitorJumping()
{
	self endon("death");
	self endon("disconnect");
	level endon("game_ended");

	// Initialize some variables we need to detect jumping
	playerJumping = false;
	heightTracker = 0;
	lastDistance = 0;
		
	for (;;)
	{
		wait (0.05);	
		
		// If player is on the ground and was jumping reset the variables
		if ( self isOnGround() && playerJumping ) {
			playerJumping = false;
			lastDistance = 0;
		} else {
			// Make sure the player has not already being detected jumping and that it's not
			// using a ladder, mantling or on the ground
			if ( !playerJumping && !self isOnGround() && !self isMantling() && !self isOnLadder() ) {
				playerOrigin = self.origin;

				// Player is airborne... Get the distance from the player to the ground
				groundOrigin = playerphysicstrace( playerOrigin, playerOrigin + (0,0,-1000) );
				newDistance = int( distance( playerOrigin, groundOrigin ) );

				// If distance is higher than the one measured before then the player might be jumping
				if ( newDistance > lastDistance ) {
					heightTracker++;

					// If we have 3 consecutive measures increasing the  distance from the ground
					// then the player is considered being jumping
					if ( heightTracker >= 3 ) {
						self.fcs["jumping"] = true;
						playerJumping = true;
						heightTracker = 0;
					}
				} else {
					heightTracker = 0;
				}

				lastDistance = newDistance;
			} else {
				heightTracker = 0;
			}
		}
	}	
}


monitorWalkWithoutADS()
{
	self endon("death");
	self endon("disconnect");
	level endon("game_ended");
	
	for (;;)
	{
		wait (0.05);
		// Check for the velocity of the player, stance, etc to see if the player is walking with no ADS
		if ( self getVelocity() != 0 && self getStance() == "stand" && self isOnGround() && !self.fcs["sprinting"] && !self playerAds() ) {
			playerIsWalking = true;
		} else {
			playerIsWalking = false;
		}
		
		// Check if we need to update the status
		if ( self.fcs["walking"] != playerIsWalking ) {
			self.fcs["walking"] = playerIsWalking;
		}		
	}	
}


speedScaleControl( maxSprintTime )
{
	self endon("death");
	self endon("disconnect");
	level endon("game_ended");
	
	// Initialize the speed modifier
	currentModifierValue = 0;

	for (;;)
	{
		wait (0.05);	
		// Calculate how speed this player should lose according to the maximum 
		sprintConsumed = 1 - self.fcs["time"] / maxSprintTime;
		newModifierValue = int( level.scr_fcs_sprint_slowsdown_max * sprintConsumed );
		
		// We'll only change the modifer if there's a different of at least 5 points
		if ( newModifierValue - currentModifierValue >= 5 || newModifierValue - currentModifierValue <= -5 ) {
			currentModifierValue = newModifierValue;
			self openwarfare\_speedcontrol::setModifierSpeed( "_tacticalmcs", newModifierValue );
		}
	}
}



sprintControl()
{
	self endon("death");
	self endon("disconnect");
	level endon("game_ended");
	
	for (;;)
	{	
		wait (0.05);
		
		// Check if the player is sprinting or walking and start reducing the sprinting time
		if ( self.fcs["sprinting"] || self.fcs["walking"] || self.fcs["jumping"] ) {
			self.fcs["canrecover"] = false;
			
			// Check if the player is jumping
			if ( self.fcs["jumping"] ) {
				self.fcs["time"] -= level.scr_fcs_jump_penalty;
				
			} else {
				lastDecrease = openwarfare\_timer::getTimePassed();
				// Sprinting will take full time but walking will take only half the time
				while ( ( self.fcs["sprinting"] || self.fcs["walking"] ) && self.fcs["time"] > 0 ) {
					wait (0.05);
					timeToDecrease = openwarfare\_timer::getTimePassed() - lastDecrease;
					if ( self.fcs["walking"] ) {
						timeToDecrease = int( timeToDecrease / 2 );
					}
					self.fcs["time"] -= timeToDecrease;
					lastDecrease = openwarfare\_timer::getTimePassed();				
				}
			}
			
			// Check if the player reached full sprint time
			if ( self.fcs["time"] <= 0 ) {
				self.fcs["time"] = 0;
				if ( !self.fcs["disabled"] ) {
					self thread maps\mp\gametypes\_gameobjects::_disableSprint();
					self thread maps\mp\gametypes\_gameobjects::_disableJump();
					self.fcs["disabled"] = true;
				}
				
				if ( level.scr_fcs_walk_without_ads_allowed == 0 ) {
					self execClientCommand("gocrouch");
				} else {
					if ( self.fcs["sprinting"] ) {
						self freezeControls( true ); wait( 0.01 );	self freezeControls( false );
					}
				}
				
				self playLocalSound( "breathing_better" );
			}

			// If the player was jumping then wait a second to let the process handle it
			if ( self.fcs["jumping"] ) {
				xWait (1.0);
				self.fcs["jumping"] = false;
			}			
		}		
		
		self.fcs["canrecover"] = true;
	}	
}


recoveryControl( maxSprintTime )
{
	self endon("death");
	self endon("disconnect");
	level endon("game_ended");
	
	for (;;)
	{	
		wait (0.05);
		
		// Make sure the player is not walking or sprinting and that it can recover time
		if ( self.fcs["canrecover"] ) {
			// Wait for the proper recovery delay if it was a full sprint
			if ( self.fcs["time"] <= 0 ) {
				recoveryDelay = openwarfare\_timer::getTimePassed() + level.scr_fcs_sprint_recovery_delay * 1000;
				while ( openwarfare\_timer::getTimePassed() < recoveryDelay && self.fcs["canrecover"] )
					wait (0.05);
			} else {
				recoveryDelay =  openwarfare\_timer::getTimePassed();
			}
				
			// Check if the necessary recovery delay passed
			if ( self.fcs["canrecover"] && openwarfare\_timer::getTimePassed() >= recoveryDelay ) {
				// Start recovering sprinting time
				while ( self.fcs["canrecover"] && self.fcs["time"] < maxSprintTime ) {
					if ( self.fcs["disabled"] ) {
						self thread maps\mp\gametypes\_gameobjects::_enableSprint();
						self thread maps\mp\gametypes\_gameobjects::_enableJump();
						self.fcs["disabled"] = false;
					}				

					// Wait the necessary time to recover 100ms of sprinting time and increase it
					xWait( 0.1 * level.scr_fcs_sprint_recovery_time );
					if ( self.fcs["canrecover"] ) {
						self.fcs["time"] += 100;
						if ( self.fcs["time"] > maxSprintTime ) {
							self.fcs["time"] = maxSprintTime;
						}					
					}
				}
			}
		}
	}	
}


hudColorControl( maxSprintTime )
{
	self endon("death");
	self endon("disconnect");
	level endon("game_ended");
	
	// Color levels: 0 = Grey, 1 = Green, 2 = Yellow, 3 = Orange, 4 = Red
	currentColorLevel = 0;
	
	for (;;)
	{	
		wait (0.05);
		
		// Calculate how much sprinting this player has consumed
		sprintConsumed = 1 - self.fcs["time"] / maxSprintTime;
				
		// Check which color should the HUD element be
		if ( sprintConsumed >= 0.9 ) {
			newColor = 4;			
		} else if ( sprintConsumed >= 0.7 ) {
			newColor = 3;			
		} else if ( sprintConsumed >= 0.4 ) {
			newColor = 2;			
		} else if ( sprintConsumed >= 0.1 ) {
			newColor = 1;
		} else {
			newColor = 0;
		}
		
		// Check if we need to set a new color
		if ( currentColorLevel != newColor ) {
			currentColorLevel = newColor;
			self setClientDvar( "ui_stance_color", newColor );
		}
	}
}


pulseControl( maxSprintTime, maxHealth )
{
	self endon("death");
	self endon("disconnect");
	level endon("game_ended");

	swayIndex = level.swaySin.size - 1;

	for (;;)
	{	
		wait (0.03);

		// If player is in last stand we ignore pulse
		if ( isDefined( self.lastStand ) && self.lastStand )
			continue;
		
		// Calculate how much sprinting this player has consumed and his damage percent
		sprintConsumed = 1 - self.fcs["time"] / maxSprintTime;	
		damageTaken = 1 - self.health / maxHealth;
	
		horizontalShift = 0;
		verticalShift = 0;
		
		// Check if we need to base the pulse on damage only or on set the base on damage
		if ( ( level.scr_fcs_pulse_enabled == 1 || level.scr_fcs_pulse_enabled == 3 ) && damageTaken >= 0.5 ) {
			horizontalShift = level.swaySin[swayIndex] * ( 10 / ( self.health + 0.0001 ) );
			verticalShift = level.swayCos[swayIndex] * ( 10 / ( self.health + 0.0001 ) );			
			
		} else if ( level.scr_fcs_pulse_enabled == 2 || level.scr_fcs_pulse_enabled == 3 ) {
			horizontalShift = level.swaySin[swayIndex] * ( 0.005 + sprintConsumed * sprintConsumed * 0.15 );
			verticalShift = level.swayCos[swayIndex] * ( 0.02 + sprintConsumed * sprintConsumed * 0.375 );			
		}

		// Make sure we still need to do the sway
		if ( horizontalShift != 0 || verticalShift != 0 ) {
			// If the current gametype is freeze tag and the player is frozen disable the sway
			if ( level.gametype == "ftag" && self.freezeTag["frozen"] ) {
				continue;
				
			// Check if we should reduce the sway based on the player stance
			} else if ( self getStance() == "prone" ) {
				// Check if the player is ADS
				if ( self playerADS() ) {
					horizontalShift *= 0.70;
					verticalShift *= 0.70;
				} else {
					horizontalShift *= 0.80;
					verticalShift *= 0.80;					
				}
				
			} else if ( self getStance() == "crouch" ) {
				// Check if the player is ADS
				if ( self playerADS() ) {
					horizontalShift *= 0.80;
					verticalShift *= 0.80;
				} else {
					horizontalShift *= 0.90;
					verticalShift *= 0.90;					
				}				

			} else if ( self getStance() == "stand" ) {
				// Check if the player is ADS
				if ( self playerADS() ) {
					horizontalShift *= 0.90;
					verticalShift *= 0.90;
				}
			}

			// Apply manual modifier
			horizontalShift *= level.scr_fcs_pulse_modifier;
			verticalShift *= level.scr_fcs_pulse_modifier;			
			
			// Do the sway
			playerAngles = self getPlayerAngles();
			self setPlayerAngles( playerAngles + ( verticalShift, horizontalShift, 0 ) );						
			
			swayIndex++;
			if ( swayIndex == level.swaySin.size ) 
				swayIndex = 0;
		}
	}	
}