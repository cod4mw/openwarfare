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

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

#include openwarfare\_eventmanager;
#include openwarfare\_utils;

init()
{
  level.scr_objective_safezone_enable = getdvarx( "scr_objective_safezone_enable", "int", 0, 0, 1 );
  level.scr_objective_safezone_radius = getdvarx( "scr_objective_safezone_radius", "int", 100, 50, 500 ); 
  
  level.scr_sd_objective_takedamage_enable = getdvarx( "scr_sd_objective_takedamage_enable", "int", 0, 0, 1 );
  level.scr_sd_objective_takedamage_option = getdvarx( "scr_sd_objective_takedamage_option", "int", 0, 0, 1 );
  if ( level.scr_sd_objective_takedamage_option )
    level.scr_sd_objective_takedamage_health = getdvarx( "scr_sd_objective_takedamage_health", "int", 500, 1, 2000 );
  else
    level.scr_sd_objective_takedamage_counter = getdvarx( "scr_sd_objective_takedamage_counter", "int", 5, 1, 20 );
  level.scr_sd_allow_defender_explosivepickup = getdvarx( "scr_sd_allow_defender_explosivepickup", "int", 0, 0, 1 );  
  level.scr_sd_allow_defender_explosivedestroy = getdvarx( "scr_sd_allow_defender_explosivedestroy", "int", 0, 0, 1 );
  level.scr_sd_allow_defender_explosivedestroy_time = getdvarx( "scr_sd_allow_defender_explosivedestroy_time", "int", 10, 1, 60 );
  level.scr_sd_allow_defender_explosivedestroy_sound = getdvarx( "scr_sd_allow_defender_explosivedestroy_sound", "int", 0, 0, 1 );
  level.scr_sd_allow_defender_explosivedestroy_win = getdvarx( "scr_sd_allow_defender_explosivedestroy_win", "int", 0, 0, 1 );
  level.scr_sd_allow_quickdefuse = getdvarx( "scr_sd_allow_quickdefuse", "int", 0, 0, 1 );
  
  if ( level.scr_sd_objective_takedamage_enable )
  {
    level._effect["bombexplosion"] = loadfx( "props/barrelexp" );
    game["strings"]["target_destroyed"] = &"MP_TARGET_DESTROYED"; 
    game["strings"]["bomb_defused"] = &"MP_BOMB_DEFUSED";
    precacheString( game["strings"]["target_destroyed"] );
    precacheString( game["strings"]["bomb_defused"] );
    level thread createDamageArea();
  }      

  level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );  
}

onPlayerSpawned()
{
	if ( level.scr_sd_allow_quickdefuse == 1 )
		self.didQuickDefuse = false;
	
	if ( level.scr_objective_safezone_enable )
		self thread getSafeZoneGametype();
	
	if ( level.scr_sd_allow_defender_explosivepickup && level.scr_sd_allow_defender_explosivedestroy && self.pers["team"] == game["defenders"] && getDvar( "g_gametype" ) == "sd" )
		self thread allowDefenderExplosiveDestroy();
} 

onPlayerKilled()
{ 
  self waittill( "death" );

  for( index = 0; index < self.safeZone.size; index++ )
  {       
      self.safeZone[index] delete();
  }
}

getSafeZoneGametype()
{
  gametype = getDvar( "g_gametype" );
  switch( gametype )
  {
    case "ctf":    
      self thread objSafeZones1( "ctf" );
      break;
    case "dom":
      self thread objSafeZones1( "dom" );
      break;  
    case "sab":
      self thread objSafeZones1( "sab" );
      break;         
    case "sd":
      self thread objSafeZones1( "sd" );
      break;      
    case "koth":
      self thread objSafeZones2();
      break;
  }
}

objSafeZones1( gametype )
{
  self endon( "death" );
  self endon( "disconnect" );
  
  self.safeZone = [];
  objZones = undefined;
  if ( gametype == "sd" )
    objZones = getEntArray( "bombzone", "targetname" );
  else if ( gametype == "ctf" )
    objZones = getEntArray( "ctf_flag_pickup_trig", "targetname" );
  else if ( gametype == "sab" )
  {
    objZones[0] = getEnt( "sab_bomb_axis", "targetname" );
    objZones[1] = getEnt( "sab_bomb_allies", "targetname" );
  }
  else
  {
    objZones1 = getEntArray( "flag_primary", "targetname" );
    objZones2 = getEntArray( "flag_secondary", "targetname" );
    
    i = 0;
    j = 0;
    for ( i = 0; i < objZones1.size; i++ )
      objZones[i] = objZones1[i];

    for ( j = i; j < objZones2.size + i; j++ )
      objZones[j] = objZones2[j-i];
   }   
  
  if ( !isDefined( objZones ) )
    return;
    
  for ( index = 0; index < objZones.size; index++ )
  {     
    self.safeZone[index] = spawn( "trigger_radius", objZones[index].origin + ( 0, 0, -48 ), 0, level.scr_objective_safezone_radius, 200 );
  }
  self thread onPlayerKilled();
  self thread monitorSafeZone();
} 


