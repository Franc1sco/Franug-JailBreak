
#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <franug_jb>
#include <scp>
#include <clientprefs>

#define STRING(%1) %1, sizeof(%1)

new Handle:array_premios;
new Handle:array_rondas;
new Handle:EnPremioComprado;

new g_creditos[MAXPLAYERS+1];
new bool:special[MAXPLAYERS+1];
new bool:FD[MAXPLAYERS+1];

new Handle:menus[MAXPLAYERS+1];

new String:RondaActual[128] = "none";

new Handle:c_GameCredits = INVALID_HANDLE;

enum Premios
{
	String:Nombre[64],
	precio,
	quien
}
#define VERSION "v1.0"

//new String:g_sFilePath[PLATFORM_MAX_PATH];

public Plugin:myinfo =
{
	name = "SM Franug JailBreak",
	author = "Franc1sco steam: franug",
	description = "",
	version = VERSION,
	url = "http://steamcommunity.com/id/franug"
};


public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("JB_AddAward", Native_AgregarPremio);
	CreateNative("JB_RemoveAward", Native_BorrarPremio);
	CreateNative("JB_ChooseRound", Native_ElegirRonda);
	CreateNative("JB_GetRound", Native_ObtenerRonda);
	CreateNative("JB_SetSpecial", Native_FijarEspecial);
	CreateNative("JB_GiveFD", Native_DarFD);
	CreateNative("JB_GetSpecial", Native_ObtenerEspecial);
	CreateNative("JB_GetFD", Native_ObtenerFD);
	CreateNative("JB_SetCredits", Native_FijarCreditos);
	CreateNative("JB_GetCredits", Native_ObtenerCreditos);
	CreateNative("JB_LoadTranslations", Native_Lengua);
	EnPremioComprado = CreateGlobalForward("JB_OnAwardBought", ET_Ignore, Param_Cell, Param_String);
    
	return APLRes_Success;
}

public Native_AgregarPremio(Handle:plugin, argc)
{  
	new Items[Premios];
	GetNativeString(1, Items[Nombre], 64);
	Items[precio] = GetNativeCell(2);
	Items[quien] = GetNativeCell(3);
	
	PushArrayArray(array_premios, Items[0]);
	
	RenewMenus();
}

public Native_BorrarPremio(Handle:plugin, argc)
{  
	decl String:buscado[64];
	GetNativeString(1, buscado, 64);
	
	new Items[Premios];
	for(new i=0;i<GetArraySize(array_premios);++i)
	{
		GetArrayArray(array_premios, i, Items[0]);
		if(StrEqual(Items[Nombre], buscado))
		{
			RemoveFromArray(array_premios, i);
			break;
		}
	}
	RenewMenus();
}


public Native_ElegirRonda(Handle:plugin, argc)
{  
	decl String:buscado[64];
	GetNativeString(1, buscado, 64);
	
	Format(RondaActual, sizeof(RondaActual), buscado);
	
}

public Native_FijarEspecial(Handle:plugin, argc)
{  
	special[GetNativeCell(1)] = GetNativeCell(2);
}

public Native_DarFD(Handle:plugin, argc)
{  
	new client = GetNativeCell(1);
	FD[client] = true;
	
	SetEntityRenderColor(client, 0, 255, 0, 255);
}

public Native_ObtenerFD(Handle:plugin, argc)
{  
	return FD[GetNativeCell(1)];
}

public Native_ObtenerEspecial(Handle:plugin, argc)
{  
	return special[GetNativeCell(1)];
}

public Native_ObtenerCreditos(Handle:plugin, argc)
{  
	return g_creditos[GetNativeCell(1)];
}

public Native_ObtenerRonda(Handle:plugin, argc)
{  
   SetNativeString(1, RondaActual, sizeof(RondaActual));
   
   if(StrEqual(RondaActual, "none", false)) return false;
   else return true;
}

public Native_FijarCreditos(Handle:plugin, argc)
{  
	g_creditos[GetNativeCell(1)] = GetNativeCell(2);
}

public Native_Lengua(Handle:plugin, argc)
{  
	decl String:buscado[64];
	GetNativeString(1, buscado, 64);
	
	LoadTranslations(buscado);
}

