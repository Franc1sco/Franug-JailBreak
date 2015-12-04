#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <lastrequest>
#include <cstrike>

public OnAvailableLR(Announced)
{
	SetCvar("mp_teammates_are_enemies", 0);
	for(new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T) FakeClientCommand(i, "sm_lr");
}

public SetCvar(String:cvarName[64], value)
{
	new Handle:cvar;
	cvar = FindConVar(cvarName);

	new flags = GetConVarFlags(cvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);

	SetConVarInt(cvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);
}