--locals
--local is_hidden_map = string.StartWith(game.GetMap(), "hdn_") and true or false
local team_indexable = {[TEAM_CONNECTING] = {}, [TEAM_SPECTATOR] = {}, [TEAM_UNASSIGNED] = {}, [TEAM_SURVIVOR] = {}, [TEAM_ANGEL] = {}, [TEAM_BUILDER] = {}}
local team_methods = table.Copy(team_indexable)
local team_retro = WEEPING_ANGELS.PlayerTeamRetro or {}
local team_rosters = WEEPING_ANGELS.PlayerTeamRosters or table.Copy(team_indexable)
local observers = {[TEAM_CONNECTING] = true, [TEAM_SPECTATOR] = true, [TEAM_UNASSIGNED] = true}

--local tables
local teams = {
	[TEAM_SURVIVOR] = {
		Class = "player_survivor",
		Color = Color(64, 72, 255),
		PrintName = "Survivors",
	},
	
	[TEAM_ANGEL] = {
		Class = "player_angel",
		Color = Color(255, 64, 64),
		PrintName = "Weeping Angels",
	},
	
	[TEAM_BUILDER] = {
		Class = "player_builder",
		Color = Color(255, 192, 128),
		PrintName = "Builder"
	}
}

--globals
GM.PlayerTeams = teams
WEEPING_ANGELS.PlayerTeamRetro = team_retro
WEEPING_ANGELS.PlayerTeamRosters = team_rosters

--gamemode functions
function GM:PlayerTeamIsActor(team_id)
	if IsEntity(team_id) then return self:PlayerTeamIsActor(team_id:Team()) end

	return not observers[team_id]
end

function GM:PlayerTeamIsObserver(team_id)
	if IsEntity(team_id) then return self:PlayerTeamIsObserver(team_id:Team()) end
	
	return observers[team_id] or false
end

function GM:PlayerTeamRegisterMethod(team_index, key, method) team_methods[team_index][key] = method end

function GM:PlayerTeamRunMethod(ply, key, ...)
	if isstring(ply) then return self:PlayerTeamRunMethod(LocalPlayer(), ply, key, ...) end
	
	local method = team_methods[ply:Team()][key]
	
	if method then return method(ply, ...) end
end

--gamemode hooks
function GM:CreateTeams()
	for index, data in ipairs(teams) do
		team.SetUp(index, data.PrintName, data.Color)
		team.SetClass(index, data.Class)
	end
end