public OnPluginStart()
{
	//BuildPath(Path_SM, g_sFilePath, sizeof(g_sFilePath), "logs/prueba.log");
	
	c_GameCredits = RegClientCookie("FranugCredits", "FranugCredits", CookieAccess_Private);
	
	LoadTranslations ("franug_jailbreak.phrases");
	array_premios = CreateArray(66);
	array_rondas = CreateArray(65);
	
	RegConsoleCmd("sm_awards", DOMenu);
	RegConsoleCmd("sm_tienda", DOMenu);
	RegConsoleCmd("sm_premios", DOMenu);
	//RegConsoleCmd("buyammo2", DOMenu);
	HookEvent("round_end", FinRonda);
	HookEvent("round_start", InicioRonda);
	
	RegAdminCmd("sm_setcredits", FijarCreditos, ADMFLAG_ROOT);
	
	CreateConVar("sm_FranugJailBreak", VERSION, "plugin info", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
    for(new client = 1; client <= MaxClients; client++)
    {
		if(IsClientInGame(client))
		{
			if(AreClientCookiesCached(client))
			{
				OnClientCookiesCached(client);
			}
		}
	}
}

public OnClientCookiesCached(client)
{
	new String:CreditsString[12];
	GetClientCookie(client, c_GameCredits, CreditsString, sizeof(CreditsString));
	g_creditos[client]  = StringToInt(CreditsString);
}

public Action:InicioRonda(Handle:event, const String:name[], bool:dontBroadcast)
{
	PrintToChatAll(" \x04[Franug-JailBreak] \x03%t" ,"Escribe !premios para gastar tus creditos en premios");
}

public OnPluginEnd()
{
	CloseHandle(array_premios);
	CloseHandle(array_rondas);
	
	for(new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			OnClientDisconnect(client);
		}
	}
}

RenewMenus()
{
	for (new i = 1; i < MaxClients; i++)
		if(IsClientInGame(i))
		{
			if(menus[i] != INVALID_HANDLE) CloseHandle(menus[i]);
			menus[i] = INVALID_HANDLE;
			CreateMenuClient(i);
		}
}

public OnClientDisconnect(client)
{
	if(menus[client] != INVALID_HANDLE) CloseHandle(menus[client]);
	
	menus[client] = INVALID_HANDLE;
	
	if(AreClientCookiesCached(client))
	{
		new String:CreditsString[12];
		Format(CreditsString, sizeof(CreditsString), "%i", g_creditos[client]);
		SetClientCookie(client, c_GameCredits, CreditsString);
	}
}

public Action:DOMenu2(client,args)
{
	PrintToChat(client, " \x04[Franug-JailBreak] \x05%t" ,"Tus creditos", g_creditos[client]);
	return Plugin_Handled;
}

public Action:DOMenu(client,args)
{
	CreateMenuClient(client);
	DisplayMenu(menus[client], client, MENU_TIME_FOREVER);
	PrintToChat(client, " \x04[Franug-JailBreak] \x05%t" ,"Tus creditos", g_creditos[client]);
	return Plugin_Handled;
}

CreateMenuClient(clientId) 
{
	if(menus[clientId] == INVALID_HANDLE)
	{
		menus[clientId] = CreateMenu(DIDMenuHandler);
		SetMenuTitle(menus[clientId], "JailBreak by Franug");
		decl String:MenuItem[128];
		decl String:tnombre[32];
		decl String:tparaquien[32];
		decl String:creditos[32];
	
		new Handle:array_premios_clon = CloneArray(array_premios);
	
		while(GetArraySize(array_premios_clon)>0)
		{
			new menor;
			new Items[GetArraySize(array_premios_clon)][Premios];
			for(new i2=0;i2<GetArraySize(array_premios_clon);++i2)
			{
				GetArrayArray(array_premios_clon, i2, Items[i2][0]);
			
				if(Items[i2][precio] <= Items[menor][precio])
				{
					menor = i2;
				}
			}

			Format(tnombre, sizeof(tnombre),"%T", Items[menor][Nombre], clientId);
			switch(Items[menor][quien])
			{
				case JB_GUARDS:Format(tparaquien, 32, "%T", "Guardias", clientId);
				case JB_PRISIONERS:Format(tparaquien, 32, "%T", "Presos", clientId);
				case JB_BOTH:Format(tparaquien, 32, "%T", "Ambos", clientId);
			}
			Format(creditos, sizeof(creditos),"%T", "Creditos", clientId);
		
			Format(MenuItem, sizeof(MenuItem),"%s (%s) - %i %s",tnombre, tparaquien, Items[menor][precio], creditos);
			AddMenuItem(menus[clientId], Items[menor][Nombre], MenuItem);
		
			RemoveFromArray(array_premios_clon, menor);
		
		}
		CloseHandle(array_premios_clon);
	
	
		SetMenuExitButton(menus[clientId], true);
	}
}

public DIDMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		decl String:info[64];
		new Items[Premios];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		for(new i=0;i<GetArraySize(array_premios);++i)
		{
			GetArrayArray(array_premios, i, Items[0]);
			if(StrEqual(Items[Nombre], info))
			{
				break;
			}
		}
		
		
		if (g_creditos[client] >= Items[precio])
		{
			if (IsPlayerAlive(client))
			{
				if (Items[quien] == JB_BOTH || (GetClientTeam(client) == CS_TEAM_T && Items[quien] == JB_PRISIONERS) || (GetClientTeam(client) == CS_TEAM_CT && Items[quien] == JB_GUARDS))
				{
					if(special[client])
					{
						PrintToChat(client," \x04[Franug-JailBreak] \x05%t","No puedes comprar cosas siendo un ser especial");
						return;
					}
					g_creditos[client] -= Items[precio];
						
					Call_StartForward(EnPremioComprado);
					Call_PushCell(client);
					Call_PushString(info);
					Call_Finish();
				}
				else
				{
					PrintToChat(client, " \x04[Franug-JailBreak] \x05%t","Este premio no esta disponible para tu equipo");
				}
			}
			else
			{
				PrintToChat(client, " \x04[Franug-JailBreak] \x05%t","Tienes que estar vivo para poder comprar premios");
			}
		}
		else
		{
			PrintToChat(client, " \x04[Franug-JailBreak] \x05%t","Necesitas creditos", g_creditos[client],Items[precio]);
		}
		//DID(client);
		DisplayMenuAtItem(menu, client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
		
	}
/* 	else if (action == MenuAction_End)
		CloseHandle(menu); */
}

public OnClientPostAdminCheck(client)
{
	//g_creditos[client] = 0;
	special[client] = false;
	FD[client] = false;
}

public Action:FinRonda(Handle:event, const String:name[], bool:dontBroadcast)
{
	Format(RondaActual, sizeof(RondaActual), "none");
	for (new i = 1; i < MaxClients; i++)
		if(IsClientInGame(i))
		{
			special[i] = false;
			FD[i] = false;
		}
}

public Action:OnChatMessage(&author, Handle:recipients, String:name[], String:message[])
{
	if (FD[author])
	{
		Format(name, MAXLENGTH_NAME, " \x01(\x04LIBRE\x01) %s", name);		
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public OnMapStart()
{
	Format(RondaActual, sizeof(RondaActual), "none");
}

public Action:FijarCreditos(client, args)
{
    if(client == 0)
    {
		//PrintToServer("%t","Command is in-game only");
		return Plugin_Handled;
    }

    if(args < 2) // Not enough parameters
    {
        ReplyToCommand(client, "[SM] Use: sm_setcredits <#userid|name> [amount]");
        return Plugin_Handled;
    }

    decl String:arg2[10];
    //GetCmdArg(1, arg, sizeof(arg));
    GetCmdArg(2, arg2, sizeof(arg2));

    new amount = StringToInt(arg2);
    //new target;

    //decl String:patt[MAX_NAME]

    //if(args == 1) 
    //{ 
    decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 

    // Process the targets 
    decl String:strTargetName[MAX_TARGET_LENGTH]; 
    decl TargetList[MAXPLAYERS], TargetCount; 
    decl bool:TargetTranslate; 

    if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
                                           strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
    { 
          ReplyToTargetError(client, TargetCount); 
          return Plugin_Handled; 
    } 

    // Apply to all targets 
    for (new i = 0; i < TargetCount; i++) 
    { 
        new iClient = TargetList[i]; 
        if (IsClientInGame(iClient)) 
        { 
              g_creditos[iClient] = amount;
              PrintToChat(client, "Set %i credits in the player %N", amount, iClient);
        } 
    } 
    //}  



//    SetEntProp(target, Prop_Data, "m_iDeaths", amount);


    return Plugin_Continue;
}

public IsValidClient( client ) 
{ 
	if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
	return false; 
	
	return true; 

}