#include <sourcemod>
#include <sdktools>
#include <franug_jb>
#include <cstrike>
#include <captain>

new rondas;
new bool:elegido;
new suerte;

new Handle:cvar;

public OnPluginStart()
{
	HookEvent("round_prestart", roundStart2, EventHookMode_Pre);
	
	RegConsoleCmd("sm_days", Rondas);
	
}

public Action:Rondas(client, args)
{
	if(JC_GetCaptain() !=  client) return;
	
	new Handle:menu = CreateMenu(DIDMenuHandler);
	SetMenuTitle(menu, "Jail Days");
	AddMenuItem(menu, "1", "FreeDay");
	AddMenuItem(menu, "2", "Freeze tag");
	AddMenuItem(menu, "3", "Zombies");
	AddMenuItem(menu, "4", "Hide and seek");
	AddMenuItem(menu, "5", "War");
	AddMenuItem(menu, "6", "War all vs all");
	AddMenuItem(menu, "7", "No scope");
	//AddMenuItem(menu, "8", "Simon");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public DIDMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		new String:info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		suerte = StringToInt(info);
		elegido = true;
		CS_TerminateRound(1.0, CSRoundEnd_GameStart);
		
		PrintToChat(client, "day selected");
		
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public OnMapStart()
{
	rondas = 0;
}

public Action:roundStart2(Handle:event, const String:name[], bool:dontBroadcast) 
{
	
	rondas++;
	//SetCvar("sm_jb_doorsopenertime", 50);
	SetCvar("sm_hosties_lr", 1);
	SetCvar("mp_teammates_are_enemies", 0);
	SetCvar("sm_afk_enable", 1);
	SetCvar("sm_noblock", 0);
	SetCvar("sv_gravity", 800);
	SetCvar("sm_anticamp_enable", 0);
	SetCvar("sv_airaccelerate", 12);                            
	SetCvarF("sv_accelerate", 5.5);
	SetCvar("sm_shortsprint_enable", 0);
	
	ServerCommand("sm_fogoff");

	if(elegido)
	{
		elegido = false;
	}
	else
	{
		JB_ChooseRound("Simon");
		Tiempo(6);
		return;
	}
	
	if(suerte == 1)
	{
		JB_ChooseRound("FreeDay");
		Tiempo(2);
		SetCvar("sm_jb_doorsopenertime", 1);
		FDTodos();
		
	}
	else if(suerte == 2)
	{
		JB_ChooseRound("Freeze tag");
		Tiempo(4);
		SetCvar("sm_jb_doorsopenertime", 1);
		SetCvar("sm_hosties_lr", 0);
		//SetCvar("mp_teammates_are_enemies", 1);
		SetCvar("sm_afk_enable", 0);
		SetCvar("sm_noblock", 1);
		SetCvar("sm_anticamp_enable", 1);
		SetCvar("sm_shortsprint_enable", 1);
	}
	else if(suerte == 3)
	{
		JB_ChooseRound("Zombies");
		Tiempo(4);
		SetCvar("sm_jb_doorsopenertime", 1);
		//ServerCommand("sm_fogon");
		SetCvar("sm_hosties_lr", 0);
	}
	else if(suerte == 4)
	{
		JB_ChooseRound("Hide and seek");
		Tiempo(4);
		SetCvar("sm_jb_doorsopenertime", 1);
		//ServerCommand("sm_fogon");
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_afk_enable", 0);
		SetCvar("sm_noblock", 0);
	}
	else if(suerte == 5)
	{
		JB_ChooseRound("War");
		Tiempo(4);
		SetCvar("sm_jb_doorsopenertime", 1);
		//ServerCommand("sm_fogon");
		SetCvar("sm_hosties_lr", 0);
	}
	else if(suerte == 6)
	{
		JB_ChooseRound("War All VS All");
		Tiempo(4);
		SetCvar("sm_jb_doorsopenertime", 1);
		//ServerCommand("sm_fogon");
		SetCvar("mp_teammates_are_enemies", 1);
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_anticamp_enable", 1);
	}
	else if(suerte == 7)
	{
		JB_ChooseRound("No scope");
		Tiempo(3);
		SetCvar("sm_jb_doorsopenertime", 1);
		//ServerCommand("sm_fogon");
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sv_gravity", 180);
		SetCvar("sm_anticamp_enable", 1);
		SetCvar("sv_airaccelerate", 9999);                            
		SetCvarF("sv_accelerate", 9999.0);
	}
	else
	{
		JB_ChooseRound("Simon");
		Tiempo(6);
	}
}

FDTodos()
{
	for (new i = 1; i < MaxClients; i++)
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T) 
			JB_GiveFD(i);
}

Tiempo(eltiempo)
{
	SetCvar("mp_roundtime", eltiempo);
	SetCvar("mp_roundtime_hostage", eltiempo);
	SetCvar("mp_roundtime_defuse", eltiempo);
}

public SetCvar(String:cvarName[64], value)
{
	cvar = FindConVar(cvarName);
	if(cvar == INVALID_HANDLE) return;
	
	new flags = GetConVarFlags(cvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);

	SetConVarInt(cvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);
}

public SetCvarF(String:cvarName[64], Float:value)
{
	cvar = FindConVar(cvarName);
	if(cvar == INVALID_HANDLE) return;

	new flags = GetConVarFlags(cvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);

	SetConVarFloat(cvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);
}