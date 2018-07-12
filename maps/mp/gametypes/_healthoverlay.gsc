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

init()
{
	precacheShader("overlay_low_health");

	level.scr_health_hurt_sound = getdvarx( "scr_health_hurt_sound", "int", 1, 0, 1 );
	level.healthOverlayCutoff = 0.55; // getting the dvar value directly doesn't work right because it's a client dvar getdvarfloat("hud_healthoverlay_pulseStart");

	regenTime = level.scr_player_healthregentime;

	level.playerHealth_RegularRegenDelay = regenTime * 1000;

	level.healthRegenDisabled = (level.playerHealth_RegularRegenDelay <= 0);

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
		player thread onPlayerKilled();
		player thread onJoinedTeam();
		player thread onJoinedSpectators();
		player thread onPlayerDisconnect();
	}
}

onJoinedTeam()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_team");
		self notify("end_healthregen");
	}
}

onJoinedSpectators()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_spectators");
		self notify("end_healthregen");
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");
		self thread playerHealthRegen();
	}
}

onPlayerKilled()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("killed_player");
		self notify("end_healthregen");
	}
}

onPlayerDisconnect()
{
	self waittill("disconnect");
	self notify("end_healthregen");
}

playerHealthRegen()
{
	self endon("end_healthregen");

	if ( self.health <= 0 )
	{
		assert( !isalive( self ) );
		return;
	}

	maxhealth = self.maxhealth;
	oldhealth = maxhealth;
	player = self;
	health_add = 0;

	regenRate = 0.1; // 0.017;
	veryHurt = false;

	player.breathingStopTime = -10000;

	thread playerBreathingSound(maxhealth * 0.35);

	lastSoundTime_Recover = 0;
	hurtTime = 0;
	newHealth = 0;

	for (;;)
	{
		wait (0.05);

		// Check if this player is frozen
		if ( level.gametype == "ftag" && self.freezeTag["frozen"] )
			continue;

		if (player.health == maxhealth)
		{
			veryHurt = false;
			self.atBrinkOfDeath = false;
			continue;
		}

		if (player.health <= 0)
			return;
			
		wasVeryHurt = veryHurt;
		ratio = player.health / maxHealth;
		if (ratio <= level.healthOverlayCutoff)
		{
			veryHurt = true;
			self.atBrinkOfDeath = true;
			if (!wasVeryHurt)
			{
				hurtTime = gettime();
			}
		}

		if (player.health >= oldhealth)
		{
			if (gettime() - hurttime < level.playerHealth_RegularRegenDelay)
				continue;

			if ( level.healthRegenDisabled )
				continue;

			if (gettime() - lastSoundTime_Recover > level.playerHealth_RegularRegenDelay)
			{
				lastSoundTime_Recover = gettime();
				if ( level.scr_health_hurt_sound == 1 && ( level.gametype != "ftag" || !self.freezeTag["frozen"] ) )
					self playLocalSound("breathing_better");
			}

			if (veryHurt)
			{
				newHealth = ratio;
				if (gettime() > hurtTime + 3000)
					newHealth += regenRate;
			}
			else
				newHealth = 1;

			if ( newHealth >= 1.0 )
			{
				if ( veryHurt ) {
					self maps\mp\gametypes\_missions::healthRegenerated();
				}
				newHealth = 1.0;
			}

			if (newHealth <= 0)
			{
				// Player is dead
				return;
			}

			player setnormalhealth (newHealth);
			oldhealth = player.health;
			continue;
		}

		oldhealth = player.health;

		health_add = 0;
		hurtTime = gettime();
		player.breathingStopTime = hurtTime + 6000;
	}
}

playerBreathingSound(healthcap)
{
	self endon("end_healthregen");

	// Are pain sounds enabled?
	if ( level.scr_health_hurt_sound == 0 )
		return;

	wait (2);
	player = self;
	for (;;)
	{
		wait (0.2);
		if (player.health <= 0)
			return;

		// Player still has a lot of health so no breathing sound
		if (player.health >= healthcap)
			continue;

		if ( level.healthRegenDisabled && gettime() > player.breathingStopTime )
			continue;

		if ( level.gametype != "ftag" || !self.freezeTag["frozen"] )
			player playLocalSound("breathing_hurt");
			
		wait .784;
		wait (0.1 + randomfloat (0.8));
	}
}
