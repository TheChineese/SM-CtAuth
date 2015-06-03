#include <sourcemod>
#include <multicolors>
#include <stamm>
#undef REQUIRE_PLUGIN
#include <updater>
#define UPDATE_URL    "http://bitbucket.toastdev.de/sourcemod-plugins/raw/master/CTAuth.txt"
new Handle:c_Amount;
new amount_points;
public Plugin:myinfo = 
{
	name = "CT Auth",
	author = "Toast",
	description = "Adds the option to restrict CT Team by Stamm Points",
	version = "1.0.3",
	url = "bitbucket.org/Toastbrot_290"
}

public OnPluginStart()
{
	CreateConVar("ctauth_amount_points", "10", "How many Points are needed for joining the CT Team");
	c_Amount = FindConVar("ctauth_amount_points");
	amount_points = GetConVarInt(c_Amount);
	HookConVarChange(c_Amount, ConVarChanged);
	
	LoadTranslations("CTAuth.phrases");
	
	AutoExecConfig(true, "ctauth");
	
	AddCommandListener(TeamJoin, "jointeam");
	
	if (LibraryExists("updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}

public OnLibraryAdded(const String:name[])
{
    if (StrEqual(name, "updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}
public ConVarChanged(Handle:cvar, const String:oldValue[], const String:newValue[]) {
	
	if(cvar == c_Amount){
		amount_points = StringToInt(newValue);
	}
	
}


public Action:TeamJoin(client, const String:command[], args)
{
	if(!IsClientInGame(client) || !STAMM_IsClientValid(client)){
		return Plugin_Stop;
	}
	new String:Team[2];
	GetCmdArg(1, Team, sizeof(Team));
	new TargetTeam = StringToInt(Team);
	
	if(TargetTeam == 3 || TargetTeam == 0)
	{
		new points = STAMM_GetClientPoints(client);
		if(points >= amount_points)
		{
			return Plugin_Continue;
		}
		new diff = amount_points - points;
		CPrintToChat(client, "%t %t", "prefix", "error_not_enough_points", amount_points, points, diff);
		
		new String:ClientName[MAX_NAME_LENGTH];
		GetClientName(client, ClientName, sizeof(ClientName));
		CPrintToChatAll("%t %t", "prefix", "error_not_enough_points_all", ClientName);
		PrintCenterText(client, "%t %t", "prefix_plain", "error_not_enough_points_plain", amount_points, points, diff);
		if(TargetTeam == 0){
			ChangeClientTeam(client, 2);
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
}