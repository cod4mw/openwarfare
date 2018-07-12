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
	game["menu_ow_cac_editor"] = "ow_cac_editor";
	precacheMenu( game["menu_ow_cac_editor"] );
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnected()
{
	self thread cacResponseHandler();
}

cacResponseHandler()
{
	self endon( "disconnect" );
	
	for(;;)
	{
		self waittill( "menuresponse", menu, response );
		
		if ( menu == "class" && response == "ow_cac_editor" ) {
			self openAllClasses();
			self initializeEditor();
			self openMenu( game["menu_ow_cac_editor"] );
		}			
		
		if ( menu == game["menu_ow_cac_editor"] )
		{
			//Restart loop if custom classes aren't unlocked. 
			//The class can be unlocked in game so we still 
			//want to give player the ability to edit their class.
			if ( self getStat( 260 ) > 0 )
			{
				switch( response )
				{		
					case "open": 
						self initializeEditor();
						self openAllClasses();
						self openMenu( game["menu_ow_cac_editor"] );
						break;	
					case "cacClassNext":
						self class( "next" );
						break;
					case "cacClassPrev":
						self class( "prev" );
						break;					
					case "cacPrimaryNext":
						self primary( "next" );
						break;
					case "cacPrimaryPrev":
						self primary( "prev" );
						break;
					case "cacSecondaryNext":
						self secondary( "next" );
						break;
					case "cacSecondaryPrev":
						self secondary( "prev" );
						break;	
					case "cacPAttachmentNext":
						self primaryAttachment( "next" );
						break;
					case "cacPAttachmentPrev":
						self primaryAttachment( "prev" );
						break;	
					case "cacSAttachmentNext":
						self secondaryAttachment( "next" );
						break;
					case "cacSAttachmentPrev":
						self secondaryAttachment( "prev" );
						break;
					case "cacPerk1Next":
						self perk1( "next" );
						break;	
					case "cacPerk1Prev":
						self perk1( "prev" );
						break;	
					case "cacPerk2Next":
						self perk2( "next" );
						break;
					case "cacPerk2Prev":
						self perk2( "prev" );
						break;	
					case "cacPerk3Next":
						self perk3( "next" );
						break;	
					case "cacPerk3Prev":
						self perk3( "prev" );
						break;	
					case "cacSGrenadeNext":
						self specialGrenade( "next" );
						break;
					case "cacSGrenadePrev":
						self specialGrenade( "prev" );
						break;	
					case "cacCamoNext":
						self camo( "next" );
						break;
					case "cacCamoPrev":
						self camo( "prev" );
						break;	
					case "cacSubmit":
						self submitUpdate();
						break;
				}		
			}
		}
	}
}

initializeEditor()
{
	//Set up arrays and starting indexes
	self.classesIndex = 0;
	self.primariesIndex = 0;
	self.primaries2Index = 0;
	self.pattachmentsIndex = 0;
	self.pattachments2Index = 0;
	self.secondariesIndex = 0;
	self.sattachmentsIndex = 0;
	self.perk1Index = 0;
	self.perk2Index = 0;
	self.perk3Index = 0;
	self.sgrenadesIndex = 0;
	self.camosIndex = 0;
	self.cacEdit_classes = [];
	self.cacEdit_primaries = [];
	self.cacEdit_pattachments = [];
	self.cacEdit_secondaries = [];
	self.cacEdit_sattachments = [];
	self.cacEdit_perk1 = [];
	self.cacEdit_perk2 = [];
	self.cacEdit_perk3 = [];
	self.cacEdit_sgrenades = [];
	self.cacEdit_camos = [];
	
	//For Overkill
	self.isUsingOverkill = false;
	
	//Add data to arrays
	self addClasses();
	self addPrimaries();
	self addPrimaryAttachments();
	self addSecondaries();
	self addSecondaryAttachments();
	self addPerk1();
	self addPerk2();
	self addPerk3();
	self addSGrenades();
	self addCamos();
	
	//On startup this will display customclass1
	self displayDefaultLoadout();
}

