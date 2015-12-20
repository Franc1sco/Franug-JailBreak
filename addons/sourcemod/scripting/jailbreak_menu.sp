
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <captain>
#include <lastrequest>
#include <franug_jb>

new Handle:cvar_ff;

public OnPluginStart()
{
	RegConsoleCmd("sm_menu", DOMenu);
	RegConsoleCmd("buyammo2", DOMenu);
	
	RegConsoleCmd("sm_simonmenu", DOsimon);
	
	cvar_ff = FindConVar("mp_teammates_are_enemies");
}

public Action:DOMenu(client,args)
{
	new Handle:menu = CreateMenu(DIDMenuHandler);
	SetMenuTitle(menu, "JailBreak cs 1.6 style by Franc1sco Franug");
	if(JC_GetCaptain() == client) 
	{
		AddMenuItem(menu, "days", "Choose Day");
		AddMenuItem(menu, "simonmenu", "Simon Menu");
	}
	else if(GetClientTeam(client) == CS_TEAM_CT) AddMenuItem(menu, "sersimon", "Be Simon");
/* 	if(GetClientTeam(client) == CS_TEAM_CT) AddMenuItem(menu, "tt", "Ser preso");
	else if(GetClientTeam(client) == CS_TEAM_T) AddMenuItem(menu, "ct", "Ser guardia (Micro requerido)"); */
	
	if(GetClientTeam(client) == CS_TEAM_CT) AddMenuItem(menu, "guns", "Choose weapons");
	//AddMenuItem(menu, "tienda", "Shop");
	
	AddMenuItem(menu, "hats", "Hats Menu");
	//AddMenuItem(menu, "normas", "Leer normas");
	//AddMenuItem(menu, "admin", "Menu de Administrador");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public DIDMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		new String:info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
/* 		if ( strcmp(info,"tt") == 0 ) 
		{
			ClientCommand(client, "jointeam %i", CS_TEAM_T);
			DOMenu(client,0);
		}
		else if ( strcmp(info,"ct") == 0 ) 
		{
			ClientCommand(client, "jointeam %i", CS_TEAM_CT);
			DOMenu(client,0);
		} */
		if ( strcmp(info,"guns") == 0 ) 
		{
			FakeClientCommand(client, "say !guns");
		}
		else if ( strcmp(info,"tienda") == 0 ) 
		{
			FakeClientCommand(client, "sm_awards");
		}
		else if ( strcmp(info,"days") == 0 ) 
		{
			FakeClientCommand(client, "sm_days");
		}
		else if ( strcmp(info,"hats") == 0 ) 
		{
			FakeClientCommand(client, "sm_hats");
		}
		else if ( strcmp(info,"normas") == 0 ) 
		{
			FakeClientCommand(client, "sm_rules");
			//DOMenu(client,0);
		}
		else if ( strcmp(info,"admin") == 0 ) 
		{
			FakeClientCommand(client, "sm_admin");
		}
		else if ( strcmp(info,"simonmenu") == 0 ) 
		{
			FakeClientCommand(client, "sm_simonmenu");
		}
		else if ( strcmp(info,"sersimon") == 0 ) 
		{
			DOMenu(client,0);
			FakeClientCommand(client, "sm_simon");

		}
		
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:DOsimon(client,args)
{
	new Handle:menu = CreateMenu(DIDMenuHandlerS);
	SetMenuTitle(menu, "Simon menu");
	
	AddMenuItem(menu, "abrir", "Open jail doors");
	AddMenuItem(menu, "cerrar", "Close jail doors");
	AddMenuItem(menu, "fdall", "Give FreeDay to all");
	AddMenuItem(menu, "fdone", "Give FreeDay to a player");
	AddMenuItem(menu, "kill", "Kill a random Ts");
	
	if(!GetConVarBool(cvar_ff)) AddMenuItem(menu, "ffa1", "Enable friendly fire to Ts");
	else AddMenuItem(menu, "ffa2", "Disable friendly fire to Ts");
	
	AddMenuItem(menu, "nosimon", "Leave Simon");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public DIDMenuHandlerS(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		if(JC_GetCaptain() != client) return;
		
		new String:info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if ( strcmp(info,"abrir") == 0 ) 
		{
			FakeClientCommand(client, "sm_open");
			DOsimon(client,0);
		}
 		else if ( strcmp(info,"cerrar") == 0 ) 
		{
			FakeClientCommand(client, "sm_close");
			DOsimon(client,0);
		} 
		else if ( strcmp(info,"fdall") == 0 ) 
		{
			FDTodos();
			PrintToChatAll(" \x04[Franug-JailBreak] \x05Simon given FreeDay to all!");
			DOsimon(client,0);
		}
		else if ( strcmp(info,"fdone") == 0 ) 
		{
			FDone(client);
		}
		else if ( strcmp(info,"ffa1") == 0 ) 
		{
			SetCvar("mp_teammates_are_enemies", 1);
			PrintToChatAll(" \x04[Franug-JailBreak] \x05Simon enabled the friendly fire to Ts!");
			
			DOsimon(client,0);
		}
		else if ( strcmp(info,"ffa2") == 0 ) 
		{
			SetCvar("mp_teammates_are_enemies", 0);
			PrintToChatAll(" \x04[Franug-JailBreak] \x05Simon Disabled the friendly fire to Ts!");
			
			DOsimon(client,0);
		}
		else if ( strcmp(info,"kill") == 0 ) 
		{
			new ale = GetRandomPlayer(CS_TEAM_T);
			if(ale > 0)
			{
				ForcePlayerSuicide(ale);
				PrintToChatAll(" \x04[Franug-JailBreak] \x05Simon killed randomly to %N", ale);
				
			}
			DOsimon(client,0);
		}
		else if ( strcmp(info,"nosimon") == 0 ) 
		{
			FakeClientCommand(client, "sm_nosimon");
			DOMenu(client,0);
		}
		
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
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

FDTodos()
{
	for (new i = 1; i < MaxClients; i++)
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T) 
			JB_GiveFD(i);
}

FDone(client)
{
	new Handle:menu = CreateMenu(DIDMenuHandlerFD);
	SetMenuTitle(menu, "Choose player to give FreeDay");
	
	decl String:temp2[8], String:temp[128];
	new cuenta = 0;
	for (new i = 1; i < MaxClients; i++)
	if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T && !JB_GetFD(i)) 
		{
			Format(temp, 128, "%N", i);
			Format(temp2, 8, "%i", i);
			AddMenuItem(menu, temp2, temp);
			
			cuenta++;
		}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	if(cuenta == 0)
	{
		PrintToChat(client, " \x04[Franug-JailBreak] \x05No players for give FreeDay");
		DOsimon(client,0);
	}
}

public DIDMenuHandlerFD(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		if(JC_GetCaptain() != client) return;
		
		new String:info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		new i = StringToInt(info);
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T) 
		{
			JB_GiveFD(i);
			PrintToChatAll(" \x04[Franug-JailBreak] \x05Simon Given FreeDay to %N", i);
			
			DOsimon(client,0);
		}
		else 
		{
			PrintToChat(client, " \x04[Franug-JailBreak] \x05Target invalid. Choose other player");
			FDone(client);
		}
		
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

GetRandomPlayer(team)
{
	new clients[MaxClients+1], clientCount;
	for (new i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && GetClientTeam(i) == team) clients[clientCount++] = i;
		
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}

