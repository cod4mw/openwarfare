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
#include common_scripts\utility;
#include openwarfare\_utils;


init()
{
	// Initialize server load variables (do not thread)
	openwarfare\_serverload::init();

	// Check if we need to load a rule
	level.cod_mode = getdvarx( "cod_mode", "string", "" );
	level.script = toLower( getDvar( "mapname" ) );
	level.gametype = toLower( getDvar( "g_gametype" ) );

	// Load the rulesets
	rulesets\openwarfare\rulesets::init();
	if ( getDvar("dedicated") != "listen server" )
		rulesets\leagues::init();

	// Initialize the rule sets
	if ( level.cod_mode != "" ) {
		// Check if we have a rule for this league and gametype first
		if ( isDefined( level.matchRules[ level.cod_mode ] ) ) {
			if ( isDefined( level.matchRules[ level.cod_mode ][ level.gametype ] ) ) {
				[[ level.matchRules[ level.cod_mode ][ level.gametype ] ]]();
				logPrint( "RSM;Ruleset " + level.cod_mode + " loaded.\n" );
				
			} else if ( isDefined( level.matchRules[ level.cod_mode ]["all"] ) ) {
				[[ level.matchRules[ level.cod_mode ][ "all" ] ]]();
				logPrint( "RSM;Ruleset " + level.cod_mode + " loaded.\n" );
				
			} else {
				// Rule is not valid or doesn't support the current gametype
				setDvar( "cod_mode", "" );
				level.cod_mode = "";
			}
		}
	}
	level.scr_league_ruleset = getdvarx( "scr_league_ruleset", "string", "" );

	level.scr_tactical = getdvarx( "scr_tactical_enable", "int", 0, 0, 1 );
	level.hardcoreMode = getdvarx( "scr_hardcore", "int", 1, 0, 1 );
	level.oldschool = ( getDvarInt( "scr_oldschool" ) == 1 );
	level.scr_enable_music = getDvarInt( "scr_enable_music" );
	level.scr_eog_fastrestart = getdvarx( "scr_eog_fastrestart", "int", 0, 0, 500 );
	level.scr_show_player_assignment = getdvarx( "scr_show_player_assignment", "int", 0, 0, 1 );

	// Get the amount of health we'll be using for players	
	if ( level.hardcoreMode )		
		level.maxhealth = getdvarx( "scr_player_maxhealth", "int", 30, 1, 500 );	
	else if ( level.oldschool )		
		level.maxhealth = getdvarx( "scr_player_maxhealth", "int", 200, 1, 500 );	
	else		
		level.maxhealth = getdvarx( "scr_player_maxhealth", "int", 100, 1, 500 );	

	// Reset certain values no matter what the setting in the server
	setDvar( "sv_fps", "20" );
	setDvar( "ui_hud_obituaries", "1" );
	setDvar( "ui_hud_showobjicons", "1" );
	setDvar( "g_antilag", getdvarx( "scr_antilag", "int", 0, 0, 1 ) );
	
	// Set mod name and version
	setDvar( "_Mod", "OpenWarfare", true );
	setDvar( "_ModVer", "v4.180.2482", true );

	// Make a health check of the server
	level thread openwarfare\_servercheck::init();

	// hack to allow maps with no scripts to run correctly
	if ( !isDefined( level.tweakablesInitialized ) )
		maps\mp\gametypes\_tweakables::init();

	// We do this for compatibility with previous variable
	level.scr_server_rank_type = getdvarx( "scr_server_rank_type", "int", getdvarx( "scr_forceunrankedmatch", "int", 0, 0, 1 ), 0, 2 );
	
	// Make the game unranked in case is being forced by the new dvar
	if ( level.scr_server_rank_type != 0 ) {
		level.rankedMatch = false;
	} else {
		level.rankedMatch = true;
	}
	
	// Initialize variables used by OpenWarfare
	openwarfare\_registerdvars::init();

	level.splitscreen = isSplitScreen();
	level.xenon = (getdvar("xenonGame") == "true");
	level.ps3 = (getdvar("ps3Game") == "true");
	
	level.console = (level.xenon || level.ps3);
	
	// If the server is not running in the standard directory then we declare an unranked match
	/*if ( !isSubStr( toLower(getDvar("sv_referencedFFNames")), "mods/openwarfare/mod" ) ) {
		level.scr_server_rank_type = 1;
		level.rankedMatch = false;
	}*/

	precacheMenu("popup_addfavorite");

	level.otherTeam["allies"] = "axis";
	level.otherTeam["axis"] = "allies";

	level.teamBased = false;

	level.overrideTeamScore = false;
	level.overridePlayerScore = false;
	level.displayHalftimeText = false;
	level.displayRoundEndText = true;

	level.endGameOnScoreLimit = true;
	level.endGameOnTimeLimit = true;

	precacheString( &"MP_HALFTIME" );
	precacheString( &"MP_OVERTIME" );
	precacheString( &"MP_ROUNDEND" );
	precacheString( &"MP_INTERMISSION" );
	precacheString( &"MP_SWITCHING_SIDES" );
	precacheString( &"MP_FRIENDLY_FIRE_WILL_NOT" );

	if ( level.splitScreen )
		precacheString( &"MP_ENDED_GAME" );
	else
		precacheString( &"MP_HOST_ENDED_GAME" );

	level.halftimeType = "halftime";
	level.halftimeSubCaption = &"MP_SWITCHING_SIDES";

	level.lastStatusTime = 0;
	level.wasWinning = "none";

	level.lastSlowProcessFrame = 0;

	level.placement["allies"] = [];
	level.placement["axis"] = [];
	level.placement["all"] = [];

	level.postRoundTime = 8.0;

	level.inOvertime = false;

	level.dropTeam = getdvarint( "sv_maxclients" );
	level.players = [];

	registerDvars();

	if ( !level.rankedMatch ) {
		maps\mp\gametypes\_class_unranked::initPerkDvars();
	} else {
		maps\mp\gametypes\_class::initPerkDvars();
	}

	if ( level.oldschool )
	{
		logString( "game mode: oldschool" );
	}

	// Changed to use the variables instead of fixed values
	// Set fall damage parameters
	setDvar( "bg_fallDamageMinHeight", level.scr_fallDamageMinHeight );
	setDvar( "bg_fallDamageMaxHeight", level.scr_fallDamageMaxHeight );

	precacheModel( "vehicle_mig29_desert" );
	precacheModel( "projectile_cbu97_clusterbomb" );
	precacheModel( "tag_origin" );

	level.fx_airstrike_afterburner = loadfx ("fire/jet_afterburner");
	level.fx_airstrike_contrail = loadfx ("smoke/jet_contrail");

	if ( !isDefined( game["tiebreaker"] ) )
		game["tiebreaker"] = false;
}

registerDvars()
{
	if ( getdvar( "scr_oldschool" ) == "" )
		setdvar( "scr_oldschool", "0" );

	makeDvarServerInfo( "scr_oldschool" );

	setDvar( "ui_hud_hardcore", 1 );
	makeDvarServerInfo( "ui_hud_hardcore", 1 );
	
	setDvar( "ui_hud_hardcore_show_minimap", 0 );
	makeDvarServerInfo( "ui_hud_hardcore_show_minimap", 0 );
	
	setDvar( "ui_hud_hardcore_show_compass", 0 );
	makeDvarServerInfo( "ui_hud_hardcore_show_compass", 0 );
	
	setDvar( "ui_hud_show_inventory", 0 );		
	makeDvarServerInfo( "ui_hud_show_inventory", 0 );
	
	setDvar( "ui_bomb_timer", 0 );
	makeDvarServerInfo( "ui_bomb_timer" );

	if ( getDvar( "scr_show_unlock_wait" ) == "" )
		setDvar( "scr_show_unlock_wait", 0.1 );
}

SetupCallbacks()
{
	level.spawnPlayer = ::spawnPlayer;
	level.spawnClient = ::spawnClient;
	level.spawnSpectator = ::spawnSpectator;
	level.spawnIntermission = ::spawnIntermission;
	level.onPlayerScore = ::default_onPlayerScore;
	level.onTeamScore = ::default_onTeamScore;

	level.onXPEvent = ::onXPEvent;
	level.waveSpawnTimer = ::waveSpawnTimer;

	level.onSpawnPlayer = ::blank;
	level.onSpawnSpectator = ::default_onSpawnSpectator;
	level.onSpawnIntermission = ::default_onSpawnIntermission;
	level.onRespawnDelay = ::blank;

	level.onForfeit = ::default_onForfeit;
	level.onTimeLimit = ::default_onTimeLimit;
	level.onScoreLimit = ::default_onScoreLimit;
	level.onDeadEvent = ::default_onDeadEvent;
	level.onOneLeftEvent = ::default_onOneLeftEvent;
	level.giveTeamScore = ::giveTeamScore;
	level.givePlayerScore = ::givePlayerScore;
	level.getTeamKillScore = ::default_getTeamKillScore;

	level._setTeamScore = ::_setTeamScore;
	level._setPlayerScore = ::_setPlayerScore;

	level._getTeamScore = ::_getTeamScore;
	level._getPlayerScore = ::_getPlayerScore;

	level.onPrecacheGametype = ::blank;
	level.onStartGameType = ::blank;
	level.onPlayerConnect = ::blank;
	level.onPlayerDisconnect = ::blank;
	level.onPlayerDamage = ::blank;
	level.onPlayerKilled = ::blank;
	level.onLoadoutGiven = ::blank;

	level.onEndGame = ::blank;

	level.autoassign = ::menuAutoAssign;
	level.spectator = ::menuSpectator;
	level.class = ::menuClass;
	level.allies = ::menuAllies;
	level.axis = ::menuAxis;
}


// to be used with things that are slow.
// unfortunately, it can only be used with things that aren't time critical.
WaitTillSlowProcessAllowed()
{
	// wait only a few frames if necessary
	// if we wait too long, we might get too many threads at once and run out of variables
	// i'm trying to avoid using a loop because i don't want any extra variables
	if ( level.lastSlowProcessFrame == gettime() )
	{
		wait .05;
		if ( level.lastSlowProcessFrame == gettime() )
		{
		wait .05;
			if ( level.lastSlowProcessFrame == gettime() )
			{
				wait .05;
				if ( level.lastSlowProcessFrame == gettime() )
				{
					wait .05;
				}
			}
		}
	}

	level.lastSlowProcessFrame = gettime();
}


blank( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 )
{
}