displayDefaultLoadout()
{
	//Class name
	self setClientDvar( "ow_cac_class", self.cacEdit_classes[self.classesIndex].text );
	
	//Get current class' stats
	def_primary = self getStat( self.cacEdit_classes[self.classesIndex].stat + 1 );
	def_pattach = self getStat( self.cacEdit_classes[self.classesIndex].stat + 2 );
	def_secondary = self getStat( self.cacEdit_classes[self.classesIndex].stat + 3 );
	def_sattach = self getStat( self.cacEdit_classes[self.classesIndex].stat + 4 );
	def_perk1 = self getStat( self.cacEdit_classes[self.classesIndex].stat + 5 );
	def_perk2 = self getStat( self.cacEdit_classes[self.classesIndex].stat + 6 );
	def_perk3 = self getStat( self.cacEdit_classes[self.classesIndex].stat + 7 );
	def_sgrenade = self getStat( self.cacEdit_classes[self.classesIndex].stat + 8 );
	def_camo = self getStat( self.cacEdit_classes[self.classesIndex].stat + 9 );
	
	//Check if class is using overkill
	if ( def_perk2 == 166 )
		self.isUsingOverkill = true;
	else
		self.isUsingOverkill = false;
	
	//Set default primary index
	for ( i = 0; i < self.cacEdit_primaries.size; i++ )
	{
		if ( self.cacEdit_primaries[i].stat == def_primary )
		{
			self.primariesIndex = i;
			self setClientDvar( "ow_cac_stat_primary", def_primary );
			break;
		}
	}
	//Set default primary attachment index
	for ( i = 0; i < self.cacEdit_pattachments.size; i++ )
	{
		if ( self.cacEdit_pattachments[i].stat == def_pattach )
		{
			self.pattachmentsIndex = i;
			self setClientDvar( "ow_cac_stat_pattachment", def_pattach );
			break;
		}
	}
	//Set default secondary index
	if ( !self.isUsingOverkill )
	{
		for ( i = 0; i < self.cacEdit_secondaries.size; i++ )
		{
			if ( self.cacEdit_secondaries[i].stat == def_secondary )
			{
				self.secondariesIndex = i;
				self setClientDvar( "ow_cac_stat_secondary", def_secondary );
				break;
			}
		}
	}
	else
	{
		for ( i = 0; i < self.cacEdit_primaries.size; i++ )
		{
			if ( self.cacEdit_primaries[i].stat == def_secondary )
			{
				self.primaries2Index = i;
				self setClientDvar( "ow_cac_stat_secondary", def_secondary );
				break;
			}
		}
	}
	//Set default secondary attachment index
	if ( !self.isUsingOverkill )
	{
		for ( i = 0; i < self.cacEdit_sattachments.size; i++ )
		{
			if ( self.cacEdit_sattachments[i].stat == def_sattach )
			{
				self.sattachmentsIndex = i;
				self setClientDvar( "ow_cac_stat_sattachment", def_sattach );
				break;
			}
		}
	}
	else
	{
		for ( i = 0; i < self.cacEdit_pattachments.size; i++ )
		{
			if ( self.cacEdit_pattachments[i].stat == def_sattach )
			{
				self.pattachments2Index = i;
				self setClientDvar( "ow_cac_stat_sattachment", def_sattach );
				break;
			}
		}		
	}
	//Set default perk1 index
	for ( i = 0; i < self.cacEdit_perk1.size; i++ )
	{
		if ( self.cacEdit_perk1[i].stat == def_perk1 )
		{
			self.perk1Index = i;
			self setClientDvar( "ow_cac_stat_perk1", def_perk1 );
			break;
		}
		else if ( def_perk1 == 190 || def_perk1 == 191 || def_perk1 == 192 || def_perk1 == 193 )
		{
			self.perk1Index = -1;
			self setClientDvar( "ow_cac_stat_perk1", def_perk1 );
			break;
		}
	}
	//Set default perk2 index
	for ( i = 0; i < self.cacEdit_perk2.size; i++ )
	{
		if ( self.cacEdit_perk2[i].stat == def_perk2 )
		{
			self.perk2Index = i;
			self setClientDvar( "ow_cac_stat_perk2", def_perk2 );
			break;
		}
	}
	//Set default perk3 index
	for ( i = 0; i < self.cacEdit_perk3.size; i++ )
	{
		if ( self.cacEdit_perk3[i].stat == def_perk3 )
		{
			self.perk3Index = i;
			self setClientDvar( "ow_cac_stat_perk3", def_perk3 );
			break;
		}
	}
	//Set default special grenade index
	for ( i = 0; i < self.cacEdit_sgrenades.size; i++ )
	{
		if ( self.cacEdit_sgrenades[i].stat == def_sgrenade )
		{
			self.sgrenadesIndex = i;
			self setClientDvar( "ow_cac_stat_sgrenade", def_sgrenade );
			break;
		}
	}
	//Set default camo index
	for ( i = 0; i < self.cacEdit_camos.size; i++ )
	{
		if ( self.cacEdit_camos[i].stat == def_camo )
		{
			self.camosIndex = i;
			self setClientDvar( "ow_cac_stat_camo", def_camo );
			break;
		}
	}
}

class( direction )
{
	if ( direction == "next" )
		self.classesIndex++;
	else
		self.classesIndex--;
		
	if ( self.classesIndex < 0 )
		self.classesIndex = self.cacEdit_classes.size - 1;
	else if ( self.classesIndex >= self.cacEdit_classes.size )
		self.classesIndex = 0;
		
	self displayDefaultLoadout();	
}

