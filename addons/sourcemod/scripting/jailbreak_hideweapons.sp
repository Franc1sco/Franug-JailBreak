#include <sourcemod>
#include <sdkhooks>

public OnPluginStart()
{
    
    for (new i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
            OnClientPutInServer(i);
    }
}

public OnClientPutInServer(client)
{
    SDKHook(client, SDKHook_PostThinkPost, OnPostThinkPost);
}

public OnPostThinkPost(client)
{
    SetEntProp(client, Prop_Send, "m_iAddonBits", 0);
}