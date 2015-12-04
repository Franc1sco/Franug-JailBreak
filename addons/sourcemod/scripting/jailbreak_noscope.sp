#include <sourcemod>
#include <sdktools>
#include <franug_jb>
#include <cstrike>
#include <sdkhooks>

new m_flNextSecondaryAttack;

new Handle:eltimer = INVALID_HANDLE;
new Handle:tiemporonda;

public OnPluginStart()
{
	tiemporonda = FindConVar("mp_roundtime");
	HookEvent("player_spawn", Event_PlayerSpawn);
	
	HookEvent("round_prestart", roundStart2);
	HookEvent("round_start", Event_RoundStart);
	
	RegConsoleCmd("drop", Soltar);
	
	m_flNextSecondaryAttack = FindSendPropOffs("CBaseCombatWeapon", "m_flNextSecondaryAttack");
}

public Action:roundStart2(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "No Scope", false))
	{
		return;
	}
	
	for(new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)) SDKHook(i, SDKHook_PreThink, OnPreThink);
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (eltimer != INVALID_HANDLE)
		KillTimer(eltimer);
		
	eltimer = INVALID_HANDLE;
	
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "No Scope", false))
	{
		return;
	}
	
	eltimer = CreateTimer(((60.0*GetConVarFloat(tiemporonda)) - 60.0), atras);
}

public Action:atras(Handle:timer, Handle:pack)
{
	eltimer = INVALID_HANDLE;
	
	PrintToChatAll(" \x04[Franug-JailBreak] \x05No CTs can be killed!");
}

public Action:Soltar(client, args)
{
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "No Scope", false))
	{
		return Plugin_Continue;
	}
	
	return Plugin_Handled;
}


public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "No scope", false))
	{
		//SetEntityGravity(client, 1.0);
		return;
	}
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(GetClientTeam(client) == CS_TEAM_T)
	{
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.2);
		//SetEntityGravity(client, 0.65);
		
		//SetEntityMoveType(client, MOVETYPE_FLYGRAVITY);
	}
	else if(GetClientTeam(client) == CS_TEAM_CT)
	{
		CreateTimer(0.5, Dar, client);
	}
}

public Action:Dar(Handle:timer, any:client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == CS_TEAM_CT) GivePlayerItem(client, "weapon_awp");
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);	
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "No scope", false))
	{
		return;
	}
	
	SDKHook(client, SDKHook_PreThink, OnPreThink);
}

public Action:CS_OnTerminateRound(&Float:delay, &CSRoundEndReason:reason)
{
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "No scope", false))
	{
		return;
	}
	
	for(new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)) SDKUnhook(i, SDKHook_PreThink, OnPreThink);
}

public Action:OnPreThink(client)
{
	new iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	SetNoScope(iWeapon);
	return Plugin_Continue;
}

stock SetNoScope(weapon)
{
	if(IsValidEdict(weapon))
	{
		decl String:classname[MAX_NAME_LENGTH];

		if (GetEdictClassname(weapon, classname, sizeof(classname))
		|| StrEqual(classname[7], "ssg08")  || StrEqual(classname[7], "aug")
		|| StrEqual(classname[7], "sg550")  || StrEqual(classname[7], "sg552")
		|| StrEqual(classname[7], "sg556")  || StrEqual(classname[7], "awp")
		|| StrEqual(classname[7], "scar20") || StrEqual(classname[7], "g3sg1"))
		{
			SetEntDataFloat(weapon, m_flNextSecondaryAttack, GetGameTime() + 1.0);
		}
	}
}

public Action:OnWeaponCanUse(client, weapon)
{
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "No scope", false))
	{
		return Plugin_Continue;
	}

	decl String:sClassname[32];
	GetEdictClassname(weapon, sClassname, sizeof(sClassname));
	if (StrEqual(sClassname, "weapon_knife") || (GetClientTeam(client) == CS_TEAM_CT && StrEqual(sClassname, "weapon_awp")))
		return Plugin_Continue;
		
		
	return Plugin_Handled;
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(victim) || attacker == victim || !IsValidClient(attacker)) return Plugin_Continue;
	
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "No scope", false))
	{
		return Plugin_Continue;
	}
	
	if(GetClientTeam(victim) == CS_TEAM_CT && GetClientTeam(attacker) == CS_TEAM_T && eltimer != INVALID_HANDLE)
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public IsValidClient( client ) 
{ 
	if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
	return false; 
	
	return true; 

}