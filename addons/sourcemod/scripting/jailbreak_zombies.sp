#include <sourcemod>
#include <sdktools>
#include <franug_jb>
#include <cstrike>
#include <sdkhooks>

new bool:quieto;
new tiempo;
new Handle:eltimer = INVALID_HANDLE;

/* new bool:infiniteammo;

new activeOffset = -1;
new clip1Offset = -1;
new clip2Offset = -1;
new secAmmoTypeOffset = -1;
new priAmmoTypeOffset = -1; */


public OnPluginStart()
{
	HookEvent("player_spawn", Event_PlayerSpawn);
	
	HookEvent("player_hurt", OnPlayerHurt);
	
	//HookEvent("weapon_fire", EventWeaponFire);
	
	HookEvent("round_prestart", roundStart2);
	HookEvent("round_start", Event_RoundStart);
	
/* 	activeOffset = FindSendPropOffs("CAI_BaseNPC", "m_hActiveWeapon");
	
	clip1Offset = FindSendPropOffs("CBaseCombatWeapon", "m_iClip1");
	clip2Offset = FindSendPropOffs("CBaseCombatWeapon", "m_iClip2");
	
	priAmmoTypeOffset = FindSendPropOffs("CBaseCombatWeapon", "m_iPrimaryAmmoCount");
	secAmmoTypeOffset = FindSendPropOffs("CBaseCombatWeapon", "m_iSecondaryAmmoCount"); */
	
	for(new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)) OnClientPutInServer(i);
}

/* public Action:EventWeaponFire(Handle:event, const String:name[], bool:dontBroadcast)
{
    // Get all required event info.
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(infiniteammo) Client_ResetAmmo(client);
} */

/* public Client_ResetAmmo(client)
{
	new zomg = GetEntDataEnt2(client, activeOffset);
	if (clip1Offset != -1 && zomg != -1)
		SetEntData(zomg, clip1Offset, GetEntData(zomg, clip1Offset, 4)+1, 4, true);
	if (clip2Offset != -1 && zomg != -1)
		SetEntData(zomg, clip2Offset, GetEntData(zomg, clip2Offset, 4)+1, 4, true);
	if (priAmmoTypeOffset != -1 && zomg != -1)
		SetEntData(zomg, priAmmoTypeOffset, GetEntData(zomg, priAmmoTypeOffset, 4)+1, 4, true);
	if (secAmmoTypeOffset != -1 && zomg != -1)
		SetEntData(zomg, secAmmoTypeOffset, GetEntData(zomg, secAmmoTypeOffset, 4)+1, 4, true);
		
} */

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (eltimer != INVALID_HANDLE)
		KillTimer(eltimer);
		
	eltimer = INVALID_HANDLE;
	
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Zombies", false))
	{
		return;
	}
	
	tiempo = 16;
	eltimer = CreateTimer(1.0, contador, _, TIMER_REPEAT);
}

public Action:contador(Handle:timer, Handle:pack)
{
	--tiempo;
	if(tiempo < 1)
	{
		Vamos();
		PrintToChatAll(" \x04[Franug-JailBreak] \x05Now the zombies are free!");
		
		if (eltimer != INVALID_HANDLE)
			KillTimer(eltimer);
		
		eltimer = INVALID_HANDLE;
	}
	else if(tiempo == 14) PrintToChatAll(" \x04[Franug-JailBreak] \x05In zombie round, the CTs will go to Ts in 15 seconds!");
	else if(tiempo <= 10) PrintToChatAll(" \x04[Franug-JailBreak] \x05Still %i seconds for start the round!", tiempo);
}

public Action:roundStart2(Handle:event, const String:name[], bool:dontBroadcast)
{
	quieto = false;
	//infiniteammo = false;
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Zombies", false))
	{
		//infiniteammo = true;
		return;
	}
	
	quieto = true;
}


public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Zombies", false))
	{
		return;
	}
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	JB_SetSpecial(client, true);
	if(GetClientTeam(client) == CS_TEAM_CT && IsPlayerAlive(client))
	{	
		Zombie(client);
		if(quieto) 
		{
			//PrintToChat(client, "congelao");
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
		}
	}
	else SetEntityHealth(client, 65);
}