// when a team leaves completely, that team forfeited, team left wins round, ends game
default_onForfeit( team )
{
	level notify ( "forfeit in progress" ); //ends all other forfeit threads attempting to run
	level endon( "forfeit in progress" );	//end if another forfeit thread is running
	level endon( "abort forfeit" );			//end if the team is no longer in forfeit status

	// Check if forfeit is enabled
	if ( level.scr_forfeit_enable == 0 )
		return;

	// in 1v1 DM, give players time to change teams
	if ( !level.teambased && level.players.size > 1 )
		wait 10;

	forfeit_delay = 20.0;						//forfeit wait, for switching teams and such

	announcement( game["strings"]["opponent_forfeiting_in"], forfeit_delay );
	wait (10.0);
	announcement( game["strings"]["opponent_forfeiting_in"], 10.0 );
	wait (10.0);

	endReason = &"";
	if ( !isDefined( team ) )
	{
		setDvar( "ui_text_endreason", game["strings"]["players_forfeited"] );
		endReason = game["strings"]["players_forfeited"];
		winner = level.players[0];
	}
	else if ( team == "allies" )
	{
		setDvar( "ui_text_endreason", game["strings"]["allies_forfeited"] );
		endReason = game["strings"]["allies_forfeited"];
		winner = "axis";
	}
	else if ( team == "axis" )
	{
		setDvar( "ui_text_endreason", game["strings"]["axis_forfeited"] );
		endReason = game["strings"]["axis_forfeited"];
		winner = "allies";
	}
	else
	{
		//shouldn't get here
		assertEx( isdefined( team ), "Forfeited team is not defined" );
		assertEx( 0, "Forfeited team " + team + " is not allies or axis" );
		winner = "tie";
	}
	//exit game, last round, no matter if round limit reached or not
	level.forcedEnd = true;

	if ( isPlayer( winner ) )
		logString( "forfeit, win: " + winner getXuid() + "(" + winner.name + ")" );
	else
		logString( "forfeit, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
	thread endGame( winner, endReason );
}


default_onDeadEvent( team )
{
	if ( team == "allies" )
	{
		iPrintLn( game["strings"]["allies_eliminated"] );
		makeDvarServerInfo( "ui_text_endreason", game["strings"]["allies_eliminated"] );
		setDvar( "ui_text_endreason", game["strings"]["allies_eliminated"] );

		logString( "team eliminated, win: opfor, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );

		thread endGame( "axis", game["strings"]["allies_eliminated"] );
	}
	else if ( team == "axis" )
	{
		iPrintLn( game["strings"]["axis_eliminated"] );
		makeDvarServerInfo( "ui_text_endreason", game["strings"]["axis_eliminated"] );
		setDvar( "ui_text_endreason", game["strings"]["axis_eliminated"] );

		logString( "team eliminated, win: allies, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );

		thread endGame( "allies", game["strings"]["axis_eliminated"] );
	}
	else
	{
		makeDvarServerInfo( "ui_text_endreason", game["strings"]["tie"] );
		setDvar( "ui_text_endreason", game["strings"]["tie"] );

		logString( "tie, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );

		if ( level.teamBased )
			thread endGame( "tie", game["strings"]["tie"] );
		else
			thread endGame( undefined, game["strings"]["tie"] );
	}
}


default_onOneLeftEvent( team )
{
	if ( !level.teamBased )
	{
		winner = getHighestScoringPlayer();

		if ( isDefined( winner ) )
			logString( "last one alive, win: " + winner.name );
		else
			logString( "last one alive, win: unknown" );

		thread endGame( winner, &"MP_ENEMIES_ELIMINATED" );
	}
	else if ( !isdefined ( level.playedlastoneSound ) || ( isdefined ( level.playedlastoneSound ) && !level.playedlastoneSound ) )
	{
		level.playedlastoneSound = true;
		for ( index = 0; index < level.players.size; index++ )
		{
			player = level.players[index];

			if ( !isAlive( player ) )
				continue;

			if ( !isDefined( player.pers["team"] ) || player.pers["team"] != team )
				continue;

			player maps\mp\gametypes\_globallogic::leaderDialogOnPlayer( "last_alive" );
		}
	}
}


default_onTimeLimit()
{
	winner = undefined;

	if ( level.teamBased && level.gametype != "bel" )
	{
		if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
			winner = "tie";
		else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
			winner = "axis";
		else
			winner = "allies";

		logString( "time limit, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
	}
	else
	{
		winner = getHighestScoringPlayer();

		if ( isDefined( winner ) )
			logString( "time limit, win: " + winner.name );
		else
			logString( "time limit, tie" );
	}

	// i think these two lines are obsolete
	makeDvarServerInfo( "ui_text_endreason", game["strings"]["time_limit_reached"] );
	setDvar( "ui_text_endreason", game["strings"]["time_limit_reached"] );

	thread endGame( winner, game["strings"]["time_limit_reached"] );
}


forceEnd()
{
	if ( level.hostForcedEnd || level.forcedEnd )
		return;

	winner = undefined;

	if ( level.teamBased && level.gametype != "bel" )
	{
		if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
			winner = "tie";
		else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
			winner = "axis";
		else
			winner = "allies";
		logString( "host ended game, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
	}
	else
	{
		winner = getHighestScoringPlayer();
		if ( isDefined( winner ) )
			logString( "host ended game, win: " + winner.name );
		else
			logString( "host ended game, tie" );
	}

	level.forcedEnd = true;
	level.hostForcedEnd = true;

	if ( level.splitscreen )
		endString = &"MP_ENDED_GAME";
	else
		endString = &"MP_HOST_ENDED_GAME";

	makeDvarServerInfo( "ui_text_endreason", endString );
	setDvar( "ui_text_endreason", endString );
	thread endGame( winner, endString );
}


default_onScoreLimit()
{
	if ( !level.endGameOnScoreLimit )
		return;

	winner = undefined;

	if ( level.teamBased && level.gametype != "bel" )
	{
		if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
			winner = "tie";
		else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
			winner = "axis";
		else
			winner = "allies";
		logString( "scorelimit, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
	}
	else
	{
		winner = getHighestScoringPlayer();
		if ( isDefined( winner ) )
			logString( "scorelimit, win: " + winner.name );
		else
			logString( "scorelimit, tie" );
	}

	makeDvarServerInfo( "ui_text_endreason", game["strings"]["score_limit_reached"] );
	setDvar( "ui_text_endreason", game["strings"]["score_limit_reached"] );

	level.forcedEnd = true; // no more rounds if scorelimit is hit
	thread endGame( winner, game["strings"]["score_limit_reached"] );
}


updateGameEvents()
{
	if ( ( level.rankedMatch || level.scr_server_rank_type == 2 ) && !level.inGracePeriod )
	{
		if ( level.teamBased && level.gametype != "bel" )
		{
			// if allies disconnected, and axis still connected, axis wins round and game ends to lobby
			if ( (level.everExisted["allies"] || level.console) && level.playerCount["allies"] < 1 && level.playerCount["axis"] > 0 && game["state"] == "playing" )
			{
				//allies forfeited
				thread [[level.onForfeit]]( "allies" );
				return;
			}

			// if axis disconnected, and allies still connected, allies wins round and game ends to lobby
			if ( (level.everExisted["axis"] || level.console) && level.playerCount["axis"] < 1 && level.playerCount["allies"] > 0 && game["state"] == "playing" )
			{
				//axis forfeited
				thread [[level.onForfeit]]( "axis" );
				return;
			}

			if ( level.playerCount["axis"] > 0 && level.playerCount["allies"] > 0 )
				level notify( "abort forfeit" );
		}
		else
		{
			if ( level.playerCount["allies"] + level.playerCount["axis"] == 1 && level.maxPlayerCount > 1 )
			{
				thread [[level.onForfeit]]();
				return;
			}

			if ( level.playerCount["axis"] + level.playerCount["allies"] > 1 )
				level notify( "abort forfeit" );
		}
	}

	if ( !level.numLives && !level.inOverTime )
		return;

	if ( level.inGracePeriod )
		return;

	if ( level.teamBased && level.gametype != "bel" )
	{
		// if both allies and axis were alive and now they are both dead in the same instance
		if ( level.everExisted["allies"] && !level.aliveCount["allies"] && level.everExisted["axis"] && !level.aliveCount["axis"] && !level.playerLives["allies"] && !level.playerLives["axis"] )
		{
			[[level.onDeadEvent]]( "all" );
			return;
		}

		// if allies were alive and now they are not
		if ( level.everExisted["allies"] && !level.aliveCount["allies"] && !level.playerLives["allies"] )
		{
			[[level.onDeadEvent]]( "allies" );
			return;
		}

		// if axis were alive and now they are not
		if ( level.everExisted["axis"] && !level.aliveCount["axis"] && !level.playerLives["axis"] )
		{
			[[level.onDeadEvent]]( "axis" );
			return;
		}

		// one ally left
		if ( level.lastAliveCount["allies"] > 1 && level.aliveCount["allies"] == 1 && level.playerLives["allies"] == 1 )
		{
			[[level.onOneLeftEvent]]( "allies" );
			return;
		}

		// one axis left
		if ( level.lastAliveCount["axis"] > 1 && level.aliveCount["axis"] == 1 && level.playerLives["axis"] == 1 )
		{
			[[level.onOneLeftEvent]]( "axis" );
			return;
		}
	}
	else
	{
		// everyone is dead
		if ( (!level.aliveCount["allies"] && !level.aliveCount["axis"]) && (!level.playerLives["allies"] && !level.playerLives["axis"]) && level.maxPlayerCount > 1 )
		{
			[[level.onDeadEvent]]( "all" );
			return;
		}

		// last man standing
		if ( (level.aliveCount["allies"] + level.aliveCount["axis"] == 1) && (level.playerLives["allies"] + level.playerLives["axis"] == 1) && level.maxPlayerCount > 1 )
		{
			[[level.onOneLeftEvent]]( "all" );
			return;
		}
	}
}


matchStartTimer()
{
	visionSetNaked( "mpIntro", 0 );

	if ( level.scr_match_readyup_period == 1 ) {
		game["matchReadyUpText"] = createServerFontString( "objective", 2.0 );
		game["matchReadyUpText"] setPoint( "CENTER", "CENTER", 0, -45 );
		game["matchReadyUpText"].sort = 1001;
		game["matchReadyUpText"] setText( &"OW_READYUP_ALL_PLAYERS_READY" );
		game["matchReadyUpText"].foreground = false;
		game["matchReadyUpText"].hidewheninmenu = true;
	}

	matchStartText = createServerFontString( "objective", 1.5 );
	matchStartText setPoint( "CENTER", "CENTER", 0, -20 );
	matchStartText.sort = 1001;
	matchStartText setText( game["strings"]["waiting_for_teams"] );
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = true;

	matchStartTimer = createServerTimer( "objective", 1.4 );
	matchStartTimer setPoint( "CENTER", "CENTER", 0, 0 );
	matchStartTimer setTimer( level.prematchPeriod );
	matchStartTimer.sort = 1001;
	matchStartTimer.foreground = false;
	matchStartTimer.hideWhenInMenu = true;

	if ( level.scr_match_readyup_period == 0 ) {
		waitForPlayers( level.prematchPeriod );
	}

	if ( level.prematchPeriodEnd > 0 )
	{
		if( !game["roundsplayed"] )
			matchStartText setText( game["strings"]["match_starting_in"] );
		else
			matchStartText setText( &"OW_MATCH_RESUMING_IN" );

		matchStartTimer setTimer( level.prematchPeriodEnd );

		// If ready-up is active we'll remind the players to start recording
		if ( level.scr_match_readyup_period == 1 ) {
			messageFlag = false;
			nextSwitch = gettime() + 2000;
			gameStarts = gettime() + 1000 * level.prematchPeriodEnd;
			
			while ( gettime() < gameStarts ) {
				wait (0.05);
				
				// Check if it's time to change the message
				if ( gettime() > nextSwitch ) {
					game["matchReadyUpText"] fadeOverTime( 0.25 );
					game["matchReadyUpText"].alpha = 0;
					wait (0.25);
					if ( messageFlag ) {
						game["matchReadyUpText"] setText( &"OW_READYUP_ALL_PLAYERS_READY" );
					} else {
						if ( level.scr_match_readyup_public == 0 ) {
							game["matchReadyUpText"] setText( &"OW_READYUP_RECORD_REMINDER" );
						} else {
							game["matchReadyUpText"] setText( "" );
						}
					}
					game["matchReadyUpText"] fadeOverTime( 0.25 );
					game["matchReadyUpText"].alpha = 1;
					messageFlag = !messageFlag;
					nextSwitch = gettime() + 2000;
				}				
			}			
		} else {
			wait level.prematchPeriodEnd;
		}
	}

	visionSetNaked( getDvar( "mapname" ), 2.0 );

	matchStartTimer destroyElem();
	matchStartText destroyElem();

	if ( isDefined( game["matchReadyUpText"] ) ) {
		game["matchReadyUpText"] destroy();
	}
}


matchStartTimerSkip()
{
	visionSetNaked( getDvar( "mapname" ), 0 );
}


spawnPlayer()
{
	prof_begin( "spawnPlayer_preUTS" );

	self endon("disconnect");
	self endon("joined_spectators");
	self notify("spawned");
	self notify("end_respawn");

	self setSpawnVariables();

	if ( level.teamBased )
		self.sessionteam = self.team;
	else
		self.sessionteam = "none";

	hadSpawned = self.hasSpawned;

	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.statusicon = "";

	// Set the health level based on the dvar using a default values based on the gamemod
	self.maxhealth = level.maxhealth;
	self.health = level.maxhealth;

	self.friendlydamage = undefined;
	self.hasSpawned = true;
	self.spawnTime = getTime();
	self.afk = false;
	if ( self.pers["lives"] )
		self.pers["lives"]--;
	self.lastStand = undefined;

	if ( !self.wasAliveAtMatchStart )
	{
		acceptablePassedTime = 20;
		if ( level.timeLimit > 0 && acceptablePassedTime < level.timeLimit * 60 / 4 )
			acceptablePassedTime = level.timeLimit * 60 / 4;

		if ( level.inGracePeriod || getTimePassed() < acceptablePassedTime * 1000 )
			self.wasAliveAtMatchStart = true;
	}

	if ( level.scr_thirdperson_enable == 0 ) {
		self setClientDvar( "cg_thirdPerson", "0" );
	}

	[[level.onSpawnPlayer]]();

	self maps\mp\gametypes\_missions::playerSpawned();

	prof_end( "spawnPlayer_preUTS" );

	level thread updateTeamStatus();

	prof_begin( "spawnPlayer_postUTS" );

	if ( level.oldschool )
	{
		assert( !isDefined( self.class ) );
		self maps\mp\gametypes\_oldschool::giveLoadout();
		if ( !level.rankedMatch ) {
			self maps\mp\gametypes\_class_unranked::setClass( level.defaultClass );
		} else {
			self maps\mp\gametypes\_class::setClass( level.defaultClass );
		}
	}
	else
	{
		if ( level.gametype != "hns" || self.pers["team"] == game["attackers"] ) {
			assert( self isValidClass( self.class ) );
			if ( !level.rankedMatch ) {
				self maps\mp\gametypes\_class_unranked::setClass( self.class );
				self maps\mp\gametypes\_class_unranked::giveLoadout( self.team, self.class );
			} else {
				self maps\mp\gametypes\_class::setClass( self.class );
				self maps\mp\gametypes\_class::giveLoadout( self.team, self.class );
			}
		}
	}
	
	if ( level.inReadyUpPeriod ) {
		// Check if we need to disable the weapons
		if ( level.scr_match_readyup_disable_weapons == 1 ) {
			self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
		}

		self freezeControls( false );
		self.canDoCombat = false;

		self setClientDvar( "scr_objectiveText", getObjectiveHintText( self.pers["team"] ) );

		team = self.pers["team"];

		music = game["music"]["spawn_" + team];
		if ( level.splitscreen )
		{
			if ( isDefined( level.playedStartingMusic ) )
				music = undefined;
			else
				level.playedStartingMusic = true;
		}
		thread maps\mp\gametypes\_hud::showClientScoreBar( 5.0 );

	} else if ( level.inStrategyPeriod ) {
		self freezeControls( true );
		self setClientDvar( "scr_objectiveText", getObjectiveHintText( self.pers["team"] ) );

		team = self.pers["team"];

		music = game["music"]["spawn_" + team];
		if ( level.splitscreen )
		{
			if ( isDefined( level.playedStartingMusic ) )
				music = undefined;
			else
				level.playedStartingMusic = true;
		}

		thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"][team + "_name"], undefined, game["icons"][team], game["colors"][team], music );
		if ( isDefined( game["dialog"]["gametype"] ) && (!level.splitscreen || self == level.players[0]) )
			self leaderDialogOnPlayer( "gametype" );

		thread maps\mp\gametypes\_hud::showClientScoreBar( 5.0 );

	} else if ( level.inPrematchPeriod ) {
		self freezeControls( true );

		self setClientDvar( "scr_objectiveText", getObjectiveHintText( self.pers["team"] ) );

		team = self.pers["team"];

		music = game["music"]["spawn_" + team];
		if ( level.splitscreen )
		{
			if ( isDefined( level.playedStartingMusic ) )
				music = undefined;
			else
				level.playedStartingMusic = true;
		}

		thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"][team + "_name"], undefined, game["icons"][team], game["colors"][team], music );
		if ( isDefined( game["dialog"]["gametype"] ) && (!level.splitscreen || self == level.players[0]) )
			self leaderDialogOnPlayer( "gametype" );

		thread maps\mp\gametypes\_hud::showClientScoreBar( 5.0 );
	}
	else
	{
		if ( level.gametype == "hns" && self.pers["team"] == game["attackers"] && level.inHidingPeriod ) {
			self freezeControls( true );
		} else {
			self freezeControls( false );
		}		
		
		self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
		if ( !hadSpawned && game["state"] == "playing" )
		{
			team = self.team;

			music = game["music"]["spawn_" + team];
			if ( level.splitscreen )
			{
				if ( isDefined( level.playedStartingMusic ) )
					music = undefined;
				else
					level.playedStartingMusic = true;
			}

			thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"][team + "_name"], undefined, game["icons"][team], game["colors"][team], music );
				
			if ( level.gametype != "hns" ) {
				if ( isDefined( game["dialog"]["gametype"] ) && (!level.splitscreen || self == level.players[0]) )
				{
					self leaderDialogOnPlayer( "gametype" );
					if ( team == game["attackers"] )
						self leaderDialogOnPlayer( "offense_obj", "introboost" );
					else
						self leaderDialogOnPlayer( "defense_obj", "introboost" );
				}
			}

			self setClientDvar( "scr_objectiveText", getObjectiveHintText( self.pers["team"] ) );
			thread maps\mp\gametypes\_hud::showClientScoreBar( 5.0 );
		}
	}

	if ( getdvar( "scr_showperksonspawn" ) == "" )
		setdvar( "scr_showperksonspawn", "1" );

	if ( !level.splitscreen && getdvarint( "scr_showperksonspawn" ) == 1 && game["state"] != "postgame" )
	{
		perks = getPerks( self );
		self showPerk( 0, perks[0], -50 );
		self showPerk( 1, perks[1], -50 );
		self showPerk( 2, perks[2], -50 );
		self thread hidePerksAfterTime( 3.0 );
		self thread hidePerksOnDeath();
	}

	prof_end( "spawnPlayer_postUTS" );

	waittillframeend;
	self notify( "spawned_player" );

	self logstring( "S " + self.origin[0] + " " + self.origin[1] + " " + self.origin[2] );

	self thread maps\mp\gametypes\_hardpoints::hardpointItemWaiter();

	if ( game["state"] == "postgame" )
	{
		assert( !level.intermission );
		// We're in the victory screen, but before intermission
		self freezePlayerForRoundEnd();
	}
}

hidePerksAfterTime( delay )
{
	self endon("disconnect");
	self endon("perks_hidden");

	wait delay;

	self thread hidePerk( 0, 2.0 );
	self thread hidePerk( 1, 2.0 );
	self thread hidePerk( 2, 2.0 );
	self notify("perks_hidden");
}

hidePerksOnDeath()
{
	self endon("disconnect");
	self endon("perks_hidden");

	self waittill("death");

	self hidePerk( 0 );
	self hidePerk( 1 );
	self hidePerk( 2 );
	self notify("perks_hidden");
}

hidePerksOnKill()
{
	self endon("disconnect");
	self endon("death");
	self endon("perks_hidden");

	self waittill( "killed_player" );

	self hidePerk( 0 );
	self hidePerk( 1 );
	self hidePerk( 2 );
	self notify("perks_hidden");
}


testMenu()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	for ( ;; )
	{
		wait ( 10.0 );

		notifyData = spawnStruct();
		notifyData.titleText = &"MP_CHALLENGE_COMPLETED";
		notifyData.notifyText = "wheee";
		notifyData.sound = "mp_challenge_complete";

		self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
	}
}

testShock()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	for ( ;; )
	{
		wait ( 3.0 );

		numShots = randomInt( 6 );

		for ( i = 0; i < numShots; i++ )
		{
			iPrintLnBold( numShots );
			self shellShock( "frag_grenade_mp", 0.2 );
			wait ( 0.1 );
		}
	}
}

testHPs()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	hps = [];
	hps[hps.size] = "radar_mp";
	hps[hps.size] = "airstrike_mp";
	hps[hps.size] = "helicopter_mp";

	for ( ;; )
	{
//		hp = hps[randomInt(hps.size)];
		hp = "radar_mp";
		if ( self thread maps\mp\gametypes\_hardpoints::giveHardpointItem( hp ) )
		{
			self playLocalSound( level.hardpointInforms[hp] );
		}

//		self thread maps\mp\gametypes\_hardpoints::upgradeHardpointItem();

		wait ( 20.0 );
	}
}


spawnSpectator( origin, angles )
{
	self notify("spawned");
	self notify("end_respawn");
	in_spawnSpectator( origin, angles );
}

// spawnSpectator clone without notifies for spawning between respawn delays
respawn_asSpectator( origin, angles )
{
	in_spawnSpectator( origin, angles );
}

// spawnSpectator helper
in_spawnSpectator( origin, angles )
{
	self setSpawnVariables();

	// don't clear lower message if not actually a spectator,
	// because it probably has important information like when we'll spawn
	if ( self.pers["team"] == "spectator" )
		self clearLowerMessage();

	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;

	if(self.pers["team"] == "spectator")
		self.statusicon = "";
	else {
		// Check if we should show the player status
		if ( level.scr_show_player_status == 1 ) {
			self.statusicon = "hud_status_dead";
		} else {
			self.statusicon = "";
		}
	}

	// Check if this player can free spectate
	maps\mp\gametypes\_spectating::setSpectatePermissions();

	[[level.onSpawnSpectator]]( origin, angles );

	if ( level.gametype == "hns" || level.scr_allow_thirdperson == 1 || isSubStr( level.scr_allow_thirdperson_guids, self getGuid() ) ) {
		self thread spectatorThirdPersonness();
	}

	level thread updateTeamStatus();
}

spectatorThirdPersonness()
{
	self endon("disconnect");
	self endon("spawned");

	self notify("spectator_thirdperson_thread");
	self endon("spectator_thirdperson_thread");

	self.spectatingThirdPerson = false;

	self setThirdPerson( true );
}

getPlayerFromClientNum( clientNum )
{
	if ( clientNum < 0 )
		return undefined;

	for ( i = 0; i < level.players.size; i++ )
	{
		if ( level.players[i] getEntityNumber() == clientNum )
			return level.players[i];
	}
	return undefined;
}

setThirdPerson( value )
{
	if ( value != self.spectatingThirdPerson )
	{
		self.spectatingThirdPerson = value;
		if ( value )
		{
			self setClientDvar( "cg_thirdPerson", "1" );
			//self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
			//self setClientDvar( "cg_fov", "40" );
		}
		else
		{
			self setClientDvar( "cg_thirdPerson", "0" );
			//self setDepthOfField( 0, 0, 512, 4000, 4, 0 );
			//self setClientDvar( "cg_fov", "65" );
		}
	}
}

waveSpawnTimer()
{
	level endon( "game_ended" );

	while ( game["state"] == "playing" )
	{
		time = getTime();

		if ( time - level.lastWave["allies"] > (level.waveDelay["allies"] * 1000) )
		{
			level notify ( "wave_respawn_allies" );
			level.lastWave["allies"] = time;
			level.wavePlayerSpawnIndex["allies"] = 0;
		}

		if ( time - level.lastWave["axis"] > (level.waveDelay["axis"] * 1000) )
		{
			level notify ( "wave_respawn_axis" );
			level.lastWave["axis"] = time;
			level.wavePlayerSpawnIndex["axis"] = 0;
		}

		wait ( 0.05 );
	}
}


default_onSpawnSpectator( origin, angles)
{
	if( isDefined( origin ) && isDefined( angles ) )
	{
		self spawn(origin, angles);
		return;
	}

	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	assert( spawnpoints.size );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	self spawn(spawnpoint.origin, spawnpoint.angles);
	self notify("never_joined_team");
}

spawnIntermission()
{
	self notify("spawned");
	self notify("end_respawn");

	self setSpawnVariables();

	self clearLowerMessage();

	self freezeControls( false );

	self setClientDvars(
		"cg_everyoneHearsEveryone", 1,
		"cg_drawhealth", 0
	);

	if ( !level.mapVotingInProgress ) {
		self.sessionstate = "intermission";
	} else {
		self.sessionstate = "spectator";
	}
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;

	[[level.onSpawnIntermission]]();
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
}


default_onSpawnIntermission()
{
	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
//	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);
	spawnpoint = spawnPoints[0];

	if( isDefined( spawnpoint ) )
		self spawn( spawnpoint.origin, spawnpoint.angles );
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
}

// returns the best guess of the exact time until the scoreboard will be displayed and player control will be lost.
// returns undefined if time is not known
timeUntilRoundEnd()
{
	if ( level.gameEnded )
	{
		timePassed = (getTime() - level.gameEndTime) / 1000;
		timeRemaining = level.postRoundTime - timePassed;

		if ( timeRemaining < 0 )
			return 0;

		return timeRemaining;
	}

	if ( level.inOvertime )
		return undefined;

	if ( level.timeLimit <= 0 )
		return undefined;

	if ( !isDefined( level.startTime ) )
		return undefined;

	timePassed = (getTime() - level.startTime)/1000;
	timeRemaining = (level.timeLimit * 60) - timePassed;

	return timeRemaining + level.postRoundTime;
}

freezePlayerForRoundEnd()
{
	self clearLowerMessage();

	self closeMenu();
	self closeInGameMenu();

	self freezeControls( true );
	self hideHUD();
}


logXPGains()
{
	if ( !isDefined( self.xpGains ) )
		return;

	xpTypes = getArrayKeys( self.xpGains );
	for ( index = 0; index < xpTypes.size; index++ )
	{
		gain = self.xpGains[xpTypes[index]];
		if ( !gain )
			continue;

		self logString( "xp " + xpTypes[index] + ": " + gain );
	}
}

freeGameplayHudElems()
{
	// free up some hud elems so we have enough for other things.

	// perk icons
	if ( isdefined( self.perkicon ) )
	{
		if ( isdefined( self.perkicon[0] ) )
		{
			self.perkicon[0] destroyElem();
			self.perkname[0] destroyElem();
		}
		if ( isdefined( self.perkicon[1] ) )
		{
			self.perkicon[1] destroyElem();
			self.perkname[1] destroyElem();
		}
		if ( isdefined( self.perkicon[2] ) )
		{
			self.perkicon[2] destroyElem();
			self.perkname[2] destroyElem();
		}
	}
	self notify("perks_hidden"); // stop any threads that are waiting to hide the perk icons

	// lower message
	self.lowerMessage destroyElem();
	self.lowerTimer destroyElem();

	// progress bar
	if ( isDefined( self.proxBar ) )
		self.proxBar destroyElem();
	if ( isDefined( self.proxBarText ) )
		self.proxBarText destroyElem();
}


getHostPlayer()
{
	players = getEntArray( "player", "classname" );

	for ( index = 0; index < players.size; index++ )
	{
		if ( players[index] getEntityNumber() == 0 )
			return players[index];
	}
}


hostIdledOut()
{
	hostPlayer = getHostPlayer();

	// host never spawned
	if ( isDefined( hostPlayer ) && !hostPlayer.hasSpawned && !isDefined( hostPlayer.selectedClass ) )
		return true;

	return false;
}


endGame( winner, endReasonText )
{
	// return if already ending via host quit or victory
	if ( game["state"] == "postgame" || level.gameEnded )
		return;

	if ( isDefined( level.onEndGame ) )
		[[level.onEndGame]]( winner );
	
	visionSetNaked( "mpOutro", 2.0 );
		
	game["state"] = "postgame";
	level.gameEndTime = getTime();
	level.gameEnded = true;
	level.inGracePeriod = false;
	level notify ( "game_ended" );
	
	setGameEndTime( 0 ); // stop/hide the timers

	if ( level.rankedMatch || level.scr_server_rank_type == 2 )
	{
		setXenonRanks();

		if ( hostIdledOut() )
		{
			level.hostForcedEnd = true;
			logString( "host idled out" );
			endLobby();
		}
	}

	updatePlacement();
	updateMatchBonusScores( winner );
	updateWinLossStats( winner );

	setdvar( "g_deadChat", 1 );

	serverHideHUD();

	// freeze players
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];

		player freezePlayerForRoundEnd();
		player thread roundEndDoF( 4.0 );

		player freeGameplayHudElems();

		player setClientDvars(
			"cg_everyoneHearsEveryone", 1,
			"cg_drawhealth", 0
		);

		if( level.rankedMatch || level.scr_server_rank_type == 2 )
		{
			if ( isDefined( player.setPromotion ) )
				player setClientDvar( "ui_lobbypopup", "promotion" );
			else
				player setClientDvar( "ui_lobbypopup", "summary" );
		}
	}

    // end round
    game["roundsplayed"]++;
    
    // See if we need to perform a check for the game
    if ( level.scr_overtime_enable == 1 && !isDefined( game["_overtime"] ) ) {
    	openwarfare\_overtime::checkGameState();
    }

    if ( (level.roundLimit > 1 || (!level.roundLimit && level.scoreLimit != 1)) && !level.forcedEnd )
    {
		if ( level.displayRoundEndText )
		{
			players = level.players;
			for ( index = 0; index < players.size; index++ )
			{
				player = players[index];

				if ( level.teamBased && level.gametype != "bel" )
					player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, true, endReasonText );
				else
					player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText );
			}

			if ( ( level.teamBased && level.gametype != "bel" ) && !(hitRoundLimit() || hitScoreLimit()) )
				thread announceRoundWinner( winner, level.roundEndDelay / 4 );

			if ( hitRoundLimit() || hitScoreLimit() )
				roundEndWait( level.roundEndDelay / 2, false );
			else
				roundEndWait( level.roundEndDelay, true );
		}

		roundSwitching = false;

		if ( !hitRoundLimit() && !hitScoreLimit() )
			roundSwitching = checkRoundSwitch();
			
		if ( isDefined( game["_overtime"] ) ) {
			level.halftimeType = "overtime";
			level.halftimeSubCaption = &"OW_LAST_ROUND";			
		}

		if ( roundSwitching && level.teamBased )
		{
			players = level.players;
			for ( index = 0; index < players.size; index++ )
			{
				player = players[index];

				if ( !isdefined(level.scr_showscore_spectator) || isdefined(level.scr_showscore_spectator) && level.scr_showscore_spectator == 0 )
				{
					if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
					{
						player [[level.spawnIntermission]]();
						player closeMenu();
						player closeInGameMenu();
						continue;
					}
				}

				switchType = level.halftimeType;
				if ( switchType == "halftime" )
				{
					if ( level.roundLimit )
					{
						if ( (game["roundsplayed"] * 2) == level.roundLimit )
							switchType = "halftime";
						else
							switchType = "intermission";
					}
					else if ( level.scoreLimit )
					{
						if ( game["roundsplayed"] == (level.scoreLimit - 1) )
							switchType = "halftime";
						else
							switchType = "intermission";
					}
					else
					{
						switchType = "intermission";
					}
				}
				switch( switchType )
				{
					case "halftime":
						player leaderDialogOnPlayer( "halftime" );
						break;
					case "overtime":
						player leaderDialogOnPlayer( "overtime" );
						break;
					default:
						player leaderDialogOnPlayer( "side_switch" );
						break;
				}
				player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( switchType, true, level.halftimeSubCaption );
			}

			roundEndWait( level.halftimeRoundEndDelay, false );
		}
		else if ( !hitRoundLimit() && !hitScoreLimit() && !level.displayRoundEndText && level.teamBased )
		{
			players = level.players;
			for ( index = 0; index < players.size; index++ )
			{
				player = players[index];

				if ( !isdefined(level.scr_showscore_spectator) || isdefined(level.scr_showscore_spectator) && level.scr_showscore_spectator == 0 )
				{
					if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
					{
						player [[level.spawnIntermission]]();
						player closeMenu();
						player closeInGameMenu();
						continue;
					}
				}

				switchType = level.halftimeType;
				if ( switchType == "halftime" )
				{
					if ( level.roundLimit )
					{
						if ( (game["roundsplayed"] * 2) == level.roundLimit )
							switchType = "halftime";
						else
							switchType = "roundend";
					}
					else if ( level.scoreLimit )
					{
						if ( game["roundsplayed"] == (level.scoreLimit - 1) )
							switchType = "halftime";
						else
							switchTime = "roundend";
					}
				}
				switch( switchType )
				{
					case "halftime":
						player leaderDialogOnPlayer( "halftime" );
						break;
					case "overtime":
						player leaderDialogOnPlayer( "overtime" );
						break;
				}
				player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( switchType, true, endReasonText );
			}

			roundEndWait( level.halftimeRoundEndDelay, !(hitRoundLimit() || hitScoreLimit()) );
		}

    if ( !hitRoundLimit() && !hitScoreLimit() )
    {
    	game["state"] = "playing";
			if ( level.teamBalance )
			{
				level notify ( "roundSwitching" );
				wait 1;
			}               	
    	level notify ( "restarting" );
      
      map_restart( true );
      return;
    }

		if ( hitRoundLimit() )
			endReasonText = game["strings"]["round_limit_reached"];
		else if ( hitScoreLimit() )
			endReasonText = game["strings"]["score_limit_reached"];
		else
			endReasonText = game["strings"]["time_limit_reached"];
	}

	thread maps\mp\gametypes\_missions::roundEnd( winner );

	if ( ( level.teamBased && level.gametype != "bel" ) && hitRoundLimit() ) {
		if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
			winner = "tie";
		else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
			winner = "axis";
		else
			winner = "allies";
	}

	// catching gametype, since DM forceEnd sends winner as player entity, instead of string
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];

		if ( !isdefined(level.scr_showscore_spectator) || isdefined(level.scr_showscore_spectator) && level.scr_showscore_spectator == 0 )
		{
			if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
			{
				player [[level.spawnIntermission]]();
				player closeMenu();
				player closeInGameMenu();
				continue;
			}
		}

		if ( level.teamBased && level.gametype != "bel" ) {
			player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, false, endReasonText );
		}	else {
			player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText );

			if ( isDefined( winner ) && player == winner )
				player playLocalSound( game["music"]["victory_" + player.pers["team"] ] );
			else if ( !level.splitScreen )
				player playLocalSound( game["music"]["defeat"] );
		}
	}

	if ( level.teamBased && level.gametype != "bel" )
	{
		thread announceGameWinner( winner, level.postRoundTime / 2 );

		if ( level.splitscreen )
		{
			if ( winner == "allies" )
				playSoundOnPlayers( game["music"]["victory_allies"], "allies" );
			else if ( winner == "axis" )
				playSoundOnPlayers( game["music"]["victory_axis"], "axis" );
			else
				playSoundOnPlayers( game["music"]["defeat"] );
		}
		else
		{
			if ( winner == "allies" )
			{
				playSoundOnPlayers( game["music"]["victory_allies"], "allies" );
				playSoundOnPlayers( game["music"]["defeat"], "axis" );
			}
			else if ( winner == "axis" )
			{
				playSoundOnPlayers( game["music"]["victory_axis"], "axis" );
				playSoundOnPlayers( game["music"]["defeat"], "allies" );
			}
			else
			{
				playSoundOnPlayers( game["music"]["defeat"] );
			}
		}
	}

	roundEndWait( level.postRoundTime, true );

	level.intermission = true;
	level notify("intermission");

	//regain players array since some might've disconnected during the wait above
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];

		player closeMenu();
		player closeInGameMenu();
		player notify ( "reset_outcome" );
		player thread spawnIntermission();
		
		if ( isDefined( game["menu_eog_main"] ) )
			player setClientDvar( "g_scriptMainMenu", game["menu_eog_main"] );
	}
	
	logString( "game ended" );
	wait getDvarFloat( "scr_show_unlock_wait" );

	if( level.console )
	{
		exitLevel( false );
		return;
	}

	if ( ( level.rankedMatch || level.scr_server_rank_type == 2 ) || level.scr_endofgame_stats_enable == 1 ) {
		if ( level.scr_endofgame_stats_enable == 1 ) {
			wait (1.0);
		}
		
		// popup for game summary
		players = level.players;
		for ( index = 0; index < players.size; index++ )
		{
			player = players[index];
			
			if ( level.scr_endofgame_stats_enable == 1 ) {
				player openMenu( game["menu_eog_stats"] );
			} else {
				player openMenu( game["menu_eog_unlock"] );
			}
		}
	}

	thread timeLimitClock_Intermission( level.scr_intermission_time, ( level.scr_amvs_enable == 0 || game["amvs_skip_voting"] ) );
	wait (level.scr_intermission_time);

	if ( level.scr_eog_fastrestart != 0 ) {	
		fastRestarts = getDvarInt( "ow_fastrestarts" );
		
		if ( fastRestarts == level.scr_eog_fastrestart ) {
			setDvar("ow_fastrestarts", 0 );
		} else {
			setDvar("ow_fastrestarts", fastRestarts+1 );
			map_restart( false );
		}
	}
	
	openwarfare\_advancedmvs::mapVoting_Intermission();
	
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		//iPrintLnBold( "closing eog summary!" );
		player closeMenu();
		player closeInGameMenu();
	}

	exitLevel( false );
}


