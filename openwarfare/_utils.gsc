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

// Function to get extended dvar values
getdvarx( dvarName, dvarType, dvarDefault, minValue, maxValue )
{
	// Check variables from lowest to highest priority

	if ( !isDefined( level.gametype ) ) {
		level.script = toLower( getDvar( "mapname" ) );
		level.gametype = toLower( getDvar( "g_gametype" ) );
		level.serverLoad = getDvar( "_sl_current" );
	}
	
	// scr_variable_name_<load>
	if ( getdvar( dvarName + "_" + level.serverLoad ) != "" )
		dvarName = dvarName + "_" + level.serverLoad;
			
	// scr_variable_name_<gametype>
	if ( getdvar( dvarName + "_" + level.gametype ) != "" )
		dvarName = dvarName + "_" + level.gametype;

	// scr_variable_name_<gametype>_<load>
	if ( getdvar( dvarName + "_" + level.gametype + "_" + level.serverLoad ) != "" )
		dvarName = dvarName + "_" + level.gametype + "_" + level.serverLoad;		

	// scr_variable_name_<mapname>
	if ( getdvar( dvarName + "_" + level.script ) != "" )
		dvarName = dvarName + "_" + level.script;

	// scr_variable_name_<mapname>_<load>
	if ( getdvar( dvarName + "_" + level.script + "_" + level.serverLoad ) != "" )
		dvarName = dvarName + "_" + level.script + "_" + level.serverLoad;

	// scr_variable_name_<gametype>_<mapname>
	if ( getdvar( dvarName + "_" + level.gametype + "_" + level.script ) != "" )
		dvarName = dvarName + "_" + level.gametype + "_" + level.script;

	// scr_variable_name_<gametype>_<mapname>_<load>
	if ( getdvar( dvarName + "_" + level.gametype + "_" + level.script + "_" + level.serverLoad ) != "" )
		dvarName = dvarName + "_" + level.gametype + "_" + level.script + "_" + level.serverLoad;

	return getdvard( dvarName, dvarType, dvarDefault, minValue, maxValue );
}


// Function to get extended dvar values (only with server load)
getdvarl( dvarName, dvarType, dvarDefault, minValue, maxValue, useLoad )
{
	// scr_variable_name_<load>
	if ( isDefined( level.serverLoad ) && useLoad && getdvar( dvarName + "_" + level.serverLoad ) != "" )
		dvarName = dvarName + "_" + level.serverLoad;

	return getdvard( dvarName, dvarType, dvarDefault, minValue, maxValue );
}


// Function to get dvar values (not extended)
getdvard( dvarName, dvarType, dvarDefault, minValue, maxValue )
{
	// Initialize the return value just in case an invalid dvartype is passed
	dvarValue = "";

	// Assign the default value if the dvar is empty
	if ( getdvar( dvarName ) == "" ) {
		dvarValue = dvarDefault;
	} else {
		// If the dvar is not empty then bring the value
		switch ( dvarType ) {
			case "int":
				dvarValue = getdvarint( dvarName );
				break;
			case "float":
				dvarValue = getdvarfloat( dvarName );
				break;
			case "string":
				dvarValue = getdvar( dvarName );
				break;
		}
	}

	// Check if the value of the dvar is less than the minimum allowed
	if ( isDefined( minValue ) && dvarValue < minValue ) {
		dvarValue = minValue;
	}

	// Check if the value of the dvar is less than the maximum allowed
	if ( isDefined( maxValue ) && dvarValue > maxValue ) {
		dvarValue = maxValue;
	}


	return ( dvarValue );
}


// Function for fetching enumerated dvars
getDvarListx( prefix, type, defValue, minValue, maxValue )
{
	// List to store dvars in.
	list = [];

	while (true)
	{
		// We don't need any defailt value since they just won't be added to the list.
		temp = getdvarx( prefix + (list.size + 1), type, defValue, minValue, maxValue );

		if (isDefined( temp ) && temp != defValue )
			list[list.size] = temp;
		else
			break;
	}

	return list;
}


updateSecondaryProgressBar( curProgress, useTime, forceRemove, barText )
{
	// Check if we need to remove the bar
	if ( forceRemove )
	{
		if ( isDefined( self.proxBar2 ) )
			self.proxBar2 hideElem();

		if ( isDefined( self.proxBarText2 ) )
			self.proxBarText2 hideElem();
		return;
	}

	// Check if the player has the primary progress bar object
	if ( !isDefined( self.proxBar2 ) )
	{
		self.proxBar2 = createSecondaryProgressBar();
	}

	if ( self.proxBar2.hidden )
	{
		self.proxBar2 showElem();
	}

	// Check if the player has the primary progress bar text object
	if ( !isDefined( self.proxBarText2 ) )
	{
		self.proxBarText2 = createSecondaryProgressBarText();
		self.proxBarText2 setText( barText );
	}

	if ( self.proxBarText2.hidden )
	{
		self.proxBarText2 showElem();
		self.proxBarText2 setText( barText );
	}

	// Make sure we are not going over the limit
	if( curProgress > useTime)
		curProgress = useTime;

	// Update the progress bar
	self.proxBar2 updateBar( curProgress / useTime , undefined );
}



