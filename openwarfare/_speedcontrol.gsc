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
	// Initialize all the events we need to use
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onPlayerDeath", ::onPlayerDeath );
}


onPlayerSpawned()
{
	// Initialize all the variables to control the player speed
	if ( !isDefined( self.speedScale ) ) {
		self.speedScale = spawnstruct();
		self.speedScale.base = 0;
		self.speedScale.current = -1;
		self.speedScale.modifiers = [];		
	}
	
	// Start the speed controller
	self thread speedController();
}


onPlayerDeath()
{
	// Reset all the modifiers on player's death
	modifierKeys = getArrayKeys( self.speedScale.modifiers );
	for ( key=0; key < modifierKeys.size; key++ ) {
		self.speedScale.modifiers[modifierKeys[key]] = 0;			
	}
	
	// Reset current speed
	self.speedScale.current = -1;
}


speedController()
{
	self endon("disconnect");
	self endon("death");
	
	for (;;)
	{
		// Calculate new speed
		modifierPercents = 0;
		modifierKeys = getArrayKeys( self.speedScale.modifiers );
		for ( key=0; key < modifierKeys.size; key++ ) {
			modifierPercents += self.speedScale.modifiers[modifierKeys[key]];			
		}
		
		// Calculate the new speed and make sure it is not negative
		newSpeed = self.speedScale.base - ( self.speedScale.base * modifierPercents / 100 );
		if ( newSpeed < 0 ) {
			newSpeed = 0;
		}
		
		// Check if we have a different speed
		if ( newSpeed != self.speedScale.current ) {

			/*/ DEBUG BEGIN //
			self iprintln( "Speed has changed with a base value of " + self.speedScale.base + " and the following modifiers:" );
			modifierKeys = getArrayKeys( self.speedScale.modifiers );
			for ( key=0; key < modifierKeys.size; key++ ) {
				self iprintln( "Modifier: " + modifierKeys[key] + " --> " + self.speedScale.modifiers[modifierKeys[key]] + "%" );
			}			
			self iprintln( "New speed for player is " + newSpeed );			
			// DEBUG END /*/			
			
			self.speedScale.current = newSpeed;
			self setMoveSpeedScale( newSpeed );
		}
		
		self waittill( "speed_changed" );
	}	
}


setBaseSpeed( newSpeed ) 
{
	// Wait until the structure is defined
	while ( !isDefined( self.speedScale ) || !isDefined( self.speedScale.base ) )
		wait (0.05);
		
	// Check if the new base speed is different from the current one
	if ( self.speedScale.base != newSpeed ) {
		self.speedScale.base = newSpeed;
		self notify( "speed_changed" );
	}
}


setModifierSpeed( modifierKey, modifierPercent )
{
	// Wait until the structure is defined
	while ( !isDefined( self.speedScale ) || !isDefined( self.speedScale.modifiers ) )
		wait (0.05);
			
	// Check if the new modifier value is different from the current one
	if ( !isDefined( self.speedScale.modifiers[ modifierKey ] ) || self.speedScale.modifiers[ modifierKey ] != modifierPercent ) {
		self.speedScale.modifiers[ modifierKey ] = modifierPercent;
		self notify( "speed_changed" );
	}
}