getWinningTeam()
{
	if ( getGameScore( "allies" ) == getGameScore( "axis" ) )
		winner = "tie";
	else if ( getGameScore( "allies" ) > getGameScore( "axis" ) )
		winner = "allies";
	else
		winner = "axis";
		
	return winner;
}


roundEndWait( defaultDelay, matchBonus )
{
	notifiesDone = false;
	while ( !notifiesDone )
	{
		players = level.players;
		notifiesDone = true;
		for ( index = 0; index < players.size; index++ )
		{
			if ( !isDefined( players[index].doingNotify ) || !players[index].doingNotify )
				continue;

			notifiesDone = false;
		}
		wait ( 0.5 );
	}

	if ( !matchBonus )
	{
		wait ( defaultDelay );
		return;
	}

    wait ( defaultDelay / 2 );
	level notify ( "give_match_bonus" );
	wait ( defaultDelay / 2 );

	notifiesDone = false;
	while ( !notifiesDone )
	{
		players = level.players;
		notifiesDone = true;
		for ( index = 0; index < players.size; index++ )
		{
			if ( !isDefined( players[index].doingNotify ) || !players[index].doingNotify )
				continue;

			notifiesDone = false;
		}
		wait ( 0.5 );
	}
}


roundEndDOF( time )
{
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
}


updateMatchBonusScores( winner )
{
	if ( !game["timepassed"] )
		return;

	if ( !level.rankedMatch && level.scr_server_rank_type != 2 )
		return;

	if ( !level.timeLimit || level.forcedEnd )
	{
		gameLength = getTimePassed() / 1000;
		// cap it at 20 minutes to avoid exploiting
		gameLength = min( gameLength, 1200 );
	}
	else
	{
		gameLength = level.timeLimit * 60;
	}

	if ( level.teamBased && level.gametype != "bel" )
	{
		if ( winner == "allies" )
		{
			winningTeam = "allies";
			losingTeam = "axis";
		}
		else if ( winner == "axis" )
		{
			winningTeam = "axis";
			losingTeam = "allies";
		}
		else
		{
			winningTeam = "tie";
			losingTeam = "tie";
		}

		if ( winningTeam != "tie" )
		{
			winnerScale = maps\mp\gametypes\_rank::getScoreInfoValue( "win" );
			loserScale = maps\mp\gametypes\_rank::getScoreInfoValue( "loss" );
		}
		else
		{
			winnerScale = maps\mp\gametypes\_rank::getScoreInfoValue( "tie" );
			loserScale = maps\mp\gametypes\_rank::getScoreInfoValue( "tie" );
		}

		players = level.players;
		for( i = 0; i < players.size; i++ )
		{
			player = players[i];

			if ( player.timePlayed["total"] < 1 || player.pers["participation"] < 1 )
			{
				player thread maps\mp\gametypes\_rank::endGameUpdate();
				continue;
			}

			// no bonus for hosts who force ends
			if ( level.hostForcedEnd && player getEntityNumber() == 0 )
				continue;

			spm = player maps\mp\gametypes\_rank::getSPM();
			if ( winningTeam == "tie" )
			{
				playerScore = int( (winnerScale * ((gameLength/60) * spm)) * (player.timePlayed["total"] / gameLength) );
				player thread giveMatchBonus( "tie", playerScore );
				player.matchBonus = playerScore;
			}
			else if ( isDefined( player.pers["team"] ) && player.pers["team"] == winningTeam )
			{
				playerScore = int( (winnerScale * ((gameLength/60) * spm)) * (player.timePlayed["total"] / gameLength) );
				player thread giveMatchBonus( "win", playerScore );
				player.matchBonus = playerScore;
			}
			else if ( isDefined(player.pers["team"] ) && player.pers["team"] == losingTeam )
			{
				playerScore = int( (loserScale * ((gameLength/60) * spm)) * (player.timePlayed["total"] / gameLength) );
				player thread giveMatchBonus( "loss", playerScore );
				player.matchBonus = playerScore;
			}
		}
	}
	else
	{
		if ( isDefined( winner ) )
		{
			winnerScale = maps\mp\gametypes\_rank::getScoreInfoValue( "win" );
			loserScale = maps\mp\gametypes\_rank::getScoreInfoValue( "loss" );
		}
		else
		{
			winnerScale = maps\mp\gametypes\_rank::getScoreInfoValue( "tie" );
			loserScale = maps\mp\gametypes\_rank::getScoreInfoValue( "tie" );
		}

		players = level.players;
		for( i = 0; i < players.size; i++ )
		{
			player = players[i];

			if ( player.timePlayed["total"] < 1 || player.pers["participation"] < 1 )
			{
				player thread maps\mp\gametypes\_rank::endGameUpdate();
				continue;
			}

			spm = player maps\mp\gametypes\_rank::getSPM();

			isWinner = false;
			for ( pIdx = 0; pIdx < min( level.placement["all"][0].size, 3 ); pIdx++ )
			{
				if ( level.placement["all"][pIdx] != player )
					continue;
				isWinner = true;
			}

			if ( isWinner )
			{
				playerScore = int( (winnerScale * ((gameLength/60) * spm)) * (player.timePlayed["total"] / gameLength) );
				player thread giveMatchBonus( "win", playerScore );
				player.matchBonus = playerScore;
			}
			else
			{
				playerScore = int( (loserScale * ((gameLength/60) * spm)) * (player.timePlayed["total"] / gameLength) );
				player thread giveMatchBonus( "loss", playerScore );
				player.matchBonus = playerScore;
			}
		}
	}
}


giveMatchBonus( scoreType, score )
{
	self endon ( "disconnect" );

	level waittill ( "give_match_bonus" );

	self maps\mp\gametypes\_rank::giveRankXP( scoreType, score );
	logXPGains();

	self maps\mp\gametypes\_rank::endGameUpdate();
}


setXenonRanks( winner )
{
	players = level.players;

	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if( !isdefined(player.score) || !isdefined(player.pers["team"]) )
			continue;

	}

	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if( !isdefined(player.score) || !isdefined(player.pers["team"]) )
			continue;

		setPlayerTeamRank( player, i, player.score - 5 * player.deaths );
		player logString( "team: score " + player.pers["team"] + ":" + player.score );
	}
	sendranks();
}


getHighestScoringPlayer()
{
	players = level.players;
	winner = undefined;
	tie = false;

	for( i = 0; i < players.size; i++ )
	{
		if ( !isDefined( players[i].score ) )
			continue;

		if ( players[i].score < 1 )
			continue;

		if ( !isDefined( winner ) || players[i].score > winner.score )
		{
			winner = players[i];
			tie = false;
		}
		else if ( players[i].score == winner.score )
		{
			tie = true;
		}
	}

	if ( tie || !isDefined( winner ) )
		return undefined;
	else
		return winner;
}


checkTimeLimit()
{
	if ( isDefined( level.timeLimitOverride ) && level.timeLimitOverride )
		return;

	if ( game["state"] != "playing" )
	{
		setGameEndTime( 0 );
		return;
	}

	if ( level.timeLimit <= 0 )
	{
		setGameEndTime( 0 );
		return;
	}

	if ( level.inPrematchPeriod )
	{
		setGameEndTime( 0 );
		return;
	}

	if ( !isdefined( level.startTime ) )
		return;

	timeLeft = getTimeRemaining();

	// want this accurate to the millisecond
	setGameEndTime( getTime() + int(timeLeft) );

	if ( timeLeft > 0 )
		return;

	[[level.onTimeLimit]]();
}

getTimeRemaining()
{
	return level.timeLimit * 60 * 1000 - getTimePassed();
}

checkScoreLimit()
{
	if ( game["state"] != "playing" )
		return;

	if ( level.scoreLimit <= 0 )
		return;

	if ( level.teamBased && level.gametype != "bel" )
	{
		if( game["teamScores"]["allies"] < level.scoreLimit && game["teamScores"]["axis"] < level.scoreLimit )
			return;
	}
	else
	{
		if ( !isPlayer( self ) )
			return;

		if ( self.score < level.scoreLimit )
			return;
	}

	[[level.onScoreLimit]]();
}


hitRoundLimit()
{
	if( level.roundLimit <= 0 )
		return false;

	return ( game["roundsplayed"] >= level.roundLimit );
}

hitScoreLimit()
{
	if( level.scoreLimit <= 0 )
		return false;

	if ( level.teamBased && level.gametype != "bel" )
	{
		if( game["teamScores"]["allies"] >= level.scoreLimit || game["teamScores"]["axis"] >= level.scoreLimit )
			return true;
	}
	else
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( isDefined( player.score ) && player.score >= level.scorelimit )
				return true;
		}
	}
	return false;
}

registerRoundSwitchDvar( dvarString, defaultValue, minValue, maxValue )
{
	dvarString = ("scr_" + dvarString + "_roundswitch");

	level.roundswitchDvar = dvarString;
	level.roundswitchMin = minValue;
	level.roundswitchMax = maxValue;
	level.roundswitch = getdvarx( dvarString, "int", defaultValue, minValue, maxValue );
}

registerRoundLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	dvarString = ("scr_" + dvarString + "_roundlimit");

	level.roundLimitDvar = dvarString;
	level.roundlimitMin = minValue;
	level.roundlimitMax = maxValue;
	level.roundLimit = getdvarx( dvarString, "int", defaultValue, minValue, maxValue );
	
	// Check if we need to increase the number of rounds due to overtime
	if ( isDefined( game["_overtime"] ) )
		level.roundLimit++;
}


registerScoreLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	dvarString = ("scr_" + dvarString + "_scorelimit");

	level.scoreLimitDvar = dvarString;
	level.scorelimitMin = minValue;
	level.scorelimitMax = maxValue;
	level.scoreLimit = getdvarx( dvarString, "int", defaultValue, minValue, maxValue );

	setDvar( "ui_scorelimit", level.scoreLimit );
}


registerTimeLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	level.timeLimitDvar = dvarString;
	level.timelimitMin = minValue;
	level.timelimitMax = maxValue;

	// Check if we need to use the timelimit due to overtime
	if ( isDefined( game["_overtime"] ) ) {
		openwarfare\_overtime::registerTimeLimitDvar();

	} else {
		dvarString = ("scr_" + dvarString + "_timelimit");
		level.timelimit = getdvarx( dvarString, "float", defaultValue, minValue, maxValue );
		setDvar( "ui_timelimit", level.timelimit );
	}
}


registerNumLivesDvar( dvarString, defaultValue, minValue, maxValue )
{
	level.numLivesDvar = dvarString;
	level.numLivesMin = minValue;
	level.numLivesMax = maxValue;

	// Check if we need to use the number of lives due to overtime
	if ( isDefined( game["_overtime"] ) ) {
		openwarfare\_overtime::registerNumLivesDvar();
	} else {
		dvarString = ("scr_" + dvarString + "_numlives");
		level.numLives = getdvarx( dvarString, "int", defaultValue, minValue, maxValue );
	}
}


getValueInRange( value, minValue, maxValue )
{
	if ( value > maxValue )
		return maxValue;
	else if ( value < minValue )
		return minValue;
	else
		return value;
}

updateGameTypeDvars()
{
	level endon ( "game_ended" );

	while ( game["state"] == "playing" )
	{
		
		if ( !isDefined( game["_overtime"] ) ) {
			roundlimit = getdvarx( level.roundLimitDvar, "int", level.roundlimit, level.roundLimitMin, level.roundLimitMax );
			if ( roundlimit != level.roundlimit )
			{
				level.roundlimit = roundlimit;
				level notify ( "update_roundlimit" );
			}
	
			timeLimit = getdvarx( level.timeLimitDvar, "float", level.timeLimit, level.timeLimitMin, level.timeLimitMax );
			if ( timeLimit != level.timeLimit )
			{
				level.timeLimit = timeLimit;
				setDvar( "ui_timelimit", level.timeLimit );
				level notify ( "update_timelimit" );
			}
		}
		thread checkTimeLimit();

		scoreLimit = getdvarx( level.scoreLimitDvar, "int", level.scoreLimit, level.scoreLimitMin, level.scoreLimitMax );
		if ( scoreLimit != level.scoreLimit )
		{
			level.scoreLimit = scoreLimit;
			setDvar( "ui_scorelimit", level.scoreLimit );
			level notify ( "update_scorelimit" );
		}
		thread checkScoreLimit();

		// make sure we check time limit right when game ends
		if ( isdefined( level.startTime ) )
		{
			if ( getTimeRemaining() < 3000 )
			{
				wait .1;
				continue;
			}
		}
		wait 1;
	}
}