getPlayerEyes()
{
	playerEyes = self.origin;
	switch ( self getStance() ) {
		case "prone":
			playerEyes += (0,0,11);
			break;
		case "crouch":
			playerEyes += (0,0,40);
			break;
		case "stand":
			playerEyes += (0,0,60);
			break;
	}
	
	return playerEyes;	
}


// Based on maps\_utility::player_looking_at() function (adapted for multiplayer)
IsLookingAt( gameEntity )
{
	entityPos = gameEntity.origin;
	playerPos = self getEye();

	entityPosAngles = vectorToAngles( entityPos - playerPos );
	entityPosForward = anglesToForward( entityPosAngles );

	playerPosAngles = self getPlayerAngles();
	playerPosForward = anglesToForward( playerPosAngles );

	newDot = vectorDot( entityPosForward, playerPosForward );

	if ( newDot < 0.72 ) {
		return false;
	} else {
		return true;
	}

	/*traceResult = bullettrace( entityPos, playerPos, false, undefined );
	self iprintln( "newDOT = "+newDot+"   /   traceResult[fraction]="+traceResult["fraction"] );
	return ( traceResult["fraction"] == 1 );*/
}


createSecondaryProgressBar()
{
	bar = createBar( (1, 1, 1), level.secondaryProgressBarWidth, level.secondaryProgressBarHeight );
	if ( level.splitScreen )
		bar setPoint("TOP", undefined, level.secondaryProgressBarX, level.secondaryProgressBarY);
	else
		bar setPoint("CENTER", undefined, level.secondaryProgressBarX, level.secondaryProgressBarY);

	return bar;
}


createSecondaryProgressBarText()
{
	text = createFontString( "objective", level.secondaryProgressBarFontSize );
	if ( level.splitScreen )
		text setPoint("TOP", undefined, level.secondaryProgressBarTextX, level.secondaryProgressBarTextY);
	else
		text setPoint("CENTER", undefined, level.secondaryProgressBarTextX, level.secondaryProgressBarTextY);

	text.sort = -1;
	return text;
}


createTimer( font, fontScale )
{
	// Creates a timer only for the player
	timerElem = newClientHudElem( self );
	timerElem.elemType = "timer";
	timerElem.font = font;
	timerElem.fontscale = fontScale;
	timerElem.x = 0;
	timerElem.y = 0;
	timerElem.width = 0;
	timerElem.height = int(level.fontHeight * fontScale);
	timerElem.xOffset = 0;
	timerElem.yOffset = 0;
	timerElem.children = [];
	timerElem setParent( level.uiParent );
	timerElem.hidden = false;

	return timerElem;
}


addLeagueRuleset( leagueName, gameType, functionPointer )
{
	level.matchRules[ leagueName ][ gameType ] = functionPointer;

	return;
}


giveNadesAfterDelay( nadeType, nadeCount, nadePrimary )
{
	if ( level.gametype == "gg" || level.gametype == "ss" || level.gametype == "oitc" )
		return;
	
	if ( level.gametype == "hns" ) {
		if ( self.pers["team"] == game["defenders"] ) {
			return;
		} else {
			// If we are in the hiding period wait until the period is over to start counting
			if ( level.inHidingPeriod ) {
				level waittill( "hiding_time_over" );	
			}	
		}
	}
	
	self notify("giveNadesAfterDelay");
	wait (0.05);
	
	self endon("disconnect");
	self endon("death");
	self endon("giveNadesAfterDelay");

	playSound = false;

	// Check what type of grenade is it?
	switch ( nadeType )
	{
		case "frag_grenade_mp":
			timeToUse = level.scr_delay_frag_grenades * 1000;
			break;
		case "smoke_grenade_mp":
			timeToUse = level.scr_delay_smoke_grenades * 1000;
			break;
		case "flash_grenade_mp":
			timeToUse = level.scr_delay_flash_grenades * 1000;
			break;
		case "concussion_grenade_mp":
			timeToUse = level.scr_delay_concussion_grenades * 1000;
			break;
		default:
			timeToUse = 0;
			break;
	}

	if ( timeToUse > 0 ) {
		playSound = true;

		// Check if we need to delay every time the player spawns
		if ( !level.scr_delay_only_round_start ) {
			timeToUse += openwarfare\_timer::getTimePassed();
		}

		while ( timeToUse > openwarfare\_timer::getTimePassed() )
			wait (0.05);
	}

	// Give the stuff to the player
	if ( isDefined( self ) ) {
		self giveWeapon( nadeType );
		self setWeaponAmmoClip( nadeType, nadeCount );
	
		// Play a sound so the players know they can use grenades
		if ( playSound && level.scr_delay_sound_enable == 1 ) {
			self playLocalSound( "weap_ammo_pickup" );
		}
	
		if( nadePrimary )
			self switchToOffhand( nadeType );
	}

	return;
}


