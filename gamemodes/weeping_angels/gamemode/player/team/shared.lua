--locals
local is_hidden_map = string.StartWith(game.GetMap(), "hdn_") and true or false
local team_indexable = {[TEAM_CONNECTING] = {}, [TEAM_SPECTATOR] = {}, [TEAM_UNASSIGNED] = {}, [TEAM_SURVIVOR] = {}, [TEAM_ANGEL] = {}}
local team_methods = table.Copy(team_indexable)

--local tables
local teams = {
	[TEAM_SURVIVOR] = {
		Class = "player_survivor",
		Color = Color(64, 72, 255),
		Key = "SURVIVOR",
		PrintName = "Survivors",
		SpawnPoint = is_hidden_map and "info_marine_spawn"
	},
	
	[TEAM_ANGEL] = {
		Class = "player_angel",
		Color = Color(255, 64, 64),
		Key = "ANGEL",
		PrintName = "Weeping Angels",
		SpawnPoint = is_hidden_map and "info_hidden_spawn"
	}
}

local team_rosters = WEEPING_ANGELS.PlayerTeamRosters or table.Copy(team_indexable)

--globals
GM.PlayerTeams = teams
WEEPING_ANGELS.PlayerTeamRosters = team_rosters

--gamemode functions
function GM:TeamRegisterMethod(team_index, key, method) team_methods[team_index][key] = method end

function GM:TeamRunMethod(ply, key, ...)
	if isstring(ply) then return self:TeamRunMethod(LocalPlayer(), ply, key, ...) end
	
	local method = team_methods[ply:Team()][key]
	
	if method then return method(ply, ...) end
end

--gamemode hooks
function GM:CreateTeams()
	for index, data in ipairs(teams) do
		team.SetUp(index, data.PrintName, data.Color)
		team.SetClass(index, data.Class)
		team.SetSpawnPoint(index, data.SpawnPoint or "info_player_start")
	end
end

--post
if is_hidden_map then
	team.SetSpawnPoint(TEAM_CONNECTING, "info_spectator")
	team.SetSpawnPoint(TEAM_SPECTATOR, "info_spectator")
	team.SetSpawnPoint(TEAM_UNASSIGNED, "info_spectator")
end