primary( direction )
{
	if ( direction == "next" )
		self.primariesIndex++;
	else
		self.primariesIndex--;
		
	if ( self.primariesIndex < 0 )
		self.primariesIndex = self.cacEdit_primaries.size - 1;
	else if ( self.primariesIndex >= self.cacEdit_primaries.size )
		self.primariesIndex = 0;	
		
	weapon_stat = self getStat( self.cacEdit_primaries[self.primariesIndex].stat + 3000 );
	while ( weapon_stat < 1 || ( self.isUsingOverkill && ( self.cacEdit_primaries[self.primariesIndex].stat == self.cacEdit_primaries[self.primaries2Index].stat ) ) )
	{
		if ( direction == "next" )
			self.primariesIndex++;
		else
			self.primariesIndex--;
		
		if ( self.primariesIndex < 0 )
			self.primariesIndex = self.cacEdit_primaries.size - 1;
		else if ( self.primariesIndex >= self.cacEdit_primaries.size )
			self.primariesIndex = 0;

		weapon_stat = self getStat( self.cacEdit_primaries[self.primariesIndex].stat + 3000 );
	}

	//Display new weapon
	self.pattachmentsIndex = 0;
	self.camosIndex = 0;
	if ( self.perk1Index == -1 && ( self.pattachments2Index != 1 && self.pattachments2Index != 5 ) )
		self setClientDvar( "ow_cac_stat_perk1", 190 );
	self setClientDvar( "ow_cac_stat_primary", self.cacEdit_primaries[self.primariesIndex].stat );
	self setClientDvar( "ow_cac_stat_pattachment", self.cacEdit_pattachments[self.pattachmentsIndex].stat );
	self setClientDvar( "ow_cac_stat_camo", self.cacEdit_camos[self.camosIndex].stat );	
}

primaryAttachment( direction )
{
	if ( direction == "next" )
		self.pattachmentsIndex++;
	else
		self.pattachmentsIndex--;
		
	if ( self.pattachmentsIndex < 0 )
		self.pattachmentsIndex = self.cacEdit_pattachments.size - 1;
	else if ( self.pattachmentsIndex >= self.cacEdit_pattachments.size )
		self.pattachmentsIndex = 0;
	
	//We have to check to make sure the camo is unlocked for this weapon
	addonMask = int( tableLookup( "mp/attachmenttable.csv", 9, self.cacEdit_pattachments[self.pattachmentsIndex].stat, 10 ) );
	weaponStat = self getStat( self.cacEdit_primaries[self.primariesIndex].stat + 3000 );
	while( ( int(weaponStat) & addonMask ) == 0 )
	{
		if ( direction == "next" )
			self.pattachmentsIndex++;
		else
			self.pattachmentsIndex--;
		
		if ( self.pattachmentsIndex < 0 )
			self.pattachmentsIndex = self.cacEdit_pattachments.size - 1;
		else if ( self.pattachmentsIndex >= self.cacEdit_pattachments.size )
			self.pattachmentsIndex = 0;

		addonMask = int( tableLookup( "mp/attachmenttable.csv", 9, self.cacEdit_pattachments[self.pattachmentsIndex].stat, 10 ) );
	}	
	
	//Perk 1 Hack
	if ( self.pattachmentsIndex == 1 || self.pattachmentsIndex == 5 )
	{
		self.perk1Index = -1;
		self setClientDvar( "ow_cac_stat_perk1", 193 );
	}
	else if ( self.pattachmentsIndex != 1 && self.pattachmentsIndex != 5 && self.pattachments2Index != 1 && self.pattachments2Index != 5 )
	{
		if ( self.perk1Index == -1 )
			self setClientDvar( "ow_cac_stat_perk1", 190 );
	}
	
	//Display new attachment
	self setClientDvar( "ow_cac_stat_pattachment", self.cacEdit_pattachments[self.pattachmentsIndex].stat );		
}

secondary( direction )
{
	if ( !self.isUsingOverkill )
	{
		if ( direction == "next" )
			self.secondariesIndex++;
		else
			self.secondariesIndex--;
		
		if ( self.secondariesIndex < 0 )
			self.secondariesIndex = self.cacEdit_secondaries.size - 1;
		else if ( self.secondariesIndex >= self.cacEdit_secondaries.size )
			self.secondariesIndex = 0;
			
		weapon_stat = self getStat( self.cacEdit_secondaries[self.secondariesIndex].stat + 3000 );
		while ( weapon_stat < 1 )
		{
			if ( direction == "next" )
				self.secondariesIndex++;
			else
				self.secondariesIndex--;
		
			if ( self.secondariesIndex < 0 )
				self.secondariesIndex = self.cacEdit_secondaries.size - 1;
			else if ( self.secondariesIndex >= self.cacEdit_secondaries.size )
				self.secondariesIndex = 0;
				
			weapon_stat = self getStat( self.cacEdit_secondaries[self.secondariesIndex].stat + 3000 );
		}

		//Display new weapon
		self.sattachmentsIndex = 0;
		self setClientDvar( "ow_cac_stat_sattachment", self.cacEdit_sattachments[self.sattachmentsIndex].stat );
		self setClientDvar( "ow_cac_stat_secondary", self.cacEdit_secondaries[self.secondariesIndex].stat );
	}
	else
	{
		if ( direction == "next" )
			self.primaries2Index++;
		else
			self.primaries2Index--;
		
		if ( self.primaries2Index < 0 )
			self.primaries2Index = self.cacEdit_primaries.size - 1;
		else if ( self.primaries2Index >= self.cacEdit_primaries.size )
			self.primaries2Index = 0;
			
		weapon_stat = self getStat( self.cacEdit_primaries[self.primaries2Index].stat + 3000 );
		while ( weapon_stat < 1 || ( self.cacEdit_primaries[self.primariesIndex].stat == self.cacEdit_primaries[self.primaries2Index].stat ) )
		{
			if ( direction == "next" )
				self.primaries2Index++;
			else
				self.primaries2Index--;
		
			if ( self.primaries2Index < 0 )
				self.primaries2Index = self.cacEdit_primaries.size - 1;
			else if ( self.primaries2Index >= self.cacEdit_primaries.size )
				self.primaries2Index = 0;
				
			weapon_stat = self getStat( self.cacEdit_primaries[self.primaries2Index].stat + 3000 );
		}	
		//Display new weapon
		self.pattachments2Index = 0;
		if ( self.perk1Index == -1 && ( self.pattachmentsIndex != 1 && self.pattachmentsIndex != 5 ) )
			self setClientDvar( "ow_cac_stat_perk1", 190 );
		self setClientDvar( "ow_cac_stat_secondary", self.cacEdit_primaries[self.primaries2Index].stat );
		self setClientDvar( "ow_cac_stat_sattachment", self.cacEdit_pattachments[self.pattachments2Index].stat );
	}
}