giveActionSlot3AfterDelay( slotWeapon )
{
	if ( level.gametype == "gg" || level.gametype == "ss" || level.gametype == "oitc" )
		return;

	if ( level.gametype == "hns" ) {
		if ( self.pers["team"] == game["defenders"] ) {
			return;
		} else {
			// If we are in the hiding period wait until the period is over to start counting
			if ( level.inHidingPeriod ) {
				level waittill( "hiding_time_over" );	
			}	
		}
	}
					
	self notify("giveActionSlot3AfterDelay");
	wait (0.05);
	
	self endon("disconnect");
	self endon("death");
	self endon("giveActionSlot3AfterDelay");

	playSound = false;

	// Check what kind of delay we should be using
	switch ( slotWeapon )
	{
		case "altMode":
			// We do not give the greande launcher if it's disabled (condition here for ranked servers)
			if ( level.attach_allow_assault_gl == 0 )
				return;
			timeToUse = level.scr_delay_grenade_launchers * 1000;
			break;
			
		case "rpg_mp":
			// We do not give RPGs if it's disabled (condition here for ranked servers)
			if ( level.perk_allow_rpg_mp == 0 )
				return;
			timeToUse = level.scr_delay_rpgs * 1000;
			break;
			
		case "c4_mp":
			// We do not give C4 if it's disabled (condition here for ranked servers)
			if ( level.perk_allow_c4_mp == 0 )
				return;
			timeToUse = level.scr_delay_c4s * 1000;
			break;
			
		case "claymore_mp":
			// We do not give Claymores if it's disabled (condition here for ranked servers)
			if ( level.perk_allow_claymore_mp == 0 )
				return;
			timeToUse = level.scr_delay_claymores * 1000;
			break;
			
		default:
			timeToUse = 0;
	}

	if ( timeToUse > 0 ) {
		playSound = true;

		// Check if we need to delay every time the player spawns
		if ( !level.scr_delay_only_round_start ) {
			timeToUse += openwarfare\_timer::getTimePassed();
		}

		while ( timeToUse > openwarfare\_timer::getTimePassed() )
			wait (0.05);
	}


	if ( isDefined( self ) ) {
		// Activate the alternate mode in the weapons
		if ( slotWeapon == "altMode" ) {
			self SetActionSlot( 3, "altMode" );
		} else {
			self SetActionSlot( 3, "weapon", slotWeapon );
		}
	
		// Play a sound so the players know they can use grenades
		if ( playSound && level.scr_delay_sound_enable == 1 ) {
			self playLocalSound( "weap_ammo_pickup" );
		}
	}

	return;
}


giveActionSlot4AfterDelay( hardpointType, streak )
{
	self notify("giveActionSlot4AfterDelay");
	wait (0.05);
	
	self endon("disconnect");
	self endon("death");
	self endon("giveActionSlot4AfterDelay");

	// Check what kind of delay we should be using
	if ( !isDefined( streak ) ) {
		switch ( hardpointType )
		{
			case "airstrike_mp":
				timeToUse = level.scr_airstrike_delay * 1000;
				break;
			case "helicopter_mp":
				timeToUse = level.scr_helicopter_delay * 1000;
				break;
			default:
				timeToUse = 0;
		}
	
		if ( timeToUse > 0 ) {
			playSound = true;
	
			while ( timeToUse > openwarfare\_timer::getTimePassed() )
				wait (0.05);
		}
	}

	if ( isDefined( self ) ) {
		// Assign the weapon slot 4
		self giveWeapon( hardpointType );
		self giveMaxAmmo( hardpointType );
		self setActionSlot( 4, "weapon", hardpointType );
		self.pers["hardPointItem"] = hardpointType;
		
		// Check if we should remind the player about having the hardpoint
		if ( level.scr_hardpoint_show_reminder != 0 ) {
			self thread maps\mp\gametypes\_hardpoints::hardpointReminder( hardpointType );
		}
	
		// Show the message
		if ( isDefined( streak ) || level.scr_hardpoint_show_reminder != 0 ) {
			self thread maps\mp\gametypes\_hardpoints::hardpointNotify( hardpointType, streak );
		}
	}

	return;
}


// Trims left spaces from a string
trimLeft( stringToTrim )
{
	stringIdx = 0;
	while ( stringToTrim[ stringIdx ] == " " && stringIdx < stringToTrim.size )
		stringIdx++;

	newString = getSubStr( stringToTrim, stringIdx, stringToTrim.size - stringIdx );

	return newString;
}


// Trims right spaces from a string
trimRight( stringToTrim )
{
	stringIdx = stringToTrim.size;
	while ( stringToTrim[ stringIdx ] == " " && stringIdx > 0 )
		stringIdx--;

	newString = getSubStr( stringToTrim, 0, stringIdx );

	return newString;

}


