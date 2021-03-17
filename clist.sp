#include <sourcemod>

#pragma semicolon 1

new const String:PLUGIN_NAME[] = "Command List";
new const String:PLUGIN_VERSION[] = "1.0";

public Plugin:myinfo =
{
	name = PLUGIN_NAME,
	author = "hlmod <3",
	description = "Показывает игрокам список всех команд, которые они могут использовать.",
	version = PLUGIN_VERSION,
	url = "hlmod.ru"
}


public OnPluginStart()
{
	CreateConVar("command_list_ver", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_PRINTABLEONLY);
	
	RegConsoleCmd("sm_commands", OnCommands);
}

public Action:OnCommands(iClient, iArgCount)
{
	if(!iClient)
		return Plugin_Handled;
	
	DisplayMenu_Commands(iClient);
	
	return Plugin_Handled;
}

DisplayMenu_Commands(iClient, iStartItem=0)
{
	new Handle:hMenu = CreateMenu(MenuHandle_Commands);
	SetMenuTitle(hMenu, "Command List");
	
	new Handle:hIter = GetCommandIterator();
	decl String:szName[64], String:szDescription[256], iFlags;
	while(ReadCommandIterator(hIter, szName, sizeof(szName), iFlags, szDescription, sizeof(szDescription)))
	{
		// Продолжайте, если это не команда для всех.
		if(iFlags)
			continue;
		
		if(!CheckCommandAccess(iClient, szName, -1, false))
			continue;
		
		if(szDescription[0])
			Format(szDescription, sizeof(szDescription), "%s - %s", szName, szDescription);
		else
			FormatEx(szDescription, sizeof(szDescription), "%s", szName);
		
		AddMenuItem(hMenu, "", szDescription, ITEMDRAW_DISABLED);
	}
	
	CloseHandle(hIter);
	
	if(!DisplayMenuAtItem(hMenu, iClient, iStartItem, 0))
		ReplyToCommand(iClient, "[SM] Там нет команд!");
}

public MenuHandle_Commands(Handle:hMenu, MenuAction:action, iParam1, iParam2)
{
	if(action == MenuAction_End)
	{
		CloseHandle(hMenu);
		return;
	}
	
	if(action != MenuAction_Select)
		return;
	
	DisplayMenu_Commands(iParam1, GetMenuSelectionPosition());
}