secondaryAttachment( direction )
{
	if ( !self.isUsingOverkill )
	{
		if ( direction == "next" )
			self.sattachmentsIndex++;
		else
			self.sattachmentsIndex--;
		
		if ( self.sattachmentsIndex < 0 )
			self.sattachmentsIndex = self.cacEdit_sattachments.size - 1;
		else if ( self.sattachmentsIndex >= self.cacEdit_sattachments.size )
			self.sattachmentsIndex = 0;
			
		addonMask = int( tableLookup( "mp/attachmenttable.csv", 9, self.cacEdit_sattachments[self.sattachmentsIndex].stat, 10 ) );
		weaponStat = self getStat( self.cacEdit_secondaries[self.secondariesIndex].stat + 3000 );
		while( ( int(weaponStat) & addonMask ) == 0 )
		{
			if ( direction == "next" )
				self.sattachmentsIndex++;
			else
				self.sattachmentsIndex--;
		
			if ( self.sattachmentsIndex < 0 )
			self.sattachmentsIndex = self.cacEdit_sattachments.size - 1;
			else if ( self.sattachmentsIndex >= self.cacEdit_sattachments.size )
				self.sattachmentsIndex = 0;
				
			addonMask = int( tableLookup( "mp/attachmenttable.csv", 9, self.cacEdit_sattachments[self.sattachmentsIndex].stat, 10 ) );
		}

		//Desert Eagle Stuff	
		if ( self.secondariesIndex == 3 || self.secondariesIndex == 4 )
			self.sattachmentsIndex = 0;
		
		//Display new attachment
		self setClientDvar( "ow_cac_stat_sattachment", self.cacEdit_sattachments[self.sattachmentsIndex].stat );
	}
	else
	{
		if ( direction == "next" )
			self.pattachments2Index++;
		else
			self.pattachments2Index--;
		
		if ( self.pattachments2Index < 0 )
			self.pattachments2Index = self.cacEdit_pattachments.size - 1;
		else if ( self.pattachments2Index >= self.cacEdit_pattachments.size )
			self.pattachments2Index = 0;
			
		//We have to check to make sure the camo is unlocked for this weapon
		addonMask = int( tableLookup( "mp/attachmenttable.csv", 9, self.cacEdit_pattachments[self.pattachments2Index].stat, 10 ) );
		weaponStat = self getStat( self.cacEdit_primaries[self.primaries2Index].stat + 3000 );
		while( ( int(weaponStat) & addonMask ) == 0 )
		{
			if ( direction == "next" )
				self.pattachments2Index++;
			else
				self.pattachments2Index--;
		
			if ( self.pattachments2Index < 0 )
				self.pattachments2Index = self.cacEdit_pattachments.size - 1;
			else if ( self.pattachments2Index >= self.cacEdit_pattachments.size )
				self.pattachments2Index = 0;
				
			addonMask = int( tableLookup( "mp/attachmenttable.csv", 9, self.cacEdit_pattachments[self.pattachments2Index].stat, 10 ) );
		}	
		
		//Perk 1 Hack
		if ( self.pattachments2Index == 1 || self.pattachments2Index == 5 )
		{
			self.perk1Index = -1;
			self setClientDvar( "ow_cac_stat_perk1", 193 );
		}
		else if ( self.pattachmentsIndex != 1 && self.pattachmentsIndex != 5 && self.pattachments2Index != 1 && self.pattachments2Index != 5 )
		{
			if ( self.perk1Index == -1 )
				self setClientDvar( "ow_cac_stat_perk1", 190 );
		}
	
		//Display new attachment
		self setClientDvar( "ow_cac_stat_sattachment", self.cacEdit_pattachments[self.pattachments2Index].stat );
	}
}

