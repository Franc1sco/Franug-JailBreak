#include <sourcemod>
#include <sdktools>
#include <franug_jb>
#include <captain>

public OnPluginStart()
{
	CreateTimer(0.2, Hud, _, TIMER_REPEAT);
}

public Action:Hud(Handle:timer)
{
	decl String:texto[512];
	decl String:ronda[64];
	if(!JB_GetRound(ronda)) Format(texto, 512, "Day not selected yet");
	else Format(texto, 512, "Day %s", ronda);
	
/* 	if(!JB_GetRound(ronda)) Format(texto, 512, "Day not selectec yet");
	else Format(texto, 512, "Day %s", ronda); */
	
	if(StrEqual(ronda, "Simon", false))
	{
		new simon = JC_GetCaptain();
		if(simon > 0) Format(texto, 512, "%s\nSimon is %N", texto,simon);
		else Format(texto, 512, "%s\nNo Simon selected", texto);
		
/* 		if(simon > 0) Format(texto, 512, "%s\nSimon is %N", texto,simon);
		else Format(texto, 512, "%s\nNo exist a Simon", texto); */
	}
	for (new i = 1; i < MaxClients; i++)
		if(IsClientInGame(i))
		{
			PrintHintText(i, "%s\nYour credits: %i", texto,JB_GetCredits(i));
			
			//PrintHintText(i, "%s\nTus creditos: %i", texto,JB_GetCredits(i));
		}
}