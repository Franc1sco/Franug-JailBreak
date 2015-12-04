#include <sourcemod>
#include <sdktools>
#include <franug_jb>
#include <cstrike>
#include <sdkhooks>

new gallina[MAXPLAYERS+1];

new bool:quieto;
new tiempo;
new Handle:eltimer = INVALID_HANDLE;

new Handle:eltimer2 = INVALID_HANDLE;

new g_BeamSprite = -1;
new g_HaloSprite = -1;

public OnPluginStart()
{
	for(new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)) OnClientPutInServer(i);
		
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("round_prestart", roundStart2);
	HookEvent("round_start", Event_RoundStart);
	
	HookEvent("player_death", Event_PlayerDeath);
}

public OnMapStart()
{
	g_BeamSprite = PrecacheModel("materials/sprites/bomb_planted_ring.vmt");
	g_HaloSprite = PrecacheModel("materials/sprites/halo.vtf");
}


public Action:roundStart2(Handle:event, const String:name[], bool:dontBroadcast)
{
	for (new client = 1; client <= MaxClients; client++)
		if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == CS_TEAM_CT)
		{
			if(gallina[client] != 0)
			{
				new gallina2 = EntRefToEntIndex(gallina[client]);
				if(gallina2 != -1 && IsValidEntity(gallina2)) 
				{
					SDKUnhook(gallina2, SDKHook_SetTransmit, ShouldHide);
					AcceptEntityInput(gallina2, "Kill");
				}
				gallina[client] = 0;
			}
		}
	
	if (eltimer2 != INVALID_HANDLE)
		KillTimer(eltimer2);
		
	eltimer2 = INVALID_HANDLE;
	quieto = false;
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Hide and seek", false))
	{
		return;
	}
	
	quieto = true;
}


public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (eltimer != INVALID_HANDLE)
		KillTimer(eltimer);
		
	eltimer = INVALID_HANDLE;
	
	if (eltimer2 != INVALID_HANDLE)
		KillTimer(eltimer2);
		
	eltimer2 = INVALID_HANDLE;
	
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Hide and seek", false))
	{
		return;
	}
	
	tiempo = 60;
	eltimer = CreateTimer(1.0, contador, _, TIMER_REPEAT);
	
	eltimer2 = CreateTimer(1.0, contador2, _, TIMER_REPEAT);
}

public Action:contador(Handle:timer, Handle:pack)
{
	--tiempo;
	if(tiempo < 1)
	{
		Vamos();
		PrintToChatAll(" \x04[Franug-JailBreak] \x05Guards can go now to Ts!");
		
		if (eltimer != INVALID_HANDLE)
			KillTimer(eltimer);
		
		eltimer = INVALID_HANDLE;
	}
	else if(tiempo == 58) PrintToChatAll(" \x04[Franug-JailBreak] \x05In Hide and seek round the guards will go in 60 seconds!");
	else if(tiempo <= 10 || tiempo == 30 || tiempo == 40) PrintToChatAll(" \x04[Franug-JailBreak] \x05Still %i seconds for start the round!", tiempo);
}