menuAutoAssign()
{
	teams[0] = "allies";
	teams[1] = "axis";
	assignment = teams[randomInt(2)];

	self closeMenus();

	// Ignore auto-assign request if the player is already assigned to a team (prevent people 
	// from switching sides in gametypes where this can give a personal advantage to the player)
	if ( isDefined( self.pers ) && isDefined( self.pers["team"] ) && self.pers["team"] != "spectator" )
		return;

	if ( level.teamBased )
	{
		if ( getDvarInt( "party_autoteams" ) == 1 )
		{
			teamNum = getAssignedTeam( self );
			switch ( teamNum )
			{
				case 1:
					assignment = teams[1];
					break;

				case 2:
					assignment = teams[0];
					break;

				default:
					assignment = "";
			}
		}

		if ( assignment == "" || getDvarInt( "party_autoteams" ) == 0 )
		{
			playerCounts = self maps\mp\gametypes\_teams::CountPlayers();

			// if teams are equal return the team with the lowest score
			if ( playerCounts["allies"] == playerCounts["axis"] )
			{
				if( getTeamScore( "allies" ) == getTeamScore( "axis" ) )
					assignment = teams[randomInt(2)];
				else if ( getTeamScore( "allies" ) < getTeamScore( "axis" ) )
					assignment = "allies";
				else
					assignment = "axis";
			}
			else if( playerCounts["allies"] < playerCounts["axis"] )
			{
				assignment = "allies";
			}
			else
			{
				assignment = "axis";
			}
		}

		if ( assignment == self.pers["team"] && (self.sessionstate == "playing" || self.sessionstate == "dead") )
		{
			self beginClassChoice();
			return;
		}
	}

	if ( assignment != self.pers["team"] && (self.sessionstate == "playing" || self.sessionstate == "dead") )
	{
		self.switching_teams = true;
		self.joining_team = assignment;
		self.leaving_team = self.pers["team"];
		self suicidePlayer();
	}

	self.pers["team"] = assignment;
	self.team = assignment;
	if ( self resetPlayerClassOnTeamSwitch( false ) ) {
		self.pers["class"] = undefined;
		self.class = undefined;
	}
	self.pers["weapon"] = undefined;
	self.pers["savedmodel"] = undefined;

	self updateObjectiveText();

	if ( level.teamBased )
		self.sessionteam = assignment;
	else
	{
		self.sessionteam = "none";
	}

	if ( !isAlive( self ) ) {
		// Check if we should show the player status
		if ( level.scr_show_player_status == 1 ) {
			self.statusicon = "hud_status_dead";
		} else {
			self.statusicon = "";
		}
	}

	lpselfnum = self getEntityNumber();
	lpselfname = self.name;
	lpselfteam = self.pers["team"];
	lpselfguid = self getGuid();

	logPrint( "JT;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + "\n" );

	self notify("joined_team");
	self thread showPlayerJoinedTeam();
	self notify("end_respawn");

	self beginClassChoice();

	self setclientdvar( "g_scriptMainMenu", game[ "menu_class_" + self.pers["team"] ] );
}


updateObjectiveText()
{
	if ( self.pers["team"] == "spectator" )
	{
		self setClientDvar( "cg_objectiveText", "" );
		return;
	}

	if( level.scorelimit > 0 )
	{
		if ( level.splitScreen )
			self setclientdvar( "cg_objectiveText", getObjectiveScoreText( self.pers["team"] ) );
		else
			self setclientdvar( "cg_objectiveText", getObjectiveScoreText( self.pers["team"] ), level.scorelimit );
	}
	else
	{
		self setclientdvar( "cg_objectiveText", getObjectiveText( self.pers["team"] ) );
	}
}

closeMenus()
{
	self closeMenu();
	self closeInGameMenu();
}

beginClassChoice( forceNewChoice )
{
	assert( self.pers["team"] == "axis" || self.pers["team"] == "allies" );

	team = self.pers["team"];

	if ( level.oldschool )
	{
		// skip class choice and just spawn.

		self.pers["class"] = undefined;
		self.class = undefined;

		// open a menu that just sets the ui_team localvar
		self openMenu( game[ "menu_initteam_" + team ] );

		if ( self.sessionstate != "playing" && game["state"] == "playing" )
			self thread [[level.spawnClient]]();
		level thread updateTeamStatus();
		self thread maps\mp\gametypes\_spectating::setSpectatePermissions();

		return;
	}

	// menu_changeclass_team is the one where you choose one of the n classes to play as.
	// menu_class_team is where you can choose to change your team, class, controls, or leave game.
	self openMenu( game[ "menu_changeclass_" + team ] );
}

showMainMenuForTeam()
{
	assert( self.pers["team"] == "axis" || self.pers["team"] == "allies" );

	team = self.pers["team"];

	// menu_changeclass_team is the one where you choose one of the n classes to play as.
	// menu_class_team is where you can choose to change your team, class, controls, or leave game.

	self openMenu( game[ "menu_class_" + team ] );
}

menuAllies()
{
	self closeMenus();

	if(self.pers["team"] != "allies")
	{
		if (level.allow_teamchange == "0" && (isdefined(self.hasDoneCombat) && self.hasDoneCombat) )
		{
			return;
		}		
		
		if( level.teamBased && !maps\mp\gametypes\_teams::getJoinTeamPermissions( "allies" ) )
		{
			self openMenu(game["menu_team"]);
			return;
		}

		// allow respawn when switching teams during grace period.
		if ( level.inGracePeriod && (!isdefined(self.hasDoneCombat) || !self.hasDoneCombat) )
			self.hasSpawned = false;

		if(self.sessionstate == "playing")
		{
			self.switching_teams = true;
			self.joining_team = "allies";
			self.leaving_team = self.pers["team"];
			
			self suicidePlayer();
		}

		self.pers["team"] = "allies";
		self.team = "allies";
		if ( self resetPlayerClassOnTeamSwitch( false ) ) {
			self.pers["class"] = undefined;
			self.class = undefined;
		}
		self.pers["weapon"] = undefined;
		self.pers["savedmodel"] = undefined;

		self updateObjectiveText();

		if ( level.teamBased )
			self.sessionteam = "allies";
		else
			self.sessionteam = "none";

		self setclientdvar("g_scriptMainMenu", game["menu_class_allies"]);

		lpselfnum = self getEntityNumber();
		lpselfname = self.name;
		lpselfteam = self.pers["team"];
		lpselfguid = self getGuid();
	
		logPrint( "JT;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + "\n" );
	
		self notify("joined_team");
		self thread showPlayerJoinedTeam();
		self notify("end_respawn");
	}

	self beginClassChoice();
}


menuAxis()
{
	self closeMenus();

	if(self.pers["team"] != "axis")
	{
		if (level.allow_teamchange == "0" && (isdefined(self.hasDoneCombat) && self.hasDoneCombat) )
		{
			return;
		}		
		
		if( level.teamBased && !maps\mp\gametypes\_teams::getJoinTeamPermissions( "axis" ) )
		{
			self openMenu(game["menu_team"]);
			return;
		}

		// allow respawn when switching teams during grace period.
		if ( level.inGracePeriod && (!isdefined(self.hasDoneCombat) || !self.hasDoneCombat) )
			self.hasSpawned = false;

		if(self.sessionstate == "playing")
		{
			self.switching_teams = true;
			self.joining_team = "axis";
			self.leaving_team = self.pers["team"];
			
			self suicidePlayer();
		}

		self.pers["team"] = "axis";
		self.team = "axis";
		if ( self resetPlayerClassOnTeamSwitch( false ) ) {
			self.pers["class"] = undefined;
			self.class = undefined;
		}
		self.pers["weapon"] = undefined;
		self.pers["savedmodel"] = undefined;

		self updateObjectiveText();

		if ( level.teamBased )
			self.sessionteam = "axis";
		else
			self.sessionteam = "none";

		self setclientdvar("g_scriptMainMenu", game["menu_class_axis"]);

		lpselfnum = self getEntityNumber();
		lpselfname = self.name;
		lpselfteam = self.pers["team"];
		lpselfguid = self getGuid();
	
		logPrint( "JT;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + "\n" );

		self notify("joined_team");
		self thread showPlayerJoinedTeam();
		self notify("end_respawn");
	}

	self beginClassChoice();
}


menuSpectator()
{
	self closeMenus();

	if(self.pers["team"] != "spectator")
	{
		if(isAlive(self))
		{
			self.switching_teams = true;
			self.joining_team = "spectator";
			self.leaving_team = self.pers["team"];
			self suicidePlayer();
		}

		self.pers["team"] = "spectator";
		self.team = "spectator";
		self.pers["class"] = undefined;
		self.class = undefined;
		self.pers["weapon"] = undefined;
		self.pers["savedmodel"] = undefined;

		self updateObjectiveText();

		self.sessionteam = "spectator";
		[[level.spawnSpectator]]();

		self setclientdvar("g_scriptMainMenu", game["menu_team"]);

		self notify("joined_spectators");
	}
}


menuClass( response )
{
	self closeMenus();

	// clears new status of unlocked classes
	if ( response == "demolitions_mp,0" && self getstat( int( tablelookup( "mp/statstable.csv", 4, "feature_demolitions", 1 ) ) ) != 1 )
	{
		demolitions_stat = int( tablelookup( "mp/statstable.csv", 4, "feature_demolitions", 1 ) );
		self setstat( demolitions_stat, 1 );
		//println( "Demolitions class [new status cleared]: stat(" + demolitions_stat + ") = " + self getstat( demolitions_stat ) );
	}
	if ( response == "sniper_mp,0" && self getstat( int( tablelookup( "mp/statstable.csv", 4, "feature_sniper", 1 ) ) ) != 1 )
	{
		sniper_stat = int( tablelookup( "mp/statstable.csv", 4, "feature_sniper", 1 ) );
		self setstat( sniper_stat, 1 );
		//println( "Sniper class [new status cleared]: stat(" + sniper_stat + ") = " + self getstat( sniper_stat ) );
	}
	assert( !level.oldschool );

	// this should probably be an assert
	if(!isDefined(self.pers["team"]) || (self.pers["team"] != "allies" && self.pers["team"] != "axis"))
		return;

	if ( !level.rankedMatch ) {
		class = self maps\mp\gametypes\_class_unranked::getClassChoice( response );
		primary = self maps\mp\gametypes\_class_unranked::getWeaponChoice( response );
	} else {
		class = self maps\mp\gametypes\_class::getClassChoice( response );
		primary = self maps\mp\gametypes\_class::getWeaponChoice( response );
	}

	if ( class == "restricted" )
	{
		self beginClassChoice();
		return;
	}

	//if( (isDefined( self.pers["class"] ) && self.pers["class"] == class) &&
	//	(isDefined( self.pers["primary"] ) && self.pers["primary"] == primary) )
	//	return;

	if ( self.sessionstate == "playing" )
	{
		self.pers["class"] = class;
		self.class = class;
		self.pers["primary"] = primary;
		self.pers["weapon"] = undefined;

		if ( game["state"] == "postgame" )
			return;

		if ( ( ( level.inGracePeriod || level.inStrategyPeriod ) && !self.hasDoneCombat && ( level.gametype != "ass" || !isDefined( self.isVIP ) || !self.isVIP ) ) || ( level.gametype == "ftag" && self.freezeTag["frozen"] ) )
		{
			self thread deleteExplosives();

			if ( !level.rankedMatch ) {
				self maps\mp\gametypes\_class_unranked::setClass( self.pers["class"] );
				self.tag_stowed_back = undefined;
				self.tag_stowed_hip = undefined;
				self maps\mp\gametypes\_class_unranked::giveLoadout( self.pers["team"], self.pers["class"] );
			} else {
				self maps\mp\gametypes\_class::setClass( self.pers["class"] );
				self.tag_stowed_back = undefined;
				self.tag_stowed_hip = undefined;
				self maps\mp\gametypes\_class::giveLoadout( self.pers["team"], self.pers["class"] );
			}
		}
		else if ( !level.splitScreen )
		{
			self iPrintLnBold( game["strings"]["change_class"] );
		}
	}
	else
	{
		self.pers["class"] = class;
		self.class = class;
		self.pers["primary"] = primary;
		self.pers["weapon"] = undefined;

		if ( game["state"] == "postgame" )
			return;

		if ( game["state"] == "playing" )
			self thread [[level.spawnClient]]();
	}

	level thread updateTeamStatus();

	self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
}

/#
assertProperPlacement()
{
	numPlayers = level.placement["all"].size;
	for ( i = 0; i < numPlayers - 1; i++ )
	{
		if ( level.placement["all"][i].score < level.placement["all"][i + 1].score )
		{
			println("^1Placement array:");
			for ( i = 0; i < numPlayers; i++ )
			{
				player = level.placement["all"][i];
				println("^1" + i + ". " + player.name + ": " + player.score );
			}
			assertmsg( "Placement array was not properly sorted" );
			break;
		}
	}
}
#/


removeDisconnectedPlayerFromPlacement()
{
	offset = 0;
	numPlayers = level.placement["all"].size;
	found = false;
	for ( i = 0; i < numPlayers; i++ )
	{
		if ( level.placement["all"][i] == self )
			found = true;

		if ( found )
			level.placement["all"][i] = level.placement["all"][ i + 1 ];
	}
	if ( !found )
		return;

	level.placement["all"][ numPlayers - 1 ] = undefined;
	assert( level.placement["all"].size == numPlayers - 1 );

	/#
	// no longer calling this here because it's possible, due to delayed assist credit,
	// for someone's score to change after updatePlacement() is called.
	//assertProperPlacement();
	#/

	updateTeamPlacement();

	if ( level.teamBased && level.gametype != "bel" )
		return;

	numPlayers = level.placement["all"].size;
	for ( i = 0; i < numPlayers; i++ )
	{
		player = level.placement["all"][i];
		player notify( "update_outcome" );
	}

}

updatePlacement()
{
	prof_begin("updatePlacement");

	if ( !level.players.size )
		return;

	level.placement["all"] = [];
	for ( index = 0; index < level.players.size; index++ )
	{
		if ( level.players[index].team == "allies" || level.players[index].team == "axis" )
			level.placement["all"][level.placement["all"].size] = level.players[index];
	}

	placementAll = level.placement["all"];

	for ( i = 1; i < placementAll.size; i++ )
	{
		player = placementAll[i];
		playerScore = player.score;
		for ( j = i - 1; j >= 0 && (playerScore > placementAll[j].score || (playerScore == placementAll[j].score && player.deaths < placementAll[j].deaths)); j-- )
			placementAll[j + 1] = placementAll[j];
		placementAll[j + 1] = player;
	}

	level.placement["all"] = placementAll;

	/#
	assertProperPlacement();
	#/

	updateTeamPlacement();

	prof_end("updatePlacement");
}


updateTeamPlacement()
{
	placement["allies"]    = [];
	placement["axis"]      = [];
	placement["spectator"] = [];

	if ( !level.teamBased || level.gametype == "bel" )
		return;

	placementAll = level.placement["all"];
	placementAllSize = placementAll.size;

	for ( i = 0; i < placementAllSize; i++ )
	{
		player = placementAll[i];
		team = player.pers["team"];

		placement[team][ placement[team].size ] = player;
	}

	level.placement["allies"] = placement["allies"];
	level.placement["axis"]   = placement["axis"];
}

onXPEvent( event )
{
	self maps\mp\gametypes\_rank::giveRankXP( event );
}


givePlayerScore( event, player, victim )
{
	if ( level.overridePlayerScore )
		return;

	score = player.pers["score"];
	[[level.onPlayerScore]]( event, player, victim );

	if ( score == player.pers["score"] )
		return;

	player maps\mp\gametypes\_persistence::statAdd( "score", (player.pers["score"] - score) );

	player.score = player.pers["score"];

	if ( !level.teambased || level.gametype == "bel" )
		thread sendUpdatedDMScores();

	player notify ( "update_playerscore_hud" );
	player thread checkScoreLimit();
}


default_onPlayerScore( event, player, victim )
{
	score = maps\mp\gametypes\_rank::getScoreInfoValue( event );

	assert( isDefined( score ) );
	/*
	if ( event == "assist" )
		player.pers["score"] += 2;
	else
		player.pers["score"] += 10;
	*/

	player.pers["score"] += score;
}


_setPlayerScore( player, score )
{
	if ( score == player.pers["score"] )
		return;

	player.pers["score"] = score;
	player.score = player.pers["score"];

	player notify ( "update_playerscore_hud" );
	player thread checkScoreLimit();
}


_getPlayerScore( player )
{
	return player.pers["score"];
}


giveTeamScore( event, team, player, victim )
{
	if ( level.overrideTeamScore )
		return;

	teamScore = game["teamScores"][team];
	[[level.onTeamScore]]( event, team, player, victim );

	if ( teamScore == game["teamScores"][team] )
		return;

	updateTeamScores( team );

	thread checkScoreLimit();
}

_setTeamScore( team, teamScore )
{
	if ( teamScore == game["teamScores"][team] )
		return;

	game["teamScores"][team] = teamScore;

		updateTeamScores( team );

	thread checkScoreLimit();
}

updateTeamScores( team1, team2 )
{
	setTeamScore( team1, getGameScore( team1 ) );
	if ( isdefined( team2 ) )
		setTeamScore( team2, getGameScore( team2 ) );

	if ( level.teambased )
		thread sendUpdatedTeamScores();
}


_getTeamScore( team )
{
	return game["teamScores"][team];
}


default_onTeamScore( event, team, player, victim )
{
	score = maps\mp\gametypes\_rank::getScoreInfoValue( event );

	assert( isDefined( score ) );

	otherTeam = level.otherTeam[team];

	if ( game["teamScores"][team] > game["teamScores"][otherTeam] )
		level.wasWinning = team;
	else if ( game["teamScores"][otherTeam] > game["teamScores"][team] )
		level.wasWinning = otherTeam;

	game["teamScores"][team] += score;

	isWinning = "none";
	if ( game["teamScores"][team] > game["teamScores"][otherTeam] )
		isWinning = team;
	else if ( game["teamScores"][otherTeam] > game["teamScores"][team] )
		isWinning = otherTeam;

	if ( !level.splitScreen && isWinning != "none" && isWinning != level.wasWinning && getTime() - level.lastStatusTime  > 5000 )
	{
		level.lastStatusTime = getTime();
		leaderDialog( "lead_taken", isWinning, "status" );
		if ( level.wasWinning != "none")
			leaderDialog( "lead_lost", level.wasWinning, "status" );
	}

	if ( isWinning != "none" )
		level.wasWinning = isWinning;
}


sendUpdatedTeamScores()
{
	level notify("updating_scores");
	level endon("updating_scores");
	wait .05;

	WaitTillSlowProcessAllowed();

	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[i] updateScores();
	}
}

sendUpdatedDMScores()
{
	level notify("updating_dm_scores");
	level endon("updating_dm_scores");
	wait .05;

	WaitTillSlowProcessAllowed();

	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[i] updateDMScores();
		level.players[i].updatedDMScores = true;
	}
}

initPersStat( dataName )
{
	if( !isDefined( self.pers[dataName] ) )
		self.pers[dataName] = 0;
}


getPersStat( dataName )
{
	return self.pers[dataName];
}


incPersStat( dataName, increment )
{
	self.pers[dataName] += increment;
	self maps\mp\gametypes\_persistence::statAdd( dataName, increment );
}


updatePersRatio( ratio, num, denom )
{
	numValue = self maps\mp\gametypes\_persistence::statGet( num );
	denomValue = self maps\mp\gametypes\_persistence::statGet( denom );
	if ( denomValue == 0 )
		denomValue = 1;

	self maps\mp\gametypes\_persistence::statSet( ratio, int( (numValue * 1000) / denomValue ) );
}


updateTeamStatus()
{
	// run only once per frame, at the end of the frame.
	level notify("updating_team_status");
	level endon("updating_team_status");
	level endon ( "game_ended" );
	waittillframeend;

	wait 0;	// Required for Callback_PlayerDisconnect to complete before updateTeamStatus can execute

	if ( game["state"] == "postgame" )
		return;

	resetTimeout();

	prof_begin( "updateTeamStatus" );

	level.playerCount["allies"] = 0;
	level.playerCount["axis"] = 0;

	level.lastAliveCount["allies"] = level.aliveCount["allies"];
	level.lastAliveCount["axis"] = level.aliveCount["axis"];
	level.aliveCount["allies"] = 0;
	level.aliveCount["axis"] = 0;
	level.playerLives["allies"] = 0;
	level.playerLives["axis"] = 0;
	level.alivePlayers["allies"] = [];
	level.alivePlayers["axis"] = [];
	level.activePlayers = [];

	players = level.players;
	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if ( !isDefined( player ) && level.splitscreen )
			continue;

		team = player.team;

		if ( team != "spectator" && player isValidClass( player.class ) )
		{
			level.playerCount[team]++;

			if ( player.sessionstate == "playing" )
			{
				level.aliveCount[team]++;
				level.playerLives[team]++;

				if ( isAlive( player ) )
				{
					level.alivePlayers[team][level.alivePlayers.size] = player;
					level.activeplayers[ level.activeplayers.size ] = player;
				}
			}
			else
			{
				if ( player maySpawn() )
					level.playerLives[team]++;
			}
		}
	}

	if ( level.aliveCount["allies"] + level.aliveCount["axis"] > level.maxPlayerCount )
		level.maxPlayerCount = level.aliveCount["allies"] + level.aliveCount["axis"];

	if ( level.aliveCount["allies"] )
		level.everExisted["allies"] = true;
	if ( level.aliveCount["axis"] )
		level.everExisted["axis"] = true;

	prof_end( "updateTeamStatus" );

	level updateGameEvents();
}

isValidClass( class )
{
	if ( level.oldschool )
	{
		assert( !isdefined( class ) );
		return true;
	}
	
	if ( level.gametype == "hns" && self.pers["team"] == game["defenders"] ) {
		return isdefined( self.pers["prop"] ) && self.pers["prop"] != "";
	} else {
		return isdefined( class ) && class != "";
	}
}

playTickingSound()
{
	self endon("death");
	self endon("stop_ticking");
	level endon("game_ended");

	while(1)
	{
		self playSound( "ui_mp_suitcasebomb_timer" );
		wait 1.0;
	}
}

stopTickingSound()
{
	self notify("stop_ticking");
}

timeLimitClock()
{
	level endon ( "game_ended" );

	wait .05;

	clockObject = spawn( "script_origin", (0,0,0) );

	while ( game["state"] == "playing" )
	{
		if ( !level.timerStopped && level.timeLimit )
		{
			timeLeft = getTimeRemaining() / 1000;
			timeLeftInt = int(timeLeft + 0.5); // adding .5 and flooring rounds it.

			if ( timeLeftInt >= 30 && timeLeftInt <= 60 )
				level notify ( "match_ending_soon" );

			if ( timeLeftInt <= 600 || timeLeftInt >=0 )
			        level notify ( "ow_countdown_start" );

			if ( timeLeftInt <= 10 || (timeLeftInt <= 30 && timeLeftInt % 2 == 0) )
			{
				level notify ( "match_ending_very_soon" );
				// don't play a tick at exactly 0 seconds, that's when something should be happening!
				if ( timeLeftInt == 0 )
					break;

				clockObject playSound( "ui_mp_timer_countdown" );
			}

			// synchronize to be exactly on the second
			if ( timeLeft - floor(timeLeft) >= .05 )
				wait timeLeft - floor(timeLeft);
		}

		wait ( 1.0 );
	}
}


timeLimitClock_Intermission( waitTime, playSound )
{
	setGameEndTime( getTime() + int(waitTime*1000) );
	clockObject = spawn( "script_origin", (0,0,0) );

	while ( waitTime > 0 ) {
		if ( playSound && waitTime <= 11 ) {
			clockObject playSound( "ui_mp_timer_countdown" );			
		}
		wait ( 1.0 );
		waitTime -= 1.0;
	}
	
	clockObject delete();
}


gameTimer()
{
	level endon ( "game_ended" );

	level waittill("prematch_over");

	level.startTime = getTime();
	level.discardTime = 0;

	if ( isDefined( game["roundMillisecondsAlreadyPassed"] ) )
	{
		level.startTime -= game["roundMillisecondsAlreadyPassed"];
		game["roundMillisecondsAlreadyPassed"] = undefined;
	}

	prevtime = gettime();

	while ( game["state"] == "playing" )
	{
		if ( !level.timerStopped )
		{
			// the wait isn't always exactly 1 second. dunno why.
			game["timepassed"] += gettime() - prevtime;
		}
		prevtime = gettime();
		wait ( 1.0 );
	}
}

getTimePassed()
{
	if ( !isDefined( level.startTime ) )
		return 0;

	if ( level.timerStopped )
		return (level.timerPauseTime - level.startTime) - level.discardTime;
	else
		return (gettime()            - level.startTime) - level.discardTime;

}


pauseTimer()
{
	if ( level.timerStopped )
		return;

	level.timerStopped = true;
	level.timerPauseTime = gettime();
}


resumeTimer()
{
	if ( !level.timerStopped )
		return;

	level.timerStopped = false;
	level.discardTime += gettime() - level.timerPauseTime;
}


startGame()
{
	level notify("prematch_start");

	serverHideHUD();
	for ( index = 0; index < level.players.size; index++ ) {
		if ( !isDefined( level.players[index] ) )
			continue;
			
		level.players[index] hideHUD();
	}	
	
	thread gameTimer();
	level.timerStopped = false;
	thread maps\mp\gametypes\_spawnlogic::spawnPerFrameUpdate();

	// Do the readyup when the game just started or strategy time when is the second or so round
	if ( level.prematchPeriod > 0 )	{
		openwarfare\_readyupperiod::start();
	} else {
		openwarfare\_strategyperiod::start();
	}

	prematchPeriod();
	level notify("prematch_over");

	thread timeLimitClock();
	thread gracePeriod();

	thread musicController();
	thread maps\mp\gametypes\_missions::roundBegin();
}


musicController()
{
	level endon ( "game_ended" );

	if ( !level.hardcoreMode && level.scr_enable_music )
		thread suspenseMusic();

	level waittill ( "match_ending_soon" );

	if ( level.roundLimit == 1 || game["roundsplayed"] == (level.roundLimit - 1) )
	{
		if ( !level.splitScreen )
		{
			if ( game["teamScores"]["allies"] > game["teamScores"]["axis"] )
			{
				if ( !level.hardcoreMode && level.scr_enable_music )
				{
					playSoundOnPlayers( game["music"]["winning"], "allies" );
					playSoundOnPlayers( game["music"]["losing"], "axis" );
				}

				leaderDialog( "winning", "allies" );
				leaderDialog( "losing", "axis" );
			}
			else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
			{
				if ( !level.hardcoreMode && level.scr_enable_music )
				{
					playSoundOnPlayers( game["music"]["winning"], "axis" );
					playSoundOnPlayers( game["music"]["losing"], "allies" );
				}

				leaderDialog( "winning", "axis" );
				leaderDialog( "losing", "allies" );
			}
			else
			{
				if ( !level.hardcoreMode && level.scr_enable_music )
					playSoundOnPlayers( game["music"]["losing"] );

				leaderDialog( "timesup" );
			}

			level waittill ( "match_ending_very_soon" );
			leaderDialog( "timesup" );
		}
	}
	else
	{
		if ( !level.hardcoreMode && level.scr_enable_music )
			playSoundOnPlayers( game["music"]["losing"] );

		leaderDialog( "timesup" );
	}
}


suspenseMusic()
{
	level endon ( "game_ended" );
	level endon ( "match_ending_soon" );

	numTracks = game["music"]["suspense"].size;
	for ( ;; )
	{
		wait ( randomFloatRange( 60, 120 ) );

		playSoundOnPlayers( game["music"]["suspense"][randomInt(numTracks)] );
	}
}


waitForPlayers( maxTime )
{
	endTime = gettime() + maxTime * 1000 - 200;

	if ( level.teamBased )
		while( (!level.everExisted[ "axis" ] || !level.everExisted[ "allies" ]) && gettime() < endTime )
			wait ( 0.05 );
	else
		while ( level.maxPlayerCount < 2 && gettime() < endTime )
			wait ( 0.05 );
}


prematchPeriod()
{
	level endon( "game_ended" );

	if ( level.prematchPeriod > 0 )
	{
		matchStartTimer();
	}
	else
	{
		matchStartTimerSkip();
	}

	level.inPrematchPeriod = false;
	serverShowHUD();

	for ( index = 0; index < level.players.size; index++ )
	{
		if ( !isDefined( level.players[index] ) )
			continue;
			
		level.players[index] showHUD();		
		level.players[index] freezeControls( false );
		level.players[index] thread maps\mp\gametypes\_gameobjects::_enableWeapon();

		hintMessage = getObjectiveHintText( level.players[index].pers["team"] );
		if ( !isDefined( hintMessage ) || !level.players[index].hasSpawned )
			continue;

		level.players[index] setClientDvar( "scr_objectiveText", hintMessage );

		if ( level.gametype != "hns" )
			level.players[index] thread maps\mp\gametypes\_hud_message::hintMessage( hintMessage );
	}

	if ( level.gametype != "hns" ) {
		leaderDialog( "offense_obj", game["attackers"], "introboost" );
		leaderDialog( "defense_obj", game["defenders"], "introboost" );
	}

	if ( game["state"] != "playing" )
		return;
}


gracePeriod()
{
	level endon("game_ended");

	wait ( level.gracePeriod );

	level notify ( "grace_period_ending" );
	wait ( 0.05 );

	level.inGracePeriod = false;

	if ( game["state"] != "playing" )
		return;

	if ( level.numLives )
	{
		// Players on a team but without a weapon show as dead since they can not get in this round
		players = level.players;

		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];

			if ( !player.hasSpawned && player.sessionteam != "spectator" && !isAlive( player ) ) {
				// Check if we should show the player status
				if ( level.scr_show_player_status == 1 ) {
					self.statusicon = "hud_status_dead";
				} else {
					self.statusicon = "";
				}
			}
		}
	}

	level thread updateTeamStatus();
}


announceRoundWinner( winner, delay )
{
	if ( delay > 0 )
		wait delay;

	if ( !isDefined( winner ) || isPlayer( winner ) )
		return;

	if ( winner == "allies" )
	{
		leaderDialog( "round_success", "allies" );
		leaderDialog( "round_failure", "axis" );
	}
	else if ( winner == "axis" )
	{
		leaderDialog( "round_success", "axis" );
		leaderDialog( "round_failure", "allies" );
	}
	else
	{
//		leaderDialog( "mission_draw" );
	}
}


announceGameWinner( winner, delay )
{
	if ( delay > 0 )
		wait delay;

	if ( !isDefined( winner ) || isPlayer( winner ) )
		return;

	if ( winner == "allies" )
	{
		leaderDialog( "mission_success", "allies" );
		leaderDialog( "mission_failure", "axis" );
	}
	else if ( winner == "axis" )
	{
		leaderDialog( "mission_success", "axis" );
		leaderDialog( "mission_failure", "allies" );
	}
	else
	{
		leaderDialog( "mission_draw" );
	}
}


updateWinStats( winner )
{
	winner maps\mp\gametypes\_persistence::statAdd( "losses", -1 );

	println( "setting winner: " + winner maps\mp\gametypes\_persistence::statGet( "wins" ) );
	winner maps\mp\gametypes\_persistence::statAdd( "wins", 1 );
	winner updatePersRatio( "wlratio", "wins", "losses" );
	winner maps\mp\gametypes\_persistence::statAdd( "cur_win_streak", 1 );

	cur_win_streak = winner maps\mp\gametypes\_persistence::statGet( "cur_win_streak" );
	if ( cur_win_streak > winner maps\mp\gametypes\_persistence::statGet( "win_streak" ) )
		winner maps\mp\gametypes\_persistence::statSet( "win_streak", cur_win_streak );

	lpselfnum = winner getEntityNumber();
	lpGuid = winner getGuid();
	logPrint("W;" + lpGuid + ";" + lpselfnum + ";" + winner.name + "\n");	
}


updateLossStats( loser )
{
	loser maps\mp\gametypes\_persistence::statAdd( "losses", 1 );
	loser updatePersRatio( "wlratio", "wins", "losses" );
	loser maps\mp\gametypes\_persistence::statSet( "cur_win_streak", 0 );

	lpselfnum = loser getEntityNumber();
	lpGuid = loser getGuid();
	logPrint("L;" + lpGuid + ";" + lpselfnum + ";" + loser.name + "\n");
}


updateTieStats( loser )
{
	loser maps\mp\gametypes\_persistence::statAdd( "losses", -1 );

	loser maps\mp\gametypes\_persistence::statAdd( "ties", 1 );
	loser updatePersRatio( "wlratio", "wins", "losses" );
	loser maps\mp\gametypes\_persistence::statSet( "cur_win_streak", 0 );

	lpselfnum = loser getEntityNumber();
	lpGuid = loser getGuid();
	logPrint("T;" + lpGuid + ";" + lpselfnum + ";" + loser.name + "\n");
}


updateWinLossStats( winner )
{
	if ( level.roundLimit > 1 && !hitRoundLimit() )
		return;

	players = level.players;

	if ( !isDefined( winner ) || ( isDefined( winner ) && !isPlayer( winner ) && winner == "tie" ) )
	{
		for ( i = 0; i < players.size; i++ )
		{
			if ( !isDefined( players[i].pers["team"] ) )
				continue;

			if ( level.hostForcedEnd && players[i] getEntityNumber() == 0 )
				return;

			updateTieStats( players[i] );
		}
	}
	else if ( isPlayer( winner ) )
	{
		if ( level.hostForcedEnd && winner getEntityNumber() == 0 )
			return;

		updateWinStats( winner );
	}
	else
	{
		for ( i = 0; i < players.size; i++ )
		{
			if ( !isDefined( players[i].pers["team"] ) )
				continue;

			if ( level.hostForcedEnd && players[i] getEntityNumber() == 0 )
				return;

			if ( winner == "tie" )
				updateTieStats( players[i] );
			else if ( players[i].pers["team"] == winner )
				updateWinStats( players[i] );
		}
	}
}


