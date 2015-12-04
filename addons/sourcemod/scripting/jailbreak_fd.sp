#include <sourcemod>
#include <sdktools>
#include <franug_jb>
#include <cstrike>
#include <sdkhooks>

public OnPluginStart()
{
	HookEvent("player_spawn", Event_PlayerSpawn);
}


public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "FreeDay", false))
	{
		return;
	}
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(GetClientTeam(client) == CS_TEAM_T && IsPlayerAlive(client)) JB_GiveFD(client);
}