Vamos()
{
	for (new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_CT) SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.2);
		
	quieto = false;
	ServerCommand("sm_fogon");
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(victim) || attacker == victim || !IsValidClient(attacker)) return Plugin_Continue;
	
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Zombies", false))
	{
		return Plugin_Continue;
	}
	
	if(quieto) return Plugin_Handled;
	
	return Plugin_Continue;
}

public Action:OnWeaponCanUse(client, weapon)
{
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Zombies", false) || GetClientTeam(client) == CS_TEAM_T)
	{
		return Plugin_Continue;
	}

	decl String:sClassname[32];
	GetEdictClassname(weapon, sClassname, sizeof(sClassname));
	if (!StrEqual(sClassname, "weapon_knife"))
		return Plugin_Handled;
		
		
	return Plugin_Continue;
}

public OnMapStart()
{
	AddFileToDownloadsTable("materials/models/player/kuristaja/zombies/gozombie/csgo_zombie_skin.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/zombies/gozombie/csgo_zombie_normal.");
	AddFileToDownloadsTable("models/player/kuristaja/zombies/gozombie/gozombie.dx90.vtx");
	AddFileToDownloadsTable("models/player/kuristaja/zombies/gozombie/gozombie.mdl");
	AddFileToDownloadsTable("models/player/kuristaja/zombies/gozombie/gozombie.phy");
	AddFileToDownloadsTable("models/player/kuristaja/zombies/gozombie/gozombie.vvd");
	
	PrecacheModel("models/player/kuristaja/zombies/gozombie/gozombie.mdl");
}

Zombie(client)
{
	JB_SetSpecial(client, true);
	SetEntityHealth(client, 10000);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.4);
	CreateTimer(2.0, tiempos, client);
}

public Action:tiempos(Handle:timer, any:client)
{
	if(!IsClientInGame(client)) return;

	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Zombies", false))
	{
		return;
	}
	if(GetClientTeam(client) == CS_TEAM_CT && IsPlayerAlive(client))
	{	
		SetEntityModel(client, "models/player/kuristaja/zombies/gozombie/gozombie.mdl");
	}
}

public Action:OnPlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Zombies", false))
	{
		return;
	}
	
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (!IsValidClient(attacker) || GetClientTeam(client) == CS_TEAM_T)
		return;


	new damage = GetEventInt(event, "dmg_health");

	new Float:knockback = 8.0; // knockback amount

 	new Float:clientloc[3];
   	new Float:attackerloc[3];
    
    	GetClientAbsOrigin(client, clientloc);
    
        // Get attackers eye position.
        GetClientEyePosition(attacker, attackerloc);
        
        // Get attackers eye angles.
        new Float:attackerang[3];
        GetClientEyeAngles(attacker, attackerang);
        
        // Calculate knockback end-vector.
        TR_TraceRayFilter(attackerloc, attackerang, MASK_ALL, RayType_Infinite, KnockbackTRFilter);
        TR_GetEndPosition(clientloc);
    
    
    	// Apply damage knockback multiplier.
    	knockback *= damage;
		
        if(GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") == -1) knockback *= 0.5;
    
    	// Apply knockback.
    	KnockbackSetVelocity(client, attackerloc, clientloc, knockback);
}

KnockbackSetVelocity(client, const Float:startpoint[3], const Float:endpoint[3], Float:magnitude)
{
    // Create vector from the given starting and ending points.
    new Float:vector[3];
    MakeVectorFromPoints(startpoint, endpoint, vector);
    
    // Normalize the vector (equal magnitude at varying distances).
    NormalizeVector(vector, vector);
    
    // Apply the magnitude by scaling the vector (multiplying each of its components).
    ScaleVector(vector, magnitude);
    

    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vector);
}

public bool:KnockbackTRFilter(entity, contentsMask)
{
    // If entity is a player, continue tracing.
    if (entity > 0 && entity < MAXPLAYERS)
    {
        return false;
    }
    
    // Allow hit.
    return true;
}


public IsValidClient( client ) 
{ 
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
        return false; 
     
    return true; 
}
