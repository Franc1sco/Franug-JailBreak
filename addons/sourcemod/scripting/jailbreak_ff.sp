#include <sourcemod>
#include <sdktools>
#include <cstrike>

new Handle:cvar;
	
public OnPluginStart()
{
	//RegConsoleCmd("mp_friendlyfire", block);
	cvar = FindConVar("mp_friendlyfire");

	new flags = GetConVarFlags(cvar);
	if(flags & FCVAR_NOTIFY)
	{
		flags &= ~FCVAR_NOTIFY;
		SetConVarFlags(cvar, flags);
	}

	HookConVarChange(cvar, CVarChange);
}

public CVarChange(Handle:convar, const String:oldValue[], const String:newValue[]) {

	new valor = StringToInt(newValue);
	
	if(valor == 1) SetConVarInt(convar, 0);
}

