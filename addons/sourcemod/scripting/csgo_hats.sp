#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>


enum Hat
{
	String:Name[64],
	String:szModel[PLATFORM_MAX_PATH],
	String:szAttachment[64],
	Float:fPosition[3],
	Float:fAngles[3],
	bool:bBonemerge
}

new g_eHats[1024][Hat];
new g_Elegido[MAXPLAYERS + 1];
new g_hats;
new g_Hat[MAXPLAYERS+1];

new Handle:g_hLookupAttachment = INVALID_HANDLE;

new Handle:c_GameSprays = INVALID_HANDLE;

public Plugin:myinfo = 
{
	name = "CSGO Hat",
	author = "Franc1sco franug",
	description = "",
	version = "1.0",
	url = "servers-cfg.foroactivo.com"
};

public OnPluginStart()
{
	c_GameSprays = RegClientCookie("Hats", "Hats", CookieAccess_Private);
	RegConsoleCmd("sm_hats", Command_Hats);
	
	HookEvent("player_death", PlayerDeath, EventHookMode_Pre);
	

	new Handle:hGameConf = LoadGameConfigFile("hats.gamedata");
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "LookupAttachment");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	g_hLookupAttachment = EndPrepSDKCall();
	
	HookEvent("player_spawn", Event_PlayerSpawn);
	
	for(new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && AreClientCookiesCached(i)) OnClientCookiesCached(i);
	
}

public OnPluginEnd()
{
	for(new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)) OnClientDisconnect(i);
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	CreateTimer(3.5, Tiempo, client);
}

public Action:Tiempo(Handle:timer, any:client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) > 1) CreateHat(client);
}

public Action:Command_Hats(client, args)
{	
	new Handle:menu = CreateMenu(DIDMenuHandler);
	SetMenuTitle(menu, "Choose Hat");
	decl String:item[4];
	for (new i=0; i<g_hats; ++i) {
		Format(item, 4, "%i", i);
		AddMenuItem(menu, item, g_eHats[i][Name]);
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
}

public DIDMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		decl String:info[4];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		g_Elegido[client] = StringToInt(info);
		PrintToChat(client, " \x04[Franug-Hats]\x01 You have choosen\x03 %s!",g_eHats[g_Elegido[client]][Name]);
		CreateHat(client);
	}
	else if (action == MenuAction_Cancel) 
	{ 
		PrintToServer("Client %d's menu was cancelled.  Reason: %d", client, itemNum); 
	} 
		
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public LoadHats()
{
	g_hats = 0;
	
	new String:sConfig[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sConfig, PLATFORM_MAX_PATH, "configs/csgo_hats.txt");
	
	new Handle:kv = CreateKeyValues("Hats");
	FileToKeyValues(kv, sConfig);

	if(KvGotoFirstSubKey(kv))
	{
		do
		{
			decl Float:m_fTemp[3];
			KvGetSectionName(kv, g_eHats[g_hats][Name], 64);
			KvGetString(kv, "model", g_eHats[g_hats][szModel], PLATFORM_MAX_PATH);
			KvGetVector(kv, "position", m_fTemp);
			g_eHats[g_hats][fPosition] = m_fTemp;
			KvGetVector(kv, "angles", m_fTemp);
			g_eHats[g_hats][fAngles] = m_fTemp;
			g_eHats[g_hats][bBonemerge] = (KvGetNum(kv, "bonemerge", 0)?true:false);
			KvGetString(kv, "attachment", g_eHats[g_hats][szAttachment], 64, "forward");
					
			if(!StrEqual(g_eHats[g_hats][szModel], "none") && strcmp(g_eHats[g_hats][szModel], "")!=0 && (FileExists(g_eHats[g_hats][szModel]) || FileExists(g_eHats[g_hats][szModel], true)))
				PrecacheModel(g_eHats[g_hats][szModel], true);
			
			++g_hats;
		} while (KvGotoNextKey(kv));
	}
	CloseHandle(kv);
}

stock LookupAttachment(client, String:point[])
{
    if(g_hLookupAttachment==INVALID_HANDLE) return 0;
    if( client<=0 || !IsClientInGame(client) ) return 0;
    return SDKCall(g_hLookupAttachment, client, point);
}

public OnMapStart()
{
	LoadHats();
}