// Trims all the spaces left and right from a string
trim( stringToTrim )
{
	return ( trimLeft( trimRight ( stringToTrim ) ) );
}


// As we cannot reference native engine functions we have to use a wrapper to do this.
// This way we can easily attach it to an event, which is useful for debugging.
iPrintLnWrapper( message )
{
	self iPrintLn( message );
}

// Removes an element from the array and reindexes it.
removeIndexArray(orgArray, index)
{
	newArray = [];

	for(i = 0; i < orgArray.size; i++) {
		if(i < index) {
			newArray[i] = orgArray[i];
		} else if(i > index) {
			newArray[i - 1] = orgArray[i];
		}
	}

	return newArray;
}

/*
   Note that getArrayKeys() returns the list of keys in reverse order,
   therefore we need to iterate through them in reverse as well to get
   the correct order.
*/

// Removes all instances of an element from the array
array_remove( array, item )
{
	temp = [];

	keys = getArrayKeys( array );
	for (i = keys.size - 1; i >= 0; i--)
	{
		if (array[keys[i]] != item)
			temp[keys[i]] = array[keys[i]];
	}

	return temp;
}

// Removes the first instances of an element from the array
array_remove_first( array, item )
{
	temp = [];
	removed = false;

	keys = getArrayKeys( array );
	for (i = keys.size - 1; i >= 0; i--)
	{
		if (array[keys[i]] != item || removed == true)
		{
			temp[keys[i]] = array[keys[i]];
		}
		else
		{
			removed = true;
		}
	}

	return temp;
}

// Extracts a sub-array from an array with numeral indicies.
array_slice( array, start, end )
{
	temp = [];
	for (i = start; i <= end; i++)
	{
		temp[temp.size] = array[i];
	}

	return temp;
}

// Replaces a sub-array from an array with a new item.
array_splice( array, start, end, item )
{
	temp = [];
	for (i = 0; i < array.size; i++)
	{
		if (i < start || i > end)
			temp[temp.size] = array[i];
		if (i == start)
			temp[temp.size] = item;
	}

	return temp;
}

// Performs 'func' on each element in the array with an optional argument.
each( array, func, arg )
{
	keys = getArrayKeys( array );
	if (isDefined( arg ))
	{
		for (i = keys.size - 1; i >= 0; i--)
		{
			self [[ func ]]( array[keys[i]], arg );
		}
	}
	else
	{
		for (i = keys.size - 1; i >= 0; i--)
		{
			self [[ func ]]( array[keys[i]] );
		}
	}
}

// Same as 'each' but will also pass the index of the item to 'func'
each_with_index( array, func, arg )
{
	keys = getArrayKeys( array );
	if (isDefined( arg ))
	{
		for (i = keys.size - 1; i >= 0; i--)
		{
			self [[ func ]]( array[keys[i]], arg, i );
		}
	}
	else
	{
		for (i = keys.size - 1; i >= 0; i--)
		{
			self [[ func ]]( array[keys[i]], i );
		}
	}
}

//	Selects only elements of an array which have been evaluated to "true"
//	by the evaluator function and returns them as a new array
select( array, evaluator )
{
	temp = [];

	keys = getArrayKeys( array );

	for (i = keys.size - 1; i >= 0; i--)
	{
		if ([[ evaluator ]]( array[keys[i]] ))
			temp[temp.size] = array[keys[i]];
	}

	return temp;
}


deleteExplosives()
{
	// delete c4
	if ( isdefined( self.c4array ) )
	{
		for ( i = 0; i < self.c4array.size; i++ )
		{
			if ( isdefined(self.c4array[i]) )
				self.c4array[i] delete();
		}
	}
	self.c4array = [];

	// delete claymores
	if ( isdefined( self.claymorearray ) )
	{
		for ( i = 0; i < self.claymorearray.size; i++ )
		{
			if ( isdefined(self.claymorearray[i]) )
				self.claymorearray[i] delete();
		}
	}
	self.claymorearray = [];

	return;
}

ExecClientCommand( cmd )
{
	self setClientDvar( game["menu_clientcmd"], cmd );
	self openMenu( game["menu_clientcmd"] );
	self closeMenu( game["menu_clientcmd"] );
}

weaponPause(waittime)
{
	/*---------------------------------------------------------------------
	 Inuitively obvious to the casual observer (and used as thread)
	---------------------------------------------------------------------*/
	self endon("killed_player");
	self endon("spawned");
	self endon("disconnect");
	level endon("intermission");

	self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
	wait waittime;
	self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
}

percentChance(chance)
// Random function
{
	if(chance == 0) return false;
	if(chance > 100) chance = 100;
	percent = randomint(100);
	if(percent < chance)
		return true;
	else
		return false;
}