objSafeZones2()
{
  self endon( "death" );
  self endon( "disconnect" );
 
  self.safeZone = undefined;
  currentRadio = undefined; 
  origin = undefined; 
  radios = getEntArray( "hq_hardpoint", "targetname" );

  while ( isAlive( self ) )
  {
    if ( isDefined( level.prevradio ) && !isDefined( currentRadio ) )
    {
      currentRadio = level.prevradio;
      
      for ( index = 0; index < radios.size; index++ )
      {
        if ( radios[index] == currentRadio )
        {
          origin = index;
          break;
        }  
      } 
      self.safeZone[0] = spawn( "trigger_radius", radios[origin].origin + ( 0, 0, -100 ), 0, level.scr_objective_safezone_radius, 200 );
      self thread monitorSafeZone( );
    }      
    else if ( isDefined( level.prevradio ) && isDefined( currentRadio ) && currentRadio != level.prevradio )
    {
      // Instead of deleting and creating a new trigger
      // We are just going to move the trigger to the new hq location.
      currentRadio = level.prevradio;
      for ( index = 0; index < radios.size; index++ )
      {
        if ( radios[index] == currentRadio )
        {
          origin = index;
          break;
        }  
      }
      self.safeZone[0].origin = radios[origin].origin + ( 0, 0, -100 );
    }
    
    wait 1;
  }   
  self thread onPlayerKilled();
} 
 
  
monitorSafeZone()
{  
  self endon( "death" );
  self endon( "disconnect" );
    
  for (;;)
  {    
    self waittill( "grenade_fire", explosive, weaponName );
  
    if ( weaponName == "c4_mp" || weaponName == "claymore_mp" )
    {  
      explosive.weaponName = weaponName;
      explosive maps\mp\gametypes\_weapons::waitTillNotMoving();
      
      for ( index = 0; index < self.safeZone.size; index++ )
      {
        if ( explosive isTouching( self.safeZone[index] ) )
        {
          stockCount = self getWeaponAmmoStock( explosive.weaponName );
          maxStock = weaponMaxAmmo( explosive.weaponName );
        
          if ( stockCount < maxStock ) 
            self setWeaponAmmoStock( explosive.weaponName, stockCount + 1 );

          explosive delete();
          break;  
        } 
      }
    }      
  }
}

createDamageArea()
{
  if ( getDvar( "g_gametype" ) != "sd" )
    return;
    
  while ( !isDefined( level.bombZones ) )
      wait(0.5);
      
  bombZones = getEntArray( "bombzone", "targetname" );
  level.damageArea = [];
  level.damageArea2 = [];
  level.objectiveTakeDamage = false; //used to make sure only one script_model makes a call to destroy target

  for ( index = 0; index < bombZones.size; index++ )
  {
    visuals = getEntArray( bombZones[index].target, "targetname" );
    if ( index == 0 )
    {      
      if ( level.scr_sd_objective_takedamage_option )    
        level.objectiveHealth[index] = level.scr_sd_objective_takedamage_health;     
      else
        level.objectiveHealth[index] = level.scr_sd_objective_takedamage_counter;
        
      level.objDamageCounter[index] = 0;
      level.objDamageTotal[index] = 0;
      level.isLosingHealth[index] = false;

      //Script models with no setModel used to check for damage. 
      for ( i = 0; i < 5; i++ )
      {
        switch( i )
        {
          case 0:
            level.damageArea[index] = spawn( "script_model", bombZones[index].origin + ( 0, 0, 85 ) );
            break;
          case 1:
            level.damageArea[index] = spawn( "script_model", bombZones[index].origin + ( 75, 0, 10 ) );
            break;
          case 2:
            level.damageArea[index] = spawn( "script_model", bombZones[index].origin + ( -75, 0, 10 ) );
            break;
          case 3:
            level.damageArea[index] = spawn( "script_model", bombZones[index].origin + ( 0, 75, 10 ) );
            break;
          case 4:
            level.damageArea[index] = spawn( "script_model", bombZones[index].origin + ( 0, -75, 10 ) );
            break;  
         }               
        level.damageArea[index] setcandamage( true ); //Allows the script_model to receive damage
        level.damageArea[index].health = 100000; //A high value is all we need
        level.damageArea[index] thread waitForDamage( index, bombZones[index], visuals );
     }
   }
   else
   {
      if ( level.scr_sd_objective_takedamage_option )    
        level.objectiveHealth[index] = level.scr_sd_objective_takedamage_health;     
      else
        level.objectiveHealth[index] = level.scr_sd_objective_takedamage_counter;
           
      level.objDamageCounter[index] = 0;
      level.objDamageTotal[index] = 0;
      level.isLosingHealth[index] = false;
      
      for ( i = 0; i < 5; i++ )
      {
        switch( i )
        {
          case 0:
            level.damageArea2[index] = spawn( "script_model", bombZones[index].origin + ( 0, 0, 85 ) );
            break;
          case 1:
            level.damageArea2[index] = spawn( "script_model", bombZones[index].origin + ( 75, 0, 10 ) );
            break;
          case 2:
            level.damageArea2[index] = spawn( "script_model", bombZones[index].origin + ( -75, 0, 10 ) );
            break;
          case 3:
            level.damageArea2[index] = spawn( "script_model", bombZones[index].origin + ( 0, 75, 10 ) );
            break;
          case 4:
            level.damageArea2[index] = spawn( "script_model", bombZones[index].origin + ( 0, -75, 10 ) );
            break;  
         }               
         level.damageArea2[index] setcandamage( true );
         level.damageArea2[index].health = 100000;
         level.damageArea2[index] thread waitForDamage( index, bombZones[index], visuals );    
      }
    }
  }
}
  