CreateHat(client)
{	
		if(!IsPlayerAlive(client))
			return;
		
		//PrintToChatAll("paso0");
		if(!LookupAttachment(client, g_eHats[g_Elegido[client]][szAttachment]))
		{
			return;
		}
		
		//PrintToChatAll("paso1");
		RemoveHat(client);
		if(StrEqual(g_eHats[g_Elegido[client]][szModel], "none")) return;
		
		//PrintToChatAll("paso2");
		
		
		// Calculate the final position and angles for the hat
		decl Float:m_fHatOrigin[3];
		decl Float:m_fHatAngles[3];
		decl Float:m_fForward[3];
		decl Float:m_fRight[3];
		decl Float:m_fUp[3];
		GetClientAbsOrigin(client,m_fHatOrigin);
		GetClientAbsAngles(client,m_fHatAngles);
		
		m_fHatAngles[0] += g_eHats[g_Elegido[client]][fAngles][0];
		m_fHatAngles[1] += g_eHats[g_Elegido[client]][fAngles][1];
		m_fHatAngles[2] += g_eHats[g_Elegido[client]][fAngles][2];

		new Float:m_fOffset[3];
		m_fOffset[0] = g_eHats[g_Elegido[client]][fPosition][0];
		m_fOffset[1] = g_eHats[g_Elegido[client]][fPosition][1];
		m_fOffset[2] = g_eHats[g_Elegido[client]][fPosition][2];

		GetAngleVectors(m_fHatAngles, m_fForward, m_fRight, m_fUp);

		m_fHatOrigin[0] += m_fRight[0]*m_fOffset[0]+m_fForward[0]*m_fOffset[1]+m_fUp[0]*m_fOffset[2];
		m_fHatOrigin[1] += m_fRight[1]*m_fOffset[0]+m_fForward[1]*m_fOffset[1]+m_fUp[1]*m_fOffset[2];
		m_fHatOrigin[2] += m_fRight[2]*m_fOffset[0]+m_fForward[2]*m_fOffset[1]+m_fUp[2]*m_fOffset[2];
		
		// Create the hat entity
		new m_iEnt = CreateEntityByName("prop_dynamic_override");
		DispatchKeyValue(m_iEnt, "model", g_eHats[g_Elegido[client]][szModel]);
		DispatchKeyValue(m_iEnt, "spawnflags", "256");
		DispatchKeyValue(m_iEnt, "solid", "0");
		SetEntPropEnt(m_iEnt, Prop_Send, "m_hOwnerEntity", client);
		
		if(g_eHats[g_Elegido[client]][bBonemerge])
			Bonemerge(m_iEnt);
		
		DispatchSpawn(m_iEnt);	
		AcceptEntityInput(m_iEnt, "TurnOn", m_iEnt, m_iEnt, 0);
		
		// Save the entity index
		g_Hat[client]=m_iEnt;
		
		// We don't want the client to see his own hat
		SDKHook(m_iEnt, SDKHook_SetTransmit, ShouldHide);
		
		// Teleport the hat to the right position and attach it
		TeleportEntity(m_iEnt, m_fHatOrigin, m_fHatAngles, NULL_VECTOR); 
		
		SetVariantString("!activator");
		AcceptEntityInput(m_iEnt, "SetParent", client, m_iEnt, 0);
		
		SetVariantString(g_eHats[g_Elegido[client]][szAttachment]);
		AcceptEntityInput(m_iEnt, "SetParentAttachmentMaintainOffset", m_iEnt, m_iEnt, 0);
}

public Bonemerge(ent)
{
	new m_iEntEffects = GetEntProp(ent, Prop_Send, "m_fEffects"); 
	m_iEntEffects &= ~32;
	m_iEntEffects |= 1;
	m_iEntEffects |= 128;
	SetEntProp(ent, Prop_Send, "m_fEffects", m_iEntEffects); 
}

public Action:PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	RemoveHat(client);
}

public OnClientCookiesCached(client)
{
	new String:SprayString[12];
	GetClientCookie(client, c_GameSprays, SprayString, sizeof(SprayString));
	g_Elegido[client]  = StringToInt(SprayString);
}

public OnClientDisconnect(client)
{
	if(AreClientCookiesCached(client))
	{
		new String:SprayString[12];
		Format(SprayString, sizeof(SprayString), "%i", g_Elegido[client]);
		SetClientCookie(client, c_GameSprays, SprayString);
	}
	RemoveHat(client);
}

public Action:ShouldHide(ent, client)
{
	if(ent == g_Hat[client])
		return Plugin_Handled;
			
	if(IsClientInGame(client))
		if(GetEntProp(client, Prop_Send, "m_iObserverMode") == 4 && GetEntPropEnt(client, Prop_Send, "m_hObserverTarget")>=0)
			if(ent == g_Hat[GetEntPropEnt(client, Prop_Send, "m_hObserverTarget")])
				return Plugin_Handled;
	
	return Plugin_Continue;
}

public RemoveHat(client)
{
	if (g_Hat[client] != 0 && IsValidEdict(g_Hat[client]))
	{
		AcceptEntityInput(g_Hat[client], "Kill");
		SDKUnhook(g_Hat[client], SDKHook_SetTransmit, ShouldHide);
		g_Hat[client] = 0;
	}
}
