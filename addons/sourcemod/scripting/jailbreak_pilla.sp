#include <sourcemod>
#include <sdktools>
#include <franug_jb>
#include <cstrike>
#include <sdkhooks>


new bool:quieto;
new bool:cogido[MAXPLAYERS+1];
new tiempo;
new Handle:eltimer = INVALID_HANDLE;


public OnPluginStart()
{
	for(new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)) OnClientPutInServer(i);
		
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("round_prestart", roundStart2);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_team", EventPlayerTeam);
	HookEvent("player_death", EventPlayerTeam);
}


public Action:roundStart2(Handle:event, const String:name[], bool:dontBroadcast)
{
	quieto = false;
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Freeze tag", false))
	{
		return;
	}
	
	quieto = true;
}

public Action:EventPlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Freeze tag", false))
	{
		return;
	}
	Comprobar();
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (eltimer != INVALID_HANDLE)
		KillTimer(eltimer);
		
	eltimer = INVALID_HANDLE;
	
	
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Freeze tag", false))
	{
		return;
	}
	
	tiempo = 30;
	eltimer = CreateTimer(1.0, contador, _, TIMER_REPEAT);
	
}

public Action:contador(Handle:timer, Handle:pack)
{
	--tiempo;
	if(tiempo < 1)
	{
		Vamos();
		PrintToChatAll(" \x04[Franug-JailBreak] \x05The freeze tag started!");
		
		if (eltimer != INVALID_HANDLE)
			KillTimer(eltimer);
		
		eltimer = INVALID_HANDLE;
	}
	else if(tiempo == 28) PrintToChatAll(" \x04[Franug-JailBreak] \x05In Freeze tag day, guards will go to Ts in 30 seconds!");
	else if(tiempo <= 10) PrintToChatAll(" \x04[Franug-JailBreak] \x05Still %i to start the round!", tiempo);
}


public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Freeze tag", false))
	{
		return;
	}
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	JB_SetSpecial(client, true);
	cogido[client] = false;
	
	if(GetClientTeam(client) == CS_TEAM_CT && quieto) SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
}

Vamos()
{
	for (new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_CT) SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.2);
		
	quieto = false;
	//ServerCommand("sm_fogon");
}

public OnClientPutInServer(client)
{
	cogido[client] = false;
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);	
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public Action:OnWeaponCanUse(client, weapon)
{
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Freeze tag", false))
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
	if(!StrEqual(ronda, "Freeze tag", false))
	{
		return Plugin_Continue;
	}
	
	if(GetClientTeam(victim) == CS_TEAM_T && GetClientTeam(attacker) == CS_TEAM_CT && !cogido[victim])
	{
		Coger(victim, attacker);
		Comprobar();
	}
	else if(GetClientTeam(victim) == CS_TEAM_T && GetClientTeam(attacker) == CS_TEAM_T && cogido[victim] && !cogido[attacker])
	{
		DesCoger(victim, attacker);
	}

	
	return Plugin_Handled;
}

public IsValidClient( client ) 
{ 
	if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
	return false; 
	
	return true; 

}

public OnClientDisconnect_Post(client)
{
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Freeze tag", false))
	{
		return;
	}
	Comprobar();
}

Coger(client, attacker)
{
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
	SetEntityRenderColor(client, 0, 0, 255, 255);
	cogido[client] = true;
	
	PrintToChatAll(" \x04[Franug-JailBreak] \x05Guard %N caught to %N", attacker, client);
}

DesCoger(client, attacker)
{
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	SetEntityRenderColor(client, 255, 255, 255, 0);
	cogido[client] = false;
	
	PrintToChatAll(" \x04[Franug-JailBreak] \x05Ts %N saved to %N", attacker, client);
}

Comprobar()
{
	new numero = 0;
	for (new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T && !cogido[i]) numero++;
		
	if(numero == 0) CS_TerminateRound(5.0, CSRoundEnd_CTWin);
}