perk1( direction )
{
	if ( direction == "next" )
		self.perk1Index++;
	else
		self.perk1Index--;
		
	if ( self.perk1Index < 0 )
		self.perk1Index = self.cacEdit_perk1.size - 1;
	else if ( self.perk1Index >= self.cacEdit_perk1.size )
		self.perk1Index = 0;
		
	while ( self getStat( self.cacEdit_perk1[self.perk1Index].stat ) < 1 || ( self.sgrenadesIndex == 2 && self.cacEdit_perk1[self.perk1Index].stat == 176 ) )
	{
		if ( direction == "next" )
			self.perk1Index++;
		else
			self.perk1Index--;
		
		if ( self.perk1Index < 0 )
			self.perk1Index = self.cacEdit_perk1.size - 1;
		else if ( self.perk1Index >= self.cacEdit_perk1.size )
			self.perk1Index = 0;
	}

	//Weapon Attachment Hack
	if ( self.pattachmentsIndex == 1 || self.pattachmentsIndex == 5 || self.pattachments2Index == 1 || self.pattachments2Index == 5 ) 
	{
		self.perk1Index = -1; 
		self setClientDvar( "ow_cac_stat_perk1", 193 );
	}
	
	//Display new perk
	if ( self.perk1Index != -1 )
	{
		self setClientDvar( "ow_cac_stat_perk1", self.cacEdit_perk1[self.perk1Index].stat );
	}	
}

perk2( direction )
{
	if ( direction == "next" )
		self.perk2Index++;
	else
		self.perk2Index--;
		
	if ( self.perk2Index < 0 )
		self.perk2Index = self.cacEdit_perk2.size - 1;
	else if ( self.perk2Index >= self.cacEdit_perk2.size )
		self.perk2Index = 0;
		
	while ( self getStat( self.cacEdit_perk2[self.perk2Index].stat ) < 1 )
	{
		if ( direction == "next" )
			self.perk2Index++;
		else
			self.perk2Index--;
		
		if ( self.perk2Index < 0 )
			self.perk2Index = self.cacEdit_perk2.size - 1;
		else if ( self.perk2Index >= self.cacEdit_perk2.size )
			self.perk2Index = 0;
	}

	//Overkill Hack
	if ( self.cacEdit_perk2[self.perk2Index].stat == 166 )
	{
		self.isUsingOverkill = true;
		if ( self.cacEdit_primaries[self.primariesIndex].stat == 25 )
		{
			self.primaries2Index = 1; //Ak47
			self.pattachments2Index = 0;
			self.sattachmentsIndex = 0;
			self setClientDvar( "ow_cac_stat_secondary", self.cacEdit_primaries[self.primaries2Index].stat );
			self setClientDvar( "ow_cac_stat_sattachment", self.cacEdit_pattachments[self.pattachments2Index].stat );
		}
		else 
		{
			self.primaries2Index = 0; //M16
			self.pattachments2Index = 0;
			self.sattachmentsIndex = 0;			
			self setClientDvar( "ow_cac_stat_secondary", self.cacEdit_primaries[self.primaries2Index].stat );
			self setClientDvar( "ow_cac_stat_sattachment", self.cacEdit_pattachments[self.pattachments2Index].stat );			
		}
	}
	else if ( self.cacEdit_perk2[self.perk2Index].stat != 166 && self.isUsingOverkill )
	{
		self.isUsingOverkill = false;
		self.primaries2Index = 0;
		self.secondaryIndex = 0;
		self.sattachmentsIndex = 0;
		self setClientDvar( "ow_cac_stat_secondary", self.cacEdit_secondaries[self.secondariesIndex].stat );
		self setClientDvar( "ow_cac_stat_sattachment", self.cacEdit_sattachments[self.sattachmentsIndex].stat );
	}
	
	//Display new perk
	self setClientDvar( "ow_cac_stat_perk2", self.cacEdit_perk2[self.perk2Index].stat );	
}

perk3( direction )
{
	if ( direction == "next" )
		self.perk3Index++;
	else
		self.perk3Index--;
		
	if ( self.perk3Index < 0 )
		self.perk3Index = self.cacEdit_perk3.size - 1;
	else if ( self.perk3Index >= self.cacEdit_perk3.size )
		self.perk3Index = 0;	
		
	while ( self getStat( self.cacEdit_perk3[self.perk3Index].stat ) < 1 )
	{
		if ( direction == "next" )
			self.perk3Index++;
		else
			self.perk3Index--;
		
		if ( self.perk3Index < 0 )
			self.perk3Index = self.cacEdit_perk3.size - 1;
		else if ( self.perk3Index >= self.cacEdit_perk3.size )
			self.perk3Index = 0;
	}

	//Display new perk
	self setClientDvar( "ow_cac_stat_perk3", self.cacEdit_perk3[self.perk3Index].stat );	
}