waitForDamage( index, object, visuals )
{
  attacker = undefined;
  while (1)
  {
    if ( level.objectiveHealth[index] <= 0 )
      break;
  
    self waittill( "damage", damage, attacker );

    if ( level.scr_sd_objective_takedamage_option )
    {
      level.objDamageCounter[index]++;
      level.objDamageTotal[index] += damage;
    }
    
    wait( 0.1 );
    
    if ( isDefined( attacker ) && isPlayer( attacker ) )
    {  
      if ( attacker.pers["team"] == game["defenders"] )
      {
        if ( !level.isLosingHealth[index] )
        {
          level.isLosingHealth[index] = true;
          if ( level.scr_sd_objective_takedamage_option )
          {
            level.objectiveHealth[index] -= int( level.objDamageTotal[index] / level.objDamageCounter[index] );
            level.objDamageCounter[index] = 0;
            level.objDamageTotal[index] = 0;
          }
          else
          {
            level.objectiveHealth[index]--;
          }
          wait(0.1);
          level.isLosingHealth[index] = false;
        }
      }
    }
    wait(0.1); 
  } 
  if ( !level.objectiveTakeDamage )
  {
    level.objectiveTakeDamage = true;
    self thread destroyObjective( object, visuals, attacker );
  } 
}  
  
destroyObjective( object, visuals, attacker )
{
  if ( isDefined( level.bombExploded ) && !level.bombExploded )
    level.bombExploded = true;
  else 
    return;
      
    for ( i = 0; i < visuals.size; i++ )
		{
			if ( isDefined( visuals[i].script_exploder ) )
			{
				object.exploderIndex = visuals[i].script_exploder;
				break;
			}
		}  
      
    visuals[0] radiusDamage( object.origin, 512, 200, 20, attacker, "MOD_EXPLOSIVE", "briefcase_bomb_mp" );
    
    rot = randomfloat(360);
	  explosionEffect = spawnFx( level._effect["bombexplosion"], object.origin + (0,0,50), (0,0,1), (cos(rot),sin(rot),0) );
	  triggerFx( explosionEffect );
	  
	  exploder( object.exploderIndex );
	  
	  thread maps\mp\gametypes\sd::playSoundinSpace( "exp_suitcase_bomb_main", object.origin );
	  
	  setGameEndTime( 0 );
	  
	  wait 3;
	
	  maps\mp\gametypes\sd::sd_endGame( game["attackers"], game["strings"]["target_destroyed"] );
} 

