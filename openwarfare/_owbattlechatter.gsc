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
#include openwarfare\_utils;

init()
{
  // Get the dvar
  scr_countdown_sounds = getdvarx( "scr_countdown_sounds", "string", "" );

  level.soundFlags = 0;

  level.CDFLAG_10MIN = 1;
  level.CDFLAG_5MIN = 2;
  level.CDFLAG_4MIN = 4;
  level.CDFLAG_3MIN = 8;
  level.CDFLAG_2MIN = 16;
  level.CDFLAG_1MIN = 32;
  level.CDFLAG_30SEC = 64;
  level.CDFLAG_15SEC = 128;
  level.CDFLAG_FINAL = 256;

  // translate the sounds into bit field
  if (scr_countdown_sounds != "")
    {
      countDownSounds = strtok ( scr_countdown_sounds, ";" );

      for ( idx = 0; idx < countDownSounds.size; idx++ )
	{
	  if ( tolower(countDownSounds[idx]) == "10min" )
	    level.soundFlags |= level.CDFLAG_10MIN;
	  else if ( tolower(countDownSounds[idx]) == "5min" )
	    level.soundFlags |= level.CDFLAG_5MIN;
	  else if ( tolower(countDownSounds[idx]) == "4min" )
	    level.soundFlags |= level.CDFLAG_4MIN;
	  else if ( tolower(countDownSounds[idx]) == "3min" )
	    level.soundFlags |= level.CDFLAG_3MIN;
	  else if ( tolower(countDownSounds[idx]) == "2min" )
	    level.soundFlags |= level.CDFLAG_2MIN;
	  else if ( tolower(countDownSounds[idx]) == "1min" )
	    level.soundFlags |= level.CDFLAG_1MIN;
	  else if ( tolower(countDownSounds[idx]) == "30sec" )
	    level.soundFlags |= level.CDFLAG_30SEC;
	  else if ( tolower(countDownSounds[idx]) == "15sec" )
	    level.soundFlags |= level.CDFLAG_15SEC;
	  else if ( tolower(countDownSounds[idx]) == "countdown" )
	    level.soundFlags |= level.CDFLAG_FINAL;
	}
    }
  
  // the sounds were not set or not correct -> save cpu and quit this module
  if ( level.soundFlags == 0)
    return;
  
  level thread CountdownMonitor();
}


