#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

public OnPluginStart()
{
	RegConsoleCmd("sm_normas", DOMenu);
	RegConsoleCmd("sm_reglas", DOMenu);
	RegConsoleCmd("sm_rules", DOMenu);
}

public Action:DOMenu(client,args)
{
	decl String:url[512];
	Format(url, 512, "http://www.claninspired.com/foro/index.php/topic,613.0.html");
	FixMotdCSGO(url);
	
	ShowMOTDPanel(client, "JailBreak by Franug", url, MOTDPANEL_TYPE_URL);
}

stock FixMotdCSGO(String:web[512])
{
	Format(web, sizeof(web), "http://www.cola-team.es/franug/webshortcuts.html?web=%s", web);
}