TimeUntilWaveSpawn( minimumWait )
{
	// the time we'll spawn if we only wait the minimum wait.
	earliestSpawnTime = gettime() + minimumWait * 1000;

	lastWaveTime = level.lastWave[self.pers["team"]];
	waveDelay = level.waveDelay[self.pers["team"]] * 1000;

	// the number of waves that will have passed since the last wave happened, when the minimum wait is over.
	numWavesPassedEarliestSpawnTime = (earliestSpawnTime - lastWaveTime) / waveDelay;
	// rounded up
	numWaves = ceil( numWavesPassedEarliestSpawnTime );

	timeOfSpawn = lastWaveTime + numWaves * waveDelay;

	// avoid spawning everyone on the same frame
	if ( isdefined( self.waveSpawnIndex ) )
		timeOfSpawn += 50 * self.waveSpawnIndex;

	return (timeOfSpawn - gettime()) / 1000;
}

TeamKillDelay()
{
	teamkills = self.pers["teamkills"];
	if ( level.minimumAllowedTeamKills < 0 || teamkills <= level.minimumAllowedTeamKills )
		return 0;
	exceeded = (teamkills - level.minimumAllowedTeamKills);
	return maps\mp\gametypes\_tweakables::getTweakableValue( "team", "teamkillspawndelay" ) * exceeded;
}


TimeUntilSpawn( includeTeamkillDelay )
{
	if ( level.inGracePeriod && !self.hasSpawned )
		return 0;

	respawnDelay = 0;
	if ( self.hasSpawned )
	{
		result = self [[level.onRespawnDelay]]();
		if ( isDefined( result ) )
			respawnDelay = result;
		else if ( isDefined( game["_overtime"] ) )
			respawnDelay = self openwarfare\_overtime::respawnDelay();
		else
			respawnDelay = getdvarx( "scr_" + level.gameType + "_playerrespawndelay", "float", 10, -1, 300 );

		if ( level.hardcoreMode && !isDefined( result ) && !respawnDelay )
			respawnDelay = 10.0;

		if ( includeTeamkillDelay && self.teamKillPunish )
			respawnDelay += TeamKillDelay();
	}

	waveBased = (getdvarx( "scr_" + level.gameType + "_waverespawndelay", "float", 0, 0, 300 ) > 0);

	if ( waveBased )
		return self TimeUntilWaveSpawn( respawnDelay );

	return respawnDelay;
}


maySpawn()
{
	if ( level.inOvertime )
		return false;

	if ( level.inReadyUpPeriod )
		return true;

	if ( level.inHidingPeriod )
		return true;
		
	if ( level.numLives )
	{
		if ( level.teamBased )
			gameHasStarted = ( level.everExisted[ "axis" ] && level.everExisted[ "allies" ] );
		else
			gameHasStarted = (level.maxPlayerCount > 1);

		if ( !self.pers["lives"] && gameHasStarted )
		{
			return false;
		}
		else if ( gameHasStarted )
		{
			// disallow spawning for late comers
			if ( !level.inGracePeriod && !self.hasSpawned )
				return false;
		}
	}
	return true;
}

spawnClient( timeAlreadyPassed )
{
	assert(	isDefined( self.team ) );
	assert(	self isValidClass( self.class ) );

	if ( !self maySpawn() )
	{
		currentorigin =	self.origin;
		currentangles =	self.angles;

		shouldShowRespawnMessage = true;
		if ( level.roundLimit > 1 && game["roundsplayed"] >= (level.roundLimit - 1) )
			shouldShowRespawnMessage = false;
		if ( level.scoreLimit > 1 && level.teambased && game["teamScores"]["allies"] >= level.scoreLimit - 1 && game["teamScores"]["axis"] >= level.scoreLimit - 1 )
			shouldShowRespawnMessage = false;
		if ( shouldShowRespawnMessage )
		{
			setLowerMessage( game["strings"]["spawn_next_round"] );
			self thread removeSpawnMessageShortly( 3 );
		}
		self thread	[[level.spawnSpectator]]( currentorigin	+ (0, 0, 60), currentangles	);
		return;
	}

	if ( self.waitingToSpawn )
		return;
	self.waitingToSpawn = true;

	self waitAndSpawnClient( timeAlreadyPassed );

	if ( isdefined( self ) )
		self.waitingToSpawn = false;
}

waitAndSpawnClient( timeAlreadyPassed )
{
	self endon ( "disconnect" );
	self endon ( "end_respawn" );
	self endon ( "game_ended" );

	if ( !isdefined( timeAlreadyPassed ) )
		timeAlreadyPassed = 0;

	spawnedAsSpectator = false;

	if ( self.teamKillPunish )
	{
		teamKillDelay = TeamKillDelay();
		if ( teamKillDelay > timeAlreadyPassed )
		{
			teamKillDelay -= timeAlreadyPassed;
			timeAlreadyPassed = 0;
		}
		else
		{
			timeAlreadyPassed -= teamKillDelay;
			teamKillDelay = 0;
		}

		if ( teamKillDelay > 0 )
		{
			setLowerMessage( &"MP_FRIENDLY_FIRE_WILL_NOT", teamKillDelay );

			self thread	respawn_asSpectator( self.origin + (0, 0, 60), self.angles );
			spawnedAsSpectator = true;

			wait( teamKillDelay );
		}

		self.teamKillPunish = false;
	}

	if ( !isdefined( self.waveSpawnIndex ) && isdefined( level.wavePlayerSpawnIndex[self.team] ) )
	{
		self.waveSpawnIndex = level.wavePlayerSpawnIndex[self.team];
		level.wavePlayerSpawnIndex[self.team]++;
	}

	timeUntilSpawn = self TimeUntilSpawn( false );
	if ( timeUntilSpawn > timeAlreadyPassed )
	{
		timeUntilSpawn -= timeAlreadyPassed;
		timeAlreadyPassed = 0;
	}
	else
	{
		timeAlreadyPassed -= timeUntilSpawn;
		timeUntilSpawn = 0;
	}

	if ( timeUntilSpawn > 0 )
	{
		// spawn player into spectator on death during respawn delay, if he switches teams during this time, he will respawn next round
		setLowerMessage( game["strings"]["waiting_to_spawn"], timeUntilSpawn );

		if ( !spawnedAsSpectator )
			self thread	respawn_asSpectator( self.origin + (0, 0, 60), self.angles );
		spawnedAsSpectator = true;

		self waitForTimeOrNotify( timeUntilSpawn, "force_spawn" );
	}

	waveBased = (getdvarx( "scr_" + level.gameType + "_waverespawndelay", "float", 0, 0, 300 ) > 0);
	if ( level.scr_player_forcerespawn == 0 && self.hasSpawned && !waveBased )
	{
		//setLowerMessage( game["strings"]["press_to_spawn"] );

		if ( !spawnedAsSpectator )
			self thread	respawn_asSpectator( self.origin + (0, 0, 60), self.angles );
		spawnedAsSpectator = true;

		self waitRespawnButton();
	}

	self.waitingToSpawn = false;

	self clearLowerMessage();

	self.waveSpawnIndex = undefined;

	self thread	[[level.spawnPlayer]]();
}


waitForTimeOrNotify( time, notifyname )
{
	self endon( notifyname );

	finishWait = openwarfare\_timer::getTimePassed() + time * 1000;
	while ( isDefined( level.startTime ) && finishWait > openwarfare\_timer::getTimePassed() ) {
		wait (0.05);
		if ( level.inTimeoutPeriod ) {
			self.lowerMessage.alpha = 0;
			self.lowerTimer.alpha = 0;
			xWait( 0.1 );
			self.lowerTimer setTimer( ( finishWait - openwarfare\_timer::getTimePassed() ) / 1000 );
			self.lowerMessage.alpha = 1;
			self.lowerTimer.alpha = 1;
		}
	}
}


removeSpawnMessageShortly( delay )
{
	self endon("disconnect");

	waittillframeend; // so we don't endon the end_respawn from spawning as a spectator

	self endon("end_respawn");

	wait delay;

	self clearLowerMessage( 2.0 );
}


Callback_StartGameType()
{
	level.prematchPeriod = 0;
	level.prematchPeriodEnd = 0;

	level.intermission = false;

	maps\mp\gametypes\_scoreboard::init();

	if ( !isDefined( game["gamestarted"] ) )
	{
		// defaults if not defined in level script
		if ( !isDefined( game["allies"] ) )
			game["allies"] = "marines";
		if ( !isDefined( game["axis"] ) )
			game["axis"] = "opfor";
		if ( !isDefined( game["attackers"] ) )
			game["attackers"] = "allies";
		if (  !isDefined( game["defenders"] ) )
			game["defenders"] = "axis";

		if ( !isDefined( game["state"] ) )
			game["state"] = "playing";

		precacheStatusIcon( "hud_status_dead" );
		precacheStatusIcon( "hud_status_connecting" );

		precacheRumble( "damage_heavy" );

		precacheShader( "white" );
		precacheShader( "black" );

		makeDvarServerInfo( "scr_allies", "usmc" );
		makeDvarServerInfo( "scr_axis", "arab" );

		makeDvarServerInfo( "cg_thirdPersonAngle", 354 );
		setDvar( "cg_thirdPersonAngle", 354 );

		game["strings"]["press_to_spawn"] = &"PLATFORM_PRESS_TO_SPAWN";
		if ( level.teamBased )
		{
			game["strings"]["waiting_for_teams"] = &"MP_WAITING_FOR_TEAMS";
			game["strings"]["opponent_forfeiting_in"] = &"MP_OPPONENT_FORFEITING_IN";
		}
		else
		{
			game["strings"]["waiting_for_teams"] = &"MP_WAITING_FOR_PLAYERS";
			game["strings"]["opponent_forfeiting_in"] = &"MP_OPPONENT_FORFEITING_IN";
		}
		game["strings"]["match_starting_in"] = &"MP_MATCH_STARTING_IN";
		game["strings"]["spawn_next_round"] = &"MP_SPAWN_NEXT_ROUND";
		game["strings"]["waiting_to_spawn"] = &"MP_WAITING_TO_SPAWN";
		game["strings"]["match_starting"] = &"MP_MATCH_STARTING";
		game["strings"]["change_class"] = &"MP_CHANGE_CLASS_NEXT_SPAWN";
		game["strings"]["last_stand"] = &"MPUI_LAST_STAND";

		game["strings"]["cowards_way"] = &"PLATFORM_COWARDS_WAY_OUT";

		game["strings"]["tie"] = &"MP_MATCH_TIE";
		game["strings"]["round_draw"] = &"MP_ROUND_DRAW";

		game["strings"]["enemies_eliminated"] = &"MP_ENEMIES_ELIMINATED";
		game["strings"]["score_limit_reached"] = &"MP_SCORE_LIMIT_REACHED";
		game["strings"]["round_limit_reached"] = &"MP_ROUND_LIMIT_REACHED";
		game["strings"]["time_limit_reached"] = &"MP_TIME_LIMIT_REACHED";
		game["strings"]["players_forfeited"] = &"MP_PLAYERS_FORFEITED";

		switch ( game["allies"] )
		{
			case "sas":
				game["music"]["spawn_allies"] = "mp_spawn_sas";
				game["music"]["victory_allies"] = "mp_victory_sas";
				game["colors"]["allies"] = (0.6,0.64,0.69);
				game["voice"]["allies"] = "UK_1mc_";
				setDvar( "scr_allies", "sas" );
				break;
			case "marines":
			default:
				game["music"]["spawn_allies"] = "mp_spawn_usa";
				game["music"]["victory_allies"] = "mp_victory_usa";
				game["colors"]["allies"] = (0,0,0);
				game["voice"]["allies"] = "US_1mc_";
				setDvar( "scr_allies", "usmc" );
				break;
		}
		switch ( game["axis"] )
		{
			case "russian":
				game["music"]["spawn_axis"] = "mp_spawn_soviet";
				game["music"]["victory_axis"] = "mp_victory_soviet";
				game["colors"]["axis"] = (0.52,0.28,0.28);
				game["voice"]["axis"] = "RU_1mc_";
				setDvar( "scr_axis", "ussr" );
				break;
			case "arab":
			case "opfor":
			default:
				game["music"]["spawn_axis"] = "mp_spawn_opfor";
				game["music"]["victory_axis"] = "mp_victory_opfor";
				game["colors"]["axis"] = (0.65,0.57,0.41);
				game["voice"]["axis"] = "AB_1mc_";
				setDvar( "scr_axis", "arab" );
				break;
		}
		game["music"]["defeat"] = "mp_defeat";
		game["music"]["victory_spectator"] = "mp_defeat";
		game["music"]["winning"] = "mp_time_running_out_winning";
		game["music"]["losing"] = "mp_time_running_out_losing";
		game["music"]["victory_tie"] = "mp_defeat";

		game["music"]["suspense"] = [];
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_01";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_02";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_03";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_04";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_05";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_06";

		game["dialog"]["mission_success"] = "mission_success";
		game["dialog"]["mission_failure"] = "mission_fail";
		game["dialog"]["mission_draw"] = "draw";

		game["dialog"]["round_success"] = "encourage_win";
		game["dialog"]["round_failure"] = "encourage_lost";
		game["dialog"]["round_draw"] = "draw";

		// status
		game["dialog"]["timesup"] = "timesup";
		game["dialog"]["winning"] = "winning";
		game["dialog"]["losing"] = "losing";
		game["dialog"]["lead_lost"] = "lead_lost";
		game["dialog"]["lead_tied"] = "tied";
		game["dialog"]["lead_taken"] = "lead_taken";
		game["dialog"]["last_alive"] = "lastalive";

		game["dialog"]["boost"] = "boost";

		if ( !isDefined( game["dialog"]["offense_obj"] ) )
			game["dialog"]["offense_obj"] = "boost";
		if ( !isDefined( game["dialog"]["defense_obj"] ) )
			game["dialog"]["defense_obj"] = "boost";

		game["dialog"]["hardcore"] = "hardcore";
		game["dialog"]["oldschool"] = "oldschool";
		game["dialog"]["highspeed"] = "highspeed";
		game["dialog"]["tactical"] = "tactical";

		game["dialog"]["challenge"] = "challengecomplete";
		game["dialog"]["promotion"] = "promotion";

		game["dialog"]["bomb_taken"] = "bomb_taken";
		game["dialog"]["bomb_lost"] = "bomb_lost";
		game["dialog"]["bomb_defused"] = "bomb_defused";
		game["dialog"]["bomb_planted"] = "bomb_planted";

		game["dialog"]["obj_taken"] = "securedobj";
		game["dialog"]["obj_lost"] = "lostobj";

		game["dialog"]["obj_defend"] = "obj_defend";
		game["dialog"]["obj_destroy"] = "obj_destroy";
		game["dialog"]["obj_capture"] = "capture_obj";
		game["dialog"]["objs_capture"] = "capture_objs";

		game["dialog"]["hq_located"] = "hq_located";
		game["dialog"]["hq_enemy_captured"] = "hq_captured";
		game["dialog"]["hq_enemy_destroyed"] = "hq_destroyed";
		game["dialog"]["hq_secured"] = "hq_secured";
		game["dialog"]["hq_offline"] = "hq_offline";
		game["dialog"]["hq_online"] = "hq_online";

		game["dialog"]["move_to_new"] = "new_positions";

		game["dialog"]["attack"] = "attack";
		game["dialog"]["defend"] = "defend";
		game["dialog"]["offense"] = "offense";
		game["dialog"]["defense"] = "defense";

		game["dialog"]["halftime"] = "halftime";
		game["dialog"]["overtime"] = "overtime";
		game["dialog"]["side_switch"] = "switching";

		game["dialog"]["flag_taken"] = "ourflag";
		game["dialog"]["flag_dropped"] = "ourflag_drop";
		game["dialog"]["flag_returned"] = "ourflag_return";
		game["dialog"]["flag_captured"] = "ourflag_capt";
		game["dialog"]["enemy_flag_taken"] = "enemyflag";
		game["dialog"]["enemy_flag_dropped"] = "enemyflag_drop";
		game["dialog"]["enemy_flag_returned"] = "enemyflag_return";
		game["dialog"]["enemy_flag_captured"] = "enemyflag_capt";

		game["dialog"]["capturing_a"] = "capturing_a";
		game["dialog"]["capturing_b"] = "capturing_b";
		game["dialog"]["capturing_c"] = "capturing_c";
		game["dialog"]["captured_a"] = "capture_a";
		game["dialog"]["captured_b"] = "capture_c";
		game["dialog"]["captured_c"] = "capture_b";

		game["dialog"]["securing_a"] = "securing_a";
		game["dialog"]["securing_b"] = "securing_b";
		game["dialog"]["securing_c"] = "securing_c";
		game["dialog"]["secured_a"] = "secure_a";
		game["dialog"]["secured_b"] = "secure_b";
		game["dialog"]["secured_c"] = "secure_c";

		game["dialog"]["losing_a"] = "losing_a";
		game["dialog"]["losing_b"] = "losing_b";
		game["dialog"]["losing_c"] = "losing_c";
		game["dialog"]["lost_a"] = "lost_a";
		game["dialog"]["lost_b"] = "lost_b";
		game["dialog"]["lost_c"] = "lost_c";

		game["dialog"]["enemy_taking_a"] = "enemy_take_a";
		game["dialog"]["enemy_taking_b"] = "enemy_take_b";
		game["dialog"]["enemy_taking_c"] = "enemy_take_c";
		game["dialog"]["enemy_has_a"] = "enemy_has_a";
		game["dialog"]["enemy_has_b"] = "enemy_has_b";
		game["dialog"]["enemy_has_c"] = "enemy_has_c";

		game["dialog"]["lost_all"] = "take_positions";
		game["dialog"]["secure_all"] = "positions_lock";

		[[level.onPrecacheGameType]]();

		game["gamestarted"] = true;

		game["teamScores"]["allies"] = 0;
		game["teamScores"]["axis"] = 0;

		// first round, so set up prematch
		level.prematchPeriod = level.scr_game_playerwaittime;
		level.prematchPeriodEnd = level.scr_game_matchstarttime;
	} else {
		if ( isDefined( game["readyupperiod"] ) && game["readyupperiod"] ) {
			level.prematchPeriod = level.scr_game_playerwaittime;
			level.prematchPeriodEnd = level.scr_game_matchstarttime;
		} else {
			if ( getdvarx( "scr_match_readyup_period", "int", 0, 0, 1 ) == 1 && getdvarx( "scr_match_readyup_period_onsideswitch", "int", 0, 0, 1 ) == 1 ) {
				if ( isDefined( level.roundSwitch ) && level.roundSwitch && game["roundsplayed"] && ( game["roundsplayed"] % level.roundswitch == 0 ) ) {
					level.prematchPeriod = level.scr_game_playerwaittime;
					level.prematchPeriodEnd = level.scr_game_matchstarttime;
				}
			}
		}
	}

	if(!isdefined(game["timepassed"]))
		game["timepassed"] = 0;

	if(!isdefined(game["roundsplayed"]))
		game["roundsplayed"] = 0;

	level.skipVote = false;
	level.gameEnded = false;
	level.teamSpawnPoints["axis"] = [];
	level.teamSpawnPoints["allies"] = [];

	level.objIDStart = 0;
	level.forcedEnd = false;
	level.hostForcedEnd = false;

	if ( level.hardcoreMode )
		logString( "game mode: hardcore" );

	// this gets set to false when someone takes damage or a gametype-specific event happens.
	level.useStartSpawns = true;

	// set to 0 to disable
	if ( getdvar( "scr_teamKillPunishCount" ) == "" )
		setdvar( "scr_teamKillPunishCount", "3" );
	level.minimumAllowedTeamKills = getdvarint( "scr_teamKillPunishCount" ) - 1; // punishment starts at the next one

	if( getdvar( "r_reflectionProbeGenerate" ) == "1" )
		level waittill( "eternity" );

	thread maps\mp\gametypes\_persistence::init();

	if ( !level.rankedMatch ) {
		thread maps\mp\gametypes\_modwarfare::init();
		thread maps\mp\gametypes\_menus_unranked::init();
	} else {

		thread maps\mp\gametypes\_menus::init();
	}

	thread maps\mp\gametypes\_hud::init();
	thread maps\mp\gametypes\_serversettings::init();
	thread maps\mp\gametypes\_clientids::init();
	thread maps\mp\gametypes\_teams::init();
	thread maps\mp\gametypes\_weapons::init();
	thread maps\mp\gametypes\_killcam::init();
	thread maps\mp\gametypes\_shellshock::init();
	thread maps\mp\gametypes\_deathicons::init();
	thread maps\mp\gametypes\_damagefeedback::init();
	thread maps\mp\gametypes\_spectating::init();
	thread maps\mp\gametypes\_objpoints::init();
	thread maps\mp\gametypes\_gameobjects::init();
	thread maps\mp\gametypes\_spawnlogic::init();
	thread maps\mp\gametypes\_oldschool::init();
	thread maps\mp\gametypes\_battlechatter_mp::init();

	thread maps\mp\gametypes\_hardpoints::init();

	if ( level.teamBased )
		thread maps\mp\gametypes\_friendicons::init();

	thread maps\mp\gametypes\_hud_message::init();

	if ( !level.console )
		thread maps\mp\gametypes\_quickmessages::init();

	thread maps\mp\_explosive_barrels::main();			

	// Do not thread this initialization
	openwarfare\_globalinit::init();
	
	// Check which regen method we should load depending on the dvar
	switch ( level.scr_healthregen_method )
	{
		case 1:
			thread maps\mp\gametypes\_healthoverlay::init();
			break;
		case 0:
		case 2:
			thread openwarfare\_healthsystem::init_healthOverlay();
			break;
	}
			
	stringNames = getArrayKeys( game["strings"] );
	for ( index = 0; index < stringNames.size; index++ ) {
		if ( !isString( game["strings"][stringNames[index]] ) ) {
			precacheString( game["strings"][stringNames[index]] );
		}
	}

	level.maxPlayerCount = 0;
	level.playerCount["allies"] = 0;
	level.playerCount["axis"] = 0;
	level.aliveCount["allies"] = 0;
	level.aliveCount["axis"] = 0;
	level.playerLives["allies"] = 0;
	level.playerLives["axis"] = 0;
	level.lastAliveCount["allies"] = 0;
	level.lastAliveCount["axis"] = 0;
	level.everExisted["allies"] = false;
	level.everExisted["axis"] = false;
	level.waveDelay["allies"] = 0;
	level.waveDelay["axis"] = 0;
	level.lastWave["allies"] = 0;
	level.lastWave["axis"] = 0;
	level.wavePlayerSpawnIndex["allies"] = 0;
	level.wavePlayerSpawnIndex["axis"] = 0;
	level.alivePlayers["allies"] = [];
	level.alivePlayers["axis"] = [];
	level.activePlayers = [];

	if ( !isDefined( level.timeLimit ) )
		registerTimeLimitDvar( "default", 10, 1, 1440 );

	if ( !isDefined( level.scoreLimit ) )
		registerScoreLimitDvar( "default", 100, 1, 500 );

	if ( !isDefined( level.roundLimit ) )
		registerRoundLimitDvar( "default", 1, 0, 10 );

	makeDvarServerInfo( "ui_scorelimit" );
	makeDvarServerInfo( "ui_timelimit" );
	makeDvarServerInfo( "ui_allow_classchange", getDvar( "ui_allow_classchange" ) );
	makeDvarServerInfo( "ui_allow_teamchange", getDvar( "ui_allow_teamchange" ) );

	if ( level.numlives )
		setdvar( "g_deadChat", getdvarx( "scr_enable_deadchat", "int", 0, 0, 1 ) );
	else
		setdvar( "g_deadChat", getdvarx( "scr_enable_deadchat", "int", 1, 0, 1 ) );

	if ( getDvarInt( "scr_game_forceuav" ) )
		setDvar( "g_compassShowEnemies", 1 );
	else
		setDvar( "g_compassShowEnemies", 0 );

	waveDelay = getdvarx( "scr_" + level.gameType + "_waverespawndelay", "float", 0, 0, 300 );
	if ( waveDelay )
	{
		level.waveDelay["allies"] = waveDelay;
		level.waveDelay["axis"] = waveDelay;
		level.lastWave["allies"] = 0;
		level.lastWave["axis"] = 0;

		level thread [[level.waveSpawnTimer]]();
	}

	level.inTimeoutPeriod = false;
	level.inReadyUpPeriod = false;
	level.inStrategyPeriod = false;
	level.inPrematchPeriod = true;
	level.inHidingPeriod = ( level.gametype == "hns" );

	level.gracePeriod = 15;

	level.inGracePeriod = true;

	level.roundEndDelay = 5;
	level.halftimeRoundEndDelay = 3;

	updateTeamScores( "axis", "allies" );

	if ( !level.teamBased )
		thread initialDMScoreUpdate();

	[[level.onStartGameType]]();

	// this must be after onstartgametype for scr_showspawns to work when set at start of game
	/#
	thread maps\mp\gametypes\_dev::init();
	#/

	thread startGame();
	level thread updateGameTypeDvars();
}

