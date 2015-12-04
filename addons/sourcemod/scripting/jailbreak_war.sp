#include <sourcemod>
#include <sdktools>
#include <franug_jb>
#include <cstrike>
#include <sdkhooks>

new bool:quieto;
new tiempo;
new Handle:eltimer = INVALID_HANDLE;


public OnPluginStart()
{
	
	HookEvent("round_prestart", roundStart2);
	HookEvent("round_start", Event_RoundStart);
	
	HookEvent("player_spawn", Event_PlayerSpawn);
	
	for(new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)) OnClientPutInServer(i);
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "War", false))
	{
		return;
	}
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(GetClientTeam(client) == CS_TEAM_T && quieto) SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (eltimer != INVALID_HANDLE)
		KillTimer(eltimer);
		
	eltimer = INVALID_HANDLE;
	
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "War", false))
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
		PrintToChatAll(" \x04[Franug-JailBreak] \x05The war started!");
		
		if (eltimer != INVALID_HANDLE)
			KillTimer(eltimer);
		
		eltimer = INVALID_HANDLE;
	}
	else if(tiempo == 28) PrintToChatAll(" \x04[Franug-JailBreak] \x05The round War will start in 30 seconds!");
	else if(tiempo <= 10) PrintToChatAll(" \x04[Franug-JailBreak] \x05Still %i seconds to start the war!", tiempo);
}

public Action:roundStart2(Handle:event, const String:name[], bool:dontBroadcast)
{
	quieto = false;
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "War", false))
	{
		return;
	}
	
	quieto = true;
}

Vamos()
{
	for (new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T) SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
		
	quieto = false;
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(victim) || attacker == victim || !IsValidClient(attacker)) return Plugin_Continue;
	
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "War", false))
	{
		return Plugin_Continue;
	}
	
	if(quieto) return Plugin_Handled;
	
	return Plugin_Continue;
}

public IsValidClient( client ) 
{ 
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
        return false; 
     
    return true; 
}
