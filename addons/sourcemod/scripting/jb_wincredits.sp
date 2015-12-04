#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <franug_jb>
#include <cstrike>

public OnPluginStart()
{
	HookEvent("player_death", EventPlayerDeath);
	
	HookEvent("round_end", FinRonda);
	
	CreateTimer(60.0, ResetAmmo2, _, TIMER_REPEAT);
}

public Action:FinRonda(Handle:event, const String:name[], bool:dontBroadcast)
{
	new clients = 0;
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && GetClientTeam(client) > 1)
		{
			clients++;
		}
	}
	
	if(clients < 3) return;
	
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && GetClientTeam(client) > 1 && IsPlayerAlive(client))
		{
			JB_SetCredits(client, JB_GetCredits(client)+4);
		}
	}
}

public Action:EventPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{

	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (!attacker) return;
	if (attacker == client || GetClientTeam(attacker) == CS_TEAM_CT) return;
	
	JB_SetCredits(attacker, JB_GetCredits(attacker)+2);
	
}

public Action:ResetAmmo2(Handle:timer)
{
	new clients = 0;
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && GetClientTeam(client) > 1)
		{
			clients++;
		}
	}
	
	if(clients < 3) return;
	
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && GetClientTeam(client) > 1)
		{
			JB_SetCredits(client, JB_GetCredits(client)+1);
		}
	}
}