allowDefenderExplosiveDestroy()
{
  self endon( "disconnect" );
  self endon( "death" );
  
  self.destroyingExplosive = false;
  self.explosiveDestroyed = false;
  lastWeapon = self getCurrentWeapon();
  startTime = 0;
  destroyTime = level.scr_sd_allow_defender_explosivedestroy_time;
  while ( isAlive( self ) && !level.bombPlanted && !level.gameEnded && !self.explosiveDestroyed )
  {     
    while ( isAlive( self ) && self meleeButtonPressed() && self.isBombCarrier && !level.gameEnded )
    {
      if ( startTime == 0 )
      {
        if ( level.scr_sd_allow_defender_explosivedestroy_sound )
          playSoundOnPlayers( "mp_ingame_summary", game["attackers"] );
        wait( 0.5 ); //Give time for melee animation to finish
        if ( self meleeButtonpressed() )
        {
          if( level.scr_sd_show_briefcase )
          {
            self thread openwarfare\_speedcontrol::setModifierSpeed( "_objpoints", 100 );
            self giveWeapon( "briefcase_bomb_mp" );
            self setWeaponAmmoStock( "briefcase_bomb_mp", 0 );
            self setWeaponAmmoClip( "briefcase_bomb_mp", 0 );
            self switchToWeapon( "briefcase_bomb_mp" );
            self attach( "prop_suitcase_bomb","tag_inhand", true );
            while ( self getCurrentWeapon() != "briefcase_bomb_mp" )
            	wait (0.05);
          }
          else
          {
            self thread openwarfare\_healthsystem::stopPlayer( true );
          }
          startTime = openwarfare\_timer::getTimePassed();
          self.destroyingExplosive = true;
        }
        else
        {
          break;
        }   
      }
      wait( 0.05 );
      timeHack = ( openwarfare\_timer::getTimePassed() - startTime ) / 1000; 
      self updateSecondaryProgressBar( timeHack, destroyTime, false, &"OW_DESTROYING_EXPLOSIVES" );
        
      if ( timeHack >= destroyTime )
      {
        self.explosiveDestroyed = true; 
        break;
      }
      
      if( level.scr_sd_show_briefcase && self getCurrentWeapon() != "briefcase_bomb_mp" )
      	break;
    }
    if ( self.destroyingExplosive )
    {
      self updateSecondaryProgressBar( undefined, undefined, true, undefined );
      self.destroyingExplosive = false;
      wait .5;
      if( level.scr_sd_show_briefcase )
      {
        self detach( "prop_suitcase_bomb", "tag_inhand" ); 
        self switchToWeapon( lastWeapon );
        self thread openwarfare\_speedcontrol::setModifierSpeed( "_objpoints", 0 );
      }
      else
      {
        self thread openwarfare\_healthsystem::stopPlayer( false );
      }
      startTime = 0;  
    }  
    wait .5;   
  }
  
  if ( !level.bombPlanted && !level.gameEnded && level.scr_sd_allow_defender_explosivedestroy_win )
  {
    setGameEndTime( 0 );
    maps\mp\gametypes\sd::sd_endGame( game["defenders"], &"OW_EXPLOSIVES_DESTROYED" );

    maps\mp\gametypes\_globallogic::givePlayerScore( "defuse", self );
		self thread [[level.onXPEvent]]( "defuse" );
  }
  else if ( !level.scr_sd_allow_defender_explosivedestroy_win && !level.bombPlanted && !level.gameEnded )
  {
	self.isBombCarrier = false;
	self takeWeapon( "briefcase_bomb_mp" );
	if ( isDefined( level.sdBomb ) )
		level.sdBomb maps\mp\gametypes\_gameobjects::disableObject();
  }
}

quickDefuse()
{
  self endon( "disconnect" );
  self endon( "death" );
  
  if ( self.didQuickDefuse )
  	return;
  
  self.isChangingWire = false;
  
  if ( isAlive( self ) && self.isDefusing && !level.gameEnded && !level.bombExploded )
  {
    bombwire[0] = &"OW_RED_WIRE";
    bombwire[1] = &"OW_GREEN_WIRE";
    bombwire[2] = &"OW_YELLOW_WIRE";
    bombwire[3] = &"OW_BLUE_WIRE"; 
    
    correctWire = randomIntRange( 0, 4 );
    playerChoice = 0;
    self iprintlnbold( &"OW_QUICK_DEFUSE_1" );
    self iprintlnbold( &"OW_QUICK_DEFUSE_2" );
    while ( self.isDefusing && isAlive( self ) && !level.gameEnded && !level.bombExploded && !self.didQuickDefuse )
    {
      if ( self attackButtonPressed() ) {
      	self.didQuickDefuse = true;
				self thread quickDefuseResults( playerChoice, correctWire );
				
      } else if ( self adsButtonPressed() && !self.isChangingWire ) {
        self.isChangingWire = true;
        self allowAds( false );
        if ( playerChoice == 3 )
          playerChoice = 0;
        else
          playerChoice++;        
        self iprintlnbold( bombwire[playerChoice] );  
        wait( 0.1 );  
        self.isChangingWire = false;
        self allowAds( true );
      }
      
      wait( 0.05 );
    }
  }
}  

quickDefuseResults( playerChoice, correctWire )
{
  level endon ( "game_ended" );
  
  if ( playerChoice == correctWire && isAlive( self ) && !level.gameEnded && !level.bombExploded ) {
  	level.defuseObject thread maps\mp\gametypes\sd::onUseDefuseObject( self );
  		
  } else if ( playerChoice != correctWire && isAlive( self ) && !level.gameEnded && !level.bombExploded ) {
  	level notify( "wrong_wire" );
  }
}