Distort()
{
//Gunsway
	self endon("killed_player");
	self endon("spawned");
	self endon("disconnect");
	level endon("intermission");

	horiz[1] = .26;
	horiz[2] = .26;
	horiz[3] = .25;
	horiz[4] = .25;
	horiz[5] = .25;
	horiz[6] = .25;
	horiz[7] = .25;
	horiz[8] = .25;
	horiz[9] = .25;
	horiz[10] = .25;
	horiz[11] = .25;
	horiz[12] = .15;
	horiz[13] = .13;
	vert[1] = 0.0;
	vert[2] = 0.025;
	vert[3] = 0.036;
	vert[4] = 0.037;
	vert[5] = 0.053;
	vert[6] = 0.072;
	vert[7] = 0.080;
	vert[8] = 0.100;
	vert[9] = 0.11;
	vert[10] = 0.15;
	vert[11] = 0.244;
	vert[12] = 0.238;
	vert[13] = 0.085;

	wait 2;
	i = 1;
	idir = 0;
	pshift = 0;
	yshift = 0;


	for(;;)
	{
		VMag = self.VaxisMag;
		YMag = self.YaxisMag;

		if(i >= 1 && i <= 13)
 		{
			pShift = horiz[i]*VMag;
			yShift = (0 - vert[i])*YMag;
		}
		else if(i >= 14 && i <= 26)
		{
			j = 14 - (i -13);
			pShift = (0 - horiz[j])*VMag;
			yShift = (0 - vert[j])*YMag;
		}
		else if(i >= 27 && i <= 39)
		{
			pShift = (0-horiz[i-26])*VMag;
			yShift = (vert[i-26])*YMag;
		}
		else if(i >= 40 && i <= 52)
		{
			j = 14 - (i -39);
			pShift = (horiz[j])*VMag;
			yShift = (vert[j])*YMag;
		}
		angles = self getplayerangles();
		self setPlayerAngles(angles + (pShift, yShift, 0));
		if(randomInt(50) == 0)
		{
			if(idir == 0) idir = 1;
			else idir = 0;
			i = i + 26;
		}
		if(idir == 0) i++;
		if(idir == 1) i--;
		if( i > 52) i = i - 52;
		if( i < 0) i = 52 - i;
		wait 0.05;
	}
}

convertHitLocation( sHitLoc )
{
// Better Names for hitloc
	switch( sHitLoc )
	{
		case "torso_upper":
			sHitLoc = &"OW_UPPER_TORSO";
			break;

		case "torso_lower":
			sHitLoc = &"OW_LOWER_TORSO";
			break;

		case "head":
			sHitLoc = &"OW_HEAD";
			break;

		case "neck":
			sHitLoc = &"OW_NECK";
			break;

		case "left_arm_upper":
		case "left_arm_lower":
		case "left_hand":
			sHitLoc = &"OW_LEFT_ARM";
			break;

		case "right_arm_upper":
		case "right_arm_lower":
		case "right_hand":
			sHitLoc = &"OW_RIGHT_ARM";
			break;

		case "left_leg_upper":
		case "left_leg_lower":
		case "left_foot":
			sHitLoc = &"OW_LEFT_LEG";
			break;

		case "right_leg_upper":
		case "right_leg_lower":
		case "right_foot":
			sHitLoc = &"OW_RIGHT_LEG";
			break;

		case "none":
			sHitLoc = &"OW_MASSIVE_INJURIES";
			break;

		case "bloodloss":
			sHitLoc = &"OW_BLOOD_LOSS";
			break;
	}

	return sHitLoc;
}


