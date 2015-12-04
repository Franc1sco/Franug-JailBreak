#include <sourcemod>
#include <sdktools>
#include <basecomm>
#include <cstrike>
#include <franug_jb>


#pragma semicolon 1


#define DATA "4.4"


new commander;


public Plugin:myinfo =
{
	name = "SM Franug Simon",
	author = "Franc1sco Steam: franug",
	description = "Be a Simon for jail",
	version = DATA,
	url = "www.uea-clan.com"
};

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
    CreateNative("JC_GetCaptain", Native_Obtener);
    
    return APLRes_Success;
}

public Native_Obtener(Handle:plugin, argc)
{    
    	return commander;
}

public OnPluginStart()
{

	LoadTranslations ("captain.phrases");

	CreateConVar("sm_FranugSimon_version", DATA, "version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	RegAdminCmd("sm_removesimon", command_removecaptain, ADMFLAG_GENERIC);
        RegConsoleCmd("sm_simon", Co);
        RegConsoleCmd("sm_c", Co);
        RegConsoleCmd("sm_nosimon", unCo);
        RegConsoleCmd("sm_noc", unCo);

	HookEvent("round_start", roundStart);
	HookEvent("player_death", playerDeath);
	HookEvent("player_disconnect", playerDisconnect);


}

public Action:command_removecaptain(client, args)
{
	if(IsValidClient(commander))
	{
		PrintToChatAll(" \x04[Jail_Simon] \x03%t", "Captain has been removed by an administrator. You can now choose a new one");
		commander = -1;
		return Plugin_Handled;
	}

	PrintToChat(client, " \x04[Jail_Simon] \x03%t", "Captain still not exist!");

	return Plugin_Handled;
}

public Action:Co(client,args)
{
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Simon", false))
	{
		PrintToChat(client, " \x04[Jail_Simon] \x03Only simon is allowed the simon day!");
		return Plugin_Handled;
	}
	
	
	if(!client)
		return Plugin_Handled;

	if(!IsValidClient(commander))
	{
		if(IsValidClient(client) && GetClientTeam(client) == 3 && IsPlayerAlive(client))
		{
           		//SetEntityRenderColor(client, 255, 150, 0, 255);
				commander = client;
				
				FakeClientCommand(client, "sm_simonmenu");
		}
		else
		{
			PrintToChat(client, " \x04[Jail_Simon] \x03%t", "You must be alive or be a CT for be a captain!");
		}
	}
	else
	{
		PrintToChat(client, " \x04[Jail_Simon] \x03%t", "Captain already exist!");
	}

	return Plugin_Handled;
}

public Action:unCo(client,args)
{
    if(commander == client)
    {
           DesNombradoC(client);
           //SetEntityRenderColor(client, 255, 255, 255, 255);
           commander = -1;
    }
    else
    {
       PrintToChat(client, " \x04[Jail_Simon] \x03%t", "You are not the captain!");
    }
}

public Action:roundStart(Handle:event, const String:name[], bool:dontBroadcast) 
{
	commander = -1;
	
	decl String:ronda[64];
	JB_GetRound(ronda);
	if(!StrEqual(ronda, "Simon", false))
	{
		return;
	}
	
	new client = GetRandomPlayer(CS_TEAM_CT);
	if(client > 0)
	{
		
		commander = client;
		
		FakeClientCommand(client, "sm_simonmenu");
	}
	
}

GetRandomPlayer(team)
{
	new clients[MaxClients+1], clientCount;
	for (new i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && GetClientTeam(i) == team) clients[clientCount++] = i;
		
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}



public Action:playerDisconnect(Handle:event, const String:name[], bool:dontBroadcast) 
{
        new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(client == commander)
        {
	   DesNombradoC(client);
	   commander = -1;
        }
}

public Action:playerDeath(Handle:event, const String:name[], bool:dontBroadcast) 
{
        new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(client == commander)
        {
	   DesNombradoC(client);
	   commander = -1;
        }
}

DesNombradoC(client)
{
	decl String:nombre[32];
	GetClientName(client, nombre, sizeof(nombre));
	PrintToChatAll(" \x04[Jail_Simon] \x03%t", "no longer", nombre);
}






public IsValidClient( client ) 
{ 
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
        return false; 
     
    return true; 
}