initialDMScoreUpdate()
{
	// the first time we call updateDMScores on a player, we have to send them the whole scoreboard.
	// by calling updateDMScores on each player one at a time,
	// we can avoid having to send the entire scoreboard to every single player
	// the first time someone kills someone else.
	wait .2;
	numSent = 0;
	while(1)
	{
		didAny = false;

		players = level.players;
		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];

			if ( !isdefined( player ) )
				continue;

			if ( isdefined( player.updatedDMScores ) )
				continue;

			player.updatedDMScores = true;
			player updateDMScores();

			didAny = true;
			wait .5;
		}

		if ( !didAny )
			wait 3; // let more players connect
	}
}

checkRoundSwitch()
{
	if ( !isdefined( level.roundSwitch ) || !level.roundSwitch )
		return false;
	if ( !isdefined( level.onRoundSwitch ) )
		return false;

	assert( game["roundsplayed"] > 0 );

	if ( game["roundsplayed"] % level.roundswitch == 0 )
	{
		// Switch Teams/Scores
		if( level.scr_switch_teams_at_halftime == 1  )
		{
			game["switchedteams"] = !game["switchedteams"];
			
			if ( level.scr_custom_teams_enable == 1 ) {
				maps\mp\gametypes\_scoreboard::setTeamResources();
			}
		
			tempscores = game["teamScores"]["allies"];
			game["teamScores"]["allies"] = game["teamScores"]["axis"];
			game["teamScores"]["axis"] = tempscores;
			updateTeamScores( "allies", "axis" );

			level.ignoreUpdateClassLimit = true;

			for( i = 0; i < level.players.size; i++ )
			{
				player = level.players[i];
				if ( player.pers["team"] != "spectator" ) {
					player switchPlayerTeam( level.otherTeam[ player.pers["team"] ], true );
				}
			}
			
			level.ignoreUpdateClassLimit = false;
			
			// If we are running unranked then update the class limits
			if ( !level.rankedMatch ) {
				level thread maps\mp\gametypes\_modwarfare::updateClassLimits();
			}
			
		} else {
			[[level.onRoundSwitch]]();
		}

		return true;
	}

	return false;
}


getGameScore( team )
{
	return game["teamScores"][team];
}


fakeLag()
{
	self endon ( "disconnect" );
	self.fakeLag = randomIntRange( 50, 150 );

	for ( ;; )
	{
		self setClientDvar( "fakelag_target", self.fakeLag );
		wait ( randomFloatRange( 5.0, 15.0 ) );
	}
}

listenForGameEnd()
{
	self waittill( "host_sucks_end_game" );
	if ( level.console )
		endparty();
	level.skipVote = true;

	if ( !level.gameEnded )
		level thread maps\mp\gametypes\_globallogic::forceEnd();
}


Callback_PlayerConnect()
{
	thread notifyConnecting();

	self.statusicon = "hud_status_connecting";
	self waittill( "begin" );
	waittillframeend;
	self.statusicon = "";

	level notify( "connected", self );

	if ( level.console && self getEntityNumber() == 0 )
		self thread listenForGameEnd();

	// only print that we connected if we haven't connected in a previous round
	if( !level.splitscreen && !isdefined( self.pers["score"] ) )
		iPrintLn(&"MP_CONNECTED", self);

	lpselfnum = self getEntityNumber();
	lpGuid = self getGuid();
	logPrint("J;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");

	self setClientDvars(
		"ui_favoriteAddress", level.ui_favoriteAddress,
		"ui_server_info", ( level.scr_welcome_enable > 0 ),
		"bg_fallDamageMinHeight", level.scr_fallDamageMinHeight,
		"bg_fallDamageMaxHeight", level.scr_fallDamageMaxHeight		
	);

	if ( level.hardcoreMode )
	{
		// [0.0.1] Removed to allow players using in-game voice to show up on the screen
		// "cg_drawTalk", 3,
		// [0.0.1]
		self setClientDvars( "cg_drawTalk", "ALL",
							 "cg_drawCrosshair", 0,
							 "cg_hudGrenadeIconMaxRangeFrag", 0 );
	}
	else
	{
		self setClientDvars( "cg_drawTalk", "ALL",
							 "cg_drawCrosshair", 1,
						 	 "cg_hudGrenadeIconMaxRangeFrag", 250 );
	}

	self setClientDvars("cg_hudGrenadeIconHeight", "25",
						"cg_hudGrenadeIconWidth", "25",
						"cg_hudGrenadeIconOffset", "50",
						"cg_hudGrenadePointerHeight", "12",
						"cg_hudGrenadePointerWidth", "25",
						"cg_hudGrenadePointerPivot", "12 27",
						"cg_fovscale", "1");

	if ( level.oldschool )
	{
		self setClientDvars( 
			"ragdoll_explode_force", 60000,
			"ragdoll_explode_upbias", 0.8,
			"player_sprintUnlimited", 1,
			"player_clipSizeMultiplier", 2.0
		);
	}

	if ( getdvarint("scr_hitloc_debug") )
	{
		for ( i = 0; i < 6; i++ )
		{
			self setClientDvar( "ui_hitloc_" + i, "" );
		}
		self.hitlocInited = true;
	}

	self initPersStat( "score" );
	self.score = self.pers["score"];

	self initPersStat( "deaths" );
	self.deaths = self getPersStat( "deaths" );

	self initPersStat( "suicides" );
	self.suicides = self getPersStat( "suicides" );

	self initPersStat( "kills" );
	self.kills = self getPersStat( "kills" );

	self initPersStat( "headshots" );
	self.headshots = self getPersStat( "headshots" );

	self initPersStat( "assists" );
	self.assists = self getPersStat( "assists" );

	self initPersStat( "teamkills" );
	self.teamKillPunish = false;
	if ( level.minimumAllowedTeamKills >= 0 && self.pers["teamkills"] > level.minimumAllowedTeamKills )
		self thread reduceTeamKillsOverTime();

	if( getdvar( "r_reflectionProbeGenerate" ) == "1" )
		level waittill( "eternity" );

	self.killedPlayers = [];
	self.killedPlayersCurrent = [];
	self.killedBy = [];

	self.leaderDialogQueue = [];
	self.leaderDialogActive = false;
	self.leaderDialogGroups = [];
	self.leaderDialogGroup = "";

	self.cur_kill_streak = 0;
	self.cur_death_streak = 0;
	self.death_streak = self maps\mp\gametypes\_persistence::statGet( "death_streak" );
	self.kill_streak = self maps\mp\gametypes\_persistence::statGet( "kill_streak" );
	self.lastGrenadeSuicideTime = -1;

	self.teamkillsThisRound = 0;

	self.pers["lives"] = level.numLives;

	self.hasSpawned = false;
	self.waitingToSpawn = false;
	self.deathCount = 0;

	self.wasAliveAtMatchStart = false;

	self thread maps\mp\_flashgrenades::monitorFlash();

	if ( level.numLives )
	{
		self setClientDvars("cg_deadChatWithDead", 1,
							"cg_deadChatWithTeam", 0,
							"cg_deadHearTeamLiving", 0,
							"cg_deadHearAllLiving", 0,
							"cg_everyoneHearsEveryone", 0 );
	}
	else
	{
		self setClientDvars("cg_deadChatWithDead", 0,
							"cg_deadChatWithTeam", 1,
							"cg_deadHearTeamLiving", 1,
							"cg_deadHearAllLiving", 0,
							"cg_everyoneHearsEveryone", 0 );
	}

	level.players[level.players.size] = self;

	if( level.splitscreen )
		setdvar( "splitscreen_playerNum", level.players.size );

	if ( level.teambased )
		self updateScores();

	// When joining a game in progress, if the game is at the post game state (scoreboard) the connecting player should spawn into intermission
	if ( game["state"] == "postgame" )
	{
		self.pers["team"] = "spectator";
		self.team = "spectator";
		[[level.spawnIntermission]]();
		self closeMenu();
		self closeInGameMenu();
		self hideHUD();

		return;
	}
	
	updateLossStats( self );

	level endon( "game_ended" );

	if ( level.oldschool )
	{
		self.pers["class"] = undefined;
		self.class = self.pers["class"];
	}

	if ( isDefined( self.pers["team"] ) )
		self.team = self.pers["team"];

	if ( isDefined( self.pers["class"] ) )
		self.class = self.pers["class"];

	if ( !isDefined( self.pers["team"] ) )
	{
		// Don't set .sessionteam until we've gotten the assigned team from code,
		// because it overrides the assigned team.
		self.pers["team"] = "spectator";
		self.team = "spectator";
		self.sessionstate = "dead";

		self updateObjectiveText();

		[[level.spawnSpectator]]();

		if ( ( level.rankedMatch || level.scr_server_rank_type == 2 ) && level.console )
		{
			[[level.autoassign]]();

			//self thread forceSpawn();
			self thread kickIfDontSpawn();
		}
		else if ( !level.teamBased && level.console )
		{
			[[level.autoassign]]();
		}
		else
		{
			self setclientdvar( "g_scriptMainMenu", game["menu_team"] );
			// Check if we need to load the welcome screen
			if ( level.scr_welcome_enable == 1  ) {
				self openMenu( game["menu_serverinfo"] );
			} else {
				self openMenu( game["menu_team"] );
			}
		}

		if ( self.pers["team"] == "spectator" )
			self.sessionteam = "spectator";

		if ( level.teamBased )
		{
			// set team and spectate permissions so the map shows waypoint info on connect
			self.sessionteam = self.pers["team"];
			if ( !isAlive( self ) ) {
				// Check if we should show the player status
				if ( level.scr_show_player_status == 1 && self.pers["team"] != "spectator" ) {
					self.statusicon = "hud_status_dead";
				} else {
					if ( self.pers["team"] != "spectator" ) {
						self.statusicon = "";
					}
				}
			}

			// Check if this player can free spectate
			self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
		}
	}
	else if ( self.pers["team"] == "spectator" )
	{
		self setclientdvar( "g_scriptMainMenu", game["menu_team"] );
		self.sessionteam = "spectator";
		self.sessionstate = "spectator";
		[[level.spawnSpectator]]();
	}
	else
	{
		self.sessionteam = self.pers["team"];
		self.sessionstate = "dead";

		self updateObjectiveText();

		[[level.spawnSpectator]]();

		if ( self isValidClass( self.pers["class"] ) )
		{
			self thread [[level.spawnClient]]();
		}
		else
		{
			self showMainMenuForTeam();
		}

		self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
	}

	if ( level.inPrematchPeriod ) {
		self hideHUD();
	} else {
		self showHUD();
	}

	if ( isDefined( self.pers["isBot"] ) )
		return;

	// <font size="8"><strong>TO DO: DELETE THIS WHEN CODE HAS CHECKSUM SUPPORT!</strong></font> :: Check for stat integrity
	for( i=0; i<5; i++ )
	{
		if( self getstat( 205+(i*10) ) == 0 )
		{
			kick( self getentitynumber() );
			return;
		}
	}
}


forceSpawn()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "spawned" );

	wait ( 60.0 );

	if ( self.hasSpawned )
		return;

	if ( self.pers["team"] == "spectator" )
		return;

	if ( !self isValidClass( self.pers["class"] ) )
	{
		if ( getDvarInt( "onlinegame" ) )
			self.pers["class"] = "CLASS_CUSTOM1";
		else
			self.pers["class"] = "CLASS_ASSAULT";

		self.class = self.pers["class"];
	}

	self closeMenus();
	self thread [[level.spawnClient]]();
}

kickIfDontSpawn()
{
	if ( self getEntityNumber() == 0 )
	{
		// don't try to kick the host
		return;
	}

	self kickIfIDontSpawnInternal();
	// clear any client dvars here,
	// like if we set anything to change the menu appearance to warn them of kickness
}

kickIfIDontSpawnInternal()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "spawned" );

	waittime = 90;
	if ( getdvar("scr_kick_time") != "" )
		waittime = getdvarfloat("scr_kick_time");
	mintime = 45;
	if ( getdvar("scr_kick_mintime") != "" )
		mintime = getdvarfloat("scr_kick_mintime");

	starttime = gettime();

	kickWait( waittime );

	timePassed = (gettime() - starttime)/1000;
	if ( timePassed < waittime - .1 && timePassed < mintime )
		return;

	if ( self.hasSpawned )
		return;

	if ( self.pers["team"] == "spectator" )
		return;

	kick( self getEntityNumber() );
}

kickWait( waittime )
{
	level endon("game_ended");
	wait waittime;
}

Callback_PlayerDisconnect()
{
	self removePlayerOnDisconnect();

	if ( !level.gameEnded )
		self logXPGains();

	if ( level.splitscreen )
	{
		players = level.players;

		if ( players.size <= 1 )
			level thread maps\mp\gametypes\_globallogic::forceEnd();

		// passing number of players to menus in splitscreen to display leave or end game option
		setdvar( "splitscreen_playerNum", players.size );
	}

	if ( isDefined( self.score ) && isDefined( self.pers["team"] ) )
	{
		setPlayerTeamRank( self, level.dropTeam, self.score - 5 * self.deaths );
		self logString( "team: score " + self.pers["team"] + ":" + self.score );
		level.dropTeam += 1;
	}

	[[level.onPlayerDisconnect]]();

	lpselfnum = self getEntityNumber();
	lpGuid = self getGuid();
	logPrint("Q;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");

	for ( entry = 0; entry < level.players.size; entry++ )
	{
		if ( level.players[entry] == self )
		{
			while ( entry < level.players.size-1 )
			{
				level.players[entry] = level.players[entry+1];
				entry++;
			}
			level.players[entry] = undefined;
			break;
		}
	}
	for ( entry = 0; entry < level.players.size; entry++ )
	{
		if ( isDefined( level.players[entry].killedPlayers[""+self.clientid] ) )
			level.players[entry].killedPlayers[""+self.clientid] = undefined;

		if ( isDefined( level.players[entry].killedPlayersCurrent[""+self.clientid] ) )
			level.players[entry].killedPlayersCurrent[""+self.clientid] = undefined;

		if ( isDefined( level.players[entry].killedBy[""+self.clientid] ) )
			level.players[entry].killedBy[""+self.clientid] = undefined;
	}

	if ( level.gameEnded )
		self removeDisconnectedPlayerFromPlacement();

	level thread updateTeamStatus();
}


removePlayerOnDisconnect()
{
	for ( entry = 0; entry < level.players.size; entry++ )
	{
		if ( level.players[entry] == self )
		{
			while ( entry < level.players.size-1 )
			{
				level.players[entry] = level.players[entry+1];
				entry++;
			}
			level.players[entry] = undefined;
			break;
		}
	}
}

isHeadShot( sWeapon, sHitLoc, sMeansOfDeath )
{
	return (sHitLoc == "head" || sHitLoc == "helmet") && sMeansOfDeath != "MOD_MELEE" && sMeansOfDeath != "MOD_IMPACT" && !isMG( sWeapon );
}