convertWeaponName( sWeapon )
{
	// Let's make the weapon's name shorter
	sWeaponShort = "";
	for ( i = 0; i < sWeapon.size; i++ ) {
		if ( sWeapon[i] != "_" ) {
			sWeaponShort += sWeapon[i];
		} else {
			break;
		}
	} 
	
	// Use the localized strings to get the name of the weapon
	switch( sWeaponShort ) {
		case "m16":
			sWeapon = &"WEAPON_M16";
			break;

		case "ak47":
			sWeapon = &"WEAPON_AK47";
			break;

		case "m4":
			sWeapon = &"WEAPON_M4";
			break;

		case "g3":
			sWeapon = &"WEAPON_G3";
			break;

		case "g36c":
			sWeapon = &"WEAPON_G36C";
			break;

		case "m14":
			sWeapon = &"WEAPON_M14";
			break;

		case "mp44_mp":
		case "mp44_single_mp":		
			sWeapon = &"WEAPON_MP44";
			break;

		case "mp5":
			sWeapon = &"WEAPON_MP5";
			break;

		case "skorpion":
			sWeapon = &"WEAPON_SKORPION";
			break;

		case "uzi":
			sWeapon = &"WEAPON_UZI";
			break;

		case "ak74u":
			sWeapon = "AK-74u";
			break;

		case "p90":
			sWeapon = &"WEAPON_P90";
			break;

		case "m1014":
			sWeapon = &"WEAPON_BENELLI";
			break;

		case "winchester1200":
			sWeapon = &"WEAPON_WINCHESTER1200";
			break;

		case "saw":
			sWeapon = &"WEAPON_SAW";
			break;

		case "rpd":
			sWeapon = &"WEAPON_RPD";
			break;

		case "m60e4":
			sWeapon = &"WEAPON_M60E4";
			break;

		case "dragunov":
			sWeapon = &"WEAPON_DRAGUNOV";
			break;

		case "m40a3":
			sWeapon = &"WEAPON_M40A3";
			break;

		case "barrett":
			sWeapon = &"WEAPON_BARRETT";
			break;

		case "remington700":
			sWeapon = &"WEAPON_REMINGTON700";
			break;

		case "m21":
			sWeapon = &"WEAPON_M21";
			break;

		case "beretta":
			sWeapon = &"WEAPON_BERETTA";
			break;

		case "colt45":
			sWeapon = &"WEAPON_COLT45";
			break;

		case "usp":
			sWeapon = &"WEAPON_USP";
			break;

		case "deserteagle":
		case "deserteaglegold":
			sWeapon = &"WEAPON_DESERTEAGLE";
			break;

		case "gl":
			sWeapon = &"WEAPON_GRENADE_LAUNCHER";
			break;

		case "frag":
			sWeapon = &"WEAPON_M2FRAGGRENADE";
			break;

		case "flash":
			sWeapon = &"WEAPON_FLASH_GRENADE";
			break;

		case "smoke":
			sWeapon = &"WEAPON_SMOKE_GRENADE";
			break;

		case "concussion":
			sWeapon = &"WEAPON_CONCUSSION_GRENADE";
			break;

		case "c4":
			sWeapon = &"WEAPON_C4";
			break;

		case "claymore":
			sWeapon = &"WEAPON_CLAYMORE";
			break;

		case "rpg":
			sWeapon = &"WEAPON_RPG_LAUNCHER";
			break;

		case "destructible":
			sWeapon = &"OW_DESTRUCTIBLE_CAR";
			break;

		case "knife":
			sWeapon = &"OW_KNIFE";
			break;

		case "explodable":
			sWeapon = &"OW_EXPLODING_BARREL";
			break;

		case "unknown":
			sWeapon = &"MP_UNKNOWN";
			break;

		case "cobra":
		case "hind":
			sWeapon = &"OW_HELICOPTER";
			break;

		case "artillery":
			sWeapon = &"OW_AIRSTRIKE";
			break;

		case "briefcase":
			sWeapon = &"OW_BOMB";
			break;
	}

	return sWeapon;
}


xWait( timeToWait )
{
	finishWait = openwarfare\_timer::getTimePassed() + timeToWait * 1000;

	while ( finishWait > openwarfare\_timer::getTimePassed() )
		wait (0.05);

	return;
}


getPlayerPrimaryWeapon()
{
	weaponsList = self getWeaponsList();
	for( idx = 0; idx < weaponsList.size; idx++ )
	{
		if ( maps\mp\gametypes\_weapons::isPrimaryWeapon( weaponsList[idx] ) ) {
			return weaponsList[idx];
		}
	}

	return "none";
}


shiftPlayerView( iDamage )
{
	if(iDamage == 0)
		return;
	// Make sure iDamage is between certain range
	if ( iDamage < 3 ) {
		iDamage = randomInt( 10 ) + 5;
	} else if ( iDamage > 45 ) {
		iDamage = 45;
	} else {
		iDamage = int( iDamage );
	}

	// Calculate how much the view will shift
	xShift = randomInt( iDamage ) - randomInt( iDamage );
	yShift = randomInt( iDamage ) - randomInt( iDamage );

	// Shift the player's view
	self setPlayerAngles( self.angles + (xShift, yShift, 0) );

	return;
}


weaponDrop()
{
	// Only allow to drop the weapon after the grace period has ended
	if ( !level.inGracePeriod ) {
		// Make sure it's a weapon they can drop
		currentWeapon = self getCurrentWeapon();

		if ( maps\mp\gametypes\_weapons::isPrimaryWeapon( currentWeapon ) || maps\mp\gametypes\_weapons::isPistol( currentWeapon ) ) {
			self dropItem( currentWeapon );
		}
	}

	return;
}


gameTypeDialog( gametype )
{
	// Add more detail to the type of game being played
	if ( level.scr_tactical == 1 ) {
		gametype += ";tactical";
	} else if ( level.oldschool == 1 ) {
		gametype += ";oldschool";
	} else if ( level.hardcoreMode == 1 ) {
		gametype += ";hardcore";
	}

	return gametype;
}


isSpectating()
{
   return ( self.pers["team"] == "spectator" );
}


rulesetDvar( varName, varValue )
{
	// Store the variable for in-game monitoring
	if ( !isDefined( level.dvarMonitor ) )
		level.dvarMonitor = [];

	// Set the variable value
	setDvar( varName, varValue );	
	
	// Store the new variable in the array
	newElement = level.dvarMonitor.size;
	level.dvarMonitor[newElement]["name"] = varName;
	level.dvarMonitor[newElement]["value"] = getDvar( varName );
}