public Action:contador2(Handle:timer)
{
	for (new client = 1; client <= MaxClients; client++)
		if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == CS_TEAM_CT)
		{
			if(gallina[client] != 0)
			{
				new gallina2 = EntRefToEntIndex(gallina[client]);
				if(gallina2 != -1 && IsValidEntity(gallina2)) 
				{
					SDKUnhook(gallina2, SDKHook_SetTransmit, ShouldHide);
					AcceptEntityInput(gallina2, "Kill");
				}
				gallina[client] = 0;
			}
			decl Float:Position2[3]; 
			GetClientAbsOrigin(client, Position2);
			Position2[0] += 10.0;
			new clients[MaxClients];
			new index = 0;
			for(new i2 = 1; i2 <=MaxClients; ++i2)
				if(IsClientInGame(i2) && GetClientTeam(i2) != CS_TEAM_CT)
				{
					clients[index] = i2;
					index++;
				}
			TE_SetupBeamRingPoint(Position2, 10.0, 190.0, g_BeamSprite, g_HaloSprite, 0, 15, 1.0, 5.0, 0.0, {0, 0, 255, 255}, 10, 0);
			TE_Send(clients, index);
			//TE_SendToAll();
			
			Position2[0] += 20.0;
			new chickent = CreateEntityByName("chicken");
			if(chickent == -1) return;
			DispatchSpawn(chickent);
    
			TeleportEntity(chickent, Position2, NULL_VECTOR, NULL_VECTOR);
			Entity_SetParent(chickent, client);
			//SetEntityMoveType(chickent, MOVETYPE_NONE);
			//Entity_Freeze(chickent);
			SetEntProp(chickent, Prop_Data, "m_takedamage", 0, 1);
			//SetEntData(chickent, g_offsCollisionGroup, 2, 4, true);
			SetEntProp(chickent, Prop_Send, "m_bShouldGlow", true, true);
			SetEntPropFloat(chickent, Prop_Send, "m_flModelScale", 5.0);
			SDKHook(chickent, SDKHook_SetTransmit, ShouldHide);
			gallina[client] = EntIndexToEntRef(chickent);
	
		}
}

public OnClientDisconnect(client)
{
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Hide and seek", false))
	{
		return;
	}
	if(gallina[client] != 0)
	{
		new gallina2 = EntRefToEntIndex(gallina[client]);
		if(gallina2 != -1 && IsValidEntity(gallina2)) 
		{
			SDKUnhook(gallina2, SDKHook_SetTransmit, ShouldHide);
			AcceptEntityInput(gallina2, "Kill");
		}
		gallina[client] = 0;
	}
}


public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Hide and seek", false))
	{
		return;
	}
	
	JB_SetSpecial(client, true);
	
	if(GetClientTeam(client) == CS_TEAM_T && !quieto) SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.2);
	else if(GetClientTeam(client) == CS_TEAM_CT && quieto) SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
}

Vamos()
{
	for (new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && IsPlayerAlive(i))
		{
			if(GetClientTeam(i) == CS_TEAM_CT) SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.2);
			else SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0.2);
		}
		
	quieto = false;
	ServerCommand("sm_fogon");
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);	
	gallina[client] = 0;
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public Action:OnWeaponCanUse(client, weapon)
{
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Hide and seek", false))
	{
		return Plugin_Continue;
	}

	decl String:sClassname[32];
	GetEdictClassname(weapon, sClassname, sizeof(sClassname));
	if (!StrEqual(sClassname, "weapon_knife"))
		return Plugin_Handled;
		
		
	return Plugin_Continue;
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(victim) || attacker == victim || !IsValidClient(attacker)) return Plugin_Continue;
	
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Hide and seek", false))
	{
		return Plugin_Continue;
	}
	
	if(GetClientTeam(victim) == CS_TEAM_CT && GetClientTeam(attacker) == CS_TEAM_T)
	{
		return Plugin_Handled;
	}

	
	return Plugin_Continue;
}

public Action:ShouldHide(ent, client)
{
	if(ent == gallina[client] || GetClientTeam(client) == CS_TEAM_CT)
		return Plugin_Handled;
	
	return Plugin_Continue;
}

stock Entity_SetParent(entity, parent)
{
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", parent);
}

public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(gallina[client] != 0)
	{
		new gallina2 = EntRefToEntIndex(gallina[client]);
		if(gallina2 != -1 && IsValidEntity(gallina2)) 
		{
			SDKUnhook(gallina2, SDKHook_SetTransmit, ShouldHide);
			AcceptEntityInput(gallina2, "Kill");
		}
		gallina[client] = 0;
	}
}

public IsValidClient( client ) 
{ 
	if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
	return false; 
	
	return true; 

}