Callback_PlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	self.iDFlags = iDFlags;
	self.iDFlagsTime = getTime();

	if ( game["state"] == "postgame" )
		return;

	if ( self.sessionteam == "spectator" )
		return;

	if ( isDefined( self.canDoCombat ) && !self.canDoCombat )
		return;

	if ( level.inStrategyPeriod )
		return;

	if ( level.inTimeoutPeriod && level.timeoutTeam != self.pers["team"] )
		return;

	if ( isDefined( eAttacker ) && isPlayer( eAttacker ) && isDefined( eAttacker.canDoCombat ) && !eAttacker.canDoCombat )
		return;

	if ( level.gametype == "ftag" && self.freezeTag["frozen"] )
		return;
		
	if ( level.scr_bullet_penetration_enabled == 0 && iDFlags & level.iDFLAGS_PENETRATION )
		return;

	// Check if the player is spawn protected and there's an attacker (there's no attacker if the player falls)
	if ( isDefined( eAttacker ) && isPlayer( eAttacker ) && ( ( isDefined( self.spawn_protected ) && self.spawn_protected ) || ( isDefined( self.cap_protected ) && self.cap_protected ) ) ) {
		// If the hiticon for spawn protection is enabled then show the icon to the attacker
		if ( level.scr_spawn_protection_hiticon == 1 && isDefined( eAttacker.hud_damagefeedback ) ) {
			eAttacker.hud_damagefeedback.x = 0;
			eAttacker.hud_damagefeedback.y = 0;
	 		eAttacker.hud_damagefeedback setShader("shield", 20, 20);
			eAttacker.hud_damagefeedback.alpha = 0.7;
			eAttacker.hud_damagefeedback fadeOverTime(1);
			eAttacker.hud_damagefeedback.alpha = 0;
			eAttacker.hud_damagefeedback.x = -12;
			eAttacker.hud_damagefeedback.y = -12;
		}
		
		// Check if we need to punish the attacker
		if ( level.scr_spawn_protection_punishment_time > 0 ) {
			eAttacker openwarfare\_spawnprotection::punishSpawnCamper();
		}
	 	return;
	}

	// explosive barrel/car detection
	sWeaponHack = undefined;
	if ( sWeapon == "none" && isDefined( eInflictor ) )	{
		if ( isDefined( eInflictor.targetname ) && eInflictor.targetname == "explodable_barrel" )	{
			if ( level.scr_barrel_damage_enable == 0 )
				return;
				
			sWeaponHack = "explodable_barrel";
	    sWeapon = "destructible_car";
	    sMeansOfDeath = "MOD_IMPACT";		
	    	
		} else if ( isDefined( eInflictor.destructible_type ) && isSubStr( eInflictor.destructible_type, "vehicle_" ) ) 	{
			if ( level.scr_vehicle_damage_enable == 0 )
				return;
				
			sWeapon = "destructible_car";
		}
	}

	// Check if we need to modify the damage done
	if ( level.scr_wdm_enabled == 1 ) {
		if ( isDefined( sWeaponHack ) ) {
			iDamage = openwarfare\_weapondamagemodifier::wdmDamage( iDamage, sWeaponHack, sHitLoc, sMeansOfDeath );
		} else {
			iDamage = openwarfare\_weapondamagemodifier::wdmDamage( iDamage, sWeapon, sHitLoc, sMeansOfDeath );
		}
		if ( iDamage == 0 )
				return;			
	}

	// Check if we need to modify the damage done
	if ( level.scr_wlm_enabled == 1 ) {
		iDamage = openwarfare\_weaponlocationmodifier::wlmDamage( iDamage, sHitLoc, sMeansOfDeath );
		if ( iDamage == 0 )
				return;			
	}

	if ( level.scr_wrm_enabled == 1 ) {
		iDamage = openwarfare\_weaponrangemodifier::wrmDamage( eAttacker, iDamage, sWeapon, sHitLoc, sMeansOfDeath );
		if ( iDamage == 0 )
				return;			
	}

	// Check if rng is enabled.
	if( level.scr_rng_enabled != 0 ) {
		iDamage = self openwarfare\_rng::rngDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
		if ( iDamage == 0 )
				return;			
	}
		
	// create a class specialty checks; CAC:bulletdamage, CAC:armorvest
	if ( sWeapon != "concussion_grenade_mp" ) {
		if ( !level.rankedMatch ) {
			iDamage = maps\mp\gametypes\_class_unranked::cac_modified_damage( self, eAttacker, iDamage, sMeansOfDeath );
		} else {
			iDamage = maps\mp\gametypes\_class::cac_modified_damage( self, eAttacker, iDamage, sMeansOfDeath );
		}
	}

	// If iDamage has been reduced to zero we don't do anything else
	if ( iDamage == 0 )
			return;

	// If we are playing "One In The Chamber" one bullet is one kill
	if ( level.gametype == "oitc" && maps\mp\gametypes\_weapons::isSideArm( sWeapon ) ) {
		iDamage = self.maxhealth;
	}

	prof_begin( "Callback_PlayerDamage flags/tweaks" );

	// Don't do knockback if the damage direction was not specified
	if( !isDefined( vDir ) )
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	friendly = false;

	if ( ( level.teamBased && (self.health == self.maxhealth)) || !isDefined( self.attackers ) )
	{
		self.attackers = [];
		self.attackerData = [];
		self.attackerDamage = [];
	}

	if( maps\mp\gametypes\_weapons::isSniper( sWeapon ) && sMeansOfDeath == "MOD_IMPACT" )
		sMeansOfDeath = "MOD_RIFLE_BULLET";

	if ( isHeadShot( sWeapon, sHitLoc, sMeansOfDeath ) )
		sMeansOfDeath = "MOD_HEAD_SHOT";

	prof_end( "Callback_PlayerDamage flags/tweaks" );

	// check for completely getting out of the damage
	if( !(iDFlags & level.iDFLAGS_NO_PROTECTION) )
	{
		// return if helicopter friendly fire is on
		if ( level.teamBased && isdefined( level.chopper ) && isdefined( eAttacker ) && eAttacker == level.chopper && eAttacker.team == self.pers["team"] )
		{
//			if( level.friendlyfire == 0 )
//			{
				prof_end( "Callback_PlayerDamage player" );
				return;
//			}
		}

		if ( (isSubStr( sMeansOfDeath, "MOD_GRENADE" ) || isSubStr( sMeansOfDeath, "MOD_EXPLOSIVE" ) || isSubStr( sMeansOfDeath, "MOD_PROJECTILE" )) && isDefined( eInflictor ) )
		{
			// protect players from spectators 
			if ( eInflictor.classname == "grenade" && ( !isDefined( eAttacker ) || eAttacker isSpectating() ) ) {
				prof_end( "Callback_PlayerDamage player" );
				return;				
			}
			
			// protect players from spawnkill grenades
			if ( eInflictor.classname == "grenade" && (self.lastSpawnTime + 3500) > getTime() && distance( eInflictor.origin, self.lastSpawnPoint.origin ) < 250 )
			{
				prof_end( "Callback_PlayerDamage player" );
				return;
			}

			self.explosiveInfo = [];
			self.explosiveInfo["damageTime"] = getTime();
			self.explosiveInfo["damageId"] = eInflictor getEntityNumber();
			self.explosiveInfo["returnToSender"] = false;
			self.explosiveInfo["counterKill"] = false;
			self.explosiveInfo["chainKill"] = false;
			self.explosiveInfo["cookedKill"] = false;
			self.explosiveInfo["throwbackKill"] = false;
			self.explosiveInfo["weapon"] = sWeapon;

			isFrag = isSubStr( sWeapon, "frag_" );

			if ( eAttacker != self )
			{
				if ( (isSubStr( sWeapon, "c4_" ) || isSubStr( sWeapon, "claymore_" )) && isDefined( eAttacker ) && isDefined( eInflictor.owner ) )
				{
					self.explosiveInfo["returnToSender"] = (eInflictor.owner == self);
					self.explosiveInfo["counterKill"] = isDefined( eInflictor.wasDamaged );
					self.explosiveInfo["chainKill"] = isDefined( eInflictor.wasChained );
					self.explosiveInfo["bulletPenetrationKill"] = isDefined( eInflictor.wasDamagedFromBulletPenetration );
					self.explosiveInfo["cookedKill"] = false;
				}
				if ( isDefined( eAttacker.lastGrenadeSuicideTime ) && eAttacker.lastGrenadeSuicideTime >= gettime() - 50 && isFrag )
				{
					self.explosiveInfo["suicideGrenadeKill"] = true;
				}
				else
				{
					self.explosiveInfo["suicideGrenadeKill"] = false;
				}
			}

			if ( isFrag )
			{
				self.explosiveInfo["cookedKill"] = isDefined( eInflictor.isCooked );
				self.explosiveInfo["throwbackKill"] = isDefined( eInflictor.threwBack );
			}
		}

		if ( isPlayer( eAttacker ) )
			eAttacker.pers["participation"]++;

		prevHealthRatio = self.health / self.maxhealth;

		if ( level.teamBased && isPlayer( eAttacker ) && (self != eAttacker) && (self.pers["team"] == eAttacker.pers["team"]) )
		{
			prof_begin( "Callback_PlayerDamage player" ); // profs automatically end when the function returns
			if ( level.friendlyfire == 0 ) // no one takes damage
			{
				if ( sWeapon == "artillery_mp" )
					self damageShellshockAndRumble( eInflictor, sWeapon, sMeansOfDeath, iDamage );
				return;
			}
			else if ( level.friendlyfire == 1 ) // the friendly takes damage
			{
				// Make sure at least one point of damage is done
				if ( iDamage < 1 )
					iDamage = 1;

				self.lastDamageWasFromEnemy = false;

				self finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
			}
			else if ( level.friendlyfire == 2 && isAlive( eAttacker ) ) // only the attacker takes damage
			{
				iDamage = int(iDamage * .5);

				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

				eAttacker.lastDamageWasFromEnemy = false;

				eAttacker.friendlydamage = true;
				eAttacker finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
				eAttacker.friendlydamage = undefined;
				
				iDamage = 0;
			}
			else if ( level.friendlyfire == 3 && isAlive( eAttacker ) ) // both friendly and attacker take damage
			{
				iDamage = int(iDamage * .5);

				// Make sure at least one point of damage is done
				if ( iDamage < 1 )
					iDamage = 1;

				self.lastDamageWasFromEnemy = false;
				eAttacker.lastDamageWasFromEnemy = false;

				self finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
				if ( isAlive( eAttacker ) ) // may have died due to friendly fire punishment
				{
					eAttacker.friendlydamage = true;
					eAttacker finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
					eAttacker.friendlydamage = undefined;
				}
			}

			friendly = true;
		}
		else
		{
			prof_begin( "Callback_PlayerDamage world" );
			// Make sure at least one point of damage is done
			if(iDamage < 1)
				iDamage = 1;

			if ( level.teamBased && isDefined( eAttacker ) && isPlayer( eAttacker ) )
			{
				if ( !isdefined( self.attackerData[eAttacker.clientid] ) )
				{
					self.attackerDamage[eAttacker.clientid] = iDamage;
					self.attackers[ self.attackers.size ] = eAttacker;
					// we keep an array of attackers by their client ID so we can easily tell
					// if they're already one of the existing attackers in the above if().
					// we store in this array data that is useful for other things, like challenges
					self.attackerData[eAttacker.clientid] = false;
				}
				else
				{
					self.attackerDamage[eAttacker.clientid] += iDamage;
				}
				if ( maps\mp\gametypes\_weapons::isPrimaryWeapon( sWeapon ) )
					self.attackerData[eAttacker.clientid] = true;
			}

			if ( isdefined( eAttacker ) )
				level.lastLegitimateAttacker = eAttacker;

			if ( isdefined( eAttacker ) && isPlayer( eAttacker ) && isDefined( sWeapon ) )
				eAttacker maps\mp\gametypes\_weapons::checkHit( sWeapon );

			/*
			if ( isPlayer( eInflictor ) )
				eInflictor maps\mp\gametypes\_persistence::statAdd( "hits", 1 );
			*/

			if ( issubstr( sMeansOfDeath, "MOD_GRENADE" ) && isDefined( eInflictor ) && isDefined( eInflictor.isCooked ) )
				self.wasCooked = getTime();
			else
				self.wasCooked = undefined;

			self.lastDamageWasFromEnemy = (isDefined( eAttacker ) && (eAttacker != self));

			self finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);

			self thread maps\mp\gametypes\_missions::playerDamaged(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, sHitLoc );

			prof_end( "Callback_PlayerDamage world" );
		}

		self notify( "damage_taken", eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

		if ( isdefined(eAttacker) && eAttacker != self )
		{
			hasBodyArmor = false;
			if ( self hasPerk( "specialty_armorvest" ) )
			{
				hasBodyArmor = true;
				/*
				damageScalar = level.cac_armorvest_data / 100;
				if ( prevHealthRatio > damageScalar )
					hasBodyArmor = true;
				*/
			}
			if ( iDamage > 0 ) {
				// By default we'll call damage feedback
				damageFeedback = true;
				// Check if the hit was through a material and hit icons are disabled for these type of hits
				if ( level.scr_enable_hiticon == 2 && (iDFlags & level.iDFLAGS_PENETRATION) )
					damageFeedback = false;

				if ( damageFeedback )
					eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( hasBodyArmor );
			}
		}

		self.hasDoneCombat = true;
	}

	if ( isdefined( eAttacker ) && eAttacker != self && !friendly )
		level.useStartSpawns = false;

	prof_begin( "Callback_PlayerDamage log" );

	// Do debug print if it's enabled
	if(getDvarInt("g_debugDamage"))
		println("client:" + self getEntityNumber() + " health:" + self.health + " attacker:" + eAttacker.clientid + " inflictor is player:" + isPlayer(eInflictor) + " damage:" + iDamage + " hitLoc:" + sHitLoc);

	if(self.sessionstate != "dead")
	{
		lpselfnum = self getEntityNumber();
		lpselfname = self.name;
		lpselfteam = self.pers["team"];
		lpselfGuid = self getGuid();
		lpattackerteam = "";

		if(isPlayer(eAttacker))
		{
			lpattacknum = eAttacker getEntityNumber();
			lpattackGuid = eAttacker getGuid();
			lpattackname = eAttacker.name;
			lpattackerteam = eAttacker.pers["team"];
		}
		else
		{
			lpattacknum = -1;
			lpattackGuid = "";
			lpattackname = "";
			lpattackerteam = "world";
		}

		logPrint("D;" + lpselfGuid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackGuid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n");
	} else {
		// Saved to handle blood splatters for knife and headshot
		self.sMeansOfDeath = sMeansOfDeath;
	}

	if ( getdvarint("scr_hitloc_debug") )
	{
		if ( !isdefined( eAttacker.hitlocInited ) )
		{
			for ( i = 0; i < 6; i++ )
			{
				eAttacker setClientDvar( "ui_hitloc_" + i, "" );
			}
			eAttacker.hitlocInited = true;
		}

		if ( isPlayer( eAttacker ) && !level.splitscreen )
		{
			colors = [];
			colors[0] = 2;
			colors[1] = 3;
			colors[2] = 5;
			colors[3] = 7;

			elemcount = 6;
			if ( !isdefined( eAttacker.damageInfo ) )
			{
				eAttacker.damageInfo = [];
				for ( i = 0; i < elemcount; i++ )
				{
					eAttacker.damageInfo[i] = spawnstruct();
					eAttacker.damageInfo[i].damage = 0;
					eAttacker.damageInfo[i].hitloc = "";
					eAttacker.damageInfo[i].bp = false;
					eAttacker.damageInfo[i].jugg = false;
					eAttacker.damageInfo[i].colorIndex = 0;
				}
				eAttacker.damageInfoColorIndex = 0;
				eAttacker.damageInfoVictim = undefined;
			}

			for ( i = elemcount-1; i > 0; i-- )
			{
				eAttacker.damageInfo[i].damage = eAttacker.damageInfo[i - 1].damage;
				eAttacker.damageInfo[i].hitloc = eAttacker.damageInfo[i - 1].hitloc;
				eAttacker.damageInfo[i].bp = eAttacker.damageInfo[i - 1].bp;
				eAttacker.damageInfo[i].jugg = eAttacker.damageInfo[i - 1].jugg;
				eAttacker.damageInfo[i].colorIndex = eAttacker.damageInfo[i - 1].colorIndex;
			}
			eAttacker.damageInfo[0].damage = iDamage;
			eAttacker.damageInfo[0].hitloc = sHitLoc;
			eAttacker.damageInfo[0].bp = (iDFlags & level.iDFLAGS_PENETRATION);
			eAttacker.damageInfo[0].jugg = self hasPerk( "specialty_armorvest" );
			if ( isdefined( eAttacker.damageInfoVictim ) && eAttacker.damageInfoVictim != self )
			{
				eAttacker.damageInfoColorIndex++;
				if ( eAttacker.damageInfoColorIndex == colors.size )
					eAttacker.damageInfoColorIndex = 0;
			}
			eAttacker.damageInfoVictim = self;
			eAttacker.damageInfo[0].colorIndex = eAttacker.damageInfoColorIndex;

			for ( i = 0; i < elemcount; i++ )
			{
				color = "^" + colors[ eAttacker.damageInfo[i].colorIndex ];
				if ( eAttacker.damageInfo[i].hitloc != "" )
				{
					val = color + eAttacker.damageInfo[i].hitloc;
					if ( eAttacker.damageInfo[i].bp )
						val += " (BP)";
					if ( eAttacker.damageInfo[i].jugg  )
						val += " (Jugg)";
					eAttacker setClientDvar( "ui_hitloc_" + i, val );
				}
				eAttacker setClientDvar( "ui_hitloc_damage_" + i, color + eAttacker.damageInfo[i].damage );
			}
		}
	}

	prof_end( "Callback_PlayerDamage log" );
}

finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	if ( level.gametype == "hns" && self.pers["team"] == game["defenders"] && iDamage >= self.health ) {
		self thread maps\mp\gametypes\hns::killPropOwner( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
	} else {
		self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
	}

	self damageShellshockAndRumble( eInflictor, sWeapon, sMeansOfDeath, iDamage );
}

damageShellshockAndRumble( eInflictor, sWeapon, sMeansOfDeath, iDamage )
{
	self thread maps\mp\gametypes\_weapons::onWeaponDamage( eInflictor, sWeapon, sMeansOfDeath, iDamage );
	self PlayRumbleOnEntity( "damage_heavy" );
}

default_getTeamKillPenalty( eInflictor, attacker, sMeansOfDeath, sWeapon )
{
	teamkill_penalty = 1;
	
	if ( sWeapon == "airstrike_mp" )
	{
		teamkill_penalty = maps\mp\gametypes\_tweakables::getTweakableValue( "team", "airstrikeTeamKillPenalty" );
	}
	return teamkill_penalty;
}

default_getTeamKillScore( eInflictor, attacker, sMeansOfDeath, sWeapon )
{
	return maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
}

Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	self endon( "spawned" );

	if ( level.inReadyUpPeriod )
		return;

	self notify( "killed_player" );

	// back translation as explodable_barrel is not propagated correctly
	if ( issubstr( sMeansOfDeath, "MOD_IMPACT" ) && sWeapon == "destructible_car" )
	  {
	    sMeansOfDeath = "MOD_CRUSH";
	    sWeapon = "explodable_barrel";
	  }

	if ( self.sessionteam == "spectator" )
		return;

	if ( game["state"] == "postgame" )
		return;


	prof_begin( "PlayerKilled pre constants" );

	deathTimeOffset = 0;
	if ( isdefined( self.useLastStandParams ) )
	{
		self.useLastStandParams = undefined;

		assert( isdefined( self.lastStandParams ) );

		eInflictor = self.lastStandParams.eInflictor;
		attacker = self.lastStandParams.attacker;
		iDamage = self.lastStandParams.iDamage;
		sMeansOfDeath = self.lastStandParams.sMeansOfDeath;
		sWeapon = self.lastStandParams.sWeapon;
		vDir = self.lastStandParams.vDir;
		sHitLoc = self.lastStandParams.sHitLoc;
		fDistance = self.lastStandParams.fDistance;

		deathTimeOffset = (gettime() - self.lastStandParams.lastStandStartTime) / 1000;

		self.lastStandParams = undefined;
	} else {
		fDistance = distance( self.origin, attacker.origin );
	}

	if( maps\mp\gametypes\_weapons::isSniper( sWeapon ) && sMeansOfDeath == "MOD_IMPACT" )
		sMeansOfDeath = "MOD_RIFLE_BULLET";

	if( isHeadShot( sWeapon, sHitLoc, sMeansOfDeath ) )
		sMeansOfDeath = "MOD_HEAD_SHOT";

	if( attacker.classname == "script_vehicle" && isDefined( attacker.owner ) )
		attacker = attacker.owner;

	// Send player_killed event with all the data to the player
	self notify( "player_killed", eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, fDistance );

	// send out an obituary message to all clients about the kill
	if ( level.scr_show_obituaries != 0 ) {
		if( level.teamBased && isDefined( attacker.pers ) && self.team == attacker.team && sMeansOfDeath == "MOD_GRENADE" && level.friendlyfire == 0 ) {
			obituary(self, self, sWeapon, sMeansOfDeath);
		} else {
			if ( level.scr_show_obituaries == 1 || ( level.teamBased && isDefined( attacker.pers ) && self.team == attacker.team ) ) {
				obituary(self, attacker, sWeapon, sMeansOfDeath);
			}
		}
	}

	// self maps\mp\gametypes\_weapons::updateWeaponUsageStats();
	if ( !level.inGracePeriod )
	{
		self maps\mp\gametypes\_weapons::dropWeaponForDeath( attacker );
		self maps\mp\gametypes\_weapons::dropOffhand();
	}

	maps\mp\gametypes\_spawnlogic::deathOccured(self, attacker);

	self.sessionstate = "dead";

	// Check if we should show the player status
	if ( level.scr_show_player_status == 1 ) {
		self.statusicon = "hud_status_dead";
	} else {
		self.statusicon = "";
	}

	self.pers["weapon"] = undefined;

	self.killedPlayersCurrent = [];

	self.deathCount++;

	if( !isDefined( self.switching_teams ) )
	{
		// if team killed we reset kill streak, but dont count death and death streak
		if ( isPlayer( attacker ) && level.teamBased && ( attacker != self ) && ( self.pers["team"] == attacker.pers["team"] ) )
		{
			self.cur_kill_streak = 0;
		}
		else
		{
			self incPersStat( "deaths", 1 );
			self.deaths = self getPersStat( "deaths" );
			self updatePersRatio( "kdratio", "kills", "deaths" );

			self.cur_kill_streak = 0;
			self.cur_death_streak++;

			if ( self.cur_death_streak > self.death_streak )
			{
				self maps\mp\gametypes\_persistence::statSet( "death_streak", self.cur_death_streak );
				self.death_streak = self.cur_death_streak;
			}
		}
	}

	lpselfnum = self getEntityNumber();
	lpselfname = self.name;
	lpattackGuid = "";
	lpattackname = "";
	if( isdefined( self.pers["team"] ) )
		lpselfteam = self.pers["team"];
	else
		lpselfteam = "";
	lpselfguid = self getGuid();
	lpattackerteam = "";

	lpattacknum = -1;

	prof_end( "PlayerKilled pre constants" );

	if( isPlayer( attacker ) )
	{
		lpattackGuid = attacker getGuid();
		lpattackname = attacker.name;
		if( isdefined( attacker.pers["team"] ) )
			lpattackerteam = attacker.pers["team"];
		else
			lpattackerteam = "";		
			
		if ( attacker == self ) // killed himself
		{
			doKillcam = false;

			// suicide kill cam
			//lpattacknum = attacker getEntityNumber();
			//doKillcam = true;

			// switching teams
			if ( isDefined( self.switching_teams ) )
			{
				if ( !level.teamBased && ((self.leaving_team == "allies" && self.joining_team == "axis") || (self.leaving_team == "axis" && self.joining_team == "allies")) )
				{
					playerCounts = self maps\mp\gametypes\_teams::CountPlayers();
					playerCounts[self.leaving_team]--;
					playerCounts[self.joining_team]++;

					if( (playerCounts[self.joining_team] - playerCounts[self.leaving_team]) > 1 )
					{
						self thread [[level.onXPEvent]]( "suicide" );
						self incPersStat( "suicides", 1 );
						self.suicides = self getPersStat( "suicides" );
					}
				}
			}
			else
			{
				self thread [[level.onXPEvent]]( "suicide" );
				self incPersStat( "suicides", 1 );
				self.suicides = self getPersStat( "suicides" );

				// suicides will be substracted from the players score only
				maps\mp\gametypes\_globallogic::givePlayerScore( "suicide", self );

				if ( sMeansOfDeath == "MOD_SUICIDE" && sHitLoc == "none" && self.throwingGrenade )
				{
					self.lastGrenadeSuicideTime = gettime();
				}
			}

			if( isDefined( self.friendlydamage ) )
				self iPrintLn(&"MP_FRIENDLY_FIRE_WILL_NOT");
		}
		else
		{
			prof_begin( "PlayerKilled attacker" );

			lpattacknum = attacker getEntityNumber();

			doKillcam = true;

			if ( level.teamBased && self.pers["team"] == attacker.pers["team"] && sMeansOfDeath == "MOD_GRENADE" && level.friendlyfire == 0 )
			{
			}
			else if ( level.teamBased && self.pers["team"] == attacker.pers["team"] ) // killed by a friendly
			{
				attacker notify("team_kill", self, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime );

				attacker thread [[level.onXPEvent]]( "teamkill" );

				attacker.pers["teamkills"] += 1.0;

				attacker.teamkillsThisRound++;

				if ( maps\mp\gametypes\_tweakables::getTweakableValue( "team", "teamkillpointloss" ) )
				{
				  // we have to differentiate between kills and teamkills
				  maps\mp\gametypes\_globallogic::givePlayerScore( "teamkill", attacker );
				  // team could suffer from teamkills too -> overall score will be reduced
				  if ( level.scr_score_tk_affects_teamscore ) {
						giveTeamScore( "teamkill", attacker.team,  attacker, self );
					}
				}

				if ( getTimePassed() < 5000 )
					teamKillDelay = 1;
				else if ( attacker.pers["teamkills"] > 1 && getTimePassed() < (8000 + (attacker.pers["teamkills"] * 1000)) )
					teamKillDelay = 1;
				else
					teamKillDelay = attacker TeamKillDelay();

				if ( teamKillDelay > 0 )
				{
					attacker.teamKillPunish = true;
					attacker suicide();
					attacker thread reduceTeamKillsOverTime();
				}
			}
			else
			{
				prof_begin( "pks1" );

				attacker incPersStat( "kills", 1 );
				attacker.kills = attacker getPersStat( "kills" );
				attacker updatePersRatio( "kdratio", "kills", "deaths" );

				// Check if the victim was killed by an airstrike or helicopter to give streak point
				streakGiven = false;

				if ( isAlive( attacker ) )
				{
					if ( !isDefined( eInflictor ) || !isDefined( eInflictor.requiredDeathCount ) || attacker.deathCount == eInflictor.requiredDeathCount ) {

						switch ( sWeapon ) {
							case "artillery_mp":
								if ( level.scr_airstrike_kills_toward_streak == 1 ) {
									attacker.cur_kill_streak++;
									streakGiven = true;
								}
								break;
							case "cobra_20mm_mp":
							case "cobra_FFAR_mp":
							case "hind_FFAR_mp":
								if ( level.scr_helicopter_kills_toward_streak == 1 ) {
									attacker.cur_kill_streak++;
									streakGiven = true;
								}
								break;
							default:
								attacker.cur_kill_streak++;
								streakGiven = true;
								break;
						}
					}
				}

				// Send the event to notify that this player has increased the kill streak
				if ( isAlive( attacker ) ) {
					attacker notify( "kill_streak", attacker.cur_kill_streak, streakGiven, sMeansOfDeath );
				}

				// Check to make sure the kill streak was given to the attacker or the he/she might get a duplicate hardpoint
				if ( isDefined( level.hardpointItems ) && isAlive( attacker ) && streakGiven )
					attacker thread maps\mp\gametypes\_hardpoints::giveHardpointItemForStreak();

				attacker.cur_death_streak = 0;

				if ( attacker.cur_kill_streak > attacker.kill_streak )
				{
					attacker maps\mp\gametypes\_persistence::statSet( "kill_streak", attacker.cur_kill_streak );
					attacker.kill_streak = attacker.cur_kill_streak;
				}


				// Get the score corresponding with this kill
				ScoreOfPlayer = openwarfare\_scoresystem::getPointsForKill( sMeansOfDeath, sWeapon, attacker );

				// Make sure the attacker didn't switch to spectator
				if ( attacker.pers["team"] != "spectator" && ScoreOfPlayer["score"] != 0 ) {
					// Give player the score points
					givePlayerScore( ScoreOfPlayer["type"], attacker, self );
				
					// Give player's team score
					if ( level.teamBased ) {
						giveTeamScore( ScoreOfPlayer["type"], attacker.pers["team"],  attacker, self );
					}
					
					// Give XP points to the player
					attacker thread maps\mp\gametypes\_rank::giveRankXP( ScoreOfPlayer["type"],  ScoreOfPlayer["score"] );
				}				
					
				name = ""+self.clientid;
				if ( !isDefined( attacker.killedPlayers[name] ) )
					attacker.killedPlayers[name] = 0;

				if ( !isDefined( attacker.killedPlayersCurrent[name] ) )
					attacker.killedPlayersCurrent[name] = 0;

				attacker.killedPlayers[name]++;
				attacker.killedPlayersCurrent[name]++;

				attackerName = ""+attacker.clientid;
				if ( !isDefined( self.killedBy[attackerName] ) )
					self.killedBy[attackerName] = 0;

				self.killedBy[attackerName]++;

				// helicopter score for team
				if( level.teamBased && isdefined( level.chopper ) && isdefined( Attacker ) && Attacker == level.chopper )
					giveTeamScore( "kill", attacker.team,  attacker, self );

				maps\mp\gametypes\_globallogic::givePlayerScore( "death", self );

				if ( level.scr_allowbattlechatter == 1 && maps\mp\gametypes\_battlechatter_mp::shouldPlayBattlechatter( level.scr_battlechatter_kill_probability ) )
					level thread maps\mp\gametypes\_battlechatter_mp::sayLocalSoundDelayed( attacker, "kill", 0.75 );

				prof_end( "pks1" );

				if ( level.teamBased )
				{
					prof_begin( "PlayerKilled assists" );

					if ( isdefined( self.attackers ) )
					{
						for ( j = 0; j < self.attackers.size; j++ )
						{
							player = self.attackers[j];

							if ( !isDefined( player ) )
								continue;

							if ( player == attacker )
								continue;

							damage_done = self.attackerDamage[player.clientId];
							player thread processAssist( self, damage_done );
						}
						self.attackers = [];
					}

					prof_end( "PlayerKilled assists" );
				}
			}

			prof_end( "PlayerKilled attacker" );
		}
	}
	else
	{
		doKillcam = false;
		killedByEnemy = false;

		lpattacknum = -1;
		lpattackguid = "";
		lpattackname = "";
		lpattackerteam = "world";

		// even if the attacker isn't a player, it might be on a team
		if ( isDefined( attacker ) && isDefined( attacker.team ) && (attacker.team == "axis" || attacker.team == "allies") )
		{
			if ( attacker.team != self.pers["team"] )
			{
				killedByEnemy = true;
				if ( level.teamBased )
					giveTeamScore( "kill", attacker.team, attacker, self );
			}
		}
	}

	prof_begin( "PlayerKilled post constants" );

	if ( isDefined( attacker ) && isPlayer( attacker ) && attacker != self && (!level.teambased || attacker.pers["team"] != self.pers["team"]) )
		self thread maps\mp\gametypes\_missions::playerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, sHitLoc );
	else
		self notify("playerKilledChallengesProcessed");

	logPrint( "K;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackguid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n" );
	attackerString = "none";
	if ( isPlayer( attacker ) ) // attacker can be the worldspawn if it's not a player
		attackerString = attacker getXuid() + "(" + lpattackname + ")";
	self logstring( "d " + sMeansOfDeath + "(" + sWeapon + ") a:" + attackerString + " d:" + iDamage + " l:" + sHitLoc + " @ " + int( self.origin[0] ) + " " + int( self.origin[1] ) + " " + int( self.origin[2] ) );

	level thread updateTeamStatus();

	if ( level.gametype != "hns" || self.pers["team"] == game["attackers"] ) {
		self maps\mp\gametypes\_gameobjects::detachUseModels(); // want them detached before we create our corpse
	
		body = self clonePlayer( deathAnimDuration );
		if ( self isOnLadder() || self isMantling() )
			body startRagDoll();
	
		thread delayStartRagdoll( body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath );
	
		self.body = body;
		self notify("player_body");
	
		if ( !isDefined( self.switching_teams ) && level.scr_hud_show_death_icons == 1 )
			thread maps\mp\gametypes\_deathicons::addDeathicon( body, self, self.pers["team"], 5.0 );
	}
	
	self.switching_teams = undefined;
	self.joining_team = undefined;
	self.leaving_team = undefined;

	self thread [[level.onPlayerKilled]](eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);

	if ( sWeapon == "artillery_mp" || sWeapon == "claymore_mp" || sWeapon == "frag_grenade_short_mp" || sWeapon == "none" || isSubStr( sWeapon, "cobra" ) )
		doKillcam = false;

	if ( ( isSubStr( sWeapon, "cobra" ) ) && isdefined( eInflictor ) )
	{
		killcamentity = eInflictor getEntityNumber();
		doKillcam = true;
	}
	else
	{
		killcamentity = -1;
	}

	self.deathTime = getTime();

	// let the player watch themselves die
	wait ( 0.25 );
	self.cancelKillcam = false;
	self thread cancelKillCamOnUse();
	postDeathDelay = waitForTimeOrNotifies( 1.75 );
	self notify ( "death_delay_finished" );

	if ( game["state"] != "playing" )
		return;

	respawnTimerStartTime = gettime();

	/#
	if ( getDvarInt( "scr_forcekillcam" ) != 0 )
	{
		doKillcam = true;
		if ( lpattacknum < 0 )
			lpattacknum = self getEntityNumber();
	}
	#/

	if ( !self.cancelKillcam && doKillcam && level.killcam )
	{
		livesLeft = !(level.numLives && !self.pers["lives"]);
		timeUntilSpawn = self TimeUntilSpawn( true );
		willRespawnImmediately = livesLeft && (timeUntilSpawn <= 0);
		perks = getPerks( attacker );
		
		if ( level.gametype == "hns" && self.pers["team"] == game["defenders"] ) {
			self setClientDvar( "cg_thirdPerson", "0" );
		}		
		self maps\mp\gametypes\_killcam::killcam( lpattacknum, killcamentity, sWeapon, postDeathDelay + deathTimeOffset, psOffsetTime, willRespawnImmediately, timeUntilRoundEnd(), perks, attacker );
		if ( level.gametype == "hns" && self.pers["team"] == game["defenders"] ) {
			self setClientDvar( "cg_thirdPerson", "1" );
		}		
	}

	if ( sMeansOfDeath == "MOD_TRIGGER_HURT" ) {
		self.freezeangles = undefined;
		self.freezeorigin = undefined;
	}

	prof_end( "PlayerKilled post constants" );

	if ( game["state"] != "playing" )
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;
		return;
	}

	// class may be undefined if we have changed teams
	if ( self isValidClass( self.class ) )
	{
		timePassed = (gettime() - respawnTimerStartTime) / 1000;
		self thread [[level.spawnClient]]( timePassed );
	}
}