specialGrenade( direction )
{
	if ( direction == "next" )
		self.sgrenadesIndex++;
	else
		self.sgrenadesIndex--;
		
	if ( self.sgrenadesIndex < 0 )
		self.sgrenadesIndex = self.cacEdit_sgrenades.size - 1;
	else if ( self.sgrenadesIndex >= self.cacEdit_sgrenades.size )
		self.sgrenadesIndex = 0;
		
	//Smoke Hack
	if ( self.sgrenadesIndex == 2 && ( self.perk1Index != -1 && self.cacEdit_perk1[self.perk1Index].stat == 176 ) )
	{
		self.perk1Index = -1;
		self setClientDvar( "ow_cac_stat_perk1", 190 );
	}
	
	//Display new grenade
	self setClientDvar( "ow_cac_stat_sgrenade", self.cacEdit_sgrenades[self.sgrenadesIndex].stat );	
}

camo( direction )
{
	if ( direction == "next" )
		self.camosIndex++;
	else
		self.camosIndex--;
		
	if ( self.camosIndex < 0 )
		self.camosIndex = self.cacEdit_camos.size - 1;
	else if ( self.camosIndex >= self.cacEdit_camos.size )
		self.camosIndex = 0;
		
	addonMask = int( tableLookup( "mp/attachmenttable.csv", 11, self.cacEdit_camos[self.camosIndex].stat, 10 ) );
	weaponStat = self getStat( self.cacEdit_primaries[self.primariesIndex].stat + 3000 );	
	while( ( int(weaponStat) & addonMask ) == 0 )
	{
		if ( direction == "next" )
			self.camosIndex++;
		else
			self.camosIndex--;
		
		if ( self.camosIndex < 0 )
			self.camosIndex = self.cacEdit_camos.size - 1;
		else if ( self.camosIndex >= self.cacEdit_camos.size )
			self.camosIndex = 0;
			
		addonMask = int( tableLookup( "mp/attachmenttable.csv", 11, self.cacEdit_camos[self.camosIndex].stat, 10 ) );
	}	
	
	//Display new camo
	self setClientDvar( "ow_cac_stat_camo", self.cacEdit_camos[self.camosIndex].stat );
}

submitUpdate()
{
	class_offset = self.cacEdit_classes[self.classesIndex].stat; //Custom Class

	self setStat( class_offset + 1, self.cacEdit_primaries[self.primariesIndex].stat ); //Primary Weapon
	self setStat( class_offset + 2, self.cacEdit_pattachments[self.pattachmentsIndex].stat ); //Primary Attachment
	if ( self.cacEdit_perk2[self.perk2Index].stat != 166 )
	{
		self setStat( class_offset + 3, self.cacEdit_secondaries[self.secondariesIndex].stat ); //Secondary Weapon
		self setStat( class_offset + 4, self.cacEdit_sattachments[self.sattachmentsIndex].stat ); //Secondary Attachment
	}
	else
	{
		self setStat( class_offset + 3, self.cacEdit_primaries[self.primaries2Index].stat ); //Secondary Weapon (When Overkill)
		self setStat( class_offset + 4, self.cacEdit_pattachments[self.pattachments2Index].stat ); //Secondary Attachment (When Overkill)
	}
	if ( self.perk1Index != -1 )
		self setStat( class_offset + 5, self.cacEdit_perk1[self.perk1Index].stat ); //Perk 1 
	else if ( self.pattachmentsIndex == 1 || self.pattachments2Index == 1 || self.pattachmentsIndex == 5 || self.pattachments2Index == 5 )
		self setStat( class_offset + 5, 193 ); //Perk 1
	else if ( self.sgrenadesIndex == 2 && ( self.perk1Index != -1 && self.cacEdit_perk1[self.perk1Index].stat == 176 ) )
		self setStat( class_offset + 5, 190 ); //Perk 1
	
	self setStat( class_offset + 6, self.cacEdit_perk2[self.perk2Index].stat ); //Perk 2
	self setStat( class_offset + 7, self.cacEdit_perk3[self.perk3Index].stat ); //Perk 3
	self setStat( class_offset + 8, self.cacEdit_sgrenades[self.sgrenadesIndex].stat ); //Special Grenade
	self setStat( class_offset + 9, self.cacEdit_camos[self.camosIndex].stat ); //Camo	
	
	self.cac_initialized = undefined;
}

addClasses()
{
	//Add classes ( name, class_stat )
	self addCACClasses( "customclass1", 200 ); //Custom class 1
	self addCACClasses( "customclass2", 210 ); //Custom class 2
	self addCACClasses( "customclass3", 220 ); //Custom class 3
	self addCACClasses( "customclass4", 230 ); //Custom class 4
	self addCACClasses( "customclass5", 240 ); //Custom class 5
}
	