forceClientDvar( varName, varValue )
{
	// Store the variable for in-game monitoring
	if ( !isDefined( level.forcedDvars ) )
		level.forcedDvars = [];

	// Store the new variable in the array
	newElement = level.forcedDvars.size;
	level.forcedDvars[newElement]["name"] = varName;
	level.forcedDvars[newElement]["value"] = varValue;
}


isPlayerClanMember( clanTags )
{
	// Search each tag in the player's name
	for ( tagx = 0; tagx < clanTags.size; tagx++ ) {
		if ( issubstr( self.name, clanTags[tagx] ) ) {
			return (1);
		}
	}

	return (0);
}


isPlayerNearTurret()
{
	// If turrets were removed then there's no way player can be next to one
	if ( level.scr_allow_stationary_turrets == 0 ) {
		return false;
	} else {
		// Classes for turrets (this way if something new comes out we just need to add an entry to the array)
		turretClasses = [];
		turretClasses[0] = "misc_turret";
		turretClasses[1] = "misc_mg42";
	
		// Cycle all the classes used by turrets
		for ( classix = 0; classix < turretClasses.size; classix++ )
		{
			// Get an array of entities for this class
			turretEntities = getentarray( turretClasses[ classix ], "classname" );
	
			// Cycle and check if the player is touching the trigger of the entity
			if ( isDefined ( turretEntities ) ) {
				for ( turretix = 0; turretix < turretEntities.size; turretix++ ) {
					if ( self isTouching( turretEntities[ turretix ] ) ) {
						return true;
					}
				}
			}
		}
		return false;
	}	
}


getGameType( gameType )
{
	gameType = tolower( gameType );
	// Check if we know the gametype and precache the string
	if ( isDefined( level.supportedGametypes[ gameType ] ) ) {
		gameType = level.supportedGametypes[ gameType ];
	}

	return gameType;
}


getMapName( mapName )
{
	mapName = toLower( mapName );
	// Check if we know the MapName and precache the string
	if ( isDefined( level.stockMapNames[ mapName ] ) ) {
		mapName = level.stockMapNames[ mapName ];
	} else if ( isDefined( level.customMapNames[ mapname ] ) ) {
		mapName = level.customMapNames[ mapName ];		
	}

	return mapName;
}


