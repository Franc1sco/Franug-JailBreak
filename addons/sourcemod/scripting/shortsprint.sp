/*
 * SourceMod ShortSprint Plugin
 * Copyright (C) 2009-2013 Martin Walter
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * Thanks to:
 * - Shaman (Alican Çubukçuoglu), who released a sprint plugin for SourceMod in
 *   2007 called "Sprint: Source".
 * - blade81, who used a unreleased plugin with progress bar and sprint sound on
 *   the Gamerz Paradise CS:S soccer servers in 2009.
 * - SWAT_88, who released the SM Parachute plugin with added +use button support
 *   in 2008.
 * - Forlix (Dominik Friedrichs), who helped me a lot with scripting.
 */

#include <sourcemod>
#include <sdktools>
#include <clientprefs>

#pragma semicolon 1

#define PLUGIN_VERSION       "1.20"
#define PLUGIN_VERSION_CVAR  "sm_shortsprint_version"

//Chat Colours
#define YELLOW 0x01
#define LIGHTGREEN 0x03
#define GREEN 0x04

#define PANEL_COMMAND        "shortsprint"

#define SPRINT_COMMAND       "sprint"

#define SOUND_SPRINT         "player/suit_sprint.wav"

#define TRANSLATION_FILE     "shortsprint.phrases.txt"

#define CLIENT_SPRINTUSING   (1<<0)
#define CLIENT_SPRINTUNABLE  (1<<1)
#define CLIENT_MESSAGEUSING  (1<<2)
#define CLIENT_ANNOUNCEMENT  (1<<3)

new iCLIENT_STATUS[MAXPLAYERS+1];

new Handle:h_SPRINT_TIMERS[MAXPLAYERS+1];

new bool:bLATE_LOAD = false;

#include "shortsprint/convars.sp"
#include "shortsprint/clientsettings.sp"
#include "shortsprint/infopanel.sp"
#include "shortsprint/timers.sp"
#include "shortsprint/events.sp"

public Plugin:myinfo =
{
  name = "ShortSprint",
  author = "walmar (Martin Walter)",
  description = "Players can sprint for a short time.",
  version = PLUGIN_VERSION,
  url = "https://github.com/walmar"
};

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
  bLATE_LOAD = late;
  return(APLRes_Success);
}

public OnPluginEnd()
{
  //Clientprefs
  WriteEveryClientCookie();
  return;
}

public OnPluginStart()
{
  SetupConVars();

  //Commands
  RegConsoleCmd(SPRINT_COMMAND, Command_StartSprint, "Starts the sprint.");

  RegConsoleCmd(PANEL_COMMAND, Command_InfoPanel,
  "Opens the ShortSprint InfoPanel.");

  //Event Hooks
  HookEvent("round_start", Event_RoundStart);
  HookEvent("player_spawn", Event_PlayerSpawn);
  HookEvent("player_death", Event_PlayerDeath);

  //Clientprefs
  RegSprintCookie();

  return;
}

public OnMapStart()
{
  LoadTranslations(TRANSLATION_FILE);

  PrecacheSound(SOUND_SPRINT, true);

  if(bLATE_LOAD)
  {
    SetEveryClientDefaultSettings();
    //Clientprefs
    ReadEveryClientCookie();
  }
  bLATE_LOAD = false;

  return;
}

public OnClientConnected(client)
{
  SetDefaultClientSettings(client);
  return;
}

//Client settings
public OnClientCookiesCached(client)
{
  if(IsClientConnected(client))
  {
    ReadClientCookie(client);
  }
  return;
}

public OnClientDisconnect(client)
{
  WriteClientCookie(client);
  return;
}
//

