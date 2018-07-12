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
	level.scr_quickactions_enable = getdvarx( "scr_quickactions_enable", "int", 0, 0, 1 );
	
	if ( level.scr_quickactions_enable == 0 )
		return;
	
	// Initialize all the commands that we'll support
	quickActions = initQuickActions();
	level.scr_player_forcerespawn = getdvarx( "scr_player_forcerespawn", "int", 1, 0, 1 );
	
	// Make sure at least one quick action is enabled
	if ( quickActions ) {
		level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
	}	
}


initQuickActions()
{
	// Initialize the array we'll use to hold the quick actions
	level.quickActions = [];
	
	// Add quick actions in order of importance
	addQuickAction( &"OW_QUICKACTION_BANDAGE", ::actionBandage );
	addQuickAction( &"OW_QUICKACTION_UNJAM", ::actionUnjam );
	addQuickAction( &"OW_ATTACH_DETACH", ::actionAttachDetach );
	
	return ( level.quickActions.size > 0 );
}


addQuickAction( actionText, actionFunction )
{
	// The function without parameters returns if the functionality is enabled
	actionEnabled = [[actionFunction]]();

	// Add the new quick command to the list
	if ( actionEnabled ) {
		level.quickActions[ level.quickActions.size ]["text"] = actionText;
		level.quickActions[ level.quickActions.size - 1 ]["function"] = actionFunction;	
	}
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}


onPlayerSpawned()
{
	self thread quickActions();
}


quickActions()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );
	
	currentAction = -1;
	pressReset = 0;
	
	// If players need to press the USE key to spawn we'll wait couple of seconds
	if ( level.scr_player_forcerespawn == 1 ) {
		wait (2.0);
	}
	
	for (;;) {
		wait (0.05);
		
		// Check if the player is pressing the use key
		if ( self useButtonPressed() ) {
			// Make sure the player is not interacting with anything
			if ( level.gametype != "sd" || ( !self.isPlanting && !self.isDefusing ) ) {
				ms = 0;
				while ( ms < 11 && self useButtonPressed() ) {
					 ms++; wait (0.05);
				}

				// Releasing the key before half a second count as a tap
				if ( ms < 11 ) {
					currentAction++;
					// If we get to the end we start from the first command
					if ( currentAction == level.quickActions.size ) {
						currentAction = 0;
					}
					
					// Show the player which command is active now
					self iprintln( &"OW_QUICKACTION_TEXT", currentAction + 1, level.quickActions.size, level.quickActions[currentAction]["text"] );
										
				} else {
					// Player is holding the use key for more than half a second execute the current command
					if ( currentAction != -1 ) {
						functionToCall = level.quickActions[currentAction]["function"];
						self thread [[functionToCall]]( true );
						while ( self useButtonPressed() ) wait (0.05);
						self thread [[functionToCall]]( false );
					} else {
						while ( self useButtonPressed() ) wait (0.05);						
					}					
				}
			}			
			pressReset = 0;	
		}	else {
			pressReset++;
		}
		
		// Check if we need to reset the tap counter
		if ( pressReset == 31 && currentAction != -1 ) {
			pressReset = 0;
			currentAction = -1;
			self iprintln( &"OW_QUICKACTION_ENDED" );
		}		
	}	
}


actionBandage( whatToDo )
{
	// If what to do is not defined then we return if this functionality is active
	if ( !isDefined( whatToDo ) )
	{
    if ( getDvarInt( "scr_healthsystem_bleeding_enable") != 0 || getDvarInt( "scr_healthsystem_medic_enable") != 0 )
      return true;
		else
      return false;
  } 
  
  if ( !isDefined( self.stopBandage ) )
    self.stopBandage = false;
    
    		
  if ( self.stopBandage )
  {
    self.stopBandage = false;
    
    if ( isDefined( self.isBandaging ) && self.isBandaging )
      self thread openwarfare\_healthsystem::bandageSelf();
    if ( isDefined( self.isBandagingTeammate ) && self.isBandagingTeammate )
      self thread openwarfare\_healthsystem::medic();
    else if ( isDefined( self.isHealingTeammate ) && self.isHealingTeammate )
      self thread openwarfare\_healthsystem::medic();
    else if ( isDefined( self.isHealing ) && self.isHealing )
      self thread openwarfare\_healthsystem::medic(); 
  }
  else
  {
    self.stopBandage = true;
    
    if ( isDefined( self.isBleeding ) && self.isBleeding )
      self thread openwarfare\_healthsystem::bandageSelf();
		else
      self thread openwarfare\_healthsystem::medic();
  }
}


actionUnjam( whatToDo )
{
	// If what to do is not defined then we return if this functionality is active
	if ( !isDefined( whatToDo ) )
		return ( getdvarx( "scr_weaponjams_enable", "int", 0 ) != 0 );
		
	// We only try to unjam the weapon when whatToDo is set to true
	if ( whatToDo ) {
		self thread openwarfare\_weaponjam::unjamWeapon();
	}		
}


actionAttachDetach( whatToDo )
{
	// If what to do is not defined then we return if this functionality is active
	if ( !isDefined( whatToDo ) )
		return ( getdvarx( "scr_dynamic_attachments_enable", "int", 0 ) != 0 );
		
	// We only try to attach/detach the attachment when whatToDo is set to true
	if ( whatToDo ) {
		self thread openwarfare\_dynamicattachments::attachDetachAttachment();
	}		
}