addPrimaries()
{
	//Add Primaries ( label, weapon_stat )
	//Assault Weapons
	self addCACPrimaries( "assault", 25 ); //M16
	self addCACPrimaries( "assault", 20 ); //AK47
	self addCACPrimaries( "assault", 26 ); //M4 Carbine
	self addCACPrimaries( "assault", 23 ); //G3
	self addCACPrimaries( "assault", 24 ); //G36C
	self addCACPrimaries( "assault", 21 ); //M14
	self addCACPrimaries( "assault", 22 ); //MP44
	//Sub-Machine Weapons
	self addCACPrimaries( "smg", 10 ); //MP5
	self addCACPrimaries( "smg", 11 ); //Skorpion
	self addCACPrimaries( "smg", 12 ); //UZI
	self addCACPrimaries( "smg", 13 ); //AK74U
	self addCACPrimaries( "smg", 14 ); //P90
	//Heavy Weapons
	self addCACPrimaries( "heavy", 81 ); //SAW
	self addCACPrimaries( "heavy", 80 ); //RPD
	self addCACPrimaries( "heavy", 82 ); //M60E4
	//Shotgun Weapons
	self addCACPrimaries( "shotgun", 71 ); //Winchester
	self addCACPrimaries( "shotgun", 70 ); //Benelli
	//Sharpshooter Weapons
	self addCACPrimaries( "sniper", 61 ); //M40A3
	self addCACPrimaries( "sniper", 65 ); //M21
	self addCACPrimaries( "sniper", 60 ); //Dragunov
	self addCACPrimaries( "sniper", 64 ); //Remington700
	self addCACPrimaries( "sniper", 62 ); //Barrett	
}

addPrimaryAttachments() 
{
	//Add Primary Attachments ( attachment_stat )
	self addCACPrimaryAttachments( 0 ); //None
	self addCACPrimaryAttachments( 5 ); //GL
	self addCACPrimaryAttachments( 3 ); //Silencer
	self addCACPrimaryAttachments( 2 ); //Reflex
	self addCACPrimaryAttachments( 1 ); //Acog
	self addCACPrimaryAttachments( 4 );	//Grip
}

addSecondaries()
{
	//Add Secondaries ( weapon_stat )
	self addCACSecondaries( 0 ); //Beretta
	self addCACSecondaries( 2 ); //USP
	self addCACSecondaries( 1 ); //Colt 45 
	self addCACSecondaries( 3 ); //Desert Eagle
	self addCACSecondaries( 4 ); //Gold Desert Eagle	
}

addSecondaryAttachments()
{
	//Add Secondary Attachments ( attachment_stat )
	self addCACSecondaryAttachments( 0 ); //None
	self addCACSecondaryAttachments( 3 ); //Silencer
}

addPerk1()
{
	//Add perk1 ( perk_stat )
	//Make sure the perks are allowed before adding them to the list
	if ( getdvarx( "perk_allow_c4_mp", "int", 1, 0, 1 ) )
		self addCACPerk1( 184 ); //C4
	if ( getdvarx( "perk_allow_specialty_specialgrenade", "int", 1, 0, 1 ) )	
		self addCACPerk1( 176 ); //3x Special
	if ( getdvarx( "perk_allow_rpg_mp", "int", 1, 0, 1 ) )	
		self addCACPerk1( 186 ); //RPG
	if ( getdvarx( "perk_allow_claymore_mp", "int", 1, 0, 1 ) )	
		self addCACPerk1( 185 ); //Claymore
	if ( getdvarx( "perk_allow_specialty_fraggrenade", "int", 1, 0, 1 ) )	
		self addCACPerk1( 173 ); //3x Frag
	if ( getdvarx( "perk_allow_specialty_extraammo", "int", 1, 0, 1 ) )	
		self addCACPerk1( 165 ); //Bandolier
	if ( getdvarx( "perk_allow_specialty_detectexplosive", "int", 1, 0, 1 ) )	
		self addCACPerk1( 155 ); //Bomb Squad
}

addPerk2()
{
	//Add perk2 ( perk_stat )
	//Make sure the perks are allowed before adding them to the list
	if ( getdvarx( "perk_allow_specialty_bulletdamage", "int", 1, 0, 1 ) )
		self addCACPerk2( 160 ); //Stopping Power
	if ( getdvarx( "perk_allow_specialty_armorvest", "int", 1, 0, 1 ) )	
		self addCACPerk2( 167 ); //Juggernaut
	if ( getdvarx( "perk_allow_specialty_fastreload", "int", 1, 0, 1 ) )	
		self addCACPerk2( 164 ); //Sleight of Hand
	if ( getdvarx( "perk_allow_specialty_rof", "int", 1, 0, 1 ) )	
		self addCACPerk2( 163 ); //Double Tap
	if ( getdvarx( "perk_allow_specialty_twoprimaries", "int", 1, 0, 1 ) )	
		self addCACPerk2( 166 ); //Overkill
	if ( getdvarx( "perk_allow_specialty_gpsjammer", "int", 1, 0, 1 ) )	
		self addCACPerk2( 151 ); //UAV Jammer
	if ( getdvarx( "perk_allow_specialty_explosivedamage", "int", 1, 0, 1 ) )	
		self addCACPerk2( 156 ); //Sonic Boom
}