CountdownMonitor()
{
  level endon ( "game_ended" );
  
  level waittill ( "ow_countdown_start" );
  
  playedAlready = 0;

  //prevent sounds from playing in case game timelimit is already below our triggers
  timeLeft = int(maps\mp\gametypes\_globallogic::getTimeRemaining() / 1000);

  if (timeLeft <= 600)
    playedAlready |= level.CDFLAG_10MIN;
  if (timeLeft <= 300)
    playedAlready |= level.CDFLAG_5MIN;
  if (timeLeft <= 240)
    playedAlready |= level.CDFLAG_4MIN;
  if (timeLeft <= 180)
    playedAlready |= level.CDFLAG_3MIN;
  if (timeLeft <= 120)
    playedAlready |= level.CDFLAG_2MIN;
  if (timeLeft <= 67)
    playedAlready |= level.CDFLAG_1MIN;
  if (timeLeft <= 33)
    playedAlready |= level.CDFLAG_30SEC;
  if (timeLeft <= 15)
    playedAlready |= level.CDFLAG_15SEC;
  if (timeLeft <= 10)
    playedAlready |= level.CDFLAG_FINAL;

  while ( game["state"] == "playing" )
    {
      if ( !level.timerStopped && level.timeLimit )
	{
    timeLeft = int(maps\mp\gametypes\_globallogic::getTimeRemaining() / 1000);
	  
	  if (( level.soundFlags & level.CDFLAG_10MIN ) && ( timeLeft <= 600 && !( playedAlready & level.CDFLAG_10MIN )))
	    {
	      playSoundOnPlayers( "CD10minPos" );
	      playedAlready |= level.CDFLAG_10MIN;
	      wait ( 1.0 );
	    }

	  if (( level.soundFlags & level.CDFLAG_5MIN ) && ( timeLeft <= 300 && !( playedAlready & level.CDFLAG_5MIN )))
	    {
	      playSoundOnPlayers( "CD05minPos" );
	      playedAlready |= level.CDFLAG_5MIN;
	      wait ( 1.0 );
	    }
	  if (( level.soundFlags & level.CDFLAG_4MIN ) && ( timeLeft <= 240 && !( playedAlready & level.CDFLAG_4MIN )))
	    {
	      playSoundOnPlayers( "CD04minPos" );
	      playedAlready |= level.CDFLAG_4MIN;
	      wait ( 1.0 );
	    }
	  if (( level.soundFlags & level.CDFLAG_3MIN ) && ( timeLeft <= 180 && !( playedAlready & level.CDFLAG_3MIN )))
	    {
	      playSoundOnPlayers( "CD03minPos" );
	      playedAlready |= level.CDFLAG_3MIN;
	      wait ( 1.0 );
	    }
	  if (( level.soundFlags & level.CDFLAG_2MIN ) && ( timeLeft <= 120 && !( playedAlready & level.CDFLAG_2MIN )))	  
	    {
	      if ( game["teamScores"]["allies"] > game["teamScores"]["axis"] )
		{
		  playSoundOnPlayers( "CD02minPos", "allies" );
		  playSoundOnPlayers( "CD02minNeg", "axis" );
		  wait ( 1.0 );
		}
	      else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
		{
		  playSoundOnPlayers( "CD02minPos", "axis" );
		  playSoundOnPlayers( "CD02minNeg", "allies" );
		  wait ( 1.0 );
		}
	      else
		{
		  playSoundOnPlayers( "CD02minPos");
		  wait ( 1.0 );
		}
	      playedAlready |= level.CDFLAG_2MIN;
	    }
	  if (( level.soundFlags & level.CDFLAG_1MIN ) && ( timeLeft <= 67 && !( playedAlready & level.CDFLAG_1MIN )))	  
	    {
	      if ( game["teamScores"]["allies"] > game["teamScores"]["axis"] )
		{
		  playSoundOnPlayers( "CD01minPos", "allies" );
		  playSoundOnPlayers( "CD01minNeg", "axis" );
		  wait ( 1.0 );
		}
	      else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
		{
		  playSoundOnPlayers( "CD01minPos", "axis" );
		  playSoundOnPlayers( "CD01minNeg", "allies" );
		  wait ( 1.0 );
		}
	      else
		{
		  playSoundOnPlayers( "CD01minPos");
		  wait ( 1.0 );
		}
	      playedAlready |= level.CDFLAG_1MIN;
	    }
	  if (( level.soundFlags & level.CDFLAG_30SEC ) && ( timeLeft <= 33 && !( playedAlready & level.CDFLAG_30SEC )))	  
	    {
	      playSoundOnPlayers( "CD30secPos" );
	      playedAlready |= level.CDFLAG_30SEC;
	      wait ( 1.0 );
	    }
	  if (( level.soundFlags & level.CDFLAG_15SEC ) && ( timeLeft <= 15 && !( playedAlready & level.CDFLAG_15SEC )))
	    {
	      playSoundOnPlayers( "CD15secPos" );
	      playedAlready |= level.CDFLAG_15SEC;
	      wait ( 1.0 );
	    }
	  if (( level.soundFlags & level.CDFLAG_FINAL ) && ( timeLeft <= 10 && !( playedAlready & level.CDFLAG_FINAL )))
	    {
      	playSoundOnPlayers( "CDFinalPos" );
	      playedAlready |= level.CDFLAG_FINAL;
	      wait ( 1.0 );
	    }
	}
      wait ( 0.1 );
    }
}
