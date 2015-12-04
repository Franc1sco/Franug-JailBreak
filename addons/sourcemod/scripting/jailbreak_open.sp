#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <captain> 
#include <cstrike>
#include <smartjaildoors>

new tiempo;

new Handle:eltimer = INVALID_HANDLE;
new Handle:Cvar_Tiempo = INVALID_HANDLE;

public Plugin:myinfo =
{
	name = "SM Doors Opener",
	author = "Franc1sco steam: franug",
	description = ".",
	version = "2.0",
	url = "http://www.clanuea.com/"
};

public OnPluginStart()
{
	RegConsoleCmd("sm_open", AbrirS);
	//RegConsoleCmd("sm_close", CerrarS);
	RegConsoleCmd("sm_close", CerrarS);
	//RegConsoleCmd("sm_cerrar", CerrarS);
	HookEvent("round_start", Event_RoundStart);
	Cvar_Tiempo = CreateConVar("sm_jb_doorsopenertime", "50", "Time in seconds for open doors on round start when CTs only have bots");
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (eltimer != INVALID_HANDLE)
		KillTimer(eltimer);
		
	eltimer = INVALID_HANDLE;
	
	
	tiempo = GetConVarInt(Cvar_Tiempo);
	eltimer = CreateTimer(1.0, contador, _, TIMER_REPEAT);
}

public Action:contador(Handle:timer, Handle:pack)
{
	--tiempo;
	if(tiempo < 1)
	{
		Abrir();
		PrintToChatAll(" \x04[Franug-JailBreak] \x05Jail button pressed automatically!");
		
		if (eltimer != INVALID_HANDLE)
			KillTimer(eltimer);
		
		eltimer = INVALID_HANDLE;
	}
}

Abrir()
{
	SJD_OpenDoors(); 
}

public Action:AbrirS(client, args) 
{ 
    new capitan = JC_GetCaptain(); // get captain 

    if(client == capitan) 
	{
		PrintToChatAll(" \x04[Franug-JailBreak] \x05Simon opened the jails doors"); 
		SJD_OpenDoors(); 
	}
    else 
            PrintToChat(client, " \x04[Franug-JailBreak] \x05Need to be simon"); 
}  

public Action:CerrarS(client, args) 
{ 
    new capitan = JC_GetCaptain(); // get captain 

    if(client == capitan) 
	{
		PrintToChatAll(" \x04[Franug-JailBreak] \x05Simon closed the jail doors"); 
		SJD_CloseDoors();
	}
    else 
            PrintToChat(client, " \x04[Franug-JailBreak] \x05Need to be simon"); 
}  