addPerk3()
{
	//Add perk3 ( perk_stat )
	//Make sure the perks are allowed before adding them to the list
	if ( getdvarx( "perk_allow_specialty_longersprint", "int", 1, 0, 1 ) )
		self addCACPerk3( 154 ); //Extreme Conditioning
	if ( getdvarx( "perk_allow_specialty_bulletaccuracy", "int", 1, 0, 1 ) )
		self addCACPerk3( 162 ); //Steady Aim
	if ( getdvarx( "perk_allow_specialty_pistoldeath", "int", 1, 0, 1 ) )
		self addCACPerk3( 157 ); //Last Stand
	if ( getdvarx( "perk_allow_specialty_grenadepulldeath", "int", 1, 0, 1 ) )
		self addCACPerk3( 158 ); //Martyrdom
	if ( getdvarx( "perk_allow_specialty_bulletpenetration", "int", 1, 0, 1 ) )
		self addCACPerk3( 161 ); //Deep Impact
	if ( getdvarx( "perk_allow_specialty_holdbreath", "int", 1, 0, 1 ) )
		self addCACPerk3( 152 ); //Iron Lungs
	if ( getdvarx( "perk_allow_specialty_quieter", "int", 1, 0, 1 ) )
		self addCACPerk3( 153 ); //Dead Silence
	if ( getdvarx( "perk_allow_specialty_parabolic", "int", 1, 0, 1 ) )	
		self addCACPerk3( 150 ); //Eaves Drop
}

addSGrenades()
{
	//Add Special Grenades ( sgrenade_stat )
	self addCACSpecialGrenade( 101 ); //Flash
	self addCACSpecialGrenade( 103 ); //Smoke
	self addCACSpecialGrenade( 102 ); //Stun
}

addCamos()
{
	//Add Camos ( camo_stat ) 
	self addCACCamos( 0 ); //None
	self addCACCamos( 1 ); //Brockhaurd
	self addCACCamos( 2 ); //Bushdweller
	self addCACCamos( 3 ); //BlackWhiteMarPat
	self addCACCamos( 4 ); //Stagger
	self addCACCamos( 5 ); //TigerRed
	self addCACCamos( 6 ); //Gold
}

addCACClasses( text, stat )
{
	cacClass = spawnstruct();
	cacClass.text = text;
	cacClass.stat = stat;
	self.cacEdit_classes[self.cacEdit_classes.size] = cacClass;
}

addCACPrimaries( label, stat )
{
	cacPrimary = spawnstruct();
	cacPrimary.label = label;
	cacPrimary.stat = stat;
	self.cacEdit_primaries[self.cacEdit_primaries.size] = cacPrimary;
}

addCACPrimaryAttachments( stat )
{
	cacPAttachment = spawnstruct();
	cacPAttachment.stat = stat;
	self.cacEdit_pattachments[self.cacEdit_pattachments.size] = cacPAttachment;
}

addCACSecondaries( stat )
{
	cacSecondary = spawnstruct();
	cacSecondary.stat = stat;
	self.cacEdit_secondaries[self.cacEdit_secondaries.size] = cacSecondary;
}

addCACSecondaryAttachments( stat )
{	
		cacSAttachment = spawnstruct();
		cacSAttachment.stat = stat;
		self.cacEdit_sattachments[self.cacEdit_sattachments.size] = cacSAttachment;
}

addCACPerk1( stat )
{
	cacPerk1 = spawnstruct();
	cacPerk1.stat = stat;
	self.cacEdit_perk1[self.cacEdit_perk1.size] = cacPerk1;
}

addCACPerk2( stat )
{
	cacPerk2 = spawnstruct();
	cacPerk2.stat = stat;
	self.cacEdit_perk2[self.cacEdit_perk2.size] = cacPerk2;
}

addCACPerk3( stat )
{
	cacPerk3 = spawnstruct();
	cacPerk3.stat = stat;
	self.cacEdit_perk3[self.cacEdit_perk3.size] = cacPerk3;
}

addCACSpecialGrenade( stat )
{
	cacSpecial = spawnstruct();
	cacSpecial.stat = stat;
	self.cacEdit_sgrenades[self.cacEdit_sgrenades.size] = cacSpecial;
}

addCACCamos( stat )
{
	cacCamo = spawnstruct();
	cacCamo.stat = stat;
	self.cacEdit_camos[self.cacEdit_camos.size] = cacCamo;
}

openAllClasses()
{
	//If the first custom class is unlocked then in order
	//to display all of the classes in the class selection
	//menu without having to exit game and edit them
	//then we need to unlock them on initialization of the menu
	//so players can edit and then select from any custom class.
	if ( self getStat( 210 ) < 1 )
		self setStat( 210, 1 );
	if ( self getStat( 220 ) < 1 )
		self setStat( 220, 1 );
	if ( self getStat( 230 ) < 1 )
		self setStat( 230, 1 );	
	if ( self getStat( 240 ) < 1 )
		self setStat( 240, 1 );		
}