switchPlayerTeam( newTeam, halfTimeSwitch )
{
	if ( newTeam != self.pers["team"] && ( self.sessionstate == "playing" || self.sessionstate == "dead" ) )
	{
		self.switching_teams = true;
		self.joining_team = newTeam;
		self.leaving_team = self.pers["team"];
		self suicidePlayer();
	}

	// Change the player to the new team
	self.pers["team"] = newTeam;
	self.team = newTeam;
	self.pers["savedmodel"] = undefined;
	self.pers["teamTime"] = undefined;

	if ( level.teamBased ) {
		self.sessionteam = newTeam;
	} else {
		self.sessionteam = "none";
	}

	// Check if we need to enforce a class reset
	resetClass = self resetPlayerClassOnTeamSwitch( halfTimeSwitch );
	if ( resetClass ) {
		self.pers["weapon"] = undefined;
		self.pers["class"] = undefined;
		self.class = undefined;
		self.pers["spawnweapon"] = undefined;
	}
	
	self maps\mp\gametypes\_globallogic::updateObjectiveText();
	
	// Log in the system log the team switch
	lpselfnum = self getEntityNumber();
	lpselfname = self.name;
	lpselfteam = newTeam;
	lpselfguid = self getGuid();
	logPrint( "JT;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + "\n" );	
	
	// Notify other modules about the team switch
	self notify("joined_team");
	if ( !halfTimeSwitch ) {
		self thread maps\mp\gametypes\_globallogic::showPlayerJoinedTeam();
	}
	self notify("end_respawn");

	if ( resetClass ) {
		self maps\mp\gametypes\_globallogic::beginClassChoice();
		self setclientdvar( "g_scriptMainMenu", game[ "menu_class_" + self.pers["team"] ] );
	}
}


resetPlayerClassOnTeamSwitch( halfTimeSwitch )
{
	// If the server is ranked there's no need to reset
	if ( level.rankedMatch || !isDefined( self.pers["class"] ) )
		return false;
		
	// Check non-class dependent limits
	if ( isDefined( self.specialty ) && isDefined ( self.specialty[0] ) ) {
		if ( !halfTimeSwitch && game["perk_c4_mp_limit"] != 0 && game["perk_c4_mp_limit"] != 64 && self.specialty[0] == "c4_mp" )
			return true;
		if ( !halfTimeSwitch && game["perk_rpg_mp_limit"] != 0 && game["perk_rpg_mp_limit"] != 64 && self.specialty[0] == "rpg_mp" )
			return true;		
		if ( !halfTimeSwitch && game["perk_claymore_mp_limit"] != 0 && game["perk_claymore_mp_limit"] != 64 && self.specialty[0] == "claymore_mp" )
			return true;	
	}
	if ( !halfTimeSwitch && game["smoke_grenade_limit"] != 0 && game["smoke_grenade_limit"] != 64 && self.pers[self.pers["class"]]["loadout_grenade"] == "smoke_grenade" )
		return true;		
		
				
	// Check class dependent limits
	switch ( self.pers["class"] ) {
		case "assault":
			if ( ( !halfTimeSwitch && game[ self.team + "_assault_limit"] != 0 && game[ self.team + "_assault_limit"] != 64 ) || ( halfTimeSwitch && game[ "allies_assault_limit"] != game[ "axis_assault_limit"] ) )
				return true;
				
			if ( !halfTimeSwitch && game["attach_assault_gl_limit"] != 0 && game["attach_assault_gl_limit"] != 64 && self.pers["assault"]["loadout_primary_attachment"] == "gl" )
				return true;
			break;
			
		case "specops":
			if ( ( !halfTimeSwitch && game[ self.team + "_specops_limit"] != 0 && game[ self.team + "_specops_limit"] != 64 ) || ( halfTimeSwitch && game[ "allies_specops_limit"] != game[ "axis_specops_limit"] ) )
				return true;			
			break;
			
		case "heavygunner":
			if ( ( !halfTimeSwitch && game[ self.team + "_heavygunner_limit"] != 0 && game[ self.team + "_heavygunner_limit"] != 64 ) || ( halfTimeSwitch && game[ "allies_heavygunner_limit"] != game[ "axis_heavygunner_limit"] ) )
				return true;			
			break;
			
		case "demolitions":
			if ( ( !halfTimeSwitch && game[ self.team + "_demolitions_limit"] != 0 && game[ self.team + "_demolitions_limit"] != 64 ) || ( halfTimeSwitch && game[ "allies_demolitions_limit"] != game[ "axis_demolitions_limit"] ) )
				return true;			
			break;
			
		case "sniper":
			if ( ( !halfTimeSwitch && game[ self.team + "_sniper_limit"] != 0 && game[ self.team + "_sniper_limit"] != 64 ) || ( halfTimeSwitch && game[ "allies_sniper_limit"] != game[ "axis_sniper_limit"] ) )
				return true;			
			break;
	}
	
	return false;	
}


waitAndSendEvent( timeToWait, eventToSend )
{
	self endon( eventToSend );
	
	xWait(timeToWait );
	self notify( eventToSend );	
}


suicidePlayer()
{
	if ( level.gametype != "hns" || self.pers["team"] == game["attackers"] ) {
		self suicide();
	} else {
		self maps\mp\gametypes\hns::killPropOwner( undefined, self, 0, undefined, "MOD_SUICIDE", "none", (0,0,0), (0,0,0), "torso_upper", gettime() );
	}	
}


serverHideHUD()
{
	setDvar( "ui_hud_hardcore", 1 );
	setDvar( "ui_hud_hardcore_show_minimap", 0 );
	setDvar( "ui_hud_hardcore_show_compass", 0 );
	setDvar( "ui_hud_show_inventory", 0 );	
}


serverShowHUD()
{
	setDvar( "ui_hud_hardcore", level.hardcoreMode );
	setDvar( "ui_hud_hardcore_show_minimap", level.scr_hud_hardcore_show_minimap );
	setDvar( "ui_hud_hardcore_show_compass", level.scr_hud_hardcore_show_compass );
	setDvar( "ui_hud_show_inventory", level.scr_hud_show_inventory );	
}


hideHUD()
{
	self setClientDvars(
		"ui_hud_hardcore", 1,
		"cg_drawSpectatorMessages", 0,
		"g_compassShowEnemies", 0,
		"ui_hud_hardcore_show_minimap", 0,
		"ui_hud_hardcore_show_compass", 0,
		"ui_hud_show_inventory", 0
	);
}


showHUD()
{
	self setClientDvars(
		"ui_hud_hardcore", level.hardcoreMode,
		"cg_drawSpectatorMessages", 1,
		"ui_hud_hardcore_show_minimap", level.scr_hud_hardcore_show_minimap,
		"ui_hud_hardcore_show_compass", level.scr_hud_hardcore_show_compass,
		"ui_hud_show_inventory", level.scr_hud_show_inventory
	);
}


getLastAlivePlayer()
{
	winner = undefined;
	
	for ( index = 0; index < level.players.size; index++ ) {
		player = level.players[index];
		
		if ( !isDefined( player ) || !isDefined( player.pers ) || player.pers["team"] == "spectator" )
			continue;
			
		if ( ( player.sessionstate == "dead" || player.sessionstate == "spectator" ) && ( player.pers["lives"] == 0 || !player.hasSpawned ) )
			continue;
			
		winner = player;
		break;		
	}

	return winner;
}