public Action:Command_StartSprint(client, args)
{
  if(bSPRINT_ENABLED && client > 0 && IsClientInGame(client)
  && IsPlayerAlive(client) && GetClientTeam(client) > 1
  && !(iCLIENT_STATUS[client] & CLIENT_SPRINTUSING)
  && !(iCLIENT_STATUS[client] & CLIENT_SPRINTUNABLE))
  {
    iCLIENT_STATUS[client] |= CLIENT_SPRINTUSING | CLIENT_SPRINTUNABLE;

    //Set sprint speed
    SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", fSPRINT_SPEED);
    //----

    //Outputs
    if(iP_SETTINGS[client] & PLAYER_SOUND)
    {
      EmitSoundToClient(client, SOUND_SPRINT, SOUND_FROM_PLAYER, SNDCHAN_AUTO,
      SNDLEVEL_NORMAL, SND_NOFLAGS, 0.8);
    }

    if(iP_SETTINGS[client] & PLAYER_MESSAGES)
    {
      PrintToChat(client, "%c%t", LIGHTGREEN, "CHAT_MSG_SPRINTUSING");

      iCLIENT_STATUS[client] |= CLIENT_MESSAGEUSING;
    }
    //----

    h_SPRINT_TIMERS[client] = CreateTimer(fSPRINT_TIME, Timer_SprintEnd, client);
  }
  return(Plugin_Handled);
}

public OnGameFrame()
{
  if(bSPRINT_BUTTON)
  {
    for(new i = 1; i <= MaxClients; i++)
    {
      if(IsClientInGame(i) && (GetClientButtons(i) & IN_USE))
      {
        Command_StartSprint(i, 0);
      }
    }
  }
  return;
}

////////////////////////////////////////////////////////////////////////////////
//Default settings
SetDefaultClientSettings(client)
{
  iCLIENT_STATUS[client] = 0;
  if(bANNOUNCEMENT)
  {
    iCLIENT_STATUS[client] |= CLIENT_ANNOUNCEMENT;
  }

  h_SPRINT_TIMERS[client] = INVALID_HANDLE;

  iP_SETTINGS[client] = DEF_SPRINT_COOKIE;

  return;
}

SetEveryClientDefaultSettings()
{
  for(new client = 1; client <= MaxClients; client++)
  {
    if(IsClientInGame(client))
    {
      SetDefaultClientSettings(client);
    }
  }
  return;
}

////////////////////////////////////////////////////////////////////////////////
//Reset
ResetSprint(client)
{
  if(h_SPRINT_TIMERS[client] != INVALID_HANDLE)
  {
    KillTimer(h_SPRINT_TIMERS[client]);
    h_SPRINT_TIMERS[client] = INVALID_HANDLE;
  }

  //Reset sprint speed
  if(GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue") != 1)
  {
    SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
  }

  if(iCLIENT_STATUS[client] & CLIENT_SPRINTUSING)
  {
    iCLIENT_STATUS[client] &= ~ CLIENT_SPRINTUSING;
    PrintSprintEndMsgToClient(client);
  }

  return;
}

////////////////////////////////////////////////////////////////////////////////
//Outputs
PrintAnnouncementMsg(client)
{
  decl String:sBuf[64];
  Format(sBuf, sizeof(sBuf), "%c%s%s%c", LIGHTGREEN, sCHAT_TRIGGER,
  PANEL_COMMAND, YELLOW);

  if(client)
  {
    //PrintToChat(client, "%cShortSprint%c - %t", GREEN, YELLOW,
   // "CHAT_MSG_ANNOUNCEMENT", sBuf);
  }
  else
  {
    //PrintToChatAll("%cShortSprint%c - %t", GREEN, YELLOW,
	//"CHAT_MSG_ANNOUNCEMENT", sBuf);
  }

  return;
}

PrintSprintEndMsgToClient(client)
{
  if(iCLIENT_STATUS[client] & CLIENT_MESSAGEUSING)
  {
    PrintToChat(client, "%c%t", LIGHTGREEN, "CHAT_MSG_SPRINTENDING");
  }
  return;
}

PrintSprintCDMsgToClient(client)
{
  if(iCLIENT_STATUS[client] & CLIENT_MESSAGEUSING)
  {
    PrintToChat(client, "%c%t", GREEN, "CHAT_MSG_SPRINTABLE");
    iCLIENT_STATUS[client] &= ~ CLIENT_MESSAGEUSING;
  }
  return;
}

SendProgressBarResetToClient(client)
{
  if(GetEntProp(client, Prop_Send, "m_iProgressBarDuration", 4))
  {
    SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);
  }
  return;
}