cancelKillCamOnUse()
{
	self endon ( "death_delay_finished" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );

	for ( ;; )
	{
		if ( !self UseButtonPressed() )
		{
			wait ( 0.05 );
			continue;
		}

		buttonTime = 0;
		while( self UseButtonPressed() )
		{
			buttonTime += 0.05;
			wait ( 0.05 );
		}

		if ( buttonTime >= 0.5 )
			continue;

		buttonTime = 0;

		while ( !self UseButtonPressed() && buttonTime < 0.5 )
		{
			buttonTime += 0.05;
			wait ( 0.05 );
		}

		if ( buttonTime >= 0.5 )
			continue;

		self.cancelKillcam = true;
		return;
	}
}


waitForTimeOrNotifies( desiredDelay )
{
	startedWaiting = getTime();

//	while( self.doingNotify )
//		wait ( 0.05 );

	waitedTime = (getTime() - startedWaiting)/1000;

	if ( waitedTime < desiredDelay )
	{
		wait desiredDelay - waitedTime;
		return desiredDelay;
	}
	else
	{
		return waitedTime;
	}
}

reduceTeamKillsOverTime()
{
	timePerOneTeamkillReduction = 20.0;
	reductionPerSecond = 1.0 / timePerOneTeamkillReduction;

	while(1)
	{
		if ( isAlive( self ) )
		{
			self.pers["teamkills"] -= reductionPerSecond;
			if ( self.pers["teamkills"] < level.minimumAllowedTeamKills )
			{
				self.pers["teamkills"] = level.minimumAllowedTeamKills;
				break;
			}
		}
		wait 1;
	}
}

getPerks( player )
{
	perks[0] = "specialty_null";
	perks[1] = "specialty_null";
	perks[2] = "specialty_null";
	
	if ( level.gametype == "hns" && player.pers["team"] == game["defenders"] )
		return perks;

	if ( !level.rankedMatch || level.gametype == "gg" || level.gametype == "ss" || level.gametype == "oitc" ) {
		if ( isPlayer( player ) )
		{
			if ( isDefined( player.specialty[0] ) )
				perks[0] = player.specialty[0];
			if ( isDefined( player.specialty[1] ) )
				perks[1] = player.specialty[1];
			if ( isDefined( player.specialty[2] ) )
				perks[2] = player.specialty[2];
		}
	} else {
		if ( isPlayer( player ) && !level.oldschool )
		{
			// if public game, if is not bot, if class selection is custom, if is currently using a custom class instead of pending class change
			if ( !isdefined( player.pers["isBot"] ) && isSubstr( player.curClass, "CLASS_CUSTOM" ) && isdefined(player.custom_class) )
			{
				//assertex( isdefined(player.custom_class), "Player: " + player.name + "'s Custom Class: " + player.pers["class"] + " is corrupted." );

				class_num = player.class_num;
				if ( isDefined( player.custom_class[class_num]["specialty1"] ) )
					perks[0] = player.custom_class[class_num]["specialty1"];
				if ( isDefined( player.custom_class[class_num]["specialty2"] ) )
					perks[1] = player.custom_class[class_num]["specialty2"];
				if ( isDefined( player.custom_class[class_num]["specialty3"] ) )
					perks[2] = player.custom_class[class_num]["specialty3"];
			}
			else
			{
				if ( isDefined( level.default_perk[player.curClass][0] ) )
					perks[0] = level.default_perk[player.curClass][0];
				if ( isDefined( level.default_perk[player.curClass][1] ) )
					perks[1] = level.default_perk[player.curClass][1];
				if ( isDefined( level.default_perk[player.curClass][2] ) )
					perks[2] = level.default_perk[player.curClass][2];
			}
		}
	}

	return perks;
}

processAssist( killedplayer, damagedone )
{
	self endon("disconnect");
	killedplayer endon("disconnect");

	wait .05; // don't ever run on the same frame as the playerkilled callback.
	WaitTillSlowProcessAllowed();

	if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" )
		return;

	if ( self.pers["team"] == killedplayer.pers["team"] )
		return;

	assist_level = "assist";
	
	assist_level_value = int( floor( damagedone / 25 ) );
	
	if ( assist_level_value > 0 )
	{
		if ( assist_level_value > 3 )
		{
			assist_level_value = 3;
		}
		assist_level = assist_level + "_" + ( assist_level_value * 25 );
	}
	
	self thread [[level.onXPEvent]]( "assist" );
	self incPersStat( "assists", 1 );
	self.assists = self getPersStat( "assists" );

	givePlayerScore( "assist", self, killedplayer );

	self thread maps\mp\gametypes\_missions::playerAssist();
}

Callback_PlayerLastStand( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	playerHasPistol = false;

	self.health = 1;

	self.lastStandParams = spawnstruct();
	self.lastStandParams.eInflictor = eInflictor;
	self.lastStandParams.attacker = attacker;
	self.lastStandParams.iDamage = iDamage;
	self.lastStandParams.sMeansOfDeath = sMeansOfDeath;
	self.lastStandParams.sWeapon = sWeapon;
	self.lastStandParams.vDir = vDir;
	self.lastStandParams.sHitLoc = sHitLoc;
	self.lastStandParams.lastStandStartTime = gettime();
	if ( isDefined( attacker ) ) {
		self.lastStandParams.fDistance = distance( self.origin, attacker.origin );
	} else {
		self.lastStandParams.fDistance = 0;
	}

	mayDoLastStand = mayDoLastStand( sWeapon, sMeansOfDeath, sHitLoc );
	/#
	if ( getdvar("scr_forcelaststand" ) == "1" )
		mayDoLastStand = true;
	#/
	if ( !mayDoLastStand )
	{
		self.useLastStandParams = true;
		self ensureLastStandParamsValidity();
		self suicide();
		return;
	}

	weaponslist = self getweaponslist();
	assertex( isdefined( weaponslist ) && weaponslist.size > 0, "Player's weapon(s) missing before dying -=Last Stand=-" );

	self thread maps\mp\gametypes\_gameobjects::onPlayerLastStand();

	// Let's make sure the player doesn't drop the pistol
	if ( !maps\mp\gametypes\_weapons::isPistol( self.lastDroppableWeapon ) ) {
		self maps\mp\gametypes\_weapons::dropWeaponForDeath( attacker );
	}

	grenadeTypePrimary = "frag_grenade_mp";

	// check if player has pistol
	for( i = 0; i < weaponslist.size; i++ )
	{
		weapon = weaponslist[i];
		if ( maps\mp\gametypes\_weapons::isPistol( weapon ) )
		{
			// get the ammo count before we take all the weapons away
			totalAmmoLeft = self getAmmoCount( weapon );
			clipAmmoLeft = self getWeaponAmmoClip( weapon );

			// take away all weapon and leave this pistol
			self takeallweapons();
			self maps\mp\gametypes\_hardpoints::giveOwnedHardpointItem();
			self giveweapon( weapon );

			// Check if we just give the ammo that had left or max amount
			if ( level.specialty_pistoldeath_check_pistol == 1 ) {
				// If the player doesn't any ammo left there's no point to go into last stand
				if ( totalAmmoLeft > 0 ) {
					self setWeaponAmmoStock( weapon, totalAmmoLeft - clipAmmoLeft );
					self setWeaponAmmoClip( weapon, clipAmmoLeft );
				} else {
					self.useLastStandParams = true;
					self ensureLastStandParamsValidity();
					self suicide();
					return;
				}
			} else {
				self giveMaxAmmo( weapon );
			}
			self switchToWeapon( weapon );
			self GiveWeapon( grenadeTypePrimary );
			self SetWeaponAmmoClip( grenadeTypePrimary, 0 );
			self SwitchToOffhand( grenadeTypePrimary );

			playerHasPistol = true;
			break;
		}
	}

	// Check if the player already had a pistol
	if ( !playerHasPistol ) {
		// This player doesn't have any pistol so there's no point to go into last stand
		if ( level.specialty_pistoldeath_check_pistol == 1 ) {
			self.useLastStandParams = true;
			self ensureLastStandParamsValidity();
			self suicide();
			return;
		}

		self takeallweapons();
		self maps\mp\gametypes\_hardpoints::giveOwnedHardpointItem();
		self giveWeapon( "beretta_mp" );
		self giveMaxAmmo( "beretta_mp" );
		self switchToWeapon( "beretta_mp" );
		self GiveWeapon( grenadeTypePrimary );
		self SetWeaponAmmoClip( grenadeTypePrimary, 0 );
		self SwitchToOffhand( grenadeTypePrimary );
	}

	notifyData = spawnStruct();
	notifyData.titleText = game["strings"]["last_stand"]; //"Last Stand!";
	notifyData.iconName = "specialty_pistoldeath";
	notifyData.glowColor = (1,0,0);
	notifyData.sound = "mp_last_stand";
	notifyData.duration = 2.0;
	self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );

	self thread lastStandTimer( 10 );
}


lastStandTimer( delay )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "game_ended" );

	self thread lastStandWaittillDeath();

	self.lastStand = true;
	self setLowerMessage( &"PLATFORM_COWARDS_WAY_OUT" );

	self thread lastStandAllowSuicide();
	self thread lastStandKeepOverlay();

	wait delay;

	self thread LastStandBleedOut();
}

LastStandBleedOut()
{
	self.useLastStandParams = true;
	self ensureLastStandParamsValidity();
	self suicide();
}

lastStandAllowSuicide()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "game_ended" );

	while(1)
	{
		if ( self useButtonPressed() )
		{
			pressStartTime = gettime();
			while ( self useButtonPressed() )
			{
				wait .05;
				if ( gettime() - pressStartTime > 700 )
					break;
			}
			if ( gettime() - pressStartTime > 700 )
				break;
		}
		wait .05;
	}

	self thread LastStandBleedOut();
}

lastStandKeepOverlay()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "game_ended" );

	// keep the health overlay going by making code think the player is getting damaged
	while(1)
	{
		self.health = 2;
		wait .05;
		self.health = 1;
		wait .5;
	}
}

lastStandWaittillDeath()
{
	self endon( "disconnect" );

	self waittill( "death" );

	self clearLowerMessage();
	self.lastStand = undefined;
}

mayDoLastStand( sWeapon, sMeansOfDeath, sHitLoc )
{
	if ( sMeansOfDeath != "MOD_PISTOL_BULLET" && sMeansOfDeath != "MOD_RIFLE_BULLET" && sMeansOfDeath != "MOD_FALLING" )
		return false;

	if ( isHeadShot( sWeapon, sHitLoc, sMeansOfDeath ) )
		return false;

	return true;
}

ensureLastStandParamsValidity()
{
	// attacker may have become undefined if the player that killed me has disconnected
	if ( !isDefined( self.lastStandParams.attacker ) )
		self.lastStandParams.attacker = self;
}

setSpawnVariables()
{
	resetTimeout();

	// Stop shellshock and rumble
	self StopShellshock();
	self StopRumble( "damage_heavy" );
}

notifyConnecting()
{
	waittillframeend;

	if( isDefined( self ) )
		level notify( "connecting", self );
}


setObjectiveText( team, text )
{
	game["strings"]["objective_"+team] = text;
	precacheString( text );
}

setObjectiveScoreText( team, text )
{
	game["strings"]["objective_score_"+team] = text;
	precacheString( text );
}

setObjectiveHintText( team, text )
{
	game["strings"]["objective_hint_"+team] = text;
	precacheString( text );
}

getObjectiveText( team )
{
	return game["strings"]["objective_"+team];
}

getObjectiveScoreText( team )
{
	return game["strings"]["objective_score_"+team];
}

getObjectiveHintText( team )
{
	return game["strings"]["objective_hint_"+team];
}

getHitLocHeight( sHitLoc )
{
	switch( sHitLoc )
	{
		case "helmet":
		case "head":
		case "neck":
			return 60;
		case "torso_upper":
		case "right_arm_upper":
		case "left_arm_upper":
		case "right_arm_lower":
		case "left_arm_lower":
		case "right_hand":
		case "left_hand":
		case "gun":
			return 48;
		case "torso_lower":
			return 40;
		case "right_leg_upper":
		case "left_leg_upper":
			return 32;
		case "right_leg_lower":
		case "left_leg_lower":
			return 10;
		case "right_foot":
		case "left_foot":
			return 5;
	}
	return 48;
}

debugLine( start, end )
{
	for ( i = 0; i < 50; i++ )
	{
		line( start, end );
		wait .05;
	}
}

delayStartRagdoll( ent, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath )
{
	if ( isDefined( ent ) )
	{
		deathAnim = ent getcorpseanim();
		if ( animhasnotetrack( deathAnim, "ignore_ragdoll" ) )
			return;
	}

	if ( level.oldschool )
	{
		if ( !isDefined( vDir ) )
			vDir = (0,0,0);

		explosionPos = ent.origin + ( 0, 0, getHitLocHeight( sHitLoc ) );
		explosionPos -= vDir * 20;
		//thread debugLine( ent.origin + (0,0,(explosionPos[2] - ent.origin[2])), explosionPos );
		explosionRadius = 40;
		explosionForce = .75;
		if ( sMeansOfDeath == "MOD_IMPACT" || sMeansOfDeath == "MOD_EXPLOSIVE" || isSubStr(sMeansOfDeath, "MOD_GRENADE") || isSubStr(sMeansOfDeath, "MOD_PROJECTILE") || sHitLoc == "head" || sHitLoc == "helmet" )
		{
			explosionForce = 2.5;
		}

		ent startragdoll( 1 );

		wait .05;

		if ( !isDefined( ent ) )
			return;

		// apply extra physics force to make the ragdoll go crazy
		physicsExplosionSphere( explosionPos, explosionRadius, explosionRadius/2, explosionForce );
		return;
	}

	wait( 0.2 );

	if ( !isDefined( ent ) )
		return;

	if ( ent isRagDoll() )
		return;

	deathAnim = ent getcorpseanim();

	startFrac = 0.35;

	if ( animhasnotetrack( deathAnim, "start_ragdoll" ) )
	{
		times = getnotetracktimes( deathAnim, "start_ragdoll" );
		if ( isDefined( times ) )
			startFrac = times[0];
	}

	waitTime = startFrac * getanimlength( deathAnim );
	wait( waitTime );

	if ( isDefined( ent ) )
	{
		println( "Ragdolling after " + waitTime + " seconds" );
		ent startragdoll( 1 );
	}
}


isExcluded( entity, entityList )
{
	for ( index = 0; index < entityList.size; index++ )
	{
		if ( entity == entityList[index] )
			return true;
	}
	return false;
}

leaderDialog( dialog, team, group, excludeList )
{
	assert( isdefined( level.players ) );

	if ( level.splitscreen )
		return;

	if ( !isDefined( team ) )
	{
		leaderDialogBothTeams( dialog, "allies", dialog, "axis", group, excludeList );
		return;
	}

	if ( level.splitscreen )
	{
		if ( level.players.size )
			level.players[0] leaderDialogOnPlayer( dialog, group );
		return;
	}

	if ( isDefined( excludeList ) )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( (isDefined( player.pers["team"] ) && (player.pers["team"] == team )) && !isExcluded( player, excludeList ) )
				player leaderDialogOnPlayer( dialog, group );
		}
	}
	else
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( isDefined( player.pers["team"] ) && (player.pers["team"] == team ) )
				player leaderDialogOnPlayer( dialog, group );
		}
	}
}

leaderDialogBothTeams( dialog1, team1, dialog2, team2, group, excludeList )
{
	assert( isdefined( level.players ) );

	if ( level.splitscreen )
		return;

	if ( level.splitscreen )
	{
		if ( level.players.size )
			level.players[0] leaderDialogOnPlayer( dialog1, group );
		return;
	}

	if ( isDefined( excludeList ) )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			team = player.pers["team"];

			if ( !isDefined( team ) )
				continue;

			if ( isExcluded( player, excludeList ) )
				continue;

			if ( team == team1 )
				player leaderDialogOnPlayer( dialog1, group );
			else if ( team == team2 )
				player leaderDialogOnPlayer( dialog2, group );
		}
	}
	else
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			team = player.pers["team"];

			if ( !isDefined( team ) )
				continue;

			if ( team == team1 )
				player leaderDialogOnPlayer( dialog1, group );
			else if ( team == team2 )
				player leaderDialogOnPlayer( dialog2, group );
		}
	}
}


leaderDialogOnPlayer( dialog, group )
{
	// Check if we are allowed to play the dialog
	if( !level.scr_allow_leader_dialog )
		return;

	team = self.pers["team"];

	if ( level.splitscreen )
		return;

	if ( !isDefined( team ) )
		return;

	if ( team != "allies" && team != "axis" )
		return;

	if ( isDefined( group ) )
	{
		// ignore the message if one from the same group is already playing
		if ( self.leaderDialogGroup == group )
			return;

		hadGroupDialog = isDefined( self.leaderDialogGroups[group] );

		self.leaderDialogGroups[group] = dialog;
		dialog = group;

		// exit because the "group" dialog call is already in the queue
		if ( hadGroupDialog )
			return;
	}

	if ( !self.leaderDialogActive )
		self thread playLeaderDialogOnPlayer( dialog, team );
	else
		self.leaderDialogQueue[self.leaderDialogQueue.size] = dialog;
}


playLeaderDialogOnPlayer( dialog, team )
{
	self endon ( "disconnect" );

	self.leaderDialogActive = true;
	if ( isDefined( self.leaderDialogGroups[dialog] ) )
	{
		group = dialog;
		dialog = self.leaderDialogGroups[group];
		self.leaderDialogGroups[group] = undefined;
		self.leaderDialogGroup = group;
	}

	if ( isDefined( game["dialog"][dialog] ) ) {
		// Split all the dialogs that we should play
		dialogs = strtok( game["dialog"][dialog], ";" );
		for ( idialog = 0; idialog < dialogs.size; idialog++ ) {
			dialog = dialogs[idialog];
			self playLocalSound( game["voice"][team]+dialog );
			wait ( 3.0 );
		}
	}

	self.leaderDialogActive = false;
	self.leaderDialogGroup = "";

	if ( self.leaderDialogQueue.size > 0 )
	{
		nextDialog = self.leaderDialogQueue[0];

		for ( i = 1; i < self.leaderDialogQueue.size; i++ )
			self.leaderDialogQueue[i-1] = self.leaderDialogQueue[i];
		self.leaderDialogQueue[i-1] = undefined;

		self thread playLeaderDialogOnPlayer( nextDialog, team );
	}
}


getMostKilledBy()
{
	mostKilledBy = "";
	killCount = 0;

	killedByNames = getArrayKeys( self.killedBy );

	for ( index = 0; index < killedByNames.size; index++ )
	{
		killedByName = killedByNames[index];
		if ( self.killedBy[killedByName] <= killCount )
			continue;

		killCount = self.killedBy[killedByName];
		mostKilleBy = killedByName;
	}

	return mostKilledBy;
}


getMostKilled()
{
	mostKilled = "";
	killCount = 0;

	killedNames = getArrayKeys( self.killedPlayers );

	for ( index = 0; index < killedNames.size; index++ )
	{
		killedName = killedNames[index];
		if ( self.killedPlayers[killedName] <= killCount )
			continue;

		killCount = self.killedPlayers[killedName];
		mostKilled = killedName;
	}

	return mostKilled;
}


showPlayerJoinedTeam()
{
	switch ( self.pers["team"] ) {
		case "allies":
			self setClientDvar( "ui_team", "marines" );
			break;
		case "axis":
			self setClientDvar( "ui_team", "opfor" );
			break;
	}

	// Check if we should display these messages
	if ( level.scr_show_player_assignment == 0 )
		return;
	
	// Initialize variable
	teamJoined = &"";
	
	// Get what team the player has joined
	if ( self.pers["team"] == "spectator" ) {
		teamJoined = &"GAME_SPECTATOR";
	} else {
		switch ( game[self.pers["team"]] ) {
			case "sas":
			case "marines":
				teamJoined = level.scr_team_allies_name;
				break;
				
			case "russian":
			case "opfor":
			case "arab":
				teamJoined = level.scr_team_axis_name;
				break;
		}
	}
	
	// Display a message to all the players in the server
	iprintln( &"OW_JOINED_TEAM", self.name, teamJoined );
	
}
